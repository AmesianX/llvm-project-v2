//===-- StackFrameRecognizer.h ----------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef liblldb_StackFrameRecognizer_h_
#define liblldb_StackFrameRecognizer_h_

#include "lldb/Core/ValueObject.h"
#include "lldb/Core/ValueObjectList.h"
#include "lldb/Symbol/VariableList.h"
#include "lldb/Utility/StructuredData.h"
#include "lldb/lldb-private-forward.h"
#include "lldb/lldb-public.h"

namespace lldb_private {

/// \class RecognizedStackFrame
///
/// This class provides extra information about a stack frame that was
/// provided by a specific stack frame recognizer. Right now, this class only
/// holds recognized arguments (via GetRecognizedArguments).

class RecognizedStackFrame
    : public std::enable_shared_from_this<RecognizedStackFrame> {
public:
  virtual lldb::ValueObjectListSP GetRecognizedArguments() {
    return m_arguments;
  }
  virtual lldb::ValueObjectSP GetExceptionObject() {
    return lldb::ValueObjectSP();
  }
  virtual ~RecognizedStackFrame(){};

protected:
  lldb::ValueObjectListSP m_arguments;
};

/// \class StackFrameRecognizer
///
/// A base class for frame recognizers. Subclasses (actual frame recognizers)
/// should implement RecognizeFrame to provide a RecognizedStackFrame for a
/// given stack frame.

class StackFrameRecognizer
    : public std::enable_shared_from_this<StackFrameRecognizer> {
public:
  virtual lldb::RecognizedStackFrameSP RecognizeFrame(
      lldb::StackFrameSP frame) {
    return lldb::RecognizedStackFrameSP();
  };
  virtual std::string GetName() {
    return "";
  }

  virtual ~StackFrameRecognizer(){};
};

/// \class ScriptedStackFrameRecognizer
///
/// Python implementation for frame recognizers. An instance of this class
/// tracks a particular Python classobject, which will be asked to recognize
/// stack frames.

class ScriptedStackFrameRecognizer : public StackFrameRecognizer {
  lldb_private::ScriptInterpreter *m_interpreter;
  lldb_private::StructuredData::ObjectSP m_python_object_sp;
  std::string m_python_class;

public:
  ScriptedStackFrameRecognizer(lldb_private::ScriptInterpreter *interpreter,
                               const char *pclass);
  ~ScriptedStackFrameRecognizer() {}

  std::string GetName() override {
    return GetPythonClassName();
  }

  const char *GetPythonClassName() { return m_python_class.c_str(); }

  lldb::RecognizedStackFrameSP RecognizeFrame(
      lldb::StackFrameSP frame) override;

private:
  DISALLOW_COPY_AND_ASSIGN(ScriptedStackFrameRecognizer);
};

/// \class StackFrameRecognizerManager
///
/// Static class that provides a registry of known stack frame recognizers.
/// Has static methods to add, enumerate, remove, query and invoke recognizers.

class StackFrameRecognizerManager {
public:
  static void AddRecognizer(lldb::StackFrameRecognizerSP recognizer,
                            ConstString module,
                            ConstString symbol,
                            bool first_instruction_only = true);

  static void AddRecognizer(lldb::StackFrameRecognizerSP recognizer,
                            lldb::RegularExpressionSP module,
                            lldb::RegularExpressionSP symbol,
                            bool first_instruction_only = true);

  static void ForEach(
      std::function<void(uint32_t recognizer_id, std::string recognizer_name,
                         std::string module, std::string symbol,
                         bool regexp)> const &callback);

  static bool RemoveRecognizerWithID(uint32_t recognizer_id);

  static void RemoveAllRecognizers();

  static lldb::StackFrameRecognizerSP GetRecognizerForFrame(
      lldb::StackFrameSP frame);

  static lldb::RecognizedStackFrameSP RecognizeFrame(lldb::StackFrameSP frame);
};

/// \class ValueObjectRecognizerSynthesizedValue
///
/// ValueObject subclass that presents the passed ValueObject as a recognized
/// value with the specified ValueType. Frame recognizers should return
/// instances of this class as the returned objects in GetRecognizedArguments().

class ValueObjectRecognizerSynthesizedValue : public ValueObject {
 public:
  static lldb::ValueObjectSP Create(ValueObject &parent, lldb::ValueType type) {
    return (new ValueObjectRecognizerSynthesizedValue(parent, type))->GetSP();
  }
  ValueObjectRecognizerSynthesizedValue(ValueObject &parent,
                                        lldb::ValueType type)
      : ValueObject(parent), m_type(type) {
    SetName(parent.GetName());
  }

  uint64_t GetByteSize() override { return m_parent->GetByteSize(); }
  lldb::ValueType GetValueType() const override { return m_type; }
  bool UpdateValue() override {
    if (!m_parent->UpdateValueIfNeeded()) return false;
    m_value = m_parent->GetValue();
    return true;
  }
  size_t CalculateNumChildren(uint32_t max = UINT32_MAX) override {
    return m_parent->GetNumChildren(max);
  }
  CompilerType GetCompilerTypeImpl() override {
    return m_parent->GetCompilerType();
  }
  bool IsSynthetic() override { return true; }

 private:
  lldb::ValueType m_type;
};

} // namespace lldb_private

#endif // liblldb_StackFrameRecognizer_h_
