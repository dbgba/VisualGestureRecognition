#SingleInstance Force
SetBatchLines -1
ListLines Off
SetControlDelay -1
SetWorkingDir %A_ScriptDir%
Menu Tray, Icon, imageres.dll, 75

; 采用手势识别与语音识别多进程分开处理
if (A_Args[10]="语音识别首加载")
    Goto % A_Args[10]

Gosub ini配置文件加载

; =================== 加载Gui界面与托盘菜单 ===================

WindowTitle := "Visual Gesture Recognition v1.0" (A_IsAdmin ? " - 管理员权限" : "")
, Navigation := ["手势识别", "语音识别", "依赖包", "设置", "---", "帮助", "关于"]

, Tab1分页添加按钮名称:=["Static13", "Static14", "Static15", "Static16", "Static17", "ComboBox1", "ComboBox2", "ComboBox3", "ComboBox4", "ComboBox5", "SysLink1", "HtmlButton1", "Edit1"]
           , Tab1分页管理按钮名称:=["Static18", "Static19", "SysHeader321"]
, Tab2分页添加按钮名称:=["Static20", "Static21", "Static22", "Static23", "Static24", "Static25", "Static26", "Static27", "Static28", "Edit2", "Edit3", "Edit4", "Edit5", "Edit6", "SysLink2", "HtmlButton2", "ComboBox6"]
           , Tab2分页管理按钮名称:=["Static29", "Static30", "ListBox1", "Button3"]

Gui +LastFound -Resize +HwndhGui
Gui Color, FFFFFF
Gui Add, Picture, x0 y0 w1699 h1 +0x4E HwndhDividerLine1  ; 分割线 从左到右【顶部菜单栏】

Gui Add, Tab2, x-666 y10 w1699 h334 -Wrap +Theme Buttons HwndhTabControl
Gui Tab

Gui Add, Picture, x-3999 y-3999 w96 h32 vpMenuHover +0x4E HwndhMenuHover  ; 菜单悬停
Gui Add, Picture, x0 y18 w4 h32 vpMenuSelect +0x4E HwndhMenuSelect  ; 菜单选择
Gui Add, Picture, x96 y0 w1 h1340 +0x4E HwndhDividerLine2  ; 分割线 从上到下
Gui Add, Progress, x0 y0 w96 h799 +0x4000000 +E0x4 Disabled BackgroundF7F7F7  ; 左侧常态背景色

; 左侧Tab标题的 字体大小 和 字体加粗
Gui Font, Bold c808080 Q5, Microsoft YaHei UI
Loop % Navigation.Length() {
    GuiControl,, %hTabControl%, % Navigation[A_Index] "|"
    If (Navigation[A_Index] = "---")
        Continue

    Gui Add, Text, % "x0 y" (32*A_Index)-24 " h32 w96 Center +0x200 BackgroundTrans gMenuClick vMenuItem" . A_Index, % Navigation[A_Index]
}

Gui Font, Norm c000000 s15
Gui Add, Text, x117 y4 w464 h32 +0x200 vPageTitle
Gui Add, Picture, x110 y38 w464 h1 +0x4E HwndhDividerLine3  ; 分割线


Gui Tab, 1
Gui Font, s9 Q0
手势识别TabID := Toolbar_Create("手势语音识别Tab分页"," 添加➕`n 管理➖",, "Flat List TextOnly NoDivider",, "x114 y44 w112 h22")

Gui Font, c338017
Gui Add, Text, Section x206 y+8, 左手姿态：
Gui Add, Text, x+150 ys, 右手姿态：

Gui Font, c000000
Gui Add, DropDownList, xs-16 w88 AltSubmit vv手势下拉栏1 gTab1姿态下拉栏 Hwndh手势下拉栏1, % " 抬起时 🙋|| 放下时 🙎|人来检测💀"
Gui Add, DropDownList, x+124  w88 AltSubmit vv手势下拉栏2 gTab1姿态下拉栏 Hwndh手势下拉栏2, % " 抬起时 🙋|| 放下时 🙎|人来检测💀"

Gui Font, c338017
Gui Add, Text, Section x206 y+15, 左手手势：
Gui Add, Text, x+150 ys, 右手手势：

Gui Font, c000000
Gui Add, DropDownList, xs-30 w115 AltSubmit vv手势下拉栏3 gResetFocus, 1.单食指 ☝|2.双指比耶  ✌|3.三指常规|4.四指常规|5.五指伸手掌 🖐|6.大拇指+小拇指|7.竖起大拇指 👍||8.OK手势  👌|9.握拳头无指 ✊|10.无法识别手势
Gui Add, DropDownList, x+98  w115 AltSubmit vv手势下拉栏4 gResetFocus, 1.单食指 ☝|2.双指比耶  ✌|3.三指常规|4.四指常规|5.五指伸手掌 🖐|6.大拇指+小拇指|7.竖起大拇指 👍||8.OK手势  👌|9.握拳头无指 ✊|10.无法识别手势

Gui Add, Text, xs-50 y+13, 当姿态手势满足以上条件时，执行以下AHK代码：
Gui Add, Link, x+6, <a href="https://www.autoahk.com/help/autohotkey/zh-cn/docs/commands/WinActive.htm">更多AHK语法帮助</a>
头语 := "生成快捷示例代码："
Gui Add, DropDownList, Section xs-66 y+8 w280 R12 HwndhTab1代码下拉栏 gTab1代码快捷添加, %头语%打开指定网址||%头语%打开程序|--> 启动键鼠录制工具，来录制生成代码 <--|%头语%发送按键|%头语%移动鼠标|%头语%移动鼠标并点击|%头语%激活窗口|%头语%关闭进程|%头语%移动文件|%头语%判断文件是否存在|%头语%判断窗口是否激活|%头语%设置剪贴板的内容|%头语%执行Cmd命令|%头语%设置弹窗|%头语%延时|%头语%读取注册表|%头语%电脑静音|%头语%显示桌面|%头语%关闭显示器|%头语%TTS语音播报|%头语%切换虚拟桌面的方法

Global HtmlButton1
NewButton1 := New HtmlButton("HtmlButton1", "添加至手势识别", "手势HtmlButton_", "ys-2", , 116, 28)
Gui Add, Edit, xs-6 y+12 w420 h102 HwndhTab1代码编辑框 vvTab1代码编辑框 WantTab
Gui Font

; Tab1中 添加➕和 管理➖按钮的标签页背景绘制
Gui Add, Progress, x115 y67 w455 h307 +0x4000000 +E0x4 Disabled BackgroundFFFFFF
Gui Add, Progress, x0 y38 w1455 h800 +0x4000000 +E0x4 Disabled BackgroundFBFBFB
Gui Add, GroupBox, x114 y61 w456 h314

; ================== Tab1 管理➖标签按钮界面切换 ==================
Gui Add, Text, Section x130 y76, 姿态手势配置列表

Gui Font, c7F7F7F
Gui Add, Text, ys, 　双击：修改　　 右键：备注/删除

Gui Font, c000000
Gui Add, ListView, % "xs-6 w436 h266 gTab1姿态手势列表双击 HwndhTab1姿态手势列表 Count" AHKini["Gesture", "Tab1ListNum"], 状态|左姿|右姿|左手|右手|命令备注
LV_ModifyCol(1, 52), LV_ModifyCol(2, 36), LV_ModifyCol(3, 36), LV_ModifyCol(4, 36), LV_ModifyCol(5, 36), LV_ModifyCol(6, 234)

For _, ControlName in Tab1分页管理按钮名称
    GuiControl, Hide, %ControlName%

Loop 3
    SetPixelColor("D8D8D8", hDividerLine%A_Index%)
SetPixelColor("E9E9E9", hMenuHover)
, SetPixelColor("0078D7", hMenuSelect)
, SelectMenu("MenuItem1")  ; 首次启动右标题刷新
, OnMessage(0x200, "WM_MOUSEMOVE")  ; 左侧边栏鼠标监控

Gui Show, w590 h390, %WindowTitle%
ChangeWindowIcon("imageres.dll", hGui, 75)
ControlFocus, Static11


Gui Tab, 2
Gui Font, , Microsoft YaHei UI
Toolbar_Create("手势语音识别Tab分页"," 添加➕`n 管理➖",, "Flat List TextOnly NoDivider",, "x114 y44 w112 h22")

Gui Add, Text, Section x142 y+8, 唤醒词： 
Gui Add, Text, xs+220 ys, 唤醒反馈： 

Gui Font, c7F7F7F
Gui Add, Text, xs+50 ys, 支持多条设置，用+分割
Gui Add, Text, xs+284 ys, 支持多条随机反馈

Gui Font, c000000
Gui Add, Edit, Section xs-8 y+8 r1 w194 Center g语音识别编辑框1 hwndhSpeechEdit1, % AHKini["Speech", "WakeupWords"]
DllCall("SendMessage", "Ptr", hSpeechEdit1, "UInt", 0x1501, "Ptr", True, "Str", "比如：电子电子+机器人", "Ptr")
Gui Add, Edit, xs+220 ys w194 r1 Center g语音识别编辑框2 hwndhSpeechEdit2, % AHKini["Speech", "WakeupFeedback"]
DllCall("SendMessage", "Ptr", hSpeechEdit2, "UInt", 0x1501, "Ptr", True, "Str", "比如：收到+主人，在呢", "Ptr")

Gui Add, Text, Section x142  y+5, 语音命令： 
Gui Add, Text, xs+220 ys, 执行反馈： 

Gui Font, c7F7F7F
Gui Add, Text, xs+60 ys, 唤醒后，再说出关键词
Gui Add, Text, xs+284 ys, 支持多条随机反馈

Gui Font, c000000
Gui Add, Edit, Section xs-8 y+8 w194 r1 Center vv执行语音命令 hwndhSpeechEdit3
DllCall("SendMessage", "Ptr", hSpeechEdit3, "UInt", 0x1501, "Ptr", True, "Str", "比如：启动浏览器+打开网址", "Ptr")
Gui Add, Edit, xs+220 ys w194 r1 Center vv语音命令反馈 hwndhSpeechEdit4
DllCall("SendMessage", "Ptr", hSpeechEdit4, "UInt", 0x1501, "Ptr", True, "Str", "比如：正在执行", "Ptr")

Gui Add, Text, Section xs+26 y+13, 当语音指令匹配以上条件时，执行以下AHK代码：
Gui Add, Link, x+6, <a href="https://www.autoahk.com/help/autohotkey/zh-cn/docs/commands/WinActive.htm">更多AHK语法帮助</a>
Gui Add, DropDownList, Section xs-22 y+8 w280 R12 HwndhTab2代码下拉栏 gTab2代码快捷添加, %头语%打开指定网址||%头语%打开程序|--> 启动键鼠录制工具，来录制生成代码 <--|%头语%发送按键|%头语%移动鼠标|%头语%移动鼠标并点击|%头语%激活窗口|%头语%关闭进程|%头语%移动文件|%头语%判断文件是否存在|%头语%判断窗口是否激活|%头语%设置剪贴板的内容|%头语%执行Cmd命令|%头语%设置弹窗|%头语%延时|%头语%读取注册表|%头语%电脑静音|%头语%显示桌面|%头语%关闭显示器|%头语%TTS语音播报

Global HtmlButton2
NewButton2 := New HtmlButton("HtmlButton2", "添加至语音识别", "语音HtmlButton_", "ys-2", , 116, 28)
Gui Add, Edit, xs-6 y+10 w420 h108 HwndhTab2代码编辑框 vvTab2代码编辑框 WantTab
Gui Font

; Tab2中 添加➕和 管理➖按钮的标签页背景绘制
Gui Add, Progress, x115 y67 w455 h307 +0x4000000 +E0x4 Disabled BackgroundFFFFFF
Gui Add, Progress, x0 y38 w1455 h800 +0x4000000 +E0x4 Disabled BackgroundFBFBFB
Gui Add, GroupBox, x114 y61 w456 h314

; ================== Tab2 管理➖标签按钮界面切换 ==================
Gui Add, Text, Section x130 y76, 语音指令配置列表

Gui Font, c7F7F7F
Gui Add, Text, ys, 　双击：修改　　 右键：删除
Gui Add, Button, x+56 ys-6 w100 gTab2控制面板, 麦克风控制面板

Gui Font, c000000 Bold, Microsoft YaHei UI
Gui Add, ListBox, xs-6 y+2 w436 h266 vvTab2语音列表内容 gTab2语音列表双击 HwndhTab2语音列表

For _, ControlName in Tab2分页管理按钮名称
    GuiControl, Hide, %ControlName%


Gui Tab, 3
Gui Font, Norm
Gui Add, Text, Section x112 y54, 手势识别需要调用Mediapipe封装的dll完成，原GitHub项目链接：
Gui Add, Button, x+4 ys+2 w98 h30 gMediapipedll依赖包下载选择弹窗 Hwndh依赖包按钮, 自动下载依赖包
Gui Add, Link, xs ys+18, <a href="https://github.com/HW140701/GoogleMediapipePackageDll">https://github.com/HW140701/GoogleMediapipePackageDll</a>

Gui Add, Text, Section y+18, Mediapipe封装dll的详细介绍和说明：
Gui Add, Link, xs ys+18, <a href="https://blog.csdn.net/HW140701/article/details/119546019#3_Mediapipedll_230">https://blog.csdn.net/HW140701/article/details/119546019</a>

Gui Add, Text, Section y+18, 语音识别和播报使用Win自带的SAPI资料：
Gui Font, c7F7F7F
Gui Add, Text, ys, Win完整版自带，无需下载安装

Gui Font, c000000
Gui Add, Link, xs y+2, <a href="https://docs.microsoft.com/zh-cn/previous-versions/windows/desktop/ms723627(v=vs.85)">https://docs.microsoft.com/zh-cn/previous.../desktop/ms723627(v=vs.85)</a>

Gui Font, c313131
Gui Add, Text, Section xs+12 y+18, 一些注意事项：
Gui Add, Text, y+6, 1. 如果依赖包下载中的GitHub镜像源与官方源自动下载都很慢或者失败的话，
Gui Add, Text, xs+13 y+3, 请选择第三项："打开官方源自行下载" 后，按提供的步骤进行操作。
Gui Add, Text, xs y+10, 2. 语音识别和语音播报的调用都是基于Win自带API来实现的。如果出现无法
Gui Add, Text, xs+13 y+3, 识别语音或无法语音反馈的情况，说明你的安装的操作系统可能把这个API
Gui Add, Text, xs+13 y+3, 给精简删除了。暂时只能重装原版系统镜像来修复


Gui Tab, 4
Gui Font, c000000 Bold, Microsoft YaHei UI
Gui Add, Text, Section x124 y54, 启动：
Gui Font

Gui Add, Checkbox, % "Section x+14 ys+2 h14 Hwndh开机自启 gini开机自启 Checked" AHKini["Startup", "PowerBoot"], 开机延时
Gui Add, Edit, x+1 ys-2 w42 r1 Limit3 Number gini开机自启延时
Gui Add, UpDown, Range0-999 Hwndh开机自启延时, % AHKini["Startup", "PowerBootDelay"]
Gui Add, Text, x+6 ys+2, (秒) 后，自动启动此脚本

Gui Add, Checkbox, % "Section xs y+14 h14 Hwndh管理员启动 gini管理员启动 Checked" AHKini["Startup", "Administrators"], 以管理员权限运行脚本
Gui Font, c7F7F7F
Gui Add, Text, ys+1, 缺乏权限会导致一些命令无法使用
Gui Font

Gui Add, Checkbox, % "xs y+14 w288 h14 Hwndh手势识别开关 gini手势识别开关 Checked" AHKini["Startup", "GestureRecognition"], 开启手势识别功能
Gui Add, Checkbox, % "xs y+14 h14 Hwndh语音识别开关 gini语音识别开关 Checked" AHKini["Startup", "SpeechRecognition"], 开启语音识别功能

Gui Font, c000000 Bold, Microsoft YaHei UI
Gui Add, Text, Section x124 y+30, 手势：
Gui Font

Gui Add, Text, Section x+14 ys+2, 使用第
Gui Add, Edit, x+5 ys-4 w38 r1 Limit2 Number gini摄像头选择
Gui Add, UpDown, Range1-99 +0x80 Hwndh摄像头选择, % AHKini["Gesture", "Camera"]
Gui Add, Text, x+4 ys, 颗摄影头进行识别
Gui Add, CheckBox, % "x+24 h14 ys Hwndh摄像头画面 gini摄像头画面 Checked" AHKini["Gesture", "LiveScreen"], 显示实时画面
Gui Add, CheckBox, % "x+12 h14 ys Hwndh摄像头反馈 gini摄像头反馈 Checked" AHKini["Gesture", "GestureFeedback"], 手势反馈

Gui Add, Checkbox, % "Section xs y+14 h14 Hwndh手势识别延时 gini手势识别延时 Checked" AHKini["Gesture", "RecognitionDelay"], 手势识别以
Gui Add, Edit, x+1 ys-2 w38 r1 Limit4 Number Hwndh手势识别延时时间 gini手势识别延时时间, % AHKini["Gesture", "DelayTime"]
Gui Add, Text, x+6 ys+2, (毫秒) 间隔，刷新画面识别
Gui Font, c7F7F7F
Gui Add, Text, x+10 ys+2, （节约性能）
Gui Font

Gui Add, Text, Section xs y+14, 手势成功时反馈：
Gui Add, Edit, x+2 ys-4 w218 r1 Center hwndhSelectMP3文字 giniSelectMP3文字, % AHKini["Gesture", "Feedback"]
DllCall("SendMessage", "Ptr", hSelectMP3文字, "UInt", 0x1501, "Ptr", True, "Str", "支持MP3文件和语音反馈：收到+好的", "Ptr")
Gui Add, Button, x+10 ys-4 giniSelectMP3, 选择MP3

Gui Add, Text, Section xs y+14, 画面旋转：
Gui Add, DropDownList, % "x+3 ys-3 w90 AltSubmit vv旋转下拉栏 gini旋转下拉栏 Hwndh旋转下拉栏 Choose" AHKini["Gesture", "RotatingScreen"], 不开启旋转||顺时针90度|顺时针180度|顺时针270度

Gui Add, Text, x+30 ys, 相同命令限制
Gui Add, Edit, x+5 ys-4 w42 r1 Limit5 Number gini手势成功延时
Gui Add, UpDown, Range1-99999 +0x80 Hwndh手势成功延时, % AHKini["Gesture", "Delayinterval"]
Gui Add, Text, x+4 ys, 秒后再次识别

Gosub 手势依赖文件检查

Gui Tab, 5  ; Skipped

Gui Tab, 6
Gui Font, c000000, Microsoft YaHei UI
Gui Add, Text, Section x116 y54, 1.此exe文件为
Gui Add, Link, x+2 ys, <a href="https://github.com/Lexikos/AutoHotkey_L">AutoHotkey</a>
Gui Add, Text, x+2 ys, 开源项目，请将其加入杀毒-信任区。避免不必要的麻烦
Gui Add, Text, Section x116 y+14, 2.手势识别时，请与摄像头保持足够距离让其至少能够识别上半身。避免产生误触发
Gui Add, Text, Section y+14, 3.当语音识别唤醒时，默认在5秒后进行无应答唤醒重置。语音识别尽量以关键词的
Gui Add, Text, xs+10 y+6, 方式触发，避免同音词的误识别或者一些关键词的难识别。
Gui Add, Text, Section xs y+14, 4.此语音API支持XML标记大致写法与效果如下：
Gui Font, c7F7F7F
Gui Add, Text, x+4 ys, 注意设置语句太长可能会读取不全
Gui Font, c000000
Gui Add, Text, xs+10 y+8 gXML停顿, •  停顿500毫秒：<emph>你<silence msec="500"/>好</emph>
Gui Add, Text, xs+10 y+6 gXML音调, •  升\降此句的音调：<pitch absmiddle="10"/>此句的音调提高10。
Gui Add, Text, xs+10 y+6 gXML语速, •  升\降此句的语速：<rate absspeed="8"/>此句的语速提高到10。
Gui Add, Text, xs+10 y+6 gXML音量, •  升\降此句的音量：<volume level="60">将音量设为60</volume> 
Gui Add, Text, xs y+14, 更多XML标记用法解释详见官方链接：
Gui Add, Link, xs y+2, <a href="https://docs.microsoft.com/zh-cn/previous-versions/windows/desktop/ms717077(v=vs.85)?redirectedfrom=MSDN">https://docs.microsoft.com/.../ms717077(v=vs.85)?redirectedfrom=MSDN</a>


Gui Tab, 7
Gui Font, Bold, Microsoft YaHei UI
Gui Add, Text, Section x118 y48, 感谢以下项目的开源与分享：
Gui Font, Norm
Gui Add, Text, y+9, Mediapipe封装dll的GitHub项目链接：
Gui Add, Link, y+1, <a href="https://github.com/HW140701/GoogleMediapipePackageDll">https://github.com/HW140701/GoogleMediapipePackageDll</a>

Gui Add, Text, y+9, Autoit OpenCV封装dll的GitHub项目链接：
Gui Add, Link, y+1, <a href="https://github.com/smbape/node-autoit-opencv-com">https://github.com/smbape/node-autoit-opencv-com</a>

Gui Add, Text, y+9, 稚晖君的ElectronBot电子机器人所带来的灵感
Gui Add, Link, y+1, <a href="https://github.com/peng-zhihui/ElectronBot">https://github.com/peng-zhihui/ElectronBot</a>

Gui Add, Text, y+9, AutoHotkey官方论坛的技术支持和分享
Gui Add, Link, y+1, <a href="https://www.autohotkey.com/boards">https://www.autohotkey.com/boards</a>

Gui Add, Text, y+9, AutoHotkey中文社区以及群友的技术支持
Gui Add, Link, y+1, <a href="https://www.autoahk.com">https://www.autoahk.com</a>

Gui Font, Bold
Gui Add, Text, y+20, 一个探究机器学习应用的小小项目
Gui Add, Link, y+1, <a href="https://github.com/dbgba/VisualGestureRecognition">https://github.com/dbgba/VisualGestureRecognition</a>
Gui Font

快捷命令字典 := {"打开指定网址" : "Run, https://www.autoahk.com/"
                    , "打开程序" : "Run, ""D:\绝对路径\应用程序名称.exe"""
                    , "执行Cmd命令" : "Run, %ComSpec% /c ""填写Cmd命令_隐藏黑窗详见AHK语法帮助"""
                    , "发送按键" : "Send, {m}  `; 花括号内填写按键名"
                    , "移动鼠标" : "CoordMode, Mouse`r`nMouseMove, 123, 456  `; 移动速度详见AHK语法帮助"
                    , "移动鼠标并点击" : "CoordMode, Mouse`r`nMouseClick, Left, 123, 456  `; 点击次数等等详见AHK语法帮助"
                    , "激活窗口" : "WinActivate, ahk_class Notepad  `; 激活(Notepad是记事本的类名)示例，更多用法详见AHK语法帮助"
                    , "关闭进程" : "Process, Close, QQ.exe  `; 关闭进程"
                    , "读取注册表" : "RegRead, 读取到变量, HKCU\Software\dbgba, 注册表值名称"
                    , "移动文件" : "FileMove, D:\需要移动的文件.txt, D:\移动至文件夹\"
                    , "判断文件是否存在" : "if FileExist(""D:\MyText.txt"") {`r`n    MsgBox, 文件存在`r`n } else {`r`n    MsgBox, 文件不存在`r`n}"
                    , "判断窗口是否激活" : "if WinActive(""ahk_class Notepad"") {  `; Notepad是记事本的类名`r`n    MsgBox, 窗口正激活`r`n } else {`r`n    MsgBox, 窗口未激活`r`n}"
                    , "设置剪贴板的内容" : "Clipboard := ""设置你要存剪贴板的内容"""
                    , "设置弹窗" : "MsgBox, 设置弹窗显示内容"
                    , "延时" : "Sleep, 3000  `; 此为延时三秒"
                    , "电脑静音" : "SoundGet, 静音检查,, Mute`r`nif (静音检查=""Off"") {`r`n    Send, {Volume_Mute}`r`n}"
                    , "显示桌面" : "ComObjCreate(""Shell.Application"").ToggleDesktop()  `; 显示桌面"
                    , "关闭显示器" : "SendMessage, 0x112, 0xF170, 2, , Program Manager  `; 关闭显示器"
                    , "TTS语音播报" : "ComObjCreate(""SAPI.SpVoice"").Speak(""写你要播报的内容"")"
                    , "切换虚拟桌面的方法" : "`; 与""人来检测""配合，实现摄像头警戒模式。老板人来时切换至虚拟桌面`r`nSend, #^d  `; Win+Ctrl+D：创建新的虚拟桌面【以下自由删减搭配】`r`nSend, #^{F4}  `; Win+Ctrl+F4：删除当前虚拟桌面`r`nSend, #^{Left}  `; Win+Ctrl+左键：切换到相邻左侧的虚拟桌面`r`nSend, #^{Right}  `; Win+Ctrl+右键：切换到相邻右侧的虚拟桌面"}

SplitPath, % AHKini["Gesture", "Feedback"],,,,, 所在盘符
if (所在盘符!="")
    if FileExist(AHKini["Gesture", "Feedback"])
        MP3FileLength :=GetAudioDuration(AHKini["Gesture", "Feedback"])

Try ComObjCreate("SAPI.SpVoice").Speak("")
 Catch
    语音功能报错 := 1

if (语音功能报错=1) and (AHKini["Startup", "SpeechRecognition"]=1)
    Gosub 语音功能报错提示
 else if (AHKini["Startup", "SpeechRecognition"]=1)
    语音识别新进程 := New ExecProcess("语音识别首加载")

CoordMode ToolTip
if (手势依赖源文件存在=1) and (AHKini["Startup", "GestureRecognition"]=1)
    Gosub 手势识别加载

; 加载托盘菜单
Menu Tray, NoStandard
Menu Tray, Add, 打开设置(&S), OpenSettings
Menu Tray, Icon, 打开设置(&S), shell32.dll, 317, 16
Menu Tray, Add
if (AHKini["Startup", "GestureRecognition"]=1) {
    Menu Tray, Add, 暂停手势(&G), 手势语音开关
    Menu Tray, Icon, 暂停手势(&G), imageres.dll, 296, 16
 } else {
    Menu Tray, Add, 恢复手势(&G), 手势语音开关
    Menu Tray, Icon, 恢复手势(&G), imageres.dll, 296, 16
}
Menu Tray, Add
if (AHKini["Startup", "SpeechRecognition"]=1) {
    Menu Tray, Add, 暂停语音(&S), 手势语音开关
    Menu Tray, Icon, 暂停语音(&S), SndVolSSO.dll, 1, 16
 } else {
    Menu Tray, Add, 恢复语音(&S), 手势语音开关
    Menu Tray, Icon, 恢复语音(&S), wmploc.dll, 41, 16
}
Menu Tray, Add
Menu Tray, Add, 退出脚本(&X), CloseScript
Menu Tray, Icon, 退出脚本(&X), shell32.dll, 132, 16
Menu Tray, Color, FFFFFF
Menu Tray, Click, 1
Menu Tray, Default, 打开设置(&S)
Menu Tray, Tip, AutoHotkey手势语音识别自动化

For _, v in [ "备注(&R)", "修改(&E)", "删除(&D)" ]
    Menu, Tab1Menu, Add, %v%, Tab1Menu%v%

Menu, Tab2Menu, Add, 删除(&D), Tab2Menu删除(&D)

if (首次运行提示=1) and (手势依赖源文件存在=0) {
    Gosub OpenSettings
    TaskDialog("未检测到 ""Mediapipedll"" 依赖包", "想要开启手势识别功能需要在 ""依赖包"" 选项中，`n`n选择 ""自动下载依赖包"" 按钮进行依赖包加载处理。", "首次启动脚本的提示说明", 0x1, 5, hGui)
    Gosub 依赖包未加载点击
}
#Include <ElectronBotSDK>  ; 给ElectronBot机器人控制预留接口，方便以后扩展
EmptyMem()  ; 清理进程占用内存
Return

; F1键智能帮助，在代码编辑框中标记AHK命令会跳转到对应命令的语法解释
#if WinActive("ahk_id " hGui)  ; 只作用于Visual Gesture Recognition界面
F1::
    Send, ^{Left}^+{Right}
    Sleep 50
    光标下单词:=Trim(GetSelectedString(), ", `t`r`n`v`f")  ; 把两侧的空白符去掉
    if (光标下单词="")
        Run https://www.autoahk.com/help/autohotkey/zh-cn/docs/Tutorial.htm
     else
        Run https://www.autoahk.com/help/autohotkey/zh-cn/docs/search.htm?q=%光标下单词%&m=2
Return
#if

; =================== 托盘菜单与Gui切换逻辑 ===================
GuiClose:
    Gui Hide
Return

OpenSettings:
    Gui Show, w590 h390, %WindowTitle%
    ChangeWindowIcon("imageres.dll", hGui, 75)
Return

EditScript:
    Edit
Return

CloseScript:
    ExitApp

手势语音开关:
    Switch A_ThisMenuItem {
        Case "暂停手势(&G)" :
            GuiControl, , %h手势识别开关%, % v手势识别开关 := 0
            Gosub 托盘跳转ini手势识别开关
        Case "恢复手势(&G)" :
            if (手势依赖源文件存在=1) {
                GuiControl, , %h手势识别开关%, % v手势识别开关 := 1
                Gosub 托盘跳转ini手势识别开关
            }
        Case "暂停语音(&S)" :
            GuiControl, , %h语音识别开关%, % v语音识别开关 := 0
            Gosub 托盘跳转ini语音识别开关
        Case "恢复语音(&S)" :
            if (语音功能报错!=1) {
                GuiControl, , %h语音识别开关%, % v语音识别开关 := 1
                Gosub 托盘跳转ini语音识别开关
            }
    }
Return

MenuClick:
    SelectMenu(A_GuiControl)
    ControlClick, Internet Explorer_Server1, ahk_id %hGui%, , Middle, 1, x999 y999
    ControlClick, Internet Explorer_Server2, ahk_id %hGui%, , Middle, 1, x999 y999
    ControlFocus, Static11
Return

ResetFocus:
    ControlFocus, Edit1
Return

手势语音识别Tab分页(hTB, Event, Text, Pos, Id) {
    Global
    if (Event="LDown") {
        Tab编号 := hTB=手势识别TabID ? 1 : 2
        if (Text="添加➕") {
            For _, ControlName in Tab%Tab编号%分页管理按钮名称
                GuiControl, Hide, %ControlName%
            For _, ControlName in Tab%Tab编号%分页添加按钮名称
                GuiControl, Show, %ControlName%
        } else if (Text="管理➖") {
            For _, ControlName in Tab%Tab编号%分页添加按钮名称
                GuiControl, Hide, %ControlName%
            For _, ControlName in Tab%Tab编号%分页管理按钮名称
                GuiControl, Show, %ControlName%
            if (Tab编号=1)
                Gosub Tab1管理列表刷新
             else
                Gosub Tab2管理列表刷新
        }
    }
}

; ====================== Tab1切换逻辑 ======================
Tab1管理列表刷新:
    LV_Delete()
    , ScriptHeader := "`; 【反馈或注释，勿动此行。请在下方添加新脚本内容】："
    GuiControl, -Redraw, SysHeader321  ; 在加载时禁用重绘来提升性能
    if FileExist(A_ScriptDir "\MyAHKScript\0-0-0-0.ahk")
        LV_Add("", "启用", 0, 0, 0, 0, StrReplace(FileOpen(A_ScriptDir "\MyAHKScript\0-0-0-0.ahk", "r").ReadLine(), ScriptHeader))
        , AHKini["Gesture", "Tab1ListNum"] := 2
     else {
        Loop Files, %A_ScriptDir%\MyAHKScript\*.ahk, R
        {
            FileReadLine, AHKReadLine, %A_LoopFilePath%, 1
            GestureNum := StrSplit(StrReplace(A_LoopFileName, ".ahk"),"-")
            if (GestureNum.length()=4)
                if (InStr(AHKReadLine, ScriptHeader)=0)
                    LV_Add("", "启用", GestureNum[1], GestureNum[2], GestureNum[3], GestureNum[4])
                    , AHKini["Gesture", "Tab1ListNum"] := A_Index+1
                 else
                    LV_Add("", "启用", GestureNum[1], GestureNum[2], GestureNum[3], GestureNum[4], StrReplace(AHKReadLine, ScriptHeader))
                    , AHKini["Gesture", "Tab1ListNum"] := A_Index+1
        }
    }
    GuiControl, +Redraw, SysHeader321
    AHKini.Save()
    Gosub 重新生成手势命令关联数组
Return

GuiContextMenu(GuiHwnd, CtrlHwnd) {
    Global
    if (CtrlHwnd=hTab1姿态手势列表) && LV_GetNext() {
        LV_GetText(Tab1MenuToggle, A_EventInfo, 1), LV_GetText(Tab1Menu1, A_EventInfo, 2), LV_GetText(Tab1Menu2, A_EventInfo, 3), LV_GetText(Tab1Menu3, A_EventInfo, 4), LV_GetText(Tab1Menu4, A_EventInfo, 5), LV_GetText(Tab1MenuNote, A_EventInfo, 6)
        Menu, Tab1Menu, Show
    } else if (Tab2右键选中="A") and (CtrlHwnd=hTab2语音列表) {
        Tab2右键选中编号 := Tab2右键选中 := A_EventInfo
        Menu, Tab2Menu, Show
    } else if (CtrlHwnd=hTab2语音列表) {
        Tab2右键选中 := "A"
        SendInput {LButton}{RButton}
    }
}

; 添加手势HtmlButton按钮事件处理
手势HtmlButton_OnClick() {
    SetTimer 手势HtmlButton跳转, -1
}

手势HtmlButton跳转:
    Gui Submit, NoHide
    if (v手势下拉栏1=3) or (v手势下拉栏2=3)
        新建脚本路径 := A_ScriptDir "\MyAHKScript\0-0-0-0.ahk"
     else
        新建脚本路径 := A_ScriptDir "\MyAHKScript\" v手势下拉栏1 "-" v手势下拉栏2 "-" v手势下拉栏3 "-" v手势下拉栏4 ".ahk"

    if FileExist(新建脚本路径) {
        Gui +OwnDialogs
        MsgBox 0x40034, 相同设置手势文件已存在, 是否用新的配置文件替换已存在的配置？
        IfMsgBox Yes, {
            FileDelete, %新建脚本路径%
            FileAppend, %vTab1代码编辑框%, %新建脚本路径%, UTF-8
        }
    } else
        FileAppend, %vTab1代码编辑框%, %新建脚本路径%, UTF-8
    if (新建脚本路径 = A_ScriptDir "\MyAHKScript\0-0-0-0.ahk")
        FileWriteLine(A_ScriptDir "\MyAHKScript\0-0-0-0.ahk", "人来检测存在时，其它手势将被禁用隐藏")
    Gosub 重新生成手势命令关联数组
Return

Tab1Menu备注(&R):
    Gui NoteSettings: Destroy
    Gui NoteSettings: -MaximizeBox -MinimizeBox +AlwaysOnTop HwndhTab1MenuGui
    Gui NoteSettings: Font, s10, Microsoft YaHei UI
    Gui NoteSettings: Add, Text, x28 y36 w62 h23 +0x200, 备注内容：
    Gui NoteSettings: Font, s9
    Gui NoteSettings: Add, GroupBox, x15 y7 w364 h72, % " 对 " Tab1Menu1 "-" Tab1Menu2 "-" Tab1Menu3 "-" Tab1Menu4 " 手势命令进行备注："
    Gui NoteSettings: Add, Edit, x98 y36 w264 R1 HwndhTab1MenuNoteEdit, % StrReplace(Tab1MenuNote,"`r`n")
    Gui NoteSettings: Add, Button, x86 y88 w76 h24 gNoteSettingsSave, 保存(&S)
    Gui NoteSettings: Add, Button, x230 y88 w76 h24 gNoteSettingsGuiClose, 取消(&C)
    Gui NoteSettings: Show, w394 h124, 为 %Tab1Menu1%-%Tab1Menu2%-%Tab1Menu3%-%Tab1Menu4%.ahk 脚本首行添加注释
    ChangeWindowIcon("imageres.dll", hTab1MenuGui, 75)
    PostMessage, 0x00B1, -2, -1,, ahk_id %hTab1MenuNoteEdit%  ; EM_SETSEL := 0x00B1
Return

NoteSettingsSave:
    GuiControlGet, Tab1MenuNote,, %hTab1MenuNoteEdit%
    FileWriteLine(A_ScriptDir "\MyAHKScript\" Tab1Menu1 "-" Tab1Menu2 "-" Tab1Menu3 "-" Tab1Menu4 ".ahk", StrReplace(Tab1MenuNote, "`n"))
    SetTimer Tab1管理列表刷新, -10

NoteSettingsGuiClose:
    Gui NoteSettings: Destroy
Return

Tab1Menu修改(&E):
    if (Tab1Menu1!=0) or (Tab1Menu2!=0) {
        Loop 4
            GuiControl, Choose, ComboBox%A_Index%, % Tab1Menu%A_Index%
        FileRead, 修改脚本内容, %A_ScriptDir%\MyAHKScript\%Tab1Menu1%-%Tab1Menu2%-%Tab1Menu3%-%Tab1Menu4%.ahk
        GuiControl,, Edit1, %修改脚本内容%
        手势语音识别Tab分页(手势识别TabID, "LDown", "添加➕", "", "")
        , ScrollCaret(hTab1代码编辑框)
    } else
        Run "C:\Windows\System32\notepad.exe" "%A_ScriptDir%\MyAHKScript\0-0-0-0.ahk"
Return

Tab1Menu删除(&D):
    FileDelete, %A_ScriptDir%\MyAHKScript\%Tab1Menu1%-%Tab1Menu2%-%Tab1Menu3%-%Tab1Menu4%.ahk
    Gosub Tab1管理列表刷新
Return

Tab1姿态手势列表双击:
    LV_GetText(Tab1Menu1, A_EventInfo, 2), LV_GetText(Tab1Menu2, A_EventInfo, 3), LV_GetText(Tab1Menu3, A_EventInfo, 4), LV_GetText(Tab1Menu4, A_EventInfo, 5)
    if LV_GetNext()
        Gosub Tab1Menu修改(&E)
Return

Tab1姿态下拉栏:
    ControlFocus, Edit1
    WinClose, ahk_id %hBubbleTooltip%

    Gui, Submit, NoHide
    if (v手势下拉栏1=3) or (v手势下拉栏2=3) {
        For _, ComboBox in (v手势下拉栏1=3 ? ["ComboBox2", "ComboBox3", "ComboBox4"] : ["ComboBox1", "ComboBox3", "ComboBox4"])
            GuiControl, Disable, %ComboBox%
        if (v手势下拉栏1=3)
            WinGetPos, X, Y,, H, ahk_id %h手势下拉栏1%
         else
            WinGetPos, X, Y,, H, ahk_id %h手势下拉栏2%
        hBubbleTooltip := BubbleTooltipBox("所有姿态手势将被禁用！`n仅能检测人是否存在画面之中。", X+5, Y+H-5, "启用人来检测时，", 2,,, 0x17ffff, 0x50669F, "Microsoft YaHei UI", "s10", True, 2500)
        , FollowMainWindow(hGui, hBubbleTooltip, 25)
    } else
        Loop 4
            GuiControl, Enable, ComboBox%A_Index%
Return

Tab1代码快捷添加:
    ControlFocus, Edit1
    GuiControlGet, Tab1代码下拉栏选项内容, , %hTab1代码下拉栏%
    if (Tab1代码下拉栏选项内容="--> 启动键鼠录制工具，来录制生成代码 <--")
        Run "%A_AhkPath%" /r /f "%A_ScriptDir%/Lib/_键盘鼠标操作录制器.ahk"
     else
        Control, EditPaste, % "`r`n" 快捷命令字典[StrReplace(Tab1代码下拉栏选项内容, 头语)] "`r`n", Edit1, ahk_id %hGui%
Return

; ==================== Tab2切换逻辑 ====================
Tab2管理列表刷新:
    ListBox列表刷新 := "|"
    GuiControl, -Redraw, ListBox1  ; 在加载时禁用重绘来提升性能
    Loop Files, %A_ScriptDir%\MyAHKScript\*.ahk, R
    {
        GestureNum := StrReplace(A_LoopFileName, ".ahk")
        if (InStr(GestureNum,"‖")!=0) {
            FileReadLine, AHKReadLine, %A_LoopFilePath%, 1
            ListBox列表刷新 .= StrReplace(GestureNum, "‖") "   <-- 反馈 -->  " StrReplace(AHKReadLine, "`; 【反馈或注释，勿动此行。请在下方添加新脚本内容】：") "|"
        }
    }
    GuiControl, +Redraw, ListBox1
    GuiControl,, ListBox1, %ListBox列表刷新%
    if (语音功能报错!=1) and (AHKini["Startup", "SpeechRecognition"]=1)
        语音识别新进程 := New ExecProcess("语音识别首加载")
Return

Tab2代码快捷添加:
    ControlFocus, Edit6
    GuiControlGet, Tab2代码下拉栏选项内容, , %hTab2代码下拉栏%
    if (Tab2代码下拉栏选项内容="--> 启动键鼠录制工具，来录制生成代码 <--")
        Run "%A_AhkPath%" /r /f "%A_ScriptDir%/Lib/_键盘鼠标操作录制器.ahk"
     else
        Control, EditPaste, % "`r`n" 快捷命令字典[StrReplace(Tab2代码下拉栏选项内容, 头语)] "`r`n", Edit6, ahk_id %hGui%
Return

语音识别编辑框1:
    AHKini["Speech", "WakeupWords"] := A_GuiControl
    , AHKini.Save()
    SetTimer 语音识别新进程重建跳转, -1000
Return

语音识别编辑框2:
    AHKini["Speech", "WakeupFeedback"] := A_GuiControl
    , AHKini.Save()
    SetTimer 语音识别新进程重建跳转, -1000
Return

; 语音HtmlButton事件处理
语音HtmlButton_OnClick() {
    SetTimer 语音HtmlButton跳转, -1
}

语音HtmlButton跳转:
    Gui Submit, NoHide
    新建脚本路径 := A_ScriptDir "\MyAHKScript\‖" RegExReplace(v执行语音命令, "[\/\\\:\*\?\""\<\>\|]") "‖.ahk"

    if (v执行语音命令!="")
        if FileExist(新建脚本路径) {
            Gui +OwnDialogs
            MsgBox 0x40034, 相同设置语音文件已存在, 是否用新的配置文件替换已存在的配置？
            IfMsgBox Yes, {
                FileDelete, %新建脚本路径%
                FileAppend, %vTab2代码编辑框%, %新建脚本路径%, UTF-8
            }
        } else
            FileAppend, %vTab2代码编辑框%, %新建脚本路径%, UTF-8

    if (v语音命令反馈!="")
        FileWriteLine(新建脚本路径, StrReplace(StrReplace(v语音命令反馈,"|"), "`n"))
    if (语音功能报错!=1) and (AHKini["Startup", "SpeechRecognition"]=1)
        语音识别新进程 := New ExecProcess("语音识别首加载")
Return

Tab2语音列表双击:
    if (A_EventInfo!=0) {
        Gui Submit, NoHide
        语音列表内容分割 := StrSplit(vTab2语音列表内容, "   <-- 反馈 -->  ")
        FileRead, 修改脚本内容, % A_ScriptDir "\MyAHKScript\‖" 语音列表内容分割[1] "‖.ahk"
        GuiControl,, Edit4, % 语音列表内容分割[1]
        GuiControl,, Edit5, % 语音列表内容分割[2]
        GuiControl,, Edit6, %修改脚本内容%
        手势语音识别Tab分页(hTab2语音列表, "LDown", "添加➕", "", "")
        , ScrollCaret(hTab2代码编辑框)
    }
Return

Tab2Menu删除(&D):
    Gui Submit, NoHide
    FileDelete, % A_ScriptDir "\MyAHKScript\‖" StrSplit(vTab2语音列表内容, "   <-- 反馈 -->  ")[1] "‖.ahk"
    Gosub Tab2管理列表刷新
Return

Tab2控制面板:
    Run %A_WinDir%\System32\rundll32.exe shell32.dll`,Control_RunDLL mmsys.cpl`,`,1
    OSDTIP_Pop("尝试选择正确麦克风", "在""属性"" - ""级别"" 里，`n可调整 ""音量"" 和 ""麦克风收音加强""", -3000)
Return

语音功能报错提示:
    OSDTIP_Pop("您的系统缺少语音组件", "语音播报和识别将无法开启！`n详见：设置页 - ""依赖包"" - ""注意事项""", -3000)
    , AHKini["Startup", "SpeechRecognition"] := 0
    , AHKini.Save()
    GuiControl, , %h语音识别开关%, 0
Return

; ====================== ini处理逻辑 ======================

ini配置文件加载:
    ; 判断系统和AHK是不是32位
    if (A_Is64bitOS=0) or (A_PtrSize=4)
        MsgBox 0x40010, 姿态手势识别不支持 32 位系统, Mediapipe姿态手势识别dll`n`n不支持在 32 位操作系统 或 32 位 AHK 上运行！

    FileCreateDir, %A_ScriptDir%\MyAHKScript\

    AHKini := New EasyIni(A_ScriptDir "\Lib\Config.ini")
    if (AHKini["Startup", "PowerBoot"]="")
        AHKini["Startup", "PowerBoot"] := 0
        , AHKini["Startup", "PowerBootDelay"] := 5
        , AHKini["Startup", "Administrators"] := 1
        , AHKini["Startup", "GestureRecognition"] := 1
        , AHKini["Startup", "SpeechRecognition"] := 1
        , AHKini["Gesture", "Camera"] := 1
        , AHKini["Gesture", "LiveScreen"] := 1
        , AHKini["Gesture", "GestureFeedback"] := 1
        , AHKini["Gesture", "RecognitionDelay"] := 0
        , AHKini["Gesture", "DelayTime"] := 500
        , AHKini["Gesture", "Feedback"] := ""
        , AHKini["Gesture", "Delayinterval"] := 5
        , AHKini["Gesture", "RotatingScreen"] := 1
        , AHKini["Gesture", "Tab1ListNum"] := 2
        , AHKini["Speech", "WakeupWords"] := ""
        , AHKini["Speech", "WakeupFeedback"] := ""
        , AHKini["Download", "Download1"] := "https://ghproxy.com/https://github.com/HW140701/GoogleMediapipePackageDll/archive/refs/heads/main.zip"
        , AHKini["Download", "Download2"] :=  "https://archive.fastgit.org/HW140701/GoogleMediapipePackageDll/archive/refs/heads/main.zip"
        , AHKini["Download", "Download3"] :=  "https://gh.ddlc.top/https://github.com/HW140701/GoogleMediapipePackageDll/archive/refs/heads/main.zip"
        , AHKini["Download", "Download4"] :=  "https://archive.xn--p8jhe.tw/HW140701/GoogleMediapipePackageDll/archive/refs/heads/main.zip"
        , AHKini.Save()
        , 首次运行提示 := 1

    if (AHKini["Startup", "PowerBoot"]=1)
        if ExaminePowerBoot("手势开机自启") {
            MsgBox 0x40034, 开机自启已失效, 脚本路径改变，导致开机自启失效`n是否恢复开机自启功能？
            IfMsgBox Yes
                DeletePowerBoot("手势开机自启")
                , PowerBoot("手势开机自启", AHKini["Startup", "PowerBootDelay"])
        }

    Gosub AHK脚本以管理员权限自启

    Menu Tray, UseErrorLevel, On
    if (AHKini["Startup", "GestureRecognition"]=0)
        Menu Tray, Icon, imageres.dll, 309
Return

AHK脚本以管理员权限自启:
    if (AHKini["Startup", "Administrators"]=1)
        if !(A_IsAdmin || InStr(DllCall("GetCommandLine", "Str"), ".exe /r"))
            if (RTrim(A_ScriptFullPath, ".ahk")=RTrim(A_AhkPath, ".exe")) {
                RegWrite, REG_SZ, HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers, %A_AhkPath%, ~ RUNASADMIN
                RunWait % "*RunAs " (s:=A_IsCompiled ? """" : A_AhkPath " /r """) A_ScriptFullPath (s ? """" : """ /r")
            } else
                RunWait % "*RunAs " (s:=A_IsCompiled ? """" : A_AhkPath " /r """) A_ScriptFullPath (s ? """" : """ /r")
Return

ini开机自启:
    GuiControlGet, v开机自启,, %h开机自启%
    if (v开机自启=0)
        DeletePowerBoot("手势开机自启")
     else
        PowerBoot("手势开机自启", AHKini["Startup", "PowerBootDelay"])
    AHKini["Startup", "PowerBoot"] := v开机自启
    , AHKini.Save()
    ControlFocus, Static11
Return

ini开机自启延时:
    if (快捷命令字典.Length()=0) {
        GuiControlGet, v开机自启延时,, %h开机自启延时%
        AHKini["Startup", "PowerBootDelay"] := v开机自启延时
        , AHKini.Save()
        if (AHKini["Startup", "PowerBoot"]=1)
            PowerBoot("手势开机自启", AHKini["Startup", "PowerBootDelay"])
    }
Return

ini管理员启动:
    GuiControlGet, v管理员启动,, %h管理员启动%
    AHKini["Startup", "Administrators"] := v管理员启动
    , AHKini.Save()
    ControlFocus, Static11
    if (v管理员启动=1)
        Gosub AHK脚本以管理员权限自启
     else {
        OSDTIP_Pop("权限选项已更改", "即将退出脚本，保存设置…", -2000)
        if (RTrim(A_ScriptFullPath, ".ahk")=RTrim(A_AhkPath, ".exe"))
            RegDelete, HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers, %A_AhkPath%
        Sleep 2200
        ExitApp
    }
Return

ini手势识别开关:
    if (手势依赖源文件存在=0)
        Goto 依赖包未加载点击
    GuiControlGet, v手势识别开关,, %h手势识别开关%
    Tip("正在" (v手势识别开关=1 ? "启动" : "关闭") "中…", 600)
托盘跳转ini手势识别开关:
    if (重置摄像头设置=1)
        Run "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    AHKini["Startup", "GestureRecognition"] := v手势识别开关
    , AHKini.Save()
    ControlFocus, Static11
    if (v手势识别开关=0) and (hOpenCV!="") {
        SetTimer GestureAsynchronousLoop, Off
        SetTimer 停止手势识别辅助显示, % "-" (AHKini["Gesture", "RecognitionDelay"]=0 ? 50 : AHKini["Gesture", "DelayTime"]+50)
        Menu Tray, Icon, imageres.dll, 309
        Menu Tray, Rename, 暂停手势(&G), 恢复手势(&G)
        Menu Tray, Icon, 恢复手势(&G), imageres.dll, 309, 16
    }
    if (v手势识别开关=1) and (hOpenCV!="") {
        cap.open(AHKini["Gesture", "Camera"]-1)
        Menu Tray, Icon, imageres.dll, 75
        Menu Tray, Rename, 恢复手势(&G), 暂停手势(&G)
        Menu Tray, Icon, 暂停手势(&G), imageres.dll, 296, 16
        if (AHKini["Gesture", "RecognitionDelay"]=0)
            SetTimer GestureAsynchronousLoop, 1
         else
            SetTimer GestureAsynchronousLoop, % AHKini["Gesture", "DelayTime"]
    } else if (v手势识别开关=1) and (hOpenCV="")
        Gosub 手势识别加载
Return

停止手势识别辅助显示:
    ToolTip,,,, 19
    cap.release()
    , cv.destroyAllWindows()
    , DllCall("Winmm\mciSendString", "Str", "Close " AHKini["Gesture", "Feedback"], "Uint", 0, "Uint", 0, "Uint", 0)
Return

ini语音识别开关:
    GuiControlGet, v语音识别开关,, %h语音识别开关%
    Tip("正在" (v语音识别开关=1 ? "启动" : "关闭") "中…", 600)
托盘跳转ini语音识别开关:
    AHKini["Startup", "SpeechRecognition"] := v语音识别开关
    , AHKini.Save()
    ControlFocus, Static11
    if (语音功能报错!=1)
        if (v语音识别开关=0) {
            Menu Tray, Icon, imageres.dll, 309
            Menu Tray, Rename, 暂停语音(&S), 恢复语音(&S)
            Menu Tray, Icon, 恢复语音(&S), wmploc.dll, 41, 16
        } else {
            Menu Tray, Icon, imageres.dll, 75
            Menu Tray, Rename, 恢复语音(&S), 暂停语音(&S)
            Menu Tray, Icon, 暂停语音(&S), SndVolSSO.dll, 1, 16
        }
语音识别新进程重建跳转:
     语音识别新进程 := (语音功能报错!=1) and (AHKini["Startup", "SpeechRecognition"]=1) ? New ExecProcess("语音识别首加载") : ""
    if (语音功能报错=1) and (AHKini["Startup", "SpeechRecognition"]=1)
        Gosub 语音功能报错提示
Return

ini摄像头选择:
    if (快捷命令字典.Length()=0) {
        GuiControlGet, v摄像头选择,, %h摄像头选择%
        AHKini["Gesture", "Camera"] := v摄像头选择
        , AHKini.Save()
    }
Return

ini摄像头画面:
    GuiControlGet, v摄像头画面,, %h摄像头画面%
    AHKini["Gesture", "LiveScreen"] := v摄像头画面
    , AHKini.Save()
    ControlFocus, Static11
    if (v摄像头画面=0)
        cv.destroyAllWindows()
Return

ini摄像头反馈:
    GuiControlGet, v摄像头反馈,, %h摄像头反馈%
    AHKini["Gesture", "GestureFeedback"] := v摄像头反馈
    , AHKini.Save()
    ControlFocus, Static11
    if (v摄像头反馈=0)
        ToolTip,,,, 19
Return

ini旋转下拉栏:
    GuiControlGet, v旋转设置下拉栏,, %h旋转下拉栏%
    AHKini["Gesture", "RotatingScreen"] := v旋转设置下拉栏
    , AHKini.Save()
    ControlFocus, Static11
Return

ini手势识别延时:
    GuiControlGet, v手势识别延时,, %h手势识别延时%
    AHKini["Gesture", "RecognitionDelay"] := v手势识别延时
    , AHKini.Save()
    ControlFocus, Static11
    if (v手势识别延时=0) and (hOpenCV!="")
        SetTimer GestureAsynchronousLoop, 1
     else if (v手势识别延时=1) and (hOpenCV!="")
        SetTimer GestureAsynchronousLoop, % AHKini["Gesture", "DelayTime"]
Return

ini手势识别延时时间:
    GuiControlGet, v手势识别延时时间,, %h手势识别延时时间%
    AHKini["Gesture", "DelayTime"] := v手势识别延时时间
    , AHKini.Save()
    if (AHKini["Gesture", "RecognitionDelay"]=1) and (hOpenCV!="")
        SetTimer GestureAsynchronousLoop, %v手势识别延时时间%
Return

iniSelectMP3文字:
    GuiControlGet, vSelectMP3文字,, %hSelectMP3文字%
    SplitPath, vSelectMP3文字, MP3音乐文件路径
    if (MP3音乐文件路径!="")
        if FileExist(vSelectMP3文字)
            if ((MP3FileLength :=GetAudioDuration(vSelectMP3文字))="") {
                GuiControl,, %hSelectMP3文字%, % AHKini["Gesture", "Feedback"]
                Gui +OwnDialogs
                MsgBox 0x40010, 此音频文件无法读取播放, 系统API不支持该音频播放，`n`n请将此音频重新转码成固定码率再试。
                Return
            }
    AHKini["Gesture", "Feedback"] := vSelectMP3文字
    , AHKini.Save()
Return

iniSelectMP3:
    FileSelectFile, MP3音乐文件路径, , ,选择一段音频，做为手势成功时的反馈, 常用音频文件 (*.mp3; *.wav)
    if ((MP3FileLength :=GetAudioDuration(MP3音乐文件路径))="") {
        GuiControl,, %hSelectMP3文字%, % AHKini["Gesture", "Feedback"]
        Gui +OwnDialogs
        MsgBox 0x40010, 此音频文件无法读取播放, 系统API不支持该音频播放，`n`n请将此音频重新转码成固定码率再试。
        Return
    }
    AHKini["Gesture", "Feedback"] := MP3音乐文件路径
    , AHKini.Save()
    GuiControl,, %hSelectMP3文字%, %MP3音乐文件路径%
Return

ini手势成功延时:
    if (快捷命令字典.Length()=0) {
        GuiControlGet, v手势成功延时,, %h手势成功延时%
        AHKini["Gesture", "Delayinterval"] := v手势成功延时
        , AHKini.Save()
    }
Return

; 注意：如果使用变量来引用字符串的双引号需要转义，不然TTS没法识别。" 转义等于 ""
XML停顿:
    Clipboard := "<emph>你<silence msec=""500""/>好</emph>"
    , Tip("""停顿语句"" 已存入剪贴板")
Return

XML音调:
    Clipboard := "<pitch absmiddle=""10""/>此句的音调提高10。"
    , Tip("""改变音调"" 语句已存入剪贴板")
Return

XML语速:
    Clipboard := "<rate absspeed=""8""/>此句的语速提高到10。"
    , Tip("""改变语速"" 语句已存入剪贴板")
Return

XML音量:
    Clipboard := "<volume level=""60"">将音量设为60</volume>"
    , Tip("""改变音量"" 语句已存入剪贴板")
Return

; ================== Mediapipe依赖包下载处理逻辑 ==================
Mediapipedll依赖包下载选择弹窗:
    GuiControlGet, 依赖包按钮内容,, %h依赖包按钮%
    if (依赖包按钮内容!="自动下载依赖包") {
        MsgBox 0x40034, 是否停止下载？, 选“是”将会结束当前下载进度`n是否停止下载？
        IfMsgBox Yes
            Run *RunAs "%A_AhkPath%" /r /f "%A_ScriptDir%/Lib/DownloadProgressBar.ahk" 1 2 "ExitApp"
        Return
    }
    Instruction := "选择来源下载 Mediapipedll 依赖包"
    , Content := "请选择用什么方式，下载手势识别所需要的 Mediapipedll 依赖包支持。"
    , Title := "下载 Mediapipe 依赖包"
    , MainIcon := 0xFFFB ; UAC shield

    , RadioButtons := []
    , RadioButtons.Push([201, "使用GitHub镜像源下载             【自动解压适配】"])
    , RadioButtons.Push([202, "使用GitHub官方源下载             【自动解压适配】"])
    , RadioButtons.Push([203, "打开GitHub官方源自行下载       【自行手动解压适配】"])
    , cRadioButtons := RadioButtons.Length()

    ; A script to set Adventure as default AHK editor.
    , VarSetCapacity(pRadioButtons, 4 * cRadioButtons + A_PtrSize * cRadioButtons, 0)
    Loop %cRadioButtons%
        iButtonID := RadioButtons[A_Index][1]
        , iButtonText := &(r%A_Index% := RadioButtons[A_Index][2])
        , NumPut(iButtonID, pRadioButtons, (4 + A_PtrSize) * (A_Index - 1), "int")
        , NumPut(iButtonText, pRadioButtons, (4 + A_PtrSize) * A_Index - A_PtrSize, "Ptr")

    ; TASKDIALOGCONFIG structure
    x64 := A_PtrSize == 8
    , NumPut(VarSetCapacity(TDC, x64 ? 160 : 96, 0), TDC, 0, "UInt") ; cbSize
    , NumPut(hGui, TDC, 4, "Ptr") ; hwndParent
    , NumPut(Flags, TDC, x64 ? 20 : 12, "int") ; dwFlags
    , NumPut(0x9, TDC, x64 ? 24 : 16, "int") ; dwCommonButtons (TDCBF_OK_BUTTON | TDCBF_CANCEL_BUTTON)
    , NumPut(&Title, TDC, x64 ? 28 : 20, "Ptr") ; pszWindowTitle
    , NumPut(MainIcon, TDC, x64 ? 36 : 24, "Ptr") ; pszMainIcon
    , NumPut(&Instruction, TDC, x64 ? 44 : 28, "Ptr") ; pszMainInstruction
    , NumPut(&Content, TDC, x64 ? 52 : 32, "Ptr") ; pszContent
    , NumPut(cRadioButtons, TDC, x64 ? 76 : 48, "UInt") ; cRadioButtons
    , NumPut(&pRadioButtons, TDC, x64 ? 80 : 52, "Ptr") ; pRadioButtons
    , NumPut(&ExpandedText, TDC, x64 ? 100 : 64, "Ptr") ; pszExpandedInformation
    , NumPut(Callback, TDC, (x64) ? 140 : 84) ; pfCallback
    , NumPut(260, TDC, x64 ? 156 : 92, "UInt") ; cxWidth
    , DllCall("Comctl32.dll\TaskDialogIndirect", "Ptr", &TDC, "int*", Button := 0, "int*", Radio := 0, "int*", Checked := 0)

    if (Button=1) {  ; OK
        if (Radio!=203) {
            Run *RunAs "%A_AhkPath%" /r /f "%A_ScriptDir%/Lib/DownloadProgressBar.ahk" %Radio% %hGui%,,, 下载进程PID
            loading := ["🕛", "🕐", "🕒", "🕓", "🕔", "🕕", "🕖", "🕗", "🕘", "🕙", "🕚"]
            , loading计数 := 0
            SetTimer 依赖包按钮名称更新, 333
        } else {
            Run https://github.com/HW140701/GoogleMediapipePackageDll

            弹窗说明和选择镜像源:
            OnMessage(0x44, "OnMsgBox")
            MsgBox 0x40041, 手动安装依赖方法, 点击 GitHub 官方源页面 "Code" 的 "Download ZIP"，`n`n将整个项目 .zip 包下载下来，放到主程序目录下的 "Lib" 文件夹里。`n`n然后关闭主程序后，再重新打开就能自动识别并解压释放依赖包。`n`n解压释放完成后，就能使用姿态手势识别功能了。
            OnMessage(0x44, "")
            IfMsgBox OK, {
                Run https://hub.fastgit.xyz/HW140701/GoogleMediapipePackageDll
                Goto 弹窗说明和选择镜像源
            }
        }
    }
Return

依赖包按钮名称更新:
    Process, Exist, %下载进程PID%
    if ErrorLevel {
        (++loading计数>11 && loading计数:=1)
        GuiControl, Text, %h依赖包按钮%, % loading[loading计数] " 等待下载中"
    } else {
        Gosub 手势依赖文件检查
        SetTimer 依赖包按钮名称更新, Delete
    }
Return

OnMsgBox() {
    DetectHiddenWindows On
    if (WinExist("ahk_class #32770 ahk_pid " DllCall("GetCurrentProcessId"))) {
        ControlSetText Button1, 镜像源网址
        ControlSetText Button2, 确定
    }
}

手势依赖文件检查:
    if !FileExist(A_ScriptDir "\Lib\GoogleMediapipePackageDll\opencv_world3410.dll") or !FileExist(A_ScriptDir "\Lib\GoogleMediapipePackageDll\autoit_opencv_com455.dll") or !FileExist(A_ScriptDir "\Lib\GoogleMediapipePackageDll\opencv_world455.dll") or !FileExist(A_ScriptDir "\Lib\GoogleMediapipePackageDll\MediapipeHolisticTracking.dll") or !FileExist(A_ScriptDir "\mediapipe\modules\hand_landmark\hand_landmark.tflite") or !FileExist(A_ScriptDir "\mediapipe\modules\pose_detection\pose_detection.tflite")
        手势依赖源文件存在 := 0
     else
        手势依赖源文件存在 := 1

    if (手势依赖源文件存在=1) {
        GuiControl, Hide, %h依赖包提示图片%
        GuiControl, Hide, %h依赖包提示文字%
        GuiControl, Disable, %h依赖包按钮%
        GuiControl, Text, %h依赖包按钮%, 依赖包已安装
     } else {
        Menu Tray, Icon, imageres.dll, 309
        Gui Tab, 1
        Gui Font, s12 Bold cFF0000, Microsoft YaHei UI
        Gui Add, Picture, Section x274 y128 w20 h20 Icon78 Hwndh依赖包提示图片 g依赖包未加载点击, shell32.dll
        Gui Add, Text, x+4 ys Hwndh依赖包提示文字 g依赖包未加载点击, 依赖包未加载！
        Gui Font
        GuiControl, Text, %h依赖包按钮%, 自动下载依赖包
        GuiControl, , %h手势识别开关%, 0
        GuiControl, Text, %h手势识别开关%, 开启手势识别功能 【此项需更新依赖包才能使用】
        AHKini["Startup", "GestureRecognition"] := 0
        , AHKini.Save()
        if FileExist(A_ScriptDir "\Lib\GoogleMediapipePackageDll-main.zip") {
            FileGetSize, zip依赖包文件大小, %A_ScriptDir%\Lib\GoogleMediapipePackageDll-main.zip
            if (zip依赖包文件大小>383000000)
                Run *RunAs "%A_AhkPath%" /r /f "%A_ScriptDir%/Lib/DownloadProgressBar.ahk" 1 %hGui% "依赖zip压缩包解压"
        }
    }
Return

依赖包未加载点击:
    ControlClick, Static7, ahk_id %hGui%
    GuiControl, , %h手势识别开关%, 0
Return

; ==================== 脚本优化参数与依赖库加载 ====================
#NoEnv
#KeyHistory 0
#MaxThreads 255
#Include <_GuiFunc>  ; https://www.autohotkey.com/boards/viewtopic.php?p=458266#p458266
#Include <_Mediapipedll>  ; https://blog.csdn.net/HW140701/article/details/119546019#3_Mediapipedll_230
#Include <_SpeechRecognition>  ; https://gist.github.com/Uberi/6263822
#Include <ExecProcess>  ; https://www.autoahk.com/archives/38591
#Include <VBSPowerBoot>  ; https://www.autoahk.com/archives/38527
#Include <BubbleTooltipBox>  ; https://www.autoahk.com/archives/37864
#Include <Easyini>  ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=5522
#Include <Toolbar>  ; https://www.autohotkey.com/boards/viewtopic.php?f=64&t=89901
#Include <OSDTIP_Pop>  ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=76881
#Include <TextToSpeech>  ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=12304