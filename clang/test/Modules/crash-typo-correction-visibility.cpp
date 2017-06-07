// RUN: %clang_cc1 -x c++ -std=c++11 -fmodules -fmodule-name=module -o %T/module.pcm -emit-module %S/Inputs/crash-typo-correction-visibility/module.modulemap
// RUN: %clang_cc1 -x c++ -std=c++11 -fmodules -fmodule-file=%T/module.pcm %s -verify

struct S {
  int member; // expected-note {{declared here}}
};

int f(...);

int b = sizeof(f(member)); // expected-error {{undeclared identifier 'member'}}
