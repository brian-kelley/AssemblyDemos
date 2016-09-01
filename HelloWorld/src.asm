extern _puts

global _main

section .text

_main:
  push rbp
  mov rbp, rsp
  mov rdi, string   ; first arg is ptr to the string
  call _puts
  xor rax, rax      ; return 0 for success
  pop rbp
  ret

section .data

string: db 'Hello World!', 0
