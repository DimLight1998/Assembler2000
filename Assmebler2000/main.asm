include common.inc
include LineControl.inc
include Tokenizer.inc

.code
main proc
	invoke tmpLoadInput
	invoke loadLine
	invoke tmpTestTokenize
	invoke ExitProcess, 0
main endp
end main