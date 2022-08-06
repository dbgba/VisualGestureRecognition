; Modified from: https://www.autoahk.com/archives/38527
/*
; 优点：普通用户权限也能创建
if ExaminePowerBoot("演示开机自启") {
	MsgBox 0x40034, 开机自启已失效, 脚本路径改变，导致开机自启失效`n是否恢复开机自启功能？
	IfMsgBox Yes, {
		; RegRead, 开机启动延时, HKCU\Software\YuanShenAHK, KaiJiYanShi
		; 开机启动延时 := 开机启动延时="" ? "5" : 开机启动延时
		FileDelete, %A_StartMenu%\Programs\Startup\演示开机自启.vbs
		; RegWrite, REG_SZ, HKCU\Software\YuanShenAHK, KaiJiYanShi, %开机启动延时%
		; PowerBoot("演示开机自启", 开机启动延时)
		MsgBox % PowerBoot("演示开机自启")
	}
}
*/

; 添加开机自启动，延时功能以秒为单位【vbs带if判断，即使目标不存在也不会报错】
PowerBoot(VBSFileName:="StartupVBS", Sleep:=0, StartupPath:="") {
	FileDelete, %A_StartMenu%\Programs\Startup\%VBSFileName%.vbs
	StartupPath := StartupPath="" ? A_ScriptFullPath : StartupPath
	FileAppend, Set shell=CreateObject("Wscript.Shell")`nSet fs=CreateObject("Scripting.FileSystemObject")`nif fs.FileExists("%StartupPath%") then`nWscript.Sleep 1000*%Sleep%`nshell.Run"""%StartupPath%"""`nend if, %A_StartMenu%\Programs\Startup\%VBSFileName%.vbs
	Return ErrorLevel
}

; 删除自启动
DeletePowerBoot(VBSFileName:="StartupVBS") {
	FileDelete, %A_StartMenu%\Programs\Startup\%VBSFileName%.vbs
}

; 检查开机自启动脚本路径是否正确匹配【正确返回0，错误返回1】
ExaminePowerBoot(VBSFileName:="StartupVBS", StartupPath:="") {
	FileRead, VBSContent, %A_StartMenu%\Programs\Startup\%VBSFileName%.vbs
	StartupPath := StartupPath="" ? A_ScriptFullPath : StartupPath
	Return InStr(VBSContent, StartupPath)=0 ? 1 : 0
}