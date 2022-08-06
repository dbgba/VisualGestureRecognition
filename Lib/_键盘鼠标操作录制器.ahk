/*
═══════════════════════════════════════════════
    键盘鼠标操作录制器（ 简易版 ）

    使用说明：
    1、快捷键：F3录像/停止录像，F4回放
    2、点击托盘图标也可以显示录制内容，复制到用户脚本中使用即可
═══════════════════════════════════════════════
*/
#SingleInstance Force
#MaxThreadsPerHotkey 2  ; 让F3可以中断录制
SetBatchLines -1  ; 全速运行脚本，保证录制精度

录像机.查看()
Return

; 热键，一键录像/停止
F3::
if (onoff := !onoff)
    录像机.录制()
 else
    录像机.停止()
Return

; 回放热键
F4::录像机.回放()

;================ 下面是函数类 ================
; 基于FeiYue的基础上修改优化：https://www.autoahk.com/archives/38566
Class 录像机 {   ; --> 类开始
    Static oldx, oldy, oldt, ok, text

    录制(鼠标录制间隔:=15) {
        GuiControlGet, ButtonCheckBox, 键鼠录像%A_ScriptHwnd%:, Button1
        Gui 键鼠录像%A_ScriptHwnd%: Hide
        录像机.回放("", 1)
        if (this.ok=1)
            this.ok := 0, this._ReStart(A_ThisFunc)
        SetFormat, IntegerFast, d
        CoordMode ToolTip
        ToolTip -- 正在录制 --, A_ScreenWidth//2-(44*A_ScreenDPI/96), 0
        this.text := "SetBatchLines -1`r`nCoordMode Mouse`r`n`r`n"
        , this.oldx := this.oldy:="", this.oldt := A_TickCount
        , this._SetHotkey(this.ok:=1)
        , _ := this._LogPos.Bind(this)
        if ButtonCheckBox=1
            SetTimer %_%, 300
         else
            SetTimer %_%, % (鼠标录制间隔<15 ? 15 : 鼠标录制间隔)
        ListLines Off
        While (this.ok=1)
            Sleep 100
        ListLines On
        SetTimer %_%, Off
        ToolTip
        this._SetHotkey(0)
        , this.text .= "Return"
        , _ := this.查看.Bind(this)
        SetTimer %_%, -5
        Return this.text
    }

    回放(s:="", flag:="") {
        this.ok := 0
        if !flag
            if (this.text="") {
                CoordMode ToolTip
                ToolTip 请先按F3键进行录制, A_ScreenWidth//2-(60*A_ScreenDPI/96), 0
                Return
            } else {
                s := this.text
                Gui 键鼠录像%A_ScriptHwnd%: Hide
            }
        DetectHiddenWindows On
        WinGet, NewPID, PID, <<ExecVideoReplay>> ahk_class AutoHotkeyGUI
        Process Close, %NewPID%
        add=
        (
        #NoTrayIcon
        Gui, Gui_Flag_Gui: Show, Hide, <<ExecVideoReplay>>
        CoordMode ToolTip
        ToolTip, -- 正在回放 --, A_ScreenWidth//2-(44*A_ScreenDPI/96), 0
        )
        if !flag
            s := add "`n" StrReplace(s, "Return") "`nToolTip 回放结束`nSleep 600`nExitApp"
         else
            s := add "`n" StrReplace(s, "Return") "`nExitApp"
        exec := ComObjCreate("WScript.Shell").Exec(A_AhkPath " /ErrorStdOut /f *")
        , exec.StdIn.Write(s)
        , exec.StdIn.Close()
    }

    查看() {
        if (this.ok=1)
            this.ok := 0, this._ReStart(A_ThisFunc)
        Gui 键鼠录像%A_ScriptHwnd%: +LastFound Hwndh录制器界面
        Gui 键鼠录像%A_ScriptHwnd%: Add, CheckBox, h16 Hwndh鼠标频率 Checked0, 低频率记录鼠标移动轨迹
        Gui 键鼠录像%A_ScriptHwnd%: Font, cBlue s12
        Gui 键鼠录像%A_ScriptHwnd%: Add, Edit, w330 h400
        Gui 键鼠录像%A_ScriptHwnd%: Add, Button, w330 Default Hwndh键鼠回放按钮, 键鼠录制内容回放
        GuiControl, 键鼠录像%A_ScriptHwnd%:, Edit1, % this.text := StrReplace(this.text, "Sleep, 0`r`n")
        __回放按钮 := this.回放.Bind(this, this.text, "")
        GuiControl, 键鼠录像%A_ScriptHwnd%: +g, %h键鼠回放按钮%, %__回放按钮%
        Gui 键鼠录像%A_ScriptHwnd%: Show, , 〔 F3：录制/停止，F4：回放 〕
        ControlFocus, Button2
    }

    停止() {
        this.ok := 0
    }

    _托盘图标自动加载() {
        Static init := 录像机._托盘图标自动加载()
        Menu Tray, UseErrorLevel, On
        Menu Tray, Color, FFFFFF
        hMenu := MenuGetHandle("Tray")
        , ___ := this.查看.Bind(this)
        Loop 10
            DllCall("RemoveMenu", "Ptr", hMenu, "int", 65310-A_Index, "int", 0)
        Menu Tray, Icon, shell32.dll, 204
        Menu Tray, Click, 1
        Menu Tray, Add, 显示编辑界面, %___%
        Menu Tray, Default, 显示编辑界面
        Menu Tray, Add
        RegRead InstallDir, HKLM\SOFTWARE\AutoHotkey, InstallDir
        if FileExist(InstallDir "\WindowSpy.ahk") {
            DllCall("InsertMenu", "Ptr", hMenu, "Uint", 65311, "Uint", 0, "Uptr", 65302, "Str", "坐标获取工具", "int")
            Menu Tray, Add
        }
        DllCall("InsertMenu", "Ptr", hMenu, "Uint", 65311, "Uint", 0, "Uptr", 65307, "Str", "关闭录制器", "int")
    }

    _LogPos() {
        ListLines Off
        CoordMode Mouse
        MouseGetPos, x, y
        if (this.oldx!=x || this.oldy!=y)
            this.oldx := x, this.oldy := y
            , t := -this.oldt+(this.oldt := A_TickCount)
            , this.text .= "Sleep, " t "`r`nMouseMove, " x ", " y ", 0`r`n"
    }

    _SetHotkey(f:=1) {
        ;-- 可以过滤已使用的热键，以逗号分隔
        Static allkeys
        ListLines Off
        if (allkeys="") {
            ; 过滤会与LShift、LControl、LAlt等冲突的，补上主键盘与小键盘虚拟按键码相同导致遗漏的
            s:="|Shift|Control|Alt|||Home|End|PgUp|PgDn|Left|Right|Up|Down|Ins|Del|NumpadEnter|"
            Loop, 254
                k := GetKeyName("vk" . Format("{:X}",A_Index))
                , (StrLen(k)=1 && k := Format("{:L}", k))
                , s .= InStr(s, "|" k "|") ? "" : k "|"
            s := Trim(SubStr(s, InStr(s,"||")+1), "|")
            , allkeys := StrReplace(s, "Control", "Ctrl")
        }
        f := (f ? "On":"Off")
        , r := this._LogKey.Bind(this)
        Loop, Parse, allkeys, |
            if A_LoopField not in F3,F4
                Hotkey, ~*%A_LoopField%, %r%, %f% UseErrorLevel
        ListLines On
    }

    _LogKey() {
        Critical
        k := SubStr(A_ThisHotkey,3)
        if k Contains Button,Wheel
            this._LogPos()
        if k Contains Shift,Ctrl,Alt,Win,Button
        {
            t := -this.oldt+(this.oldt := A_TickCount)
            , this.text .= "Sleep, " t "`r`nSend, {" k " Down}`r`n"
            Critical Off
            KeyWait %k%
            t := -this.oldt+(this.oldt:=A_TickCount)
            , this.text .= "Sleep, " t "`r`nSend, {" k " Up}`r`n"
        } else {  ; 处理QQ中文输入法自动发送左右键来调整光标的情况
            if (k="NumpadLeft"||k="NumpadRight") and !GetkeyState(k,"P")
                Return
            k := (k="``" ? Format("vk{:x}",GetKeyVK("``")) : k)
            , t := -this.oldt+(this.oldt := A_TickCount)
            , this.text .= "Sleep, " t "`r`nSend, {Blind}{" k "}`r`n"
        }
    }

    _ReStart(f:="") {
        if f=
            SetTimer, %__%, % "-1" __ := Func(this.func).Bind(this)
         else {
            this.func := f, __:=Func(A_ThisFunc).Bind(this)
            SetTimer, %__%, -1, -1
        }
        Exit
    }
}  ;<-- 类结束