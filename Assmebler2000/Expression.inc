MaxStackCount equ 1000

Operator struct
	operatorType byte ?
	priority dword ?
Operator ends

readExpression proto, outputAddr: ptr dword