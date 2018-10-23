include common.inc
include Glue.inc
include LineControl.inc
include SymbolDict.inc
.code

middleGlue proc uses esi ebx
.data
	sectionLengthPrompt byte "this section's length is %d byte(s)", 10, 0
.code
	; get length
	getSectionLength textSection
	invoke crt_printf, addr sectionLengthPrompt, eax ; demo
	getSectionLength dataSection
	invoke crt_printf, addr sectionLengthPrompt, eax ; demo
	; todo set section's base address
	invoke initSection, addr textSection, 0 ; demo
	invoke initSection, addr dataSection, 0 ; demo
	addBaseAddr textSection
	addBaseAddr dataSection
	; todo set external's address
.data
	externalFromPrompt byte "I am %s from %s", 10, 0
.code
	;mov esi, offset externTries
	;assume esi: ptr TrieNode
	;.while esi != currentExtern
	;	invoke crt_printf, addr externalFromPrompt, addr [esi].nodeName, addr [esi].nodeStr
	;	mov [esi].nodeVal, 0 ; demo, you should fill this with its address
	;	add esi, type dword
	;.endw
	assume esi: nothing
.code
	ret
middleGlue endp

afterGlue proc
	; write the content of textSection and dataSection to the output PE file
	ret
afterGlue endp

end