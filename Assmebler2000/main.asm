include common.inc
include LineControl.inc
include Tokenizer.inc
include SymbolDict.inc

.code
main proc
	invoke tmpLoadInput
	invoke loadLine
	invoke dictPreprocess
	invoke tmpTestTokenize
	invoke ExitProcess, 0
main endp
end main