from __future__ import print_function
from __future__ import absolute_import

import lldb
from lldbsuite.test.lldbtest import *
import lldbsuite.test.lldbutil as lldbutil
import lldbsuite.test.test_categories as test_categories
# System modules
import os

# Third-party modules

# LLDB modules
import lldb
from .lldbtest import *
from . import configuration
from . import lldbutil
from .decorators import *


def source_type(filename):
    _, extension = os.path.splitext(filename)
    return {
        '.c': 'C_SOURCES',
        '.cpp': 'CXX_SOURCES',
        '.cxx': 'CXX_SOURCES',
        '.cc': 'CXX_SOURCES',
        '.m': 'OBJC_SOURCES',
        '.mm': 'OBJCXX_SOURCES',
        '.swift': 'SWIFT_SOURCES'
    }.get(extension, None)


class CommandParser:

    def __init__(self):
        self.breakpoints = []

    def parse_one_command(self, line):
        parts = line.split('//%')

        command = None
        new_breakpoint = True

        if len(parts) == 2:
            command = parts[1].strip()  # take off whitespace
            new_breakpoint = parts[0].strip() != ""

        return (command, new_breakpoint)

    def parse_source_files(self, source_files):
        for source_file in source_files:
            file_handle = open(source_file)
            lines = file_handle.readlines()
            line_number = 0
            # non-NULL means we're looking through whitespace to find
            # additional commands
            current_breakpoint = None
            for line in lines:
                line_number = line_number + 1  # 1-based, so we do this first
                (command, new_breakpoint) = self.parse_one_command(line)

                if new_breakpoint:
                    current_breakpoint = None

                if command is not None:
                    if current_breakpoint is None:
                        current_breakpoint = {}
                        current_breakpoint['file_name'] = source_file
                        current_breakpoint['line_number'] = line_number
                        current_breakpoint['command'] = command
                        self.breakpoints.append(current_breakpoint)
                    else:
                        current_breakpoint['command'] = current_breakpoint[
                            'command'] + "\n" + command

    def set_breakpoints(self, target):
        for breakpoint in self.breakpoints:
            breakpoint['breakpoint'] = target.BreakpointCreateByLocation(
                breakpoint['file_name'], breakpoint['line_number'])

    def handle_breakpoint(self, test, breakpoint_id):
        for breakpoint in self.breakpoints:
            if breakpoint['breakpoint'].GetID() == breakpoint_id:
                test.execute_user_command(breakpoint['command'])
                return


class InlineTest(TestBase):
    # Internal implementation

    def BuildMakefile(self):
        makefilePath = self.getBuildArtifact("Makefile")
        if os.path.exists(makefilePath):
            return

        categories = {}

        for f in os.listdir(self.getSourceDir()):
            t = source_type(f)
            if t:
                if t in list(categories.keys()):
                    categories[t].append(f)
                else:
                    categories[t] = [f]

        makefile = open(makefilePath, 'w+')

        level = os.sep.join(
            [".."] * len(self.mydir.split(os.sep))) + os.sep + "make"

        makefile.write("LEVEL = " + level + "\n")

        for t in list(categories.keys()):
            line = t + " := " + " ".join(categories[t])
            makefile.write(line + "\n")

        if ('OBJCXX_SOURCES' in list(categories.keys())) or (
                'OBJC_SOURCES' in list(categories.keys())):
            makefile.write(
                "LDFLAGS = $(CFLAGS) -lobjc -framework Foundation\n")

        if ('CXX_SOURCES' in list(categories.keys())):
            makefile.write("CXXFLAGS += -std=c++11\n")

        makefile.write("include $(LEVEL)/Makefile.rules\n")
        makefile.write("\ncleanup:\n\trm -f Makefile *.d\n\n")
        makefile.flush()
        makefile.close()

    def _test(self):
        self.BuildMakefile()
        self.build()
        self.do_test()

    def execute_user_command(self, __command):
        exec(__command, globals(), locals())

    def do_test(self):
        exe = self.getBuildArtifact("a.out")
        source_files = [f for f in os.listdir(self.getSourceDir())
                        if source_type(f)]
        target = self.dbg.CreateTarget(exe)

        parser = CommandParser()
        parser.parse_source_files(source_files)
        parser.set_breakpoints(target)

        process = target.LaunchSimple(None, None, self.get_process_working_directory())
        hit_breakpoints = 0

        while lldbutil.get_stopped_thread(process, lldb.eStopReasonBreakpoint):
            hit_breakpoints += 1
            thread = lldbutil.get_stopped_thread(
                process, lldb.eStopReasonBreakpoint)
            breakpoint_id = thread.GetStopReasonDataAtIndex(0)
            parser.handle_breakpoint(self, breakpoint_id)
            process.Continue()

        self.assertTrue(hit_breakpoints > 0,
                        "inline test did not hit a single breakpoint")
        # Either the process exited or the stepping plan is complete.
        self.assertTrue(process.GetState() in [lldb.eStateStopped,
                                               lldb.eStateExited],
                        PROCESS_EXITED)

    # Utilities for testcases

    def check_expression(self, expression, expected_result, use_summary=True):
        value = self.frame().EvaluateExpression(expression)
        self.assertTrue(value.IsValid(), expression + "returned a valid value")
        if self.TraceOn():
            print(value.GetSummary())
            print(value.GetValue())
        if use_summary:
            answer = value.GetSummary()
        else:
            answer = value.GetValue()
        report_str = "%s expected: %s got: %s" % (
            expression, expected_result, answer)
        self.assertTrue(answer == expected_result, report_str)


def ApplyDecoratorsToFunction(func, decorators):
    tmp = func
    if isinstance(decorators, list):
        for decorator in decorators:
            tmp = decorator(tmp)
    elif hasattr(decorators, '__call__'):
        tmp = decorators(tmp)
    return tmp

def MakeInlineTest(__file, __globals, decorators=None):
    # Adjust the filename if it ends in .pyc.  We want filenames to
    # reflect the source python file, not the compiled variant.
    if __file is not None and __file.endswith(".pyc"):
        # Strip the trailing "c"
        __file = __file[0:-1]

    # Derive the test name from the current file name
    file_basename = os.path.basename(__file)

    test_name, _ = os.path.splitext(file_basename)

    test_func = ApplyDecoratorsToFunction(InlineTest._test, decorators)
    # Build the test case
    test_class = type(test_name, (InlineTest,), dict(test=test_func, name=test_name))

    # Add the test case to the globals, and hide InlineTest
    __globals.update({test_name: test_class})

    # Keep track of the original test filename so we report it
    # correctly in test results.
    test_class.test_filename = __file
    test_class.mydir = TestBase.compute_mydir(__file)
    return test_class
