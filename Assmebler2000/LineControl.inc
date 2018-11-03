externdef lineBuffer: byte, lineLength: dword, lineEnd: dword
externdef lineErrorFlag: byte, totalErrorCount: dword

MaxLabelInSection equ 20000
MaxByteInSection equ 200000
MaxBufferLength equ 100000
FileNameLength equ 1000
SEEK_SET equ 0 ; for fseek

Section struct
	locationCounter dword ?
	baseAddress dword ?
	labelTries dword MaxLabelInSection dup(?)
	currentTrie dword ?
	sectionContent byte MaxByteInSection dup(?)
	currentCursor dword ?
Section ends

externdef textSection: Section, dataSection: Section
externdef currentSection: dword
externdef parseCount: dword
externdef externTries: dword, currentExtern: dword
externdef inFileName: byte, outFileName: byte


addSectionLocation proto, sectionAddr: dword, difference: dword
assemble proto
loadLine proto
initSection proto, sectionAddr: dword, base: dword
tmpLoadInput proto
writeSectionData proto, sectionAddr: dword, data: dword, dataSize: dword
addTrieEntry proto, sectionAddr: dword, trieEntry: dword