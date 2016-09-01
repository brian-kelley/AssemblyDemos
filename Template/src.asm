extern _puts

global _main

section .text

_main:
  push rbp
  mov rbp, rsp
  ; begin main
  ; end main
  pop rbp
  ret

section .data

