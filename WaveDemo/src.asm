default rel

extern _putchar
extern _sin

global _main

section .text

_main:
  push rbp
  mov rbp, rsp
  fninit
  ; begin main
  fld qword [width]
  fld qword [delta]
  fld qword [time]
  .line:
    fld st0                 ; copy time since st0 modified by fsin
    fsin                    ; get sin(t)
    fld1                    ; shift range to [0, 2)
    faddp
    fmul st3                ; scale to range [0, 80]
    fistp dword [intval]    ; cast value to s32
    fadd st1                ; time += timestep
    mov ecx, [intval]
    mov dl, 80    ; 2w
    xor rbx, rbx
    cmp cl, dl
    .a1:
      cmp bl, cl
      jge .a1done
      push rcx
      push rdx
      mov edi, [fill]     ; putchar will print edi as char
      call _putchar
      pop rdx
      pop rcx
      inc bl
      jmp .a1
    .a1done:
    ; delay, cycles proportional to delayticks
    mov rax, [delayticks] 
    .wait:
      nop
      dec rax
      test rax, rax
      jnz .wait
    mov edi, 0x0A
    call _putchar
    jmp .line
.done:
pop rbp
ret

section .data

width: dq 40.0
time: dq 0.785
delta: dq 0.1
intval: dd 0
delayticks: dq 0x1FFFFFF
empty: dd ' '
fill: dd '*'
fmt: db '%i', 0x0A, 0x0

