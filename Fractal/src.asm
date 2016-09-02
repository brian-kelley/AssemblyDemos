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
  mov rax, [itercap]
  sub rax, rdi
  ; if rax == 0: print 0x2A
  ; else if rax <= 4: print 0x2D
  ; else: print 0x20
  cmp eax, 4
  jg .zone1
  mov edi, 0x20
  jmp .print
  .zone1:
  cmp eax, 100
  jg .zone2
  mov edi, 0x2D
  jmp .print
  .zone2:
  mov edi, 0x23
  .print:
  call _putchar
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

itercap: dq 500000
xstart: dd -1.5
ystart: dd -1.2
psx: dd 0.028
psy: dd 0.08

section .data

status: dw 0
intTest: dd 0
