.import "User32.dll",   LoadIconA
.import "User32.dll",   LoadCursorA
.import "User32.dll",   RegisterClassA
.import "User32.dll",   CreateWindowExA
.import "User32.dll",   ShowWindow
.import "User32.dll",   UpdateWindow
.import "User32.dll",   MessageBoxA
.import "User32.dll",   GetMessageA
.import "User32.dll",   DispatchMessageA
.import "User32.dll",   PostQuitMessage
.import "User32.dll",   DefWindowProcA
.import "Kernel32.dll", ExitProcess
.import "Kernel32.dll", GetModuleHandleA
.import "msvcrt.dll",   printf


COLOR_WINDOW            = 5
IDI_APPLICATION         = 32512
IDC_ARROW               = 32512
INT_MIN                 = -2147483647 - 1
COMMON_WINDOW_STYLE     = 0x118f0000
WM_LBUTTONDOWN          = 513
WM_CREATE               = 1
WM_CLOSE                = 16
WM_KEYDOWN              = 256

.data
AppLoadMsgTitle:        .asciz "Application Loaded"
AppLoadMsgText:         .asciz "This window displays when the WM_CREATE message is received"
PopupTitle:             .asciz "Popup Window"
PopupText:              .asciz "This window was activated by a WM_LBUTTONDOWN message"
GreetTitle:             .asciz "Main Window Active"
GreetText:              .asciz "This window is shown immediately after CreateWindow and UpdateWindow are called."
IAmHitTitle:            .asciz "Welcome"
IAmHitText:             .asciz "You press a key!"
CloseMsg:               .asciz "Bye"
ErrorTitle:             .asciz "Error"
WindowName:             .asciz "ASM Windows App"
ClassName:              .asciz "ASMWin"

MainWin:
MainWinStyle:           .long 0
MainWinLpFnWndProc:     .long WinProc 
MainWinCbClsExtra:      .long 0
MainWinCbWndExtra:      .long 0
MainWinHInstance:       .long 0
MainWinHIcon:           .long 0
MainWinHCursor:         .long 0
MainWinHbrBackground:   .long COLOR_WINDOW
MainWinLpszMenuName:    .long 0
MainWinLpszClassName:   .long ClassName

Msg:
MsgHwnd:                .long 0    
MsgMessage:             .long 0    
MsgWParam:              .long 0    
MsgLParam:              .long 0    
MsgTime:                .long 0    
MsgPtX:                 .long 0
MsgPtY:                 .long 0

WinRect:                
WinRectLeft:            .long 0
WinRectTop:             .long 0
WinRectRight:           .long 0
WinRectBottom:          .long 0

HMainWnd:               .long 0
HInstance:              .long 0

.text
    pushl   $0
    call    GetModuleHandleA
    
    movl    %eax, HInstance
    movl    %eax, MainWinHInstance

    pushl   $IDI_APPLICATION
    pushl   $0
    call    LoadIconA
    movl    %eax, MainWinHIcon
    
    pushl   $IDC_ARROW
    pushl   $0
    call    LoadCursorA
    movl    %eax, MainWinHCursor

    pushl   $MainWin
    call    RegisterClassA
    
    pushl   $0
    pushl   HInstance
    pushl   $0
    pushl   $0
    pushl   $INT_MIN
    pushl   $INT_MIN
    pushl   $INT_MIN
    pushl   $INT_MIN
    pushl   $COMMON_WINDOW_STYLE
    pushl   $WindowName
    pushl   $ClassName
    pushl   $0
    call    CreateWindowExA
    movl    %eax, HMainWnd

    pushl   $5
    pushl   HMainWnd
    call    ShowWindow
    pushl   HMainWnd
    call    UpdateWindow
    
    pushl   $0
    pushl   $GreetTitle
    pushl   $GreetText
    pushl   HMainWnd
    call    MessageBoxA
    
MessageLoop:
    pushl   $0
    pushl   $0
    pushl   $0
    pushl   $Msg
    call    GetMessageA
    
    cmpl    $0, %eax
    jz      ExitProgram
    
    pushl   $Msg
    call    DispatchMessageA
    jmp     MessageLoop

ExitProgram:
    pushl   $0
    call    ExitProcess
    
WinProc:
    pushl   %ebp
    movl    %esp, %ebp

    movl    12(%ebp), %eax

TEST_EAX_EQ_WM_LBUTTONDOWN:
    cmpl    $WM_LBUTTONDOWN, %eax
    jz      EAX_EQ_WM_LBUTTONDOWN
    jmp     TEST_EAX_EQ_WM_CREATE
EAX_EQ_WM_LBUTTONDOWN:
    pushl   $0
    pushl   $PopupTitle
    pushl   $PopupText
    pushl   8(%ebp)
    call    MessageBoxA
    jmp     WINPROC_EXIT
TEST_EAX_EQ_WM_CREATE:
    cmpl    $WM_CREATE, %eax
    jz      EAX_EQ_WM_CREATE
    jmp     TEST_EAX_EQ_WM_CLOSE
EAX_EQ_WM_CREATE:
    pushl   $0
    pushl   $AppLoadMsgTitle
    pushl   $AppLoadMsgText
    pushl   8(%ebp)
    call    MessageBoxA
    jmp     WINPROC_EXIT
TEST_EAX_EQ_WM_CLOSE:
    cmpl    $WM_CLOSE, %eax
    jz      EAX_EQ_WM_CLOSE
    jmp     TEST_EAX_EQ_WM_KEYDOWN
EAX_EQ_WM_CLOSE:
    pushl   $0
    pushl   $WindowName
    pushl   $CloseMsg
    pushl   8(%ebp)
    call    MessageBoxA
        
    pushl   $0
    call    PostQuitMessage
    jmp     WINPROC_EXIT
TEST_EAX_EQ_WM_KEYDOWN:
    cmpl    $WM_KEYDOWN, %eax
    jz      EAX_EQ_WM_KEYDOWN
    jmp     WINPROC_ELSE
EAX_EQ_WM_KEYDOWN:
    pushl   $0
    pushl   $IAmHitTitle
    pushl   $IAmHitText
    pushl   8(%ebp)
    call    MessageBoxA
    jmp     WINPROC_EXIT
WINPROC_ELSE: 
    pushl   20(%ebp)
    pushl   16(%ebp)
    pushl   12(%ebp)
    pushl   8(%ebp)
    call    DefWindowProcA
    jmp     WINPROC_EXIT
WINPROC_EXIT:
    movl    %ebp, %esp
    popl    %ebp
    ret
