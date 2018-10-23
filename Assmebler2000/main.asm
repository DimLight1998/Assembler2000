include common.inc
include LineControl.inc
include Tokenizer.inc
include SymbolDict.inc

.code
main proc
	invoke assemble
	invoke ExitProcess, 0
main endp
end main