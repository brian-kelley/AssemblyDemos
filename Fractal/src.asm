default rel

extern _putchar
extern _printf
extern _puts

global _main
global _iterate
global _drawchar

section .text

_iterate:
  push rbp
  mov rbp, rsp
  ; fp stack has 2: cr, ci
  ; st0 = cr, st1 = ci
  ; 2
  ; push z.imag and z.real (both initially zero)
  fldz
  fldz
  ; 4: zr, zi, cr, ci
  mov rcx, [itercap]
  inc rcx
  .loop:
    ; print out FPU stack top: should be same every iteration
    ; get zr^2
    fld st0
    fmul st0            ; squares st0
    ; 5
    ; get zi^2
    fld st2
    fmul st0
    ; get magnitude
    fld st0
    fadd st2
    fistp dword [intTest]
    mov eax, [intTest]
    cmp eax, 4
    jge .done1  ; pops zi^2 and zr^2
    ; get zr * zi
    fld st2
    fmul st4
    ; double it
    fadd st0
    ; add ci
    fadd st6
    ; put in zi's place and pop
    fxch st4
    faddp st0
    ; get new zr
    fld st1
    fsubp st1
    ; zr^2 - zi^2, zr^2, zr, zi, cr, ci
    fadd st4
    ; put in zr's place
    fxch st2
    ; pop 2
    faddp st0
    faddp st0
    ; test for divergence
    dec rcx
    test rcx, rcx
    jz .done2
    jmp .loop
  ; return rax = 1 if converge, 0 otherwise
  .done1:
  faddp st0
  faddp st0
  .done2:
  mov rax, rcx
  faddp st0
  faddp st0
  pop rbp
  ret

_drawchar:
  push rbp
  mov rbp, rsp
  test rdi, rdi
  jnz .inSet
    mov edi, 0x2A
    call _putchar
    jmp .drawDone
  .inSet:
    mov edi, 0x1F
    call _putchar
  .drawDone:
  pop rbp
  ret

_main:
  push rbp
  mov rbp, rsp
  finit
  ; push c.r
  fld dword [ystart]
  mov bh, 31
  .outer:           ; loop over y
    ; y loop
    mov bl, 120
    ; push c.i
    fld dword [xstart]
    .inner:
      ; x loop
      call _iterate  ; eax is 1 if in set
      mov rdi, rax
      call _drawchar
      ; y += ps
      fld dword [psx]
      faddp st1
      dec bl
      test bl, bl
      jnz .inner
    ; pop x (cr) from inner loop
    faddp st0
    fld dword [psy]
    faddp st1
    mov edi, 0x0A
    call _putchar
    dec bh
    test bh, bh
    jnz .outer
  ; end main
  faddp st0
  ; return 0 for success
  xor rax, rax
  pop rbp
  ret

section .data

status: dw 0
intTest: dd 0
debug1: dd 0
debug2: dd 0

section .rodata

itercap: dq 100000
xstart: dd -1.94
ystart: dd -1.94
psx: dd 0.0494
psy: dd 0.13
fmt: db '%i ', 0
fmt2: db '%x', 0x0A, 0
fmt3: db '(%4i,%4i)   ', 0
msg1: db 'Starting outer loop', 0
msg2: db 'Done with iterate()', 0

