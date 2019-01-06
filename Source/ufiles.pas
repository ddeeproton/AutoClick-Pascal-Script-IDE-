unit ufiles;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

  function ReadFromFile(Filename: string):String;
  procedure WriteInFile(Filename, txt: string);
  function makeDir(path:string):Boolean;

implementation


function ReadFromFile(Filename: string):String;
var
  Fichier        : textfile;
  texte          : string;
begin
  result:= '';
  if not FileExists(Filename) then exit;
  try
    //reset(Fp);
    {$I-}
    assignFile(Fichier, Filename);
    reset(Fichier); // ouvre en lecture
    while not eof(Fichier) do begin
      readln(Fichier, texte);
      if texte <> '' then
        result := result + texte;
    end;
    closefile(Fichier);
    {$I+}
  except
  // If there was an error the reason can be found here
  on E: EInOutError do
    //writeln('File handling error occurred. Details: ', E.ClassName, '/', E.Message);
    exit;
  end;
end;


procedure WriteInFile(Filename, txt: string);
var
  Fp : textfile;
begin
  if not DirectoryExists(ExtractFileDir(Filename)) then exit;
  assignFile(Fp, Filename);
  try
    {$I-}
    reWrite(Fp);
    Write(Fp, txt);
    closefile(Fp);
    {$I+}
  except
  on E: EInOutError do
    //writeln('File handling error occurred. Details: ', E.ClassName, '/', E.Message);
    exit;
  end;
end;


function makeDir(path:string):Boolean; // return true if created
var
  error : Integer;
begin
  {$IOChecks off}
  MkDir(path);
  error := IOResult;
  result := error = 0;
  {$IOChecks on}
end;

end.

