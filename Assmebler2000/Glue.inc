; store section length in eax
getSectionLength macro section
	mov eax, section.currentCursor
	sub eax, offset section.sectionContent
endm

middleGlue proto
afterGlue proto
