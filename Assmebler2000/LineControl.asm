include common.inc
include LineControl.inc
include Glue.inc
include Tokenizer.inc
include Parser.inc
include SymbolDict.inc

.data
	inMode byte "r", 0
	outMode byte "w", 0
	inFileName byte "input.s", 0, 200 dup(0)
	outFileName byte "output.exe", 0, 200 dup(0)
.data?
	lineLength dword ? ; line length in bytes
	lineEnd dword ? ; line end address
	lineBuffer byte MaxBufferLength dup(?) ; buffer to put in line

	lineNumber dword ?
	parseCount dword ?

	fin dword ?
	fout dword ?

	lineErrorFlag byte ?
	totalErrorCount dword ?

	dataSection Section <>
	textSection Section <>
	currentSection dword ?

	externTries dword MaxLabelInSection dup(?)
	currentExtern dword ?
.code

; load a line in lineBuffer
; return val in eax
; return bytes read, -1 if EOF
loadLine proc uses ecx
	invoke crt_fgets, addr lineBuffer, lengthof lineBuffer - 1, fin
	; todo: line too long warning
	.if eax != 0
		invoke crt_strlen, addr lineBuffer ; store line length in eax return value

		mov ecx, offset lineBuffer
		add ecx, eax

		.if eax > 0 && byte ptr [ecx - 1] == 10 ; remove line end \n
			dec eax
			dec ecx
			mov byte ptr [ecx], 0
		.endif

		mov lineLength, eax
		mov lineEnd, ecx

		inc lineNumber
	.else
		mov eax, -1
	.endif
	ret
loadLine endp

addSectionLocation proc uses esi edi, sectionAddr: dword, difference: dword
	mov esi, sectionAddr
	assume esi: ptr Section
	mov edi, difference
	add [esi].currentCursor, edi
	add [esi].locationCounter, edi
	add (TrieNode ptr dotTrieAddr).nodeVal, edi
	assume esi: nothing
	ret
addSectionLocation endp

writeSectionData proc uses esi edi eax, sectionAddr: dword, data: dword, dataSize: dword
	mov esi, sectionAddr
	assume esi: ptr Section
	mov eax, data
	mov edi, [esi].currentCursor
	.if dataSize == 1
		mov [edi], al
		invoke addSectionLocation, sectionAddr, 1
	.elseif dataSize == 2
		mov [edi], ax
		invoke addSectionLocation, sectionAddr, 2
	.elseif dataSize == 4
		mov [edi], eax
		invoke addSectionLocation, sectionAddr, 4
	.else
.data
	unsupportedDataSize byte "unsupported data size: %d", 10, 0
.code
		invoke crt_printf, addr unsupportedDataSize, dataSize
	.endif
	assume esi: nothing
	ret
writeSectionData endp

initSection proc uses eax esi, sectionAddr: dword, base: dword
	mov esi, sectionAddr
	assume esi: ptr Section
	mov eax, base
	mov [esi].baseAddress, eax
	mov [esi].locationCounter, eax
	lea eax, [esi].labelTries
	mov [esi].currentTrie, eax
	lea eax, [esi].sectionContent
	mov [esi].currentCursor, eax
	assume esi: nothing
	ret
initSection endp

addTrieEntry proc uses esi eax ebx, sectionAddr: dword, trieEntry: dword
	mov esi, sectionAddr
	assume esi: ptr Section
	mov eax, trieEntry
	mov ebx, [esi].currentTrie
	mov [ebx], eax ; prevbug: memory reference bug
	add [esi].currentTrie, type dword
	assume esi: nothing
	ret
addTrieEntry endp

tmpLoadInput proc
	invoke crt_fopen, addr inFileName, addr inMode
	mov fin, eax
	ret
tmpLoadInput endp

parseFile proc
	mov lineNumber, 0
	.while 1
		mov lineErrorFlag, 0
		invoke loadLine
		.if eax == -1
			.break
		.endif
		invoke tokenizeLine
		.if !lineErrorFlag
			invoke parseLine
		.endif
		.if lineErrorFlag
.data
	errorOccurLineInfo byte "error occured when parsing line %d", 10, 0
.code
			invoke crt_printf, addr errorOccurLineInfo, lineNumber
		.endif
	.endw
	ret
parseFile endp

; the main procedure
assemble proc
; todo: get inFileName, outFileName from command line parameter
	
	invoke dictPreprocess

; open file
	invoke crt_fopen, addr inFileName, addr inMode
	mov fin, eax
	.if !fin ; null pointer, error
.data
	fileNotOpenErr byte "Error: cannot open input file %s", 10, 0
.code
		invoke crt_printf, addr fileNotOpenErr, addr inFileName
		ret
	.endif

; clear error flags
	mov totalErrorCount, 0

; first pass
	invoke initSection, addr dataSection, 0
	invoke initSection, addr textSection, 0
	mov currentSection, 0 ; point to nothing
	mov parseCount, 1
	mov currentExtern, offset externTries ; prevbug: forgot to initialize
	invoke parseFile
	.if totalErrorCount
.data
	errOccuredDuringPass byte "%d error occured during pass %d, assemble terminated", 10, 0
.code
		invoke crt_printf, addr errOccuredDuringPass, totalErrorCount, parseCount
		ret
	.endif

	invoke middleGlue

	invoke crt_fseek, fin, 0, SEEK_SET ; back to beginning

; second pass
	mov currentSection, 0 ; point to nothing
	mov parseCount, 2
	invoke parseFile
	.if totalErrorCount
		invoke crt_printf, addr errOccuredDuringPass, totalErrorCount, parseCount
		ret
	.endif

	invoke crt_fclose, fin
	mov fin, 0

	invoke afterGlue

	ret
assemble endp

end