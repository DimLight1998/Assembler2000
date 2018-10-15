.386
.model flat, stdcall
option casemap:none

include EncoderUtils.inc

; almost the same as PushReg
IncReg proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 0ffh

    ; mrr
    ; MOD = 11, R/M on sourceReg
    ; REG = 000 to enable INC, set to other value will not be INC
    local mrr byte
    mov mrr, 192 + 0
    add mrr, sourceReg
    mov [writeTo + 1], mrr

    mov [sizeOut], 2

    ret
IncReg endp


IncMem proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 0ffh

    ; mrr and sib
    ; REG = 000
    local mrr byte
    mov mrr, 0
    ; MOD and R/M, and SIB
    invoke EncodeMrrSib, memBaseReg, memScale, memIndexReg
    add mrr, al
    mov eax, writeTo
    mov [eax + 1], mrr

    .if cl == 0
        mov edx, 2
    .else if cl == 1
        mov [eax + 2], bl
        mov edx, 3
    .else
        invoke ExitProcess, 1

    mov ecx, memDisplacement
    mov dword ptr [eax + edx], ecx
    add edx, 4
    mov [sizeOut], edx

    ret
IncMem endp