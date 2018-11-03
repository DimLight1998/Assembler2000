.386
.model flat, stdcall
option casemap: none

include windows.inc
include kernel32.inc
include user32.inc
include msvcrt.inc

m2m macro m1, m2
	mov eax,m2
	mov m1,eax
endm

m2meax macro m1, m2
	push eax
	m2m m1, m2
	pop eax
endm