default rel

extern _putchar
extern _printf

global _main
global _iterate
global _drawchar

section .text

_iterate:
  push rbp
  mov rbp, rsp
  xor rax, rax
  fld st0
  fmul st1
  fld st2
  fmul st3
  faddp
  fistp dword [intTest]
  mov edx, [intTest]
  cmp edx, 4
  jge .asdf
  pop rbp
  ret
  .asdf:
  inc rax
  pop rbp
  ret

  xor rax, rax
  ; 2
  ; st0 = c.imag, st1 = c.real 
  ; push z.imag and z.real
  fldz
  ; 3
  fldz
  ; 4: zr, zi, cr, ci
  xor rcx, rcx            ; rcx counts iterations
  mov r8, [itercap]
  .loop:
    ; get zi^2
    fld st1
    fmul st0
    ; 5
    ; get zr^2
    fld st3
    fmul st0
    ; 6: zr2, zi2, zr, zi, cr, ci
    ; get 2 * zr*zi
    fld st2
    fmul st4
    ; 7: zrzi, zr2, zi2, zr, zi, cr, ci
    fadd st0
    ; st0 = zrzi
    ; replace zi with (2*zr*zi) + c.i
    fadd st6
    ; put st0 in zi's place
    fxch st4
    ; pop?
    ffree st0
    ; get zr2 - zi2 + zr
    ; 6: zr2, zi2, zr, zi, cr, ci
    fld st0
    ; 7
    fsub st2
    fadd st3, st0
    ffree st0
    ; test for divergence
    fld st0
    fadd st2
    inc rcx
    fistp dword [intTest]
    mov edx, [intTest]
    ; pop 3 regs so there is just zr, zi, cr, ci
    ffree st0
    ffree st0
    ; cpu comparison flags now set 
    cmp edx, 4
    jl .diverged
    cmp rcx, r8
    je .converged
    jmp .loop
  ; return rax = 1 if converge, 0 otherwise
  .converged:
  inc rax
  .diverged:
  ret

_drawchar:
  push rbp
  mov rbp, rsp
  test rdi, rdi
  jnz .inSet
    mov edi, [divergeChar]
    call _putchar
    jmp .drawDone
  .inSet:
    mov edi, [convergeChar]
    call _putchar
  .drawDone:
  pop rbp
  ret

_main:
  push rbp
  mov rbp, rsp
  finit
  ; begin main
  ; push c.r
  fld dword [ystart]
  mov bh, 30
  .outer:           ; loop over y
    ; y loop
    mov bl, 80
    ; push c.i
    fld dword [xstart]
    .inner:
      ; line, x loop
      ; ystart += ps
      call _iterate  ; eax is 1 if in set
      mov rdi, rax
      call _drawchar
      ; y += ps
      fld dword [ps]
      faddp
      dec bl
      test bl, bl
      jnz .inner
    faddp st0
    fld dword [ps]
    faddp
    mov edi, 0x0A
    call _putchar
    dec bh
    test bh, bh
    jnz .outer
  ; end main
  ffree st0
  xor rax, rax
  pop rbp
  ret

section .data

itercap: dd 1000
width: dd 80.0      ; width in pixels
height: dd 30.0     ; height in pixels
xstart: dd -2.0
ystart: dd -2.0
ps: dd 0.05
intTest: dd 0
status: dw 0
convergeChar: dd 0x2A ; asterisk
divergeChar: dd 0x21  ; space
fmt: db '%i ', 0
