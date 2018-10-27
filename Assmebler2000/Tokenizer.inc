TokenStringLength equ 200
; todo token too long warning

MaxToken equ 1000

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
TOKEN_ASSIGN equ 15

TOKEN_UNARY_NEG equ 16
TOKEN_UNARY_NOT equ 17
TOKEN_UNARY_POS equ 18
TOKEN_UNARY_BIT_NOT equ 37

TOKEN_MUL equ 19 ; *
TOKEN_DIV equ 20 ; /
; TOKEN_MOD same as TOKEN_PERCENT
TOKEN_MOD equ TOKEN_PERCENT ; %
TOKEN_SHL equ 21 ; <<
TOKEN_SHR equ 22 ; >>

TOKEN_BIT_OR equ 23 ; |
TOKEN_BIT_AND equ 24 ; &
TOKEN_BIT_XOR equ 25 ; ^
TOKEN_BIT_ORNOT equ 26 ; !

TOKEN_ADD equ 27 ; +
TOKEN_SUB equ 28 ; -
TOKEN_EQUAL equ 29 ; ==
TOKEN_NOT_EQUAL equ 30 ; !=
TOKEN_LESS equ 31 ; <
TOKEN_GREATER equ 32 ; >
TOKEN_GE equ 33 ; >=
TOKEN_LE equ 34 ; <=

TOKEN_LOGIC_AND equ 35 ; &&
TOKEN_LOGIC_OR equ 36 ; ||


Token struct
	tokenType byte ?
	tokenValue dword ?
	tokenStr byte TokenStringLength dup(?)
Token ends

externdef tokenSize: dword, tokens: Token

tokenizeLine proto
getOpPriority proto, op: dword
tmpTestSymbol proto
tmpTestInteger proto
tmpTestChar proto
tmpTestString proto
tmpTestTokenize proto