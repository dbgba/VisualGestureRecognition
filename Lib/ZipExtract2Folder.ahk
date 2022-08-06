/*
	Extract2Folder(Zip, Dest="", Filename="")
 
	Extract contents of a zip file to a folder using Windows Shell
	Based on code by shajul
	(http://www.autohotkey.com/board/topic/60706-native-zip-and-unzip-xpvista7-ahk-l/)

	Parameters
		Zip (required)
			If no path is specified then Zip is assumed to be in the Script Folder
		Dest (optional)
			Name of folder to extract to
			If not specified, a folder based on the Zip name is created in the Script Folder
			If a full path is not specified, then the specified folder is created in the Script Folder
		Filename (optional)
			Name of file to extract
			If not specified, the entire contents of Zip are extracted
			Only works for files in the root folder of Zip
			Wildcards not allowed

	Example usage:
		Extract2Folder("Test.zip")
			将Test.zip的全部内容提取到脚本文件夹中一个名为 "Test "的文件夹中。
			如果'Test'文件夹不存在，将被创建。

		Extract2Folder("Test.zip",, "MyFile.txt")
			从Test.zip的根文件夹中提取 "MyFile.txt "到脚本文件夹中一个名为 "Test "的文件夹中。
			如果'Test'文件夹不存在，将被创建。

		Extract2Folder("Test.zip", "AnotherTest", "MyOtherFile.txt")
			从Test.zip的根文件夹中提取 "MyOtherFile.txt "到脚本文件夹中一个名为 "AnotherTest "的文件夹中。
			如果'AnotherTest'文件夹不存在，将被创建。
 
	Jess Harpur 2013
	It works for me on Windows 7 Home Premium SP1 64bit
	If it doesn't work for you, feel free to alter the code!   
*/
Extract2Folder(Zip, Dest="", Filename="") {
	SplitPath, Zip,, SourceFolder
	if ! SourceFolder
		Zip := A_ScriptDir . "\" . Zip

	if ! Dest {
		SplitPath, Zip,, DestFolder,, Dest
		Dest := DestFolder . "\" . Dest . "\"
	}
	if SubStr(Dest, 0, 1) <> "\"
		Dest .= "\"
	SplitPath, Dest,,,,,DestDrive
	if ! DestDrive
		Dest := A_ScriptDir . "\" . Dest

	fso := ComObjCreate("Scripting.FileSystemObject")
	If Not fso.FolderExists(Dest)  ; http://www.autohotkey.com/forum/viewtopic.php?p=402574
	 	fso.CreateFolder(Dest)

	AppObj := ComObjCreate("Shell.Application")
	, FolderObj := AppObj.Namespace(Zip)
	if Filename
		FileObj := FolderObj.ParseName(Filename)
		, AppObj.Namespace(Dest).CopyHere(FileObj, 4|16)
	 else
		FolderItemsObj := FolderObj.Items()
		, AppObj.Namespace(Dest).CopyHere(FolderItemsObj, 4|16)
}