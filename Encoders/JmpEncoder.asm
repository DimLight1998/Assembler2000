.386
.model flat, stdcall
option casemap:none

include EncoderUtils.inc

JmpRel proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 0E9h
    
   ; followed by immediateValue, immediatly
    mov eax, writeTo
	mov ebx, immediateValue
    mov dword ptr [eax + 1], ebx
    mov eax, sizeOut
    mov dword ptr [eax], 5

    ret
JmpRel endp

JmpReg proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 0ffh

    ; mrr
    ; MOD = 11, R/M on sourceReg
    ; REG = 100 to enable JMP, set to other value will not be JMP
    local mrr byte
    mov mrr, 192 + 32
    add mrr, sourceReg
    mov [writeTo + 1], mrr
    mov [sizeOut], 2
    ret
JmpReg endp

JmpMem proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 0ffh

    ; mrr and sib
    ; REG = 100
    local mrr byte
    mov mrr, 32
    ; MOD and R/M, and SIB
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
JmpMem endp