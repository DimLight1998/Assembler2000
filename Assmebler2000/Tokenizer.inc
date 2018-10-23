TokenStringLength equ 200
; todo token too long warning

TOKEN_SYMBOL equ 1
TOKEN_LABEL equ 2
TOKEN_INTEGER equ 3
TOKEN_STRING equ 4
TOKEN_CHAR equ 5
TOKEN_COMMA equ 6
TOKEN_PERCENT equ 7
TOKEN_DOLLAR equ 8
TOKEN_LEFTBRA equ 9
TOKEN_RIGHTBRA equ 10
TOKEN_MEM_LEFTBRA equ 11
TOKEN_MEM_RIGHTBRA equ 12
TOKEN_MEM_COMMA equ 13
TOKEN_ENDLINE equ 14

Token struct
	tokenType byte ?
	tokenValue dword ?
	tokenStr byte TokenStringLength dup(?)
Token ends

externdef tokenSize: dword, tokens: Token

tokenizeLine proto
assemble proto
tmpTestSymbol proto
tmpTestInteger proto
tmpTestChar proto
tmpTestString proto
tmpTestTokenize proto