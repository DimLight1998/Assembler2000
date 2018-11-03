.import "User32.dll", GetModuleHandleA, LoadIconA
.import "Kernel32.dll"

COLOR_WINDOW            = 5
IDI_APPLICATION         = 32512
IDC_ARROW               = 32512
INT_MIN                 = -2147483648
COMMON_WINDOW_STYLE     = 294584320
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
MsgLPrivate:            .long 0       

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
    addl    $4, %esp

    movl    %eax, HInstance
    movl    %eax, MainWinHInstance

    pushl   $IDI_APPLICATION
    pushl   $0
    call    LoadIconA
    addl    $8, %esp
    movl    %eax, MainWindowHIcon
    
    pushl   $IDC_ARROW
    pushl   $0
    call    LoadCursorA
    addl    $8, %esp

    pushl   $MainWin
    call    RegisterClassA
    addl    $4, %esp

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
    addl    $48, %esp
    movl    %eax, HMainWnd

    pushl   $5
    pushl   HMainWnd
    call    ShowWindow
    addl    $8, %esp
    pushl   HMainWnd
    call    UpdateWindow
    addl    $4, %esp

    pushl   $0
    pushl   $GreetTitle
    pushl   $GreetText
    pushl   HMainWnd
    call    MessageBoxA
    addl    $16, %esp

MessageLoop:
    pushl   $0
    pushl   $0
    pushl   $0
    pushl   $Msg
    call    GetMessageA
    addl    $16, %esp

    cmpl    $0, %eax
    jz      ExitProgram
    
    pushl   $Msg
    call    DispatchMessageA
    addl    $4, %esp
    jmp     MessageLoop

ExitProgram:
    pushl   $0
    call    ExitProcess
    addl    $4, %esp

WinProc:
    pushl   %ebp
    movl    %esp, %ebp

    movl    8(%ebp), %eax

TEST_EAX_EQ_WM_LBUTTONDOWN:
    cmpl    $WM_LBUTTONDOWN, %eax
    jz      EAX_EQ_LBUTTONDOWN
    jmp     TEST_EAX_EQ_WM_CREATE
EAX_EQ_WM_LBUTTONDOWN:
    pushl   $0
    pushl   $PopupTitle
    pushl   $PopupText
    pushl   4(%ebp)
    call    MessageBoxA
    addl    $16, %esp
    jmp     WINPROC_EXIT
TEST_EAX_EQ_WM_CREATE:
    cmpl    $WM_CREATE, %eax
    jz      EAX_EQ_WM_CREATE
    jmp     TEST_EAX_EQ_WM_CLOSE
EAX_EQ_WM_CREATE:
    pushl   $0
    pushl   $AppLoadMsgTitle
    pushl   $AppLoadMsgText
    pushl   4(%ebp)
    call    MessageBoxA
    addl    $16, %esp
    jmp     WINPROC_EXIT
TEST_EAX_EQ_WM_CLOSE:
    cmpl    $WM_CLOSE, %eax
    jz      EAX_EQ_WM_CLOSE
    jmp     TEST_EAX_EQ_WM_KEYDOWN
EAX_EQ_WM_CLOSE:
    pushl   $0
    pushl   $WindowName
    pushl   $CloseMsg
    pushl   4(%ebp)
    call    MessageBoxA
    addl    $16, %esp
    
    pushl   $0
    call    PostQuitMessage
    addl    $4, %esp
TEST_EAX_EQ_WM_KEYDOWN:
    cmpl    $WM_CREATE, %eax
    jz      EAX_EQ_WM_KEYDOWN
    jmp     WINPROC_ELSE
EAX_EQ_WM_KEYDOWN:
    pushl   $0
    pushl   $IAmHitTitle
    pushl   $IAmHitText
    pushl   4(%ebp)
    call    MessageBoxA
    addl    $16, %esp
    jmp     WINPROC_EXIT
WINPROC_ELSE:
    pushl   16(%ebp)
    pushl   12(%ebp)
    pushl   8(%ebp)
    pushl   4(%ebp)
    call    DefWindowProcA
    addl    $16, %esp
    jmp     WINPROC_EXIT
WINPROC_EXIT:
    movl    %ebp, %esp
    popl    %ebp
    ret
