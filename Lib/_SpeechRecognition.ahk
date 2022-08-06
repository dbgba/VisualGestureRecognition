; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=71363
; by Uberi，Modified from：https://gist.github.com/Uberi/6263822
; #Persistent
; #Include <Easyini>
; #Include <TextToSpeech>

; ExitApp() {
;     Menu, Tray, NoIcon
;     Process, Close, % DllCall("GetCurrentProcessId")
; }

语音识别首加载:
CoordMode ToolTip

Global 语音识别类, 异步语音播报, 唤醒词数组, 唤醒反馈, 执行命令开关, 唤醒词字典 := {}, 执行命令反馈 := {}, 执行命令脚本名 := {}

重新加载语音识别:
AHKini := New EasyIni(A_ScriptDir "\Lib\Config.ini")
, 唤醒词数组 := StrSplit(AHKini["Speech", "WakeupWords"], "+")
, 唤醒反馈 := StrSplit(AHKini["Speech", "WakeupFeedback"], "+")
, 执行命令数组 := []

Loop % 唤醒词数组.length()
    唤醒词字典[唤醒词数组[A_Index]] := "已注册唤醒词"

Loop Files, %A_ScriptDir%\MyAHKScript\*.ahk, R
{
    GestureNum := StrReplace(A_LoopFileName, ".ahk")
    if (InStr(GestureNum,"‖")!=0) {
        FileReadLine, AHKReadLine, %A_LoopFilePath%, 1
        反馈内容 := StrReplace(AHKReadLine, "`; 【反馈或注释，勿动此行。请在下方添加新脚本内容】：")
        , _ := StrSplit(StrReplace(GestureNum, "‖"), "+")

        Loop % _.length()
            执行命令数组.Push(_[A_Index])
            , 执行命令脚本名[_[A_Index]] := A_LoopFileName
            , 执行命令反馈[_[A_Index]] := 反馈内容
    }
}

两个数组合并 := 唤醒词数组.Clone()
, 两个数组合并.Push(执行命令数组*)
, OnExit("ExitApp")  ; 用于解决无法即时退出进程的问题
; 两个数组合并 := ["电子电子", "机器", "你好", "开机", "打开浏览器"]
; 系统的语音播报回复，也可能被误当成触发词被语音识别。实际使用时尽量避开这个问题

if (AHKini["Startup", "SpeechRecognition"]=1)
    语音识别类 := New 语音控制唤醒()
    , 语音识别类.Recognize(两个数组合并)
    , 异步语音播报 := New TTS()
Return


同步语音播报(Text, Rate:=0) {
    SAPI := ComObjCreate("SAPI.SpVoice")
    , SAPI.rate := Rate  ; 语速从 -10 到 10
    , SAPI.Speak(Text)
}

执行命令开关开启:
    执行命令开关 := 1
Return

无应答重置:
    执行命令开关 := ""
Return

Class 语音控制唤醒 extends SpeechRecognizer {
	OnRecognize(Text) {
        ; ToolTip % "接收到你所说过的话：" Text , , , 17   ; 做调试用

        ; 执行命令
        if 执行命令开关
            if (执行命令脚本名[Text]!="") {
                ; 用Exec()调用新脚本反映会很慢，所以只能用Run直接打开新脚本
                Run % """" A_AhkPath """ /r """ A_ScriptDir "\MyAHKScript\" 执行命令脚本名[Text] """"
                ; ToolTip % "被识别的执行指令：" 执行命令反馈[Text]   ; 做调试用
                if (执行命令反馈[Text]!="") {
                    _ := StrSplit(执行命令反馈[Text], "+")
                    Random, 随机反馈, 1, % _.length()
                    异步语音播报.Speak(_[随机反馈])
                }
                Text := 执行命令开关 := ""
                SetTimer 无应答重置, Off
            }

        ; 唤醒
        if (唤醒词字典[Text]!="") {
            ; ToolTip % "被识别的唤醒词：" 唤醒词数组[唤醒词字典[Text]], A_ScreenWidth, A_ScreenHeight//1.09  ; 做调试用
            if (唤醒反馈[1]!="") {
                Random, 随机反馈, 1, % 唤醒反馈.length()
                同步语音播报(唤醒反馈[随机反馈], 2)  ; 为了防止语音指令误触发
            }
            SetTimer 无应答重置, -5000
            SetTimer 执行命令开关开启, -50
        }
	}
}

/*
	UBERI's SAPI Speech Wrapper for AHK
	Speech Recognition
	==================
	A class providing access to Microsoft's SAPI. Requires the SAPI SDK.
	Reference
	---------
	### Recognizer := new SpeechRecognizer
	Creates a new speech recognizer instance.
	The instance starts off listening to any phrases.
	### Recognizer.Recognize(Values = True)
	Set the values that can be recognized by the recognizer.
	if `Values` is an array of strings, the array is interpreted as a list of possibile phrases to recognize. Phrases not in the array will not be recognized. This provides a relatively high degree of recognition accuracy 

compared to dictation mode.
		if `Values` is otherwise truthy, dictation mode is enabled, which means that the speech recognizer will attempt to recognize any phrases spoken.
			if `Values` is falsy, the speech recognizer will be disabled and will stop listening if currently doing so.
				Returns the speech recognizer instance.
	### Recognizer.Listen(State = True)
	Set the state of the recognizer.
	if `State` is truthy, then the recognizer will start listening if not already doing so.
		if `State` is falsy, then the recognizer will stop listening if currently doing so.
			Returns the speech recognizer instance.
	### Text := Recognizer.Prompt(Timeout = -1)
	Obtains the next phrase spoken as plain text.
	if `Timeout` is a positive number, the function will stop and return a blank string after this amount of time, if the user has not said anything in this interval.
		if `Timeout` is a negative number, the function will wait indefinitely for the user to speak a phrase.
			Returns the text spoken.
	### Recognizer.OnRecognize(Text)
	A callback invoked immediately upon any phrases being recognized.
	The `Text` parameter received the phrase spoken.
	This function is meant to be overridden in subclasses. By default, it does nothing.
	The return value is discarded.
*/

class SpeechRecognizer { ; speech recognition class by Uberi
	static Contexts := {}

	__New() {
		try this.cListener := ComObjCreate("SAPI.SpInprocRecognizer") ;obtain speech recognizer (ISpeechRecognizer object)
			, cAudioInputs := this.cListener.GetAudioInputs() ;obtain list of audio inputs (ISpeechObjectTokens object)
			, this.cListener.AudioInput := cAudioInputs.Item(0) ;set audio device to first input
		 catch e
			throw Exception("Could not create recognizer: " . e.Message)

		try this.cContext := this.cListener.CreateRecoContext() ;obtain speech recognition context (ISpeechRecoContext object)
		 catch e
			throw Exception("Could not create recognition context: " . e.Message)

		try this.cGrammar := this.cContext.CreateGrammar() ;obtain phrase manager (ISpeechRecoGrammar object)
		 catch e
			throw Exception("Could not create recognition grammar: " . e.Message)

		;create rule to use when dictation mode is off
		try this.cRules := this.cGrammar.Rules() ;obtain list of grammar rules (ISpeechGrammarRules object)
			, this.cRule := this.cRules.Add("WordsRule",0x1 | 0x20) ;add a new grammar rule (SRATopLevel | SRADynamic)
		 catch e
			throw Exception("Could not create speech recognition grammar rules: " . e.Message)

		this.Phrases(["hello", "hi", "greetings", "salutations"])
		, this.Dictate(True)

		, SpeechRecognizer.Contexts[&this.cContext] := &this ;store a weak reference to the instance so event callbacks can obtain this instance
		, this.Prompting := False ;prompting defaults to inactive

		, ComObjConnect(this.cContext, "SpeechRecognizer_") ;connect the recognition context events to functions
	}

	Recognize(Values = True) {
		if Values { ;enable speech recognition
			this.Listen(True)
			if IsObject(Values) ;list of phrases to use
				this.Phrases(Values)
			 else ;recognize any phrase
				this.Dictate(True)
		} else ;disable speech recognition
			this.Listen(False)
		Return this
	}

	Listen(State = True) {
		try if State
				this.cListener.State := 1 ;SRSActive
			 else
				this.cListener.State := 0 ;SRSInactive
		 catch e
			throw Exception("Could not set listener state: " . e.Message)
		Return this
	}

	Prompt(Timeout = -1) {
		this.Prompting := True
		, this.SpokenText := ""
		if (Timeout < 0) ;no timeout
			While, this.Prompting
				Sleep 0
		 else {
			StartTime := A_TickCount
			While, this.Prompting && (A_TickCount - StartTime) > Timeout
				Sleep 0
		}
		Return this.SpokenText
	}

	Phrases(PhraseList) {
		try this.cRule.Clear() ;reset rule to initial state
		 catch e
			throw Exception("Could not reset rule: " . e.Message)

		try cState := this.cRule.InitialState() ;obtain rule initial state (ISpeechGrammarRuleState object)
		 catch e
			throw Exception("Could not obtain rule initial state: " . e.Message)

		;add rules to recognize
		cNull := ComObjParameter(13,0) ;null IUnknown pointer
		For Index, Phrase In PhraseList
			try cState.AddWordTransition(cNull, Phrase) ;add a no-op rule state transition triggered by a phrase
			 catch e
				throw Exception("Could not add rule """ . Phrase . """: " . e.Message)

		try this.cRules.Commit() ;compile all rules in the rule collection
		 catch e
			throw Exception("Could not update rule: " . e.Message)

		this.Dictate(False) ;disable dictation mode
		Return this
	}

	Dictate(Enable = True) {
		try if Enable ;enable dictation mode
				this.cGrammar.DictationSetState(1) ;enable dictation mode (SGDSActive)
				, this.cGrammar.CmdSetRuleState("WordsRule", 0) ;disable the rule (SGDSInactive)
			 else ;disable dictation mode
				this.cGrammar.DictationSetState(0) ;disable dictation mode (SGDSInactive)
				, this.cGrammar.CmdSetRuleState("WordsRule", 1) ;enable the rule (SGDSActive)
		 catch e
			throw Exception("Could not set grammar dictation state: " . e.Message)
		Return this
	}

	OnRecognize(Text) {
		;placeholder function meant to be overridden in subclasses
	}

	__Delete() { ; remove weak reference to the instance
		this.base.Contexts.Remove(&this.cContext, "")
	}
}

SpeechRecognizer_Recognition(StreamNumber, StreamPosition, RecognitionType, cResult, cContext) { ;speech recognition engine produced a recognition
	try pPhrase := cResult.PhraseInfo() ;obtain detailed information about recognized phrase (ISpeechPhraseInfo object from ISpeechRecoResult object)
		, Text := pPhrase.GetText() ;obtain the spoken text
	 catch e
		throw Exception("Could not obtain recognition result text: " . e.Message)

	Instance := Object(SpeechRecognizer.Contexts[&cContext]) ;obtain reference to the recognizer

	;handle prompting mode
	if Instance.Prompting
		Instance.SpokenText := Text
		, Instance.Prompting := False

	Instance.OnRecognize(Text) ;invoke callback in recognizer
}