.386
.model flat, stdcall
option casemap:none

include EncoderUtils.inc

PopReg proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 8fh

    ; mrr
    ; MOD = 11, R/M is destinationReg
    ; REG = 000 to use PUSH
    ; use eax to store mrr
    mov eax, 192
    add eax, destinationReg

    mov [writeTo + 1], eax
    mov [sizeOut], 2

    ret
PopReg endp


PopMem proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 8fh

    ; mrr
    ; REG = 000 to use PUSH
    local mrr byte
    mov mrr, 0

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

    ; set up displacement
    mov ecx, memDisplacement
    mov dword ptr [eax + edx], ecx
    add edx, 4
    mov [sizeOut], edx

    ret
PopMem endp