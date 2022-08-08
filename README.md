# 项目简介
* 基于AutoHotkey制作的摄像头手势识别软件。能让你的电脑摄像头在识别手势后，执行自定义的电脑操作命令。同时也集成了语音识别功能，可调用Windows自带API实现简单的语音助手功能。

* 手势识别调用了高性能的Mediapipe动态链接库来免部署实现。而电脑自动化操作使用AutoHotkey脚本语言来实现，它能更方便的对电脑进行深度调用和流程自动化处理。

# 使用介绍
* 测试环境：Win10 64位（专业版完整镜像）

* **第一次运行 Visual_Gesture_Recognition.exe**时，会提示下载手势识别的**依赖包**。点击**确定**后，跟着提示**点击自动下载**。

　　![](https://gcore.jsdelivr.net/gh/dbgba/Projectimages@master/VisualGestureRecognition/%E4%B8%8B%E8%BD%BD%E4%BE%9D%E8%B5%96%E5%8C%85.jpg)

* 等待下载完成后，软件会**自动解压**并**适配手势识别**功能。

　　![](https://gcore.jsdelivr.net/gh/dbgba/Projectimages@master/VisualGestureRecognition/%E4%B8%8B%E8%BD%BD%E4%B8%AD.jpg)

* 之后就可以对你的**摄像头**进行**手势识别**控制了。下图示例为：当**双手抬起**并**竖起大拇指**时，就**执行打开网页并放大网页**。

　　![](https://gcore.jsdelivr.net/gh/dbgba/Projectimages@master/VisualGestureRecognition/%E6%B7%BB%E5%8A%A0%E6%89%8B%E5%8A%BF%E4%BB%A3%E7%A0%81.jpg)

* 软件还附带了**调用Windows自带API**来实现的**免费语音助手**。下图示例为：说出**电子电子**唤醒语音识别后，再说出关键字**启动游戏大厅**即可执行对应的**自定义流程**。

　　![](https://gcore.jsdelivr.net/gh/dbgba/Projectimages@master/VisualGestureRecognition/%E6%B7%BB%E5%8A%A0%E8%AF%AD%E9%9F%B3%E8%AF%86%E5%88%AB%E4%BB%A3%E7%A0%81.jpg)

　

* 更多**玩法**和用法，请详见**设置**与**帮助**的具体说明。例如：**当摄像头中有人时，自动切换到虚拟桌面。**
想创造更多自动化玩法组合，可使用软件附带的**生成快捷代码**和[AHK中文帮助文档](https://www.autoahk.com/help/autohotkey/zh-cn/docs/commands/WinActive.htm)来实现自己的**定制需求**。

# 注意事项

* 此exe文件为[AutoHotkey](https://github.com/Lexikos/AutoHotkey_L)开源项目，请将其加入杀毒-信任区。避免不必要的麻烦。

* 手势识别需要借助电脑的摄像头实现（任意摄像头都行），而语音识别需要接电脑麦克风实现。由于语音识别是调用Windows自带API来实现的，有些系统为了缩减体积会删掉此语音识别播报API导致无效。用原版镜像上安装的系统基本都不会出这问题。

* 我添加了4个手势依赖包的镜像源供高速下载，如果出现某个镜像源无法下载的情况。可根据弹出提示点击重新换源下载即可。如果镜像源和官方源自动下载都失效，只能自行想办法从官方GitHub下载"GoogleMediapipePackageDll-main.zip"压缩包后，将压缩包存放在"Lib"目录中，重启软件即可识别压缩包并解压适配手势识别功能。


# 感谢以下项目

>[peng-zhihui/ElectronBot: Open Source Desktop Robotics Project](https://github.com/peng-zhihui/ElectronBot)
>
>[Lexikos/AutoHotkey_L: AutoHotkey - macro-creation and automation-oriented scripting utility for Windows. (github.com)](https://github.com/Lexikos/AutoHotkey_L)
>
>[HW140701/GoogleMediapipePackageDll: package google mediapipe hand and holistic tracking into a dynamic link library](https://github.com/HW140701/GoogleMediapipePackageDll)
