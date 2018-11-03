.386
.model flat, stdcall
option casemap:none

include EncoderUtils.inc

JzRel proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 0F84h

   ; followed by immediateValue, immediatly
    mov eax, writeTo
	mov ebx, immediateValue
    mov dword ptr [eax + 2], ebx
    mov eax, sizeOut
    mov dword ptr [eax], 6

    ret
JzRel endp