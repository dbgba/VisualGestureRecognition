; #Persistent
; #Include <Easyini>
; #Include <TextToSpeech>
; AHKini := New EasyIni(A_ScriptDir "\Lib\Config.ini")
; SetBatchLines -1

; Methods of independent testing:
; Uncomment the above code and store it in the parent directory to run. Comment out the error code again.
; You need to use "VisualGestureRecognition.ahk" to download and extract the dependency package successfully before this script can take effect independently.

手势识别加载:

Gosub 重新生成手势命令关联数组  ; Regenerate the gesture command dictionary

OnExit("ExitApp")  ; 用于解决无法正常退出进程的残留问题
, hOpenCV := DllCall("LoadLibrary", "Str", "./Lib/GoogleMediapipePackageDll/opencv_world455.dll", "Ptr")
; autoit_opencv_com455.dll出处：https://github.com/smbape/node-autoit-opencv-com
, hOpenCVCom := DllCall("LoadLibrary", "Str", "./Lib/GoogleMediapipePackageDll/autoit_opencv_com455.dll", "Ptr")

Try cv := ComObjCreate("OpenCV.cv") ; 创建 COM 对象
 catch
    DllCall("autoit_opencv_com455.dll\DllInstall", "int", 1, "Wstr", A_IsAdmin=0 ? "user" : "", "cdecl")
    , cv := ComObjCreate("OpenCV.cv")

cap := ComObjCreate("OpenCV.cv.Videocapture") ; 创建 COM 对象，可用open()方法来打开摄像头
, frame := ComObjCreate("OpenCV.cv.Mat") ; 创建 COM 对象，可将视频帧读取到Mat矩阵中

, DllCall("SetDllDirectory", "Str", A_ScriptDir "/Lib/GoogleMediapipePackageDll/")
, hMediapipedll := DllCall("LoadLibrary", "Str", "MediapipeHolisticTracking.dll")

if !DllCall("MediapipeHolisticTracking\MediapipeHolisticTrackingInit", "astr", "./Lib/GoogleMediapipePackageDll/holistic_tracking_cpu.pbtxt", "int", True, "int", True, "int", True, "int", True) {
    MsgBox 0x40010, 初始化全身关节点跟踪模型失败, 请检查Mediapipe解压是否完整，`n可重新下载依赖包解压后再次尝试。
    Return
}

cap.open(AHKini["Gesture", "Camera"]-1)  ; 打开摄像头。Turn on the camera

if (!cap.isopened()) {
    MsgBox 0x40010, 摄像头未成功打开！, % "第 " AHKini["Gesture", "Camera"] " 颗摄像头无法启动调用，请检查摄像头是否能正常使用？`n`n或者到 ""设置"" 页面切换到其它摄像头再次尝试"
    Gosub OpenSettings
    重置摄像头设置 := 1
    GuiControl, , %h手势识别开关%, 0
    ControlClick, Static8, ahk_id %hGui%
    Return
}

EmptyMem("", 5000)  ; 延时5秒后清理内存。Clear memory after a 5 second delay
, VarSetcapacity(pDetect_Result, 16)

Menu Tray, UseErrorLevel, On
Menu Tray, Icon, imageres.dll, 75
Menu Tray, Rename, 恢复手势(&G), 暂停手势(&G)
Menu Tray, Icon, 暂停手势(&G), imageres.dll, 296, 16

if (语音功能报错!=1)
    异步语音播报 := New TTS()

; 500性能和效率兼顾，反映时间大概需要1.5秒
if (AHKini["Gesture", "RecognitionDelay"]=0)
    SetTimer GestureAsynchronousLoop, 1
 else
    SetTimer GestureAsynchronousLoop, % AHKini["Gesture", "DelayTime"]
Return

; 手势识别异步循环
GestureAsynchronousLoop:
    ret := cap.read(frame) ; 从摄像头cap中读取一帧存到Frame中

    if ((AHKini["Gesture", "RotatingScreen"]-2)!=-1)  ; 画面旋转 Screen rotation
        frame := cv.rotate(frame, AHKini["Gesture", "RotatingScreen"]-2)

    ; 传图片帧进去做全身关节点识别【PostureReturn=姿态返回】
    PostureReturn := MediapipeHolisticTrackingDetectFrameDirect(frame.cols(), frame.rows(), frame.data(), pDetect_Result)

    if AHKini["Gesture", "GestureFeedback"]=1
        ToolTip % "左手：" GetArmUpAndDownResultCN(PostureReturn[1]) "		右手：" GetArmUpAndDownResultCN(PostureReturn[2]) "`n左手手指：" GetGestureResultCN(PostureReturn[3]) "  右手手指：" GetGestureResultCN(PostureReturn[4]), A_ScreenWidth, A_ScreenHeight//1.11, 19

    ; Judgment of the existence of being human
    ; GesturesOrPresence=手势或存在，GestureCommandDict=手势命令关联数组
    if FileExist(A_ScriptDir "\MyAHKScript\0-0-0-0.ahk")
        GesturesOrPresence := (PostureReturn[1]+PostureReturn[2])>-2 ? A_ScriptDir "\MyAHKScript\0-0-0-0.ahk" : ""
     else
        GesturesOrPresence := GestureCommandDict[ PostureReturn[1] . PostureReturn[2] . (PostureReturn[3]="-1" ? 10 : PostureReturn[3]) . (PostureReturn[4]="-1" ? 10 : PostureReturn[4]) ]

    ; GestureWaitingReset=手势等待重置，GestureScript=手势命令脚本内容，RandomFeedback=随机反馈，MP3FileLength=MP3文件长度
    if (GesturesOrPresence!="")
        if (GesturesOrPresence!=GestureWaitingReset) {
            FileRead, GestureScript, %GesturesOrPresence%
            Exec(GestureScript, SubStr(GesturesOrPresence, -14))
            , GestureWaitingReset := GesturesOrPresence
            SetTimer SameCommandDelay, % "-" AHKini["Gesture", "Delayinterval"]*1000
            if (AHKini["Gesture", "Feedback"]!="")
                if (MP3FileLength!="") and (FileExist(AHKini["Gesture", "Feedback"]))
                    DllCall("Winmm\mciSendString", "Str", "Open """ AHKini["Gesture", "Feedback"] """", "Uint", 0, "Uint", 0, "Uint", 0)
                    , DllCall("Winmm\mciSendString", "Str", "Play """ AHKini["Gesture", "Feedback"] """ FROM 000 to " MP3FileLength, "Uint", 0, "Uint", 0, "Uint", 0)
                 else {
                    _ := StrSplit(AHKini["Gesture", "Feedback"], "+")
                    Random, RandomFeedback, 1, % _.length()
                    异步语音播报.Speak(_[RandomFeedback])
                }
        }

    ; 显示摄像头实时画面。Show camera live feed
    if AHKini["Gesture", "LiveScreen"]=1
        cv.imshow("AHK.cv.Image", frame)
Return

; 增加上下黑边框 Add top and bottom black borders
; img_grey := cv.cvtColor(frame, 1)  ; CV_COLOR_BGR2GRAY := 1
; frame := cv.copyMakeBorder(img_grey, 50, 50, 0, 0, 0)

; frame := cv.flip(frame, 1)  ; 画面左右颠倒 The picture is reversed left and right，0、1、-1

; 相同命令延时执行
SameCommandDelay:
    GestureWaitingReset := ""
Return

; Regenerate the gesture command association array
重新生成手势命令关联数组:
    GestureCommandDict := {}
    if FileExist(A_ScriptDir "\MyAHKScript\0-0-0-0.ahk")
        GestureCommandDict[0000] := A_ScriptDir "\MyAHKScript\0-0-0-0.ahk"
     else {
        Loop Files, %A_ScriptDir%\MyAHKScript\*.ahk, R
        {
            GestureNum := StrSplit(StrReplace(A_LoopFileName, ".ahk"),"-")
            if (GestureNum.length()=4)
                GestureCommandDict[GestureNum[1] . GestureNum[2] . GestureNum[3] . GestureNum[4]] := A_ScriptDir "\MyAHKScript\" GestureNum[1] "-" GestureNum[2] "-" GestureNum[3] "-" GestureNum[4] ".ahk"
        }
    }
Return

; Return the result of the left and right hand reversal adjustment because of the mirror image
; 返回结果因为镜像画面而左右手反转调整
MediapipeHolisticTrackingDetectFrameDirect(image_width, image_height, image_data, ByRef Detect_Result, Show_Result_image := False) {
    DllCall("MediapipeHolisticTracking\MediapipeHolisticTrackingDetectFrameDirect", "int", image_width, "int", image_height, "Ptr", image_data, "Ptr", &Detect_Result, "int", Show_Result_image)

    Return [ NumGet(Detect_Result, 4, "int"), NumGet(Detect_Result, 0, "int"), NumGet(Detect_Result, 12, "int"), NumGet(Detect_Result, 8, "int") ]
}

GetGestureResultCN(Result) {
    Switch Result {
        Case -1 : Return "无法识别手势"
        Case 1 : Return "单食指 ☝"
        Case 2 : Return "双指比耶  ✌"
        Case 3 : Return "三指常规"
        Case 4 : Return "四指常规"
        Case 5 : Return "五指伸手掌 🖐"
        Case 6 : Return "大拇指+小拇指"
        Case 7 : Return "竖起大拇指 👍"
        Case 8 : Return "OK手势  👌"
        Case 9 : Return "握拳头无指 ✊"
    }
}

GetGestureResultEN(Result) {
    Switch Result {
        Case -1 : Return "Unknown"
        Case 1 : Return "One ☝"
        Case 2 : Return "Two  ✌"
        Case 3 : Return "Three"
        Case 4 : Return "Four"
        Case 5 : Return "Five 🖐"
        Case 6 : Return "Six"
        Case 7 : Return "Thumb Up 👍"
        Case 8 : Return "OK  👌"
        Case 9 : Return "Fist ✊"
    }
}

GetArmUpAndDownResultCN(Result) {
    Switch Result {
        Case -1 : Return "未知"
        Case 1 : Return "手臂抬起"
        Case 2 : Return "手臂放下"
    }
}

GetArmUpAndDownResultEN(Result) {
    Switch Result {
        Case -1 : Return "Unknown"
        Case 1 : Return "Arm Lift"
        Case 2 : Return "Arms Down"
    }
}

; 清理进程占用内存。Clean up the memory occupied by processes
EmptyMem(PID="", Priority:="") {
    if Priority is Number
    {   ; 实现异步延时清理进程占用内存
        __AsyncEmpty%A_ScriptHwnd%:=Func(A_ThisFunc).Bind(PID, "Asynchronous")
        SetTimer % __AsyncEmpty%A_ScriptHwnd%, -%Priority%
        Return
    }
    pid:=!PID ? DllCall("GetCurrentProcessId") : pid
    , h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
    , DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
    , DllCall("CloseHandle", "Int", h)
}

; 使用临时进程启动自定义脚本
Exec(s, flag:="Default", Args1:="") {
	Critical
	DetectHiddenWindows % ("On", DHW:=A_DetectHiddenWindows)
	WinGet, NewPID, PID, <<ExecNew%flag%>> ahk_class AutoHotkeyGUI
	SendMessage, 0x111, 65307,,, %A_ScriptDir%\* ahk_pid %NewPID%
	DetectHiddenWindows %DHW%
	Critical Off
	add=
	(`%
	; #NoTrayIcon  ; 可以关闭手势新进程的托盘图标显示
	Return
	Exec同步关闭标签跳转:
	SetBatchLines -1
	Gui Gui_Flag%A_ScriptHwnd%: Show, Hide, <<ExecNew%flag%>>
	DllCall("RegisterShellHookWindow", "Ptr", A_ScriptHwnd)
	, OnMessage(DllCall("RegisterWindowMessage", "Str", "ShellHook"), "ShellEvent")
	, OnError("ProcessErrorMessage")
	Return
	ShellEvent() {
		DetectHiddenWindows On
		IfWinNotExist ExecHostProcessName, , ExitApp
	 }
	ProcessErrorMessage(exception) {
		SplitPath, % exception.File, FileName
		MsgBox 0x10, 你的"%FileName%"脚本语法写错了，请检查并修正！, % "发生错误的语句在第 " exception.Line-1 " 行`n`n报错消息：" exception.Message "`n`n报错命令或函数的名称：" exception.What "`n`n报错额外信息：" exception.Extra
		ExitApp
	 }
	)
	s:="Gosub Exec同步关闭标签跳转`n" s "`nExitApp`n" ElectronBotSDKCode "`n" add  ; ElectronBotSDKCode变量为方便扩展所预留
	, s:=StrReplace(s, "ExecHostProcessName", "ahk_pid " DllCall("GetCurrentProcessId"))
	, s:=StrReplace(s, "<<ExecNew%flag%>>", "<<ExecNew" flag ">>")
	, exec:=ComObjCreate("WScript.Shell").Exec(A_AhkPath " /f * """ Args1 """")
	, exec.StdIn.Write(s)
	, exec.StdIn.Close()
}

; Used to solve the problem of not being able to exit the process properly residual
; 用于解决无法正常退出进程残留的问题
ExitApp() {
    Menu, Tray, NoIcon
    Process, Close, % DllCall("GetCurrentProcessId")
}