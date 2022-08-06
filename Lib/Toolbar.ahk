﻿; Modified from: https://www.autohotkey.com/boards/viewtopic.php?f=64&t=89901
Toolbar_Create(Handler, Buttons, ImageList := "", Options := "Flat List ToolTips", Extra := "", Pos := "", Padding := "", ExStyle := 0x9) {
	Local fShowText, fTextOnly, Styles, hWnd, TBB_Size, cButtons, TBBUTTONS
	, Index, Button, iBitmap, idCommand, fsState, fsStyle, iString, Offset, SIZE, 

	Static TOOLTIPS := 0x100, WRAPABLE := 0x200, FLAT := 0x800, LIST := 0x1000
	, TABSTOP := 0x10000, BORDER := 0x800000, TEXTONLY := 0, BOTTOM := 0x3
	, ADJUSTABLE := 0x20, NODIVIDER := 0x40, VERTICAL := 0x80
	, CHECKED := 1, HIDDEN := 8, WRAP := 32, DISABLED := 0 ; States
	, CHECK := 2, CHECKGROUP := 6, DROPDOWN := 8, AUTOSIZE := 16
	, NOPREFIX := 32, SHOWTEXT := 64, WHOLEDROPDOWN := 128 ; Styles

	StrReplace(Options, "SHOWTEXT", "", fShowText, 1)
	, fTextOnly := InStr(Options, "TEXTONLY")

	, Styles = 0
	Loop Parse, Options, %A_Tab%%A_Space%, %A_Tab%%A_Space% ; Parse toolbar styles
		IfEqual A_LoopField,, Continue
		else Styles |= A_LoopField + 0 ? A_LoopField : %A_LoopField%

	if (Pos != "")
		Styles |= 0x4C ; CCS_NORESIZE | CCS_NOPARENTALIGN | CCS_NODIVIDER

	Gui Add, Custom, ClassToolbarWindow32 hWndhWnd gToolbar_Handler -Tabstop %Pos% %Styles% %Extra%
	Toolbar_Store(hWnd, Handler)

	, TBB_Size := A_PtrSize == 8 ? 32 : 20
	, Buttons := StrSplit(Buttons, "`n")
	, cButtons := Buttons.Length()
	, VarSetCapacity(TBBUTTONS, TBB_Size * cButtons , 0)

	, Index = 0
	Loop %cButtons% {
		Button := StrSplit(Buttons[A_Index], ",", " `t")

		if (Button[1] == "-")
			iBitmap := 0
			, idCommand := 0
			, fsState := 0
			, fsStyle := 1 ; BTNS_SEP
			, iString := -1
		 else {
			Index++
			, iBitmap := (fTextOnly) ? -1 : (Button[2] != "" ? Button[2] - 1 : Index - 1)
			, idCommand := (Button[5]) ? Button[5] : 10000 + Index

			, fsState := InStr(Button[3], "DISABLED") ? 0 : 4 ; TBSTATE_ENABLED
			Loop Parse, % Button[3], %A_Tab%%A_Space%, %A_Tab%%A_Space% ; Parse button states
				IfEqual A_LoopField,, Continue
				else fsState |= %A_LoopField%

			fsStyle := fTextOnly || fShowText ? SHOWTEXT : 0
			Loop Parse, % Button[4], %A_Tab%%A_Space%, %A_Tab%%A_Space% ; Parse button styles
				IfEqual A_LoopField,, Continue
				else fsStyle |= %A_LoopField%

			iString := &(ButtonText%Index% := Button[1])
		}

		Offset := (A_Index - 1) * TBB_Size
		, NumPut(iBitmap, TBBUTTONS, Offset, "Int")
		, NumPut(idCommand, TBBUTTONS, Offset + 4, "Int")
		, NumPut(fsState, TBBUTTONS, Offset + 8, "UChar")
		, NumPut(fsStyle, TBBUTTONS, Offset + 9, "UChar")
		, NumPut(iString, TBBUTTONS, Offset + (A_PtrSize == 8 ? 24 : 16), "Ptr")
	}

	if (Padding)
		SendMessage 0x457, 0, %Padding%,, ahk_id %hWnd% ; TB_SETPADDING

	if (ExStyle) ; 0x9 = TBSTYLE_EX_DRAWDDARROWS | TBSTYLE_EX_MIXEDBUTTONS
		SendMessage 0x454, 0, %ExStyle%,, ahk_id %hWnd% ; TB_SETEXTENDEDSTYLE

	SendMessage 0x430, 0, %ImageList%,, ahk_id %hWnd% ; TB_SETIMAGELIST
	SendMessage % A_IsUnicode ? 0x444 : 0x414, %cButtons%, % &TBBUTTONS,, ahk_id %hWnd% ; TB_ADDBUTTONS

	if (InStr(Options, "VERTICAL")) {
		VarSetCapacity(SIZE, 8, 0)
		SendMessage 0x453, 0, &SIZE,, ahk_id %hWnd% ; TB_GETMAXSIZE
	} else
		SendMessage 0x421, 0, 0,, ahk_id %hWnd% ; TB_AUTOSIZE

	Return hWnd
}

Toolbar_Store(hWnd, Callback := "") {
	Static o := {}
	Return (o[hWnd] != "") ? o[hWnd] : o[hWnd] := Callback
}

Toolbar_Handler(hWnd) {
	Static n := {-2: "Click", -5: "RightClick", -20: "LDown", -713: "Hot", -710: "DropDown"}
	Local Handler, Code, ButtonId, Pos, Text, Event, RECT, Left, Bottom

	Handler := Toolbar_Store(hWnd)

	, Code := NumGet(A_EventInfo + 0, A_PtrSize * 2, "Int")

	if (Code != -713)
		ButtonId := NumGet(A_EventInfo + (3 * A_PtrSize))
	 else 
		ButtonId := NumGet(A_EventInfo, A_PtrSize == 8 ? 28 : 16, "Int") ; NMTBHOTITEM idNew

	SendMessage 0x419, ButtonId,,, ahk_id %hWnd% ; TB_COMMANDTOINDEX
	Pos := ErrorLevel + 1

	, VarSetCapacity(Text, 128, 0)
	SendMessage % A_IsUnicode ? 0x44B : 0x42D, ButtonId, &Text,, ahk_id %hWnd% ; TB_GETBUTTONTEXT

	Event := (n[Code] != "") ? n[Code] : Code

	, VarSetCapacity(RECT, 16, 0)
	SendMessage 0x433, ButtonId, &RECT,, ahk_id %hWnd% ; TB_GETRECT
	DllCall("MapWindowPoints", "Ptr", hWnd, "Ptr", 0, "Ptr", &RECT, "UInt", 2)
	, Left := NumGet(RECT, 0, "Int")
	, Bottom := NumGet(RECT, 12, "Int")

	%Handler%(hWnd, Event, Text, Pos, ButtonId, Left, Bottom)
}