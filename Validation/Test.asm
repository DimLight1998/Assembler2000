.386
.model flat, stdcall
option casemap:none

include EncoderUtils.inc
include g:\masm32\include\windows.inc
include g:\masm32\include\kernel32.inc
include g:\masm32\include\masm32.inc
include g:\masm32\include\msvcrt.inc
includelib g:\masm32\lib\kernel32.lib
includelib g:\masm32\lib\masm32.lib
includelib g:\masm32\lib\msvcrt.lib

.data
    encoded byte 32 dup(?)
    encodedLength dword 0
    fileName byte "EC043F61423846589CCD3FB4A9ED58AD.out", 0
    fileHandler dword 0

    hh byte "%d",10, 0
.code

main proc
    ; invoke RetOnly, -1, 1, -1, 0, 0, -1, -1, addr encoded, addr encodedLength
    
    ;==========================================
    ; MEM
    ; 11335577
    ; invoke JmpMem, -1, 1, -1, 11335577h, 0, -1, -1, addr encoded, addr encodedLength

    ; 2 * ebx + 1223344
    ; invoke JmpMem, -1, 2, 3, 01223344h, 0, -1, -1, addr encoded, addr encodedLength

    ; ecx + 22334455
    ; invoke JmpMem, 1, 1, -1, 22334455h, 0, -1, -1, addr encoded, addr encodedLength

    ; esi + 8 * edi + abbccdd
    ; invoke JmpMem, 6, 8, 7, 00abbccddh, 0, -1, -1, addr encoded, addr encodedLength

    ;==========================================
    ; REG
    ; ebx
    ; invoke JmpReg, -1, 1, -1, 0, 0, 3, -1, addr encoded, addr encodedLength

    invoke JzRel, -1, 1, -1, 0, 11335577h, -1, -1, addr encoded, addr encodedLength

    ;===========================================
    ; MEM IMM
    ; 11335577, 22446688
    ; invoke XorMemImm, -1, 1, -1, 11335577h, 22446688h, -1, -1, addr encoded, addr encodedLength

    ; 2 * ebx + 1223344, 1234
    ; invoke XorMemImm, -1, 2, 3, 01223344h, 1234h, -1, -1, addr encoded, addr encodedLength

    ; ecx + 22334455, 9
    ; invoke XorMemImm, 1, 1, -1, 22334455h, 9h, -1, -1, addr encoded, addr encodedLength

    ; esi + 8 * edi + abbccdd, aabb7788
    ; invoke XorMemImm, 6, 8, 7, 00abbccddh, 0aabb7788h, -1, -1, addr encoded, addr encodedLength
    
    ;===========================================
    ; REG IMM
    ; eax, 12345678
    ; invoke XorRegImm, -1, 1, -1, 0, 12345678h, -1, 0, addr encoded, addr encodedLength
    ; esi, 3
    ; invoke XorRegImm, -1, 1, -1, 0, 3h, -1, 6, addr encoded, addr encodedLength
    ;===============================================
    ; MEM REG
    ; 11335577, esi
    ; invoke XorMemReg, -1, 1, -1, 11335577h, 0, 6, -1, addr encoded, addr encodedLength

    ; 2 * ebx + 1223344, esi
    ; invoke XorMemReg, -1, 2, 3, 01223344h, 0, 6, -1, addr encoded, addr encodedLength

    ; ecx + 22334455, esi
    ; invoke XorMemReg, 1, 1, -1, 22334455h, 0, 6, -1, addr encoded, addr encodedLength

    ; esi + 8 * edi + abbccdd, esi
    ; invoke XorMemReg, 6, 8, 7, 00abbccddh, 0, 6, -1, addr encoded, addr encodedLength

    ;===============================================
    ; REG MEM
    ; esi, 11335577
    ; invoke XorRegMem, -1, 1, -1, 11335577h, 0, -1, 6, addr encoded, addr encodedLength

    ; esi, 2 * ebx + 1223344
    ; invoke XorRegMem, -1, 2, 3, 01223344h, 0, -1, 6, addr encoded, addr encodedLength

    ; esi, ecx + 22334455
    ; invoke XorRegMem, 1, 1, -1, 22334455h, 0, -1, 6, addr encoded, addr encodedLength

    ; esi, esi + 8 * edi + abbccdd
    ; invoke XorRegMem, 6, 8, 7, 00abbccddh, 0, -1, 6, addr encoded, addr encodedLength

    ;===========================================
    ; REG REG
    ; edx, ecx
    ; invoke XorRegReg, -1, 1, -1, 0, 0, 1, 2, addr encoded, addr encodedLength

    ; esi, edi
    ; invoke XorRegReg, -1, 1, -1, 0, 0, 7, 6, addr encoded, addr encodedLength

    invoke CreateFile, addr fileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
    mov fileHandler, eax
    invoke WriteFile, fileHandler, addr encoded, encodedLength, ebx, 0
    mov eax, fileHandler
    invoke CloseHandle, eax
    invoke ExitProcess, 0
main endp

end main