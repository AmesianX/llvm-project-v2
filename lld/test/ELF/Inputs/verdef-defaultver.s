b@LIBSAMPLE_1.0 = b_1
b@@LIBSAMPLE_2.0 = b_2

.globl a
.type  a,@function
a:
retq

.globl b_1
.type  b_1,@function
b_1:
retq

.globl b_2
.type  b_2,@function
b_2:
retq

.globl c
.type  c,@function
c:
retq
