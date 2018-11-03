include EncoderUtils.inc
.data
  ha byte "%d", 10, 0
.code
CallMem proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte
    local mrr: byte

    ; opcode
    mov eax, writeTo
    mov byte ptr [eax], 0ffh

    ; mrr and sib
    ; REG = 010
    mov mrr, 16
    ; MOD and R/M, and SIB
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

    mov ecx, memDisplacement
    mov dword ptr [eax + edx], ecx
    add edx, 4
    mov eax, sizeOut
    mov dword ptr [eax], edx
    
    ret
CallMem endp
end