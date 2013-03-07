  .386
  .model  flat,stdcall
  option  casemap:none

include  windows.inc
include  user32.inc
include  gdi32.inc
include  kernel32.inc
includelib  user32.lib
includelib  gdi32.lib
includelib  kernel32.lib

IDC_Edit     equ         100

red          equ         0ffh
green        equ         0ff00h
yellow       equ         0ffffh
TimerID      equ         74
;Timer value(millisecond)
Time         equ         200
;Mouse stay Time*wait_times
wait_times   equ         10


WndProc proto   :HWND,:UINT,:WPARAM,:LPARAM 
DebugDlgProc proto   :HWND,:UINT,:WPARAM,:LPARAM 
debug   proto   :HWND
;**********************************************
	.DATA
;Deug------------------------------------------
DebugDlgName      db          'DebugDlg',0	
szTest        db          601 dup (0)	
posTest       dd          0
;----------------------------------------------	
ClassName     db   				'Press'
AppName       db          'Press Run/Stop',0
szString      db          'TekScope',0
;szButton      db          'Run / Stop',0
;middle coord. of button Hi->y Lo->x
posButton     dd          001B002Bh
;posButton2    dd          001B002Bh
;button coord. on the screen <x,y>
run_button_crd    POINT       <580,210>
close_button_crd  POINT       <580,458>
run           db          TRUE
sub_menu      db          3                    
sub_menu_item db          6
hInstance     HINSTANCE	 	?
hwnd					HWND			 	?
CommandLine   LPSTR       ?
color         dd          green
;Mouse stay counter
stay_count    db          0
wc            WNDCLASSEX	<30h,?,?,0,0,?,?,?,?,0,offset ClassName,?>
;typedef struct _WNDCLASSEX {    // wc  
;    UINT    cbSize; 
;    UINT    style; 
;    WNDPROC lpfnWndProc; 
;    int     cbClsExtra; 
;    int     cbWndExtra; 
;    HANDLE  hInstance; 
;    HICON   hIcon; 
;    HCURSOR hCursor; 
;    HBRUSH  hbrBackground; 
;    LPCTSTR lpszMenuName; 
;    LPCTSTR lpszClassName; 
;    HICON   hIconSm; 
;} WNDCLASSEX; 

;APP coord. on the screen
window_crd    RECT        <?>
;typedef struct _RECT {    // rc  
;    LONG left; 
;    LONG top; 
;    LONG right; 
;    LONG bottom; 
;} RECT; 

;Mouse coord.
mouse_crd     POINT       <?>
;typedef struct tagPOINT { // pt  
;    LONG x; 
;    LONG y; 
;} POINT; 

msg           MSG					<?>
;typedef struct tagMSG {     // msg  
;    HWND   hwnd;	 
;    UINT   message; 
;    WPARAM wParam; 
;    LPARAM lParam; 
;    DWORD  time; 
;    POINT  pt; 
;} MSG; 


	.CODE
start:  invoke   GetModuleHandle,NULL
			  mov      hInstance,eax
			  invoke   GetCommandLine
			  mov      CommandLine,eax
			  mov 		 wc.style,CS_HREDRAW or CS_VREDRAW
			  mov      wc.lpfnWndProc,offset WndProc
			  mov      eax,hInstance
			  mov      wc.hInstance,eax
			  mov      wc.hbrBackground,COLOR_WINDOW+1
			  invoke   LoadIcon,NULL,IDI_APPLICATION
			  mov 	   wc.hIcon,eax
			  mov      wc.hIconSm,eax
			  invoke   LoadCursor,NULL,IDC_ARROW
			  mov 		 wc.hCursor,eax
			  invoke   RegisterClassEx,offset wc
			  invoke   CreateWindowEx,WS_EX_TOPMOST,offset ClassName,offset AppName, \
			   	       WS_SYSMENU or WS_MINIMIZEBOX,50,80,100,100,0,0,hInstance,NULL
        ;HWND CreateWindowEx(
        ;
        ;    DWORD dwExStyle,	// extended window style
        ;    LPCTSTR lpClassName,	// pointer to registered class name
        ;    LPCTSTR lpWindowName,	// pointer to window name
        ;    DWORD dwStyle,	// window style
        ;    int x,	// horizontal position of window
        ;    int y,	// vertical position of window
        ;    int nWidth,	// window width
        ;    int nHeight,	// window height
        ;    HWND hWndParent,	// handle to parent or owner window
        ;    HMENU hMenu,	// handle to menu, or child-window identifier
        ;    HINSTANCE hInstance,	// handle to application instance
        ;    LPVOID lpParam 	// pointer to window-creation data
        ;   );
        
        mov      hwnd,eax
			  invoke   ShowWindow,hwnd,SW_SHOWDEFAULT
			  invoke   UpdateWindow,hwnd

.while   TRUE
         invoke  GetMessage,offset msg,NULL,0,0
         ;BOOL GetMessage(
         ;
         ;    LPMSG lpMsg,	// address of structure with message
         ;    HWND hWnd,	// handle of window
         ;    UINT wMsgFilterMin,	// first message
         ;    UINT wMsgFilterMax 	// last message
         ;   );
.break   .if     !eax
         invoke  TranslateMessage,offset msg
         invoke  DispatchMessage,offset msg    
.endw 
         mov     eax,msg.wParam
         invoke  ExitProcess,eax
         
         
;Draw color to show the state, green:idle yellow:runnung red:after run 
DrawRec proc     hWnd:HWND
        local    PS:PAINTSTRUCT
;        typedef struct tagPAINTSTRUCT { // ps  
;				    HDC  hdc; 
;    				BOOL fErase; 
;    				RECT rcPaint; 
;    				BOOL fRestore; 
;    				BOOL fIncUpdate; 
;    				BYTE rgbReserved[32]; 
;				} PAINTSTRUCT; 

        local    hdc:HDC
        local    newPen:DWORD
        local    oldPen:DWORD
        local    newBrush:HBRUSH
        local    oldBrush:HBRUSH
        
        invoke   BeginPaint,hWnd,addr PS
        mov      hdc,eax

        invoke   CreatePen,PS_SOLID,1,color
;       HPEN CreatePen(
;            int fnPenStyle,	// pen style 
;            int nWidth,	// pen width  
;            COLORREF crColor 	// pen color 
;           );	

        mov      newPen,eax
        invoke   SelectObject,hdc,eax
        mov      oldPen,eax
        invoke   CreateSolidBrush,color
        mov      newBrush,eax 
        invoke   SelectObject,hdc,eax
        mov      oldBrush,eax
        invoke   Rectangle,hdc,0,0,200,200
        invoke   SelectObject,hdc,oldPen
        invoke   DeleteObject,newPen
        invoke   SelectObject,hdc,oldBrush
        invoke   DeleteObject,newBrush
        invoke   EndPaint,hWnd,addr PS
        ret
DrawRec endp


;Execute target menu item (ex:Run/Stop). Wait 1 sec. let item show. 
;Get hWnd from mouse pos. and send mouse left click. Wait 1 sec.
;Send mouse left click to close item
press       proc
        local    hWnd1:HWND
        local    hWnd2:HWND
        local    id:DWORD
        local    szClass:DWORD
        invoke   FindWindow,NULL,addr szString
        mov      hWnd1,eax
;        invoke   SetForegroundWindow,hWnd1
;        invoke   SetActiveWindow,hWnd1
;Debug----------------------------------   
        invoke   debug,hWnd1   
;---------------------------------------  
        invoke   GetMenu,hWnd1
        mov      hWnd2,eax 
         
        invoke   debug,hWnd2

        invoke   GetSubMenu,hWnd2,sub_menu
        mov      hWnd2,eax
        
        invoke   debug,hWnd2

        invoke   GetMenuItemID,hWnd2,sub_menu_item
        mov      id,eax
        invoke   PostMessage,hWnd1,WM_COMMAND,id,0
        
        invoke   Sleep,1000
        invoke   WindowFromPoint,run_button_crd.x,run_button_crd.y
        mov      hWnd1,eax
        
        invoke   debug,hWnd1
;        invoke   SetCursorPos,button_crd.x,button_crd.y
        
        invoke   PostMessage,hWnd1,WM_LBUTTONDOWN,MK_LBUTTON,posButton
        invoke   PostMessage,hWnd1,WM_LBUTTONUP,MK_LBUTTON,posButton

        invoke   Sleep,1000
        invoke   WindowFromPoint,close_button_crd.x,close_button_crd.y
        mov      hWnd1,eax
        
        invoke   debug,hWnd1

        invoke   PostMessage,hWnd1,WM_LBUTTONDOWN,MK_LBUTTON,posButton
        invoke   PostMessage,hWnd1,WM_LBUTTONUP,MK_LBUTTON,posButton

;Debug----------------------------------       
        invoke   DialogBoxParam,hInstance,offset DebugDlgName,hwnd,addr DebugDlgProc,NULL 
        invoke   SetTimer,hwnd,TimerID,Time,NULL
;---------------------------------------
        ret
press endp

		 
WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
;When window create, create Timer and set.
.if     uMsg==WM_CREATE
        invoke   SetTimer,hWnd,TimerID,Time,NULL
;				UINT SetTimer(
;
;       HWND hWnd,	// handle of window for timer messages
;       UINT nIDEvent,	// timer identifier
;       UINT uElapse,	// time-out value
;       TIMERPROC lpTimerFunc 	// address of timer procedure
;       );
        
.elseif uMsg==WM_TIMER
;Find mouse in the APP window range True or False (Not include window title)
;***********************************************************************
        invoke   GetWindowRect,hWnd,offset window_crd
;       BOOL GetWindowRect(
;       HWND hWnd,	// handle of window
;       LPRECT lpRect 	// address of structure for window coordinates
;       );

        invoke   GetCursorPos,offset mouse_crd
        
        mov      eax,mouse_crd.y
        mov      ecx,window_crd.top
        add      ecx,25
        cmp      ecx,eax
;				Syntax
;       cmp <reg>,<reg>
;       cmp <reg>,<mem>
;       cmp <mem>,<reg>
;       cmp <reg>,<con> 
        jg         exit
        cmp      window_crd.bottom,eax
        jl       exit
        mov      eax,mouse_crd.x
        cmp      window_crd.left,eax
        jg       exit
        cmp      window_crd.right,eax
        jl       exit				
;***********************************************************************

;When stay_count >= wait_times(mouse stay time over setting), let button press and set flag run FALSE 
;***********************************************************************				
        inc      stay_count
        .if   stay_count >= wait_times
              .if  run==FALSE
                   mov      stay_count,wait_times                 
              .else 
                   mov      run,FALSE     	     
			             mov      color,red
                   invoke   InvalidateRect,hWnd,0,0
           ;       BOOL InvalidateRect(
           ;       HWND hWnd,	// handle of window with changed update region  
           ;       CONST RECT *lpRect,	// address of rectangle coordinates 
           ;       BOOL bErase	// erase-background flag 
           ;       );
	                 invoke   press
              .endif

        .else        
        mov      color,yellow
        invoke   InvalidateRect,hWnd,0,0   
        .endif
;***********************************************************************
.elseIf uMsg==WM_PAINT
        invoke   DrawRec,hWnd			
			
.elseif uMsg==WM_DESTROY
			  invoke   PostQuitMessage,NULL
.else
        invoke   DefWindowProc,hWnd,uMsg,wParam,lParam
        ret
.endif
        xor      eax,eax
        ret

exit:   
;Reset
        mov      stay_count,0
        mov      color,green
        invoke   InvalidateRect,hWnd,0,0
        mov      run,TRUE
        xor      eax,eax
        ret
        
WndProc endp


;Debug dialog to show the debug imformation in string
;*Need to modify store string.(ex:szTest)
DebugDlgProc proc hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
         LOCAL    nWinSize:RECT
         LOCAL    hWndEdit:HWND
.if uMsg==WM_INITDIALOG
         invoke   KillTimer,hwnd,TimerID
;initial pos. of result string
         mov      posTest,0
;set edit range match window                 
         invoke   GetDlgItem,hWnd,IDC_Edit
         mov      hWndEdit,eax
         invoke   GetClientRect,hWnd,addr nWinSize
         mov      eax,nWinSize.bottom
         mov      ecx,nWinSize.right
         sub      eax,nWinSize.top
         sub      ecx,nWinSize.left
         invoke   MoveWindow,hWndEdit,0,0,ecx,eax,TRUE
         invoke   SetDlgItemText,hWnd,IDC_Edit,addr szTest
.elseif uMsg==WM_CLOSE
         invoke   EndDialog,hWnd,NULL
.else
         mov      eax,FALSE
         ret   
.endif
         mov      eax,TRUE
         ret
DebugDlgProc endp


;For Debug use. Translate value into string (8bits inital)
;*Need declare a string to store result.(ex:szTest)
debug   proc   uses edi esi x1:DWORD
        local    show_bit:DWORD
        local    shift:BYTE
        mov      show_bit,8
        mov      edx,offset szTest
        add      edx,posTest
        
.while  show_bit > 0
        mov      eax,show_bit
        mov      shift,al  
;from 7 to 0             
        sub      shift,1
;4bits per char -> shl 2
        shl      shift,2 
        mov      eax,x1
        mov      cl,shift                  
        shr      eax,cl
        and      al,0fh
.if     al > 9
        add      al,37h
.else
        add      al,'0'
.endif
        mov      [edx],al
        inc      edx
        dec      show_bit
.endw        
;add Cr
        mov      eax,13       
        mov      [edx],eax
        inc      edx
;add Lf
        mov      eax,10    
        mov      [edx],eax
        inc      edx
;add end string        
        mov      eax,0    
        mov      [edx],eax
        inc      edx
;8bits + 2 chars        
        add      posTest,10
        
        ret
debug endp  

end 	 start
