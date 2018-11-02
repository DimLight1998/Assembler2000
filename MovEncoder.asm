.386
.model flat, stdcall
option casemap:none

include EncoderUtils.inc

.code
MovMemReg proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    local mrr: byte

    ; opcode
    mov byte ptr [writeTo], 089h

    ; get mrr and sib, mrr is for 'MOD-REG-R/M'
    mov mrr, 0
    ; set up REG
    invoke RegInMemRegRmValue, sourceReg
    add mrr, al
    
    invoke EncodeMrrSib, memBaseReg, memScale, memIndexReg
    add mrr, al
    mov eax, writeTo
    mov bl, mrr
    mov byte ptr [eax + 1], bl
    .if cl == 0
        mov edx, 2
    .elseif cl == 1
        mov byte ptr [eax + 2], bl
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
MovMemReg endp


MovRegReg proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; size of the code will be stored in ebx

    ; get opcode
    local mrr: byte
    local sib: byte
    ; write opcode
    mov byte ptr [writeTo], 08Bh

    ; get mrr and sib, mrr is for 'MOD-REG-R/M'
    mov mrr, 0
    mov sib, 0
    ; set up REG
    invoke RegInMemRegRmValue, destinationReg
    add mrr, al
    ; MOD = 11, R/M = sourceReg
    add mrr, 192
    mov ecx, sourceReg
    add mrr, cl
    ; write mrr
    mov bl, mrr
    mov byte ptr [writeTo + 1], bl
    
    ; this operation always has only 2 bytes
    mov [sizeOut], 2

    ret
MovRegReg endp


MovRegMem proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    local mrr: byte

    ; opcode
    mov byte ptr [writeTo], 08Bh

    ; get mrr and sib, mrr is for 'MOD-REG-R/M'
    mov mrr, 0
    ; set up REG
    invoke RegInMemRegRmValue, destinationReg
    add mrr, al
    
    invoke EncodeMrrSib, memBaseReg, memScale, memIndexReg
    add mrr, al
    mov eax, writeTo
    mov bl, mrr
    mov byte ptr [eax + 1], bl
    .if cl == 0
        mov edx, 2
    .elseif cl == 1
        mov byte ptr [eax + 2], bl
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
MovRegMem endp


MovRegImm proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; size of the code will be stored in ebx

    ; get opcode
    local mrr: byte

    ; write opcode
    mov byte ptr [writeTo], 0C7h

    ; get mrr, mrr is for 'MOD-REG-R/M'
    mov mrr, 0

    ; MOD = 11, REG = 000, R/M = destinationReg
    add mrr, 192
    mov ebx, destinationReg
    add mrr, bl
    mov bl, mrr
    mov byte ptr [writeTo + 1], bl
    mov ebx, 2

    ; set up constant
    mov ecx, immediateValue
    mov dword ptr [writeTo + ebx], ecx

    add ebx, 4
    mov [sizeOut], ebx

    
    ret
MovRegImm endp


MovMemImm proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    local mrr: byte

    ; opcode
    mov byte ptr [writeTo], 0C7h

    ; get mrr and sib, mrr is for 'MOD-REG-R/M'
    mov mrr, 0
    ; set up REG
    ; REG = 000
    
    invoke EncodeMrrSib, memBaseReg, memScale, memIndexReg
    add mrr, al
    mov eax, writeTo
    mov bl, mrr
    mov byte ptr [eax + 1], bl
    .if cl == 0
        mov edx, 2
    .elseif cl == 1
        mov byte ptr [eax + 2], bl
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
MovMemImm endp
end