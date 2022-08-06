; Modified from: https://www.autoahk.com/archives/38591

Class ExecProcess {  ; By dbgba   Thank FeiYue
	; 关联进程变量 := New ExecProcess("标签名称") 新建一个关联进程，重复新建该进程变量可重启此进程。最多可传递8组参数
	__New(LabelOrFunc, Arg1:="", Arg2:="", Arg3:="", Arg4:="", Arg5:="", Arg6:="", Arg7:="", Arg8:="") {
		if (A_Args[9]!="")
			Return
		ParentPID := DllCall("GetCurrentProcessId")
		if A_IsCompiled
			Run "%A_ScriptFullPath%" /f "%Arg1%" "%Arg2%" "%Arg3%" "%Arg4%" "%Arg5%" "%Arg6%" "%Arg7%" "%Arg8%" "%ParentPID%" "%LabelOrFunc%",,, pid
		 else
			Run "%A_AhkPath%" /f "%A_ScriptFullPath%" "%Arg1%" "%Arg2%" "%Arg3%" "%Arg4%" "%Arg5%" "%Arg6%" "%Arg7%" "%Arg8%" "%ParentPID%" "%LabelOrFunc%",,, pid
		this.pid := pid
	}

	; 关联进程变量 := ""，清空这个“进程变量”来关闭对应的进程
	__Delete() {
		DetectHiddenWindows On  ; Logging Out Script
		SendMessage, 0x111, 65307,,, % A_ScriptFullPath " ahk_pid " this.pid
		Process Close, % this.pid
	}

	; 与新进程同步退出，使用异步等待主进程结束回调
	_CallBack() {
		ExitApp
	}

	_ScriptStart() {
		Static init:=ExecProcess._ScriptStart()
		#NoTrayIcon
		SetBatchLines % ("-1", Bch:=A_BatchLines)
		OnMessage(0x4a, "_ExecProcessReceive_WM_COPYDATA")
		Gui _ExecProcess_Label%A_ScriptHwnd%: Add, Button, g_ExecProcessGuiHideLabelGoto
		if (A_Args[9]="") {
			DetectHiddenWindows % ("On", DHW:=A_DetectHiddenWindows)
			PostMessage, 0x111, 65307,,, <<ExecProcessParent>> ahk_class AutoHotkeyGUI
			DetectHiddenWindows %DHW%
			Menu Tray, Icon
			Gui _ExecProcess_Label%A_ScriptHwnd%: Show, Hide, <<ExecProcessParent>>
			SetBatchLines %Bch%
			Return
		}
		_ := DllCall("OpenProcess", "Uint", 0x100000, "int", False, "Uint", A_Args[9], "Ptr")
		Gui _ExecProcess_Label%A_ScriptHwnd%: Show, Hide, % "<<ExecProcess" A_Args[10] ">>"
		Suspend On  ; 屏蔽新进程的热键，来避免冲突
		DllCall("RegisterWaitForSingleObject", "Ptr*", 0, "Ptr", _, "Ptr", RegisterCallback("ExecProcess._CallBack", "F"), "Ptr", 0, "Uint", -1, "Uint", 8)
		SetBatchLines %Bch%
	}

	Send(StringToSend, Label:="Parent", wParam:=0) {
		SetBatchLines % ("-1", Bch:=A_BatchLines)
		VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)
		, NumPut((StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1), CopyDataStruct, A_PtrSize)
		, NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)
		DetectHiddenWindows % ("On", DHW:=A_DetectHiddenWindows)
		WinGet, NewPID, PID, <<ExecProcess%Label%>> ahk_class AutoHotkeyGUI
		SendMessage, 0x4a, wParam, &CopyDataStruct,, ahk_pid %NewPID% ahk_class AutoHotkey
		DetectHiddenWindows %DHW%
		SetBatchLines %Bch%
		Return ErrorLevel
	}

} ; // Class End

; ==================== ↓ 内部调用私有函数与标签 ↓ ====================

; 接收字符串后保存在变量名为"CopyOfData"，以供调用
_ExecProcessReceive_WM_COPYDATA(wParam, lParam) {
	CopyOfData := StrGet(NumGet(lParam + 2*A_PtrSize))
	Switch wParam
	{	; wParam 是ExecProcess库内部通讯的编号
	  Case 1 : _ExecProcessPostFunction(CopyOfData)
	  Case 2 : _ExecProcessPostFunction(CopyOfData,1)
	  Case 3 :
		LabelName := StrReplace(SubStr(CopyOfData, 1, 50), " ")
		if !IsLabel(LabelName)
			Return False
		Gosub %LabelName%
	  Case 4 :
		LabelName := StrReplace(SubStr(CopyOfData, 1, 50), " ")
		if !IsLabel(LabelName)
			Return False
		Global _ExecProcessVarNameRtn := "_ExecProcessVarGetvarValue"
		Gosub _ExecProcessVarGetvarRtn
		_ExecProcessVarGetvarValue := LabelName
		DetectHiddenWindows On
		Control, Check, , Button1, % "<<ExecProcess" (A_Args[10]="" ? "Parent" : A_Args[10]) ">> ahk_class AutoHotkeyGUI"
	  Case 5 : ExecProcessvarName := StrReplace(SubStr(CopyOfData, 1, 50), " "), %ExecProcessvarName% := SubStr(CopyOfData, 51)
	  Case 6 : Global _ExecProcessVarGetvarRtnVar := CopyOfData
	  Case 7 :
		Global _ExecProcessVarNameRtn := StrReplace(SubStr(CopyOfData, 1, 50), " ")
		Gosub _ExecProcessVarGetvarRtn
		ExecProcess.Send(_ExecProcessVarGetvarValue, , 6)
	  Case 8 : ExecProcess.Send(A_IsPaused, , 6)
	  Case 9 :
		SetBatchLines % ("-1", Bch:=A_BatchLines)
		Critical
		Suspend Off
		s:="||Home|End|Ins|Del|PgUp|PgDn|Left|Right|Up|Down|NumpadEnter|"
		Loop 254
			k:=GetKeyName(Format("VK{:X}",A_Index)), s.=InStr(s,"|" k "|") ? "" : k "|"
		For k,v in { Escape:"Esc", Control:"Ctrl", Backspace:"BS" }
			s:=StrReplace(s, k, v)
		s:=Trim(RegExReplace(s,"\|+","|"), "|")
		Loop, Parse, s, |
		{  ; 只能够禁用大多数热键和组合
			Hotkey %A_LoopField%, Off, UseErrorLevel
			Hotkey ~%A_LoopField%, Off, UseErrorLevel
			Hotkey ^%A_LoopField%, Off, UseErrorLevel
			Hotkey #%A_LoopField%, Off, UseErrorLevel
			Hotkey !%A_LoopField%, Off, UseErrorLevel
			Hotkey +%A_LoopField%, Off, UseErrorLevel
			Hotkey ^!%A_LoopField%, Off, UseErrorLevel
			Hotkey ^+%A_LoopField%, Off, UseErrorLevel
			Hotkey ^#%A_LoopField%, Off, UseErrorLevel
		}
		For _,v in StrSplit(CopyOfData, "|")
			Hotkey %v%, On
		Critical Off
		SetBatchLines %Bch%
	}
	Return True
}

_ExecProcessPostFunction(CopyOfData, Synchronous:=0) {
	Global _ExecProcessFunctionName := StrReplace(SubStr(CopyOfData, 1, 50), " "), _ExecProcessFunctionArgs := []
	Loop 10
		_ExecProcessFunctionArgs[A_Index] := RegExReplace(CopyOfData, "(^.+ExecProcessFuncNameLabelArg" A_Index+10 ")(.*)(ExecProcessFuncNameLabelArg" A_Index+30 ".+)", "$2")
	if !IsFunc(_ExecProcessFunctionName)
		Return
	if Synchronous
		SetTimer _ProcessPostFunctionSetTimer, -1
	  else
		Gosub _ProcessPostFunctionSetTimer
	Return

	_ProcessPostFunctionSetTimer:
	%_ExecProcessFunctionName%(_ExecProcessFunctionArgs*)
	Return
}

Goto _ExecProcessLabelSkip

_ExecProcessGuiHideLabelGoto:
	Goto %_ExecProcessVarGetvarValue%
Return

_ExecProcessVarGetvarRtn:
	Global _ExecProcessVarGetvarValue := %_ExecProcessVarNameRtn%
	Gui _debug_%A_ScriptHwnd%: Add, Text,, % _ExecProcessVarGetvarValue %_ExecProcessVarNameRtn%
Return

_ExecProcessLabelSkip:
SetBatchLines %A_BatchLines%
; ==================== ↑ 内部调用私有函数与标签 ↑ ====================


; 让进程调用函数【等待函数执行完毕才返回】
; ExecFunction("演示新进程代码载入", "MyFunc", "Hello World!")
ExecFunction(ProcessLabel:="Parent", FuncName:="", Arg1:="", Arg2:="", Arg3:="", Arg4:="", Arg5:="", Arg6:="", Arg7:="", Arg8:="", Arg9:="", Arg10:="") {
	L := "ExecProcessFuncNameLabelArg", FuncNameArgs := Format("{:-50}", FuncName) . L "11" Arg1 L "31" L "12" Arg2 L "32" L "13" Arg3 L "33" L "14" Arg4 L "34" L "15" Arg5 L "35" L "16" Arg6 L "36" L "17" Arg7 L "37" L "18" Arg8 L "38" L "19" Arg9 L "39" L "20" Arg10 L "40End"
	Return ExecProcess.Send(FuncNameArgs, ProcessLabel, 1)
}

; 让进程调用函数【不等待函数执行完毕返回】
; ExecPostFunction("演示新进程代码载入", "MyFunc", "Hello World!")
ExecPostFunction(ProcessLabel:="Parent", FuncName:="", Arg1:="", Arg2:="", Arg3:="", Arg4:="", Arg5:="", Arg6:="", Arg7:="", Arg8:="", Arg9:="", Arg10:="") {
	L := "ExecProcessFuncNameLabelArg", FuncNameArgs := Format("{:-50}", FuncName) . L "11" Arg1 L "31" L "12" Arg2 L "32" L "13" Arg3 L "33" L "14" Arg4 L "34" L "15" Arg5 L "35" L "16" Arg6 L "36" L "17" Arg7 L "37" L "18" Arg8 L "38" L "19" Arg9 L "39" L "20" Arg10 L "40End"
	Return ExecProcess.Send(FuncNameArgs, ProcessLabel, 2)
}

; 只有异步执行标签能不受变量作用域影响，所以默认使用异步执行
; 让进程跳转至指定标签 ExecLabel("演示新进程代码载入", "MyLabel")
ExecLabel(ProcessLabel:="Parent", LabelName:="", DoNotWait:=0) {
	if DoNotWait
		Rtn := ExecProcess.Send(Format("{:-50}", LabelName), ProcessLabel, 3)  ; Synchronisation
	  else
		Rtn := ExecProcess.Send(Format("{:-50}", LabelName), ProcessLabel, 4)  ; Asynchronous
	Return Rtn
}

; 给进程的变量赋值：ExecAssign("演示新进程代码载入", "var", "123456")
ExecAssign(ProcessLabel:="Parent", VarName:="", Value:="") {
	Return ExecProcess.Send(Format("{:-50}", VarName) . Value, ProcessLabel, 5)
}

; 返回进程中变量的内容：MsgBox % ExecGetvar("演示新进程代码载入","var")
ExecGetvar(ProcessLabel:="Parent", VarName:="") {
	Global _ExecProcessVarGetvarRtnVar
	ExecProcess.Send(Format("{:-50}", VarName), ProcessLabel, 7)
	Return _ExecProcessVarGetvarRtnVar
}

; 查看新进程运行状态：MsgBox % ExecReady("演示新进程代码载入")
ExecReady(ProcessLabel) {
	DetectHiddenWindows On
	Return WinExist("<<ExecProcess" ProcessLabel ">> ahk_class AutoHotkeyGUI") ? 1 : 0
}

; 暂停指定进程：ExecPause("演示新进程代码载入", "Off")
ExecPause(ProcessLabel, ahkPauseOnOff:="On") {
	Global _ExecProcessVarGetvarRtnVar
	ExecProcess.Send("", ProcessLabel, 8) ; Return _ExecProcessVarGetvarRtnVar
	DetectHiddenWindows On
	if (_ExecProcessVarGetvarRtnVar=1) && (ahkPauseOnOff="Off")
		PostMessage, 0x111, 65306,,, <<ExecProcess%ProcessLabel%>> ahk_class AutoHotkeyGUI
	 else if (_ExecProcessVarGetvarRtnVar=0) && (ahkPauseOnOff="On")
		PostMessage, 0x111, 65306,,, <<ExecProcess%ProcessLabel%>> ahk_class AutoHotkeyGUI
}

/*
; 【由于复用进程机制的缘故，新进程将无法启用热键。若想在新进程启用热键可参考以下方法】
; ==== F3和F4为弥补措施, 按F3后F2结束新进程将无法启用, 需要按F4恢复给主进程才行 ====

; 开启关联进程的热键，启用后会屏蔽主进程对应热键。屏蔽后，需要F4为主进程恢复热键
F3::ExecHotkey("演示新进程代码载入","Esc|F2|F3") ; 用 | 号分隔来添加多个热键

; ExecHotkey只能屏蔽日常大部分热键和组合键，会有组合键疏漏。若不了解, 则不推荐对新进程开启热键
F4::ExecRecoveryHotkey("演示新进程代码载入") ; 恢复主进程热键
*/

; 启用指定进程的热键：ExecHotkey("演示新进程代码载入","Esc|F2|^1")
ExecHotkey(ProcessLabel, ProcessHotkey) {
	if (ProcessLabel!="")
		For _,v in StrSplit(ProcessHotkey, "|")
			Hotkey, %v%, Off
	ExecRecoveryHotkey(ProcessLabel, ProcessHotkey)
	, ExecProcess.Send(ProcessHotkey, ProcessLabel, 9)
}

; 记录与恢复主进程热键：ExecRecoveryHotkey("演示新进程代码载入")
ExecRecoveryHotkey(ProcessLabel, ProcessHotkey:="") {
	Static _Boolean
	if (A_Args[9]!="")
		Return
	if !_Boolean
		_Boolean:=[]
	if (ProcessHotkey="") {
		For _,v in StrSplit(_Boolean[ProcessLabel], "|")
			Hotkey %v%, On
		Return _Boolean[ProcessLabel]
	}
	Return _Boolean[ProcessLabel] := ProcessHotkey
}

; 临时新建进程【依赖AHK解释器，编译后无效】ProcessExec("Loop{`nSleep 80`nToolTip test-%A_Index%`n}")
; 结束临时进程：ProcessExec("")	;【第二个参数带编号可不重复新建临时进程】
ProcessExec(NewCode:="", flag:="Default") {
	if A_AhkPath {
		SetBatchLines % ("-1", Bch:=A_BatchLines)
		Critical
		DetectHiddenWindows On
		WinGet, NewPID, PID, <<ExecNew%flag%>> ahk_class AutoHotkeyGUI
		Process Close, %NewPID%
		add=`nflag=<<ExecNew%flag%>>`n
		(%
		#NoTrayIcon
		Gui Gui_ExecFlag_Gui%A_ScriptHwnd%: Show, Hide, %flag%
		DllCall("RegisterShellHookWindow", "Ptr", A_ScriptHwnd)
		, OnMessage(DllCall("RegisterWindowMessage", "Str", "ShellHook"), "_ShellEvent")
		_ShellEvent() {
			DetectHiddenWindows On
			IfWinNotExist <<ExecProcessParent>> ahk_class AutoHotkeyGUI, , ExitApp
		 }
		)
		NewCode:=add "`n" NewCode "`nExitApp"
		, exec := ComObjCreate("WScript.Shell").Exec(A_AhkPath " /ErrorStdOut /f *")
		, exec.StdIn.Write(NewCode)
		, exec.StdIn.Close()
		Critical Off
		SetBatchLines %Bch%
		WinWait, <<ExecNew%flag%>> ahk_class AutoHotkeyGUI, , 3
		WinGet, RtnID, ID, <<ExecNew%flag%>> ahk_class AutoHotkeyGUI
		if RtnID
			Return True
	}
	Return False
}

; 读取ahk脚本来新建临时新进程【依赖AHK解释器，编译后无效】
; ProcessExecFile("NewScript.ahk")  ;【第二个参数带编号可不重复新建临时进程】
ProcessExecFile(FilePath:="", flag:="Default") {
	SplitPath, FilePath,,,,, drive
	if drive=
		FilePath=%A_ScriptDir%\%FilePath%
	FileRead, FileReadVar, %FilePath%
	if (FileReadVar!="")
		Rtn := ProcessExec(FileReadVar, flag)
	Return (Rtn="" ? False : Rtn)
}