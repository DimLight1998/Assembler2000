.import "User32.dll", MessageBoxA
.import "Kernel32.dll", ExitProcess

.data
caption: .asciz "Hello"
content: .asciz "Hello, Windows GUI!"

.text
main:
    # push from right to left
	pushl $0 # MB_OK
	pushl $caption
	pushl $content
	pushl $0
	call MessageBoxA
	addl $16, %esp

	pushl $0
	call ExitProcess