include EncoderUtils.inc
.data
  ha byte "%d", 10, 0
.code
MovRegReg proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte
    local mrr: byte
    local sib: byte

    ; size of the code will be stored in ebx

    ; get opcode
    mov eax, writeTo
    mov byte ptr [eax], 08Bh

    ; get mrr and sib, mrr is for 'MOD-REG-R/M'
    mov mrr, 0
    mov sib, 0
    ; set up REG
    ; opcode = 08Bh, Reg = destination
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
MovRegReg endp
end