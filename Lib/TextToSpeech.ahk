; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=12304
; #SingleInstance Force
; Object := New TTS()
; 测试=<pitch absmiddle="10"/>改变此句音调。你<silence msec="500"/>好<volume level="60">音量设为60</volume>
; Object.Speak(测试)
; Loop
;     ToolTip % n := n="" ? 1 : ++n
; Return
; 
; F1::Object.Speak("测试播报语音功能")  ; 按F1键来测试异步Speak()。
; F3::ComObjCreate("SAPI.SpVoice").Speak("简易同步语音播报")  ; 免类库，单行调用写法

; https://docs.microsoft.com/zh-cn/previous-versions/windows/desktop/ms717077(v=vs.85)?redirectedfrom=MSDN
; <volume level="60">哈哈</volume> 用于设置文本朗读的音量，0~100%【示例的60，是以音量的60%朗读】
; <rate absspeed="1"/>、<rate speed="5"/> 分别用于设置文本朗读的绝对速度和相对速度
; <pitch absmiddle="2"/>、<pitch middle="5"/> 分别用于设置文本朗读的绝对语调和相对语调
; <emph></emph> 在他们之间的句子被视为强调朗读
; <spell></spell> 可以将单词逐个字母的拼写出来，只适用于英文
; <silence msec="500"/> 插入500毫秒静音
; <voice required="Language=409"></voice> 用于设置朗读所用的语言，其中409表示使用英语，804表示使用汉语，而411表示日语。


; Class TTS by evilC
; Based on code by Learning one. For AHK_L. Thanks: jballi, Sean, Frankie.
; AHK forum location: www.autohotkey.com/forum/topic57773.html
; Read more: msdn.microsoft.com/en-us/library/ms723602(v=VS.85).aspx, www.autohotkey.com/forum/topic45471.html, www.autohotkey.com/forum/topic83162.html
Class TTS {
	VoiceList := []  ; An indexed array of the available voice names
	, VoiceAssoc := {}  ; An Associative array of voice names, key = voice name, value = voice index (VoiceList lookup)
	, VoiceCount := 0  ; The number of voices available
	, VoiceNumber := 0  ; The number of the current voice
	, VoiceName := ""  ; The name of the current voice
	
	__New() {
		this.oVoice := ComObjCreate("SAPI.SpVoice")
		, this._GetVoices()
		, this.SetVoice(this.VoiceList.1)
	}

	; speak or stop speaking
	ToggleSpeak(text) {
		Status := this.oVoice.Status.RunningState
		if Status = 1	; finished
			this.oVoice.Speak(text,0x1)	; speak asynchronously
		Else if Status = 0	; paused
		{
			this.oVoice.Resume
			this.oVoice.Speak("",0x1|0x2)  ; stop
			this.oVoice.Speak(text,0x1)  ; speak asynchronously
		} Else if Status = 2  ; reading
			this.oVoice.Speak("",0x1|0x2)  ; stop
	}

	; speak asynchronously
	Speak(text) {
		Status := this.oVoice.Status.RunningState
		if Status = 0  ; paused
			this.oVoice.Resume
		this.oVoice.Speak("",0x1|0x2)  ; stop
		, this.oVoice.Speak(text,0x1)  ; speak asynchronously
	}

	; speak synchronously
	SpeakWait(text) {
		Status := this.oVoice.Status.RunningState
		if Status = 0  ; paused
			this.oVoice.Resume
		this.oVoice.Speak("",0x1|0x2)  ; stop
		, this.oVoice.Speak(text,0x0)  ; speak synchronously
	}

	; Pause toggle
	Pause() {
		Status := this.oVoice.Status.RunningState
		if Status = 0  ; paused
			this.oVoice.Resume
		else if Status = 2  ; reading
			this.oVoice.Pause
	}

	Stop() {
		Status := this.oVoice.Status.RunningState
		if Status = 0	; paused
			this.oVoice.Resume
		this.oVoice.Speak("",0x1|0x2)	; stop
	}

	; rate (reading speed): rate from -10 to 10. 0 is default.
	SetRate(rate) {
		this.oVoice.Rate := rate
	}

	; volume (reading loudness): vol from 0 to 100. 100 is default
	SetVolume(vol) {
		this.oVoice.Volume := vol
	}

	; pitch : From -10 to 10. 0 is default.
	; http://msdn.microsoft.com/en-us/library/ms717077(v=vs.85).aspx
	SetPitch(pitch) {
		this.oVoice.Speak("<pitch absmiddle = '" pitch "'/>",0x20)
	}

	; Set voice by name
	SetVoice(VoiceName) {
		if (!ObjHasKey(this.VoiceAssoc, VoiceName))
			return 0
		While !(this.oVoice.Status.RunningState = 1)
		Sleep, 20
		this.oVoice.Voice := this.oVoice.GetVoices("Name=" VoiceName).Item(0) ; set voice to param1
		, this.VoiceName := VoiceName
		, this.VoiceNumber := this.VoiceAssoc[VoiceName]
		return 1
	}

	; Set voice by index
	SetVoiceByIndex(VoiceIndex) {
		return this.SetVoice(this.VoiceList[VoiceIndex])
	}

	; Use the next voice. Loops around at end
	NextVoice() {
		v := this.VoiceNumber + 1
		if (v > this.VoiceCount)
			v := 1
		return this.SetVoiceByIndex(v)
	}

	; Returns an array of voice names
	GetVoices() {
		return this.VoiceList
	}

	GetStatus(){
		Status := this.oVoice.Status.RunningState
		if Status = 0 ; paused
			Return "paused"
		Else if Status = 1 ; finished
			Return "finished"
		Else if Status = 2 ; reading
			Return "reading"
	}

	GetCount() {
		return this.VoiceCount
	}

	SpeakToFile(param1, param2) {
		oldAOS := this.oVoice.AudioOutputStream
		, oldAAOFCONS := this.oVoice.AllowAudioOutputFormatChangesOnNextSet
		, this.oVoice.AllowAudioOutputFormatChangesOnNextSet := 1	

		, SpStream := ComObjCreate("SAPI.SpFileStream")
		FileDelete, % param2  ; OutputFilePath
		SpStream.Open(param2, 3)
		, this.oVoice.AudioOutputStream := SpStream
		, this.SpeakWait(param1)
		, SpStream.Close()
		, this.oVoice.AudioOutputStream := oldAOS
		, this.oVoice.AllowAudioOutputFormatChangesOnNextSet := oldAAOFCONS
	}

	; ====== Private funcs, not intended to be called by user =======
	_GetVoices() {
		this.VoiceList := []
		, this.VoiceAssoc := {}
		, this.VoiceCount := this.oVoice.GetVoices.Count
		Loop, % this.VoiceCount
			Name := this.oVoice.GetVoices.Item(A_Index-1).GetAttribute("Name")  ; 0 based
			, this.VoiceList.push(Name)
			, this.VoiceAssoc[Name] := A_Index
	}
}