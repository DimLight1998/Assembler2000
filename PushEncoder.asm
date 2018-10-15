.386
.model flat, stdcall
option casemap:none

include EncoderUtils.inc

; we only allow pushing eax/ebx/ecx/edx/esi/edi/esp/ebp
PushReg proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 0ffh

    ; mrr
    ; MOD = 11, R/M on sourceReg
    ; REG = 110 to enable PUSH, set to other value will not be PUSH
    local mrr byte
    mov mrr, 192 + 48
    add mrr, sourceReg
    mov [writeTo + 1], mrr

    mov [sizeOut], 2
    
    ret
PushReg endp


PushMem proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 0ffh

    ; mrr and sib
    ; REG = 110
    local mrr byte
    mov mrr, 48
    ; MOD and R/M, and SIB
    invoke EncodeMrrSib, memBaseReg, memScale, memIndexReg
    add mrr, al
    mov eax, writeTo
    mov [eax + 1], mrr

    .if cl == 0
        mov edx, 2
    .else if cl == 1
        mov [eax + 2], bl
        mov edx, 3
    .else
        invoke ExitProcess, 1

    mov ecx, memDisplacement
    mov dword ptr [eax + edx], ecx
    add edx, 4
    mov [SizeOut], edx
    
    ret
PushMem endp


PushImm proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte

    ; opcode
    mov [writeTo], 68h

    ; followed by immediateValue, immediatly
    mov eax, writeTo
    mov byte ptr [eax + 1], immediateValue
    mov [sizeOut], 5

    ret
PushImm endp