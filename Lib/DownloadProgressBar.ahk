; Modified from: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=1674
#NoEnv
#NoTrayIcon
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
#Include %A_ScriptDir%\Easyini.ahk
#Include %A_ScriptDir%\OSDTIP_Pop.ahk
#Include %A_ScriptDir%\ZipExtract2Folder.ahk
SetBatchLines -1
SetTitleMatchMode 2
DetectHiddenWindows On
CoordMode ToolTip

下载源选择 := A_Args[1]

if (A_Args[2]!="") {  ; 与主进程同步退出
	DllCall("RegisterShellHookWindow", "Ptr", A_ScriptHwnd)
	, OnMessage(DllCall("RegisterWindowMessage", "Str", "ShellHook"), "ShellEvent")
}

if (A_Args[3]="ExitApp")
	ExitApp

Global MediapipeWindowHwnd := A_Args[2]

if (A_Args[3]="依赖zip压缩包解压")
	Goto 依赖zip压缩包解压

AHKini := New EasyIni(A_ScriptDir "\Config.ini")
Global 镜像源轮询URL := []

Loop 4
	镜像源轮询URL.Insert(AHKini["Download", "Download" A_Index])

重新开始下载MediapipePackageDll依赖包:
WinGet, MediapipeHwnd, ID, Visual Gesture Recognition ahk_class AutoHotkeyGUI

if (MediapipeWindowHwnd="")
	SetTaskbarProgress(0, , MediapipeHwnd)
 else
	SetTaskbarProgress(0, , MediapipeWindowHwnd)

if (下载源选择=201)
	URL := 镜像源轮询URL[1]
 else
	URL := "https://github.com/HW140701/GoogleMediapipePackageDll/archive/refs/heads/main.zip"

DownloadAs := A_ScriptDir "\GoogleMediapipePackageDll-main.zip"
if (Overwrite="") {
	FileGetSize, FileSize, %DownloadAs%
	if (FileSize>368021756)
		Overwrite := False
	 else
		Overwrite := True
}
UseProgressBar := True

OSDTIP_Pop("后台处理中", "正在检查下载源连接状态，请稍候…")

; 等待下载与进度条完成
DownloadFile(URL, DownloadAs, Overwrite, UseProgressBar)

if (MediapipeWindowHwnd="")
	SetTaskbarProgress(0, , MediapipeHwnd)
 else
	SetTaskbarProgress(0, , MediapipeWindowHwnd)

依赖zip压缩包解压:
OSDTIP_Pop("后台处理中", "正在解压MediapipeDll依赖包，请稍候…", -50000)

; GoogleMediapipePackageDll-main.zip压缩包解压
Extract2Folder(A_ScriptDir "\GoogleMediapipePackageDll-main.zip", "GoogleMediapipePackageDll", "GoogleMediapipePackageDll-main\dll_use_example\MediapipePackageDllTest\bin\MediapipeTest\x64\Release")
FileMoveDir, %A_ScriptDir%\GoogleMediapipePackageDll\Release, %A_ScriptDir%\GoogleMediapipePackageDll, 2

; 解压后判断，是否完整解压
if !FileExist(A_ScriptDir "\GoogleMediapipePackageDll\opencv_world3410.dll") or !FileExist(A_ScriptDir "\GoogleMediapipePackageDll\MediapipeHolisticTracking.dll") or !FileExist(A_ScriptDir "\GoogleMediapipePackageDll\mediapipe\modules\hand_landmark\hand_landmark.tflite") or !FileExist(A_ScriptDir "\GoogleMediapipePackageDll\mediapipe\modules\pose_detection\pose_detection.tflite") {
	OSDTIP_Pop()
	, Overwrite := True
	, OnMessage(0x44, "OnMsgBox")
	MsgBox 0x40012, 下载出错或解压失败！, % "MediapipePackageDll 依赖包文件未能释放或释放不完全，`n`n将无法调用手势识别功能，是否" (SubStr(URL, 1, 19)="https://github.com/" ? "" : "换个""镜像源""") "重新下载？"
	OnMessage(0x44, "")
	FileDelete, %A_ScriptDir%\GoogleMediapipePackageDll-main.zip

	IfMsgBox Abort, {
		Run https://github.com/HW140701/GoogleMediapipePackageDll

		MsgBox 0x40040, 手动安装依赖方法, 点击 GitHub 官方源页面 "Code" 的 "Download ZIP"，`n`n将整个项目 .zip 包下载下来，放到主程序目录下的 "Lib" 文件夹里。`n`n然后关闭主程序后，再重新打开就能自动识别并解压释放依赖包。`n`n解压释放完成后，就能使用姿态手势识别功能了。
		Goto 重启主进程
	} Else IfMsgBox Retry, {
		if (SubStr(URL, 1, 19)!="https://github.com/") {
			镜像源轮询URL.RemoveAt(1)
			, 下载源选择 := 201
		}
		Goto 重新开始下载MediapipePackageDll依赖包
	} Else IfMsgBox Ignore
		ExitApp
}

; Mediapipe模型转移到根目录给AHK调用
if !FileExist(A_ScriptDir "\..\mediapipe\") or !FileExist(A_ScriptDir "\..\mediapipe\modules\hand_landmark\hand_landmark.tflite")
	FileMoveDir, %A_ScriptDir%\GoogleMediapipePackageDll\mediapipe\, %A_ScriptDir%\..\mediapipe\, 1

FileDelete, %A_ScriptDir%\GoogleMediapipePackageDll-main.zip
FileDelete, %A_ScriptDir%\GoogleMediapipePackageDll\MediapipeTest.exe

OSDTIP_Pop("手势识别已开启", "MediapipeDll依赖包已释放完成！", -1500)

重启主进程:
if WinExist("ahk_id " MediapipeWindowHwnd)
	PostMessage, 0x111, 65303,,, ahk_id %MediapipeWindowHwnd% ahk_class AutoHotkeyGUI
 else
	PostMessage, 0x111, 65303,,, ahk_id %MediapipeHwnd% ahk_class AutoHotkeyGUI

Sleep 2500
ExitApp


DownloadFile(ByRef URL, SaveFileAs = "", Overwrite := True, UseProgressBar := True) {
	;Check if the file already exists and if we must not overwrite it
	if (!Overwrite && FileExist(SaveFileAs))
		Return
	;Check if the user wants a progressbar
	if (UseProgressBar) {
		if (镜像源轮询URL[1]="") {
			MsgBox 0x40030, % "GitHub" (GitHub源 := SubStr(URL, 1, 19)="https://github.com/" ? "官方源" : "镜像源") "无法下载", % "GitHub" GitHub源 "也无法下载，`n请自行到官方GitHub地址下载.zip包后，放在""Lib""目录中"
			Run https://github.com/HW140701/GoogleMediapipePackageDll
			ExitApp
		}

		换源重新下载一次:
		下载源Loop := SubStr(URL, 1, 19)="https://github.com/" ? 1 : 镜像源轮询URL.length()+1  ; 官方源=1

		Loop %下载源Loop% {
			WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			, WebRequest.Open("HEAD", URL)
			Try WebRequest.Send()
			  Catch {
				if (--下载源Loop=0) {
					if (GitHub源="") {
						MsgBox 0x40034, % "GitHub" (GitHub源 := SubStr(URL, 1, 19)="https://github.com/" ? "官方源" : "镜像源") "无法下载", % "GitHub" GitHub源 "无法下载，是否切换到" (SubStr(URL, 1, 19)!="https://github.com/" ? "官方源" : "镜像源")  "进行下载？"
						IfMsgBox Yes, {
							URL := (GitHub源="官方源" ? 镜像源轮询URL[1] : "https://github.com/HW140701/GoogleMediapipePackageDll/archive/refs/heads/main.zip")
							Goto 换源重新下载一次
						} else IfMsgBox No
							ExitApp
					} else {
						MsgBox 0x40030, % "GitHub" (GitHub源 := SubStr(URL, 1, 19)!="https://github.com/" ? "官方源" : "镜像源") "无法下载", % "GitHub" GitHub源 "也无法下载，`n请自行到官方GitHub地址下载.zip包后，放在""Lib""目录中"
						Run https://github.com/HW140701/GoogleMediapipePackageDll
						ExitApp
					}
				} else {
					镜像源轮询URL.RemoveAt(1)
					if ((URL := 镜像源轮询URL[1])!="")
						Continue
					 else
						Break
				}
			}
			Break
		}

		OSDTIP_Pop()
		;Store the header which holds the file size in a variable:
		; FinalSize := WebRequest.GetResponseHeader("Content-Length")
		; 由于在GitHub下载文件无法获取文件大小，所以只能预设文件大小供进度条参考
		FinalSize := 388021756
		;Create the progressbar and the timer
		Progress, FM10 WM500 FS11 WS600 ZY9 H80 M CWF6F6F6, , 准备下载中..., % ShortURL(URL)
		File := FileOpen(SaveFileAs, "rw")
		SetTimer, __UpdateProgressBar, 333
	}
	;Download the file
	UrlDownloadToFile, %URL%, %SaveFileAs%
	;Remove the timer and the progressbar because the download has finished
	if (UseProgressBar) {
		Progress, Off
		SetTimer, __UpdateProgressBar, Off
		File.Close()
	}
	Return

	;The label that updates the progressbar
	__UpdateProgressBar:
		;Get the current filesize and tick
		CurrentSize := File.Length ;FileGetSize wouldn't return reliable results
		, CurrentSizeTick := A_TickCount
		;Calculate the downloadspeed
		, Speed := Round((CurrentSize/1024-LastSize/1024)/((CurrentSizeTick-LastSizeTick)/1000), 1)
		;Calculate time remain
		, TimeRemain := Round( (FinalSize-CurrentSize) / (Speed*1024) )

		time = 19990101
		time += %TimeRemain%, seconds
		FormatTime, mmss, %time%, mm:ss
		TimeRemain := LTrim(TimeRemain//3600 ":" mmss, "0:")
		;Save the current filesize and tick for the next time
		, LastSizeTick := CurrentSizeTick
		, LastSize := CurrentSize
		;Calculate percent done
		, PercentDone := Round(CurrentSize/FinalSize*100)
		if (MediapipeWindowHwnd="") {
			WinGet, MediapipeHwnd, ID, Visual Gesture Recognition ahk_class AutoHotkeyGUI
			SetTaskbarProgress(PercentDone, , MediapipeHwnd)
		} else
			SetTaskbarProgress(PercentDone, , MediapipeWindowHwnd)
		;Update the ProgressBar
		Progress, %PercentDone%, 进度：%PercentDone%`% [剩余时间：%TimeRemain%], 下载速度  (%Speed% Kb/s),  % "Google MediapipeDll 下载中" (progress :=(toggle := !toggle) ? "…" : (progress="……" ? "………" : toggle:="……"))
	Return
}

; 缩短网址显示函数
ShortURL(p,l=45) {
	VarSetCapacity(_p, (A_IsUnicode?2:1)*StrLen(p) )
	, DllCall("shlwapi\PathCompactPathEx","str", _p,"str", p,"uint", abs(l),"uint", 0)
	return _p
}

OnMsgBox() {
	DetectHiddenWindows On
	If (WinExist("ahk_class #32770 ahk_pid " DllCall("GetCurrentProcessId"))) {
		ControlSetText Button1, 手动下载(&R)
		ControlSetText Button2, 是(&Y)
		ControlSetText Button3, 否(&N)
	}
}

ShellEvent(wParam, lParam) {
	if !WinExist("ahk_id " MediapipeWindowHwnd)
		ExitApp
}

; 任务栏按钮上显示进度条
SetTaskbarProgress(pct, state="", hwnd="") {
	; https://autohotkey.com/board/topic/46860-windows-7-settaskbarprogress/ - from Lexikos
	; edited version of Lexikos' SetTaskbarProgress() function to work with Unicode 64bit, Unicode 32bit, Ansi 32bit, and Basic/Classic (1.0.48.5)
	; SetTaskbarProgress - Requires Windows 7.
	; pct - A number between 0 and 100 or a state value (see below).
	; state - "N" (normal), "P" (paused), "E" (error) or "I" (indeterminate).
	; If omitted (and pct is a number), the state is not changed.
	; hwnd - The ID of the window which owns the taskbar button.
	; If omitted, the Last Found Window is used.

	Static tbl, s0:=0, sI:=1, sN:=2, sE:=4, sP:=8
	if !tbl
		Try tbl := ComObjCreate("{56FDF344-FD6D-11d0-958A-006097C9A090}", "{ea1afb91-9e28-4b86-90e9-9e9f8a5eefaf}")
		  Catch
			Return 0
	if hwnd =
		hwnd := WinExist()
	if pct is not number
		state := pct, pct := ""
	 else if (pct = 0 && state="")
		state := 0, pct := ""
	if state in 0,I,N,E,P
		DllCall(NumGet(NumGet(tbl+0)+10*A_PtrSize), "uint", tbl, "uint", hwnd, "uint", s%state%)
	if pct !=
		DllCall(NumGet(NumGet(tbl+0)+9*A_PtrSize), "uint", tbl, "uint", hwnd, "int64", pct*10, "int64", 1000)
	Return 1
}