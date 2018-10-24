MaxStackCount equ 5000

Operator struct
	operatorType byte ?
	priority dword ?
Operator ends

readExpression proto, outputAddr: ptr dword