# AutoClick (Pascal Script Compiler)

![](Images/main.jpg)

## Download
  https://github.com/ddeeproton/AutoClick-Pascal-Script-IDE-/raw/master/Source/AutoClick_PascalScriptIDE.exe
  
## Source 
  https://github.com/ddeeproton/AutoClick-Pascal-Script-IDE-/archive/master.zip
  
## Compilator
  https://www.lazarus-ide.org/
  
## Description
If you know Pascal programming language, with AutoClick you can set automatic clicks on your Windows computer. Special functions for mouse and screen controling are added in this project. And a generator code is aviable to help coding Pascal Scripts. 

## Librairy added in Unit1.pas 
```
procedure TForm1.PSScript1Compile(Sender: TPSScript);
begin
  Sender.AddFunction(@SetNextScript, 'procedure SetNextScript(const s: string)');
  Sender.AddFunction(@Log, 'procedure Log(const s: string)');
  Sender.AddFunction(@DoSleep, 'procedure DoSleep(i: Integer)');
  Sender.AddFunction(@RunScript, 'procedure RunScript(const f: String)');
  Sender.AddFunction(@RunScriptAndContinue,'procedure RunScriptAndContinue(const f: String)');
  Sender.AddMethod(Actions, @Actions.getColorHexPositionPix, 'function getColorHexPositionPix(x,y: Integer):String;');
  Sender.AddMethod(Actions, @Actions.MouseClick, 'procedure MouseClick(x,y: Integer);');
  Sender.AddMethod(Actions, @Actions.MouseMove, 'procedure MouseMove(x,y: Integer);');
  Sender.AddMethod(Actions, @Actions.MouseDown, 'procedure MouseDown();');
  Sender.AddMethod(Actions, @Actions.MouseUp, 'procedure MouseUp();');  
  Sender.AddMethod(Actions, @Actions.IsControlKeyPressed, 'function IsControlKeyPressed(): Boolean;');
  Sender.AddMethod(Actions, @Actions.IsKeyPressed, 'function IsKeyPressed(key:longint): Boolean;');
  Sender.AddMethod(Actions, @Actions.waitColorHexPositionPix2, 'procedure waitColorHexPositionPix2(x,y: Integer; hex:String; x2,y2: Integer; hex2:String);');
  Sender.AddMethod(Actions, @Actions.waitColorHexPositionPix, 'procedure waitColorHexPositionPix(x,y: Integer; hex:String);');
  Sender.AddMethod(Actions, @Actions.waitNotColorHexPositionPix, 'procedure waitNotColorHexPositionPix(x,y: Integer; hex:String);');
  Sender.AddMethod(Actions, @Actions.waitNotColorHexPositionPix2, 'procedure waitNotColorHexPositionPix2(x,y: Integer; hex:String; x2,y2: Integer; hex2:String);');
  Sender.AddMethod(Actions, @Actions.IsShiftlKeyPressed, 'function IsShiftlKeyPressed(): Boolean; ');
  Sender.AddMethod(Game, @Game.play, 'function play(x1,y1: Integer; c1:String; x2,y2: Integer; c2:String; x,y:Integer):Boolean');
  Sender.AddMethod(ProcessTask, @ProcessTask.ExecAndContinue, 'procedure ExecAndContinue(sExe, sFile: string; wShowWin: Word)');
  Sender.AddMethod(ProcessTask, @ProcessTask.ExecAndContinue, 'procedure ExecAndContinue(sExe, sFile: string)');
  Sender.AddMethod(ProcessTask, @ProcessTask.KillTask, 'function KillTask(ExeFileName: string): Integer;');
  Sender.AddMethod(ProcessTask, @ProcessTask.CloseProcessPID, 'procedure CloseProcessPID(pid: Integer)');  
  Sender.AddMethod(ScreenManager, @ScreenManager.PrintScreen, 'function PrintScreen(filename: String): Boolean;');
  Sender.AddMethod(ScreenManager, @ScreenManager.getMousePosX, 'function getMousePosX(): Integer;');
  Sender.AddMethod(ScreenManager, @ScreenManager.getMousePosY, 'function getMousePosY(): Integer;');  
  Sender.AddFunction(@ReadFromFile, 'function ReadFromFile(Filename: string):String;');
  Sender.AddFunction(@WriteInFile, 'procedure WriteInFile(Filename, txt: string);');
  Sender.AddFunction(@makeDir, 'function makeDir(path:string):Boolean;'); 
end;
```
## Debug error
You may see this message when opening the project. ("TPSScript" is not found).

![](Images/Error_tpsscript.png)

To resolve this is issue, open unit1.pas in graphical mode. And a message to resolve this issue will appear. 

![](Images/Solution_tpsscript.png)

Click "install these packages"

## Changes

### v 0.2
Allow to start a pascal script on application start, if a ".pss" file is set in parameter to AutoClick_PascalScriptIDE.exe 

Like this (Batch script):
```
AutoClick_PascalScriptIDE.exe "myscript.pss" 
```
You can also copy "AutoClick_PascalScriptIDE.exe" into a new name, and manage it from PascalScript code:

Like this (Pascal Script):
```
ExecAndContinue('AutoClick_PascalScriptIDE_2.exe','MyScriptToStart.pss /');

KillTask('AutoClick_PascalScriptIDE_2.exe'); 
```

### v 0.3
New functions are added:
```
  procedure MouseMove(x,y: Integer);
  procedure MouseDown();
  procedure MouseUp();
```
### v 0.4
New function is added
```
  procedure MouseMoveRelative(x,y: Integer);
```
### v 0.5
Function modified
```
  procedure MouseDown(x,y: Integer);
  procedure MouseUp(x,y: Integer);
```
### v 0.6
New function is added
```
  function PrintScreen(filename: String): Boolean;  
```

### v 0.7
Bug fix with PrintScreen. On repeated call.
 
### v 0.8
Bug fix - Current default path is set to database directory
New function is added
```
  function FileExists(Const FileName:String): Boolean;
```

### v 0.9
New functions are added
```
  function getMousePosX(): Integer;
  function getMousePosY(): Integer;
```

### v 0.10
Add relative path in exemples for creation new script
New functions are added
```
  function EraseFile(Const FileName:String): Boolean;
  function getClipboard: String;
  procedure setClipboard(txt: String);
```
### v 0.11
New functions are added
```
  procedure PressControlA;
  procedure PressControlC;
  procedure PressControlV;   
```
### v 0.12
New functions are added
```
  function ClientMessage(ServerName, message: String):Boolean;
  function ServerStart(ServerName:String):Boolean;
  function ServerStop:Boolean;
  function ServerStatus:Boolean;
  function ServerMessage: String;
  function ServerMessageWait: String;   
```

