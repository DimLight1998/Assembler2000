include common.inc
include Parser.inc
include Tokenizer.inc
include LineControl.inc
include SymbolDict.inc
include Expression.inc
include Operands.inc
include ../EncoderUtils.inc

.code

switchSegment proc, nodeVal: dword
	.if nodeVal == DOTDATA
		mov currentSection, offset dataSection
		mov eax, dataSection.locationCounter
		mov (TrieNode ptr dotTrieAddr).nodeVal, eax
	.elseif nodeVal == DOTTEXT
		mov currentSection, offset textSection
		mov eax, textSection.locationCounter
		mov (TrieNode ptr dotTrieAddr).nodeVal, eax
	.endif
	mov al, (Token ptr [esi]).tokenType
	.if al != TOKEN_ENDLINE
.data
	junkCharAfterSwitchSectionErr byte "junk char after switch section directive", 10, 0
.code
		invoke crt_printf, junkCharAfterSwitchSectionErr
		mov lineErrorFlag, 1
		inc totalErrorCount
	.endif
	ret
switchSegment endp

allocateData proc, nodeVal: dword
	local dataSize: dword, output: dword
	.if nodeVal == DOTBYTE
		mov dataSize, 1
	.elseif nodeVal == DOTINT
		mov dataSize, 2
	.elseif nodeVal == DOTLONG
		mov dataSize, 4
	.endif
	assume esi: ptr Token
	.if [esi].tokenType == TOKEN_ENDLINE ; zero expression
		ret
	.endif
	.while 1
		invoke readExpression, addr output
		.if eax ; error
			mov lineErrorFlag, 1
			inc totalErrorCount
			ret
		.elseif !currentSection
.data
	mustAllocateDataInSectionErr byte "must allocate data in a section", 10, 0
.code
			invoke crt_printf, addr mustAllocateDataInSectionErr
			mov lineErrorFlag, 1
			inc totalErrorCount
			ret
		.else
			invoke writeSectionData, currentSection, output, dataSize
		.endif
		.if [esi].tokenType == TOKEN_ENDLINE
			.break ; line end
		.elseif [esi].tokenType == TOKEN_COMMA
			add esi, type Token
		.else
.data
	syntaxErrAllocateData byte "not an end of line nor a comma after an expression", 10, 0
.code
			invoke crt_printf, addr syntaxErrAllocateData
			mov lineErrorFlag, 1
			inc totalErrorCount
			ret
		.endif
	.endw
	assume esi: nothing
	ret
allocateData endp

allocateString proc uses edi, nodeVal: dword
	assume esi: ptr Token
	.if [esi].tokenType == TOKEN_ENDLINE
		ret ; empty statement
	.endif
	.while 1
		.if [esi].tokenType != TOKEN_STRING
.data
	tokenNotAStringErr byte "token is not a string", 10, 0
.code
			invoke crt_printf, addr tokenNotAStringErr
			mov lineErrorFlag, 1
			inc totalErrorCount
			ret
		.elseif !currentSection
			invoke crt_printf, addr mustAllocateDataInSectionErr
			mov lineErrorFlag, 1
			inc totalErrorCount
			ret
		.endif
		lea edi, [esi].tokenStr
		.while 1
			movzx eax, byte ptr [edi]
			.if !eax
				.break
			.endif
			invoke writeSectionData, currentSection, eax, 1
			inc edi
		.endw
		.if nodeVal == DOTASCIZ
			invoke writeSectionData, currentSection, 0, 1
		.endif
		add esi, type Token
		.if [esi].tokenType == TOKEN_ENDLINE
			.break ; line end
		.elseif [esi].tokenType == TOKEN_COMMA
			add esi, type Token
		.else
			invoke crt_printf, addr syntaxErrAllocateData
			mov lineErrorFlag, 1
			inc totalErrorCount
			ret
		.endif
	.endw
	assume esi: nothing
	ret
allocateString endp

; return non-zero if error occures
addDefine proc uses ebx, strAddr: dword, value: dword
.data
	mustBeInSegmentBlock byte "special dot symbol must be in segment block", 10, 0
.code
	.if parseCount == 2
		invoke getOrCreateTrieItem, strAddr
		assume eax: ptr TrieNode
		.if [eax].nodeType == TRIE_NULL
			mov [eax].nodeType, TRIE_VAR
			mov ebx, value
			mov [eax].nodeVal, ebx
		.elseif [eax].nodeType == TRIE_VAR
			.if eax == dotTrieAddr ; special dot symbol
				.if !currentSection
					invoke crt_printf, addr mustBeInSegmentBlock
					mov eax, 2
					ret
				.endif
				mov ebx, value
				sub ebx, [eax].nodeVal ; calculate the difference
				invoke addSectionLocation, currentSection, ebx
			.else
				mov ebx, value
				mov [eax].nodeVal, ebx
			.endif
		.else
.data
	cannotAssignDefineErr byte "cannot assign define to %s", 10, 0
.code
			invoke crt_printf, addr cannotAssignDefineErr, strAddr
			mov eax, 1
			ret
		.endif
		assume eax: nothing
	.endif
	mov eax, 0
	ret
addDefine endp

setLineDefine proc
	local strAddr: ptr byte, value: dword
	assume esi: ptr Token
	.if [esi].tokenType != TOKEN_SYMBOL
.data
	assigneeNotSymbolErr byte "assignee not a symbol", 10, 0
.code
		invoke crt_printf, addr assigneeNotSymbolErr
		mov lineErrorFlag, 1
		inc totalErrorCount
		ret
	.endif
	lea eax, [esi].tokenStr
	mov strAddr, eax
	add esi, type Token
	.if [esi].tokenType != TOKEN_COMMA
.data
	syntaxErrReadDefine byte "syntax error when assign define", 10, 0
.code
		invoke crt_printf, addr syntaxErrReadDefine
		mov lineErrorFlag, 1
		inc totalErrorCount
		ret
	.endif
	add esi, type Token

	invoke readExpression, addr value
	.if eax ; error
		mov lineErrorFlag, 1
		inc totalErrorCount
		ret
	.endif
	
	.if [esi].tokenType != TOKEN_ENDLINE
		invoke crt_printf, addr syntaxErrReadDefine
		mov lineErrorFlag, 1
		inc totalErrorCount
		ret
	.endif

	invoke addDefine, strAddr, value
	.if eax
		mov lineErrorFlag, 1
		inc totalErrorCount
		ret
	.endif

	assume esi: nothing
	ret
setLineDefine endp

importLine proc uses edi ebx
	assume esi: ptr Token
.data
	syntaxImportLineErr byte "syntax error when paring .import", 10, 0
	expectedImportSymbol byte "expect symbol to import", 10, 0
	dllNameAlreadyUsed byte "dll name already used: %s", 10, 0
	cannotImportSymbol byte "duplicate import of symbol %s", 10, 0
.code
	.if [esi].tokenType != TOKEN_STRING
		invoke crt_printf, addr syntaxImportLineErr
		mov lineErrorFlag, 1
		inc totalErrorCount
		ret
	.endif
	invoke getOrCreateTrieItem, addr [esi].tokenStr
	mov edi, eax
	assume edi: ptr TrieNode
	.if [edi].nodeType == TRIE_NULL
		mov [edi].nodeType, TRIE_DLL
		mov [edi].nodeVal, 0
		mov eax, currentExtern
		mov [eax], edi ; record dll node address
		add currentExtern, type dword
		invoke crt_strcpy, addr [edi].nodeStr, addr [esi].tokenStr
	.elseif [edi].nodeType == TRIE_DLL
		; do nothing
	.else
		invoke crt_printf, addr dllNameAlreadyUsed, addr [esi].tokenStr
		mov lineErrorFlag, 1
		inc totalErrorCount
		ret
	.endif
	add esi, type Token
	.while 1
		.if [esi].tokenType == TOKEN_COMMA
			add esi, type Token
		.elseif [esi].tokenType == TOKEN_ENDLINE
			.break
		.else
			invoke crt_printf, addr syntaxImportLineErr
			mov lineErrorFlag, 1
			inc totalErrorCount
			ret
		.endif
		.if [esi].tokenType != TOKEN_SYMBOL
			invoke crt_printf, addr expectedImportSymbol
			mov lineErrorFlag, 1
			inc totalErrorCount
			ret
		.endif
		.if parseCount == 1
			invoke getOrCreateTrieItem, addr [esi].tokenStr
			mov ebx, eax ; prevbug: use eax when using strcpy: wierd!
			assume ebx: ptr TrieNode
			.if [ebx].nodeType != TRIE_NULL
				invoke crt_printf, addr cannotImportSymbol, addr [esi].tokenStr
				mov lineErrorFlag, 1
				inc totalErrorCount
				ret
			.endif
			mov [ebx].nodeType, TRIE_EXTERN
			mov eax, [edi].nodeVal
			mov [ebx].nodeVal, eax
			mov [edi].nodeVal, ebx ; linked list
			invoke crt_strcpy, addr [ebx].nodeStr, addr [esi].tokenStr ; prevbug: [edi].nodeStr, addr [esi]
			assume ebx: nothing
		.endif
		add esi, type Token ; prevbug: forget this line
	.endw

	assume edi: nothing
	assume esi: nothing
	ret
importLine endp

; return non-zero if error
setLabelLocation proc uses ebx, strAddr: ptr byte
.data
	labelAlreadyUsed byte "label already used: %s", 10, 0
	mustBeInASection byte "label must be in a section: %s", 10, 0
.code
	.if parseCount == 1
		invoke getOrCreateTrieItem, strAddr
		assume eax: ptr TrieNode
		.if [eax].nodeType != TRIE_NULL
			invoke crt_printf, addr labelAlreadyUsed, strAddr
			mov eax, 1
			ret
		.endif
		.if !currentSection
			invoke crt_printf, addr mustBeInASection, strAddr
			mov eax, 2
			ret
		.endif
		mov [eax].nodeType, TRIE_LABEL
		mov ebx, currentSection
		mov ebx, (Section ptr [ebx]).locationCounter
		mov [eax].nodeVal, ebx
		invoke addTrieEntry, currentSection, eax ; prevbug: forget this line
		assume eax: nothing
	.endif
	mov eax, 0
	ret
setLabelLocation endp

; return non-zero if error
assignLine proc
	local strAddr: ptr byte, value: dword
	assume esi: ptr Token
	lea eax, [esi].tokenStr
	mov strAddr, eax
	add esi, 2 * type Token
	invoke readExpression, addr value
	.if eax ; error
		ret
	.endif
	.if [esi].tokenType != TOKEN_ENDLINE
.data
	junkCharAfterAssign byte "junk char after assign", 10, 0
.code
		invoke crt_printf, addr junkCharAfterAssign
		mov eax, 1
		ret
	.endif
	invoke addDefine, strAddr, value
	.if eax
		ret
	.endif
	mov eax, 0	
	assume esi: nothing
	ret
assignLine endp

printOperand proc uses edi, operAddr: ptr Operand
.data
	regPattern byte "reg %d", 10, 0
	immPattern byte "imm %d", 10, 0
	memPattern byte "mem %d(%d,%d,%d)", 10, 0
.code
	mov edi, operAddr
	assume edi: ptr Operand
	.if [edi].operandType == OPER_REG
		invoke crt_printf, addr regPattern, [edi].baseReg
	.elseif [edi].operandType == OPER_IMM
		invoke crt_printf, addr immPattern, [edi].displacement
	.elseif [edi].operandType == OPER_MEM
		invoke crt_printf, addr memPattern, [edi].displacement, [edi].baseReg, [edi].indexReg, [edi].scale
	.endif
	assume edi: nothing
	ret
printOperand endp

encodeInstruction proc uses edi ebx, instruction: dword, strAddr: ptr byte
	local opCount: dword, startAddr: dword, sizeOut: dword, locationCounter: dword
.data
	invalidInstruction byte "no matching instruction %s ",0
	regPat byte "reg32", 0
	immPat byte "imm32", 0
	memPat byte "mem32", 0
	commaPat byte ", ", 0
	newLinePat byte 10, 0
.code
	mov opCount, 0
	assume esi: ptr Token
	mov curOp, offset operands
	.if [esi].tokenType != TOKEN_ENDLINE
		.while 1
			invoke readOperand, curOp
			.if eax
				mov lineErrorFlag, 1
				inc totalErrorCount
				ret
			.endif
			;invoke printOperand, curOp 
			add curOp, type Operand
			inc opCount
			.if [esi].tokenType == TOKEN_ENDLINE
				.break
			.elseif [esi].tokenType == TOKEN_COMMA
				add esi, type Token
			.else
.data
	syntaxErrorOperand byte "syntax error when reading operands", 10, 0
.code
				invoke crt_printf, addr syntaxErrorOperand
				mov lineErrorFlag, 1
				inc totalErrorCount
				ret
			.endif
		.endw
	.endif

	mov eax, currentSection
	mov ebx, (Section ptr [eax]).currentCursor
	mov startAddr, ebx
	mov ebx, (Section ptr [eax]).locationCounter
	mov locationCounter, ebx
	mov sizeOut, 0

	mov edi, offset operands
	assume edi: ptr Operand
	; add
	.if instruction == INSADDL && opCount == 2 && [edi].operandType == OPER_REG && [edi + type Operand].operandType == OPER_MEM
		invoke AddMemReg, [edi + type Operand].baseReg, [edi+type Operand].scale, [edi + type Operand].indexReg, [edi + type Operand].displacement, 0, [edi].baseReg, -1, startAddr, addr sizeOut
	.elseif instruction == INSADDL && opCount == 2 && [edi].operandType == OPER_REG && [edi + type Operand].operandType == OPER_REG
		invoke AddRegReg, -1, 1, -1, 0, 0, [edi + type Operand].baseReg, [edi].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSADDL && opCount == 2 && [edi].operandType == OPER_MEM && [edi + type Operand].operandType == OPER_REG
		invoke AddRegMem, [edi].baseReg, [edi].scale, [edi].indexReg, [edi].displacement, 0, -1, [edi + type Operand].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSADDL && opCount == 2 && [edi].operandType == OPER_IMM && [edi + type Operand].operandType == OPER_REG
		invoke AddRegImm, -1, 1, -1, 0, [edi].displacement, -1, [edi + type Operand].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSADDL && opCount == 2 && [edi].operandType == OPER_IMM && [edi + type Operand].operandType == OPER_MEM
		invoke AddMemImm, [edi + type Operand].baseReg, [edi + type Operand].scale, [edi + type Operand].indexReg, [edi + type Operand].displacement, [edi].displacement, -1, -1, startAddr, addr sizeOut
	; and
	.elseif instruction == INSANDL && opCount == 2 && [edi].operandType == OPER_REG && [edi + type Operand].operandType == OPER_MEM
		invoke AndMemReg, [edi + type Operand].baseReg, [edi+type Operand].scale, [edi + type Operand].indexReg, [edi + type Operand].displacement, 0, [edi].baseReg, -1, startAddr, addr sizeOut
	.elseif instruction == INSANDL && opCount == 2 && [edi].operandType == OPER_REG && [edi + type Operand].operandType == OPER_REG
		invoke AndRegReg, -1, 1, -1, 0, 0, [edi + type Operand].baseReg, [edi].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSANDL && opCount == 2 && [edi].operandType == OPER_MEM && [edi + type Operand].operandType == OPER_REG
		invoke AndRegMem, [edi].baseReg, [edi].scale, [edi].indexReg, [edi].displacement, 0, -1, [edi + type Operand].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSANDL && opCount == 2 && [edi].operandType == OPER_IMM && [edi + type Operand].operandType == OPER_REG
		invoke AndRegImm, -1, 1, -1, 0, [edi].displacement, -1, [edi + type Operand].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSANDL && opCount == 2 && [edi].operandType == OPER_IMM && [edi + type Operand].operandType == OPER_MEM
		invoke AndMemImm, [edi + type Operand].baseReg, [edi + type Operand].scale, [edi + type Operand].indexReg, [edi + type Operand].displacement, [edi].displacement, -1, -1, startAddr, addr sizeOut
	; cmp
	.elseif instruction == INSCMPL && opCount == 2 && [edi].operandType == OPER_REG && [edi + type Operand].operandType == OPER_MEM
		invoke CmpMemReg, [edi + type Operand].baseReg, [edi+type Operand].scale, [edi + type Operand].indexReg, [edi + type Operand].displacement, 0, [edi].baseReg, -1, startAddr, addr sizeOut
	.elseif instruction == INSCMPL && opCount == 2 && [edi].operandType == OPER_REG && [edi + type Operand].operandType == OPER_REG
		invoke CmpRegReg, -1, 1, -1, 0, 0, [edi + type Operand].baseReg, [edi].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSCMPL && opCount == 2 && [edi].operandType == OPER_MEM && [edi + type Operand].operandType == OPER_REG
		invoke CmpRegMem, [edi].baseReg, [edi].scale, [edi].indexReg, [edi].displacement, 0, -1, [edi + type Operand].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSCMPL && opCount == 2 && [edi].operandType == OPER_IMM && [edi + type Operand].operandType == OPER_REG
		invoke CmpRegImm, -1, 1, -1, 0, [edi].displacement, -1, [edi + type Operand].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSCMPL && opCount == 2 && [edi].operandType == OPER_IMM && [edi + type Operand].operandType == OPER_MEM
		invoke CmpMemImm, [edi + type Operand].baseReg, [edi + type Operand].scale, [edi + type Operand].indexReg, [edi + type Operand].displacement, [edi].displacement, -1, -1, startAddr, addr sizeOut
	; mov
	.elseif instruction == INSMOVL && opCount == 2 && [edi].operandType == OPER_REG && [edi + type Operand].operandType == OPER_MEM
		invoke MovMemReg, [edi + type Operand].baseReg, [edi+type Operand].scale, [edi + type Operand].indexReg, [edi + type Operand].displacement, 0, [edi].baseReg, -1, startAddr, addr sizeOut
	.elseif instruction == INSMOVL && opCount == 2 && [edi].operandType == OPER_REG && [edi + type Operand].operandType == OPER_REG
		invoke MovRegReg, -1, 1, -1, 0, 0, [edi + type Operand].baseReg, [edi].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSMOVL && opCount == 2 && [edi].operandType == OPER_MEM && [edi + type Operand].operandType == OPER_REG
		invoke MovRegMem, [edi].baseReg, [edi].scale, [edi].indexReg, [edi].displacement, 0, -1, [edi + type Operand].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSMOVL && opCount == 2 && [edi].operandType == OPER_IMM && [edi + type Operand].operandType == OPER_REG
		invoke MovRegImm, -1, 1, -1, 0, [edi].displacement, -1, [edi + type Operand].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSMOVL && opCount == 2 && [edi].operandType == OPER_IMM && [edi + type Operand].operandType == OPER_MEM
		invoke MovMemImm, [edi + type Operand].baseReg, [edi + type Operand].scale, [edi + type Operand].indexReg, [edi + type Operand].displacement, [edi].displacement, -1, -1, startAddr, addr sizeOut
	; or
	.elseif instruction == INSORL && opCount == 2 && [edi].operandType == OPER_REG && [edi + type Operand].operandType == OPER_MEM
		invoke OrMemReg, [edi + type Operand].baseReg, [edi+type Operand].scale, [edi + type Operand].indexReg, [edi + type Operand].displacement, 0, [edi].baseReg, -1, startAddr, addr sizeOut
	.elseif instruction == INSORL && opCount == 2 && [edi].operandType == OPER_REG && [edi + type Operand].operandType == OPER_REG
		invoke OrRegReg, -1, 1, -1, 0, 0, [edi + type Operand].baseReg, [edi].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSORL && opCount == 2 && [edi].operandType == OPER_MEM && [edi + type Operand].operandType == OPER_REG
		invoke OrRegMem, [edi].baseReg, [edi].scale, [edi].indexReg, [edi].displacement, 0, -1, [edi + type Operand].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSORL && opCount == 2 && [edi].operandType == OPER_IMM && [edi + type Operand].operandType == OPER_REG
		invoke OrRegImm, -1, 1, -1, 0, [edi].displacement, -1, [edi + type Operand].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSORL && opCount == 2 && [edi].operandType == OPER_IMM && [edi + type Operand].operandType == OPER_MEM
		invoke OrMemImm, [edi + type Operand].baseReg, [edi + type Operand].scale, [edi + type Operand].indexReg, [edi + type Operand].displacement, [edi].displacement, -1, -1, startAddr, addr sizeOut
	; sub
	.elseif instruction == INSSUBL && opCount == 2 && [edi].operandType == OPER_REG && [edi + type Operand].operandType == OPER_MEM
		invoke SubMemReg, [edi + type Operand].baseReg, [edi+type Operand].scale, [edi + type Operand].indexReg, [edi + type Operand].displacement, 0, [edi].baseReg, -1, startAddr, addr sizeOut
	.elseif instruction == INSSUBL && opCount == 2 && [edi].operandType == OPER_REG && [edi + type Operand].operandType == OPER_REG
		invoke SubRegReg, -1, 1, -1, 0, 0, [edi + type Operand].baseReg, [edi].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSSUBL && opCount == 2 && [edi].operandType == OPER_MEM && [edi + type Operand].operandType == OPER_REG
		invoke SubRegMem, [edi].baseReg, [edi].scale, [edi].indexReg, [edi].displacement, 0, -1, [edi + type Operand].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSSUBL && opCount == 2 && [edi].operandType == OPER_IMM && [edi + type Operand].operandType == OPER_REG
		invoke SubRegImm, -1, 1, -1, 0, [edi].displacement, -1, [edi + type Operand].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSSUBL && opCount == 2 && [edi].operandType == OPER_IMM && [edi + type Operand].operandType == OPER_MEM
		invoke SubMemImm, [edi + type Operand].baseReg, [edi + type Operand].scale, [edi + type Operand].indexReg, [edi + type Operand].displacement, [edi].displacement, -1, -1, startAddr, addr sizeOut
	; xor
	.elseif instruction == INSXORL && opCount == 2 && [edi].operandType == OPER_REG && [edi + type Operand].operandType == OPER_MEM
		invoke XorMemReg, [edi + type Operand].baseReg, [edi+type Operand].scale, [edi + type Operand].indexReg, [edi + type Operand].displacement, 0, [edi].baseReg, -1, startAddr, addr sizeOut
	.elseif instruction == INSXORL && opCount == 2 && [edi].operandType == OPER_REG && [edi + type Operand].operandType == OPER_REG
		invoke XorRegReg, -1, 1, -1, 0, 0, [edi + type Operand].baseReg, [edi].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSXORL && opCount == 2 && [edi].operandType == OPER_MEM && [edi + type Operand].operandType == OPER_REG
		invoke XorRegMem, [edi].baseReg, [edi].scale, [edi].indexReg, [edi].displacement, 0, -1, [edi + type Operand].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSXORL && opCount == 2 && [edi].operandType == OPER_IMM && [edi + type Operand].operandType == OPER_REG
		invoke XorRegImm, -1, 1, -1, 0, [edi].displacement, -1, [edi + type Operand].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSXORL && opCount == 2 && [edi].operandType == OPER_IMM && [edi + type Operand].operandType == OPER_MEM
		invoke XorMemImm, [edi + type Operand].baseReg, [edi + type Operand].scale, [edi + type Operand].indexReg, [edi + type Operand].displacement, [edi].displacement, -1, -1, startAddr, addr sizeOut
	; test
	.elseif instruction == INSTESTL && opCount == 2 && [edi].operandType == OPER_REG && [edi + type Operand].operandType == OPER_MEM
		invoke TestMemReg, [edi + type Operand].baseReg, [edi+type Operand].scale, [edi + type Operand].indexReg, [edi + type Operand].displacement, 0, [edi].baseReg, -1, startAddr, addr sizeOut
	.elseif instruction == INSTESTL && opCount == 2 && [edi].operandType == OPER_REG && [edi + type Operand].operandType == OPER_REG
		invoke TestRegReg, -1, 1, -1, 0, 0, [edi + type Operand].baseReg, [edi].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSTESTL && opCount == 2 && [edi].operandType == OPER_IMM && [edi + type Operand].operandType == OPER_REG
		invoke TestRegImm, -1, 1, -1, 0, [edi].displacement, -1, [edi + type Operand].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSTESTL && opCount == 2 && [edi].operandType == OPER_IMM && [edi + type Operand].operandType == OPER_MEM
		invoke TestMemImm, [edi + type Operand].baseReg, [edi + type Operand].scale, [edi + type Operand].indexReg, [edi + type Operand].displacement, [edi].displacement, -1, -1, startAddr, addr sizeOut
	; lea
	.elseif instruction == INSLEAL && opCount == 2 && [edi].operandType == OPER_MEM && [edi + type Operand].operandType == OPER_REG
		invoke LeaRegMem, [edi].baseReg, [edi].scale, [edi].indexReg, [edi].displacement, 0, -1, [edi + type Operand].baseReg, startAddr, addr sizeOut
	; dec
	.elseif instruction == INSDECL && opCount == 1 && [edi].operandType == OPER_REG
		invoke DecReg, -1, 1, -1, 0, 0, [edi].baseReg, -1, startAddr, addr sizeOut
	.elseif instruction == INSDECL && opCount == 1 && [edi].operandType == OPER_MEM
		invoke DecMem, [edi].baseReg, [edi].scale, [edi].indexReg, [edi].displacement, 0, -1, -1, startAddr, addr sizeOut
	; inc
	.elseif instruction == INSINCL && opCount == 1 && [edi].operandType == OPER_REG
		invoke IncReg, -1, 1, -1, 0, 0, [edi].baseReg, -1, startAddr, addr sizeOut
	.elseif instruction == INSINCL && opCount == 1 && [edi].operandType == OPER_MEM
		invoke IncMem, [edi].baseReg, [edi].scale, [edi].indexReg, [edi].displacement, 0, -1, -1, startAddr, addr sizeOut
	; neg
	.elseif instruction == INSNEGL && opCount == 1 && [edi].operandType == OPER_REG
		invoke NegReg, -1, 1, -1, 0, 0, [edi].baseReg, -1, startAddr, addr sizeOut
	.elseif instruction == INSNEGL && opCount == 1 && [edi].operandType == OPER_MEM
		invoke NegMem, [edi].baseReg, [edi].scale, [edi].indexReg, [edi].displacement, 0, -1, -1, startAddr, addr sizeOut
	; not
	.elseif instruction == INSNOTL && opCount == 1 && [edi].operandType == OPER_REG
		invoke NotReg, -1, 1, -1, 0, 0, [edi].baseReg, -1, startAddr, addr sizeOut
	.elseif instruction == INSNOTL && opCount == 1 && [edi].operandType == OPER_MEM
		invoke NotMem, [edi].baseReg, [edi].scale, [edi].indexReg, [edi].displacement, 0, -1, -1, startAddr, addr sizeOut
	; pop
	.elseif instruction == INSPOPL && opCount == 1 && [edi].operandType == OPER_REG
		invoke PopReg, -1, 1, -1, 0, 0, -1, [edi].baseReg, startAddr, addr sizeOut
	.elseif instruction == INSPOPL && opCount == 1 && [edi].operandType == OPER_MEM
		invoke PopMem, [edi].baseReg, [edi].scale, [edi].indexReg, [edi].displacement, 0, -1, -1, startAddr, addr sizeOut
	; push
	.elseif instruction == INSPUSHL && opCount == 1 && [edi].operandType == OPER_REG
		invoke PushReg, -1, 1, -1, 0, 0, [edi].baseReg, -1, startAddr, addr sizeOut
	.elseif instruction == INSPUSHL && opCount == 1 && [edi].operandType == OPER_MEM
		invoke PushMem, [edi].baseReg, [edi].scale, [edi].indexReg, [edi].displacement, 0, -1, -1, startAddr, addr sizeOut
	.elseif instruction == INSPUSHL && opCount == 1 && [edi].operandType == OPER_IMM
		invoke PushImm, -1, 1, -1, 0, [edi].displacement, -1, -1, startAddr, addr sizeOut
	; call
	.elseif instruction == INSCALL && opCount == 1 && [edi].operandType == OPER_REG
		invoke CallReg, -1, 1, -1, 0, 0, [edi].baseReg, -1, startAddr, addr sizeOut
	.elseif instruction == INSCALL && opCount == 1 && [edi].operandType == OPER_MEM
		invoke CallMem, [edi].baseReg, [edi].scale, [edi].indexReg, [edi].displacement, 0, -1, -1, startAddr, addr sizeOut
	; jmp
	.elseif instruction == INSJMP && opCount == 1 && [edi].operandType == OPER_MEM && [edi].baseReg == -1 && [edi].indexReg == -1
		mov ebx, [edi].displacement
		sub ebx, locationCounter
		invoke JmpRel, -1, 1, -1, 0, ebx, -1, -1, startAddr, addr sizeOut
	.elseif instruction == INSJMP && opCount == 1 && [edi].operandType == OPER_REG
		invoke JmpReg, -1, 1, -1, 0, 0, [edi].baseReg, -1, startAddr, addr sizeOut
	.elseif instruction == INSJMP && opCount == 1 && [edi].operandType == OPER_MEM
		invoke JmpMem, [edi].baseReg, [edi].scale, [edi].indexReg, [edi].displacement, 0, -1, -1, startAddr, addr sizeOut
	; jz
	.elseif instruction == INSJZ && opCount == 1 && [edi].operandType == OPER_MEM && [edi].baseReg == -1 && [edi].indexReg == -1 ; relative address
		mov ebx, [edi].displacement
		sub ebx, locationCounter
		invoke JzRel, -1, 1, -1, 0, ebx, -1, -1, startAddr, addr sizeOut
	; ret
	.elseif instruction == INSRET && opCount == 0
		invoke RetOnly, -1, 1, -1, 0, 0, -1, -1, startAddr, addr sizeOut
	.else
		invoke crt_printf, addr invalidInstruction, strAddr
		mov edi, offset operands
		mov ebx, opCount
		.while ebx > 0
			.if [edi].operandType == OPER_REG
				invoke crt_printf, addr regPat
			.elseif [edi].operandType == OPER_IMM
				invoke crt_printf, addr immPat
			.elseif [edi].operandType == OPER_MEM
				invoke crt_printf, addr memPat
			.endif
			add edi, type Operand
			.if ebx > 1
				invoke crt_printf, addr commaPat
			.else
				invoke crt_printf, addr newLinePat
			.endif
			dec ebx
		.endw
		
		mov lineErrorFlag, 1
		inc totalErrorCount
		ret
	.endif

	invoke addSectionLocation, currentSection, sizeOut
	
	assume edi: nothing
	assume esi: nothing
	ret
encodeInstruction endp

parseLine proc uses esi ebx
	local lineNodeType: byte, lineNodeVal: dword, typeOkay: byte
	mov esi, offset tokens
	assume esi: ptr Token
	.while [esi].tokenType == TOKEN_LABEL
		invoke setLabelLocation, addr [esi].tokenStr
		.if eax
			mov lineErrorFlag, 1
			inc totalErrorCount
			ret
		.endif
		add esi, type Token
	.endw
	.if [esi].tokenType == TOKEN_ENDLINE ; empty statement
		ret
	.endif
	; statement symbol = expression
	.if [esi].tokenType == TOKEN_SYMBOL
		.if [esi + type Token].tokenType == TOKEN_ASSIGN
			invoke assignLine
			.if eax ; error
				mov lineErrorFlag, 1
				inc totalErrorCount
				ret
			.endif
			ret
		.else
			; do nothing, will report error later
		.endif
	.endif
	mov typeOkay, 1
	.if [esi].tokenType != TOKEN_SYMBOL
		mov typeOkay, 0
	.endif
	assume eax: ptr TrieNode
	.if typeOkay
		invoke getTrieItem, addr [esi].tokenStr
		.if eax == 0
			mov typeOkay, 0
		.endif
	.endif
	.if typeOkay
		.if [eax].nodeType != TRIE_INST && [eax].nodeType != TRIE_DIRECTIVE
			mov typeOkay, 0
		.endif
	.endif
	.if typeOkay
		mov bl, [eax].nodeType
		mov lineNodeType, bl
		mov ebx, [eax].nodeVal
		mov lineNodeVal, ebx
		add esi, type Token
		.if lineNodeVal == DOTDATA || lineNodeVal == DOTTEXT
			invoke switchSegment, lineNodeVal
		.elseif lineNodeVal == DOTBYTE || lineNodeVal == DOTINT || lineNodeVal == DOTLONG
			invoke allocateData, lineNodeVal
		.elseif lineNodeVal == DOTASCII || lineNodeVal == DOTASCIZ
			invoke allocateString, lineNodeVal
		.elseif lineNodeVal == DOTSET || lineNodeVal == DOTEQU
			invoke setLineDefine
		.elseif lineNodeVal == DOTIMPORT
			invoke importLine
		.elseif lineNodeType == TRIE_INST
			invoke encodeInstruction, lineNodeVal, addr [esi - type Token].tokenStr
		.else
.data
	impossibleInfo byte "impossible!", 10, 0
.code
			invoke crt_printf, addr impossibleInfo
		.endif
	.else
.data
	unrecognizedInstruction byte "unrecognized instruction at line begin", 10, 0
.code
		invoke crt_printf, addr unrecognizedInstruction
		mov lineErrorFlag, 1
		inc totalErrorCount
		ret
	.endif
	assume eax: nothing
	assume esi: nothing
	ret
parseLine endp

end