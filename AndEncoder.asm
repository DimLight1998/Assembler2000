.386
.model flat, stdcall
option casemap:none

include EncoderUtils.inc


AndMemReg proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 21h

    ; get mrr and sib, mrr is for 'MOD-REG-R/M'
    local mrr: byte
    mov mrr, 0
    ; set up REG
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

    ; set up displacement
    mov ecx, memDisplacement
    mov dword ptr [eax + edx], ecx
    add edx, 4
    mov [sizeOut], edx

    ret
AndMemReg endp


AndRegReg proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; size of the code will be stored in ebx

    ; get opcode
    local opcode: byte
    mov opcode, 023h
    ; write opcode
    mov [writeTo], opcode

    ; get mrr and sib, mrr is for 'MOD-REG-R/M'
    local mrr: byte
    mov mrr, 0
    local sib: byte
    mov sib, 0
    ; set up REG
    ; opcode = 23h, Reg = destination
    invoke RegInMemRegRmValue, destinationReg
    add mrr, al
    ; MOD = 11, R/M = sourceReg
    add mrr, 192
    mov ecx, sourceReg
    add mrr, ecx
    ; write mrr
    mov [writeTo + 1], mrr
    
    ; this operation always has only 2 bytes
    mov [sizeOut], 2

    ret
AndRegReg endp


AndRegMem proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 023h

    ; get mrr and sib, mrr is for 'MOD-REG-R/M'
    local mrr: byte
    mov mrr, 0
    ; set up REG
    invoke RegInMemRegRmValue, destinationReg
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

    ; set up displacement
    mov ecx, memDisplacement
    mov dword ptr [eax + edx], ecx
    add edx, 4
    mov [sizeOut], edx

    ret
AndRegMem endp


AndRegImm proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; size of the code will be stored in ebx

    ; get opcode
    local opcode: byte

    ; always use 81 for simplicity
    mov opcode, 081h

    ; write opcode
    mov [writeTo], opcode

    ; get mrr, mrr is for 'MOD-REG-R/M'
    local mrr: byte
    mov mrr, 0

    ; MOD = 11, REG = 100, R/M = destinationReg
    add mrr, 192
    add mrr, 32
    add mrr, destinationReg
    mov [writeTo + 1], mrr
    mov ebx, 2

    ; set up constant
    mov ecx, immediateValue
    mov dword ptr [writeTo + ebx], ecx

    add ebx, 4
    mov [sizeOut], ebx

    
    ret
AndRegImm endp


AndMemImm proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 081h

    ; get mrr and sib, mrr is for 'MOD-REG-R/M'
    local mrr: byte
    mov mrr, 0
    ; set up REG
    ; REG = 100
    add mrr, 32
    
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

    ; set up displacement
    mov ecx, memDisplacement
    mov dword ptr [eax + edx], ecx
    add edx, 4

    ; set up immediateValue
    mov ecx, immediateValue
    mov dword ptr [eax + edx], ecx
    add edx, 4
    mov [sizeOut], edx
    
    ret
AndMemImm endp