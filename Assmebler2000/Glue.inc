addBaseAddr macro section
	mov esi, offset section.labelTries
	mov eax, section.baseAddress
	.while esi != section.currentTrie
		mov ebx, [esi]
		add (TrieNode ptr [ebx]).nodeVal, eax
		add esi, type dword
	.endw
endm

; store section length in eax
getSectionLength macro section
	mov eax, section.currentCursor
	sub eax, offset section.sectionContent
endm

middleGlue proto
afterGlue proto
