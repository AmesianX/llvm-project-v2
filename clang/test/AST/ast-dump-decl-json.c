// RUN: %clang_cc1 -triple x86_64-unknown-unknown -ast-dump=json -ast-dump-filter Test %s | FileCheck %s

int TestLocation;

struct TestIndent {
  int x;
};

struct TestChildren {
  int x;
  struct y {
    int z;
  };
};

void testLabelDecl() {
  __label__ TestLabelDecl;
  TestLabelDecl: goto TestLabelDecl;
}

typedef int TestTypedefDecl;

enum TestEnumDecl {
  testEnumDecl
};

struct TestEnumDeclAnon {
  enum {
    testEnumDeclAnon
  } e;
};

enum TestEnumDeclForward;

struct TestRecordDecl {
  int i;
};

struct TestRecordDeclEmpty {
};

struct TestRecordDeclAnon1 {
  struct {
  } testRecordDeclAnon1;
};

struct TestRecordDeclAnon2 {
  struct {
  };
};

struct TestRecordDeclForward;

enum testEnumConstantDecl {
  TestEnumConstantDecl,
  TestEnumConstantDeclInit = 1
};

struct TestIndirectFieldDecl {
  struct {
    int Field;
  };
};

// FIXME: It would be nice to dump the enum and its enumerators.
int TestFunctionDecl(int x, enum { e } y) {
  return x;
}

// FIXME: It would be nice to dump 'Enum' and 'e'.
int TestFunctionDecl2(enum Enum { e } x) { return x; }
int TestFunctionDeclProto(int x);
void TestFunctionDeclNoProto();
extern int TestFunctionDeclSC();
inline int TestFunctionDeclInline();

struct testFieldDecl {
  int TestFieldDecl;
  int TestFieldDeclWidth : 1;
};

int TestVarDecl;
extern int TestVarDeclSC;
__thread int TestVarDeclThread;
int TestVarDeclInit = 0;

void testParmVarDecl(int TestParmVarDecl);



// CHECK:  "kind": "VarDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 5,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 3
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 3
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 5,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 3
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestLocation",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "int"
// CHECK-NEXT:  }
// CHECK-NEXT: }


// CHECK:  "kind": "RecordDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 8,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 5
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 5
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 7
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestIndent",
// CHECK-NEXT:  "tagUsed": "struct",
// CHECK-NEXT:  "completeDefinition": true,
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "FieldDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 7,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 6
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 6
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 7,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 6
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "name": "x",
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "int"
// CHECK-NEXT:    }
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "RecordDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 8,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 9
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 9
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 14
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestChildren",
// CHECK-NEXT:  "tagUsed": "struct",
// CHECK-NEXT:  "completeDefinition": true,
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "FieldDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 7,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 10
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 10
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 7,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 10
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "name": "x",
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "int"
// CHECK-NEXT:    }
// CHECK-NEXT:   },
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "RecordDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 10,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 11
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 11
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 13
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "parentDeclContext": "0x{{.*}}",
// CHECK-NEXT:    "name": "y",
// CHECK-NEXT:    "tagUsed": "struct",
// CHECK-NEXT:    "completeDefinition": true,
// CHECK-NEXT:    "inner": [
// CHECK-NEXT:     {
// CHECK-NEXT:      "id": "0x{{.*}}",
// CHECK-NEXT:      "kind": "FieldDecl",
// CHECK-NEXT:      "loc": {
// CHECK-NEXT:       "col": 9,
// CHECK-NEXT:       "file": "{{.*}}",
// CHECK-NEXT:       "line": 12
// CHECK-NEXT:      },
// CHECK-NEXT:      "range": {
// CHECK-NEXT:       "begin": {
// CHECK-NEXT:        "col": 5,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 12
// CHECK-NEXT:       },
// CHECK-NEXT:       "end": {
// CHECK-NEXT:        "col": 9,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 12
// CHECK-NEXT:       }
// CHECK-NEXT:      },
// CHECK-NEXT:      "name": "z",
// CHECK-NEXT:      "type": {
// CHECK-NEXT:       "qualType": "int"
// CHECK-NEXT:      }
// CHECK-NEXT:     }
// CHECK-NEXT:    ]
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "LabelDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 13,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 17
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 3,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 17
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 13,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 17
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "isUsed": true,
// CHECK-NEXT:  "name": "TestLabelDecl"
// CHECK-NEXT: }


// CHECK:  "kind": "TypedefDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 13,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 21
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 21
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 13,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 21
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestTypedefDecl",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "int"
// CHECK-NEXT:  },
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "BuiltinType",
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "int"
// CHECK-NEXT:    }
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "EnumDecl",
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
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 25
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestEnumDecl",
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "EnumConstantDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 3,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 24
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 24
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 24
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "name": "testEnumDecl",
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "int"
// CHECK-NEXT:    }
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "RecordDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 8,
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
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 31
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestEnumDeclAnon",
// CHECK-NEXT:  "tagUsed": "struct",
// CHECK-NEXT:  "completeDefinition": true,
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "EnumDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 3,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 28
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 28
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 30
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "inner": [
// CHECK-NEXT:     {
// CHECK-NEXT:      "id": "0x{{.*}}",
// CHECK-NEXT:      "kind": "EnumConstantDecl",
// CHECK-NEXT:      "loc": {
// CHECK-NEXT:       "col": 5,
// CHECK-NEXT:       "file": "{{.*}}",
// CHECK-NEXT:       "line": 29
// CHECK-NEXT:      },
// CHECK-NEXT:      "range": {
// CHECK-NEXT:       "begin": {
// CHECK-NEXT:        "col": 5,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 29
// CHECK-NEXT:       },
// CHECK-NEXT:       "end": {
// CHECK-NEXT:        "col": 5,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 29
// CHECK-NEXT:       }
// CHECK-NEXT:      },
// CHECK-NEXT:      "name": "testEnumDeclAnon",
// CHECK-NEXT:      "type": {
// CHECK-NEXT:       "qualType": "int"
// CHECK-NEXT:      }
// CHECK-NEXT:     }
// CHECK-NEXT:    ]
// CHECK-NEXT:   },
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "FieldDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 5,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 30
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 28
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 5,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 30
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "name": "e",
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "desugaredQualType": "enum TestEnumDeclAnon::(anonymous at {{.*}}:28:3)",
// CHECK-NEXT:     "qualType": "enum (anonymous enum at {{.*}}:28:3)"
// CHECK-NEXT:    }
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "EnumDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 6,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 33
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 33
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 6,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 33
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestEnumDeclForward"
// CHECK-NEXT: }


// CHECK:  "kind": "RecordDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 8,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 35
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 35
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 37
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestRecordDecl",
// CHECK-NEXT:  "tagUsed": "struct",
// CHECK-NEXT:  "completeDefinition": true,
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "FieldDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 7,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 36
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 36
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 7,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 36
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "name": "i",
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "int"
// CHECK-NEXT:    }
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "RecordDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 8,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 39
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 39
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 40
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestRecordDeclEmpty",
// CHECK-NEXT:  "tagUsed": "struct",
// CHECK-NEXT:  "completeDefinition": true
// CHECK-NEXT: }


// CHECK:  "kind": "RecordDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 8,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 42
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 42
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 45
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestRecordDeclAnon1",
// CHECK-NEXT:  "tagUsed": "struct",
// CHECK-NEXT:  "completeDefinition": true,
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "RecordDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 3,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 43
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 43
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 44
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "tagUsed": "struct",
// CHECK-NEXT:    "completeDefinition": true
// CHECK-NEXT:   },
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "FieldDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 5,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 44
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 43
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 5,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 44
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "name": "testRecordDeclAnon1",
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "desugaredQualType": "struct TestRecordDeclAnon1::(anonymous at {{.*}}:43:3)",
// CHECK-NEXT:     "qualType": "struct (anonymous struct at {{.*}}:43:3)"
// CHECK-NEXT:    }
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "RecordDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 8,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 47
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 47
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 50
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestRecordDeclAnon2",
// CHECK-NEXT:  "tagUsed": "struct",
// CHECK-NEXT:  "completeDefinition": true,
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "RecordDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 3,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 48
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 48
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 49
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "tagUsed": "struct",
// CHECK-NEXT:    "completeDefinition": true
// CHECK-NEXT:   },
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "FieldDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 3,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 48
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 48
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 48
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "isImplicit": true,
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "struct TestRecordDeclAnon2::(anonymous at {{.*}}:48:3)"
// CHECK-NEXT:    }
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "RecordDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 8,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 52
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 52
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 8,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 52
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestRecordDeclForward",
// CHECK-NEXT:  "tagUsed": "struct"
// CHECK-NEXT: }


// CHECK:  "kind": "EnumConstantDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 3,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 55
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 3,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 55
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 3,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 55
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestEnumConstantDecl",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "int"
// CHECK-NEXT:  }
// CHECK-NEXT: }


// CHECK:  "kind": "EnumConstantDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 3,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 56
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 3,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 56
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 30,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 56
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestEnumConstantDeclInit",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "int"
// CHECK-NEXT:  },
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "ConstantExpr",
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 30,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 56
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 30,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 56
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "int"
// CHECK-NEXT:    },
// CHECK-NEXT:    "valueCategory": "rvalue",
// CHECK-NEXT:    "inner": [
// CHECK-NEXT:     {
// CHECK-NEXT:      "id": "0x{{.*}}",
// CHECK-NEXT:      "kind": "IntegerLiteral",
// CHECK-NEXT:      "range": {
// CHECK-NEXT:       "begin": {
// CHECK-NEXT:        "col": 30,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 56
// CHECK-NEXT:       },
// CHECK-NEXT:       "end": {
// CHECK-NEXT:        "col": 30,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 56
// CHECK-NEXT:       }
// CHECK-NEXT:      },
// CHECK-NEXT:      "type": {
// CHECK-NEXT:       "qualType": "int"
// CHECK-NEXT:      },
// CHECK-NEXT:      "valueCategory": "rvalue",
// CHECK-NEXT:      "value": "1"
// CHECK-NEXT:     }
// CHECK-NEXT:    ]
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "RecordDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 8,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 59
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 59
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 63
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestIndirectFieldDecl",
// CHECK-NEXT:  "tagUsed": "struct",
// CHECK-NEXT:  "completeDefinition": true,
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "RecordDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 3,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 60
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 60
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 62
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "tagUsed": "struct",
// CHECK-NEXT:    "completeDefinition": true,
// CHECK-NEXT:    "inner": [
// CHECK-NEXT:     {
// CHECK-NEXT:      "id": "0x{{.*}}",
// CHECK-NEXT:      "kind": "FieldDecl",
// CHECK-NEXT:      "loc": {
// CHECK-NEXT:       "col": 9,
// CHECK-NEXT:       "file": "{{.*}}",
// CHECK-NEXT:       "line": 61
// CHECK-NEXT:      },
// CHECK-NEXT:      "range": {
// CHECK-NEXT:       "begin": {
// CHECK-NEXT:        "col": 5,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 61
// CHECK-NEXT:       },
// CHECK-NEXT:       "end": {
// CHECK-NEXT:        "col": 9,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 61
// CHECK-NEXT:       }
// CHECK-NEXT:      },
// CHECK-NEXT:      "name": "Field",
// CHECK-NEXT:      "type": {
// CHECK-NEXT:       "qualType": "int"
// CHECK-NEXT:      }
// CHECK-NEXT:     }
// CHECK-NEXT:    ]
// CHECK-NEXT:   },
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "FieldDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 3,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 60
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 60
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 3,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 60
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "isImplicit": true,
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "struct TestIndirectFieldDecl::(anonymous at {{.*}}:60:3)"
// CHECK-NEXT:    }
// CHECK-NEXT:   },
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "IndirectFieldDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 9,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 61
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 9,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 61
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 9,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 61
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "isImplicit": true,
// CHECK-NEXT:    "name": "Field"
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "FunctionDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 5,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 66
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 66
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 68
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestFunctionDecl",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "int (int, enum (anonymous enum at {{.*}}:66:29))"
// CHECK-NEXT:  },
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "ParmVarDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 26,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 66
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 22,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 66
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 26,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 66
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "isUsed": true,
// CHECK-NEXT:    "name": "x",
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "int"
// CHECK-NEXT:    }
// CHECK-NEXT:   },
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "ParmVarDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 40,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 66
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 29,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 66
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 40,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 66
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "name": "y",
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "desugaredQualType": "enum (anonymous at {{.*}}:66:29)",
// CHECK-NEXT:     "qualType": "enum (anonymous enum at {{.*}}:66:29)"
// CHECK-NEXT:    }
// CHECK-NEXT:   },
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "CompoundStmt",
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 43,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 66
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 1,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 68
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "inner": [
// CHECK-NEXT:     {
// CHECK-NEXT:      "id": "0x{{.*}}",
// CHECK-NEXT:      "kind": "ReturnStmt",
// CHECK-NEXT:      "range": {
// CHECK-NEXT:       "begin": {
// CHECK-NEXT:        "col": 3,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 67
// CHECK-NEXT:       },
// CHECK-NEXT:       "end": {
// CHECK-NEXT:        "col": 10,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 67
// CHECK-NEXT:       }
// CHECK-NEXT:      },
// CHECK-NEXT:      "inner": [
// CHECK-NEXT:       {
// CHECK-NEXT:        "id": "0x{{.*}}",
// CHECK-NEXT:        "kind": "ImplicitCastExpr",
// CHECK-NEXT:        "range": {
// CHECK-NEXT:         "begin": {
// CHECK-NEXT:          "col": 10,
// CHECK-NEXT:          "file": "{{.*}}",
// CHECK-NEXT:          "line": 67
// CHECK-NEXT:         },
// CHECK-NEXT:         "end": {
// CHECK-NEXT:          "col": 10,
// CHECK-NEXT:          "file": "{{.*}}",
// CHECK-NEXT:          "line": 67
// CHECK-NEXT:         }
// CHECK-NEXT:        },
// CHECK-NEXT:        "type": {
// CHECK-NEXT:         "qualType": "int"
// CHECK-NEXT:        },
// CHECK-NEXT:        "valueCategory": "rvalue",
// CHECK-NEXT:        "castKind": "LValueToRValue",
// CHECK-NEXT:        "inner": [
// CHECK-NEXT:         {
// CHECK-NEXT:          "id": "0x{{.*}}",
// CHECK-NEXT:          "kind": "DeclRefExpr",
// CHECK-NEXT:          "range": {
// CHECK-NEXT:           "begin": {
// CHECK-NEXT:            "col": 10,
// CHECK-NEXT:            "file": "{{.*}}",
// CHECK-NEXT:            "line": 67
// CHECK-NEXT:           },
// CHECK-NEXT:           "end": {
// CHECK-NEXT:            "col": 10,
// CHECK-NEXT:            "file": "{{.*}}",
// CHECK-NEXT:            "line": 67
// CHECK-NEXT:           }
// CHECK-NEXT:          },
// CHECK-NEXT:          "type": {
// CHECK-NEXT:           "qualType": "int"
// CHECK-NEXT:          },
// CHECK-NEXT:          "valueCategory": "lvalue",
// CHECK-NEXT:          "referencedDecl": {
// CHECK-NEXT:           "id": "0x{{.*}}",
// CHECK-NEXT:           "kind": "ParmVarDecl",
// CHECK-NEXT:           "name": "x",
// CHECK-NEXT:           "type": {
// CHECK-NEXT:            "qualType": "int"
// CHECK-NEXT:           }
// CHECK-NEXT:          }
// CHECK-NEXT:         }
// CHECK-NEXT:        ]
// CHECK-NEXT:       }
// CHECK-NEXT:      ]
// CHECK-NEXT:     }
// CHECK-NEXT:    ]
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "FunctionDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 5,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 71
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 71
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 54,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 71
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestFunctionDecl2",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "int (enum Enum)"
// CHECK-NEXT:  },
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "ParmVarDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 39,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 71
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 23,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 71
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 39,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 71
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "isUsed": true,
// CHECK-NEXT:    "name": "x",
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "desugaredQualType": "enum Enum",
// CHECK-NEXT:     "qualType": "enum Enum"
// CHECK-NEXT:    }
// CHECK-NEXT:   },
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "CompoundStmt",
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 42,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 71
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 54,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 71
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "inner": [
// CHECK-NEXT:     {
// CHECK-NEXT:      "id": "0x{{.*}}",
// CHECK-NEXT:      "kind": "ReturnStmt",
// CHECK-NEXT:      "range": {
// CHECK-NEXT:       "begin": {
// CHECK-NEXT:        "col": 44,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 71
// CHECK-NEXT:       },
// CHECK-NEXT:       "end": {
// CHECK-NEXT:        "col": 51,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 71
// CHECK-NEXT:       }
// CHECK-NEXT:      },
// CHECK-NEXT:      "inner": [
// CHECK-NEXT:       {
// CHECK-NEXT:        "id": "0x{{.*}}",
// CHECK-NEXT:        "kind": "ImplicitCastExpr",
// CHECK-NEXT:        "range": {
// CHECK-NEXT:         "begin": {
// CHECK-NEXT:          "col": 51,
// CHECK-NEXT:          "file": "{{.*}}",
// CHECK-NEXT:          "line": 71
// CHECK-NEXT:         },
// CHECK-NEXT:         "end": {
// CHECK-NEXT:          "col": 51,
// CHECK-NEXT:          "file": "{{.*}}",
// CHECK-NEXT:          "line": 71
// CHECK-NEXT:         }
// CHECK-NEXT:        },
// CHECK-NEXT:        "type": {
// CHECK-NEXT:         "qualType": "int"
// CHECK-NEXT:        },
// CHECK-NEXT:        "valueCategory": "rvalue",
// CHECK-NEXT:        "castKind": "IntegralCast",
// CHECK-NEXT:        "inner": [
// CHECK-NEXT:         {
// CHECK-NEXT:          "id": "0x{{.*}}",
// CHECK-NEXT:          "kind": "ImplicitCastExpr",
// CHECK-NEXT:          "range": {
// CHECK-NEXT:           "begin": {
// CHECK-NEXT:            "col": 51,
// CHECK-NEXT:            "file": "{{.*}}",
// CHECK-NEXT:            "line": 71
// CHECK-NEXT:           },
// CHECK-NEXT:           "end": {
// CHECK-NEXT:            "col": 51,
// CHECK-NEXT:            "file": "{{.*}}",
// CHECK-NEXT:            "line": 71
// CHECK-NEXT:           }
// CHECK-NEXT:          },
// CHECK-NEXT:          "type": {
// CHECK-NEXT:           "desugaredQualType": "enum Enum",
// CHECK-NEXT:           "qualType": "enum Enum"
// CHECK-NEXT:          },
// CHECK-NEXT:          "valueCategory": "rvalue",
// CHECK-NEXT:          "castKind": "LValueToRValue",
// CHECK-NEXT:          "inner": [
// CHECK-NEXT:           {
// CHECK-NEXT:            "id": "0x{{.*}}",
// CHECK-NEXT:            "kind": "DeclRefExpr",
// CHECK-NEXT:            "range": {
// CHECK-NEXT:             "begin": {
// CHECK-NEXT:              "col": 51,
// CHECK-NEXT:              "file": "{{.*}}",
// CHECK-NEXT:              "line": 71
// CHECK-NEXT:             },
// CHECK-NEXT:             "end": {
// CHECK-NEXT:              "col": 51,
// CHECK-NEXT:              "file": "{{.*}}",
// CHECK-NEXT:              "line": 71
// CHECK-NEXT:             }
// CHECK-NEXT:            },
// CHECK-NEXT:            "type": {
// CHECK-NEXT:             "desugaredQualType": "enum Enum",
// CHECK-NEXT:             "qualType": "enum Enum"
// CHECK-NEXT:            },
// CHECK-NEXT:            "valueCategory": "lvalue",
// CHECK-NEXT:            "referencedDecl": {
// CHECK-NEXT:             "id": "0x{{.*}}",
// CHECK-NEXT:             "kind": "ParmVarDecl",
// CHECK-NEXT:             "name": "x",
// CHECK-NEXT:             "type": {
// CHECK-NEXT:              "desugaredQualType": "enum Enum",
// CHECK-NEXT:              "qualType": "enum Enum"
// CHECK-NEXT:             }
// CHECK-NEXT:            }
// CHECK-NEXT:           }
// CHECK-NEXT:          ]
// CHECK-NEXT:         }
// CHECK-NEXT:        ]
// CHECK-NEXT:       }
// CHECK-NEXT:      ]
// CHECK-NEXT:     }
// CHECK-NEXT:    ]
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "FunctionDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 5,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 72
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 72
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 32,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 72
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestFunctionDeclProto",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "int (int)"
// CHECK-NEXT:  },
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "ParmVarDecl",
// CHECK-NEXT:    "loc": {
// CHECK-NEXT:     "col": 31,
// CHECK-NEXT:     "file": "{{.*}}",
// CHECK-NEXT:     "line": 72
// CHECK-NEXT:    },
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 27,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 72
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 31,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 72
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "name": "x",
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
// CHECK-NEXT:   "line": 73
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 73
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 30,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 73
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestFunctionDeclNoProto",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "void ()"
// CHECK-NEXT:  }
// CHECK-NEXT: }


// CHECK:  "kind": "FunctionDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 12,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 74
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 74
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 31,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 74
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestFunctionDeclSC",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "int ()"
// CHECK-NEXT:  },
// CHECK-NEXT:  "storageClass": "extern"
// CHECK-NEXT: }


// CHECK:  "kind": "FunctionDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 12,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 75
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 75
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 35,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 75
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestFunctionDeclInline",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "int ()"
// CHECK-NEXT:  },
// CHECK-NEXT:  "inline": true
// CHECK-NEXT: }


// CHECK:  "kind": "FieldDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 7,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 78
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 3,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 78
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 7,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 78
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestFieldDecl",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "int"
// CHECK-NEXT:  }
// CHECK-NEXT: }


// CHECK:  "kind": "FieldDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 7,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 79
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 3,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 79
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 28,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 79
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestFieldDeclWidth",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "int"
// CHECK-NEXT:  },
// CHECK-NEXT:  "isBitfield": true,
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "ConstantExpr",
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 28,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 79
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 28,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 79
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "int"
// CHECK-NEXT:    },
// CHECK-NEXT:    "valueCategory": "rvalue",
// CHECK-NEXT:    "inner": [
// CHECK-NEXT:     {
// CHECK-NEXT:      "id": "0x{{.*}}",
// CHECK-NEXT:      "kind": "IntegerLiteral",
// CHECK-NEXT:      "range": {
// CHECK-NEXT:       "begin": {
// CHECK-NEXT:        "col": 28,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 79
// CHECK-NEXT:       },
// CHECK-NEXT:       "end": {
// CHECK-NEXT:        "col": 28,
// CHECK-NEXT:        "file": "{{.*}}",
// CHECK-NEXT:        "line": 79
// CHECK-NEXT:       }
// CHECK-NEXT:      },
// CHECK-NEXT:      "type": {
// CHECK-NEXT:       "qualType": "int"
// CHECK-NEXT:      },
// CHECK-NEXT:      "valueCategory": "rvalue",
// CHECK-NEXT:      "value": "1"
// CHECK-NEXT:     }
// CHECK-NEXT:    ]
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "VarDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 5,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 82
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 82
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 5,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 82
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestVarDecl",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "int"
// CHECK-NEXT:  }
// CHECK-NEXT: }


// CHECK:  "kind": "VarDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 12,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 83
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 83
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 12,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 83
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestVarDeclSC",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "int"
// CHECK-NEXT:  },
// CHECK-NEXT:  "storageClass": "extern"
// CHECK-NEXT: }


// CHECK:  "kind": "VarDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 14,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 84
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 84
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 14,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 84
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestVarDeclThread",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "int"
// CHECK-NEXT:  },
// CHECK-NEXT:  "tls": "static"
// CHECK-NEXT: }


// CHECK:  "kind": "VarDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 5,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 85
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 1,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 85
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 23,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 85
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestVarDeclInit",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "int"
// CHECK-NEXT:  },
// CHECK-NEXT:  "init": "c",
// CHECK-NEXT:  "inner": [
// CHECK-NEXT:   {
// CHECK-NEXT:    "id": "0x{{.*}}",
// CHECK-NEXT:    "kind": "IntegerLiteral",
// CHECK-NEXT:    "range": {
// CHECK-NEXT:     "begin": {
// CHECK-NEXT:      "col": 23,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 85
// CHECK-NEXT:     },
// CHECK-NEXT:     "end": {
// CHECK-NEXT:      "col": 23,
// CHECK-NEXT:      "file": "{{.*}}",
// CHECK-NEXT:      "line": 85
// CHECK-NEXT:     }
// CHECK-NEXT:    },
// CHECK-NEXT:    "type": {
// CHECK-NEXT:     "qualType": "int"
// CHECK-NEXT:    },
// CHECK-NEXT:    "valueCategory": "rvalue",
// CHECK-NEXT:    "value": "0"
// CHECK-NEXT:   }
// CHECK-NEXT:  ]
// CHECK-NEXT: }


// CHECK:  "kind": "ParmVarDecl",
// CHECK-NEXT:  "loc": {
// CHECK-NEXT:   "col": 26,
// CHECK-NEXT:   "file": "{{.*}}",
// CHECK-NEXT:   "line": 87
// CHECK-NEXT:  },
// CHECK-NEXT:  "range": {
// CHECK-NEXT:   "begin": {
// CHECK-NEXT:    "col": 22,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 87
// CHECK-NEXT:   },
// CHECK-NEXT:   "end": {
// CHECK-NEXT:    "col": 26,
// CHECK-NEXT:    "file": "{{.*}}",
// CHECK-NEXT:    "line": 87
// CHECK-NEXT:   }
// CHECK-NEXT:  },
// CHECK-NEXT:  "name": "TestParmVarDecl",
// CHECK-NEXT:  "type": {
// CHECK-NEXT:   "qualType": "int"
// CHECK-NEXT:  }
// CHECK-NEXT: }

