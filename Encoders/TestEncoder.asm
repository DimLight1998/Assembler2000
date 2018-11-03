include ../EncoderUtils.inc
.code
; test reg1, reg2
; reg1 is destinationReg, reg2 is sourceReg
TestRegReg proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    local mrr: byte
    local sib: byte

    ; size of the code will be stored in ebx

    ; get opcode
    mov eax, writeTo
    mov byte ptr [eax], 085h

    ; get mrr and sib, mrr is for 'MOD-REG-R/M'
    mov mrr, 0
    mov sib, 0
    ; set up REG
    ; opcode = 85h, Reg = destination
    invoke RegInMemRegRmValue, destinationReg
    add mrr, al
    ; MOD = 11, R/M = sourceReg
    add mrr, 192
    mov ecx, sourceReg
    add mrr, cl
    ; write mrr
	mov bl, mrr
    mov eax, writeTo
    mov byte ptr [eax + 1], bl
    
    ; this operation always has only 2 bytes
    mov eax, sizeOut
    mov dword ptr [eax], 2

    ret
TestRegReg endp

;OK
TestMemReg proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    local mrr: byte
    ; opcode
    mov eax, writeTo
    mov byte ptr [eax], 85h

    ; get mrr and sib, mrr is for 'MOD-REG-R/M'
    mov mrr, 0
    ; set up REG
    invoke RegInMemRegRmValue, sourceReg
    add mrr, al

    invoke EncodeMrrSib, memBaseReg, memScale, memIndexReg
    add mrr, al
    mov eax, writeTo
	mov dl, mrr
    mov byte ptr [eax + 1], dl
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
    mov eax, sizeOut
    mov dword ptr [eax], edx

    ret
TestMemReg endp

TestRegImm proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    local opcode: byte
    local mrr: byte

    ; size of the code will be stored in ebx
    ; get opcode
    ; always use 81 for simplicity
    mov eax, writeTo
    mov byte ptr [eax], 0F7h

    ; get mrr, mrr is for 'MOD-REG-R/M'
    mov mrr, 0

    ; MOD = 11, REG = 000, R/M = destinationReg
    add mrr, 192
    add mrr, 0
	mov ebx, destinationReg
    add mrr, bl
	mov cl, mrr
	mov ebx, writeTo
    mov byte ptr [ebx + 1], cl
    mov ebx, 2

    ; set up constant
    mov ecx, immediateValue
    mov eax, writeTo
    mov dword ptr [eax + ebx], ecx

    add ebx, 4
    mov eax, sizeOut
    mov dword ptr [eax], ebx

    ret
TestRegImm endp

TestMemImm proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    local mrr: byte

    ; opcode
    mov eax, writeTo
    mov byte ptr [eax], 0F7h

    ; get mrr and sib, mrr is for 'MOD-REG-R/M'
    mov mrr, 0
    ; set up REG
    ; REG = 000
    add mrr, 0
    
    invoke EncodeMrrSib, memBaseReg, memScale, memIndexReg
    add mrr, al
    mov eax, writeTo
	mov dl, mrr
    mov byte ptr [eax + 1], dl
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

    mov eax, sizeOut
    mov dword ptr [eax], edx
    
    ret
TestMemImm endp
end