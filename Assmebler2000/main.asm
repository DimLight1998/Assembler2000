include common.inc
include LineControl.inc
include Tokenizer.inc
include SymbolDict.inc

.data
	inOpt byte ".i", 0
	outOpt byte ".o", 0
	inFileNameNotAStr byte "Warning: input filename not a string, ignored", 10, 0
	outFileNameNotAStr byte "Warning: output filename not a string, ignored", 10, 0
	setInputFileName byte "setting input filename to %s", 10, 0
	setOutputFileName byte "setting output filename to %s", 10, 0
	unrecognizedOpt byte "unrecognized option: %s", 10, 0
.code

parseCommandLine proc uses esi
	invoke GetCommandLine
	assume eax: ptr byte
	.while [eax] != 32 && [eax] ; space
		inc eax
	.endw
	invoke crt_strcpy, addr lineBuffer, eax
	assume eax: nothing
	invoke tokenizeLine
	mov esi, offset tokens
	assume esi: ptr Token
	.while [esi].tokenType != TOKEN_ENDLINE
		invoke crt_strcmp, addr [esi].tokenStr, addr inOpt
		.if eax == 0
			.if [esi + type Token].tokenType != TOKEN_STRING
				invoke crt_printf, addr inFileNameNotAStr
			.else
				invoke crt_strcpy, addr inFileName, addr [esi + type Token].tokenStr
				invoke crt_printf, addr setInputFileName, addr inFileName
				add esi, type Token
			.endif
		.else
			invoke crt_strcmp, addr [esi].tokenStr, addr outOpt
			.if eax == 0
				.if [esi + type Token].tokenType != TOKEN_STRING
					invoke crt_printf, addr outFileNameNotAStr
				.else
					invoke crt_strcpy, addr outFileName, addr [esi + type Token].tokenStr
					invoke crt_printf, addr setOutputFileName, addr outFileName
					add esi, type Token
				.endif
			.else
				; do nothing
			.endif
		.endif
		add esi, type Token
	.endw
	assume esi: nothing
	ret
parseCommandLine endp

main proc
	invoke parseCommandLine
	invoke assemble
	invoke ExitProcess, 0
main endp
end main