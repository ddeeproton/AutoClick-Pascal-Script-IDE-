# Pascal-Script-IDE
AutoClick (Pascal Script Compiler)

![](Images/main.jpg)

## Download
  https://github.com/ddeeproton/AutoClick-Pascal-Script-IDE-/raw/master/Source/AutoClick_PascalScriptIDE.exe
  
## Source 
  https://github.com/ddeeproton/AutoClick-Pascal-Script-IDE-/archive/master.zip
  
## Compilator
  https://www.lazarus-ide.org/
  
## Description
If you know Pascal programming language, with AutoClick you can set automatic clicks on your Windows computer. Special functions for mouse and screen controling are added in this project. And a generator code is added to help coding Pascal Scripts. 

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
  Sender.AddMethod(Actions, @Actions.IsControlKeyPressed, 'function IsControlKeyPressed(): Boolean;');
  Sender.AddMethod(Actions, @Actions.IsKeyPressed, 'function IsKeyPressed(key:longint): Boolean;');
  Sender.AddMethod(Actions, @Actions.waitColorHexPositionPix2, 'procedure waitColorHexPositionPix2(x,y: Integer; hex:String; x2,y2: Integer; hex2:String);');
  Sender.AddMethod(Actions, @Actions.waitColorHexPositionPix, 'procedure waitColorHexPositionPix(x,y: Integer; hex:String);');
  Sender.AddMethod(Actions, @Actions.waitNotColorHexPositionPix, 'procedure waitNotColorHexPositionPix(x,y: Integer; hex:String);');
  Sender.AddMethod(Actions, @Actions.waitNotColorHexPositionPix2, 'procedure waitNotColorHexPositionPix2(x,y: Integer; hex:String; x2,y2: Integer; hex2:String);');
  Sender.AddMethod(Actions, @Actions.IsShiftlKeyPressed, 'function IsShiftlKeyPressed(): Boolean; ');
  Sender.AddMethod(Game, @Game.play, 'function play(x1,y1: Integer; c1:String; x2,y2: Integer; c2:String; x,y:Integer):Boolean;'); 
end;

