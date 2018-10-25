.386
.model flat, stdcall
option casemap:none

; return the value of REG in MEM-REG-R/M in al
RegInMemRegRmValue proc, reg: dword
    .if reg == 0
        mov al, 0
    .elseif reg == 1
        mov al, 8
    .elseif reg == 2
        mov al, 16
    .elseif reg == 3
        mov al, 24
    .elseif reg == 4
        mov al, 32
    .elseif reg == 5
        mov al, 40
    .elseif reg == 6
        mov al, 48
    .elseif reg == 7
        mov al, 56
    .else
        ; reg should be in [0, 8)
        invoke ExitProcess, 1
    .endif

    ret
RegInMemRegRmValue endp

; return the value of scale in SIB in al
ScaleInSibValue proc, scale: dword
    .if scale == 1
        mov al, 0
    .elseif scale == 2
        mov al, 64
    .elseif scale == 4
        mov al, 128
    .elseif scale == 8
        mov al, 192
    .else
        ; scale should be in {1, 2, 4, 8}
        invoke ExitProcess, 1
    .endif
    ret
ScaleInSibValue endp


; return the value of index in SIB in al
; index equal to 100 is illegal when use this function
IndexInSibValue proc, index: dword
    .if index == 0
        mov al, 0
    .elseif index == 1
        mov al, 8
    .elseif index == 2
        mov al, 16
    .elseif index == 3
        mov al, 24
    .elseif index == 4
        ; index equal to 100 is illegal when use this function
        invoke ExitProcess, 1
    .elseif index == 5
        mov al, 40
    .elseif index == 6
        mov al, 48
    .elseif index == 7
        mov al, 56
    .else
        ; index should be in [0, 8)
        invoke ExitProcess, 1
    .endif
    ret
IndexInSibValue endp


; return MRR in al, note that you need to deal with REG yourself because I have no information
; return SIB in bl
; return whether SIB is used in cl, 0 for not used, 1 for used
EncodeMrrSib proc, memBaseReg: dword, memScale: dword, memIndexReg: dword

    local mrr byte
    local sib byte
    mov mrr, 0
    mov sib, 0

    mov al, 0
    mov bl, 0
    mov cl, 0

    .if memBaseReg == -1 && memIndexReg == -1
        ; displacement only
        ; MOD = 00, R/M = 101
        add mrr, 0 + 5

        mov cl, 0
    .elseif memBaseReg != -1 && memIndexReg == -1
        ; base + displacement, use SIB, set index to 100
        ; MOD = 10, R/M = 100
        add mrr, 128 + 4
        ; scale = 00, index = 100
        add sib, 0 + 32
        mov eax, memBaseReg
        add sib, al

        mov cl, 1
    .elseif memBaseReg == -1 && memIndexReg != -1
        ; index * scale + displacement
        ; MOD = 00, R/M = 100
        add mrr, 0 + 4
        ; scale is memScale, index is memIndexReg, base = 101
        mov eax, 0
        invoke ScaleInSibValue, memScale
        add mrr, al
        mov eax, 0
        invoke IndexInSibValue, memIndex
        add mrr, al
        add mrr, 5

        mov cl, 1
    .elseif memBaseReg != -1 && memIndexReg != -1
        ; base + index * scale + displacement
        ; MOD = 10, R/M = 100
        add mrr, 128 + 4
        ; scale is memScale
        mov eax, 0
        invoke ScaleInSibValue, memScale
        add sib, al
        ; index is memIndexReg
        mov eax, 0
        invoke IndexInSibValue, memIndexReg
        add sib, al
        ; base = memBaseReg
        mov eax, memBaseReg
        add sib, al

        mov cl, 1
    .else
        invoke ExitProcess, 1

    mov eax, 0
    mov ebx, 0

    mov al, mrr
    mov bl, sib

    ret
EncodeMrrSib endp