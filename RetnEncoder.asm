.386
.model flat, stdcall
option casemap:none

include EncoderUtils.inc

RetOnly proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    mov [writeTo], 0c3h
    mov [sizeOut], 1
    
    ret
RetOnly endp