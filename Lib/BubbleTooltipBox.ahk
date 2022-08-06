/*
	气泡提示框   ; https://www.autoahk.com/archives/37864
	; https://docs.microsoft.com/en-us/windows/win32/controls/ttm-settitle
	text:提示文本
	x,y:显示坐标
	title:标题
	icon:提示状态图标——>1为信息，2为警告，3为错误
	closeButton:窗口是否显示关闭按钮
	backColor:背景色 格式：0xFFFFFF
	textColor:文本色 格式0x000000
	fontName:字体名称
	fontOptions:字体样式，参数格式同Gui 如 s12 bold
	isBallon:是否为气泡圆角形状
	timeout:显示时长
	maxWidth:窗口最大宽度
*/
BubbleTooltipBox( text, x := "", y := "", title := "", icon := 1, transparent := False, closeButton := False, backColor := "", textColor := 0, fontName := "", fontOptions := "", isBallon := True, timeout := "", maxWidth := 600 ) {
	static ttStyles := (TTS_NOPREFIX := 2) | (TTS_ALWAYSTIP := 1), TTS_BALLOON := 0x40, TTS_CLOSE := 0x80
		, TTF_TRACK := 0x20, TTF_ABSOLUTE := 0x80
		, TTM_SETMAXTIPWIDTH := 0x418, TTM_TRACKACTIVATE := 0x411, TTM_TRACKPOSITION := 0x412
		, TTM_SETTIPBKCOLOR := 0x413, TTM_SETTIPTEXTCOLOR := 0x414
		, TTM_ADDTOOL:= A_IsUnicode ? 0x432 : 0x404
		, TTM_SETTITLE:= A_IsUnicode ? 0x421 : 0x420
		, TTM_UPDATETIPTEXT  := A_IsUnicode ? 0x439 : 0x40C
		, exStyles := (WS_EX_TOPMOST := 0x00000008) | (WS_EX_COMPOSITED := 0x2000000) | (WS_EX_LAYERED := 0x00080000)
		, WM_SETFONT := 0x30, WM_GETFONT := 0x31
	DetectHiddenWindows % ("On", dhwPrev:=A_DetectHiddenWindows)
	(transparent && exStyles |= WS_EX_TRANSPARENT := 0x20)
	, defGuiPrev := A_DefaultGui, lastFoundPrev := WinExist()
	Hwnd := DllCall("CreateWindowEx", "UInt", exStyles, "Str", "tooltips_class32", "Str", ""
		, "UInt", ttStyles | TTS_CLOSE * !!CloseButton | TTS_BALLOON * !!isBallon
		, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr")
	WinExist("ahk_id" . Hwnd)
	if (textColor != "" || backColor != "")
		DllCall("UxTheme\SetWindowTheme", "Ptr", Hwnd, "Ptr", 0, "UShortP", empty := 0)
		, backColor := (StrLen(backColor) < 8 ? "0x" : "") . backColor
		, BC := ((backColor&255)<<16)+(((backColor>>8)&255)<<8)+(backColor>>16) ; rgb -> bgr
		, DllCall("user32\SendMessage", "Uint", Hwnd, "Uint", TTM_SETTIPBKCOLOR, "Uint", BC & 0xFFFFFF, "Uint", 0)

		, textColor := (StrLen(textColor) < 8 ? "0x" : "") . textColor
		, TC := ((textColor&255)<<16)+(((textColor>>8)&255)<<8)+(textColor>>16) ; rgb -> bgr
		, DllCall("user32\SendMessage", "Uint", Hwnd, "Uint", TTM_SETTIPTEXTCOLOR, "Uint",TC & 0xFFFFFF, "Uint", 0)

	if !fontName
		NumPut(VarSetCapacity(info, A_IsUnicode ? 504 : 344, 0), info, 0, "UInt")
		, DllCall("SystemParametersInfo", "UInt", 0x29, "UInt", 0, "Ptr", &info, "UInt", 0)
		, fontName:= StrGet(&info + 52)

	if (fontName || fontOptions) {
		Gui New
		Gui Font, %fontOptions%, %fontName%
		Gui Add, Text, HwndhText
		SendMessage, WM_GETFONT,,,, ahk_id %hText%
		SendMessage, WM_SETFONT, ErrorLevel
		Gui Destroy
		Gui %defGuiPrev%: Default
	}
	if (x = "" || y = "")
		DllCall("GetCursorPos", "Int64P", pt)
	(x = "" && x := (pt & 0xFFFFFFFF) + 15), (y = "" && y := (pt >> 32) + 15)

	, VarSetCapacity(TOOLINFO, sz := 24 + A_PtrSize*6, 0)
	, NumPut(sz, TOOLINFO)
	, NumPut(TTF_TRACK | TTF_ABSOLUTE * !isBallon, TOOLINFO, 4)
	, NumPut(&text, TOOLINFO, 24 + A_PtrSize*3)

	SendMessage, TTM_SETTITLE, icon, &title
	SendMessage, TTM_TRACKPOSITION, , x | (y << 16)
	SendMessage, TTM_SETMAXTIPWIDTH, , maxWidth
	SendMessage, TTM_ADDTOOL, , &TOOLINFO
	SendMessage, TTM_UPDATETIPTEXT, , &TOOLINFO
	SendMessage, TTM_TRACKACTIVATE , True, &TOOLINFO

	if timeout {
		Timer := Func("DllCall").Bind("DestroyWindow", "Ptr", Hwnd)
		SetTimer, %Timer%, -%timeout%
	}
	WinExist("ahk_id" . lastFoundPrev)
	DetectHiddenWindows %dhwPrev%
	Return Hwnd
}

FollowMainWindow(ParentHwnd, BubbleHwnd, Loop:=0) {
	Static Count := 0
	; 当主窗口未激活时，异步监测立即停止气泡提示框显示
	(!WinActive("ahk_id " ParentHwnd) && Count := Loop-1)
	if (++Count!=Loop) {
		_:=Func(A_ThisFunc).Bind(ParentHwnd, BubbleHwnd, Loop)
		SetTimer %_%, -106
		Return True
	}
	WinClose, ahk_id %BubbleHwnd%
	Return False
}