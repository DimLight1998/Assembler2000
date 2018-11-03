include ../EncoderUtils.inc
.code
RetOnly proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    mov eax, writeTo
    mov byte ptr [eax], 0c3h
    mov eax, sizeOut
    mov dword ptr [eax], 1
    
    ret
RetOnly endp
end