//===-- SWIG Interface for SBStructuredData ---------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

namespace lldb {

    %feature("docstring",
             "A class representing a StructuredData event.

              This class wraps the event type generated by StructuredData
              features."
             ) SBStructuredData;
    class SBStructuredData
    {
    public:
        
        SBStructuredData();
        
        SBStructuredData(const lldb::SBStructuredData &rhs);

        SBStructuredData(const lldb::EventSP &event_sp);

        ~SBStructuredData();
                 
        bool
        IsValid() const;
                 
        void
        Clear();

        lldb::SBError
        GetAsJSON(lldb::SBStream &stream) const;

        lldb::SBError
        GetDescription(lldb::SBStream &stream) const;

        lldb::SBError
        SetFromJSON(lldb::SBStream &stream);
    };
}
