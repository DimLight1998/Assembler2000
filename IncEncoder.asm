.386
.model flat, stdcall
option casemap:none

include EncoderUtils.inc
.code
; almost the same as PushReg
IncReg proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte
    local mrr: byte

    ; opcode
    mov byte ptr [writeTo], 0ffh

    ; mrr
    ; MOD = 11, R/M on sourceReg
    ; REG = 000 to enable INC, set to other value will not be INC
    mov mrr, 192 + 0
    mov eax, sourceReg
    add mrr, al
    mov bl, mrr
    mov byte ptr [writeTo + 1], bl

    mov [sizeOut], 2

    ret
IncReg endp


IncMem proc uses eax ebx ecx edx esi edi,
    memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword,
    immediateValue: dword, sourceReg: dword, destinationReg: dword,
    writeTo: ptr byte, sizeOut: ptr byte
    local mrr: byte

    ; opcode
    mov byte ptr [writeTo], 0ffh

    ; mrr and sib
    ; REG = 000
    mov mrr, 0
    ; MOD and R/M, and SIB
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

    mov ecx, memDisplacement
    mov dword ptr [eax + edx], ecx
    add edx, 4
    mov [sizeOut], edx

    ret
IncMem endp
end