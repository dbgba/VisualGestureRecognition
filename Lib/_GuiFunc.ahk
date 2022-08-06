; 修改窗口标题图标
ChangeWindowIcon(IconFile, hWnd:="", IconNumber:=1, IconSize:=32) {
	hWnd :=hWnd?hWnd:WinExist("A")
	if (!hWnd)
		Return "The window does not exist!"
	if not IconFile~="\.ico$"
		hIcon := LoadIcon(IconFile, IconNumber, IconSize)
	else
		hIcon := DllCall("LoadImage", "Uint", 0, "Str", IconFile, "Uint", 1, "int", 0, "int", 0, "Uint", 0x10)  ; LR_LOADFROMFILE:=0x10
	if (!hIcon)
		Return "Icon file does not exist!"
	; WM_SETICON:=0x80，ICON_SMALL2:=0，ICON_BIG:=1
	SendMessage, 0x80, 0, hIcon,, ahk_id %hWnd%  ; 设置窗口的小图标
	SendMessage, 0x80, 1, hIcon,, ahk_id %hWnd%  ; 将窗口的大图标设置为同一个
}

; 获取exe/dll/icl文件中指定图标找返回
LoadIcon(Filename, IconNumber, IconSize) {
	if DllCall("PrivateExtractIcons", "Str", Filename, "int", IconNumber-1, "int", IconSize, "int", IconSize
		, "Ptr*", hIcon, "Uint*", 0, "Uint", 1, "Uint", 0, "Ptr")
	Return hIcon
}

; 获取音频文件长度 By SKAN  https://www.autohotkey.com/forum/viewtopic.php?p=361791#361791
GetAudioDuration(mFile) {
	VarSetCapacity(DN, 16), DLLFunc := "winmm.dll\mciSendString" (A_IsUnicode ? "W" : "A")
	, DllCall(DLLFunc, "Str", "Open """ mFile """ Alias MP3", "Uint", 0, "Uint", 0, "Uint", 0)
	, DllCall(DLLFunc, "Str", "Status MP3 Length", "Str", DN, "Uint", 16, "Uint", 0)
	, DllCall(DLLFunc, "Str", "Close MP3", "Uint", 0, "Uint", 0, "Uint",0)
	Return DN
}

; 给手势或语音调用的脚本，添加或修改备注内容
FileWriteLine(_File, _NoteContent:="") {
	if FileExist(_File) {
		FileRead, _FileData, %_File%
		_ScriptHeader := "`; 【反馈或注释，勿动此行。请在下方添加新脚本内容】："
		, _FirstLine := SubStr(_FileData ,1, InStr(_FileData ,"`n"))  ; 第一行内容
		if (InStr(_FirstLine, _ScriptHeader)!=0)  ; 第一行找到时删除第一行
			_FileData := RegExReplace(_FileData, "`a)^\R*.*\R","$1")  ; 删除第一行内容

		_FileData := _ScriptHeader . _NoteContent . "`r`n" . _FileData  ; 保存内容
		FileDelete, %_File%
		FileAppend, %_FileData%, %_File%, UTF-8
	}
}

; 滚动编辑控件的内容到最后一行直到插入符号可见
ScrollCaret(Hwnd) {
	ControlFocus, , ahk_id %Hwnd%
	SendMessage, 0x00B7, 0, 0, , ahk_id %Hwnd%  ; EM_SCROLLCARET := 0x00B7
	SendMessage, 0x00B1, -2, -1, , ahk_id %Hwnd%  ; EM_SETSEL := 0x00B1
}

; 临时ToolTip提示
Tip(s:="", Priority:="") {
	SetTimer %A_ThisFunc%, % s="" ? "Off" : "-" (Priority="" ? 1800 : Priority)
	ToolTip, %s%, , , 17
}

; 用剪贴板缓存选中文本
GetSelectedString(){
	BlockInput On
	lastClip:=ClipboardAll
	Clipboard:=""
	SendInput ^{vk2Dsc152}
	BlockInput Off
	ClipWait 1
	if (Clipboard=="")
		Return
	string:=Trim(Clipboard,"`r`n")
	Clipboard:=lastClip
	if !ErrorLevel&&string
		Return string
}

; Modified from: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=4635
TaskDialog(Main, Extra := 0, Title := "", Buttons := 0, Icon := 0, Parent := 0) {
	Static S_OK := 0, TDBTNS := {OK: 1, YES: 2, NO: 4, CANCEL: 8, RETRY: 16, CLOSE: 32}
			, TDICON := {1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 8, 9: 9
				, WARN: 1, ERROR: 2, INFO: 3, SHIELD: 4, BLUE: 5, YELLOW: 6, RED: 7, GREEN: 8, GRAY: 9}
	If ((DllCall("Kernel32.dll\GetVersion", "UInt") & 0xFF) < 6) {
		MsgBox, 16, %A_ThisFunc%, 此功能需要 Windows Vista 或更高版本！
		Return
	}
	BTNS := 0
	if Buttons Is Integer
		BTNS := Buttons & 0x3F
	else
		For Each, Btn In StrSplit(Buttons, "|")
			BTNS |= (B := TDBTNS[Btn]) ? B : 0
	ICO := (I := TDICON[Icon]) ? 0x10000 - I : 0
	if (S_OK = DllCall("Comctl32.dll\TaskDialog"
					, "Ptr",  Parent
					, "Ptr",  0
					, "WStr", Title = "" ? A_ScriptName : Title
					, "WStr", Main
					, Extra = 0 ? "Ptr" : "WStr",  Extra
					, "UInt", BTNS
					, "Ptr",  ICO
					, "IntP", Result))
		Return Result
}

; Modified from: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=3851&start=360#p458266
SelectMenu(Control) {
	Global
	Loop % Navigation.Length()
		SetControlColor("808080", Navigation[A_Index])  ; Color of the unchecked button on the left

	CurrentMenu := Control
	, SetControlColor("237FFF", Control)  ; Color of the selected button on the left
	GuiControl, Move, pMenuSelect, % "x" 0 " y" (32*SubStr(Control, 9, 2))-20 " w" 4 " h" 24
	GuiControl, Choose, %hTabControl%, % SubStr(Control, 9, 2)
	GuiControl,, PageTitle, % Navigation[SubStr(Control, 9, 2)]
}

WM_MOUSEMOVE(wParam, lParam, Msg, Hwnd) {
	Global hMenuSelect
	Static hover := {}

	if (wParam = "timer") {
		MouseGetPos,,,, hControl, 2
		if (hControl != hwnd) && (hControl != hMenuSelect) {
			SetTimer,, Delete
			GuiControl, Move, pMenuHover, x-9999 y-9999
			OnMessage(0x200, "WM_MOUSEMOVE")
			, hover[hwnd] := False
		}
	 } else {
		if (InStr(A_GuiControl, "MenuItem") = True) {
			GuiControl, Move, pMenuHover, % "x" 0 " y" (32*SubStr(A_GuiControl, 9, 2))-24
			GuiControl, MoveDraw, pMenuHover
			hover[hwnd] := True
			, OnMessage(0x200, "WM_MOUSEMOVE", 0)
			, timer := Func(A_ThisFunc).Bind("timer", "", "", hwnd)
			SetTimer %timer%, 15
		} else if (InStr(A_GuiControl, "MenuItem") = False)
			GuiControl, Move, pMenuHover, x-9999 y-9999
	}
}

SetControlColor(Color, Control) {
	GuiControl, +c%Color%, %Control%

	; Required due to redrawing issues with the Tab2 control
	GuiControlGet, ControlText,, %Control%
	GuiControlGet, ControlHandle, Hwnd, %Control%
	DllCall("SetWindowText", "Ptr", ControlHandle, "Str", ControlText)
	GuiControl, MoveDraw, %Control%
}

SetPixelColor(Color, Handle) {
	VarSetCapacity(BMBITS, 4, 0), Numput("0x" . Color, &BMBITS, 0, "Uint")
	, hBM := DllCall("Gdi32.dll\CreateBitmap", "int", 1, "int", 1, "Uint", 1, "Uint", 24, "Ptr", 0)
	, hBM := DllCall("User32.dll\CopyImage", "Ptr", hBM, "Uint", 0, "int", 0, "int", 0, "Uint", 0x2008)
	, DllCall("Gdi32.dll\SetBitmapBits", "Ptr", hBM, "Uint", 3, "Ptr", &BMBITS)
	return DllCall("User32.dll\SendMessage", "Ptr", Handle, "Uint", 0x172, "Ptr", 0, "Ptr", hBM)
}

; Replace the standard button with a web button style, compatible to XP system. If Gui turns on -DPIScale, you need to set the last parameter "DPIScale" of HtmlButton to non-0 to fix the match.
Class HtmlButton {
	__New(ButtonGlobalVar, ButtonName, gLabelFunc, OptionsOrX:="", y:="", w:=78 , h:=26, GuiLabel:="", TextColor:="001C30", DPIScale:=False) {
		Static Count:=0
		f := A_Temp "\" A_TickCount "-tmp" ++Count ".DELETEME.html"

		Html_Str =
		(
			<!DOCTYPE html><html><head>
			<meta http-equiv="X-UA-Compatible" content="IE=edge">
			<style>body {overflow-x:hidden;overflow-y:hidden;}
				button { color: #%TextColor%;
					background-color: #F4F4F4;
					border-radius:2px;
					border: 1px solid #A7A7A7;
					cursor: pointer; }
				button:hover {background-color: #BEE7FD;}
			</style></head><body><body oncontextmenu="return false">
			<button id="MyButton%Count%" style="position:absolute;left:0px;top:0px;width:%w%px;height:%h%px;font-size:12px;font-family:'Microsoft YaHei UI';">%ButtonName%</button></body></html>
		)
		if (OptionsOrX!="")
			if OptionsOrX is Number
				x := "x" OptionsOrX
			 else
				Options := " " OptionsOrX
		(y != "" && y := " y" y)
		Gui, %GuiLabel%Add, ActiveX, %  x . y . " w" w " h" h " v" ButtonGlobalVar . Options, Shell.Explorer
		FileAppend, %Html_Str%, %f%
		%ButtonGlobalVar%.Navigate("file://" . f)
		, this.Html_Str := Html_Str
		, this.ButtonName := ButtonName
		, this.gLabelFunc := gLabelFunc
		, this.Count := Count 
		, %ButtonGlobalVar%.silent := True
		, this.ConnectEvents(ButtonGlobalVar, f)
		if !DPIScale
			%ButtonGlobalVar%.ExecWB(63, 1, Round((A_ScreenDPI/96*100)*A_ScreenDPI/96) ) ; Fix ActiveX control DPI scaling
	}

	Text(ButtonGlobalVar, ButtonText) {
		Html_Str := StrReplace(this.Html_Str, ">" this.ButtonName "</bu", ">" ButtonText "</bu")
		FileAppend, %Html_Str%, % f := A_Temp "\" A_TickCount "-tmp.DELETEME.html"
		%ButtonGlobalVar%.Navigate("file://" . f)
		, this.ConnectEvents(ButtonGlobalVar, f)
	}

	ConnectEvents(ButtonGlobalVar, f) {
		While %ButtonGlobalVar%.readystate != 4 or %ButtonGlobalVar%.busy
			Sleep 5
		this.MyButton := %ButtonGlobalVar%.document.getElementById("MyButton" this.Count)
		, ComObjConnect(this.MyButton, this.gLabelFunc)
		FileDelete, %f%
	}
}