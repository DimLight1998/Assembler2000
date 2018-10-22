include common.inc
include Tokenizer.inc
include LineControl.inc

MaxToken equ 1000


.data?
	cursor dword ?
	curToken dword ?
	tokenSize dword ?
	tokens Token MaxToken dup(<>)
	bracketStack dword MaxToken dup(?)
	bracketDepth dword ?
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

readSymbol proc uses edi, tokenAddr: ptr Token
	assume esi: ptr byte
	assume edi: ptr byte
	mov edx, tokenAddr
	assume edx: ptr Token
	lea edi, [edx].tokenStr
	mov [edx].tokenType, TOKEN_SYMBOL
	mov al, [esi]
	mov [edi], al
	inc esi
	inc edi
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
	mov eax, 0 ; successful return value
	ret
	assume edi: nothing
	assume edx: nothing
	assume esi: nothing
readSymbol endp

isInteger proc
	assume esi: ptr byte
	movsx eax, [esi]
	invoke crt_isdigit, eax
	ret
	assume esi: nothing
isInteger endp

char2Digit proc, char: dword
	invoke crt_isdigit, char
	.if eax
		mov eax, char
		sub eax, 48 ; '0'
		ret
	.endif
	invoke crt_isupper, char
	.if eax
		mov eax, char
		sub eax, 55 ; 'A'-10
		ret
	.endif
	invoke crt_islower, char
	.if eax
		mov eax, char
		sub eax, 87 ; 'a'-10
		ret
	.endif
	ret
char2Digit endp

readInteger proc uses edi ebx, tokenAddr: ptr Token
	assume esi: ptr byte
	mov edx, tokenAddr
	mov edi, 0 ; value
	mov ebx, 0 ; base
	mov ecx, 0 ; overflow?
	assume edx: ptr Token
	mov [edx].tokenType, TOKEN_INTEGER
	invoke char2Digit, [esi]
	.if eax == 0 ; b o h
		inc esi
		movsx eax, [esi]
		invoke crt_tolower, eax
		.if eax == 98; b
			mov ebx, 2
			inc esi
		.elseif eax == 120; x
			mov ebx, 16
			inc esi
		.else; octal
			mov ebx, 8
		.endif
	.else
		mov edi, eax
		mov ebx, 10
		inc esi
	.endif
	.while 1
		movsx eax, [esi]
		invoke crt_isalnum, eax
		.if !eax
			.break
		.endif
		invoke char2Digit, [esi]
		.if eax >= ebx
.data
	digitOverflowWarn byte "Warning: digit %d cannot fit in base %d",10,0
.code
			invoke crt_printf, addr digitOverflowWarn, eax, ebx
			mov eax, 1 ; error
			ret
		.else
			imul edi, ebx
			.if overflow?
				mov ecx, 1
			.endif
			add edi, eax
			.if overflow?
				mov ecx, 1
			.endif
			inc esi
		.endif
	.endw
	mov [edx].tokenValue, edi
	.if ecx
.data
	integerOverflowWarn byte "Warning: read integer overflow %d", 10, 0
.code
		invoke crt_printf, addr integerOverflowWarn, edi
	.endif
	mov eax, 0
	ret
	assume edx: nothing
	assume esi: nothing
readInteger endp

isChar proc
	assume esi: ptr byte
	movsx eax, [esi]
	.if eax == 39; '
		mov eax, 1
	.else
		mov eax, 0
	.endif
	ret
	assume esi: nothing
isChar endp

readChar proc
	assume esi: ptr byte
	movsx eax, [esi]
	inc esi
	.if eax == 92 ; \
		movsx eax, [esi]
		inc esi
		.if eax == 0 ; error
			mov eax, -1
		.elseif eax == 98 ; b
			mov eax, 8
		.elseif eax == 102 ; f
			mov eax, 12
		.elseif eax == 110 ; n
			mov eax, 10
		.elseif eax == 114 ; r
			mov eax, 13
		.elseif eax == 116 ; t
			mov eax, 9
		.elseif eax == 118 ; v
			mov eax, 11
		.elseif eax == 48 ; 0
			mov eax, 0
		.elseif eax == 92 || eax == 39 || eax == 34
			; do not warn
		.else
.data
	unrecognizedEscapeCharWarn byte "unrecognized escape character: %d", 10, 0
.code
			push eax
			invoke crt_printf, addr unrecognizedEscapeCharWarn, eax
			pop eax
		.endif
	.else
		.if eax == 0
			mov eax, -1; error
		.endif
	.endif
	assume esi: nothing
	ret
readChar endp

isString proc
	assume esi: ptr byte
	movsx eax, [esi]
	.if eax == 34
		mov eax, 1
	.else
		mov eax, 0
	.endif
	assume esi: nothing
	ret
isString endp

readString proc uses edx edi, tokenAddr: ptr Token
	assume esi: ptr byte
	mov edx, tokenAddr
	assume edx: ptr Token
	lea edi, [edx].tokenStr
	assume edi: ptr byte
	mov [edx].tokenType, TOKEN_STRING
	inc esi ; skip the " character
	.while 1
		movsx eax, [esi]
		.if eax == 34 ; ", end of string
			.break
		.else
			invoke readChar
			.if eax == -1
				push eax
.data
	unexpectedLineEndErr byte "unexpected line end when reading string", 10, 0
.code
				invoke crt_printf, addr unexpectedLineEndErr
				pop eax ; eax = -1 indicates error
				ret
			.endif
			mov [edi], al
			inc edi
		.endif
	.endw	
	mov edi, 0 ; end of string
	mov eax, 0 ; success
	assume edi: nothing
	assume edx: nothing
	assume esi: nothing
	ret
readString endp

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

breakWithError macro
	mov lineErrorFlag, 1
	inc totalErrorCount
	.break
endm

endAndContinue macro
	add edi, type Token
	inc tokenSize
	.continue
endm

tokenizeLine proc uses esi edi ebx
	mov esi, offset lineBuffer
	assume esi: ptr byte
	mov edi, offset tokens
	assume edi: ptr Token
	mov tokenSize, 0
	mov bracketDepth, 0
	mov ebx, offset bracketStack
	.while 1
		invoke skipSpace
		movsx eax, [esi]
		.if eax == 0 ; end of line
			.break
		.endif

		invoke isString
		.if eax
			invoke readString, edi
			.if eax ; error
				breakWithError
			.endif
			endAndContinue
		.endif

		invoke isInteger
		.if eax
			invoke readInteger, edi
			.if eax
				breakWithError
			.endif
			endAndContinue
		.endif

		invoke isSymbol
		.if eax
			invoke readSymbol, edi
			.if eax
				breakWithError
			.endif
			endAndContinue
		.endif

		invoke isChar
		.if eax
			mov [edi].tokenType, TOKEN_CHAR
			inc esi
			invoke readChar
			.if eax == -1 ; error
.data
	unexpectedLineEndCharErr byte "unexpected line end when reading char", 10, 0
.code
				invoke crt_printf, addr unexpectedLineEndCharErr
				breakWithError
			.endif
			mov [edi].tokenValue, eax
			movsx eax, [esi]
			.if eax == 39 ; '
				inc esi
			.else
.data
	notEndCharWithSingleQuoteErr byte "char does not end with '", 10, 0
.code
				invoke crt_printf, addr notEndCharWithSingleQuoteErr
				breakWithError
			.endif
			endAndContinue
		.endif

		movsx eax, [esi]
		.if eax == 44 ; ,
			.if bracketDepth == 0
				mov [edi].tokenType, TOKEN_COMMA
			.elseif bracketDepth == 1
				mov [edi].tokenType, TOKEN_MEM_COMMA
				push esi
				mov esi, [ebx - 4] ; last left bracket
				mov (Token ptr [esi]).tokenType, TOKEN_MEM_LEFTBRA
				pop esi
			.else
.data
	wrongBracketDepthErr byte "cannot use ',' in bracket depth: %d", 10, 0
.code
				invoke crt_printf, addr wrongBracketDepthErr, eax
				breakWithError
			.endif
			inc esi
			endAndContinue
		.elseif eax == 37 ; %
			mov [edi].tokenType, TOKEN_PERCENT
			inc esi
			endAndContinue
		.elseif eax == 36 ; $
			mov [edi].tokenType, TOKEN_DOLLAR
			inc esi
			endAndContinue
		.elseif eax == 40 ; (
			mov [edi].tokenType, TOKEN_LEFTBRA
			inc bracketDepth
			mov [ebx], edi
			add ebx, 4
			inc esi
			endAndContinue
		.elseif eax == 41 ; )
			.if bracketDepth == 0 ; no left bracket to match
.data
	missingLeftBracketErr byte "not enough left bracket to match", 10, 0
.code
				invoke crt_printf, addr missingLeftBracketErr
				breakWithError
			.endif
			dec bracketDepth
			sub ebx, 4
			push esi
			mov esi, [ebx]
			assume esi: ptr Token
			.if [esi].tokenType == TOKEN_LEFTBRA
				mov [edi].tokenType, TOKEN_RIGHTBRA
			.else
				mov [edi].tokenType, TOKEN_MEM_RIGHTBRA
			.endif
			assume esi: nothing
			pop esi
			inc esi
			endAndContinue
		.endif
		; default, cannot recognize
.data
	unrecognizedCharErr byte "unrecognized character when parsing line: %c", 10, 0
.code
		invoke crt_printf, addr unrecognizedCharErr, eax
		breakWithError
	.endw
	.if !lineErrorFlag && bracketDepth != 0
.data
	unusedRightBracket byte "%d ununsed right bracket(s)", 10, 0
.code
		invoke crt_printf, addr unusedRightBracket, eax
		mov lineErrorFlag, 1
		inc totalErrorCount
	.endif

	assume edi: nothing
	assume esi: nothing
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
		invoke crt_printf,addr ptt1, (Token ptr [edi]).tokenType, addr (Token ptr [edi]).tokenStr
	.endif
	ret
tmpTestSymbol endp

tmpTestInteger proc
	mov esi, offset lineBuffer
	invoke skipSpace
	invoke isInteger
	push eax
	invoke crt_printf, addr pattern, eax
	pop eax
	.if eax
		invoke readInteger, addr tokens
.data
	ptt2 byte "%d %d",10,0
.code
		mov edi, offset tokens
		invoke crt_printf,addr ptt2, (Token ptr [edi]).tokenType, (Token ptr [edi]).tokenValue
	.endif
	ret
tmpTestInteger endp

tmpTestChar proc
	mov esi, offset lineBuffer
	invoke skipSpace
	invoke isChar
	push eax
	invoke crt_printf, addr pattern, eax
	pop eax
	.if eax
		inc esi
		invoke readChar
		invoke crt_printf, addr pattern, eax
	.endif
	ret
tmpTestChar endp

tmpTestString proc
	mov esi, offset lineBuffer
	invoke skipSpace
	invoke isString
	push eax
	invoke crt_printf, addr pattern, eax
	pop eax
	.if eax
		mov edi, offset tokens
		invoke readString, edi
		invoke crt_puts, addr (Token ptr [edi]).tokenStr
	.endif
	ret
tmpTestString endp

tmpTestTokenize proc
	invoke tokenizeLine
	mov ecx, tokenSize
	mov edi, offset tokens
	assume edi: ptr Token
L1:
.data
	tokenPattern byte "%d %d %s", 10, 0
.code
	push ecx
	invoke crt_printf, addr tokenPattern, [edi].tokenType, [edi].tokenValue, addr [edi].tokenStr
	add edi, type Token
	pop ecx
	loop L1
	assume edi: nothing
	ret
tmpTestTokenize endp

end	