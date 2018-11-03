.import "msvcrt.dll", printf
.import "kernel32.dll", ExitProcess
.data
helloWorldMsg: .asciz "Hello world!"
stringPattern: .asciz "%s\n"
.text
main:
	pushl $helloWorldMsg
	pushl $stringPattern
	call printf
	addl $8,%esp
	pushl $0
	call ExitProcess