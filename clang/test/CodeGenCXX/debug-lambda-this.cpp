// RUN: %clang_cc1 -triple x86_64-apple-darwin10.0.0 -emit-llvm -o - %s -fexceptions -std=c++11 -debug-info-kind=limited | FileCheck %s

struct D {
  D();
  D(const D&);
  int x;
  int d(int x);
};
int D::d(int x) {
  [=] {
    return this->x;
  }();
}

// CHECK: ![[POINTER:.*]] = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !"_ZTS1D", size: 64, align: 64)
// CHECK: !DIDerivedType(tag: DW_TAG_member, name: "this",
// CHECK-SAME:           line: 11
// CHECK-SAME:           baseType: ![[POINTER]]
// CHECK-SAME:           size: 64, align: 64
// CHECK-NOT:            offset: 0
// CHECK-SAME:           ){{$}}
