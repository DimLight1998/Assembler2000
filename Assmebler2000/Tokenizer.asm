include common.inc
include Tokenizer.inc
include LineControl.inc

MaxToken equ 1000



.data?
	cursor dword ?
	curToken dword ?
	tokenSize dword ?
	tokens Token MaxToken dup(<>)
.code

; Receive: esi current string idx
; does not modify esi
isSymbol proc
	assume esi: ptr byte
	movsx eax, [esi]
	.if eax == 46 ; .
		mov eax, 1
		ret
	.endif
	.if eax == 95 ; _
		mov eax, 1
		ret
	.endif
	invoke crt_isalpha, eax ; [a-zA-Z]
	ret
	assume esi: nothing
isSymbol endp

isSymbolBody proc
	assume esi: ptr byte
	invoke isSymbol ; [_.a-zA-Z]
	.if eax
		ret
	.endif
	movsx eax, [esi]
	.if eax == 36 ; $
		mov eax, 1
		ret
	.endif
	invoke crt_isdigit, eax
	ret
	assume esi: nothing
isSymbolBody endp

readSymbol proc, tokenAddr: ptr Token
	assume esi: ptr byte
	assume edi: ptr byte
	mov edx, tokenAddr
	assume edx: ptr Token
	lea edi, [edx].tokenStr
	invoke isSymbol
	.if eax
		mov al, TOKEN_SYMBOL
		mov [edx].tokenType, al
		mov al, [esi]
		mov [edi], al
		inc esi
		inc edi
	.else
.data
	symbolHeadErrorMsg byte "Not a symbol head: %c",10,0
.code
		invoke crt_printf, addr symbolHeadErrorMsg, [esi]
		mov eax, 1 ; error
		ret
	.endif
	.while 1
		invoke isSymbolBody
		.if eax
			mov al, [esi]
			mov [edi], al
			inc esi
			inc edi
		.else
			.break
		.endif
	.endw
	movsx eax, [esi]
	.if eax == 58 ; :
		mov al, TOKEN_LABEL
		mov [edx].tokenType, al
		inc esi
	.endif
	mov [edi], 0 ; end string
	ret
	assume edi: nothing
	assume edx: nothing
	assume esi: nothing
readSymbol endp

; skip spaces, may add esi
skipSpace proc
	assume esi: ptr byte
	.while 1
		movsx eax, [esi]
		.if eax == 0 ; end of line string
			.break
		.endif
		invoke crt_isspace, eax
		.if !eax
			.break
		.endif
		inc esi
	.endw
	ret
	assume esi: nothing
skipSpace endp

tokenizeLine proc
	mov esi, offset lineBuffer

	;symbol

	ret
tokenizeLine endp

tmpTestSymbol proc
	mov esi, offset lineBuffer
	invoke skipSpace
	invoke isSymbol
.data
	pattern byte "%d",10,0
.code
	push eax
	invoke crt_printf, addr pattern, eax
	pop eax
	.if eax
		invoke readSymbol, addr tokens
		mov edi, offset tokens
.data
	ptt1 byte "%d %s",10,0
.code
		lea eax, (Token ptr [edi]).tokenStr
		invoke crt_printf,addr ptt1, (Token ptr [edi]).tokenType, eax
	.endif
	ret
tmpTestSymbol endp

end	