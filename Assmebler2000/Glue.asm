include common.inc
include Glue.inc
include LineControl.inc
include SymbolDict.inc

.data
	rdataBuffer byte 400000 dup(?)

	rdataBase dword 0
	dataBase dword 0

	dllCount dword 0
	functionCount dword 0

	numTextPage dword 0
	numRdataPage dword 0
	numDataPage dword 0

	textLength dword 0
	rdataLength dword 0
	dataLength dword 0

	importDirectoryTableBeginOffset dword 0
	importDirectoryTableEndOffset dword 0
.code

addBaseAddr proc sectionAddr: ptr Section, baseAddress: dword
	mov ecx, sectionAddr
	assume ecx: ptr Section
	lea esi, [ecx].labelTries
	mov eax, baseAddress
	.while esi != [ecx].currentTrie
		mov ebx, [esi]
		add (TrieNode ptr [ebx]).nodeVal, eax
		add esi, type dword
	.endw
	assume ecx: nothing
	ret
addBaseAddr endp

middleGlue proc uses esi edi ebx
.data
	sectionLengthPrompt byte "this section's length is %d byte(s)", 10, 0
	dllPrompt byte "dll %s: ", 10, 0
	symbolPrompt  byte "symbol %s", 10, 0
.code
	; get length
	getSectionLength textSection
	invoke crt_printf, addr sectionLengthPrompt, eax ; demo

	mov textLength, eax

	.if eax == 0
		mov eax, 1
	.endif
	.while eax > 1000h
		sub eax, 1000h
		inc numTextPage
	.endw
	.if eax > 0
		inc numTextPage
	.endif

	; set section's base address
	invoke addBaseAddr, addr textSection, 401000h ; demo prevbug: use initSection and clear all labelTries info
	invoke initSection, addr textSection, 401000h ; demo

	mov esi, offset externTries
	assume edi: ptr TrieNode
	.while esi != currentExtern
		mov edi, [esi]
		invoke crt_printf, addr dllPrompt, addr [edi].nodeStr
		mov edi, [edi].nodeVal
		.while edi
			invoke crt_printf, addr symbolPrompt, addr [edi].nodeStr
			mov edi, [edi].nodeVal
		.endw
		add esi, type dword
	.endw

	; calculate base address of rdata
	mov eax, numTextPage
	inc eax ; this is for page for header
	shl eax, 12
	mov rdataBase, eax
	; base address (RVA) of rdata in rdataBase

	; count dlls and functions
	mov esi, offset externTries
	assume edi: ptr TrieNode
	.while esi != currentExtern
		inc dllCount
		mov edi, [esi]
		mov edi, [edi].nodeVal
		.while edi
			inc functionCount
			mov edi, [edi].nodeVal
		.endw
		add esi, type dword
	.endw

	.data
		tableFunc1Pointer dword offset rdataBuffer
		tableDllPointer dword offset rdataBuffer
		tableFunc2Pointer dword offset rdataBuffer
		tableNamePointer dword offset rdataBuffer
	.code
	
	; move pointers to correct positions
	push ebx
	mov eax, dllCount
	add eax, functionCount
	shl eax, 2
	add tableDllPointer, eax
	mov ebx, tableDllPointer
	mov importDirectoryTableBeginOffset, ebx ; used in afterGlue

	mov eax, dllCount
	inc eax
	imul eax, 20
	add eax, tableDllPointer
	mov tableFunc2Pointer, eax
	mov ebx, tableFunc2Pointer
	mov importDirectoryTableEndOffset, ebx ; used in afterGlue

	mov eax, dllCount
	add eax, functionCount
	shl eax, 2
	add eax, tableFunc2Pointer
	mov tableNamePointer, eax
	pop ebx
	; pointers ready, action!
	push ecx
	push ebx
	mov esi, offset externTries
	assume edi: ptr TrieNode
	.while esi != currentExtern
		mov edi, [esi]
		mov edi, [edi].nodeVal

		; advance tableDllPointer
		mov eax, tableFunc2Pointer
		sub eax, offset rdataBuffer
		add eax, rdataBase
		mov ebx, tableDllPointer
		mov [ebx], eax
		add tableDllPointer, 4
		mov ebx, tableDllPointer
		mov dword ptr [ebx], 0
		add tableDllPointer, 4
		mov ebx, tableDllPointer
		mov dword ptr [ebx], 0
		add tableDllPointer, 4
		mov ebx, tableDllPointer
		mov dword ptr [ebx], 0 ; fill it later
		add tableDllPointer, 4
		mov eax, tableFunc1Pointer
		sub eax, offset rdataBuffer
		add eax, rdataBase
		mov ebx, tableDllPointer
		mov [ebx], eax

		.while edi
			; get rva
			mov eax, tableNamePointer
			sub eax, offset rdataBuffer
			add eax, rdataBase

			; advance tableFunc1Pointer
			mov ebx, tableFunc1Pointer
			mov [ebx], eax
			add tableFunc1Pointer, 4

			; advance tableFunc2Pointer
			mov ebx, tableFunc2Pointer
			mov [ebx], eax
			add tableFunc2Pointer, 4

			; advance tableNamePointer
			mov ebx, tableNamePointer
			mov word ptr [ebx], 0
			add tableNamePointer, 2	
			invoke crt_strlen, addr [edi].nodeStr
			inc eax
			push eax
			invoke crt_strcpy, tableNamePointer, addr [edi].nodeStr
			pop eax
			add tableNamePointer, eax
			mov ecx, 1
			and ecx, tableNamePointer
			.if ecx != 0
				mov ebx, tableNamePointer
				mov byte ptr [ebx], 0
				inc tableNamePointer
			.endif

			; advance edi
			mov edi, [edi].nodeVal
		.endw

		; advance tableFunc1Pointer
		mov ebx, tableFunc1Pointer
		mov dword ptr [ebx], 0
		add tableFunc1Pointer, 4

		; advance tableFunc2Pointer
		mov ebx, tableFunc2Pointer
		mov dword ptr [ebx], 0
		add tableFunc2Pointer, 4

		; set up tableDllPointer name field
		sub tableDllPointer, 4
		mov eax, tableNamePointer
		sub eax, offset rdataBuffer
		add eax, rdataBase
		mov ebx, tableDllPointer
		mov [ebx], eax
		add tableDllPointer, 8

		; advance tableNamePointer
		mov edi, [esi]
		invoke crt_strlen, addr [edi].nodeStr
		inc eax
		push eax
		invoke crt_strcpy, tableNamePointer, addr [edi].nodeStr
		pop eax
		add tableNamePointer, eax
		mov ecx, 1
		and ecx, tableNamePointer
		.if ecx != 0
			mov	ebx, tableNamePointer
			mov byte ptr [ebx], 0
			inc tableNamePointer
		.endif

		; advance esi
		add esi, type dword
	.endw
	pop ebx
	pop ecx

	; finally, insert an empty row to tableDllPointer
	mov eax, tableDllPointer
	mov dword ptr [eax], 0
	mov dword ptr [eax + 4], 0
	mov dword ptr [eax + 8], 0
	mov dword ptr [eax + 12], 0
	mov dword ptr [eax + 16], 0

	; fill the trie
	push ebx
	mov tableFunc1Pointer, offset rdataBuffer
	mov esi, offset externTries
	assume edi: ptr TrieNode
	.while esi != currentExtern
		mov edi, [esi]
		mov edi, [edi].nodeVal
		.while edi
			mov eax, tableFunc1Pointer
			sub eax, offset rdataBuffer
			add eax, rdataBase
			add tableFunc1Pointer, 4
			mov ebx, [edi].nodeVal
			add eax, 400000h
			mov [edi].nodeVal, eax
			mov edi, ebx
		.endw
		add tableFunc1Pointer, 4
		add esi, type dword
	.endw
	pop ebx

	; rdata ok, now calculate size
	mov eax, tableNamePointer
	sub eax, offset rdataBuffer

	mov rdataLength, eax

	.if eax == 0
		mov eax, 1
	.endif
	.while eax > 1000h
		inc numRdataPage
		sub eax, 1000h
	.endw
	.if eax > 0h
		inc numRdataPage
	.endif

	; calculate dataBase
	mov eax, numTextPage
	add eax, numRdataPage
	inc eax
	shl eax, 12
	mov dataBase, eax

	getSectionLength dataSection
	invoke crt_printf, addr sectionLengthPrompt, eax ; demo

	mov dataLength, eax

	push eax
	mov ebx, dataBase
	add ebx, 400000h
	invoke addBaseAddr, addr dataSection, ebx ; demo
	mov ebx, dataBase
	add ebx, 400000h
	invoke initSection, addr dataSection, ebx; demo
	pop eax

	.if eax == 0
		mov eax, 1
	.endif
	.while eax > 1000h
		sub eax, 1000h
		inc numDataPage
	.endw
	.if eax > 0
		inc numDataPage
	.endif
	
	assume edi: nothing
.code
	ret
middleGlue endp

.data
    dosStub label byte
        byte 04Dh, 05Ah             ; MZ signature
        byte 58 dup(000h)           ; unimportant fields
        byte 0B0h, 000h, 000h, 000h ; address of new exe header
        byte 112 dup(000h)          ; empty stub program
    dosStubSize = ($ - dosStub) / type dosStub

    peHeader label byte
	; 0xb0
    peHeaderSignature label byte 
        byte 050h, 045h, 000h, 000h
    peHeaderFileHeader label byte 
        byte 04ch, 001h, 003h, 000h ; machine code and number of sections, we only support three sections
        byte 000h, 000h, 000h, 000h ; timestamp, ignored
        byte 000h, 000h, 000h, 000h ; pointer to symbol table, N/A
	; 0xc0
        byte 000h, 000h, 000h, 000h ; number of symbols, N/A
        byte 0e0h, 000h, 002h, 000h ; size of optional header and characteristic, all fixed
    peHeaderOptionalHeader label byte
        byte 00bh, 001h, 000h, 000h ; magic number and linker version
        byte 000h, 000h, 000h, 000h ; size of code, ignored
	; 0xd0
        byte 000h, 000h, 000h, 000h ; size of initialized data, ignored
        byte 000h, 000h, 000h, 000h ; size of uninitialized data, ignored
        byte 000h, 010h, 000h, 000h ; entry of code, fixed to 0x1000, which is page 1
        byte 000h, 000h, 000h, 000h ; base of code, ignored
	; 0xe0
        byte 000h, 000h, 000h, 000h ; base of data, ignored
        byte 000h, 000h, 040h, 000h ; image base, fixed to 0x400000
        byte 000h, 010h, 000h, 000h ; section alignment, 0x1000 which is 4KB
        byte 000h, 002h, 000h, 000h ; file alignment, 0x200 which is 512B
	; 0xf0
        byte 000h, 000h, 000h, 000h ; operating system version
        byte 000h, 000h, 000h, 000h ; image version
        byte 004h, 000h, 000h, 000h ; sub system version, fixed to 0x4
        byte 000h, 000h, 000h, 000h ; win32 version, reserved
        sizeOfImageDecideLater label dword
	; 0x100
        byte    ?,    ?,    ?,    ? ; size of image, decide later
        byte 000h, 004h, 000h, 000h ; size of headers, fixed
        byte 000h, 000h, 000h, 000h ; checksum, set to 0
        byte 003h, 000h, 000h, 000h ; subsystem (set to console) and dll info
	; 0x110
        byte 000h, 040h, 000h, 000h ; reserved stack size
        byte 000h, 000h, 000h, 000h ; committed stack size
        byte 000h, 040h, 000h, 000h ; reserved heap size
        byte 000h, 000h, 000h, 000h ; committed heap size
	; 0x120
        byte 000h, 000h, 000h, 000h ; loader flags
        byte 010h, 000h, 000h, 000h ; number of RVA and sizes
        imageDataDirectory label byte
        byte 000h, 000h, 000h, 000h
        byte 000h, 000h, 000h, 000h ; imageDataDirectory zeroth entry
        imageDataDirectoryFirstEntryDecideLaterPart1 label dword
	; 0x130
        byte    ?,    ?,    ?,    ? ; 
		imageDataDirectoryFirstEntryDecideLaterPart2 label dword
        byte    ?,    ?,    ?,    ? ; imageDataDirectory first entry
        byte 112 dup(000h)          ; other entries, 14 in total
    peHeaderSize = ($ - peHeader) / type peHeader

    sectionTable label byte
        ; section for .text
        byte ".text", 0, 0, 0       ; name
        byte 000h, 000h, 000h, 000h ; size of the section, ignored
        textRvaDecideLater label dword
        byte    ?,    ?,    ?,    ? ; RVA of the section, decide later
        textRawDataSizeDecideLater label dword
        byte    ?,    ?,    ?,    ? ; size of raw data in file, aligned, decide later
        textRawDataOffsetDicideLater label dword
        byte    ?,    ?,    ?,    ? ; offset of raw data in file, aligned, decide later
        byte 000h, 000h, 000h, 000h ; pointer to relocations, ignored
        byte 000h, 000h, 000h, 000h ; pointer to line numbers, ignored
        byte 000h, 000h, 000h, 000h ; number of relocations and line numbers, ignored
        byte 020h, 000h, 000h, 060h ; for .text
        ; section for .rdata
        byte ".rdata", 0, 0         ; name
        byte 000h, 000h, 000h, 000h ; size of the section, ignored
        rdataRvaDecideLater label dword
        byte    ?,    ?,    ?,    ? ; RVA of the section, decide later
        rdataRawDataSizeDecideLater label dword
        byte    ?,    ?,    ?,    ? ; size of raw data in file, aligned, decide later
        rdataRawDataOffsetDicideLater label dword
        byte    ?,    ?,    ?,    ? ; offset of raw data in file, aligned, decide later
        byte 000h, 000h, 000h, 000h ; pointer to relocations, ignored
        byte 000h, 000h, 000h, 000h ; pointer to line numbers, ignored
        byte 000h, 000h, 000h, 000h ; number of relocations and line numbers, ignored
        byte 040h, 000h, 000h, 040h ; for .rdata
        ; section for .data
        byte ".data", 0, 0, 0       ; name
        byte 000h, 000h, 000h, 000h ; size of the section, ignored
        dataRvaDecideLater label dword
        byte    ?,    ?,    ?,    ? ; RVA of the section, decide later
        dataRawDataSizeDecideLater label dword
        byte    ?,    ?,    ?,    ? ; size of raw data in file, aligned, decide later
        dataRawDataOffsetDicideLater label dword
        byte    ?,    ?,    ?,    ? ; offset of raw data in file, aligned, decide later
        byte 000h, 000h, 000h, 000h ; pointer to relocations, ignored
        byte 000h, 000h, 000h, 000h ; pointer to line numbers, ignored
        byte 000h, 000h, 000h, 000h ; number of relocations and line numbers, ignored
        byte 040h, 000h, 000h, 0c0h ; for .data
    sectionTableSize = ($ - sectionTable) / type sectionTable

    headerPadding label byte
        byte 480 dup(00h)
    headerPaddingSize = ($ - headerPadding) / type headerPadding

	zero byte 0, 0, 0
.code


.data
	cannotOpenOutput byte "cannot open output file: %s", 10, 0
.code
afterGlue proc uses eax ebx ecx edx esi edi
	; write the content of textSection and dataSection to the output PE file
	local fileHandle: dword
	local numTextPageInFile: dword
	local numRdataPageInFile: dword
	local numDataPageInFile: dword

    invoke CreateFile, addr outFileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
    mov fileHandle, eax
	.if !fileHandle
		invoke crt_printf, addr cannotOpenOutput, addr outFileName
		ret
	.endif

    ; generate header
	mov eax, dosStubSize
    invoke WriteFile, fileHandle, addr dosStub, eax, ebx, 0
	mov eax, peHeaderSize
    invoke WriteFile, fileHandle, addr peHeader, eax, ebx, 0
	mov eax, sectionTableSize
    invoke WriteFile, fileHandle, addr sectionTable, eax, ebx, 0
	mov eax, headerPaddingSize
    invoke WriteFile, fileHandle, addr headerPadding, eax, ebx, 0

    ; generate text section
	getSectionLength textSection
	mov edi, eax
	invoke WriteFile, fileHandle, addr textSection.sectionContent, edi, ebx, 0
	; padding
	mov numTextPageInFile, 0

	.if edi == 0
		mov edx, 200h
		.while edx > 0
			push edx
			invoke WriteFile, fileHandle, addr zero, 1, ebx, 0
			pop edx
			dec edx
		.endw
		inc numTextPageInFile
	.else
		.while edi > 200h
			inc numTextPageInFile
			sub edi, 200h
		.endw
		.if edi > 0
			mov edx, 200h
			sub edx, edi
			.while edx > 0
				push edx
				invoke WriteFile, fileHandle, addr zero, 1, ebx, 0
				pop edx
				dec edx
			.endw
			inc numTextPageInFile
		.endif
	.endif
	
    ; generate rdata section
	invoke WriteFile, fileHandle, addr rdataBuffer, rdataLength, ebx, 0
	; padding
	mov numRdataPageInFile, 0
	mov edi, rdataLength
	.while edi > 200h
		inc numRdataPageInFile
		sub edi, 200h
	.endw
	.if edi > 0
		mov edx, 200h
		sub edx, edi
		.while edx > 0
			push edx
			invoke WriteFile, fileHandle, addr zero, 1, ebx, 0
			pop edx
			dec edx
		.endw
		inc numRdataPageInFile
	.endif

    ; generate data section
	getSectionLength dataSection
	mov edi, eax
	invoke WriteFile, fileHandle, addr dataSection.sectionContent, edi, ebx, 0
	; padding
	mov numDataPageInFile, 0

	.if edi == 0
		mov edx, 200h
		.while edx > 0
			push edx
			invoke WriteFile, fileHandle, addr zero, 1, ebx, 0
			pop edx
			dec edx
		.endw
		inc numDataPageInFile
	.else
		.while edi > 200h
			inc numDataPageInFile
			sub edi, 200h
		.endw
		.if edi > 0
			mov edx, 200h
			sub edx, edi
			.while edx > 0
				push edx
				invoke WriteFile, fileHandle, addr zero, 1, ebx, 0
				pop edx
				dec edx
			.endw
			inc numDataPageInFile
		.endif
	.endif

	; fill header holes

	; size of image
	mov eax, 0
	add eax, numTextPage
	add eax, numRdataPage
	add eax, numDataPage
	inc eax ; this is for header
	shl eax, 12
	mov sizeOfImageDecideLater, eax

	; import directory table and its size
	mov eax, importDirectoryTableBeginOffset
	sub eax, offset rdataBuffer
	add eax, rdataBase
	mov imageDataDirectoryFirstEntryDecideLaterPart1, eax
	mov eax, importDirectoryTableEndOffset
	sub eax, importDirectoryTableBeginOffset
	mov imageDataDirectoryFirstEntryDecideLaterPart2, eax

	; text holes
	mov eax, 1
	shl eax, 12
	mov textRvaDecideLater, eax
	mov eax, numTextPageInFile
	imul eax, 200h
	mov textRawDataSizeDecideLater, eax
	mov textRawDataOffsetDicideLater, 400h

	; rdata holes
	mov eax, 1
	add eax, numTextPage
	shl eax, 12
	mov rdataRvaDecideLater, eax 
	mov eax, numRdataPageInFile
	imul eax, 200h
	mov rdataRawDataSizeDecideLater, eax
	mov eax, 2
	add eax, numTextPageInFile
	imul eax, 200h
	mov rdataRawDataOffsetDicideLater, eax

	; data holes
	mov eax, 1
	add eax, numTextPage
	add eax, numRdataPage
	shl eax, 12
	mov dataRvaDecideLater, eax 
	mov eax, numDataPageInFile
	imul eax, 200h
	mov dataRawDataSizeDecideLater, eax
	mov eax, 2
	add eax, numTextPageInFile
	add eax, numRdataPageInFile
	imul eax, 200h
	mov dataRawDataOffsetDicideLater, eax

	; rewrite
	invoke SetFilePointer, fileHandle, 0, 0, FILE_BEGIN
	mov eax, dosStubSize
    invoke WriteFile, fileHandle, addr dosStub, eax, ebx, 0
	mov eax, peHeaderSize
    invoke WriteFile, fileHandle, addr peHeader, eax, ebx, 0
	mov eax, sectionTableSize
    invoke WriteFile, fileHandle, addr sectionTable, eax, ebx, 0
	mov eax, headerPaddingSize
    invoke WriteFile, fileHandle, addr headerPadding, eax, ebx, 0

	mov eax, fileHandle
    invoke CloseHandle, eax
	ret
afterGlue endp

end