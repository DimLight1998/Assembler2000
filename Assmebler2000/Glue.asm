include common.inc
include Glue.inc
include LineControl.inc
include SymbolDict.inc
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
	;invoke crt_printf, addr sectionLengthPrompt, eax ; demo fixme
	getSectionLength dataSection
	;invoke crt_printf, addr sectionLengthPrompt, eax ; demo fixme
	; todo set section's base address
	invoke addBaseAddr, addr textSection, 0 ; demo prevbug: use initSection and clear all labelTries info
	invoke addBaseAddr, addr dataSection, 0 ; demo
	invoke initSection, addr textSection, 0 ; demo
	invoke initSection, addr dataSection, 0 ; demo
	; todo set external's address
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
	assume edi: nothing
.code
	ret
middleGlue endp

afterGlue proc
	; write the content of textSection and dataSection to the output PE file
	ret
afterGlue endp

end