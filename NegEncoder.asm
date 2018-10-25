.386
.model flat, stdcall
option casemap:none

include EncoderUtils.inc

NegReg proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 0f7h

    ; mrr
    ; MOD = 11, R/M on sourceReg
    ; REG = 011 to enable NEG, set to other value will not be NEG
    local mrr byte
    mov mrr, 192 + 24
    add mrr, sourceReg
    mov [writeTo + 1], mrr

    mov [sizeOut], 2

    ret
NegReg endp


NegMem proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 0f7h

    ; mrr and sib
    ; REG = 011
    local mrr byte
    mov mrr, 24
    ; MOD and R/M, and SIB
    invoke EncodeMrrSib, memBaseReg, memScale, memIndexReg
    add mrr, al
    mov eax, writeTo
    mov [eax + 1], mrr

    .if cl == 0
        mov edx, 2
    .elseif cl == 1
        mov [eax + 2], bl
        mov edx, 3
    .else
        invoke ExitProcess, 1
    .endif

    mov ecx, memDisplacement
    mov dword ptr [eax + edx], ecx
    add edx, 4
    mov [sizeOut], edx

    ret
NegMem endp