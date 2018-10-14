.386
.model flat, stdcall
option casemap:none

include g:\masm32\include\windows.inc
include g:\masm32\include\kernel32.inc
include g:\masm32\include\masm32.inc
include g:\masm32\include\msvcrt.inc
includelib g:\masm32\lib\kernel32.lib
includelib g:\masm32\lib\masm32.lib
includelib g:\masm32\lib\msvcrt.lib

; return the value of REG in MEM-REG-R/M in al
RegInMemRegRmValue proc, reg: dword
    .if reg == 0
        mov al, 0
    .else if reg == 1
        mov al, 8
    .else if reg == 2
        mov al, 16
    .else if reg == 3
        mov al, 24
    .else if reg == 4
        mov al, 32
    .else if reg == 5
        mov al, 40
    .else if reg == 6
        mov al, 48
    .else if reg == 7
        mov al, 56
    .else
        ; reg should be in [0, 8)
        invoke ExitProcess, 1
RegInMemRegRmValue endp

; return the value of scale in SIB in al
ScaleInSibValue proc, scale: dword
    .if scale == 1
        mov al, 0
    .else if scale == 2
        mov al, 64
    .else if scale == 4
        mov al, 128
    .else if scale == 8
        mov al, 192
    .else
        ; scale should be in {1, 2, 4, 8}
        invoke ExitProcess, 1
    ret
ScaleInSibValue endp


; return the value of index in SIB in al
; index equal to 100 is illegal when use this function
IndexInSibValue proc, index: dword
    .if index == 0
        mov al, 0
    .else if index == 1
        mov al, 8
    .else if index == 2
        mov al, 16
    .else if index == 3
        mov al, 24
    .else if index == 4
        ; index equal to 100 is illegal when use this function
        invoke ExitProcess, 1
    .else if index == 5
        mov al, 40
    .else if index == 6
        mov al, 48
    .else if index == 7
        mov al, 56
    .else
        ; index should be in [0, 8)
        invoke ExitProcess, 1
    ret
IndexInSibValue endp