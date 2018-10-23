include common.inc
include Expression.inc
include SymbolDict.inc
include Tokenizer.inc
include LineControl.inc

.code

; return non-zero if error occures
readExpression proc uses esi ebx, outputAddr: ptr dword ; todo need test
	assume esi: ptr Token
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
			.if bl != TRIE_VAR && bl != TRIE_LABEL
.data
	invalidSymbolTypeErr byte "invalid symbol type: %s", 10, 0
.code
				invoke crt_printf, addr invalidSymbolTypeErr, addr [esi].tokenStr
				mov eax, 2
				ret
			.endif
			mov eax, (TrieNode ptr [eax]).nodeVal
			mov outputAddr, eax
		.else ; first pass
			mov outputAddr, 0 ; dummy value
		.endif
		add esi, type Token
	.elseif [esi].tokenType == TOKEN_INTEGER || [esi].tokenType == TOKEN_CHAR
		mov eax, [esi].tokenValue
		mov outputAddr, eax
		add esi, type Token
	.else
.data
	unrecognizedExpression byte "unrecognized expression", 10, 0
.code
		invoke crt_printf, addr unrecognizedExpression
		mov eax, 3
		ret
	.endif
	mov eax, 0
	assume esi: nothing
	ret
readExpression endp

end