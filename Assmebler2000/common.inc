.386
.model flat, stdcall
option casemap: none

include ..\..\..\masm32\include\windows.inc 
include ..\..\..\masm32\include\kernel32.inc
include ..\..\..\masm32\include\user32.inc
include ..\..\..\masm32\include\msvcrt.inc

includelib msvcrt.lib

m2m macro m1, m2
	mov eax,m2
	mov m1,eax
endm

m2meax macro m1, m2
	push eax
	m2m m1, m2
	pop eax
endm