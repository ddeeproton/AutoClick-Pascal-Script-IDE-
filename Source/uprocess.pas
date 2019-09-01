unit uprocess;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, jwatlhelp32, ShellAPI, Windows;

type
  ProcessTask = class
    class procedure ExecAndContinue(sExe, sFile: string; wShowWin: Word);
    class procedure ExecAndContinue(sExe, sFile: string);
    class function KillTask(ExeFileName: string): Integer;
    class procedure CloseProcessPID(pid: Integer);
    class procedure ExecAndWait(sExe, sFile: string);
    class procedure ExecAndWait(sExe, sFile: string; wShowWin: Word);
  end;

  function IsUserAnAdmin(): Boolean; external shell32;

implementation
                                                                   
class procedure ProcessTask.ExecAndWait(sExe, sFile: string);
begin
  ProcessTask.ExecAndWait(sExe, sFile, SW_SHOW);
end;

class procedure ProcessTask.ExecAndWait(sExe, sFile: string; wShowWin: Word);
var
  h: Cardinal;
  operation: PChar;
begin
  if IsUserAnAdmin() then operation := 'open' else operation := 'runas';
  h := 0;
  ShellExecute(h, operation, PChar(sExe), PChar(sFile), nil,wShowWin);
  WaitForSingleObject(h, INFINITE);
end;



class procedure ProcessTask.ExecAndContinue(sExe, sFile: string; wShowWin: Word);
var
  h: Cardinal;
  operation: PChar;
begin
  if IsUserAnAdmin() then operation := 'open' else operation := 'runas';
  h := 0;
  ShellExecute(h, operation, PChar(sExe), PChar(sFile), nil,wShowWin);
end;


class procedure ProcessTask.ExecAndContinue(sExe, sFile: string);
begin
  ProcessTask.ExecAndContinue(sExe, sFile, SW_SHOW);
end;



class procedure ProcessTask.CloseProcessPID(pid: Integer);
var
  processHandle: THandle;
begin
  try
    processHandle := OpenProcess(PROCESS_TERMINATE or PROCESS_QUERY_INFORMATION, False, pid);
    if processHandle <> 0 then
    begin
      //Terminate the process
      TerminateProcess(processHandle, 0);
      CloseHandle(ProcessHandle);
    end;
  except
    On E : EOSError do exit;
    On E : EAccessViolation do exit;
  end;
end;


// uses jwatlhelp32; // for Lazarus
// uses Tlhelp32; // for Delphi
class function ProcessTask.KillTask(ExeFileName: string): Integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  try
    FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
    ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
    while Integer(ContinueLoop) <> 0 do
    begin
      if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
        UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
        UpperCase(ExeFileName))) then

        ProcessTask.CloseProcessPID(FProcessEntry32.th32ProcessID);
        result := 1;

        {Result := Integer(TerminateProcess(
                          OpenProcess(PROCESS_TERMINATE,
                                    BOOL(0),
                                    FProcessEntry32.th32ProcessID),
                                    0));
        }
      ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
    end;

    CloseHandle(FSnapshotHandle);
  except
    On E : EOSError do exit;
    On E : EAccessViolation do exit;
  end;
end;


end.

