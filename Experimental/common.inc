.386
.model flat, stdcall
option casemap:none

include	windows.inc
include kernel32.inc
include user32.inc
include msvcrt.inc
includelib msvcrt.lib

externdef externalVar:dword


abcd struct
	a dword ?
	b word ?
	z byte ?
	d dword ?
abcd ends

movm2m macro mem1,mem2
	push eax
	mov eax,mem2
	mov mem1,eax
	pop eax
endm