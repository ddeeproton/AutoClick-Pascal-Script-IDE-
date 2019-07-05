unit UScreenManager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Clipbrd, Windows, Graphics, Forms;

type
  ScreenManager = class
    class function PrintScreen(filename: String): Boolean;
  end;


implementation

class function ScreenManager.PrintScreen(filename: String): Boolean;
Const KeyPrintScreen = 44; //Touche Prt Scr du clavier
var Image_Bmp:TBitmap;
    Image_Jpg:TJpegImage;
    Screen:Byte;
    function GetAsHandle(Format: Word): THandle;
    begin
      OpenClipboard(0);
      try
        Result := GetClipboardData(Format);
      finally
        CloseClipboard;
      end;
    end;
begin
  Screen := 0;
  ClipBoard.Clear;
  keybd_event(KeyPrintScreen, Screen, 0, 0);
  keybd_event(KeyPrintScreen, Screen, KEYEVENTF_KEYUP, 0);

  Sleep(1000);

  //Si le presse-papier contient un bitmap
  if ClipBoard.HasFormat(cf_BitMap) then
  begin
    Image_Bmp := TBitMap.Create;
    Image_Jpg := TJpegImage.Create;
    try
      //Image_Bmp.LoadFromClipboardFormat(cf_BitMap, GetAsHandle(cf_Bitmap),0);
      Image_Bmp.LoadFromClipboardFormat(cf_BitMap);
      Clipboard.Clear();
      Image_Jpg.CompressionQuality:=80;
      Image_Jpg.Assign(Image_Bmp);
      // Enregistrement de l'image
      try
        Image_Jpg.SaveToFile(filename+'.jpg');
      except
        result := False;
      end;
    finally
      Image_Bmp.Free;
      Image_Jpg .Free;
    end;
  end;
  result := FileExists(filename+'.jpg');
end;

end.


end.

