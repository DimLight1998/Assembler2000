MaxOperandCount equ 1000

OPER_REG equ 1
OPER_IMM equ 2
OPER_MEM equ 3

Operand struct
	operandType byte ?
	baseReg dword ? ; reg stores here
	scale dword ?
	indexReg dword ?
	displacement dword ? ; imm stores here
Operand ends

externdef operands: Operand, curOp: dword

readOperand proto, operAddr: ptr Operand