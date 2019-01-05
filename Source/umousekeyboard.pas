unit UMouseKeyboard;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Windows;

type
    TPixelColor = class
      position: TPoint;
      color: COLORREF;
    end;

    Actions = class
      class function getColorHexPositionPix(x,y: Integer):String;
      class function getPositionPix(x,y: Integer):TPixelColor;
      class function getMousePix():TPixelColor;
      class procedure MouseClick(x,y: Integer);
      class function IsControlKeyPressed(): Boolean;
      class function IsKeyPressed(key:longint): Boolean;
      class procedure waitColorHexPositionPix2(x,y: Integer; hex:String; x2,y2: Integer; hex2:String);
      class procedure waitColorHexPositionPix(x,y: Integer; hex:String);
      class procedure waitNotColorHexPositionPix(x,y: Integer; hex:String);
      class procedure waitNotColorHexPositionPix2(x,y: Integer; hex:String; x2,y2: Integer; hex2:String);
      class function IsShiftlKeyPressed(): Boolean;
    end;

    Game = class
      class function play(x1,y1: Integer; c1:String; x2,y2: Integer; c2:String; x,y:Integer):Boolean;
    end;

implementation


procedure SplitStr(const Source, Delimiter: String; var DelimitedList: TStringList);
var
  s: PChar;
  DelimiterIndex: Integer;
  Item: String;
begin
  s:=PChar(Source);
  repeat
    DelimiterIndex:=Pos(Delimiter, s);
    if DelimiterIndex=0 then Break;
    Item:=Copy(s, 1, DelimiterIndex-1);
    DelimitedList.Add(Item);
    inc(s, DelimiterIndex + Length(Delimiter)-1);
  until DelimiterIndex = 0;
  DelimitedList.Add(s);
end;

class function Actions.getPositionPix(x,y: Integer):TPixelColor;
begin
  if (GetDC(0) = 0) then Exit;
  result := TPixelColor.Create;
  result.position := TPoint.Create(x, y);
  result.color:= GetPixel(GetDC(0), x, y);
  result.position.x := x;
  result.position.y := y;
end;

class function Actions.getMousePix():TPixelColor;
var
  CursorPos: TPoint;
begin
  if (GetDC(0) = 0) then Exit;
  if not GetCursorPos(CursorPos) then Exit;
  result := TPixelColor.Create;
  result.position := TPoint.Create(0,0);
  result := Actions.getPositionPix(CursorPos.x, CursorPos.y);
end;

class procedure Actions.MouseClick(x,y: Integer);
begin
  SetCursorPos(x, y);
  Mouse_Event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
  Mouse_Event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
end;

class function Actions.IsControlKeyPressed(): Boolean;
begin
  Result := GetKeyState(VK_SHIFT) < 0;
end;

class function Actions.IsKeyPressed(key:longint): Boolean;
begin
  Result := GetKeyState(key) < 0;
end;

class function Actions.getColorHexPositionPix(x,y: Integer):String;
var DC: HDC;
begin
  DC := GetDC(0);
  if (DC = 0) then Exit;
  result := GetPixel(DC, x, y).ToHexString;
  ReleaseDC(0, DC);
end;

class procedure Actions.waitColorHexPositionPix(x,y: Integer; hex:String);
begin
  while Actions.getColorHexPositionPix(x,y) = hex do
  begin
    Sleep(1000);
  end;
  Sleep(1000);
  while Actions.getColorHexPositionPix(x,y) = hex do
  begin
    Sleep(1000);
  end;
end;

class procedure Actions.waitColorHexPositionPix2(x,y: Integer; hex:String; x2,y2: Integer; hex2:String);
var i: Integer;
begin
  i := 0;
  while (Actions.getColorHexPositionPix(x,y) = hex)
  or (Actions.getColorHexPositionPix(x2,y2) = hex2) and (i < 10)  do
  begin
    Sleep(1000);
  inc(i);
  end;
  Sleep(1000);
  while (Actions.getColorHexPositionPix(x,y) = hex)
  or (Actions.getColorHexPositionPix(x2,y2) = hex2) and (i < 10)  do
  begin
    Sleep(1000);
  end;
end;

class procedure Actions.waitNotColorHexPositionPix(x,y: Integer; hex:String);
//var i: Integer;
begin
  //i := 0;
  //while (Actions.getColorHexPositionPix(x,y) <> hex) and (i < 100)  do
  while (Actions.getColorHexPositionPix(x,y) <> hex) do
  begin
    Sleep(200);
    //inc(i);
  end;

  Sleep(100);
  {
  while (Actions.getColorHexPositionPix(x,y) <> hex) and (i < 10)  do
  begin
    Sleep(1000);
    inc(i);
  end;
  }
end;

class procedure Actions.waitNotColorHexPositionPix2(x,y: Integer; hex:String; x2,y2: Integer; hex2:String);
begin
  while (Actions.getColorHexPositionPix(x,y) <> hex)
  or (Actions.getColorHexPositionPix(x2,y2) <> hex2) do
  begin
    Sleep(1000);
  end;
  //Sleep(1000);
  while (Actions.getColorHexPositionPix(x,y) <> hex)
  or (Actions.getColorHexPositionPix(x2,y2) <> hex2) do
  begin
    Sleep(1000);
  end;
end;

class function Actions.IsShiftlKeyPressed(): Boolean;
begin
  Result := GetKeyState(VK_SHIFT) < 0;
end;

class function Game.play(x1,y1: Integer; c1:String; x2,y2: Integer; c2:String; x,y:Integer):Boolean;
begin
  result := False;
  if (Actions.getColorHexPositionPix(x1, y1)  = c1)
  and (Actions.getColorHexPositionPix(x2, y2)  = c2) then
  begin
    Actions.MouseClick(x,y);
    result := True;
  end;
end;

end.

