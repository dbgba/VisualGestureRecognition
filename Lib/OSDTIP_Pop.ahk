; Modified from: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=76881
OSDTIP_Pop(P*) { ; OSDTIP_Pop v0.55 by SKAN on D361/D36E @ tiny.cc/osdtip 
	Local
	Static FN:="", ID:=0, PM:="", PS:="" 

	if !IsObject(FN)
		FN := Func(A_ThisFunc).Bind(A_ThisFunc) 

	if (P.Count()=0 || P[1]==A_ThisFunc) {
		OnMessage(0x202, FN, 0),	OnMessage(0x010, FN, 0) ; WM_LBUTTONUP, WM_CLOSE
		SetTimer, %FN%, OFF
		DllCall("AnimateWindow", "Ptr",ID, "Int",200, "Int",0x50004) ; AW_VER_POSITIVE | AW_SLIDE
		Progress, 10:OFF	 ; | AW_HIDE
		Return ID:=0
	}

	MT:=P[1], ST:=P[2], TMR:=P[3], OP:=P[4], FONT:=P[5] ? P[5] : "Segoe UI"
	, Title := (TMR=0 ? "0x0" : A_ScriptHwnd) . ":" . A_ThisFunc

	if (ID) {
		Progress, 10:, % (ST=PS ? "" : PS:=ST), % (MT=PM ? "" : PM:=MT), %Title%
		OnMessage(0x202, FN, TMR=0 ? 0 : -1)
		SetTimer, %FN%, % Round(TMR)<0 ? TMR : "OFF"
		Return ID
	}

	if ( InStr(OP,"U2",1) && FileExist(WAV:=A_WinDir . "\Media\Windows Notify.wav") )
		DllCall("winmm\PlaySoundW", "WStr",WAV, "Ptr",0, "Int",0x220013) ; SND_FILENAME | SND_ASYNC ; | SND_NODEFAULT
	DetectHiddenWindows, % ("On", DHW:=A_DetectHiddenWindows) ; | SND_NOSTOP | SND_SYSTEM
	SetWinDelay, % (-1, SWD:=A_WinDelay)
	DllCall("uxtheme\SetThemeAppProperties", "Int",0)
	Progress, 10:C11 ZH1 FM9 FS11 CW2A2A2A CTF0F0F0 %OP% B1 M HIDE,% PS:=ST, % PM:=MT, %Title%, %FONT%
	DllCall("uxtheme\SetThemeAppProperties", "Int",7) ; STAP_ALLOW_NONCLIENT ; | STAP_ALLOW_CONTROLS
	WinWait, %Title% ahk_class AutoHotkey2 ; | STAP_ALLOW_WEBCONTENT
	WinGetPos, X, Y, W, H
	SysGet, M, MonitorWorkArea
	WinMove,% "ahk_id" . WinExist(),,% (MRight-W)-8*A_ScreenDPI/96,% (MBottom-(H:=InStr(OP,"U1",1) ? H : Max(H,100)))-8*A_ScreenDPI/96, W, H
	if ( TRN:=Round(P[6]) )
		WinSet, Transparent, %TRN%
	  else
		WinSet, Transparent, 251
	ControlGetPos,,,,H, msctls_progress321
	if (H>2) {
		ColorMQ:=Round(P[7]), ColorBG:=P[8]!="" ? Round(P[8]) : 0xF0F0F0, SpeedMQ:=Round(P[9])
		Control, ExStyle, -0x20000, msctls_progress321 ; v0.55 WS_EX_STATICEDGE
		Control, Style, +0x8, msctls_progress321 ; PBS_MARQUEE
		SendMessage, 0x040A, 1, %SpeedMQ%, msctls_progress321 ; PBM_SETMARQUEE
		SendMessage, 0x0409, 1, %ColorMQ%, msctls_progress321 ; PBM_SETBARCOLOR
		SendMessage, 0x2001, 1, %ColorBG%, msctls_progress321 ; PBM_SETBACKCOLOR
	}
	DllCall("AnimateWindow", "Ptr",WinExist(), "Int",200, "Int",0x40008) ; AW_VER_NEGATIVE | AW_SLIDE
	SetWinDelay, %SWD%
	DetectHiddenWindows, %DHW%
	if (Round(TMR)<0)
		SetTimer, %FN%, %TMR%
	OnMessage(0x202, FN, TMR=0 ? 0 : -1), OnMessage(0x010, FN) ; WM_LBUTTONUP, WM_CLOSE
	Return ID:=WinExist()
}