TokenStringLength equ 1000

TOKEN_SYMBOL equ 1
TOKEN_LABEL equ 2

Token struct
	tokenType byte ?
	tokenValue dword ?
	tokenStr byte TokenStringLength dup(?)
Token ends

tokenizeLine proto
tmpTestSymbol proto