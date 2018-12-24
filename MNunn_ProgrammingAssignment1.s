// Michael Nunn
// Programming Assignment 1
// 10/19/2018

.global _start
.section .text

_start:

/* syscall write(int fd, const void *buf, size_t count) */
/* the three arguments will be put in registers x0, x1, x2*/

// print message
mov x0, #1 // stdout
ldr x1, =message;
mov x2, #15
mov x8, #64
svc #0

/* syscall read(int fd, const void *buf, size_t count) */
/* the three arguments will be put in registers x0, x1, x2*/
/* the item read will be in the register x1*/
/* the return value is the number of bytes read */

// read input
mov x0, #0 // stdin
ldr x1, =strbuffer;
mov x2, #999  // read up to 999 characters
mov x8, #63 //  decimal 63 for read
svc #0 //do it!

// calculate string length
mov x10, #0 // zero out x10
ldr x9, =strbuffer // x9 = strbuffer
length_loop:
ldrb w10, [x9], 1 // x10 = *x9++;
cmp x10, #0 // if (x10 != 0) goto loop;
bne length_loop //
ldr x10, =strbuffer
sub x9, x9, #2 // subtract newline and null chars
sub x14, x9, 1 // store address of last char in x14
sub x9, x9, x10 // calculate length


// convert string length into characters
ldr x10, =numbuffer + 2 // start at last digit
mov x12, #10
convert_loop:
udiv x11, x9, x12 // x11 = x9 / 10
msub x13, x11, x12, x9 // x13 = x9 - (x11 * 10)
mov x9, x11 // x9 = x11
add x13, x13, #48 // x13 = x13 + '0' (ASCII 48)
strb w13, [x10], -1 // *x10-- = x13
cmp x9, #0 // if (x9 != 0) goto loop;
bne convert_loop //
add x10, x10, #1 // undo last decrement
ldr x11, =numbuffer + 4 // end of string
sub x12, x11, x10


// print number
mov x0, #1 // stdout
mov x1, x10
mov x2, x12
mov x8, #64
svc #0

// check if palindrome
ldr x0, =strbuffer // store address of first char in x0
mov x1, x14 // store address of last char in x1
bl palindrome
mov x9, x2 // store result in x9

// print "True" or "False"
// print message
mov x0, #1 // stdout
ldr x1, =str_true;
mov x2, #5
cmp x9, #0 // if (x9 != 0) goto print_true;
bne print_true
ldr x1, =str_false;
mov x2, #6
print_true:
mov x8, #64
svc #0

//exit the program
mov x8, #93
mov x0, x2 // exit code
svc #0

ret

// x0: address of first char
// x1: address of last char
// x2: return 1 if palindrome, 0 if not
palindrome:
mov x2, #1 // let's assume it's a palindrome
cmp x1, x0
bhi not_done
br x30
not_done:
mov x9, #0 // set high bits to zero
mov x10, #0 // set high bits to zero
ldrb w9, [x0], 1 // x9 = *x0++
ldrb w10, [x1], -1 // x10 = *x1--
cmp x9, x10
beq recurse
mov x2, #0
br x30
recurse:
sub sp, sp, #16 // crashes with #8 instead of #16
str x30, [sp] // store link register
bl palindrome
ldr x30, [sp]
add sp, sp, #16 // crashes with #8 instead of #16
br x30

.section .data

message: .asciz "input a string\n"
strbuffer: .space 999
numbuffer: .asciz "999\n" // 3 digits, newline, null char
str_true: .asciz "True\n"
str_false: .asciz "False\n"
