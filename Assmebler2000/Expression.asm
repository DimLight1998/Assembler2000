include common.inc
include Expression.inc
include SymbolDict.inc
include Tokenizer.inc
include LineControl.inc

.data?
	prevNumFlag byte ?
	opStack Operator MaxStackCount dup(<>)
	numStack dword MaxStackCount dup(?)
	opTop dword ?
	numTop dword ?
.code

isNumber proc
	assume esi: ptr Token
	.if [esi].tokenType == TOKEN_SYMBOL || [esi].tokenType == TOKEN_LABEL || [esi].tokenType == TOKEN_INTEGER || [esi].tokenType == TOKEN_CHAR
		mov eax, 1
	.else
		mov eax, 0
	.endif
	assume esi: nothing
	ret ; prevbug: forget this line
isNumber endp

; return non-zero if error occures
; eat the tokens if readed
readNumber proc uses ebx edi, outputAddr: ptr dword ; prevbug: add esi to USES list
	assume esi: ptr Token
	mov edi, outputAddr
	.if [esi].tokenType == TOKEN_SYMBOL || [esi].tokenType == TOKEN_LABEL
		.if parseCount == 2 ; second pass
			invoke getTrieItem, addr [esi].tokenStr
			.if eax == 0
.data
	undefinedSymbolErr byte "undefined symbol: %s", 10, 0
.code
				invoke crt_printf, addr undefinedSymbolErr, addr [esi].tokenStr
				mov eax, 1
				ret
			.endif
			mov bl, (TrieNode ptr [eax]).nodeType
			.if bl != TRIE_VAR && bl != TRIE_LABEL && bl != TRIE_EXTERN ; prevbug: forget TRIE_EXTERN
.data
	invalidSymbolTypeErr byte "invalid symbol type: %s", 10, 0
.code
				invoke crt_printf, addr invalidSymbolTypeErr, addr [esi].tokenStr
				mov eax, 2
				ret
			.endif
			.if eax == dotTrieAddr ; special dot symbol
				.if !currentSection			
.data
	mustBeInSegmentBlock byte "special dot symbol must be in segment block", 10, 0
.code
					invoke crt_printf, addr mustBeInSegmentBlock
					mov eax, 4
					ret
				.endif
			.endif
			mov eax, (TrieNode ptr [eax]).nodeVal
			mov [edi], eax
		.else ; first pass
			mov dword ptr [edi], 0 ; dummy value
		.endif
		add esi, type Token
	.elseif [esi].tokenType == TOKEN_INTEGER || [esi].tokenType == TOKEN_CHAR
		mov eax, [esi].tokenValue
		mov [edi], eax
		add esi, type Token
	.else
.data
	unrecognizedExpression byte "unrecognized expression operand", 10, 0
.code
		invoke crt_printf, addr unrecognizedExpression
		mov eax, 3
		ret
	.endif
	mov eax, 0
	assume esi: nothing
	ret
readNumber endp

pushNumber proc uses edi, number: dword
	.while opTop > offset opStack
		mov edi, opTop
		sub edi, type Operator
		assume edi: ptr Operator
		.if [edi].operatorType == TOKEN_UNARY_NEG
			neg number
		.elseif [edi].operatorType == TOKEN_UNARY_NOT
			.if number
				mov number, 0
			.else
				mov number, 1
			.endif
		.elseif [edi].operatorType == TOKEN_UNARY_BIT_NOT
			not number
		.elseif [edi].operatorType == TOKEN_UNARY_POS
			; do nothing
		.else
			.break
		.endif
		sub opTop, type Operator
		assume edi: nothing
	.endw
	; push number into stack
	mov edi, numTop
	mov eax, number
	mov [edi], eax
	add numTop, type dword
	ret
pushNumber endp

; return -1 if error
popNumber proc uses edi, outputAddr: ptr dword
	.if numTop == offset numStack ; empty stack
		mov eax, -1
		ret
	.endif
	mov edi, numTop
	sub edi, type dword ;  prevbug: forget this line
	mov eax, [edi]
	mov edi, outputAddr
	mov [edi], eax
	sub numTop, type dword
	mov eax, 0
	ret
popNumber endp

; return the type of the operator, return -1 if error occur
popOperator proc
	local op1: dword, op2: dword, result: dword
.data
	invalidOperator byte "invalid operator", 10, 0
	divideZero byte "integer divided by zero error", 10, 0
.code
	.if opTop == offset opStack
		mov eax, -1
		ret
	.endif
	mov edi, opTop
	sub edi, type Operator ; prevbug: forget this line
	xor edx, edx
	mov dl, (Operator ptr [edi]).operatorType
	sub opTop, type Operator
	invoke popNumber, addr op2
	.if eax == -1
		ret
	.endif
	invoke popNumber, addr op1
	.if eax == -1
		ret
	.endif
	.if dl == TOKEN_MUL
		mov eax, op1
		imul eax, op2
		mov result, eax
	.elseif dl == TOKEN_DIV
		.if parseCount == 2
			.if op2 == 0
				invoke crt_printf, addr divideZero
				mov eax, -1
				ret
			.endif
			push edx
			mov eax, op1
			cdq
			idiv op2
			mov result, eax
			pop edx
		.else
			mov result, 0
		.endif
	.elseif dl == TOKEN_MOD
		.if parseCount == 2
			.if op2 == 0
				invoke crt_printf, addr divideZero
				mov eax, -1
				ret
			.endif
			push edx
			mov eax, op1
			cdq
			idiv op2
			mov result, edx
			pop edx
		.else
			mov result, 0
		.endif
	.elseif dl == TOKEN_SHL
		mov eax, op1
		mov ecx, op2
		sal eax, cl
		mov result, eax
	.elseif dl == TOKEN_SHR
		mov eax, op1
		mov ecx, op2
		sar eax, cl
		mov result, eax
	.elseif dl == TOKEN_BIT_OR
		mov eax, op1
		or eax, op2
		mov result, eax
	.elseif dl == TOKEN_BIT_AND
		mov eax, op1
		and eax, op2
		mov result, eax
	.elseif dl == TOKEN_BIT_XOR
		mov eax, op1
		xor eax, op2
		mov result, eax
	.elseif dl == TOKEN_BIT_ORNOT
		mov eax, op1
		or eax, op2
		not eax
		mov result, eax
	.elseif dl == TOKEN_ADD
		mov eax, op1
		add eax, op2
		mov result, eax
	.elseif dl == TOKEN_SUB
		mov eax, op1
		sub eax, op2
		mov result, eax
	.elseif dl == TOKEN_EQUAL
		mov eax, op1
		.if eax == op2
			mov result, 1
		.else
			mov result, 0
		.endif
	.elseif dl == TOKEN_NOT_EQUAL
		mov eax, op1
		.if eax != op2
			mov result, 1
		.else
			mov result, 0
		.endif
	.elseif dl == TOKEN_LESS
		mov eax, op1
		.if eax < op2
			mov result, 1
		.else
			mov result, 0
		.endif
	.elseif dl == TOKEN_GREATER
		mov eax, op1
		.if eax > op2
			mov result, 1
		.else
			mov result, 0
		.endif
	.elseif dl == TOKEN_GE
		mov eax, op1
		.if eax >= op2
			mov result, 1
		.else
			mov result, 0
		.endif
	.elseif dl == TOKEN_LE
		mov eax, op1
		.if eax <= op2
			mov result, 1
		.else
			mov result, 0
		.endif
	.elseif dl == TOKEN_LOGIC_AND
		.if op1
			mov eax, op2
		.else
			mov eax, op1
		.endif
		mov result, eax
	.elseif dl == TOKEN_LOGIC_OR
		.if op1
			mov eax, op1
		.else
			mov eax, op2
		.endif
		mov result, eax
	.else
		invoke crt_printf, addr invalidOperator
		mov eax, -1
		ret
	.endif
	invoke pushNumber, result
	mov eax, edx
	ret
popOperator endp

; return -1 if error
pushOperator proc uses edi ebx, oppo: byte, priority: dword
	assume edi: ptr Operator
	mov ebx, priority
	.while opTop > offset opStack
		mov edi, opTop
		sub edi, type Operator ; prevbug: ftl
		.if [edi].priority >= ebx
			invoke popOperator
			.if eax == -1
				ret
			.endif
		.else
			.break
		.endif
	.endw
	mov edi, opTop
	mov al, oppo
	mov [edi].operatorType, al
	mov [edi].priority, ebx
	add opTop, type Operator
	mov eax, 0
	assume edi: nothing
	ret
pushOperator endp

; return non-zero if error
readExpression proc uses edi edx, outputAddr: ptr dword
	local output: dword
	assume esi: ptr Token
.data
	consecutiveNumberErr byte "consective operands while reading expression", 10, 0
	cannotBeUnaryErr byte "this operator cannot be unary", 10, 0
	cannotUseUnaryHere byte "cannot use unary operator here", 10, 0
	syntaxError byte "syntax error when read expression", 10, 0
.code
	mov eax, offset opStack
	mov opTop, eax
	mov eax, offset numStack
	mov numTop, eax
	mov prevNumFlag, 0
	.while 1
		invoke isNumber
		.if eax
			invoke readNumber, addr output
			.if eax ; error
				ret
			.endif
			.if prevNumFlag
				invoke crt_printf, addr consecutiveNumberErr
				mov eax, 1
				ret
			.endif
			invoke pushNumber, output

			mov prevNumFlag, 1
			.continue
		.endif

		invoke getOpPriority, [esi].tokenType
		.if eax != -1
			.if !prevNumFlag ; unary operator
				.if [esi].tokenType == TOKEN_SUB
					mov [esi].tokenType, TOKEN_UNARY_NEG
				.elseif [esi].tokenType == TOKEN_BIT_ORNOT
					mov [esi].tokenType, TOKEN_UNARY_NOT
				.elseif [esi].tokenType == TOKEN_ADD
					mov [esi].tokenType, TOKEN_UNARY_POS
				.elseif [esi].tokenType == TOKEN_UNARY_BIT_NOT
					; do nothing
				.else
					invoke crt_printf, addr cannotBeUnaryErr
					mov eax, 2
					ret
				.endif
				invoke getOpPriority, [esi].tokenType ; prevbug: ftl, use binary operator's priority when change to unary
				invoke pushOperator, [esi].tokenType, eax ; prevbug: forget this line
			.else
				.if eax == 5 ; wrong unary operator use
					invoke crt_printf, addr cannotUseUnaryHere
					mov eax, 3
					ret
				.endif
				invoke pushOperator, [esi].tokenType, eax
			.endif

			mov prevNumFlag, 0
			add esi, type Token ; prevbug: forget this line
			.continue
		.endif

		.if [esi].tokenType == TOKEN_LEFTBRA
			.if prevNumFlag ; error, because ( must appear after an operator
				invoke crt_printf, addr syntaxError
				mov eax, 6
				ret
			.endif
			mov edi, opTop
			mov (Operator ptr [edi]).operatorType, TOKEN_LEFTBRA
			mov (Operator ptr [edi]).priority, 0
			add opTop, type Operator
			add esi, type Token ; prevbug: forget this line
		.elseif [esi].tokenType == TOKEN_RIGHTBRA
			.if !prevNumFlag ; error, because ) must appear after a number
				invoke crt_printf, addr syntaxError
				mov eax, 7
				ret
			.endif
			.while 1
				.if opTop == offset opStack ; empty stack
					invoke crt_printf, addr syntaxError
					mov eax, 5
					ret
				.endif
				mov edi, opTop
				sub edi, type Operator
				mov dl, (Operator ptr [edi]).operatorType
				.if dl == TOKEN_LEFTBRA
					sub opTop, type Operator
					invoke popNumber, addr output
					invoke pushNumber, output
					.break
				.else
					invoke popOperator
					.if eax == -1 ; error
						ret
					.endif
				.endif
			.endw
			add esi, type Token ; prevbug: forget this line
		.else
			; prevbug: print syntax error
			.break ; expression end
		.endif
	.endw

	.while opTop != offset opStack
		invoke popOperator
		.if eax == -1
			ret
		.endif
	.endw

	.if numTop != offset numStack + type dword
		mov eax, 5
		ret
	.endif

	mov eax, numStack
	mov edi, outputAddr
	mov dword ptr [edi], eax

	mov eax, 0
	assume esi: nothing
	ret
readExpression endp

end