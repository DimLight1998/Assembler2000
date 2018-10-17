.386
.model flat, stdcall
option casemap:none

include	windows.inc
include kernel32.inc
include user32.inc

.data
	msg byte "Hello world",0Ah,0
.code

main proc
	mov eax,1
main endp
end main