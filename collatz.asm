bits 64
section .text
global _start

%define stdout 1
%define sys_write 1
%define sys_exit 60

_start:
   mov rsi, 0x0000000000001000 ; One above the maximum value of n to test.
   mov rcx, 0x0000000000000001 ; Starting value of n
   mov r15, rcx
   .loop:
      xor edx, edx
      xor r8, r8
      mov rax, rcx
      .inner_loop:
         ; Uncomment to print sequence. (Make sure you only set rsi to rcx+1!)
         ;mov r15, rdx
         ;call print_r15
         ;mov r15, rax
         ;call print_r15
         ;call print_newline
         add r8, 1
         jc .failed
         test rax, 0x1
         jz .mod2
         mov rbx, rax
         mov rbp, rdx
         add rax, rax
         adc rdx, rdx
         jc .overflow
         add rax, rbx
         adc rdx, rbp
         jc .overflow
         add rax, 1
         adc rdx, 0
         jc .overflow
         jmp .inner_loop
      .mod2:
         shr rax, 1
         mov rbx, rdx
         shr rdx, 1
         shr rbx, 63
         or rax,rbx
         test rdx, rdx
         jnz .inner_loop
         test rax, ~1
         jnz .inner_loop
      add rcx, 0x01
      cmp rcx, rsi
      jl .loop
      .done:

   mov rax, sys_exit
   xor edi, edi
   syscall

   .failed:
   mov r15, rcx
   call print_r15
   mov rdx, 0x3e
   mov rsi, failed_message
   call printn
   mov rax, sys_exit
   mov edi, 0x01
   syscall

   .overflow:
   mov r15, rcx
   call print_r15
   mov rdx, 0xd
   mov rsi, overflow_message
   call printn
   mov rax, sys_exit
   mov edi, 0x01
   syscall


printn: ; Prints string in rsi with a length of rdx.
   mov rax, sys_write
   mov rdi, stdout
   syscall
   ret

print_r15: ; Prints r15. Clobbers r14, r11, and rdi.
   push rdx
   push rcx
   push rax
   push rsi
   xor ecx, ecx
   mov rsi, print_u64_buffer
   cld
   .loop:
      mov r14, r15
      shr r14, 0x3c
      lea eax, [r14 + 0x30]
      lea r11d, [r14 + 0x57]
      cmp r14b, 0x09
      cmova eax, r11d
      shl r15, 0x04
      mov [rsi+rcx], al
      add ecx, 0x01
      test ecx, 0x10
      jz .loop
   mov rax, sys_write
   mov rdi, stdout
   mov rdx, 0x10
   syscall
   pop rsi
   pop rax
   pop rcx
   pop rdx
   ret

print_newline:
   push rsi
   push rax
   push rdi
   push rdx
   mov rax, sys_write
   mov rdi, stdout
   mov [rsp-1], byte 0x0a
   lea rsi, [rsp-1]
   mov rdx, 0x01
   syscall
   pop rdx
   pop rdi
   pop rax
   pop rsi
   ret


section .data

failed_message: db "=n Failed to halt in less than 0xffffffffffffffff iterations!", 0x0a
overflow_message: db "=n Overflow!", 0x0a

section .bss

print_u64_buffer resb 0x10

