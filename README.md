# Collatz-conjecture
Tests the Collatz conjecture for integers from 0 to 2^64-1 using 128 bits of precision.
*Note:* Uses linux system calls, so you can't run it on Windows or Mac.

You can compile and run it like this:
```
nasm collatz.asm -felf64 -o collatz.o
ld collatz.o -o collatz
./collatz
```
