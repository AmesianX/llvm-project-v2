// RUN: %clang_cc1 -triple x86_64-unknown-unknown -ast-dump=json -ast-dump-filter Test %s | FileCheck %s

struct S {
  void Test1();
  void Test2() const;
  void Test3() volatile;
  void Test4() &;
  void Test5() &&;
  virtual void Test6(float, int = 12);
  virtual void Test7() = 0;
};

struct T : S { // T is not referenced, but S is
  void Test6(float, int = 100) override;
};

struct U {
  void Test1();
};
void U::Test1() {} // parent

void Test1();
void Test2(void);
void Test3(int a, int b);
void Test4(int a, int b = 12);
constexpr void Test5(void);
static void Test6(void);
extern void Test7(void);
inline void Test8(void);
void Test9(void) noexcept;
void Test10(void) noexcept(false);
void Test11(void) noexcept(1);

template <typename T>
T Test12(T&);

void Test13(int) {}
void Test14(int, ...) {}

int main() {
  Test1(); // Causes this to be marked 'used'
}


// CHECK:  "kind": "CXXMethodDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 8,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 4
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 3,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 4
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 14,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 4
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test1",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void ()"
// CHECK-NEXT:  }
// CHECK-NEXT: }


// CHECK:  "kind": "CXXMethodDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 8,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 5
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 3,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 5
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 16,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 5
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test2",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void () const"
// CHECK-NEXT:  }
// CHECK-NEXT: }


// CHECK:  "kind": "CXXMethodDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 8,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 6
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 3,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 6
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 16,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 6
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test3",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void () volatile"
// CHECK-NEXT:  }
// CHECK-NEXT: }


// CHECK:  "kind": "CXXMethodDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 8,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 7
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 3,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 7
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 16,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 7
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test4",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void () &"
// CHECK-NEXT:  }
// CHECK-NEXT: }


// CHECK:  "kind": "CXXMethodDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 8,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 8
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 3,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 8
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 16,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 8
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test5",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void () &&"
// CHECK-NEXT:  }
// CHECK-NEXT: }


// CHECK:  "kind": "CXXMethodDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 16,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 9
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 3,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 9
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 37,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 9
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test6",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void (float, int)"
// CHECK-NEXT:  },
// CHECK-NEXT:  "virtual": true,
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "ParmVarDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 27,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 9
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 22,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 9
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 22,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 9
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "float"
// CHECK-NEXT:    }
// CHECK-NEXT:   },
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "ParmVarDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 33,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 9
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 29,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 9
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 35,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 9
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "int"
// CHECK-NEXT:    },
// CHECK-NEXT:    "init": "c",
// CHECK-NEXT:    "inner": [
// CHECK-NEXT:     {
// CHECK-NEXT:      "id": "0x{{.*}}",
// CHECK-NEXT:      "kind": "IntegerLiteral",
// CHECK-NEXT:      "range": {
// CHECK-NEXT:       "begin": {
// CHECK-NEXT:        "col": 35,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 9
// CHECK-NEXT:       },
// CHECK-NEXT:       "end": {
// CHECK-NEXT:        "col": 35,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 9
// CHECK-NEXT:       }
// CHECK-NEXT:      },
// CHECK-NEXT:      "type": {
// CHECK-NEXT:       "qualType": "int"
// CHECK-NEXT:      },
// CHECK-NEXT:      "valueCategory": "rvalue",
// CHECK-NEXT:      "value": "12"
// CHECK-NEXT:     }
// CHECK-NEXT:    ]
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "CXXMethodDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 16,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 10
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 3,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 10
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 26,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 10
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test7",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void ()"
// CHECK-NEXT:  },
// CHECK-NEXT:  "virtual": true,
// CHECK-NEXT:  "pure": true
// CHECK-NEXT: }


// CHECK:  "kind": "CXXMethodDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 8,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 14
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 3,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 14
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 32,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 14
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test6",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void (float, int)"
// CHECK-NEXT:  },
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "ParmVarDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 19,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 14
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 14,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 14
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 14,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 14
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "float"
// CHECK-NEXT:    }
// CHECK-NEXT:   },
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "ParmVarDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 25,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 14
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 21,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 14
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 27,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 14
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "int"
// CHECK-NEXT:    },
// CHECK-NEXT:    "init": "c",
// CHECK-NEXT:    "inner": [
// CHECK-NEXT:     {
// CHECK-NEXT:      "id": "0x{{.*}}",
// CHECK-NEXT:      "kind": "IntegerLiteral",
// CHECK-NEXT:      "range": {
// CHECK-NEXT:       "begin": {
// CHECK-NEXT:        "col": 27,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 14
// CHECK-NEXT:       },
// CHECK-NEXT:       "end": {
// CHECK-NEXT:        "col": 27,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 14
// CHECK-NEXT:       }
// CHECK-NEXT:      },
// CHECK-NEXT:      "type": {
// CHECK-NEXT:       "qualType": "int"
// CHECK-NEXT:      },
// CHECK-NEXT:      "valueCategory": "rvalue",
// CHECK-NEXT:      "value": "100"
// CHECK-NEXT:     }
// CHECK-NEXT:    ]
// CHECK-NEXT:   },
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "OverrideAttr",
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 32,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 14
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 32,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 14
// CHECK-NEXT:     }
// CHECK-NEXT:    }
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "CXXMethodDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 8,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 18
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 3,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 18
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 14,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 18
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test1",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void ()"
// CHECK-NEXT:  }
// CHECK-NEXT: }


// CHECK:  "kind": "CXXMethodDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 9,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 20
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 20
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 18,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 20
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "parentDeclContext": "0x{{.*}}",
// CHECK-NEXT:  "previousDecl": "0x{{.*}}",
// CHECK-NEXT:  "name": "Test1",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void ()"
// CHECK-NEXT:  },
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "CompoundStmt",
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 17,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 20
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 18,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 20
// CHECK-NEXT:     }
// CHECK-NEXT:    }
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "FunctionDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 6,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 22
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 22
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 12,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 22
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "isUsed": true,
// CHECK-NEXT:  "name": "Test1",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void ()"
// CHECK-NEXT:  }
// CHECK-NEXT: }


// CHECK:  "kind": "FunctionDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 6,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 23
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 23
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 16,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 23
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test2",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void ()"
// CHECK-NEXT:  }
// CHECK-NEXT: }


// CHECK:  "kind": "FunctionDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 6,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 24
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 24
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 24,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 24
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test3",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void (int, int)"
// CHECK-NEXT:  },
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "ParmVarDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 16,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 24
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 12,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 24
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 16,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 24
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "name": "a",
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "int"
// CHECK-NEXT:    }
// CHECK-NEXT:   },
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "ParmVarDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 23,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 24
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 19,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 24
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 23,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 24
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "name": "b",
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "int"
// CHECK-NEXT:    }
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "FunctionDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 6,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 25
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 25
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 29,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 25
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test4",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void (int, int)"
// CHECK-NEXT:  },
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "ParmVarDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 16,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 25
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 12,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 25
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 16,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 25
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "name": "a",
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "int"
// CHECK-NEXT:    }
// CHECK-NEXT:   },
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "ParmVarDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 23,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 25
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 19,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 25
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 27,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 25
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "name": "b",
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "int"
// CHECK-NEXT:    },
// CHECK-NEXT:    "init": "c",
// CHECK-NEXT:    "inner": [
// CHECK-NEXT:     {
// CHECK-NEXT:      "id": "0x{{.*}}",
// CHECK-NEXT:      "kind": "IntegerLiteral",
// CHECK-NEXT:      "range": {
// CHECK-NEXT:       "begin": {
// CHECK-NEXT:        "col": 27,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 25
// CHECK-NEXT:       },
// CHECK-NEXT:       "end": {
// CHECK-NEXT:        "col": 27,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 25
// CHECK-NEXT:       }
// CHECK-NEXT:      },
// CHECK-NEXT:      "type": {
// CHECK-NEXT:       "qualType": "int"
// CHECK-NEXT:      },
// CHECK-NEXT:      "valueCategory": "rvalue",
// CHECK-NEXT:      "value": "12"
// CHECK-NEXT:     }
// CHECK-NEXT:    ]
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "FunctionDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 16,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 26
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 26
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 26,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 26
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test5",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void ()"
// CHECK-NEXT:  },
// CHECK-NEXT:  "constexpr": true
// CHECK-NEXT: }


// CHECK:  "kind": "FunctionDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 13,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 27
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 27
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 23,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 27
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test6",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void ()"
// CHECK-NEXT:  },
// CHECK-NEXT:  "storageClass": "static"
// CHECK-NEXT: }


// CHECK:  "kind": "FunctionDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 13,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 28
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 28
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 23,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 28
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test7",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void ()"
// CHECK-NEXT:  },
// CHECK-NEXT:  "storageClass": "extern"
// CHECK-NEXT: }


// CHECK:  "kind": "FunctionDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 13,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 29
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 29
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 23,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 29
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test8",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void ()"
// CHECK-NEXT:  },
// CHECK-NEXT:  "inline": true
// CHECK-NEXT: }


// CHECK:  "kind": "FunctionDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 6,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 30
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 30
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 18,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 30
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test9",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void () noexcept"
// CHECK-NEXT:  }
// CHECK-NEXT: }


// CHECK:  "kind": "FunctionDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 6,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 31
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 31
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 33,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 31
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test10",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void () noexcept(false)"
// CHECK-NEXT:  }
// CHECK-NEXT: }


// CHECK:  "kind": "FunctionDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 6,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 32
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 32
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 29,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 32
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test11",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void () noexcept(1)"
// CHECK-NEXT:  }
// CHECK-NEXT: }


// CHECK:  "kind": "FunctionTemplateDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 3,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 35
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 34
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 12,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 35
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test12",
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "TemplateTypeParmDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 20,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 34
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 11,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 34
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 20,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 34
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "isReferenced": true,
// CHECK-NEXT:    "name": "T",
// CHECK-NEXT:    "tagUsed": "typename",
// CHECK-NEXT:    "depth": 0,
// CHECK-NEXT:    "index": 0
// CHECK-NEXT:   },
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "FunctionDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 3,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 35
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 1,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 35
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 12,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 35
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "name": "Test12",
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "T (T &)"
// CHECK-NEXT:    },
// CHECK-NEXT:    "inner": [
// CHECK-NEXT:     {
// CHECK-NEXT:      "id": "0x{{.*}}",
// CHECK-NEXT:      "kind": "ParmVarDecl",
// CHECK-NEXT:      "loc": {
// CHECK-NEXT:       "col": 12,
// CHECK-NEXT:       "file": "{{.*}}",
// CHECK-NEXT:       "line": 35
// CHECK-NEXT:      },
// CHECK-NEXT:      "range": {
// CHECK-NEXT:       "begin": {
// CHECK-NEXT:        "col": 10,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 35
// CHECK-NEXT:       },
// CHECK-NEXT:       "end": {
// CHECK-NEXT:        "col": 11,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 35
// CHECK-NEXT:       }
// CHECK-NEXT:      },
// CHECK-NEXT:      "type": {
// CHECK-NEXT:       "qualType": "T &"
// CHECK-NEXT:      }
// CHECK-NEXT:     }
// CHECK-NEXT:    ]
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "FunctionDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 6,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 37
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 37
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 19,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 37
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test13",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void (int)"
// CHECK-NEXT:  },
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "ParmVarDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 16,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 37
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 13,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 37
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 13,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 37
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "int"
// CHECK-NEXT:    }
// CHECK-NEXT:   },
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "CompoundStmt",
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 18,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 37
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 19,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 37
// CHECK-NEXT:     }
// CHECK-NEXT:    }
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "FunctionDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 6,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 38
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 38
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 24,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 38
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "Test14",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void (int, ...)"
// CHECK-NEXT:  },
// CHECK-NEXT:  "variadic": true,
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "ParmVarDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 16,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 38
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 13,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 38
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 13,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 38
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "int"
// CHECK-NEXT:    }
// CHECK-NEXT:   },
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "CompoundStmt",
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 23,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 38
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 24,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 38
// CHECK-NEXT:     }
// CHECK-NEXT:    }
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }

