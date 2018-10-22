include common.inc
include LineControl.inc

MaxBufferLength equ 100000
FileNameLength equ 1000

.data
	inMode byte "r", 0
	outMode byte "w", 0
	inFileName byte "input.txt", 0
	lineNumber dword 0
	errCount dword 0

.data?
	lineLength dword ? ; line length in bytes
	lineEnd dword ? ; line end address
	lineBuffer byte MaxBufferLength dup(?) ; buffer to put in line

	fin dword ?
	fout dword ?

	;inFileName byte FileNameLength dup(?) todo
	outFileName byte FileNameLength dup(?)

	lineErrorFlag byte ?
	totalErrorCount dword ?
.code

; load a line in lineBuffer
; return val in eax
; return bytes read, -1 if EOF
loadLine proc
	invoke crt_fgets, addr lineBuffer, lengthof lineBuffer - 1, fin
	; todo: line too long warning
	.if eax != 0
		invoke crt_strlen, addr lineBuffer ; store line length in eax return value
		mov lineLength, eax

		mov ecx, offset lineBuffer
		add ecx, eax

		.if eax > 0 && byte ptr [ecx - 1] == 10 ; remove line end \n
			dec eax
			dec ecx
			mov byte ptr [ecx], 0
		.endif

		mov lineEnd, ecx

		inc lineNumber
	.endif
	ret
loadLine endp

tmpLoadInput proc
	invoke crt_fopen, addr inFileName, addr inMode
	mov fin, eax
	ret
tmpLoadInput endp

end