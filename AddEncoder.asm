.386
.model flat, stdcall
option casemap:none

include EncoderUtils.inc


AddMemReg proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; size of the code will be stored in ebx

    ; get opcode
    local opcode: byte
    mov opcode, 01h
    ; write opcode
    mov [writeTo], opcode

    ; get mrr and sib, mrr is for 'MOD-REG-R/M'
    local mrr: byte
    mov mrr, 0
    local sib: byte
    mov sib, 0
    ; set up REG
    invoke RegInMemRegRmValue, sourceReg
    add mrr, al
    
    .if memBaseReg == -1 && memIndexReg == -1
        ; displacement only, won't open SIB
        ; MOD = 00, R/M = 101
        add mrr, 0
        add mrr, 5
        ; write mrr
        mov [writeTo + 1], mrr
        mov ebx, 2
    .else if memBaseReg != -1 && memIndexReg == -1
        ; base + displacement, we can use SIB mode and set index to 100
        ; MOD = 10, R/M = 100
        add mrr, 128
        add mrr, 4
        ; scale should be 00
        add sib, 0
        ; index should be 100
        add sib, 32
        ; base should be memBaseReg
        add sib, memBaseReg
        ; write mrr and sib
        mov [writeTo + 1], mrr
        mov [writeTo + 2], sib
        mov ebx, 3
    .else if memBaseReg == -1 && memIndexReg != -1
        ; index * scale + displacement
        ; MOD = 00, R/M = 100
        add mrr, 0
        add mrr, 4
        ; scale should be memScale
        invoke ScaleInSibValue, memScale
        add sib, al
        ; index should be memIndexReg
        invoke IndexInSibValue, memIndexReg
        add sib, al
        ; base should be zero, which is 101
        add sib, 5
        mov [writeTo + 1], mrr
        mov [writeTo + 2], sib
        mov ebx, 3
    .else
        ; base + index * scale + displacement
        ; MOD = 10, R/M = 100
        add mrr, 128
        add mrr, 4
        ; scale should be memScale
        invoke ScaleInSibValue, memScale
        add sib, al
        ; index should be memIndexReg
        invoke IndexInSibValue, memIndexReg
        add sib, al
        ; base should be memBaseReg
        add sib, memBaseReg
        mov [writeTo + 1], mrr
        mov [writeTo + 2], sib
        mov ebx, 3

    ; set up displacement
    mov ecx, memDisplacement
    mov dword ptr [writeTo + ebx], ecx
    add ebx, 4
    mov [sizeOut], ebx

    ret
AddMemReg endp


AddRegReg proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte


    ret
AddRegReg endp


AddRegMem proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    
    ret
AddRegMem endp


AddRegImm proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    
    ret
AddRegImm endp


AddMemImm proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    
    ret
AddMemImm endp