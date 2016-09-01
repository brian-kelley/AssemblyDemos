default rel

extern _putchar

global _main
global _iterate

section .text

_iterate:
  push rbp
  mov rbp, rsp
  ; 2
  ; st0 = c.imag, st1 = c.real 
  ; push z.imag and z.real
  fldz
  ; 3
  fldz
  ; 4: zr, zi, cr, ci
  xor rcx, rcx            ; rcx counts iterations
  mov rdx, [itercap]
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
    faddp st0
    ; get zr2 - zi2 + zr
    ; 6: zr2, zi2, zr, zi, cr, ci
    fld st0
    ; 7
    fsub st2
    fadd st3, st0
    ; pop?
    faddp st0
    ; test for divergence
    fld st0
    fadd st2
    inc rcx
    fistp word [intTest]
    mov eax, [intTest]
    ; pop 3 regs so there is just zr, zi, cr, ci
    faddp st0
    faddp st0
    faddp st0
    ; cpu comparison flags now set 
    cmp eax, 4
    jge .diverged
    cmp rcx, rdx
    je .converged
    jmp .loop
  ; return rax = 1 if converge, 0 otherwise
  xor rax, rax
  .converged:
  inc rax
  .diverged:
  pop rbp
  ret

_main:
  push rbp
  mov rbp, rsp
  fninit
  ; begin main
  fld dword [xstart]
  mov ch, 50
  .outer:           ; loop over y
    ; y loop
    mov cl, 80
    fld dword [ystart]
    .inner:
      ; line, x loop
      ; ystart += ps
      push rcx
      call _iterate  ; eax is 1 if in set
      test rax, rax
      jnz .converged
        mov edi, [divergeChar]
        call _putchar
        jmp .drawDone
      .converged:
        mov edi, [convergeChar]
        call _putchar
      .drawDone:
      pop rcx
      ; y += ps
      fld dword [ps]
      faddp st1
      dec cl
      test cl, cl
      jnz .inner
    faddp st0
    fld dword [ps]
    faddp st1
    dec ch
    test ch, ch
    jnz .outer
  ; end main
  pop rbp
  ret

section .data

itercap: dd 1000
width: dd 80.0      ; width in pixels
height: dd 50.0     ; height in pixels
xstart: dd -2.0
ystart: dd -1.25
ps: dd 0.05
intTest: dd 0
convergeChar: dd 0x2A ; asterisk
divergeChar: dd 0x20  ; space
