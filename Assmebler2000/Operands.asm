include common.inc
include Operands.inc
include SymbolDict.inc
include Tokenizer.inc
include Expression.inc

.data?
operands Operand MaxOperandCount dup(<>)
curOp dword ?

.code
; return non-zero if error
readOperand proc uses edi, operAddr: ptr Operand
.data
	registerSyntaxErr byte "syntax error when reading register", 10, 0
	notARegister byte "not a register: %s", 10, 0
	readImmErr byte "read immediate value error", 10, 0
	readDisplacementErr byte "read displacement expression error", 10, 0
	readBaseRegErr byte "read base register error", 10, 0
	readIndexRegErr byte "read index register error", 10, 0
	readScaleErr byte "read scale error", 10, 0
	improperScaleErr byte "scale is expected to be 1, 2, 4, 8, got %d", 10, 0
	junkCharAfterDisplacement byte "junk char after reading displacement", 10, 0
.code
	assume esi: ptr Token
	mov edi, operAddr
	assume edi: ptr Operand
	.if [esi].tokenType == TOKEN_PERCENT ; reg
		add esi, type Token

		.if [esi].tokenType != TOKEN_SYMBOL
			invoke crt_printf, addr registerSyntaxErr
			mov eax, 1
			ret
		.endif
		
		invoke isReg, addr [esi].tokenStr
		.if !eax
			invoke crt_printf, addr notARegister, addr [esi].tokenStr
			mov eax, 2
			ret
		.endif
		
		mov [edi].operandType, OPER_REG
		invoke getTrieItem, addr [esi].tokenStr
		mov eax, (TrieNode ptr [eax]).nodeVal
		mov [edi].baseReg, eax

		add esi, type Token
	.elseif [esi].tokenType == TOKEN_DOLLAR ; imm
		add esi, type Token

		invoke readExpression, addr [edi].displacement
		.if eax
			invoke crt_printf, addr readImmErr
			mov eax, 3
			ret
		.endif
		
		mov [edi].operandType, OPER_IMM

		;prevbug: add esi, type Token
	.else ; mem
		mov [edi].operandType, OPER_MEM
		; default value
		mov [edi].baseReg, -1
		mov [edi].scale, 1
		mov [edi].indexReg, -1
		mov [edi].displacement, 0

		.if [esi].tokenType != TOKEN_MEM_LEFTBRA ; must be a displacement
			invoke readExpression, addr [edi].displacement
			.if eax
				invoke crt_printf, addr readDisplacementErr
				mov eax, 4
				ret
			.endif
		.endif

		.if [esi].tokenType == TOKEN_ENDLINE || [esi].tokenType == TOKEN_COMMA
			mov eax, 0
			ret
		.elseif [esi].tokenType == TOKEN_MEM_LEFTBRA
			add esi, type Token

			.if [esi].tokenType == TOKEN_PERCENT
				; base reg
				add esi, type Token
				.if [esi].tokenType != TOKEN_SYMBOL
					invoke crt_printf, addr readBaseRegErr
					mov eax, 7
					ret
				.endif
				
				invoke isReg, addr [esi].tokenStr
				.if !eax
					invoke crt_printf, addr readBaseRegErr
					mov eax, 8
					ret
				.endif

				invoke getTrieItem, addr [esi].tokenStr
				mov eax, (TrieNode ptr [eax]).nodeVal
				mov [edi].baseReg, eax
				add esi, type Token

				.if [esi].tokenType == TOKEN_MEM_RIGHTBRA ; (%ebx)
					add esi, type Token
					mov eax, 0
					ret
				.elseif [esi].tokenType == TOKEN_MEM_COMMA ; (%ebx,%esi
					add esi, type Token
				.else
					invoke crt_printf, addr readBaseRegErr
					mov eax, 9
					ret
				.endif

			.elseif [esi].tokenType == TOKEN_MEM_COMMA
				add esi, type Token
			.else
				invoke crt_printf, addr readBaseRegErr
				mov eax, 6
				ret
			.endif

			; read index reg
			.if [esi].tokenType != TOKEN_PERCENT
				invoke crt_printf, addr readIndexRegErr
				mov eax, 10
				ret
			.endif
			add esi, type Token
			
			.if [esi].tokenType != TOKEN_SYMBOL
				invoke crt_printf, addr readIndexRegErr
				mov eax, 11
				ret
			.endif

			invoke isReg, addr [esi].tokenStr
			.if !eax
				invoke crt_printf, addr readIndexRegErr
				mov eax, 12
				ret
			.endif

			invoke getTrieItem, addr [esi].tokenStr
			mov eax, (TrieNode ptr [eax]).nodeVal
			mov [edi].indexReg, eax
			add esi, type Token

			.if [esi].tokenType == TOKEN_MEM_RIGHTBRA ;(%ebx,%esi)
				add esi, type Token
				mov eax, 0
				ret
			.elseif [esi].tokenType == TOKEN_MEM_COMMA;(%ebx,%esi,2
				add esi, type Token
			.else
				invoke crt_printf, addr readIndexRegErr
				mov eax, 13
				ret
			.endif

			invoke readExpression, addr [edi].scale
			.if eax
				invoke crt_printf, addr readScaleErr
				mov eax, 14
				ret
			.endif

			.if [edi].scale != 1 && [edi].scale != 2 && [edi].scale != 4 && [edi].scale != 8
				invoke crt_printf, addr improperScaleErr, [edi].scale
				mov eax, 15
				ret
			.endif

			.if [esi].tokenType == TOKEN_MEM_RIGHTBRA
				add esi, type Token
			.else
				invoke crt_printf, addr readScaleErr
				mov eax, 16
				ret
			.endif
		.else
			invoke crt_printf, addr junkCharAfterDisplacement
			mov eax, 5
			ret
		.endif
	.endif
	assume edi: nothing
	assume esi: nothing
	mov eax, 0
	ret
readOperand endp

end