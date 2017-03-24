//===---- CGBuiltin.cpp - Emit LLVM Code for builtins ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This contains code to emit Objective-C code as LLVM code.
//
//===----------------------------------------------------------------------===//

#include "CGDebugInfo.h"
#include "CGObjCRuntime.h"
#include "CodeGenFunction.h"
#include "CodeGenModule.h"
#include "TargetInfo.h"
#include "clang/AST/ASTContext.h"
#include "clang/AST/DeclObjC.h"
#include "clang/AST/StmtObjC.h"
#include "clang/Basic/Diagnostic.h"
#include "clang/CodeGen/CGFunctionInfo.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/IR/CallSite.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/InlineAsm.h"
using namespace clang;
using namespace CodeGen;

typedef llvm::PointerIntPair<llvm::Value*,1,bool> TryEmitResult;
static TryEmitResult
tryEmitARCRetainScalarExpr(CodeGenFunction &CGF, const Expr *e);
static RValue AdjustObjCObjectType(CodeGenFunction &CGF,
                                   QualType ET,
                                   RValue Result);

/// Given the address of a variable of pointer type, find the correct
/// null to store into it.
static llvm::Constant *getNullForVariable(Address addr) {
  llvm::Type *type = addr.getElementType();
  return llvm::ConstantPointerNull::get(cast<llvm::PointerType>(type));
}

/// Emits an instance of NSConstantString representing the object.
llvm::Value *CodeGenFunction::EmitObjCStringLiteral(const ObjCStringLiteral *E)
{
  llvm::Constant *C = 
      CGM.getObjCRuntime().GenerateConstantString(E->getString()).getPointer();
  // FIXME: This bitcast should just be made an invariant on the Runtime.
  return llvm::ConstantExpr::getBitCast(C, ConvertType(E->getType()));
}

/// EmitObjCBoxedExpr - This routine generates code to call
/// the appropriate expression boxing method. This will either be
/// one of +[NSNumber numberWith<Type>:], or +[NSString stringWithUTF8String:],
/// or [NSValue valueWithBytes:objCType:].
///
llvm::Value *
CodeGenFunction::EmitObjCBoxedExpr(const ObjCBoxedExpr *E) {
  // Generate the correct selector for this literal's concrete type.
  // Get the method.
  const ObjCMethodDecl *BoxingMethod = E->getBoxingMethod();
  const Expr *SubExpr = E->getSubExpr();
  assert(BoxingMethod && "BoxingMethod is null");
  assert(BoxingMethod->isClassMethod() && "BoxingMethod must be a class method");
  Selector Sel = BoxingMethod->getSelector();
  
  // Generate a reference to the class pointer, which will be the receiver.
  // Assumes that the method was introduced in the class that should be
  // messaged (avoids pulling it out of the result type).
  CGObjCRuntime &Runtime = CGM.getObjCRuntime();
  const ObjCInterfaceDecl *ClassDecl = BoxingMethod->getClassInterface();
  llvm::Value *Receiver = Runtime.GetClass(*this, ClassDecl);

  CallArgList Args;
  const ParmVarDecl *ArgDecl = *BoxingMethod->param_begin();
  QualType ArgQT = ArgDecl->getType().getUnqualifiedType();
  
  // ObjCBoxedExpr supports boxing of structs and unions 
  // via [NSValue valueWithBytes:objCType:]
  const QualType ValueType(SubExpr->getType().getCanonicalType());
  if (ValueType->isObjCBoxableRecordType()) {
    // Emit CodeGen for first parameter
    // and cast value to correct type
    Address Temporary = CreateMemTemp(SubExpr->getType());
    EmitAnyExprToMem(SubExpr, Temporary, Qualifiers(), /*isInit*/ true);
    Address BitCast = Builder.CreateBitCast(Temporary, ConvertType(ArgQT));
    Args.add(RValue::get(BitCast.getPointer()), ArgQT);

    // Create char array to store type encoding
    std::string Str;
    getContext().getObjCEncodingForType(ValueType, Str);
    llvm::Constant *GV = CGM.GetAddrOfConstantCString(Str).getPointer();
    
    // Cast type encoding to correct type
    const ParmVarDecl *EncodingDecl = BoxingMethod->parameters()[1];
    QualType EncodingQT = EncodingDecl->getType().getUnqualifiedType();
    llvm::Value *Cast = Builder.CreateBitCast(GV, ConvertType(EncodingQT));

    Args.add(RValue::get(Cast), EncodingQT);
  } else {
    Args.add(EmitAnyExpr(SubExpr), ArgQT);
  }

  RValue result = Runtime.GenerateMessageSend(
      *this, ReturnValueSlot(), BoxingMethod->getReturnType(), Sel, Receiver,
      Args, ClassDecl, BoxingMethod);
  return Builder.CreateBitCast(result.getScalarVal(), 
                               ConvertType(E->getType()));
}

llvm::Value *CodeGenFunction::EmitObjCCollectionLiteral(const Expr *E,
                                    const ObjCMethodDecl *MethodWithObjects) {
  ASTContext &Context = CGM.getContext();
  const ObjCDictionaryLiteral *DLE = nullptr;
  const ObjCArrayLiteral *ALE = dyn_cast<ObjCArrayLiteral>(E);
  if (!ALE)
    DLE = cast<ObjCDictionaryLiteral>(E);
  
  // Compute the type of the array we're initializing.
  uint64_t NumElements = 
    ALE ? ALE->getNumElements() : DLE->getNumElements();
  llvm::APInt APNumElements(Context.getTypeSize(Context.getSizeType()),
                            NumElements);
  QualType ElementType = Context.getObjCIdType().withConst();
  QualType ElementArrayType 
    = Context.getConstantArrayType(ElementType, APNumElements, 
                                   ArrayType::Normal, /*IndexTypeQuals=*/0);

  // Allocate the temporary array(s).
  Address Objects = CreateMemTemp(ElementArrayType, "objects");
  Address Keys = Address::invalid();
  if (DLE)
    Keys = CreateMemTemp(ElementArrayType, "keys");
  
  // In ARC, we may need to do extra work to keep all the keys and
  // values alive until after the call.
  SmallVector<llvm::Value *, 16> NeededObjects;
  bool TrackNeededObjects =
    (getLangOpts().ObjCAutoRefCount &&
    CGM.getCodeGenOpts().OptimizationLevel != 0);

  // Perform the actual initialialization of the array(s).
  for (uint64_t i = 0; i < NumElements; i++) {
    if (ALE) {
      // Emit the element and store it to the appropriate array slot.
      const Expr *Rhs = ALE->getElement(i);
      LValue LV = MakeAddrLValue(
          Builder.CreateConstArrayGEP(Objects, i, getPointerSize()),
          ElementType, AlignmentSource::Decl);

      llvm::Value *value = EmitScalarExpr(Rhs);
      EmitStoreThroughLValue(RValue::get(value), LV, true);
      if (TrackNeededObjects) {
        NeededObjects.push_back(value);
      }
    } else {      
      // Emit the key and store it to the appropriate array slot.
      const Expr *Key = DLE->getKeyValueElement(i).Key;
      LValue KeyLV = MakeAddrLValue(
          Builder.CreateConstArrayGEP(Keys, i, getPointerSize()),
          ElementType, AlignmentSource::Decl);
      llvm::Value *keyValue = EmitScalarExpr(Key);
      EmitStoreThroughLValue(RValue::get(keyValue), KeyLV, /*isInit=*/true);

      // Emit the value and store it to the appropriate array slot.
      const Expr *Value = DLE->getKeyValueElement(i).Value;
      LValue ValueLV = MakeAddrLValue(
          Builder.CreateConstArrayGEP(Objects, i, getPointerSize()),
          ElementType, AlignmentSource::Decl);
      llvm::Value *valueValue = EmitScalarExpr(Value);
      EmitStoreThroughLValue(RValue::get(valueValue), ValueLV, /*isInit=*/true);
      if (TrackNeededObjects) {
        NeededObjects.push_back(keyValue);
        NeededObjects.push_back(valueValue);
      }
    }
  }
  
  // Generate the argument list.
  CallArgList Args;  
  ObjCMethodDecl::param_const_iterator PI = MethodWithObjects->param_begin();
  const ParmVarDecl *argDecl = *PI++;
  QualType ArgQT = argDecl->getType().getUnqualifiedType();
  Args.add(RValue::get(Objects.getPointer()), ArgQT);
  if (DLE) {
    argDecl = *PI++;
    ArgQT = argDecl->getType().getUnqualifiedType();
    Args.add(RValue::get(Keys.getPointer()), ArgQT);
  }
  argDecl = *PI;
  ArgQT = argDecl->getType().getUnqualifiedType();
  llvm::Value *Count = 
    llvm::ConstantInt::get(CGM.getTypes().ConvertType(ArgQT), NumElements);
  Args.add(RValue::get(Count), ArgQT);

  // Generate a reference to the class pointer, which will be the receiver.
  Selector Sel = MethodWithObjects->getSelector();
  QualType ResultType = E->getType();
  const ObjCObjectPointerType *InterfacePointerType
    = ResultType->getAsObjCInterfacePointerType();
  ObjCInterfaceDecl *Class 
    = InterfacePointerType->getObjectType()->getInterface();
  CGObjCRuntime &Runtime = CGM.getObjCRuntime();
  llvm::Value *Receiver = Runtime.GetClass(*this, Class);

  // Generate the message send.
  RValue result = Runtime.GenerateMessageSend(
      *this, ReturnValueSlot(), MethodWithObjects->getReturnType(), Sel,
      Receiver, Args, Class, MethodWithObjects);

  // The above message send needs these objects, but in ARC they are
  // passed in a buffer that is essentially __unsafe_unretained.
  // Therefore we must prevent the optimizer from releasing them until
  // after the call.
  if (TrackNeededObjects) {
    EmitARCIntrinsicUse(NeededObjects);
  }

  return Builder.CreateBitCast(result.getScalarVal(), 
                               ConvertType(E->getType()));
}

llvm::Value *CodeGenFunction::EmitObjCArrayLiteral(const ObjCArrayLiteral *E) {
  return EmitObjCCollectionLiteral(E, E->getArrayWithObjectsMethod());
}

llvm::Value *CodeGenFunction::EmitObjCDictionaryLiteral(
                                            const ObjCDictionaryLiteral *E) {
  return EmitObjCCollectionLiteral(E, E->getDictWithObjectsMethod());
}

/// Emit a selector.
llvm::Value *CodeGenFunction::EmitObjCSelectorExpr(const ObjCSelectorExpr *E) {
  // Untyped selector.
  // Note that this implementation allows for non-constant strings to be passed
  // as arguments to @selector().  Currently, the only thing preventing this
  // behaviour is the type checking in the front end.
  return CGM.getObjCRuntime().GetSelector(*this, E->getSelector());
}

llvm::Value *CodeGenFunction::EmitObjCProtocolExpr(const ObjCProtocolExpr *E) {
  // FIXME: This should pass the Decl not the name.
  return CGM.getObjCRuntime().GenerateProtocolRef(*this, E->getProtocol());
}

/// \brief Adjust the type of an Objective-C object that doesn't match up due
/// to type erasure at various points, e.g., related result types or the use
/// of parameterized classes.
static RValue AdjustObjCObjectType(CodeGenFunction &CGF, QualType ExpT,
                                   RValue Result) {
  if (!ExpT->isObjCRetainableType())
    return Result;

  // If the converted types are the same, we're done.
  llvm::Type *ExpLLVMTy = CGF.ConvertType(ExpT);
  if (ExpLLVMTy == Result.getScalarVal()->getType())
    return Result;

  // We have applied a substitution. Cast the rvalue appropriately.
  return RValue::get(CGF.Builder.CreateBitCast(Result.getScalarVal(),
                                               ExpLLVMTy));
}

/// Decide whether to extend the lifetime of the receiver of a
/// returns-inner-pointer message.
static bool
shouldExtendReceiverForInnerPointerMessage(const ObjCMessageExpr *message) {
  switch (message->getReceiverKind()) {

  // For a normal instance message, we should extend unless the
  // receiver is loaded from a variable with precise lifetime.
  case ObjCMessageExpr::Instance: {
    const Expr *receiver = message->getInstanceReceiver();

    // Look through OVEs.
    if (auto opaque = dyn_cast<OpaqueValueExpr>(receiver)) {
      if (opaque->getSourceExpr())
        receiver = opaque->getSourceExpr()->IgnoreParens();
    }

    const ImplicitCastExpr *ice = dyn_cast<ImplicitCastExpr>(receiver);
    if (!ice || ice->getCastKind() != CK_LValueToRValue) return true;
    receiver = ice->getSubExpr()->IgnoreParens();

    // Look through OVEs.
    if (auto opaque = dyn_cast<OpaqueValueExpr>(receiver)) {
      if (opaque->getSourceExpr())
        receiver = opaque->getSourceExpr()->IgnoreParens();
    }

    // Only __strong variables.
    if (receiver->getType().getObjCLifetime() != Qualifiers::OCL_Strong)
      return true;

    // All ivars and fields have precise lifetime.
    if (isa<MemberExpr>(receiver) || isa<ObjCIvarRefExpr>(receiver))
      return false;

    // Otherwise, check for variables.
    const DeclRefExpr *declRef = dyn_cast<DeclRefExpr>(ice->getSubExpr());
    if (!declRef) return true;
    const VarDecl *var = dyn_cast<VarDecl>(declRef->getDecl());
    if (!var) return true;

    // All variables have precise lifetime except local variables with
    // automatic storage duration that aren't specially marked.
    return (var->hasLocalStorage() &&
            !var->hasAttr<ObjCPreciseLifetimeAttr>());
  }

  case ObjCMessageExpr::Class:
  case ObjCMessageExpr::SuperClass:
    // It's never necessary for class objects.
    return false;

  case ObjCMessageExpr::SuperInstance:
    // We generally assume that 'self' lives throughout a method call.
    return false;
  }

  llvm_unreachable("invalid receiver kind");
}

/// Given an expression of ObjC pointer type, check whether it was
/// immediately loaded from an ARC __weak l-value.
static const Expr *findWeakLValue(const Expr *E) {
  assert(E->getType()->isObjCRetainableType());
  E = E->IgnoreParens();
  if (auto CE = dyn_cast<CastExpr>(E)) {
    if (CE->getCastKind() == CK_LValueToRValue) {
      if (CE->getSubExpr()->getType().getObjCLifetime() == Qualifiers::OCL_Weak)
        return CE->getSubExpr();
    }
  }

  return nullptr;
}

RValue CodeGenFunction::EmitObjCMessageExpr(const ObjCMessageExpr *E,
                                            ReturnValueSlot Return) {
  // Only the lookup mechanism and first two arguments of the method
  // implementation vary between runtimes.  We can get the receiver and
  // arguments in generic code.

  bool isDelegateInit = E->isDelegateInitCall();

  const ObjCMethodDecl *method = E->getMethodDecl();

  // If the method is -retain, and the receiver's being loaded from
  // a __weak variable, peephole the entire operation to objc_loadWeakRetained.
  if (method && E->getReceiverKind() == ObjCMessageExpr::Instance &&
      method->getMethodFamily() == OMF_retain) {
    if (auto lvalueExpr = findWeakLValue(E->getInstanceReceiver())) {
      LValue lvalue = EmitLValue(lvalueExpr);
      llvm::Value *result = EmitARCLoadWeakRetained(lvalue.getAddress());
      return AdjustObjCObjectType(*this, E->getType(), RValue::get(result));
    }
  }

  // We don't retain the receiver in delegate init calls, and this is
  // safe because the receiver value is always loaded from 'self',
  // which we zero out.  We don't want to Block_copy block receivers,
  // though.
  bool retainSelf =
    (!isDelegateInit &&
     CGM.getLangOpts().ObjCAutoRefCount &&
     method &&
     method->hasAttr<NSConsumesSelfAttr>());

  CGObjCRuntime &Runtime = CGM.getObjCRuntime();
  bool isSuperMessage = false;
  bool isClassMessage = false;
  ObjCInterfaceDecl *OID = nullptr;
  // Find the receiver
  QualType ReceiverType;
  llvm::Value *Receiver = nullptr;
  switch (E->getReceiverKind()) {
  case ObjCMessageExpr::Instance:
    ReceiverType = E->getInstanceReceiver()->getType();
    if (retainSelf) {
      TryEmitResult ter = tryEmitARCRetainScalarExpr(*this,
                                                   E->getInstanceReceiver());
      Receiver = ter.getPointer();
      if (ter.getInt()) retainSelf = false;
    } else
      Receiver = EmitScalarExpr(E->getInstanceReceiver());
    break;

  case ObjCMessageExpr::Class: {
    ReceiverType = E->getClassReceiver();
    const ObjCObjectType *ObjTy = ReceiverType->getAs<ObjCObjectType>();
    assert(ObjTy && "Invalid Objective-C class message send");
    OID = ObjTy->getInterface();
    assert(OID && "Invalid Objective-C class message send");
    Receiver = Runtime.GetClass(*this, OID);
    isClassMessage = true;
    break;
  }

  case ObjCMessageExpr::SuperInstance:
    ReceiverType = E->getSuperType();
    Receiver = LoadObjCSelf();
    isSuperMessage = true;
    break;

  case ObjCMessageExpr::SuperClass:
    ReceiverType = E->getSuperType();
    Receiver = LoadObjCSelf();
    isSuperMessage = true;
    isClassMessage = true;
    break;
  }

  if (retainSelf)
    Receiver = EmitARCRetainNonBlock(Receiver);

  // In ARC, we sometimes want to "extend the lifetime"
  // (i.e. retain+autorelease) of receivers of returns-inner-pointer
  // messages.
  if (getLangOpts().ObjCAutoRefCount && method &&
      method->hasAttr<ObjCReturnsInnerPointerAttr>() &&
      shouldExtendReceiverForInnerPointerMessage(E))
    Receiver = EmitARCRetainAutorelease(ReceiverType, Receiver);

  QualType ResultType = method ? method->getReturnType() : E->getType();

  CallArgList Args;
  EmitCallArgs(Args, method, E->arguments(), /*AC*/AbstractCallee(method));

  // For delegate init calls in ARC, do an unsafe store of null into
  // self.  This represents the call taking direct ownership of that
  // value.  We have to do this after emitting the other call
  // arguments because they might also reference self, but we don't
  // have to worry about any of them modifying self because that would
  // be an undefined read and write of an object in unordered
  // expressions.
  if (isDelegateInit) {
    assert(getLangOpts().ObjCAutoRefCount &&
           "delegate init calls should only be marked in ARC");

    // Do an unsafe store of null into self.
    Address selfAddr =
      GetAddrOfLocalVar(cast<ObjCMethodDecl>(CurCodeDecl)->getSelfDecl());
    Builder.CreateStore(getNullForVariable(selfAddr), selfAddr);
  }

  RValue result;
  if (isSuperMessage) {
    // super is only valid in an Objective-C method
    const ObjCMethodDecl *OMD = cast<ObjCMethodDecl>(CurFuncDecl);
    bool isCategoryImpl = isa<ObjCCategoryImplDecl>(OMD->getDeclContext());
    result = Runtime.GenerateMessageSendSuper(*this, Return, ResultType,
                                              E->getSelector(),
                                              OMD->getClassInterface(),
                                              isCategoryImpl,
                                              Receiver,
                                              isClassMessage,
                                              Args,
                                              method);
  } else {
    result = Runtime.GenerateMessageSend(*this, Return, ResultType,
                                         E->getSelector(),
                                         Receiver, Args, OID,
                                         method);
  }

  // For delegate init calls in ARC, implicitly store the result of
  // the call back into self.  This takes ownership of the value.
  if (isDelegateInit) {
    Address selfAddr =
      GetAddrOfLocalVar(cast<ObjCMethodDecl>(CurCodeDecl)->getSelfDecl());
    llvm::Value *newSelf = result.getScalarVal();

    // The delegate return type isn't necessarily a matching type; in
    // fact, it's quite likely to be 'id'.
    llvm::Type *selfTy = selfAddr.getElementType();
    newSelf = Builder.CreateBitCast(newSelf, selfTy);

    Builder.CreateStore(newSelf, selfAddr);
  }

  return AdjustObjCObjectType(*this, E->getType(), result);
}

namespace {
struct FinishARCDealloc final : EHScopeStack::Cleanup {
  void Emit(CodeGenFunction &CGF, Flags flags) override {
    const ObjCMethodDecl *method = cast<ObjCMethodDecl>(CGF.CurCodeDecl);

    const ObjCImplDecl *impl = cast<ObjCImplDecl>(method->getDeclContext());
    const ObjCInterfaceDecl *iface = impl->getClassInterface();
    if (!iface->getSuperClass()) return;

    bool isCategory = isa<ObjCCategoryImplDecl>(impl);

    // Call [super dealloc] if we have a superclass.
    llvm::Value *self = CGF.LoadObjCSelf();

    CallArgList args;
    CGF.CGM.getObjCRuntime().GenerateMessageSendSuper(CGF, ReturnValueSlot(),
                                                      CGF.getContext().VoidTy,
                                                      method->getSelector(),
                                                      iface,
                                                      isCategory,
                                                      self,
                                                      /*is class msg*/ false,
                                                      args,
                                                      method);
  }
};
}

/// StartObjCMethod - Begin emission of an ObjCMethod. This generates
/// the LLVM function and sets the other context used by
/// CodeGenFunction.
void CodeGenFunction::StartObjCMethod(const ObjCMethodDecl *OMD,
                                      const ObjCContainerDecl *CD) {
  SourceLocation StartLoc = OMD->getLocStart();
  FunctionArgList args;
  // Check if we should generate debug info for this method.
  if (OMD->hasAttr<NoDebugAttr>())
    DebugInfo = nullptr; // disable debug info indefinitely for this function

  llvm::Function *Fn = CGM.getObjCRuntime().GenerateMethod(OMD, CD);

  const CGFunctionInfo &FI = CGM.getTypes().arrangeObjCMethodDeclaration(OMD);
  CGM.SetInternalFunctionAttributes(OMD, Fn, FI);

  args.push_back(OMD->getSelfDecl());
  args.push_back(OMD->getCmdDecl());

  args.append(OMD->param_begin(), OMD->param_end());

  CurGD = OMD;
  CurEHLocation = OMD->getLocEnd();

  StartFunction(OMD, OMD->getReturnType(), Fn, FI, args,
                OMD->getLocation(), StartLoc);

  // In ARC, certain methods get an extra cleanup.
  if (CGM.getLangOpts().ObjCAutoRefCount &&
      OMD->isInstanceMethod() &&
      OMD->getSelector().isUnarySelector()) {
    const IdentifierInfo *ident = 
      OMD->getSelector().getIdentifierInfoForSlot(0);
    if (ident->isStr("dealloc"))
      EHStack.pushCleanup<FinishARCDealloc>(getARCCleanupKind());
  }
}

static llvm::Value *emitARCRetainLoadOfScalar(CodeGenFunction &CGF,
                                              LValue lvalue, QualType type);

/// Generate an Objective-C method.  An Objective-C method is a C function with
/// its pointer, name, and types registered in the class struture.
void CodeGenFunction::GenerateObjCMethod(const ObjCMethodDecl *OMD) {
  StartObjCMethod(OMD, OMD->getClassInterface());
  PGO.assignRegionCounters(GlobalDecl(OMD), CurFn);
  assert(isa<CompoundStmt>(OMD->getBody()));
  incrementProfileCounter(OMD->getBody());
  EmitCompoundStmtWithoutScope(*cast<CompoundStmt>(OMD->getBody()));
  FinishFunction(OMD->getBodyRBrace());
}

/// emitStructGetterCall - Call the runtime function to load a property
/// into the return value slot.
static void emitStructGetterCall(CodeGenFunction &CGF, ObjCIvarDecl *ivar, 
                                 bool isAtomic, bool hasStrong) {
  ASTContext &Context = CGF.getContext();

  Address src =
    CGF.EmitLValueForIvar(CGF.TypeOfSelfObject(), CGF.LoadObjCSelf(), ivar, 0)
       .getAddress();

  // objc_copyStruct (ReturnValue, &structIvar, 
  //                  sizeof (Type of Ivar), isAtomic, false);
  CallArgList args;

  Address dest = CGF.Builder.CreateBitCast(CGF.ReturnValue, CGF.VoidPtrTy);
  args.add(RValue::get(dest.getPointer()), Context.VoidPtrTy);

  src = CGF.Builder.CreateBitCast(src, CGF.VoidPtrTy);
  args.add(RValue::get(src.getPointer()), Context.VoidPtrTy);

  CharUnits size = CGF.getContext().getTypeSizeInChars(ivar->getType());
  args.add(RValue::get(CGF.CGM.getSize(size)), Context.getSizeType());
  args.add(RValue::get(CGF.Builder.getInt1(isAtomic)), Context.BoolTy);
  args.add(RValue::get(CGF.Builder.getInt1(hasStrong)), Context.BoolTy);

  llvm::Constant *fn = CGF.CGM.getObjCRuntime().GetGetStructFunction();
  CGCallee callee = CGCallee::forDirect(fn);
  CGF.EmitCall(CGF.getTypes().arrangeBuiltinFunctionCall(Context.VoidTy, args),
               callee, ReturnValueSlot(), args);
}

/// Determine whether the given architecture supports unaligned atomic
/// accesses.  They don't have to be fast, just faster than a function
/// call and a mutex.
static bool hasUnalignedAtomics(llvm::Triple::ArchType arch) {
  // FIXME: Allow unaligned atomic load/store on x86.  (It is not
  // currently supported by the backend.)
  return 0;
}

/// Return the maximum size that permits atomic accesses for the given
/// architecture.
static CharUnits getMaxAtomicAccessSize(CodeGenModule &CGM,
                                        llvm::Triple::ArchType arch) {
  // ARM has 8-byte atomic accesses, but it's not clear whether we
  // want to rely on them here.

  // In the default case, just assume that any size up to a pointer is
  // fine given adequate alignment.
  return CharUnits::fromQuantity(CGM.PointerSizeInBytes);
}

namespace {
  class PropertyImplStrategy {
  public:
    enum StrategyKind {
      /// The 'native' strategy is to use the architecture's provided
      /// reads and writes.
      Native,

      /// Use objc_setProperty and objc_getProperty.
      GetSetProperty,

      /// Use objc_setProperty for the setter, but use expression
      /// evaluation for the getter.
      SetPropertyAndExpressionGet,

      /// Use objc_copyStruct.
      CopyStruct,

      /// The 'expression' strategy is to emit normal assignment or
      /// lvalue-to-rvalue expressions.
      Expression
    };

    StrategyKind getKind() const { return StrategyKind(Kind); }

    bool hasStrongMember() const { return HasStrong; }
    bool isAtomic() const { return IsAtomic; }
    bool isCopy() const { return IsCopy; }

    CharUnits getIvarSize() const { return IvarSize; }
    CharUnits getIvarAlignment() const { return IvarAlignment; }

    PropertyImplStrategy(CodeGenModule &CGM,
                         const ObjCPropertyImplDecl *propImpl);

  private:
    unsigned Kind : 8;
    unsigned IsAtomic : 1;
    unsigned IsCopy : 1;
    unsigned HasStrong : 1;

    CharUnits IvarSize;
    CharUnits IvarAlignment;
  };
}

/// Pick an implementation strategy for the given property synthesis.
PropertyImplStrategy::PropertyImplStrategy(CodeGenModule &CGM,
                                     const ObjCPropertyImplDecl *propImpl) {
  const ObjCPropertyDecl *prop = propImpl->getPropertyDecl();
  ObjCPropertyDecl::SetterKind setterKind = prop->getSetterKind();

  IsCopy = (setterKind == ObjCPropertyDecl::Copy);
  IsAtomic = prop->isAtomic();
  HasStrong = false; // doesn't matter here.

  // Evaluate the ivar's size and alignment.
  ObjCIvarDecl *ivar = propImpl->getPropertyIvarDecl();
  QualType ivarType = ivar->getType();
  std::tie(IvarSize, IvarAlignment) =
      CGM.getContext().getTypeInfoInChars(ivarType);

  // If we have a copy property, we always have to use getProperty/setProperty.
  // TODO: we could actually use setProperty and an expression for non-atomics.
  if (IsCopy) {
    Kind = GetSetProperty;
    return;
  }

  // Handle retain.
  if (setterKind == ObjCPropertyDecl::Retain) {
    // In GC-only, there's nothing special that needs to be done.
    if (CGM.getLangOpts().getGC() == LangOptions::GCOnly) {
      // fallthrough

    // In ARC, if the property is non-atomic, use expression emission,
    // which translates to objc_storeStrong.  This isn't required, but
    // it's slightly nicer.
    } else if (CGM.getLangOpts().ObjCAutoRefCount && !IsAtomic) {
      // Using standard expression emission for the setter is only
      // acceptable if the ivar is __strong, which won't be true if
      // the property is annotated with __attribute__((NSObject)).
      // TODO: falling all the way back to objc_setProperty here is
      // just laziness, though;  we could still use objc_storeStrong
      // if we hacked it right.
      if (ivarType.getObjCLifetime() == Qualifiers::OCL_Strong)
        Kind = Expression;
      else
        Kind = SetPropertyAndExpressionGet;
      return;

    // Otherwise, we need to at least use setProperty.  However, if
    // the property isn't atomic, we can use normal expression
    // emission for the getter.
    } else if (!IsAtomic) {
      Kind = SetPropertyAndExpressionGet;
      return;

    // Otherwise, we have to use both setProperty and getProperty.
    } else {
      Kind = GetSetProperty;
      return;
    }
  }

  // If we're not atomic, just use expression accesses.
  if (!IsAtomic) {
    Kind = Expression;
    return;
  }

  // Properties on bitfield ivars need to be emitted using expression
  // accesses even if they're nominally atomic.
  if (ivar->isBitField()) {
    Kind = Expression;
    return;
  }

  // GC-qualified or ARC-qualified ivars need to be emitted as
  // expressions.  This actually works out to being atomic anyway,
  // except for ARC __strong, but that should trigger the above code.
  if (ivarType.hasNonTrivialObjCLifetime() ||
      (CGM.getLangOpts().getGC() &&
       CGM.getContext().getObjCGCAttrKind(ivarType))) {
    Kind = Expression;
    return;
  }

  // Compute whether the ivar has strong members.
  if (CGM.getLangOpts().getGC())
    if (const RecordType *recordType = ivarType->getAs<RecordType>())
      HasStrong = recordType->getDecl()->hasObjectMember();

  // We can never access structs with object members with a native
  // access, because we need to use write barriers.  This is what
  // objc_copyStruct is for.
  if (HasStrong) {
    Kind = CopyStruct;
    return;
  }

  // Otherwise, this is target-dependent and based on the size and
  // alignment of the ivar.

  // If the size of the ivar is not a power of two, give up.  We don't
  // want to get into the business of doing compare-and-swaps.
  if (!IvarSize.isPowerOfTwo()) {
    Kind = CopyStruct;
    return;
  }

  llvm::Triple::ArchType arch =
    CGM.getTarget().getTriple().getArch();

  // Most architectures require memory to fit within a single cache
  // line, so the alignment has to be at least the size of the access.
  // Otherwise we have to grab a lock.
  if (IvarAlignment < IvarSize && !hasUnalignedAtomics(arch)) {
    Kind = CopyStruct;
    return;
  }

  // If the ivar's size exceeds the architecture's maximum atomic
  // access size, we have to use CopyStruct.
  if (IvarSize > getMaxAtomicAccessSize(CGM, arch)) {
    Kind = CopyStruct;
    return;
  }

  // Otherwise, we can use native loads and stores.
  Kind = Native;
}

/// \brief Generate an Objective-C property getter function.
///
/// The given Decl must be an ObjCImplementationDecl. \@synthesize
/// is illegal within a category.
void CodeGenFunction::GenerateObjCGetter(ObjCImplementationDecl *IMP,
                                         const ObjCPropertyImplDecl *PID) {
  llvm::Constant *AtomicHelperFn =
      CodeGenFunction(CGM).GenerateObjCAtomicGetterCopyHelperFunction(PID);
  const ObjCPropertyDecl *PD = PID->getPropertyDecl();
  ObjCMethodDecl *OMD = PD->getGetterMethodDecl();
  assert(OMD && "Invalid call to generate getter (empty method)");
  StartObjCMethod(OMD, IMP->getClassInterface());

  generateObjCGetterBody(IMP, PID, OMD, AtomicHelperFn);

  FinishFunction();
}

static bool hasTrivialGetExpr(const ObjCPropertyImplDecl *propImpl) {
  const Expr *getter = propImpl->getGetterCXXConstructor();
  if (!getter) return true;

  // Sema only makes only of these when the ivar has a C++ class type,
  // so the form is pretty constrained.

  // If the property has a reference type, we might just be binding a
  // reference, in which case the result will be a gl-value.  We should
  // treat this as a non-trivial operation.
  if (getter->isGLValue())
    return false;

  // If we selected a trivial copy-constructor, we're okay.
  if (const CXXConstructExpr *construct = dyn_cast<CXXConstructExpr>(getter))
    return (construct->getConstructor()->isTrivial());

  // The constructor might require cleanups (in which case it's never
  // trivial).
  assert(isa<ExprWithCleanups>(getter));
  return false;
}

/// emitCPPObjectAtomicGetterCall - Call the runtime function to 
/// copy the ivar into the resturn slot.
static void emitCPPObjectAtomicGetterCall(CodeGenFunction &CGF, 
                                          llvm::Value *returnAddr,
                                          ObjCIvarDecl *ivar,
                                          llvm::Constant *AtomicHelperFn) {
  // objc_copyCppObjectAtomic (&returnSlot, &CppObjectIvar,
  //                           AtomicHelperFn);
  CallArgList args;
  
  // The 1st argument is the return Slot.
  args.add(RValue::get(returnAddr), CGF.getContext().VoidPtrTy);
  
  // The 2nd argument is the address of the ivar.
  llvm::Value *ivarAddr = 
    CGF.EmitLValueForIvar(CGF.TypeOfSelfObject(), 
                          CGF.LoadObjCSelf(), ivar, 0).getPointer();
  ivarAddr = CGF.Builder.CreateBitCast(ivarAddr, CGF.Int8PtrTy);
  args.add(RValue::get(ivarAddr), CGF.getContext().VoidPtrTy);
  
  // Third argument is the helper function.
  args.add(RValue::get(AtomicHelperFn), CGF.getContext().VoidPtrTy);
  
  llvm::Constant *copyCppAtomicObjectFn = 
    CGF.CGM.getObjCRuntime().GetCppAtomicObjectGetFunction();
  CGCallee callee = CGCallee::forDirect(copyCppAtomicObjectFn);
  CGF.EmitCall(
      CGF.getTypes().arrangeBuiltinFunctionCall(CGF.getContext().VoidTy, args),
               callee, ReturnValueSlot(), args);
}

void
CodeGenFunction::generateObjCGetterBody(const ObjCImplementationDecl *classImpl,
                                        const ObjCPropertyImplDecl *propImpl,
                                        const ObjCMethodDecl *GetterMethodDecl,
                                        llvm::Constant *AtomicHelperFn) {
  // If there's a non-trivial 'get' expression, we just have to emit that.
  if (!hasTrivialGetExpr(propImpl)) {
    if (!AtomicHelperFn) {
      ReturnStmt ret(SourceLocation(), propImpl->getGetterCXXConstructor(),
                     /*nrvo*/ nullptr);
      EmitReturnStmt(ret);
    }
    else {
      ObjCIvarDecl *ivar = propImpl->getPropertyIvarDecl();
      emitCPPObjectAtomicGetterCall(*this, ReturnValue.getPointer(), 
                                    ivar, AtomicHelperFn);
    }
    return;
  }

  const ObjCPropertyDecl *prop = propImpl->getPropertyDecl();
  QualType propType = prop->getType();
  ObjCMethodDecl *getterMethod = prop->getGetterMethodDecl();

  ObjCIvarDecl *ivar = propImpl->getPropertyIvarDecl();  

  // Pick an implementation strategy.
  PropertyImplStrategy strategy(CGM, propImpl);
  switch (strategy.getKind()) {
  case PropertyImplStrategy::Native: {
    // We don't need to do anything for a zero-size struct.
    if (strategy.getIvarSize().isZero())
      return;

    LValue LV = EmitLValueForIvar(TypeOfSelfObject(), LoadObjCSelf(), ivar, 0);

    // Currently, all atomic accesses have to be through integer
    // types, so there's no point in trying to pick a prettier type.
    uint64_t ivarSize = getContext().toBits(strategy.getIvarSize());
    llvm::Type *bitcastType = llvm::Type::getIntNTy(getLLVMContext(), ivarSize);
    bitcastType = bitcastType->getPointerTo(); // addrspace 0 okay

    // Perform an atomic load.  This does not impose ordering constraints.
    Address ivarAddr = LV.getAddress();
    ivarAddr = Builder.CreateBitCast(ivarAddr, bitcastType);
    llvm::LoadInst *load = Builder.CreateLoad(ivarAddr, "load");
    load->setAtomic(llvm::AtomicOrdering::Unordered);

    // Store that value into the return address.  Doing this with a
    // bitcast is likely to produce some pretty ugly IR, but it's not
    // the *most* terrible thing in the world.
    llvm::Type *retTy = ConvertType(getterMethod->getReturnType());
    uint64_t retTySize = CGM.getDataLayout().getTypeSizeInBits(retTy);
    llvm::Value *ivarVal = load;
    if (ivarSize > retTySize) {
      llvm::Type *newTy = llvm::Type::getIntNTy(getLLVMContext(), retTySize);
      ivarVal = Builder.CreateTrunc(load, newTy);
      bitcastType = newTy->getPointerTo();
    }
    Builder.CreateStore(ivarVal,
                        Builder.CreateBitCast(ReturnValue, bitcastType));

    // Make sure we don't do an autorelease.
    AutoreleaseResult = false;
    return;
  }

  case PropertyImplStrategy::GetSetProperty: {
    llvm::Constant *getPropertyFn =
      CGM.getObjCRuntime().GetPropertyGetFunction();
    if (!getPropertyFn) {
      CGM.ErrorUnsupported(propImpl, "Obj-C getter requiring atomic copy");
      return;
    }
    CGCallee callee = CGCallee::forDirect(getPropertyFn);

    // Return (ivar-type) objc_getProperty((id) self, _cmd, offset, true).
    // FIXME: Can't this be simpler? This might even be worse than the
    // corresponding gcc code.
    llvm::Value *cmd =
      Builder.CreateLoad(GetAddrOfLocalVar(getterMethod->getCmdDecl()), "cmd");
    llvm::Value *self = Builder.CreateBitCast(LoadObjCSelf(), VoidPtrTy);
    llvm::Value *ivarOffset =
      EmitIvarOffset(classImpl->getClassInterface(), ivar);

    CallArgList args;
    args.add(RValue::get(self), getContext().getObjCIdType());
    args.add(RValue::get(cmd), getContext().getObjCSelType());
    args.add(RValue::get(ivarOffset), getContext().getPointerDiffType());
    args.add(RValue::get(Builder.getInt1(strategy.isAtomic())),
             getContext().BoolTy);

    // FIXME: We shouldn't need to get the function info here, the
    // runtime already should have computed it to build the function.
    llvm::Instruction *CallInstruction;
    RValue RV = EmitCall(
        getTypes().arrangeBuiltinFunctionCall(propType, args),
        callee, ReturnValueSlot(), args, &CallInstruction);
    if (llvm::CallInst *call = dyn_cast<llvm::CallInst>(CallInstruction))
      call->setTailCall();

    // We need to fix the type here. Ivars with copy & retain are
    // always objects so we don't need to worry about complex or
    // aggregates.
    RV = RValue::get(Builder.CreateBitCast(
        RV.getScalarVal(),
        getTypes().ConvertType(getterMethod->getReturnType())));

    EmitReturnOfRValue(RV, propType);

    // objc_getProperty does an autorelease, so we should suppress ours.
    AutoreleaseResult = false;

    return;
  }

  case PropertyImplStrategy::CopyStruct:
    emitStructGetterCall(*this, ivar, strategy.isAtomic(),
                         strategy.hasStrongMember());
    return;

  case PropertyImplStrategy::Expression:
  case PropertyImplStrategy::SetPropertyAndExpressionGet: {
    LValue LV = EmitLValueForIvar(TypeOfSelfObject(), LoadObjCSelf(), ivar, 0);

    QualType ivarType = ivar->getType();
    switch (getEvaluationKind(ivarType)) {
    case TEK_Complex: {
      ComplexPairTy pair = EmitLoadOfComplex(LV, SourceLocation());
      EmitStoreOfComplex(pair, MakeAddrLValue(ReturnValue, ivarType),
                         /*init*/ true);
      return;
    }
    case TEK_Aggregate:
      // The return value slot is guaranteed to not be aliased, but
      // that's not necessarily the same as "on the stack", so
      // we still potentially need objc_memmove_collectable.
      EmitAggregateCopy(ReturnValue, LV.getAddress(), ivarType);
      return;
    case TEK_Scalar: {
      llvm::Value *value;
      if (propType->isReferenceType()) {
        value = LV.getAddress().getPointer();
      } else {
        // We want to load and autoreleaseReturnValue ARC __weak ivars.
        if (LV.getQuals().getObjCLifetime() == Qualifiers::OCL_Weak) {
          if (getLangOpts().ObjCAutoRefCount) {
            value = emitARCRetainLoadOfScalar(*this, LV, ivarType);
          } else {
            value = EmitARCLoadWeak(LV.getAddress());
          }

        // Otherwise we want to do a simple load, suppressing the
        // final autorelease.
        } else {
          value = EmitLoadOfLValue(LV, SourceLocation()).getScalarVal();
          AutoreleaseResult = false;
        }

        value = Builder.CreateBitCast(
            value, ConvertType(GetterMethodDecl->getReturnType()));
      }
      
      EmitReturnOfRValue(RValue::get(value), propType);
      return;
    }
    }
    llvm_unreachable("bad evaluation kind");
  }

  }
  llvm_unreachable("bad @property implementation strategy!");
}

/// emitStructSetterCall - Call the runtime function to store the value
/// from the first formal parameter into the given ivar.
static void emitStructSetterCall(CodeGenFunction &CGF, ObjCMethodDecl *OMD,
                                 ObjCIvarDecl *ivar) {
  // objc_copyStruct (&structIvar, &Arg, 
  //                  sizeof (struct something), true, false);
  CallArgList args;

  // The first argument is the address of the ivar.
  llvm::Value *ivarAddr = CGF.EmitLValueForIvar(CGF.TypeOfSelfObject(),
                                                CGF.LoadObjCSelf(), ivar, 0)
    .getPointer();
  ivarAddr = CGF.Builder.CreateBitCast(ivarAddr, CGF.Int8PtrTy);
  args.add(RValue::get(ivarAddr), CGF.getContext().VoidPtrTy);

  // The second argument is the address of the parameter variable.
  ParmVarDecl *argVar = *OMD->param_begin();
  DeclRefExpr argRef(argVar, false, argVar->getType().getNonReferenceType(), 
                     VK_LValue, SourceLocation());
  llvm::Value *argAddr = CGF.EmitLValue(&argRef).getPointer();
  argAddr = CGF.Builder.CreateBitCast(argAddr, CGF.Int8PtrTy);
  args.add(RValue::get(argAddr), CGF.getContext().VoidPtrTy);

  // The third argument is the sizeof the type.
  llvm::Value *size =
    CGF.CGM.getSize(CGF.getContext().getTypeSizeInChars(ivar->getType()));
  args.add(RValue::get(size), CGF.getContext().getSizeType());

  // The fourth argument is the 'isAtomic' flag.
  args.add(RValue::get(CGF.Builder.getTrue()), CGF.getContext().BoolTy);

  // The fifth argument is the 'hasStrong' flag.
  // FIXME: should this really always be false?
  args.add(RValue::get(CGF.Builder.getFalse()), CGF.getContext().BoolTy);

  llvm::Constant *fn = CGF.CGM.getObjCRuntime().GetSetStructFunction();
  CGCallee callee = CGCallee::forDirect(fn);
  CGF.EmitCall(
      CGF.getTypes().arrangeBuiltinFunctionCall(CGF.getContext().VoidTy, args),
               callee, ReturnValueSlot(), args);
}

/// emitCPPObjectAtomicSetterCall - Call the runtime function to store 
/// the value from the first formal parameter into the given ivar, using 
/// the Cpp API for atomic Cpp objects with non-trivial copy assignment.
static void emitCPPObjectAtomicSetterCall(CodeGenFunction &CGF, 
                                          ObjCMethodDecl *OMD,
                                          ObjCIvarDecl *ivar,
                                          llvm::Constant *AtomicHelperFn) {
  // objc_copyCppObjectAtomic (&CppObjectIvar, &Arg, 
  //                           AtomicHelperFn);
  CallArgList args;
  
  // The first argument is the address of the ivar.
  llvm::Value *ivarAddr = 
    CGF.EmitLValueForIvar(CGF.TypeOfSelfObject(), 
                          CGF.LoadObjCSelf(), ivar, 0).getPointer();
  ivarAddr = CGF.Builder.CreateBitCast(ivarAddr, CGF.Int8PtrTy);
  args.add(RValue::get(ivarAddr), CGF.getContext().VoidPtrTy);
  
  // The second argument is the address of the parameter variable.
  ParmVarDecl *argVar = *OMD->param_begin();
  DeclRefExpr argRef(argVar, false, argVar->getType().getNonReferenceType(), 
                     VK_LValue, SourceLocation());
  llvm::Value *argAddr = CGF.EmitLValue(&argRef).getPointer();
  argAddr = CGF.Builder.CreateBitCast(argAddr, CGF.Int8PtrTy);
  args.add(RValue::get(argAddr), CGF.getContext().VoidPtrTy);
  
  // Third argument is the helper function.
  args.add(RValue::get(AtomicHelperFn), CGF.getContext().VoidPtrTy);
  
  llvm::Constant *fn = 
    CGF.CGM.getObjCRuntime().GetCppAtomicObjectSetFunction();
  CGCallee callee = CGCallee::forDirect(fn);
  CGF.EmitCall(
      CGF.getTypes().arrangeBuiltinFunctionCall(CGF.getContext().VoidTy, args),
               callee, ReturnValueSlot(), args);
}


static bool hasTrivialSetExpr(const ObjCPropertyImplDecl *PID) {
  Expr *setter = PID->getSetterCXXAssignment();
  if (!setter) return true;

  // Sema only makes only of these when the ivar has a C++ class type,
  // so the form is pretty constrained.

  // An operator call is trivial if the function it calls is trivial.
  // This also implies that there's nothing non-trivial going on with
  // the arguments, because operator= can only be trivial if it's a
  // synthesized assignment operator and therefore both parameters are
  // references.
  if (CallExpr *call = dyn_cast<CallExpr>(setter)) {
    if (const FunctionDecl *callee
          = dyn_cast_or_null<FunctionDecl>(call->getCalleeDecl()))
      if (callee->isTrivial())
        return true;
    return false;
  }

  assert(isa<ExprWithCleanups>(setter));
  return false;
}

static bool UseOptimizedSetter(CodeGenModule &CGM) {
  if (CGM.getLangOpts().getGC() != LangOptions::NonGC)
    return false;
  return CGM.getLangOpts().ObjCRuntime.hasOptimizedSetter();
}

void
CodeGenFunction::generateObjCSetterBody(const ObjCImplementationDecl *classImpl,
                                        const ObjCPropertyImplDecl *propImpl,
                                        llvm::Constant *AtomicHelperFn) {
  const ObjCPropertyDecl *prop = propImpl->getPropertyDecl();
  ObjCIvarDecl *ivar = propImpl->getPropertyIvarDecl();
  ObjCMethodDecl *setterMethod = prop->getSetterMethodDecl();
  
  // Just use the setter expression if Sema gave us one and it's
  // non-trivial.
  if (!hasTrivialSetExpr(propImpl)) {
    if (!AtomicHelperFn)
      // If non-atomic, assignment is called directly.
      EmitStmt(propImpl->getSetterCXXAssignment());
    else
      // If atomic, assignment is called via a locking api.
      emitCPPObjectAtomicSetterCall(*this, setterMethod, ivar,
                                    AtomicHelperFn);
    return;
  }

  PropertyImplStrategy strategy(CGM, propImpl);
  switch (strategy.getKind()) {
  case PropertyImplStrategy::Native: {
    // We don't need to do anything for a zero-size struct.
    if (strategy.getIvarSize().isZero())
      return;

    Address argAddr = GetAddrOfLocalVar(*setterMethod->param_begin());

    LValue ivarLValue =
      EmitLValueForIvar(TypeOfSelfObject(), LoadObjCSelf(), ivar, /*quals*/ 0);
    Address ivarAddr = ivarLValue.getAddress();

    // Currently, all atomic accesses have to be through integer
    // types, so there's no point in trying to pick a prettier type.
    llvm::Type *bitcastType =
      llvm::Type::getIntNTy(getLLVMContext(),
                            getContext().toBits(strategy.getIvarSize()));

    // Cast both arguments to the chosen operation type.
    argAddr = Builder.CreateElementBitCast(argAddr, bitcastType);
    ivarAddr = Builder.CreateElementBitCast(ivarAddr, bitcastType);

    // This bitcast load is likely to cause some nasty IR.
    llvm::Value *load = Builder.CreateLoad(argAddr);

    // Perform an atomic store.  There are no memory ordering requirements.
    llvm::StoreInst *store = Builder.CreateStore(load, ivarAddr);
    store->setAtomic(llvm::AtomicOrdering::Unordered);
    return;
  }

  case PropertyImplStrategy::GetSetProperty:
  case PropertyImplStrategy::SetPropertyAndExpressionGet: {

    llvm::Constant *setOptimizedPropertyFn = nullptr;
    llvm::Constant *setPropertyFn = nullptr;
    if (UseOptimizedSetter(CGM)) {
      // 10.8 and iOS 6.0 code and GC is off
      setOptimizedPropertyFn = 
        CGM.getObjCRuntime()
           .GetOptimizedPropertySetFunction(strategy.isAtomic(),
                                            strategy.isCopy());
      if (!setOptimizedPropertyFn) {
        CGM.ErrorUnsupported(propImpl, "Obj-C optimized setter - NYI");
        return;
      }
    }
    else {
      setPropertyFn = CGM.getObjCRuntime().GetPropertySetFunction();
      if (!setPropertyFn) {
        CGM.ErrorUnsupported(propImpl, "Obj-C setter requiring atomic copy");
        return;
      }
    }
   
    // Emit objc_setProperty((id) self, _cmd, offset, arg,
    //                       <is-atomic>, <is-copy>).
    llvm::Value *cmd =
      Builder.CreateLoad(GetAddrOfLocalVar(setterMethod->getCmdDecl()));
    llvm::Value *self =
      Builder.CreateBitCast(LoadObjCSelf(), VoidPtrTy);
    llvm::Value *ivarOffset =
      EmitIvarOffset(classImpl->getClassInterface(), ivar);
    Address argAddr = GetAddrOfLocalVar(*setterMethod->param_begin());
    llvm::Value *arg = Builder.CreateLoad(argAddr, "arg");
    arg = Builder.CreateBitCast(arg, VoidPtrTy);

    CallArgList args;
    args.add(RValue::get(self), getContext().getObjCIdType());
    args.add(RValue::get(cmd), getContext().getObjCSelType());
    if (setOptimizedPropertyFn) {
      args.add(RValue::get(arg), getContext().getObjCIdType());
      args.add(RValue::get(ivarOffset), getContext().getPointerDiffType());
      CGCallee callee = CGCallee::forDirect(setOptimizedPropertyFn);
      EmitCall(getTypes().arrangeBuiltinFunctionCall(getContext().VoidTy, args),
               callee, ReturnValueSlot(), args);
    } else {
      args.add(RValue::get(ivarOffset), getContext().getPointerDiffType());
      args.add(RValue::get(arg), getContext().getObjCIdType());
      args.add(RValue::get(Builder.getInt1(strategy.isAtomic())),
               getContext().BoolTy);
      args.add(RValue::get(Builder.getInt1(strategy.isCopy())),
               getContext().BoolTy);
      // FIXME: We shouldn't need to get the function info here, the runtime
      // already should have computed it to build the function.
      CGCallee callee = CGCallee::forDirect(setPropertyFn);
      EmitCall(getTypes().arrangeBuiltinFunctionCall(getContext().VoidTy, args),
               callee, ReturnValueSlot(), args);
    }
    
    return;
  }

  case PropertyImplStrategy::CopyStruct:
    emitStructSetterCall(*this, setterMethod, ivar);
    return;

  case PropertyImplStrategy::Expression:
    break;
  }

  // Otherwise, fake up some ASTs and emit a normal assignment.
  ValueDecl *selfDecl = setterMethod->getSelfDecl();
  DeclRefExpr self(selfDecl, false, selfDecl->getType(),
                   VK_LValue, SourceLocation());
  ImplicitCastExpr selfLoad(ImplicitCastExpr::OnStack,
                            selfDecl->getType(), CK_LValueToRValue, &self,
                            VK_RValue);
  ObjCIvarRefExpr ivarRef(ivar, ivar->getType().getNonReferenceType(),
                          SourceLocation(), SourceLocation(),
                          &selfLoad, true, true);

  ParmVarDecl *argDecl = *setterMethod->param_begin();
  QualType argType = argDecl->getType().getNonReferenceType();
  DeclRefExpr arg(argDecl, false, argType, VK_LValue, SourceLocation());
  ImplicitCastExpr argLoad(ImplicitCastExpr::OnStack,
                           argType.getUnqualifiedType(), CK_LValueToRValue,
                           &arg, VK_RValue);
    
  // The property type can differ from the ivar type in some situations with
  // Objective-C pointer types, we can always bit cast the RHS in these cases.
  // The following absurdity is just to ensure well-formed IR.
  CastKind argCK = CK_NoOp;
  if (ivarRef.getType()->isObjCObjectPointerType()) {
    if (argLoad.getType()->isObjCObjectPointerType())
      argCK = CK_BitCast;
    else if (argLoad.getType()->isBlockPointerType())
      argCK = CK_BlockPointerToObjCPointerCast;
    else
      argCK = CK_CPointerToObjCPointerCast;
  } else if (ivarRef.getType()->isBlockPointerType()) {
     if (argLoad.getType()->isBlockPointerType())
      argCK = CK_BitCast;
    else
      argCK = CK_AnyPointerToBlockPointerCast;
  } else if (ivarRef.getType()->isPointerType()) {
    argCK = CK_BitCast;
  }
  ImplicitCastExpr argCast(ImplicitCastExpr::OnStack,
                           ivarRef.getType(), argCK, &argLoad,
                           VK_RValue);
  Expr *finalArg = &argLoad;
  if (!getContext().hasSameUnqualifiedType(ivarRef.getType(),
                                           argLoad.getType()))
    finalArg = &argCast;


  BinaryOperator assign(&ivarRef, finalArg, BO_Assign,
                        ivarRef.getType(), VK_RValue, OK_Ordinary,
                        SourceLocation(), false);
  EmitStmt(&assign);
}

/// \brief Generate an Objective-C property setter function.
///
/// The given Decl must be an ObjCImplementationDecl. \@synthesize
/// is illegal within a category.
void CodeGenFunction::GenerateObjCSetter(ObjCImplementationDecl *IMP,
                                         const ObjCPropertyImplDecl *PID) {
  llvm::Constant *AtomicHelperFn =
      CodeGenFunction(CGM).GenerateObjCAtomicSetterCopyHelperFunction(PID);
  const ObjCPropertyDecl *PD = PID->getPropertyDecl();
  ObjCMethodDecl *OMD = PD->getSetterMethodDecl();
  assert(OMD && "Invalid call to generate setter (empty method)");
  StartObjCMethod(OMD, IMP->getClassInterface());

  generateObjCSetterBody(IMP, PID, AtomicHelperFn);

  FinishFunction();
}

namespace {
  struct DestroyIvar final : EHScopeStack::Cleanup {
  private:
    llvm::Value *addr;
    const ObjCIvarDecl *ivar;
    CodeGenFunction::Destroyer *destroyer;
    bool useEHCleanupForArray;
  public:
    DestroyIvar(llvm::Value *addr, const ObjCIvarDecl *ivar,
                CodeGenFunction::Destroyer *destroyer,
                bool useEHCleanupForArray)
      : addr(addr), ivar(ivar), destroyer(destroyer),
        useEHCleanupForArray(useEHCleanupForArray) {}

    void Emit(CodeGenFunction &CGF, Flags flags) override {
      LValue lvalue
        = CGF.EmitLValueForIvar(CGF.TypeOfSelfObject(), addr, ivar, /*CVR*/ 0);
      CGF.emitDestroy(lvalue.getAddress(), ivar->getType(), destroyer,
                      flags.isForNormalCleanup() && useEHCleanupForArray);
    }
  };
}

/// Like CodeGenFunction::destroyARCStrong, but do it with a call.
static void destroyARCStrongWithStore(CodeGenFunction &CGF,
                                      Address addr,
                                      QualType type) {
  llvm::Value *null = getNullForVariable(addr);
  CGF.EmitARCStoreStrongCall(addr, null, /*ignored*/ true);
}

static void emitCXXDestructMethod(CodeGenFunction &CGF,
                                  ObjCImplementationDecl *impl) {
  CodeGenFunction::RunCleanupsScope scope(CGF);

  llvm::Value *self = CGF.LoadObjCSelf();

  const ObjCInterfaceDecl *iface = impl->getClassInterface();
  for (const ObjCIvarDecl *ivar = iface->all_declared_ivar_begin();
       ivar; ivar = ivar->getNextIvar()) {
    QualType type = ivar->getType();

    // Check whether the ivar is a destructible type.
    QualType::DestructionKind dtorKind = type.isDestructedType();
    if (!dtorKind) continue;

    CodeGenFunction::Destroyer *destroyer = nullptr;

    // Use a call to objc_storeStrong to destroy strong ivars, for the
    // general benefit of the tools.
    if (dtorKind == QualType::DK_objc_strong_lifetime) {
      destroyer = destroyARCStrongWithStore;

    // Otherwise use the default for the destruction kind.
    } else {
      destroyer = CGF.getDestroyer(dtorKind);
    }

    CleanupKind cleanupKind = CGF.getCleanupKind(dtorKind);

    CGF.EHStack.pushCleanup<DestroyIvar>(cleanupKind, self, ivar, destroyer,
                                         cleanupKind & EHCleanup);
  }

  assert(scope.requiresCleanups() && "nothing to do in .cxx_destruct?");
}

void CodeGenFunction::GenerateObjCCtorDtorMethod(ObjCImplementationDecl *IMP,
                                                 ObjCMethodDecl *MD,
                                                 bool ctor) {
  MD->createImplicitParams(CGM.getContext(), IMP->getClassInterface());
  StartObjCMethod(MD, IMP->getClassInterface());

  // Emit .cxx_construct.
  if (ctor) {
    // Suppress the final autorelease in ARC.
    AutoreleaseResult = false;

    for (const auto *IvarInit : IMP->inits()) {
      FieldDecl *Field = IvarInit->getAnyMember();
      ObjCIvarDecl *Ivar = cast<ObjCIvarDecl>(Field);
      LValue LV = EmitLValueForIvar(TypeOfSelfObject(), 
                                    LoadObjCSelf(), Ivar, 0);
      EmitAggExpr(IvarInit->getInit(),
                  AggValueSlot::forLValue(LV, AggValueSlot::IsDestructed,
                                          AggValueSlot::DoesNotNeedGCBarriers,
                                          AggValueSlot::IsNotAliased));
    }
    // constructor returns 'self'.
    CodeGenTypes &Types = CGM.getTypes();
    QualType IdTy(CGM.getContext().getObjCIdType());
    llvm::Value *SelfAsId =
      Builder.CreateBitCast(LoadObjCSelf(), Types.ConvertType(IdTy));
    EmitReturnOfRValue(RValue::get(SelfAsId), IdTy);

  // Emit .cxx_destruct.
  } else {
    emitCXXDestructMethod(*this, IMP);
  }
  FinishFunction();
}

llvm::Value *CodeGenFunction::LoadObjCSelf() {
  VarDecl *Self = cast<ObjCMethodDecl>(CurFuncDecl)->getSelfDecl();
  DeclRefExpr DRE(Self, /*is enclosing local*/ (CurFuncDecl != CurCodeDecl),
                  Self->getType(), VK_LValue, SourceLocation());
  return EmitLoadOfScalar(EmitDeclRefLValue(&DRE), SourceLocation());
}

QualType CodeGenFunction::TypeOfSelfObject() {
  const ObjCMethodDecl *OMD = cast<ObjCMethodDecl>(CurFuncDecl);
  ImplicitParamDecl *selfDecl = OMD->getSelfDecl();
  const ObjCObjectPointerType *PTy = cast<ObjCObjectPointerType>(
    getContext().getCanonicalType(selfDecl->getType()));
  return PTy->getPointeeType();
}

void CodeGenFunction::EmitObjCForCollectionStmt(const ObjCForCollectionStmt &S){
  llvm::Constant *EnumerationMutationFnPtr =
    CGM.getObjCRuntime().EnumerationMutationFunction();
  if (!EnumerationMutationFnPtr) {
    CGM.ErrorUnsupported(&S, "Obj-C fast enumeration for this runtime");
    return;
  }
  CGCallee EnumerationMutationFn =
    CGCallee::forDirect(EnumerationMutationFnPtr);

  CGDebugInfo *DI = getDebugInfo();
  if (DI)
    DI->EmitLexicalBlockStart(Builder, S.getSourceRange().getBegin());

  // The local variable comes into scope immediately.
  AutoVarEmission variable = AutoVarEmission::invalid();
  if (const DeclStmt *SD = dyn_cast<DeclStmt>(S.getElement()))
    variable = EmitAutoVarAlloca(*cast<VarDecl>(SD->getSingleDecl()));

  JumpDest LoopEnd = getJumpDestInCurrentScope("forcoll.end");

  // Fast enumeration state.
  QualType StateTy = CGM.getObjCFastEnumerationStateType();
  Address StatePtr = CreateMemTemp(StateTy, "state.ptr");
  EmitNullInitialization(StatePtr, StateTy);

  // Number of elements in the items array.
  static const unsigned NumItems = 16;

  // Fetch the countByEnumeratingWithState:objects:count: selector.
  IdentifierInfo *II[] = {
    &CGM.getContext().Idents.get("countByEnumeratingWithState"),
    &CGM.getContext().Idents.get("objects"),
    &CGM.getContext().Idents.get("count")
  };
  Selector FastEnumSel =
    CGM.getContext().Selectors.getSelector(llvm::array_lengthof(II), &II[0]);

  QualType ItemsTy =
    getContext().getConstantArrayType(getContext().getObjCIdType(),
                                      llvm::APInt(32, NumItems),
                                      ArrayType::Normal, 0);
  Address ItemsPtr = CreateMemTemp(ItemsTy, "items.ptr");

  RunCleanupsScope ForScope(*this);

  // Emit the collection pointer.  In ARC, we do a retain.
  llvm::Value *Collection;
  if (getLangOpts().ObjCAutoRefCount) {
    Collection = EmitARCRetainScalarExpr(S.getCollection());

    // Enter a cleanup to do the release.
    EmitObjCConsumeObject(S.getCollection()->getType(), Collection);
  } else {
    Collection = EmitScalarExpr(S.getCollection());
  }

  // The 'continue' label needs to appear within the cleanup for the
  // collection object.
  JumpDest AfterBody = getJumpDestInCurrentScope("forcoll.next");

  // Send it our message:
  CallArgList Args;

  // The first argument is a temporary of the enumeration-state type.
  Args.add(RValue::get(StatePtr.getPointer()),
           getContext().getPointerType(StateTy));

  // The second argument is a temporary array with space for NumItems
  // pointers.  We'll actually be loading elements from the array
  // pointer written into the control state; this buffer is so that
  // collections that *aren't* backed by arrays can still queue up
  // batches of elements.
  Args.add(RValue::get(ItemsPtr.getPointer()),
           getContext().getPointerType(ItemsTy));

  // The third argument is the capacity of that temporary array.
  llvm::Type *UnsignedLongLTy = ConvertType(getContext().UnsignedLongTy);
  llvm::Constant *Count = llvm::ConstantInt::get(UnsignedLongLTy, NumItems);
  Args.add(RValue::get(Count), getContext().UnsignedLongTy);

  // Start the enumeration.
  RValue CountRV =
    CGM.getObjCRuntime().GenerateMessageSend(*this, ReturnValueSlot(),
                                             getContext().UnsignedLongTy,
                                             FastEnumSel,
                                             Collection, Args);

  // The initial number of objects that were returned in the buffer.
  llvm::Value *initialBufferLimit = CountRV.getScalarVal();

  llvm::BasicBlock *EmptyBB = createBasicBlock("forcoll.empty");
  llvm::BasicBlock *LoopInitBB = createBasicBlock("forcoll.loopinit");

  llvm::Value *zero = llvm::Constant::getNullValue(UnsignedLongLTy);

  // If the limit pointer was zero to begin with, the collection is
  // empty; skip all this. Set the branch weight assuming this has the same
  // probability of exiting the loop as any other loop exit.
  uint64_t EntryCount = getCurrentProfileCount();
  Builder.CreateCondBr(
      Builder.CreateICmpEQ(initialBufferLimit, zero, "iszero"), EmptyBB,
      LoopInitBB,
      createProfileWeights(EntryCount, getProfileCount(S.getBody())));

  // Otherwise, initialize the loop.
  EmitBlock(LoopInitBB);

  // Save the initial mutations value.  This is the value at an
  // address that was written into the state object by
  // countByEnumeratingWithState:objects:count:.
  Address StateMutationsPtrPtr = Builder.CreateStructGEP(
      StatePtr, 2, 2 * getPointerSize(), "mutationsptr.ptr");
  llvm::Value *StateMutationsPtr
    = Builder.CreateLoad(StateMutationsPtrPtr, "mutationsptr");

  llvm::Value *initialMutations =
    Builder.CreateAlignedLoad(StateMutationsPtr, getPointerAlign(),
                              "forcoll.initial-mutations");

  // Start looping.  This is the point we return to whenever we have a
  // fresh, non-empty batch of objects.
  llvm::BasicBlock *LoopBodyBB = createBasicBlock("forcoll.loopbody");
  EmitBlock(LoopBodyBB);

  // The current index into the buffer.
  llvm::PHINode *index = Builder.CreatePHI(UnsignedLongLTy, 3, "forcoll.index");
  index->addIncoming(zero, LoopInitBB);

  // The current buffer size.
  llvm::PHINode *count = Builder.CreatePHI(UnsignedLongLTy, 3, "forcoll.count");
  count->addIncoming(initialBufferLimit, LoopInitBB);

  incrementProfileCounter(&S);

  // Check whether the mutations value has changed from where it was
  // at start.  StateMutationsPtr should actually be invariant between
  // refreshes.
  StateMutationsPtr = Builder.CreateLoad(StateMutationsPtrPtr, "mutationsptr");
  llvm::Value *currentMutations
    = Builder.CreateAlignedLoad(StateMutationsPtr, getPointerAlign(),
                                "statemutations");

  llvm::BasicBlock *WasMutatedBB = createBasicBlock("forcoll.mutated");
  llvm::BasicBlock *WasNotMutatedBB = createBasicBlock("forcoll.notmutated");

  Builder.CreateCondBr(Builder.CreateICmpEQ(currentMutations, initialMutations),
                       WasNotMutatedBB, WasMutatedBB);

  // If so, call the enumeration-mutation function.
  EmitBlock(WasMutatedBB);
  llvm::Value *V =
    Builder.CreateBitCast(Collection,
                          ConvertType(getContext().getObjCIdType()));
  CallArgList Args2;
  Args2.add(RValue::get(V), getContext().getObjCIdType());
  // FIXME: We shouldn't need to get the function info here, the runtime already
  // should have computed it to build the function.
  EmitCall(
          CGM.getTypes().arrangeBuiltinFunctionCall(getContext().VoidTy, Args2),
           EnumerationMutationFn, ReturnValueSlot(), Args2);

  // Otherwise, or if the mutation function returns, just continue.
  EmitBlock(WasNotMutatedBB);

  // Initialize the element variable.
  RunCleanupsScope elementVariableScope(*this);
  bool elementIsVariable;
  LValue elementLValue;
  QualType elementType;
  if (const DeclStmt *SD = dyn_cast<DeclStmt>(S.getElement())) {
    // Initialize the variable, in case it's a __block variable or something.
    EmitAutoVarInit(variable);

    const VarDecl* D = cast<VarDecl>(SD->getSingleDecl());
    DeclRefExpr tempDRE(const_cast<VarDecl*>(D), false, D->getType(),
                        VK_LValue, SourceLocation());
    elementLValue = EmitLValue(&tempDRE);
    elementType = D->getType();
    elementIsVariable = true;

    if (D->isARCPseudoStrong())
      elementLValue.getQuals().setObjCLifetime(Qualifiers::OCL_ExplicitNone);
  } else {
    elementLValue = LValue(); // suppress warning
    elementType = cast<Expr>(S.getElement())->getType();
    elementIsVariable = false;
  }
  llvm::Type *convertedElementType = ConvertType(elementType);

  // Fetch the buffer out of the enumeration state.
  // TODO: this pointer should actually be invariant between
  // refreshes, which would help us do certain loop optimizations.
  Address StateItemsPtr = Builder.CreateStructGEP(
      StatePtr, 1, getPointerSize(), "stateitems.ptr");
  llvm::Value *EnumStateItems =
    Builder.CreateLoad(StateItemsPtr, "stateitems");

  // Fetch the value at the current index from the buffer.
  llvm::Value *CurrentItemPtr =
    Builder.CreateGEP(EnumStateItems, index, "currentitem.ptr");
  llvm::Value *CurrentItem =
    Builder.CreateAlignedLoad(CurrentItemPtr, getPointerAlign());

  // Cast that value to the right type.
  CurrentItem = Builder.CreateBitCast(CurrentItem, convertedElementType,
                                      "currentitem");

  // Make sure we have an l-value.  Yes, this gets evaluated every
  // time through the loop.
  if (!elementIsVariable) {
    elementLValue = EmitLValue(cast<Expr>(S.getElement()));
    EmitStoreThroughLValue(RValue::get(CurrentItem), elementLValue);
  } else {
    EmitStoreThroughLValue(RValue::get(CurrentItem), elementLValue,
                           /*isInit*/ true);
  }

  // If we do have an element variable, this assignment is the end of
  // its initialization.
  if (elementIsVariable)
    EmitAutoVarCleanups(variable);

  // Perform the loop body, setting up break and continue labels.
  BreakContinueStack.push_back(BreakContinue(LoopEnd, AfterBody));
  {
    RunCleanupsScope Scope(*this);
    EmitStmt(S.getBody());
  }
  BreakContinueStack.pop_back();

  // Destroy the element variable now.
  elementVariableScope.ForceCleanup();

  // Check whether there are more elements.
  EmitBlock(AfterBody.getBlock());

  llvm::BasicBlock *FetchMoreBB = createBasicBlock("forcoll.refetch");

  // First we check in the local buffer.
  llvm::Value *indexPlusOne
    = Builder.CreateAdd(index, llvm::ConstantInt::get(UnsignedLongLTy, 1));

  // If we haven't overrun the buffer yet, we can continue.
  // Set the branch weights based on the simplifying assumption that this is
  // like a while-loop, i.e., ignoring that the false branch fetches more
  // elements and then returns to the loop.
  Builder.CreateCondBr(
      Builder.CreateICmpULT(indexPlusOne, count), LoopBodyBB, FetchMoreBB,
      createProfileWeights(getProfileCount(S.getBody()), EntryCount));

  index->addIncoming(indexPlusOne, AfterBody.getBlock());
  count->addIncoming(count, AfterBody.getBlock());

  // Otherwise, we have to fetch more elements.
  EmitBlock(FetchMoreBB);

  CountRV =
    CGM.getObjCRuntime().GenerateMessageSend(*this, ReturnValueSlot(),
                                             getContext().UnsignedLongTy,
                                             FastEnumSel,
                                             Collection, Args);

  // If we got a zero count, we're done.
  llvm::Value *refetchCount = CountRV.getScalarVal();

  // (note that the message send might split FetchMoreBB)
  index->addIncoming(zero, Builder.GetInsertBlock());
  count->addIncoming(refetchCount, Builder.GetInsertBlock());

  Builder.CreateCondBr(Builder.CreateICmpEQ(refetchCount, zero),
                       EmptyBB, LoopBodyBB);

  // No more elements.
  EmitBlock(EmptyBB);

  if (!elementIsVariable) {
    // If the element was not a declaration, set it to be null.

    llvm::Value *null = llvm::Constant::getNullValue(convertedElementType);
    elementLValue = EmitLValue(cast<Expr>(S.getElement()));
    EmitStoreThroughLValue(RValue::get(null), elementLValue);
  }

  if (DI)
    DI->EmitLexicalBlockEnd(Builder, S.getSourceRange().getEnd());

  ForScope.ForceCleanup();
  EmitBlock(LoopEnd.getBlock());
}

void CodeGenFunction::EmitObjCAtTryStmt(const ObjCAtTryStmt &S) {
  CGM.getObjCRuntime().EmitTryStmt(*this, S);
}

void CodeGenFunction::EmitObjCAtThrowStmt(const ObjCAtThrowStmt &S) {
  CGM.getObjCRuntime().EmitThrowStmt(*this, S);
}

void CodeGenFunction::EmitObjCAtSynchronizedStmt(
                                              const ObjCAtSynchronizedStmt &S) {
  CGM.getObjCRuntime().EmitSynchronizedStmt(*this, S);
}

namespace {
  struct CallObjCRelease final : EHScopeStack::Cleanup {
    CallObjCRelease(llvm::Value *object) : object(object) {}
    llvm::Value *object;

    void Emit(CodeGenFunction &CGF, Flags flags) override {
      // Releases at the end of the full-expression are imprecise.
      CGF.EmitARCRelease(object, ARCImpreciseLifetime);
    }
  };
}

/// Produce the code for a CK_ARCConsumeObject.  Does a primitive
/// release at the end of the full-expression.
llvm::Value *CodeGenFunction::EmitObjCConsumeObject(QualType type,
                                                    llvm::Value *object) {
  // If we're in a conditional branch, we need to make the cleanup
  // conditional.
  pushFullExprCleanup<CallObjCRelease>(getARCCleanupKind(), object);
  return object;
}

llvm::Value *CodeGenFunction::EmitObjCExtendObjectLifetime(QualType type,
                                                           llvm::Value *value) {
  return EmitARCRetainAutorelease(type, value);
}

/// Given a number of pointers, inform the optimizer that they're
/// being intrinsically used up until this point in the program.
void CodeGenFunction::EmitARCIntrinsicUse(ArrayRef<llvm::Value*> values) {
  llvm::Constant *&fn = CGM.getObjCEntrypoints().clang_arc_use;
  if (!fn) {
    llvm::FunctionType *fnType =
      llvm::FunctionType::get(CGM.VoidTy, None, true);
    fn = CGM.CreateRuntimeFunction(fnType, "clang.arc.use");
  }

  // This isn't really a "runtime" function, but as an intrinsic it
  // doesn't really matter as long as we align things up.
  EmitNounwindRuntimeCall(fn, values);
}


static llvm::Constant *createARCRuntimeFunction(CodeGenModule &CGM,
                                                llvm::FunctionType *type,
                                                StringRef fnName) {
  llvm::Constant *fn = CGM.CreateRuntimeFunction(type, fnName);

  if (llvm::Function *f = dyn_cast<llvm::Function>(fn)) {
    // If the target runtime doesn't naturally support ARC, emit weak
    // references to the runtime support library.  We don't really
    // permit this to fail, but we need a particular relocation style.
    if (!CGM.getLangOpts().ObjCRuntime.hasNativeARC() &&
        !CGM.getTriple().isOSBinFormatCOFF()) {
      f->setLinkage(llvm::Function::ExternalWeakLinkage);
    } else if (fnName == "objc_retain" || fnName  == "objc_release") {
      // If we have Native ARC, set nonlazybind attribute for these APIs for
      // performance.
      f->addFnAttr(llvm::Attribute::NonLazyBind);
    }
  }

  return fn;
}

/// Perform an operation having the signature
///   i8* (i8*)
/// where a null input causes a no-op and returns null.
static llvm::Value *emitARCValueOperation(CodeGenFunction &CGF,
                                          llvm::Value *value,
                                          llvm::Constant *&fn,
                                          StringRef fnName,
                                          bool isTailCall = false) {
  if (isa<llvm::ConstantPointerNull>(value)) return value;

  if (!fn) {
    llvm::FunctionType *fnType =
      llvm::FunctionType::get(CGF.Int8PtrTy, CGF.Int8PtrTy, false);
    fn = createARCRuntimeFunction(CGF.CGM, fnType, fnName);
  }

  // Cast the argument to 'id'.
  llvm::Type *origType = value->getType();
  value = CGF.Builder.CreateBitCast(value, CGF.Int8PtrTy);

  // Call the function.
  llvm::CallInst *call = CGF.EmitNounwindRuntimeCall(fn, value);
  if (isTailCall)
    call->setTailCall();

  // Cast the result back to the original type.
  return CGF.Builder.CreateBitCast(call, origType);
}

/// Perform an operation having the following signature:
///   i8* (i8**)
static llvm::Value *emitARCLoadOperation(CodeGenFunction &CGF,
                                         Address addr,
                                         llvm::Constant *&fn,
                                         StringRef fnName) {
  if (!fn) {
    llvm::FunctionType *fnType =
      llvm::FunctionType::get(CGF.Int8PtrTy, CGF.Int8PtrPtrTy, false);
    fn = createARCRuntimeFunction(CGF.CGM, fnType, fnName);
  }

  // Cast the argument to 'id*'.
  llvm::Type *origType = addr.getElementType();
  addr = CGF.Builder.CreateBitCast(addr, CGF.Int8PtrPtrTy);

  // Call the function.
  llvm::Value *result = CGF.EmitNounwindRuntimeCall(fn, addr.getPointer());

  // Cast the result back to a dereference of the original type.
  if (origType != CGF.Int8PtrTy)
    result = CGF.Builder.CreateBitCast(result, origType);

  return result;
}

/// Perform an operation having the following signature:
///   i8* (i8**, i8*)
static llvm::Value *emitARCStoreOperation(CodeGenFunction &CGF,
                                          Address addr,
                                          llvm::Value *value,
                                          llvm::Constant *&fn,
                                          StringRef fnName,
                                          bool ignored) {
  assert(addr.getElementType() == value->getType());

  if (!fn) {
    llvm::Type *argTypes[] = { CGF.Int8PtrPtrTy, CGF.Int8PtrTy };

    llvm::FunctionType *fnType
      = llvm::FunctionType::get(CGF.Int8PtrTy, argTypes, false);
    fn = createARCRuntimeFunction(CGF.CGM, fnType, fnName);
  }

  llvm::Type *origType = value->getType();

  llvm::Value *args[] = {
    CGF.Builder.CreateBitCast(addr.getPointer(), CGF.Int8PtrPtrTy),
    CGF.Builder.CreateBitCast(value, CGF.Int8PtrTy)
  };
  llvm::CallInst *result = CGF.EmitNounwindRuntimeCall(fn, args);

  if (ignored) return nullptr;

  return CGF.Builder.CreateBitCast(result, origType);
}

/// Perform an operation having the following signature:
///   void (i8**, i8**)
static void emitARCCopyOperation(CodeGenFunction &CGF,
                                 Address dst,
                                 Address src,
                                 llvm::Constant *&fn,
                                 StringRef fnName) {
  assert(dst.getType() == src.getType());

  if (!fn) {
    llvm::Type *argTypes[] = { CGF.Int8PtrPtrTy, CGF.Int8PtrPtrTy };

    llvm::FunctionType *fnType
      = llvm::FunctionType::get(CGF.Builder.getVoidTy(), argTypes, false);
    fn = createARCRuntimeFunction(CGF.CGM, fnType, fnName);
  }

  llvm::Value *args[] = {
    CGF.Builder.CreateBitCast(dst.getPointer(), CGF.Int8PtrPtrTy),
    CGF.Builder.CreateBitCast(src.getPointer(), CGF.Int8PtrPtrTy)
  };
  CGF.EmitNounwindRuntimeCall(fn, args);
}

/// Produce the code to do a retain.  Based on the type, calls one of:
///   call i8* \@objc_retain(i8* %value)
///   call i8* \@objc_retainBlock(i8* %value)
llvm::Value *CodeGenFunction::EmitARCRetain(QualType type, llvm::Value *value) {
  if (type->isBlockPointerType())
    return EmitARCRetainBlock(value, /*mandatory*/ false);
  else
    return EmitARCRetainNonBlock(value);
}

/// Retain the given object, with normal retain semantics.
///   call i8* \@objc_retain(i8* %value)
llvm::Value *CodeGenFunction::EmitARCRetainNonBlock(llvm::Value *value) {
  return emitARCValueOperation(*this, value,
                               CGM.getObjCEntrypoints().objc_retain,
                               "objc_retain");
}

/// Retain the given block, with _Block_copy semantics.
///   call i8* \@objc_retainBlock(i8* %value)
///
/// \param mandatory - If false, emit the call with metadata
/// indicating that it's okay for the optimizer to eliminate this call
/// if it can prove that the block never escapes except down the stack.
llvm::Value *CodeGenFunction::EmitARCRetainBlock(llvm::Value *value,
                                                 bool mandatory) {
  llvm::Value *result
    = emitARCValueOperation(*this, value,
                            CGM.getObjCEntrypoints().objc_retainBlock,
                            "objc_retainBlock");

  // If the copy isn't mandatory, add !clang.arc.copy_on_escape to
  // tell the optimizer that it doesn't need to do this copy if the
  // block doesn't escape, where being passed as an argument doesn't
  // count as escaping.
  if (!mandatory && isa<llvm::Instruction>(result)) {
    llvm::CallInst *call
      = cast<llvm::CallInst>(result->stripPointerCasts());
    assert(call->getCalledValue() == CGM.getObjCEntrypoints().objc_retainBlock);

    call->setMetadata("clang.arc.copy_on_escape",
                      llvm::MDNode::get(Builder.getContext(), None));
  }

  return result;
}

static void emitAutoreleasedReturnValueMarker(CodeGenFunction &CGF) {
  // Fetch the void(void) inline asm which marks that we're going to
  // do something with the autoreleased return value.
  llvm::InlineAsm *&marker
    = CGF.CGM.getObjCEntrypoints().retainAutoreleasedReturnValueMarker;
  if (!marker) {
    StringRef assembly
      = CGF.CGM.getTargetCodeGenInfo()
           .getARCRetainAutoreleasedReturnValueMarker();

    // If we have an empty assembly string, there's nothing to do.
    if (assembly.empty()) {

    // Otherwise, at -O0, build an inline asm that we're going to call
    // in a moment.
    } else if (CGF.CGM.getCodeGenOpts().OptimizationLevel == 0) {
      llvm::FunctionType *type =
        llvm::FunctionType::get(CGF.VoidTy, /*variadic*/false);
      
      marker = llvm::InlineAsm::get(type, assembly, "", /*sideeffects*/ true);

    // If we're at -O1 and above, we don't want to litter the code
    // with this marker yet, so leave a breadcrumb for the ARC
    // optimizer to pick up.
    } else {
      llvm::NamedMDNode *metadata =
        CGF.CGM.getModule().getOrInsertNamedMetadata(
                            "clang.arc.retainAutoreleasedReturnValueMarker");
      assert(metadata->getNumOperands() <= 1);
      if (metadata->getNumOperands() == 0) {
        auto &ctx = CGF.getLLVMContext();
        metadata->addOperand(llvm::MDNode::get(ctx,
                                     llvm::MDString::get(ctx, assembly)));
      }
    }
  }

  // Call the marker asm if we made one, which we do only at -O0.
  if (marker)
    CGF.Builder.CreateCall(marker);
}

/// Retain the given object which is the result of a function call.
///   call i8* \@objc_retainAutoreleasedReturnValue(i8* %value)
///
/// Yes, this function name is one character away from a different
/// call with completely different semantics.
llvm::Value *
CodeGenFunction::EmitARCRetainAutoreleasedReturnValue(llvm::Value *value) {
  emitAutoreleasedReturnValueMarker(*this);
  return emitARCValueOperation(*this, value,
              CGM.getObjCEntrypoints().objc_retainAutoreleasedReturnValue,
                               "objc_retainAutoreleasedReturnValue");
}

/// Claim a possibly-autoreleased return value at +0.  This is only
/// valid to do in contexts which do not rely on the retain to keep
/// the object valid for for all of its uses; for example, when
/// the value is ignored, or when it is being assigned to an
/// __unsafe_unretained variable.
///
///   call i8* \@objc_unsafeClaimAutoreleasedReturnValue(i8* %value)
llvm::Value *
CodeGenFunction::EmitARCUnsafeClaimAutoreleasedReturnValue(llvm::Value *value) {
  emitAutoreleasedReturnValueMarker(*this);
  return emitARCValueOperation(*this, value,
              CGM.getObjCEntrypoints().objc_unsafeClaimAutoreleasedReturnValue,
                               "objc_unsafeClaimAutoreleasedReturnValue");
}

/// Release the given object.
///   call void \@objc_release(i8* %value)
void CodeGenFunction::EmitARCRelease(llvm::Value *value,
                                     ARCPreciseLifetime_t precise) {
  if (isa<llvm::ConstantPointerNull>(value)) return;

  llvm::Constant *&fn = CGM.getObjCEntrypoints().objc_release;
  if (!fn) {
    llvm::FunctionType *fnType =
      llvm::FunctionType::get(Builder.getVoidTy(), Int8PtrTy, false);
    fn = createARCRuntimeFunction(CGM, fnType, "objc_release");
  }

  // Cast the argument to 'id'.
  value = Builder.CreateBitCast(value, Int8PtrTy);

  // Call objc_release.
  llvm::CallInst *call = EmitNounwindRuntimeCall(fn, value);

  if (precise == ARCImpreciseLifetime) {
    call->setMetadata("clang.imprecise_release",
                      llvm::MDNode::get(Builder.getContext(), None));
  }
}

/// Destroy a __strong variable.
///
/// At -O0, emit a call to store 'null' into the address;
/// instrumenting tools prefer this because the address is exposed,
/// but it's relatively cumbersome to optimize.
///
/// At -O1 and above, just load and call objc_release.
///
///   call void \@objc_storeStrong(i8** %addr, i8* null)
void CodeGenFunction::EmitARCDestroyStrong(Address addr,
                                           ARCPreciseLifetime_t precise) {
  if (CGM.getCodeGenOpts().OptimizationLevel == 0) {
    llvm::Value *null = getNullForVariable(addr);
    EmitARCStoreStrongCall(addr, null, /*ignored*/ true);
    return;
  }

  llvm::Value *value = Builder.CreateLoad(addr);
  EmitARCRelease(value, precise);
}

/// Store into a strong object.  Always calls this:
///   call void \@objc_storeStrong(i8** %addr, i8* %value)
llvm::Value *CodeGenFunction::EmitARCStoreStrongCall(Address addr,
                                                     llvm::Value *value,
                                                     bool ignored) {
  assert(addr.getElementType() == value->getType());

  llvm::Constant *&fn = CGM.getObjCEntrypoints().objc_storeStrong;
  if (!fn) {
    llvm::Type *argTypes[] = { Int8PtrPtrTy, Int8PtrTy };
    llvm::FunctionType *fnType
      = llvm::FunctionType::get(Builder.getVoidTy(), argTypes, false);
    fn = createARCRuntimeFunction(CGM, fnType, "objc_storeStrong");
  }

  llvm::Value *args[] = {
    Builder.CreateBitCast(addr.getPointer(), Int8PtrPtrTy),
    Builder.CreateBitCast(value, Int8PtrTy)
  };
  EmitNounwindRuntimeCall(fn, args);

  if (ignored) return nullptr;
  return value;
}

/// Store into a strong object.  Sometimes calls this:
///   call void \@objc_storeStrong(i8** %addr, i8* %value)
/// Other times, breaks it down into components.
llvm::Value *CodeGenFunction::EmitARCStoreStrong(LValue dst,
                                                 llvm::Value *newValue,
                                                 bool ignored) {
  QualType type = dst.getType();
  bool isBlock = type->isBlockPointerType();

  // Use a store barrier at -O0 unless this is a block type or the
  // lvalue is inadequately aligned.
  if (shouldUseFusedARCCalls() &&
      !isBlock &&
      (dst.getAlignment().isZero() ||
       dst.getAlignment() >= CharUnits::fromQuantity(PointerAlignInBytes))) {
    return EmitARCStoreStrongCall(dst.getAddress(), newValue, ignored);
  }

  // Otherwise, split it out.

  // Retain the new value.
  newValue = EmitARCRetain(type, newValue);

  // Read the old value.
  llvm::Value *oldValue = EmitLoadOfScalar(dst, SourceLocation());

  // Store.  We do this before the release so that any deallocs won't
  // see the old value.
  EmitStoreOfScalar(newValue, dst);

  // Finally, release the old value.
  EmitARCRelease(oldValue, dst.isARCPreciseLifetime());

  return newValue;
}

/// Autorelease the given object.
///   call i8* \@objc_autorelease(i8* %value)
llvm::Value *CodeGenFunction::EmitARCAutorelease(llvm::Value *value) {
  return emitARCValueOperation(*this, value,
                               CGM.getObjCEntrypoints().objc_autorelease,
                               "objc_autorelease");
}

/// Autorelease the given object.
///   call i8* \@objc_autoreleaseReturnValue(i8* %value)
llvm::Value *
CodeGenFunction::EmitARCAutoreleaseReturnValue(llvm::Value *value) {
  return emitARCValueOperation(*this, value,
                            CGM.getObjCEntrypoints().objc_autoreleaseReturnValue,
                               "objc_autoreleaseReturnValue",
                               /*isTailCall*/ true);
}

/// Do a fused retain/autorelease of the given object.
///   call i8* \@objc_retainAutoreleaseReturnValue(i8* %value)
llvm::Value *
CodeGenFunction::EmitARCRetainAutoreleaseReturnValue(llvm::Value *value) {
  return emitARCValueOperation(*this, value,
                     CGM.getObjCEntrypoints().objc_retainAutoreleaseReturnValue,
                               "objc_retainAutoreleaseReturnValue",
                               /*isTailCall*/ true);
}

/// Do a fused retain/autorelease of the given object.
///   call i8* \@objc_retainAutorelease(i8* %value)
/// or
///   %retain = call i8* \@objc_retainBlock(i8* %value)
///   call i8* \@objc_autorelease(i8* %retain)
llvm::Value *CodeGenFunction::EmitARCRetainAutorelease(QualType type,
                                                       llvm::Value *value) {
  if (!type->isBlockPointerType())
    return EmitARCRetainAutoreleaseNonBlock(value);

  if (isa<llvm::ConstantPointerNull>(value)) return value;

  llvm::Type *origType = value->getType();
  value = Builder.CreateBitCast(value, Int8PtrTy);
  value = EmitARCRetainBlock(value, /*mandatory*/ true);
  value = EmitARCAutorelease(value);
  return Builder.CreateBitCast(value, origType);
}

/// Do a fused retain/autorelease of the given object.
///   call i8* \@objc_retainAutorelease(i8* %value)
llvm::Value *
CodeGenFunction::EmitARCRetainAutoreleaseNonBlock(llvm::Value *value) {
  return emitARCValueOperation(*this, value,
                               CGM.getObjCEntrypoints().objc_retainAutorelease,
                               "objc_retainAutorelease");
}

/// i8* \@objc_loadWeak(i8** %addr)
/// Essentially objc_autorelease(objc_loadWeakRetained(addr)).
llvm::Value *CodeGenFunction::EmitARCLoadWeak(Address addr) {
  return emitARCLoadOperation(*this, addr,
                              CGM.getObjCEntrypoints().objc_loadWeak,
                              "objc_loadWeak");
}

/// i8* \@objc_loadWeakRetained(i8** %addr)
llvm::Value *CodeGenFunction::EmitARCLoadWeakRetained(Address addr) {
  return emitARCLoadOperation(*this, addr,
                              CGM.getObjCEntrypoints().objc_loadWeakRetained,
                              "objc_loadWeakRetained");
}

/// i8* \@objc_storeWeak(i8** %addr, i8* %value)
/// Returns %value.
llvm::Value *CodeGenFunction::EmitARCStoreWeak(Address addr,
                                               llvm::Value *value,
                                               bool ignored) {
  return emitARCStoreOperation(*this, addr, value,
                               CGM.getObjCEntrypoints().objc_storeWeak,
                               "objc_storeWeak", ignored);
}

/// i8* \@objc_initWeak(i8** %addr, i8* %value)
/// Returns %value.  %addr is known to not have a current weak entry.
/// Essentially equivalent to:
///   *addr = nil; objc_storeWeak(addr, value);
void CodeGenFunction::EmitARCInitWeak(Address addr, llvm::Value *value) {
  // If we're initializing to null, just write null to memory; no need
  // to get the runtime involved.  But don't do this if optimization
  // is enabled, because accounting for this would make the optimizer
  // much more complicated.
  if (isa<llvm::ConstantPointerNull>(value) &&
      CGM.getCodeGenOpts().OptimizationLevel == 0) {
    Builder.CreateStore(value, addr);
    return;
  }

  emitARCStoreOperation(*this, addr, value,
                        CGM.getObjCEntrypoints().objc_initWeak,
                        "objc_initWeak", /*ignored*/ true);
}

/// void \@objc_destroyWeak(i8** %addr)
/// Essentially objc_storeWeak(addr, nil).
void CodeGenFunction::EmitARCDestroyWeak(Address addr) {
  llvm::Constant *&fn = CGM.getObjCEntrypoints().objc_destroyWeak;
  if (!fn) {
    llvm::FunctionType *fnType =
      llvm::FunctionType::get(Builder.getVoidTy(), Int8PtrPtrTy, false);
    fn = createARCRuntimeFunction(CGM, fnType, "objc_destroyWeak");
  }

  // Cast the argument to 'id*'.
  addr = Builder.CreateBitCast(addr, Int8PtrPtrTy);

  EmitNounwindRuntimeCall(fn, addr.getPointer());
}

/// void \@objc_moveWeak(i8** %dest, i8** %src)
/// Disregards the current value in %dest.  Leaves %src pointing to nothing.
/// Essentially (objc_copyWeak(dest, src), objc_destroyWeak(src)).
void CodeGenFunction::EmitARCMoveWeak(Address dst, Address src) {
  emitARCCopyOperation(*this, dst, src,
                       CGM.getObjCEntrypoints().objc_moveWeak,
                       "objc_moveWeak");
}

/// void \@objc_copyWeak(i8** %dest, i8** %src)
/// Disregards the current value in %dest.  Essentially
///   objc_release(objc_initWeak(dest, objc_readWeakRetained(src)))
void CodeGenFunction::EmitARCCopyWeak(Address dst, Address src) {
  emitARCCopyOperation(*this, dst, src,
                       CGM.getObjCEntrypoints().objc_copyWeak,
                       "objc_copyWeak");
}

/// Produce the code to do a objc_autoreleasepool_push.
///   call i8* \@objc_autoreleasePoolPush(void)
llvm::Value *CodeGenFunction::EmitObjCAutoreleasePoolPush() {
  llvm::Constant *&fn = CGM.getObjCEntrypoints().objc_autoreleasePoolPush;
  if (!fn) {
    llvm::FunctionType *fnType =
      llvm::FunctionType::get(Int8PtrTy, false);
    fn = createARCRuntimeFunction(CGM, fnType, "objc_autoreleasePoolPush");
  }

  return EmitNounwindRuntimeCall(fn);
}

/// Produce the code to do a primitive release.
///   call void \@objc_autoreleasePoolPop(i8* %ptr)
void CodeGenFunction::EmitObjCAutoreleasePoolPop(llvm::Value *value) {
  assert(value->getType() == Int8PtrTy);

  llvm::Constant *&fn = CGM.getObjCEntrypoints().objc_autoreleasePoolPop;
  if (!fn) {
    llvm::FunctionType *fnType =
      llvm::FunctionType::get(Builder.getVoidTy(), Int8PtrTy, false);

    // We don't want to use a weak import here; instead we should not
    // fall into this path.
    fn = createARCRuntimeFunction(CGM, fnType, "objc_autoreleasePoolPop");
  }

  // objc_autoreleasePoolPop can throw.
  EmitRuntimeCallOrInvoke(fn, value);
}

/// Produce the code to do an MRR version objc_autoreleasepool_push.
/// Which is: [[NSAutoreleasePool alloc] init];
/// Where alloc is declared as: + (id) alloc; in NSAutoreleasePool class.
/// init is declared as: - (id) init; in its NSObject super class.
///
llvm::Value *CodeGenFunction::EmitObjCMRRAutoreleasePoolPush() {
  CGObjCRuntime &Runtime = CGM.getObjCRuntime();
  llvm::Value *Receiver = Runtime.EmitNSAutoreleasePoolClassRef(*this);
  // [NSAutoreleasePool alloc]
  IdentifierInfo *II = &CGM.getContext().Idents.get("alloc");
  Selector AllocSel = getContext().Selectors.getSelector(0, &II);
  CallArgList Args;
  RValue AllocRV =  
    Runtime.GenerateMessageSend(*this, ReturnValueSlot(), 
                                getContext().getObjCIdType(),
                                AllocSel, Receiver, Args); 

  // [Receiver init]
  Receiver = AllocRV.getScalarVal();
  II = &CGM.getContext().Idents.get("init");
  Selector InitSel = getContext().Selectors.getSelector(0, &II);
  RValue InitRV =
    Runtime.GenerateMessageSend(*this, ReturnValueSlot(),
                                getContext().getObjCIdType(),
                                InitSel, Receiver, Args); 
  return InitRV.getScalarVal();
}

/// Produce the code to do a primitive release.
/// [tmp drain];
void CodeGenFunction::EmitObjCMRRAutoreleasePoolPop(llvm::Value *Arg) {
  IdentifierInfo *II = &CGM.getContext().Idents.get("drain");
  Selector DrainSel = getContext().Selectors.getSelector(0, &II);
  CallArgList Args;
  CGM.getObjCRuntime().GenerateMessageSend(*this, ReturnValueSlot(),
                              getContext().VoidTy, DrainSel, Arg, Args); 
}

void CodeGenFunction::destroyARCStrongPrecise(CodeGenFunction &CGF,
                                              Address addr,
                                              QualType type) {
  CGF.EmitARCDestroyStrong(addr, ARCPreciseLifetime);
}

void CodeGenFunction::destroyARCStrongImprecise(CodeGenFunction &CGF,
                                                Address addr,
                                                QualType type) {
  CGF.EmitARCDestroyStrong(addr, ARCImpreciseLifetime);
}

void CodeGenFunction::destroyARCWeak(CodeGenFunction &CGF,
                                     Address addr,
                                     QualType type) {
  CGF.EmitARCDestroyWeak(addr);
}

namespace {
  struct CallObjCAutoreleasePoolObject final : EHScopeStack::Cleanup {
    llvm::Value *Token;

    CallObjCAutoreleasePoolObject(llvm::Value *token) : Token(token) {}

    void Emit(CodeGenFunction &CGF, Flags flags) override {
      CGF.EmitObjCAutoreleasePoolPop(Token);
    }
  };
  struct CallObjCMRRAutoreleasePoolObject final : EHScopeStack::Cleanup {
    llvm::Value *Token;

    CallObjCMRRAutoreleasePoolObject(llvm::Value *token) : Token(token) {}

    void Emit(CodeGenFunction &CGF, Flags flags) override {
      CGF.EmitObjCMRRAutoreleasePoolPop(Token);
    }
  };
}

void CodeGenFunction::EmitObjCAutoreleasePoolCleanup(llvm::Value *Ptr) {
  if (CGM.getLangOpts().ObjCAutoRefCount)
    EHStack.pushCleanup<CallObjCAutoreleasePoolObject>(NormalCleanup, Ptr);
  else
    EHStack.pushCleanup<CallObjCMRRAutoreleasePoolObject>(NormalCleanup, Ptr);
}

static TryEmitResult tryEmitARCRetainLoadOfScalar(CodeGenFunction &CGF,
                                                  LValue lvalue,
                                                  QualType type) {
  switch (type.getObjCLifetime()) {
  case Qualifiers::OCL_None:
  case Qualifiers::OCL_ExplicitNone:
  case Qualifiers::OCL_Strong:
  case Qualifiers::OCL_Autoreleasing:
    return TryEmitResult(CGF.EmitLoadOfLValue(lvalue,
                                              SourceLocation()).getScalarVal(),
                         false);

  case Qualifiers::OCL_Weak:
    return TryEmitResult(CGF.EmitARCLoadWeakRetained(lvalue.getAddress()),
                         true);
  }

  llvm_unreachable("impossible lifetime!");
}

static TryEmitResult tryEmitARCRetainLoadOfScalar(CodeGenFunction &CGF,
                                                  const Expr *e) {
  e = e->IgnoreParens();
  QualType type = e->getType();

  // If we're loading retained from a __strong xvalue, we can avoid 
  // an extra retain/release pair by zeroing out the source of this
  // "move" operation.
  if (e->isXValue() &&
      !type.isConstQualified() &&
      type.getObjCLifetime() == Qualifiers::OCL_Strong) {
    // Emit the lvalue.
    LValue lv = CGF.EmitLValue(e);
    
    // Load the object pointer.
    llvm::Value *result = CGF.EmitLoadOfLValue(lv,
                                               SourceLocation()).getScalarVal();
    
    // Set the source pointer to NULL.
    CGF.EmitStoreOfScalar(getNullForVariable(lv.getAddress()), lv);
    
    return TryEmitResult(result, true);
  }

  // As a very special optimization, in ARC++, if the l-value is the
  // result of a non-volatile assignment, do a simple retain of the
  // result of the call to objc_storeWeak instead of reloading.
  if (CGF.getLangOpts().CPlusPlus &&
      !type.isVolatileQualified() &&
      type.getObjCLifetime() == Qualifiers::OCL_Weak &&
      isa<BinaryOperator>(e) &&
      cast<BinaryOperator>(e)->getOpcode() == BO_Assign)
    return TryEmitResult(CGF.EmitScalarExpr(e), false);

  return tryEmitARCRetainLoadOfScalar(CGF, CGF.EmitLValue(e), type);
}

typedef llvm::function_ref<llvm::Value *(CodeGenFunction &CGF,
                                         llvm::Value *value)>
  ValueTransform;

/// Insert code immediately after a call.
static llvm::Value *emitARCOperationAfterCall(CodeGenFunction &CGF,
                                              llvm::Value *value,
                                              ValueTransform doAfterCall,
                                              ValueTransform doFallback) {
  if (llvm::CallInst *call = dyn_cast<llvm::CallInst>(value)) {
    CGBuilderTy::InsertPoint ip = CGF.Builder.saveIP();

    // Place the retain immediately following the call.
    CGF.Builder.SetInsertPoint(call->getParent(),
                               ++llvm::BasicBlock::iterator(call));
    value = doAfterCall(CGF, value);

    CGF.Builder.restoreIP(ip);
    return value;
  } else if (llvm::InvokeInst *invoke = dyn_cast<llvm::InvokeInst>(value)) {
    CGBuilderTy::InsertPoint ip = CGF.Builder.saveIP();

    // Place the retain at the beginning of the normal destination block.
    llvm::BasicBlock *BB = invoke->getNormalDest();
    CGF.Builder.SetInsertPoint(BB, BB->begin());
    value = doAfterCall(CGF, value);

    CGF.Builder.restoreIP(ip);
    return value;

  // Bitcasts can arise because of related-result returns.  Rewrite
  // the operand.
  } else if (llvm::BitCastInst *bitcast = dyn_cast<llvm::BitCastInst>(value)) {
    llvm::Value *operand = bitcast->getOperand(0);
    operand = emitARCOperationAfterCall(CGF, operand, doAfterCall, doFallback);
    bitcast->setOperand(0, operand);
    return bitcast;

  // Generic fall-back case.
  } else {
    // Retain using the non-block variant: we never need to do a copy
    // of a block that's been returned to us.
    return doFallback(CGF, value);
  }
}

/// Given that the given expression is some sort of call (which does
/// not return retained), emit a retain following it.
static llvm::Value *emitARCRetainCallResult(CodeGenFunction &CGF,
                                            const Expr *e) {
  llvm::Value *value = CGF.EmitScalarExpr(e);
  return emitARCOperationAfterCall(CGF, value,
           [](CodeGenFunction &CGF, llvm::Value *value) {
             return CGF.EmitARCRetainAutoreleasedReturnValue(value);
           },
           [](CodeGenFunction &CGF, llvm::Value *value) {
             return CGF.EmitARCRetainNonBlock(value);
           });
}

/// Given that the given expression is some sort of call (which does
/// not return retained), perform an unsafeClaim following it.
static llvm::Value *emitARCUnsafeClaimCallResult(CodeGenFunction &CGF,
                                                 const Expr *e) {
  llvm::Value *value = CGF.EmitScalarExpr(e);
  return emitARCOperationAfterCall(CGF, value,
           [](CodeGenFunction &CGF, llvm::Value *value) {
             return CGF.EmitARCUnsafeClaimAutoreleasedReturnValue(value);
           },
           [](CodeGenFunction &CGF, llvm::Value *value) {
             return value;
           });
}

llvm::Value *CodeGenFunction::EmitARCReclaimReturnedObject(const Expr *E,
                                                      bool allowUnsafeClaim) {
  if (allowUnsafeClaim &&
      CGM.getLangOpts().ObjCRuntime.hasARCUnsafeClaimAutoreleasedReturnValue()) {
    return emitARCUnsafeClaimCallResult(*this, E);
  } else {
    llvm::Value *value = emitARCRetainCallResult(*this, E);
    return EmitObjCConsumeObject(E->getType(), value);
  }
}

/// Determine whether it might be important to emit a separate
/// objc_retain_block on the result of the given expression, or
/// whether it's okay to just emit it in a +1 context.
static bool shouldEmitSeparateBlockRetain(const Expr *e) {
  assert(e->getType()->isBlockPointerType());
  e = e->IgnoreParens();

  // For future goodness, emit block expressions directly in +1
  // contexts if we can.
  if (isa<BlockExpr>(e))
    return false;

  if (const CastExpr *cast = dyn_cast<CastExpr>(e)) {
    switch (cast->getCastKind()) {
    // Emitting these operations in +1 contexts is goodness.
    case CK_LValueToRValue:
    case CK_ARCReclaimReturnedObject:
    case CK_ARCConsumeObject:
    case CK_ARCProduceObject:
      return false;

    // These operations preserve a block type.
    case CK_NoOp:
    case CK_BitCast:
      return shouldEmitSeparateBlockRetain(cast->getSubExpr());

    // These operations are known to be bad (or haven't been considered).
    case CK_AnyPointerToBlockPointerCast:
    default:
      return true;
    }
  }

  return true;
}

namespace {
/// A CRTP base class for emitting expressions of retainable object
/// pointer type in ARC.
template <typename Impl, typename Result> class ARCExprEmitter {
protected:
  CodeGenFunction &CGF;
  Impl &asImpl() { return *static_cast<Impl*>(this); }

  ARCExprEmitter(CodeGenFunction &CGF) : CGF(CGF) {}

public:
  Result visit(const Expr *e);
  Result visitCastExpr(const CastExpr *e);
  Result visitPseudoObjectExpr(const PseudoObjectExpr *e);
  Result visitBinaryOperator(const BinaryOperator *e);
  Result visitBinAssign(const BinaryOperator *e);
  Result visitBinAssignUnsafeUnretained(const BinaryOperator *e);
  Result visitBinAssignAutoreleasing(const BinaryOperator *e);
  Result visitBinAssignWeak(const BinaryOperator *e);
  Result visitBinAssignStrong(const BinaryOperator *e);

  // Minimal implementation:
  //   Result visitLValueToRValue(const Expr *e)
  //   Result visitConsumeObject(const Expr *e)
  //   Result visitExtendBlockObject(const Expr *e)
  //   Result visitReclaimReturnedObject(const Expr *e)
  //   Result visitCall(const Expr *e)
  //   Result visitExpr(const Expr *e)
  //
  //   Result emitBitCast(Result result, llvm::Type *resultType)
  //   llvm::Value *getValueOfResult(Result result)
};
}

/// Try to emit a PseudoObjectExpr under special ARC rules.
///
/// This massively duplicates emitPseudoObjectRValue.
template <typename Impl, typename Result>
Result
ARCExprEmitter<Impl,Result>::visitPseudoObjectExpr(const PseudoObjectExpr *E) {
  SmallVector<CodeGenFunction::OpaqueValueMappingData, 4> opaques;

  // Find the result expression.
  const Expr *resultExpr = E->getResultExpr();
  assert(resultExpr);
  Result result;

  for (PseudoObjectExpr::const_semantics_iterator
         i = E->semantics_begin(), e = E->semantics_end(); i != e; ++i) {
    const Expr *semantic = *i;

    // If this semantic expression is an opaque value, bind it
    // to the result of its source expression.
    if (const OpaqueValueExpr *ov = dyn_cast<OpaqueValueExpr>(semantic)) {
      typedef CodeGenFunction::OpaqueValueMappingData OVMA;
      OVMA opaqueData;

      // If this semantic is the result of the pseudo-object
      // expression, try to evaluate the source as +1.
      if (ov == resultExpr) {
        assert(!OVMA::shouldBindAsLValue(ov));
        result = asImpl().visit(ov->getSourceExpr());
        opaqueData = OVMA::bind(CGF, ov,
                            RValue::get(asImpl().getValueOfResult(result)));

      // Otherwise, just bind it.
      } else {
        opaqueData = OVMA::bind(CGF, ov, ov->getSourceExpr());
      }
      opaques.push_back(opaqueData);

    // Otherwise, if the expression is the result, evaluate it
    // and remember the result.
    } else if (semantic == resultExpr) {
      result = asImpl().visit(semantic);

    // Otherwise, evaluate the expression in an ignored context.
    } else {
      CGF.EmitIgnoredExpr(semantic);
    }
  }

  // Unbind all the opaques now.
  for (unsigned i = 0, e = opaques.size(); i != e; ++i)
    opaques[i].unbind(CGF);

  return result;
}

template <typename Impl, typename Result>
Result ARCExprEmitter<Impl,Result>::visitCastExpr(const CastExpr *e) {
  switch (e->getCastKind()) {

  // No-op casts don't change the type, so we just ignore them.
  case CK_NoOp:
    return asImpl().visit(e->getSubExpr());

  // These casts can change the type.
  case CK_CPointerToObjCPointerCast:
  case CK_BlockPointerToObjCPointerCast:
  case CK_AnyPointerToBlockPointerCast:
  case CK_BitCast: {
    llvm::Type *resultType = CGF.ConvertType(e->getType());
    assert(e->getSubExpr()->getType()->hasPointerRepresentation());
    Result result = asImpl().visit(e->getSubExpr());
    return asImpl().emitBitCast(result, resultType);
  }

  // Handle some casts specially.
  case CK_LValueToRValue:
    return asImpl().visitLValueToRValue(e->getSubExpr());
  case CK_ARCConsumeObject:
    return asImpl().visitConsumeObject(e->getSubExpr());
  case CK_ARCExtendBlockObject:
    return asImpl().visitExtendBlockObject(e->getSubExpr());
  case CK_ARCReclaimReturnedObject:
    return asImpl().visitReclaimReturnedObject(e->getSubExpr());

  // Otherwise, use the default logic.
  default:
    return asImpl().visitExpr(e);
  }
}

template <typename Impl, typename Result>
Result
ARCExprEmitter<Impl,Result>::visitBinaryOperator(const BinaryOperator *e) {
  switch (e->getOpcode()) {
  case BO_Comma:
    CGF.EmitIgnoredExpr(e->getLHS());
    CGF.EnsureInsertPoint();
    return asImpl().visit(e->getRHS());

  case BO_Assign:
    return asImpl().visitBinAssign(e);

  default:
    return asImpl().visitExpr(e);
  }
}

template <typename Impl, typename Result>
Result ARCExprEmitter<Impl,Result>::visitBinAssign(const BinaryOperator *e) {
  switch (e->getLHS()->getType().getObjCLifetime()) {
  case Qualifiers::OCL_ExplicitNone:
    return asImpl().visitBinAssignUnsafeUnretained(e);

  case Qualifiers::OCL_Weak:
    return asImpl().visitBinAssignWeak(e);

  case Qualifiers::OCL_Autoreleasing:
    return asImpl().visitBinAssignAutoreleasing(e);

  case Qualifiers::OCL_Strong:
    return asImpl().visitBinAssignStrong(e);

  case Qualifiers::OCL_None:
    return asImpl().visitExpr(e);
  }
  llvm_unreachable("bad ObjC ownership qualifier");
}

/// The default rule for __unsafe_unretained emits the RHS recursively,
/// stores into the unsafe variable, and propagates the result outward.
template <typename Impl, typename Result>
Result ARCExprEmitter<Impl,Result>::
                    visitBinAssignUnsafeUnretained(const BinaryOperator *e) {
  // Recursively emit the RHS.
  // For __block safety, do this before emitting the LHS.
  Result result = asImpl().visit(e->getRHS());

  // Perform the store.
  LValue lvalue =
    CGF.EmitCheckedLValue(e->getLHS(), CodeGenFunction::TCK_Store);
  CGF.EmitStoreThroughLValue(RValue::get(asImpl().getValueOfResult(result)),
                             lvalue);

  return result;
}

template <typename Impl, typename Result>
Result
ARCExprEmitter<Impl,Result>::visitBinAssignAutoreleasing(const BinaryOperator *e) {
  return asImpl().visitExpr(e);
}

template <typename Impl, typename Result>
Result
ARCExprEmitter<Impl,Result>::visitBinAssignWeak(const BinaryOperator *e) {
  return asImpl().visitExpr(e);
}

template <typename Impl, typename Result>
Result
ARCExprEmitter<Impl,Result>::visitBinAssignStrong(const BinaryOperator *e) {
  return asImpl().visitExpr(e);
}

/// The general expression-emission logic.
template <typename Impl, typename Result>
Result ARCExprEmitter<Impl,Result>::visit(const Expr *e) {
  // We should *never* see a nested full-expression here, because if
  // we fail to emit at +1, our caller must not retain after we close
  // out the full-expression.  This isn't as important in the unsafe
  // emitter.
  assert(!isa<ExprWithCleanups>(e));

  // Look through parens, __extension__, generic selection, etc.
  e = e->IgnoreParens();

  // Handle certain kinds of casts.
  if (const CastExpr *ce = dyn_cast<CastExpr>(e)) {
    return asImpl().visitCastExpr(ce);

  // Handle the comma operator.
  } else if (auto op = dyn_cast<BinaryOperator>(e)) {
    return asImpl().visitBinaryOperator(op);

  // TODO: handle conditional operators here

  // For calls and message sends, use the retained-call logic.
  // Delegate inits are a special case in that they're the only
  // returns-retained expression that *isn't* surrounded by
  // a consume.
  } else if (isa<CallExpr>(e) ||
             (isa<ObjCMessageExpr>(e) &&
              !cast<ObjCMessageExpr>(e)->isDelegateInitCall())) {
    return asImpl().visitCall(e);

  // Look through pseudo-object expressions.
  } else if (const PseudoObjectExpr *pseudo = dyn_cast<PseudoObjectExpr>(e)) {
    return asImpl().visitPseudoObjectExpr(pseudo);
  }

  return asImpl().visitExpr(e);
}

namespace {

/// An emitter for +1 results.
struct ARCRetainExprEmitter :
  public ARCExprEmitter<ARCRetainExprEmitter, TryEmitResult> {

  ARCRetainExprEmitter(CodeGenFunction &CGF) : ARCExprEmitter(CGF) {}

  llvm::Value *getValueOfResult(TryEmitResult result) {
    return result.getPointer();
  }

  TryEmitResult emitBitCast(TryEmitResult result, llvm::Type *resultType) {
    llvm::Value *value = result.getPointer();
    value = CGF.Builder.CreateBitCast(value, resultType);
    result.setPointer(value);
    return result;
  }

  TryEmitResult visitLValueToRValue(const Expr *e) {
    return tryEmitARCRetainLoadOfScalar(CGF, e);
  }

  /// For consumptions, just emit the subexpression and thus elide
  /// the retain/release pair.
  TryEmitResult visitConsumeObject(const Expr *e) {
    llvm::Value *result = CGF.EmitScalarExpr(e);
    return TryEmitResult(result, true);
  }

  /// Block extends are net +0.  Naively, we could just recurse on
  /// the subexpression, but actually we need to ensure that the
  /// value is copied as a block, so there's a little filter here.
  TryEmitResult visitExtendBlockObject(const Expr *e) {
    llvm::Value *result; // will be a +0 value

    // If we can't safely assume the sub-expression will produce a
    // block-copied value, emit the sub-expression at +0.
    if (shouldEmitSeparateBlockRetain(e)) {
      result = CGF.EmitScalarExpr(e);

    // Otherwise, try to emit the sub-expression at +1 recursively.
    } else {
      TryEmitResult subresult = asImpl().visit(e);

      // If that produced a retained value, just use that.
      if (subresult.getInt()) {
        return subresult;
      }

      // Otherwise it's +0.
      result = subresult.getPointer();
    }

    // Retain the object as a block.
    result = CGF.EmitARCRetainBlock(result, /*mandatory*/ true);
    return TryEmitResult(result, true);
  }

  /// For reclaims, emit the subexpression as a retained call and
  /// skip the consumption.
  TryEmitResult visitReclaimReturnedObject(const Expr *e) {
    llvm::Value *result = emitARCRetainCallResult(CGF, e);
    return TryEmitResult(result, true);
  }

  /// When we have an undecorated call, retroactively do a claim.
  TryEmitResult visitCall(const Expr *e) {
    llvm::Value *result = emitARCRetainCallResult(CGF, e);
    return TryEmitResult(result, true);
  }

  // TODO: maybe special-case visitBinAssignWeak?

  TryEmitResult visitExpr(const Expr *e) {
    // We didn't find an obvious production, so emit what we've got and
    // tell the caller that we didn't manage to retain.
    llvm::Value *result = CGF.EmitScalarExpr(e);
    return TryEmitResult(result, false);
  }
};
}

static TryEmitResult
tryEmitARCRetainScalarExpr(CodeGenFunction &CGF, const Expr *e) {
  return ARCRetainExprEmitter(CGF).visit(e);
}

static llvm::Value *emitARCRetainLoadOfScalar(CodeGenFunction &CGF,
                                                LValue lvalue,
                                                QualType type) {
  TryEmitResult result = tryEmitARCRetainLoadOfScalar(CGF, lvalue, type);
  llvm::Value *value = result.getPointer();
  if (!result.getInt())
    value = CGF.EmitARCRetain(type, value);
  return value;
}

/// EmitARCRetainScalarExpr - Semantically equivalent to
/// EmitARCRetainObject(e->getType(), EmitScalarExpr(e)), but making a
/// best-effort attempt to peephole expressions that naturally produce
/// retained objects.
llvm::Value *CodeGenFunction::EmitARCRetainScalarExpr(const Expr *e) {
  // The retain needs to happen within the full-expression.
  if (const ExprWithCleanups *cleanups = dyn_cast<ExprWithCleanups>(e)) {
    enterFullExpression(cleanups);
    RunCleanupsScope scope(*this);
    return EmitARCRetainScalarExpr(cleanups->getSubExpr());
  }

  TryEmitResult result = tryEmitARCRetainScalarExpr(*this, e);
  llvm::Value *value = result.getPointer();
  if (!result.getInt())
    value = EmitARCRetain(e->getType(), value);
  return value;
}

llvm::Value *
CodeGenFunction::EmitARCRetainAutoreleaseScalarExpr(const Expr *e) {
  // The retain needs to happen within the full-expression.
  if (const ExprWithCleanups *cleanups = dyn_cast<ExprWithCleanups>(e)) {
    enterFullExpression(cleanups);
    RunCleanupsScope scope(*this);
    return EmitARCRetainAutoreleaseScalarExpr(cleanups->getSubExpr());
  }

  TryEmitResult result = tryEmitARCRetainScalarExpr(*this, e);
  llvm::Value *value = result.getPointer();
  if (result.getInt())
    value = EmitARCAutorelease(value);
  else
    value = EmitARCRetainAutorelease(e->getType(), value);
  return value;
}

llvm::Value *CodeGenFunction::EmitARCExtendBlockObject(const Expr *e) {
  llvm::Value *result;
  bool doRetain;

  if (shouldEmitSeparateBlockRetain(e)) {
    result = EmitScalarExpr(e);
    doRetain = true;
  } else {
    TryEmitResult subresult = tryEmitARCRetainScalarExpr(*this, e);
    result = subresult.getPointer();
    doRetain = !subresult.getInt();
  }

  if (doRetain)
    result = EmitARCRetainBlock(result, /*mandatory*/ true);
  return EmitObjCConsumeObject(e->getType(), result);
}

llvm::Value *CodeGenFunction::EmitObjCThrowOperand(const Expr *expr) {
  // In ARC, retain and autorelease the expression.
  if (getLangOpts().ObjCAutoRefCount) {
    // Do so before running any cleanups for the full-expression.
    // EmitARCRetainAutoreleaseScalarExpr does this for us.
    return EmitARCRetainAutoreleaseScalarExpr(expr);
  }

  // Otherwise, use the normal scalar-expression emission.  The
  // exception machinery doesn't do anything special with the
  // exception like retaining it, so there's no safety associated with
  // only running cleanups after the throw has started, and when it
  // matters it tends to be substantially inferior code.
  return EmitScalarExpr(expr);
}

namespace {

/// An emitter for assigning into an __unsafe_unretained context.
struct ARCUnsafeUnretainedExprEmitter :
  public ARCExprEmitter<ARCUnsafeUnretainedExprEmitter, llvm::Value*> {

  ARCUnsafeUnretainedExprEmitter(CodeGenFunction &CGF) : ARCExprEmitter(CGF) {}

  llvm::Value *getValueOfResult(llvm::Value *value) {
    return value;
  }

  llvm::Value *emitBitCast(llvm::Value *value, llvm::Type *resultType) {
    return CGF.Builder.CreateBitCast(value, resultType);
  }

  llvm::Value *visitLValueToRValue(const Expr *e) {
    return CGF.EmitScalarExpr(e);
  }

  /// For consumptions, just emit the subexpression and perform the
  /// consumption like normal.
  llvm::Value *visitConsumeObject(const Expr *e) {
    llvm::Value *value = CGF.EmitScalarExpr(e);
    return CGF.EmitObjCConsumeObject(e->getType(), value);
  }

  /// No special logic for block extensions.  (This probably can't
  /// actually happen in this emitter, though.)
  llvm::Value *visitExtendBlockObject(const Expr *e) {
    return CGF.EmitARCExtendBlockObject(e);
  }

  /// For reclaims, perform an unsafeClaim if that's enabled.
  llvm::Value *visitReclaimReturnedObject(const Expr *e) {
    return CGF.EmitARCReclaimReturnedObject(e, /*unsafe*/ true);
  }

  /// When we have an undecorated call, just emit it without adding
  /// the unsafeClaim.
  llvm::Value *visitCall(const Expr *e) {
    return CGF.EmitScalarExpr(e);
  }

  /// Just do normal scalar emission in the default case.
  llvm::Value *visitExpr(const Expr *e) {
    return CGF.EmitScalarExpr(e);
  }
};
}

static llvm::Value *emitARCUnsafeUnretainedScalarExpr(CodeGenFunction &CGF,
                                                      const Expr *e) {
  return ARCUnsafeUnretainedExprEmitter(CGF).visit(e);
}

/// EmitARCUnsafeUnretainedScalarExpr - Semantically equivalent to
/// immediately releasing the resut of EmitARCRetainScalarExpr, but
/// avoiding any spurious retains, including by performing reclaims
/// with objc_unsafeClaimAutoreleasedReturnValue.
llvm::Value *CodeGenFunction::EmitARCUnsafeUnretainedScalarExpr(const Expr *e) {
  // Look through full-expressions.
  if (const ExprWithCleanups *cleanups = dyn_cast<ExprWithCleanups>(e)) {
    enterFullExpression(cleanups);
    RunCleanupsScope scope(*this);
    return emitARCUnsafeUnretainedScalarExpr(*this, cleanups->getSubExpr());
  }

  return emitARCUnsafeUnretainedScalarExpr(*this, e);
}

std::pair<LValue,llvm::Value*>
CodeGenFunction::EmitARCStoreUnsafeUnretained(const BinaryOperator *e,
                                              bool ignored) {
  // Evaluate the RHS first.  If we're ignoring the result, assume
  // that we can emit at an unsafe +0.
  llvm::Value *value;
  if (ignored) {
    value = EmitARCUnsafeUnretainedScalarExpr(e->getRHS());
  } else {
    value = EmitScalarExpr(e->getRHS());
  }

  // Emit the LHS and perform the store.
  LValue lvalue = EmitLValue(e->getLHS());
  EmitStoreOfScalar(value, lvalue);

  return std::pair<LValue,llvm::Value*>(std::move(lvalue), value);
}

std::pair<LValue,llvm::Value*>
CodeGenFunction::EmitARCStoreStrong(const BinaryOperator *e,
                                    bool ignored) {
  // Evaluate the RHS first.
  TryEmitResult result = tryEmitARCRetainScalarExpr(*this, e->getRHS());
  llvm::Value *value = result.getPointer();

  bool hasImmediateRetain = result.getInt();

  // If we didn't emit a retained object, and the l-value is of block
  // type, then we need to emit the block-retain immediately in case
  // it invalidates the l-value.
  if (!hasImmediateRetain && e->getType()->isBlockPointerType()) {
    value = EmitARCRetainBlock(value, /*mandatory*/ false);
    hasImmediateRetain = true;
  }

  LValue lvalue = EmitLValue(e->getLHS());

  // If the RHS was emitted retained, expand this.
  if (hasImmediateRetain) {
    llvm::Value *oldValue = EmitLoadOfScalar(lvalue, SourceLocation());
    EmitStoreOfScalar(value, lvalue);
    EmitARCRelease(oldValue, lvalue.isARCPreciseLifetime());
  } else {
    value = EmitARCStoreStrong(lvalue, value, ignored);
  }

  return std::pair<LValue,llvm::Value*>(lvalue, value);
}

std::pair<LValue,llvm::Value*>
CodeGenFunction::EmitARCStoreAutoreleasing(const BinaryOperator *e) {
  llvm::Value *value = EmitARCRetainAutoreleaseScalarExpr(e->getRHS());
  LValue lvalue = EmitLValue(e->getLHS());

  EmitStoreOfScalar(value, lvalue);

  return std::pair<LValue,llvm::Value*>(lvalue, value);
}

void CodeGenFunction::EmitObjCAutoreleasePoolStmt(
                                          const ObjCAutoreleasePoolStmt &ARPS) {
  const Stmt *subStmt = ARPS.getSubStmt();
  const CompoundStmt &S = cast<CompoundStmt>(*subStmt);

  CGDebugInfo *DI = getDebugInfo();
  if (DI)
    DI->EmitLexicalBlockStart(Builder, S.getLBracLoc());

  // Keep track of the current cleanup stack depth.
  RunCleanupsScope Scope(*this);
  if (CGM.getLangOpts().ObjCRuntime.hasNativeARC()) {
    llvm::Value *token = EmitObjCAutoreleasePoolPush();
    EHStack.pushCleanup<CallObjCAutoreleasePoolObject>(NormalCleanup, token);
  } else {
    llvm::Value *token = EmitObjCMRRAutoreleasePoolPush();
    EHStack.pushCleanup<CallObjCMRRAutoreleasePoolObject>(NormalCleanup, token);
  }

  for (const auto *I : S.body())
    EmitStmt(I);

  if (DI)
    DI->EmitLexicalBlockEnd(Builder, S.getRBracLoc());
}

/// EmitExtendGCLifetime - Given a pointer to an Objective-C object,
/// make sure it survives garbage collection until this point.
void CodeGenFunction::EmitExtendGCLifetime(llvm::Value *object) {
  // We just use an inline assembly.
  llvm::FunctionType *extenderType
    = llvm::FunctionType::get(VoidTy, VoidPtrTy, RequiredArgs::All);
  llvm::Value *extender
    = llvm::InlineAsm::get(extenderType,
                           /* assembly */ "",
                           /* constraints */ "r",
                           /* side effects */ true);

  object = Builder.CreateBitCast(object, VoidPtrTy);
  EmitNounwindRuntimeCall(extender, object);
}

/// GenerateObjCAtomicSetterCopyHelperFunction - Given a c++ object type with
/// non-trivial copy assignment function, produce following helper function.
/// static void copyHelper(Ty *dest, const Ty *source) { *dest = *source; }
///
llvm::Constant *
CodeGenFunction::GenerateObjCAtomicSetterCopyHelperFunction(
                                        const ObjCPropertyImplDecl *PID) {
  if (!getLangOpts().CPlusPlus ||
      !getLangOpts().ObjCRuntime.hasAtomicCopyHelper())
    return nullptr;
  QualType Ty = PID->getPropertyIvarDecl()->getType();
  if (!Ty->isRecordType())
    return nullptr;
  const ObjCPropertyDecl *PD = PID->getPropertyDecl();
  if ((!(PD->getPropertyAttributes() & ObjCPropertyDecl::OBJC_PR_atomic)))
    return nullptr;
  llvm::Constant *HelperFn = nullptr;
  if (hasTrivialSetExpr(PID))
    return nullptr;
  assert(PID->getSetterCXXAssignment() && "SetterCXXAssignment - null");
  if ((HelperFn = CGM.getAtomicSetterHelperFnMap(Ty)))
    return HelperFn;
  
  ASTContext &C = getContext();
  IdentifierInfo *II
    = &CGM.getContext().Idents.get("__assign_helper_atomic_property_");
  FunctionDecl *FD = FunctionDecl::Create(C,
                                          C.getTranslationUnitDecl(),
                                          SourceLocation(),
                                          SourceLocation(), II, C.VoidTy,
                                          nullptr, SC_Static,
                                          false,
                                          false);

  QualType DestTy = C.getPointerType(Ty);
  QualType SrcTy = Ty;
  SrcTy.addConst();
  SrcTy = C.getPointerType(SrcTy);
  
  FunctionArgList args;
  ImplicitParamDecl dstDecl(getContext(), FD, SourceLocation(), nullptr,DestTy);
  args.push_back(&dstDecl);
  ImplicitParamDecl srcDecl(getContext(), FD, SourceLocation(), nullptr, SrcTy);
  args.push_back(&srcDecl);

  const CGFunctionInfo &FI =
    CGM.getTypes().arrangeBuiltinFunctionDeclaration(C.VoidTy, args);

  llvm::FunctionType *LTy = CGM.getTypes().GetFunctionType(FI);
  
  llvm::Function *Fn =
    llvm::Function::Create(LTy, llvm::GlobalValue::InternalLinkage,
                           "__assign_helper_atomic_property_",
                           &CGM.getModule());

  CGM.SetInternalFunctionAttributes(nullptr, Fn, FI);

  StartFunction(FD, C.VoidTy, Fn, FI, args);
  
  DeclRefExpr DstExpr(&dstDecl, false, DestTy,
                      VK_RValue, SourceLocation());
  UnaryOperator DST(&DstExpr, UO_Deref, DestTy->getPointeeType(),
                    VK_LValue, OK_Ordinary, SourceLocation());
  
  DeclRefExpr SrcExpr(&srcDecl, false, SrcTy,
                      VK_RValue, SourceLocation());
  UnaryOperator SRC(&SrcExpr, UO_Deref, SrcTy->getPointeeType(),
                    VK_LValue, OK_Ordinary, SourceLocation());
  
  Expr *Args[2] = { &DST, &SRC };
  CallExpr *CalleeExp = cast<CallExpr>(PID->getSetterCXXAssignment());
  CXXOperatorCallExpr TheCall(C, OO_Equal, CalleeExp->getCallee(),
                              Args, DestTy->getPointeeType(),
                              VK_LValue, SourceLocation(), false);
  
  EmitStmt(&TheCall);

  FinishFunction();
  HelperFn = llvm::ConstantExpr::getBitCast(Fn, VoidPtrTy);
  CGM.setAtomicSetterHelperFnMap(Ty, HelperFn);
  return HelperFn;
}

llvm::Constant *
CodeGenFunction::GenerateObjCAtomicGetterCopyHelperFunction(
                                            const ObjCPropertyImplDecl *PID) {
  if (!getLangOpts().CPlusPlus ||
      !getLangOpts().ObjCRuntime.hasAtomicCopyHelper())
    return nullptr;
  const ObjCPropertyDecl *PD = PID->getPropertyDecl();
  QualType Ty = PD->getType();
  if (!Ty->isRecordType())
    return nullptr;
  if ((!(PD->getPropertyAttributes() & ObjCPropertyDecl::OBJC_PR_atomic)))
    return nullptr;
  llvm::Constant *HelperFn = nullptr;

  if (hasTrivialGetExpr(PID))
    return nullptr;
  assert(PID->getGetterCXXConstructor() && "getGetterCXXConstructor - null");
  if ((HelperFn = CGM.getAtomicGetterHelperFnMap(Ty)))
    return HelperFn;
  
  
  ASTContext &C = getContext();
  IdentifierInfo *II
  = &CGM.getContext().Idents.get("__copy_helper_atomic_property_");
  FunctionDecl *FD = FunctionDecl::Create(C,
                                          C.getTranslationUnitDecl(),
                                          SourceLocation(),
                                          SourceLocation(), II, C.VoidTy,
                                          nullptr, SC_Static,
                                          false,
                                          false);

  QualType DestTy = C.getPointerType(Ty);
  QualType SrcTy = Ty;
  SrcTy.addConst();
  SrcTy = C.getPointerType(SrcTy);
  
  FunctionArgList args;
  ImplicitParamDecl dstDecl(getContext(), FD, SourceLocation(), nullptr,DestTy);
  args.push_back(&dstDecl);
  ImplicitParamDecl srcDecl(getContext(), FD, SourceLocation(), nullptr, SrcTy);
  args.push_back(&srcDecl);

  const CGFunctionInfo &FI =
    CGM.getTypes().arrangeBuiltinFunctionDeclaration(C.VoidTy, args);

  llvm::FunctionType *LTy = CGM.getTypes().GetFunctionType(FI);
  
  llvm::Function *Fn =
  llvm::Function::Create(LTy, llvm::GlobalValue::InternalLinkage,
                         "__copy_helper_atomic_property_", &CGM.getModule());
  
  CGM.SetInternalFunctionAttributes(nullptr, Fn, FI);

  StartFunction(FD, C.VoidTy, Fn, FI, args);
  
  DeclRefExpr SrcExpr(&srcDecl, false, SrcTy,
                      VK_RValue, SourceLocation());
  
  UnaryOperator SRC(&SrcExpr, UO_Deref, SrcTy->getPointeeType(),
                    VK_LValue, OK_Ordinary, SourceLocation());
  
  CXXConstructExpr *CXXConstExpr = 
    cast<CXXConstructExpr>(PID->getGetterCXXConstructor());
  
  SmallVector<Expr*, 4> ConstructorArgs;
  ConstructorArgs.push_back(&SRC);
  ConstructorArgs.append(std::next(CXXConstExpr->arg_begin()),
                         CXXConstExpr->arg_end());

  CXXConstructExpr *TheCXXConstructExpr =
    CXXConstructExpr::Create(C, Ty, SourceLocation(),
                             CXXConstExpr->getConstructor(),
                             CXXConstExpr->isElidable(),
                             ConstructorArgs,
                             CXXConstExpr->hadMultipleCandidates(),
                             CXXConstExpr->isListInitialization(),
                             CXXConstExpr->isStdInitListInitialization(),
                             CXXConstExpr->requiresZeroInitialization(),
                             CXXConstExpr->getConstructionKind(),
                             SourceRange());
  
  DeclRefExpr DstExpr(&dstDecl, false, DestTy,
                      VK_RValue, SourceLocation());
  
  RValue DV = EmitAnyExpr(&DstExpr);
  CharUnits Alignment
    = getContext().getTypeAlignInChars(TheCXXConstructExpr->getType());
  EmitAggExpr(TheCXXConstructExpr, 
              AggValueSlot::forAddr(Address(DV.getScalarVal(), Alignment),
                                    Qualifiers(),
                                    AggValueSlot::IsDestructed,
                                    AggValueSlot::DoesNotNeedGCBarriers,
                                    AggValueSlot::IsNotAliased));
  
  FinishFunction();
  HelperFn = llvm::ConstantExpr::getBitCast(Fn, VoidPtrTy);
  CGM.setAtomicGetterHelperFnMap(Ty, HelperFn);
  return HelperFn;
}

llvm::Value *
CodeGenFunction::EmitBlockCopyAndAutorelease(llvm::Value *Block, QualType Ty) {
  // Get selectors for retain/autorelease.
  IdentifierInfo *CopyID = &getContext().Idents.get("copy");
  Selector CopySelector =
      getContext().Selectors.getNullarySelector(CopyID);
  IdentifierInfo *AutoreleaseID = &getContext().Idents.get("autorelease");
  Selector AutoreleaseSelector =
      getContext().Selectors.getNullarySelector(AutoreleaseID);

  // Emit calls to retain/autorelease.
  CGObjCRuntime &Runtime = CGM.getObjCRuntime();
  llvm::Value *Val = Block;
  RValue Result;
  Result = Runtime.GenerateMessageSend(*this, ReturnValueSlot(),
                                       Ty, CopySelector,
                                       Val, CallArgList(), nullptr, nullptr);
  Val = Result.getScalarVal();
  Result = Runtime.GenerateMessageSend(*this, ReturnValueSlot(),
                                       Ty, AutoreleaseSelector,
                                       Val, CallArgList(), nullptr, nullptr);
  Val = Result.getScalarVal();
  return Val;
}

llvm::Value *
CodeGenFunction::EmitBuiltinAvailable(ArrayRef<llvm::Value *> Args) {
  assert(Args.size() == 3 && "Expected 3 argument here!");

  if (!CGM.IsOSVersionAtLeastFn) {
    llvm::FunctionType *FTy =
        llvm::FunctionType::get(Int32Ty, {Int32Ty, Int32Ty, Int32Ty}, false);
    CGM.IsOSVersionAtLeastFn =
        CGM.CreateRuntimeFunction(FTy, "__isOSVersionAtLeast");
  }

  llvm::Value *CallRes =
      EmitNounwindRuntimeCall(CGM.IsOSVersionAtLeastFn, Args);

  return Builder.CreateICmpNE(CallRes, llvm::Constant::getNullValue(Int32Ty));
}

void CodeGenModule::emitAtAvailableLinkGuard() {
  if (!IsOSVersionAtLeastFn)
    return;
  // @available requires CoreFoundation only on Darwin.
  if (!Target.getTriple().isOSDarwin())
    return;
  // Add -framework CoreFoundation to the linker commands. We still want to
  // emit the core foundation reference down below because otherwise if
  // CoreFoundation is not used in the code, the linker won't link the
  // framework.
  auto &Context = getLLVMContext();
  llvm::Metadata *Args[2] = {llvm::MDString::get(Context, "-framework"),
                             llvm::MDString::get(Context, "CoreFoundation")};
  LinkerOptionsMetadata.push_back(llvm::MDNode::get(Context, Args));
  // Emit a reference to a symbol from CoreFoundation to ensure that
  // CoreFoundation is linked into the final binary.
  llvm::FunctionType *FTy =
      llvm::FunctionType::get(Int32Ty, {VoidPtrTy}, false);
  llvm::Constant *CFFunc =
      CreateRuntimeFunction(FTy, "CFBundleGetVersionNumber");

  llvm::FunctionType *CheckFTy = llvm::FunctionType::get(VoidTy, {}, false);
  llvm::Function *CFLinkCheckFunc = cast<llvm::Function>(CreateBuiltinFunction(
      CheckFTy, "__clang_at_available_requires_core_foundation_framework"));
  CFLinkCheckFunc->setLinkage(llvm::GlobalValue::LinkOnceAnyLinkage);
  CFLinkCheckFunc->setVisibility(llvm::GlobalValue::HiddenVisibility);
  CodeGenFunction CGF(*this);
  CGF.Builder.SetInsertPoint(CGF.createBasicBlock("", CFLinkCheckFunc));
  CGF.EmitNounwindRuntimeCall(CFFunc, llvm::Constant::getNullValue(VoidPtrTy));
  CGF.Builder.CreateUnreachable();
  addCompilerUsedGlobal(CFLinkCheckFunc);
}

CGObjCRuntime::~CGObjCRuntime() {}
