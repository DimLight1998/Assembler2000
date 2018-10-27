.386
.model flat, stdcall
option casemap:none

include EncoderUtils.inc

; test reg1, reg2
; reg1 is destinationReg, reg2 is sourceReg
TestRegReg proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 85h

    ; REG
    local mrr: byte
    mov mrr, 0

    ; REG = sourceReg
    invoke RegInMemRegRmValue, sourceReg
    add mrr, al

    ; MOD = 11, R/M = destinationReg
    add mrr, 192
    mov ecx, destinationReg
    add mrr, ecx
    mov [writeTo + 1], mrr

    mov [sizeOut], 2

    ret
TestRegReg endp

TestMemReg proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 85h

    ; REG = sourceReg
    local mrr: byte
    mov mrr, 0
    invoke RegInMemRegRmValue, sourceReg
    add mrr, al

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
TestMemReg endp

TestRegImm proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 0f7h

    ; MOD = 11, REG = 000, R/M = destinationReg
    local mrr: byte
    mov mrr, 192 + 0
    add mrr, destinationReg
    mov [writeTo + 1], mrr
    mov ebx, 2

    mov ecx, immediateValue
    mov dword ptr [writeTo + ebx], ecx

    add ebx, 4
    mov [sizeOut], ebx

    ret
TestRegImm endp

TestMemImm proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 0f7h

    ; REG = 000
    invoke EncodeMrrSib, memBaseReg, memScale, memIndexReg
    mov edx, writeTo
    mov [edx + 1], al
    .if cl == 0
        mov eax, 2
    .elseif cl == 1
        mov [edx + 2], bl
        mov eax, 3
    .else
        invoke ExitProcess, 1
    .endif

    mov ecx, memDisplacement
    mov dword ptr [edx + eax], ecx
    add eax, 4

    mov ecx, immediateValue
    mov dword ptr [edx + eax], ecx
    add eax, 4
    mov [sizeOut], eax
    
    ret
TestMemImm endp