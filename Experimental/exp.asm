include common.inc

.data
	a dword 1
	b dword 2
	pattern byte "%d",0Ah,0
	char byte "a"
	buffer byte 1000 dup(?)
.code

main proc
	mov eax,0
	assume ebx: ptr byte
	mov ebx, offset char
	movsx eax,[ebx]
	assume ebx: nothing
	mov eax, [ebx]
	invoke ExitProcess,0
main endp
end main