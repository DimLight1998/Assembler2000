; main.asm

.386
.model flat, stdcall
option casemap:none

include g:\masm32\include\windows.inc
include g:\masm32\include\kernel32.inc
include g:\masm32\include\user32.inc
include g:\masm32\include\masm32.inc
include g:\masm32\include\msvcrt.inc
includelib g:\masm32\lib\kernel32.lib
includelib g:\masm32\lib\user32.lib
includelib g:\masm32\lib\masm32.lib
includelib g:\masm32\lib\msvcrt.lib



.data
    dosStub label byte
        byte 04Dh, 05Ah             ; MZ signature
        byte 58 dup(000h)           ; unimportant fields
        byte 0B0h, 000h, 000h, 000h ; address of new exe header
        byte 112 dup(000h)          ; empty stub program
    dosStubSize = ($ - dosStub) / type dosStub

    peHeader label byte
    peHeaderSignature label byte 
        byte 050h, 045h, 000h, 000h
    peHeaderFileHeader label byte 
        byte 04ch, 001h, 003h, 000h ; machine code and number of sections, we only support three sections
        byte 000h, 000h, 000h, 000h ; timestamp, ignored
        byte 000h, 000h, 000h, 000h ; pointer to symbol table, N/A
        byte 000h, 000h, 000h, 000h ; number of symbols, N/A
        byte 0e0h, 000h, 002h, 000h ; size of optional header and characteristic, all fixed
    peHeaderOptionalHeader label byte
        byte 00bh, 001h, 000h, 000h ; magic number and linker version
        byte 000h, 000h, 000h, 000h ; size of code, ignored
        byte 000h, 000h, 000h, 000h ; size of initialized data, ignored
        byte 000h, 000h, 000h, 000h ; size of uninitialized data, ignored
        byte 000h, 010h, 000h, 000h ; entry of code, fixed to 0x1000, which is page 1
        byte 000h, 000h, 000h, 000h ; base of code, ignored
        byte 000h, 000h, 000h, 000h ; base of data, ignored
        byte 000h, 000h, 040h, 000h ; image base, fixed to 0x400000
        byte 000h, 010h, 000h, 000h ; section alignment, 0x1000 which is 4KB
        byte 000h, 002h, 000h, 000h ; file alignment, 0x200 which is 512B
        byte 000h, 000h, 000h, 000h ; operating system version
        byte 000h, 000h, 000h, 000h ; image version
        byte 004h, 000h, 000h, 000h ; sub system version, fixed to 0x4
        byte 000h, 000h, 000h, 000h ; win32 version, reserved
        sizeOfImageDecideLater label byte
        byte    ?,    ?,    ?,    ? ; size of image, decide later
        byte 000h, 004h, 000h, 000h ; size of headers, fixed
        byte 000h, 000h, 000h, 000h ; checksum, set to 0
        byte 003h, 000h, 000h, 000h ; subsystem (set to console) and dll info
        byte 000h, 040h, 000h, 000h ; reserved stack size
        byte 000h, 000h, 000h, 000h ; committed stack size
        byte 000h, 040h, 000h, 000h ; reserved heap size
        byte 000h, 000h, 000h, 000h ; committed heap size
        byte 000h, 000h, 000h, 000h ; loader flags
        byte 010h, 000h, 000h, 000h ; number of RVA and sizes
        imageDataDirectory label byte
        byte 000h, 000h, 000h, 000h
        byte 000h, 000h, 000h, 000h ; imageDataDirectory zeroth entry
        imageDataDirectoryFirstEntryDecideLater label byte
        byte    ?,    ?,    ?,    ? ; 
        byte    ?,    ?,    ?,    ? ; imageDataDirectory first entry
        byte 112 dup(000h)          ; other entries, 14 in total
    peHeaderSize = ($ - peHeader) / type peHeader

    sectionTable label byte
        ; section for .text
        byte ".text", 0, 0, 0       ; name
        byte 000h, 000h, 000h, 000h ; size of the section, ignored
        textRvaDecideLater label byte
        byte    ?,    ?,    ?,    ? ; RVA of the section, decide later
        textRawDataSizeDecideLater label byte
        byte    ?,    ?,    ?,    ? ; size of raw data in file, aligned, decide later
        textRawDataOffsetDicideLater label byte
        byte    ?,    ?,    ?,    ? ; offset of raw data in file, aligned, decide later
        byte 000h, 000h, 000h, 000h ; pointer to relocations, ignored
        byte 000h, 000h, 000h, 000h ; pointer to line numbers, ignored
        byte 000h, 000h, 000h, 000h ; number of relocations and line numbers, ignored
        byte 020h, 000h, 000h, 060h ; for .text
        ; section for .rdata
        byte ".rdata", 0, 0         ; name
        byte 000h, 000h, 000h, 000h ; size of the section, ignored
        rdataRvaDecideLater label byte
        byte    ?,    ?,    ?,    ? ; RVA of the section, decide later
        rdataRawDataSizeDecideLater label byte
        byte    ?,    ?,    ?,    ? ; size of raw data in file, aligned, decide later
        rdataRawDataOffsetDicideLater label byte
        byte    ?,    ?,    ?,    ? ; offset of raw data in file, aligned, decide later
        byte 000h, 000h, 000h, 000h ; pointer to relocations, ignored
        byte 000h, 000h, 000h, 000h ; pointer to line numbers, ignored
        byte 000h, 000h, 000h, 000h ; number of relocations and line numbers, ignored
        byte 040h, 000h, 000h, 040h ; for .rdata
        ; section for .data
        byte ".data", 0, 0, 0       ; name
        byte 000h, 000h, 000h, 000h ; size of the section, ignored
        dataRvaDecideLater label byte
        byte    ?,    ?,    ?,    ? ; RVA of the section, decide later
        dataRawDataSizeDecideLater label byte
        byte    ?,    ?,    ?,    ? ; size of raw data in file, aligned, decide later
        dataRawDataOffsetDicideLater label byte
        byte    ?,    ?,    ?,    ? ; offset of raw data in file, aligned, decide later
        byte 000h, 000h, 000h, 000h ; pointer to relocations, ignored
        byte 000h, 000h, 000h, 000h ; pointer to line numbers, ignored
        byte 000h, 000h, 000h, 000h ; number of relocations and line numbers, ignored
        byte 040h, 000h, 000h, 0c0h ; for .data
    sectionTableSize = ($ - sectionTable) / type sectionTable

    headerPadding label byte
        byte 480 dup(00h)
    headerPaddingSize = ($ - headerPadding) / type headerPadding
    fileName byte "a.exe", 0
.code

GetSourceFile proc
    
GetSourceFile endp

Main proc
    local fileHandle: dword

    invoke GetCommandLine
    invoke MessageBox, NULL, eax, addr szCaption, MB_OK

    invoke CreateFile, addr fileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
    mov fileHandle, eax

    ; generate header
    invoke WriteFile, fileHandle, addr dosStub, dosStubSize, ebx, 0
    invoke WriteFile, fileHandle, addr peHeader, peHeaderSize, ebx, 0
    invoke WriteFile, fileHandle, addr sectionTable, sectionTableSize, ebx, 0
    invoke WriteFile, fileHandle, addr headerPadding, headerPaddingSize, ebx, 0

    ; generate text section
    
    
    ; generate rdata section

    ; generate data section

    invoke CloseHandle, eax
    invoke ExitProcess, 0
Main endp

end Main