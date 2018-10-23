include common.inc

.data
	b dword 2
	pattern byte "%d",0Ah,0
	char byte "a"
	buffer byte 1000 dup(?)
.code

main proc
	a=1
	invoke crt_printf, addr pattern,a
	a=2
	invoke crt_printf, addr pattern, externalVar
	invoke ExitProcess,0
main endp

haha proc
	ret
haha endp
end main