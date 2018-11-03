.386
.model flat, stdcall
option casemap:none

include g:\masm32\include\windows.inc
include g:\masm32\include\kernel32.inc
include g:\masm32\include\masm32.inc
include g:\masm32\include\msvcrt.inc
includelib g:\masm32\lib\kernel32.lib
includelib g:\masm32\lib\masm32.lib
includelib g:\masm32\lib\msvcrt.lib


RegInMemRegRmValue proto, reg: dword
ScaleInSibValue proto, scale: dword
IndexInSibValue proto, index: dword
EncodeMrrSib proto, memBaseReg: dword, memScale: dword, memIndexReg: dword

; headers
AddMemReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
AddRegReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
AddRegMem proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
AddRegImm proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
AddMemImm proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
AndMemReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
AndRegReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
AndRegMem proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
AndRegImm proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
AndMemImm proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
CmpMemReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
CmpRegReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
CmpRegMem proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
CmpRegImm proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
CmpMemImm proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
MovMemReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
MovRegReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
MovRegMem proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
MovRegImm proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
MovMemImm proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
OrMemReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
OrRegReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
OrRegMem proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
OrRegImm proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
OrMemImm proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
SubRegImm proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
SubMemImm proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
SubMemReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
SubRegReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
SubRegMem proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
XorMemReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
XorRegReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
XorRegMem proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
XorRegImm proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
XorMemImm proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
TestRegReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
TestMemReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
TestRegImm proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
TestMemImm proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
LeaRegMem proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
DecReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
DecMem proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
IncReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
IncMem proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
NegReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
NegMem proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
NotReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
NotMem proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
PopReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
PopMem proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
PushReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
PushMem proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
PushImm proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
CallReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
CallMem proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
RetOnly proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
JmpReg proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
JmpRel proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
JmpMem proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte
JzRel proto, memBaseReg: dword, memScale: dword, memIndexReg: dword, memDisplacement: dword, immediateValue: dword, sourceReg: dword, destinationReg: dword, writeTo: ptr byte, sizeOut: ptr byte

