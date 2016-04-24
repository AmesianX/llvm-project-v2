// RUN: %clang -S -emit-llvm -target x86_64-unknown_unknown -g %s -o - -std=c++11 | FileCheck %s

// CHECK: !DICompileUnit(
// CHECK: [[EMPTY:![0-9]*]] = !{}

struct foo {
  char pad[8]; // make the member pointer to 'e' a bit more interesting (nonzero)
  int e;
  void f();
  static void g();
};

typedef int foo::*foo_mem;

template<typename T, T, const int *x, foo_mem a, void (foo::*b)(), void (*f)(), int ...Is>
struct TC {
  struct nested {
  };
};

// CHECK: [[INT:![0-9]+]] = !DIBasicType(name: "int"
int glb;
void func();

// CHECK: !DIGlobalVariable(name: "tci",
// CHECK-SAME:              type: ![[TCNESTED:[0-9]+]]
// CHECK-SAME:              variable: %"struct.TC<unsigned int, 2, &glb, &foo::e, &foo::f, &foo::g, 1, 2, 3>::nested"* @tci
// CHECK: ![[TCNESTED]] ={{.*}}!DICompositeType(tag: DW_TAG_structure_type, name: "nested",
// CHECK-SAME:             scope: ![[TC:[0-9]+]],

// CHECK: ![[TC]] = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "TC<unsigned int, 2, &glb, &foo::e, &foo::f, &foo::g, 1, 2, 3>"
// CHECK-SAME:                              templateParams: [[TCARGS:![0-9]*]]
TC
// CHECK: [[TCARGS]] = !{[[TCARG1:![0-9]*]], [[TCARG2:![0-9]*]], [[TCARG3:![0-9]*]], [[TCARG4:![0-9]*]], [[TCARG5:![0-9]*]], [[TCARG6:![0-9]*]], [[TCARG7:![0-9]*]]}
// CHECK: [[TCARG1]] = !DITemplateTypeParameter(name: "T", type: [[UINT:![0-9]*]])
// CHECK: [[UINT:![0-9]*]] = !DIBasicType(name: "unsigned int"
< unsigned,
// CHECK: [[TCARG2]] = !DITemplateValueParameter(type: [[UINT]], value: i32 2)
  2,
// CHECK: [[TCARG3]] = !DITemplateValueParameter(name: "x", type: [[CINTPTR:![0-9]*]], value: i32* @glb)
// CHECK: [[CINTPTR]] = !DIDerivedType(tag: DW_TAG_pointer_type, {{.*}}baseType: [[CINT:![0-9]+]]
// CHECK: [[CINT]] = !DIDerivedType(tag: DW_TAG_const_type, {{.*}}baseType: [[INT]]
  &glb,
// CHECK: [[TCARG4]] = !DITemplateValueParameter(name: "a", type: [[MEMINTPTR:![0-9]*]], value: i64 8)
// CHECK: [[MEMINTPTR]] = !DIDerivedType(tag: DW_TAG_ptr_to_member_type, {{.*}}baseType: [[INT]], {{.*}}extraData: ![[FOO:[0-9]+]])
//
// We could just emit a declaration of 'foo' here, rather than the entire
// definition (same goes for any time we emit a member (function or data)
// pointer type)
// CHECK: [[FOO]] = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "foo", {{.*}}identifier: "_ZTS3foo")
// CHECK: !DISubprogram(name: "f", linkageName: "_ZN3foo1fEv", {{.*}}type: [[FTYPE:![0-9]*]]
//
// Currently Clang emits the pointer-to-member-function value, but LLVM doesn't
// use it (GCC doesn't emit a value for pointers to member functions either - so
// it's not clear what, if any, format would be acceptable to GDB)
//
// CHECK: [[FTYPE:![0-9]*]] = !DISubroutineType(types: [[FARGS:![0-9]*]])
// CHECK: [[FARGS]] = !{null, [[FARG1:![0-9]*]]}
// CHECK: [[FARG1]] = !DIDerivedType(tag: DW_TAG_pointer_type,
// CHECK-SAME:                       baseType: ![[FOO]]
// CHECK-NOT:                        line:
// CHECK-SAME:                       size: 64, align: 64
// CHECK-NOT:                        offset: 0
// CHECK-SAME:                       DIFlagArtificial
// CHECK: [[FUNTYPE:![0-9]*]] = !DISubroutineType(types: [[FUNARGS:![0-9]*]])
// CHECK: [[FUNARGS]] = !{null}
  &foo::e,
// CHECK: [[TCARG5]] = !DITemplateValueParameter(name: "b", type: [[MEMFUNPTR:![0-9]*]], value: { i64, i64 } { i64 ptrtoint (void (%struct.foo*)* @_ZN3foo1fEv to i64), i64 0 })
// CHECK: [[MEMFUNPTR]] = !DIDerivedType(tag: DW_TAG_ptr_to_member_type, {{.*}}baseType: [[FTYPE]], {{.*}}extraData: ![[FOO]])
  &foo::f,
// CHECK: [[TCARG6]] = !DITemplateValueParameter(name: "f", type: [[FUNPTR:![0-9]*]], value: void ()* @_ZN3foo1gEv)
// CHECK: [[FUNPTR]] = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: [[FUNTYPE]]
  &foo::g,
// CHECK: [[TCARG7]] = !DITemplateValueParameter(tag: DW_TAG_GNU_template_parameter_pack, name: "Is", value: [[TCARG7_VALS:![0-9]*]])
// CHECK: [[TCARG7_VALS]] = !{[[TCARG7_1:![0-9]*]], [[TCARG7_2:![0-9]*]], [[TCARG7_3:![0-9]*]]}
// CHECK: [[TCARG7_1]] = !DITemplateValueParameter(type: [[INT]], value: i32 1)
  1,
// CHECK: [[TCARG7_2]] = !DITemplateValueParameter(type: [[INT]], value: i32 2)
  2,
// CHECK: [[TCARG7_3]] = !DITemplateValueParameter(type: [[INT]], value: i32 3)
  3>::nested tci;

// CHECK: !DIGlobalVariable(name: "tcn"
// CHECK-SAME:              type: ![[TCNT:[0-9]+]]
// CHECK-SAME:              variable: %struct.TC* @tcn
TC
// CHECK: ![[TCNT]] ={{.*}}!DICompositeType(tag: DW_TAG_structure_type, name: "TC<int, -3, nullptr, nullptr, nullptr, nullptr>"
// CHECK-SAME:             templateParams: [[TCNARGS:![0-9]*]]
// CHECK: [[TCNARGS]] = !{[[TCNARG1:![0-9]*]], [[TCNARG2:![0-9]*]], [[TCNARG3:![0-9]*]], [[TCNARG4:![0-9]*]], [[TCNARG5:![0-9]*]], [[TCNARG6:![0-9]*]], [[TCNARG7:![0-9]*]]}
// CHECK: [[TCNARG1]] = !DITemplateTypeParameter(name: "T", type: [[INT]])
<int,
// CHECK: [[TCNARG2]] = !DITemplateValueParameter(type: [[INT]], value: i32 -3)
  -3,
// CHECK: [[TCNARG3]] = !DITemplateValueParameter(name: "x", type: [[CINTPTR]], value: i8 0)
  nullptr,

// The interesting null pointer: -1 for member data pointers (since they are
// just an offset in an object, they can be zero and non-null for the first
// member)

// CHECK: [[TCNARG4]] = !DITemplateValueParameter(name: "a", type: [[MEMINTPTR]], value: i64 -1)
  nullptr,
//
// In some future iteration we could possibly emit the value of a null member
// function pointer as '{ i64, i64 } zeroinitializer' as it may be handled
// naturally from the LLVM CodeGen side once we decide how to handle non-null
// member function pointers. For now, it's simpler just to emit the 'i8 0'.
//
// CHECK: [[TCNARG5]] = !DITemplateValueParameter(name: "b", type: [[MEMFUNPTR]], value: i8 0)
  nullptr,
// CHECK: [[TCNARG6]] = !DITemplateValueParameter(name: "f", type: [[FUNPTR]], value: i8 0)
  nullptr
// CHECK: [[TCNARG7]] = !DITemplateValueParameter(tag: DW_TAG_GNU_template_parameter_pack, name: "Is", value: [[EMPTY]])
  > tcn;

template<typename>
struct tmpl_impl {
};

template <template <typename> class tmpl, int &lvr, int &&rvr>
struct NN {
};

// CHECK: !DIGlobalVariable(name: "nn"
// CHECK-SAME:              type: ![[NNT:[0-9]+]]
// CHECK-SAME:              variable: %struct.NN* @nn

// FIXME: these parameters should probably be rendered as 'glb' rather than
// '&glb', since they're references, not pointers.
// CHECK: ![[NNT]] ={{.*}}!DICompositeType(tag: DW_TAG_structure_type, name: "NN<tmpl_impl, &glb, &glb>",
// CHECK-SAME:             templateParams: [[NNARGS:![0-9]*]]
// CHECK-SAME:             identifier:
// CHECK: [[NNARGS]] = !{[[NNARG1:![0-9]*]], [[NNARG2:![0-9]*]], [[NNARG3:![0-9]*]]}
// CHECK: [[NNARG1]] = !DITemplateValueParameter(tag: DW_TAG_GNU_template_template_param, name: "tmpl", value: !"tmpl_impl")
// CHECK: [[NNARG2]] = !DITemplateValueParameter(name: "lvr", type: [[INTLVR:![0-9]*]], value: i32* @glb)
// CHECK: [[INTLVR]] = !DIDerivedType(tag: DW_TAG_reference_type, baseType: [[INT]]
// CHECK: [[NNARG3]] = !DITemplateValueParameter(name: "rvr", type: [[INTRVR:![0-9]*]], value: i32* @glb)
// CHECK: [[INTRVR]] = !DIDerivedType(tag: DW_TAG_rvalue_reference_type, baseType: [[INT]]
NN<tmpl_impl, glb, glb> nn;

// CHECK: ![[PADDINGATEND:[0-9]+]] = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "PaddingAtEnd",
struct PaddingAtEnd {
  int i;
  char c;
};

PaddingAtEnd PaddedObj = {};

// CHECK: !DICompositeType(tag: DW_TAG_structure_type, name: "PaddingAtEndTemplate<&PaddedObj>"
// CHECK-SAME:             templateParams: [[PTOARGS:![0-9]*]]
// CHECK: [[PTOARGS]] = !{[[PTOARG1:![0-9]*]]}
// CHECK: [[PTOARG1]] = !DITemplateValueParameter(type: [[CONST_PADDINGATEND_PTR:![0-9]*]], value: %struct.PaddingAtEnd* @PaddedObj)
// CHECK: [[CONST_PADDINGATEND_PTR]] = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: ![[PADDINGATEND]], size: 64, align: 64)
template <PaddingAtEnd *>
struct PaddingAtEndTemplate {
};

PaddingAtEndTemplate<&PaddedObj> PaddedTemplateObj;
