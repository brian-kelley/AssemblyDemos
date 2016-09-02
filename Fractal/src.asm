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
  jmp .actual
  ; fp stack has 2: cr, ci
  ; debugging: multiply cr and ci by 32 and print them
  ; st0 = cr, st1 = ci
  ; 2
  ; push z.imag and z.real (both initially zero)
  ; testing: cr^2 + ci^2 >= 4
  fld st0
  fmul st0
  fld st2
  fmul st0
  faddp st1
  fistp dword [intTest]
  mov eax, [intTest]
  cmp eax, 4
  jg .asdf1
  xor rax, rax
  pop rbp
  ret
  .asdf1:
  xor rax, rax
  inc rax
  pop rbp
  ret

  .actual:
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
    ; zr^2, zr, zi, cr, ci
    ; get zi^2
    fld st2
    fmul st0
    ; zi^2, zr^2, zr, zi, cr, ci
    ; get magnitude
    fld st0
    ; zi^2, zi^2, zr^2, zr, zi, cr, ci
    fadd st2
    fistp dword [intTest]
    mov eax, [intTest]
    cmp eax, 4
    jge .done1  ; pops zi^2 and zr^2
    ; zi^2, zr^2, zr, zi, cr, ci
    ; get zr * zi
    fld st2
    ; zr, zi^2, zr^2, zr, zi, cr, ci
    fmul st4
    ; zr*zi, zi^2, zr^2, zr, zi, cr, ci
    ; double it
    fadd st0
    ; add ci
    fadd st6
    ; put in zi's place and pop
    fxch st4
    faddp st0
    ; zi^2, zr^2, zr, zi, cr, ci
    ; get new zr
    fxch
    ; zr^2, zi^2, zr, zi, cr, ci
    fsub st1
    fxch
    faddp st0
    ; zr^2 - zi^2, zr, zi, cr, ci
    fadd st3
    ; put in zr's place
    fxch st1
    ; pop 1
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
    mov edi, 0x2D
    call _putchar
  .drawDone:
  pop rbp
  ret

_main:
  push rbp
  mov rbp, rsp
  finit
  ; push c.i
  fld dword [ystart]
  mov bh, 30
  .outer:           ; loop over y
    ; y loop
    mov bl, 80
    ; push c.r
    fld dword [xstart]
    .inner:
      ; x loop
      call _iterate  ; eax is 1 if in set
      mov rdi, rax
      call _drawchar
      fld dword [psx]
      faddp
      dec bl
      test bl, bl
      jnz .inner
    ; pop x (cr) from inner loop
    faddp st0
    fld dword [psy]
    faddp
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

section .rodata

itercap: dq 500
xstart: dd -1.5
ystart: dd -1.5
psx: dd 0.0375
psy: dd 0.107

section .data

status: dw 0
intTest: dd 0
delay: dq 0xFFFFFF
fmt: db '%i ', 0
fmt2: db '%x', 0x0A, 0
fmt3: db '(%3i,%3i) ', 0
msg1: db 'Starting outer loop', 0
msg2: db 'Done with iterate()', 0
debug1: dd 0
debug2: dd 0
