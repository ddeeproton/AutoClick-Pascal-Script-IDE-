unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterPas, uPSComponent, Forms,
  Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, Menus, ComCtrls, ShellCtrls,
  Spin, uPSRuntime, uPSComponent_Default, umousekeyboard, uPSCompiler, uPSUtils,
  Windows, uprocess;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonCloseGenerator: TButton;
    ButtonCodeCopy: TButton;
    ButtonCodeInsert: TButton;
    ButtonListenKeyboard: TButton;
    ComboBoxCode: TComboBox;
    Label5: TLabel;
    LabeledEdit1: TLabeledEdit;
    ListBox1: TListBox;
    MainMenu1: TMainMenu;
    Memo2: TMemo;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItemDisableLog: TMenuItem;
    MenuItemFunctionGenerator: TMenuItem;
    MenuItem1Options: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItemSaveAs: TMenuItem;
    MenuItemClearCache: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    MenuItemRename: TMenuItem;
    MenuItemDeleteDirOrFile: TMenuItem;
    MenuItemDelete: TMenuItem;
    MenuItemCutClip: TMenuItem;
    MenuItemPaste: TMenuItem;
    MenuItemCopyClip: TMenuItem;
    MenuItemNewFile: TMenuItem;
    MenuItemSave: TMenuItem;
    MenuItemRunFromCache: TMenuItem;
    MenuItemRunAndSave: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItemCreateDir: TMenuItem;
    MenuItemStop: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    PopupMenuTrayIcon: TPopupMenu;
    PopupMenuSynEdit1: TPopupMenu;
    PopupMenuShellView: TPopupMenu;
    PSScript1: TPSScript;
    SaveDialog1: TSaveDialog;
    ShellTreeView1: TShellTreeView;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    Splitter4: TSplitter;
    SynEdit1: TSynEdit;
    SynPasSyn1: TSynPasSyn;
    TimerRecord: TTimer;
    TrayIcon1: TTrayIcon;
    procedure ButtonCloseGeneratorClick(Sender: TObject);
    procedure ButtonCodeCopyClick(Sender: TObject);
    procedure ButtonCodeInsertClick(Sender: TObject);
    procedure ButtonListenKeyboardClick(Sender: TObject);
    procedure ButtonRunClick(Sender: TObject);
    procedure ComboBoxCodeSelect(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem15Click(Sender: TObject);
    procedure MenuItem17Click(Sender: TObject);
    procedure MenuItem18Click(Sender: TObject);
    procedure MenuItemClearCacheClick(Sender: TObject);
    procedure MenuItemCopyClipClick(Sender: TObject);
    procedure MenuItemCreateDirClick(Sender: TObject);
    procedure MenuItemCutClipClick(Sender: TObject);
    procedure MenuItemDeleteClick(Sender: TObject);
    procedure MenuItemDeleteDirOrFileClick(Sender: TObject);
    procedure MenuItemDisableLogClick(Sender: TObject);
    procedure MenuItemFunctionGeneratorClick(Sender: TObject);
    procedure MenuItemNewFileClick(Sender: TObject);
    procedure MenuItemPasteClick(Sender: TObject);
    procedure MenuItemRenameClick(Sender: TObject);
    procedure MenuItemRunFromCacheClick(Sender: TObject);
    procedure MenuItemSaveAsClick(Sender: TObject);
    procedure MenuItemSaveClick(Sender: TObject);
    procedure MenuItemStopClick(Sender: TObject);
    procedure PSScript1Compile(Sender: TPSScript);
    procedure ShellTreeView1Changing(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure ShellTreeView1Click(Sender: TObject);
    procedure SynEdit1Change(Sender: TObject);
    procedure SynEdit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TimerRecordTimer(Sender: TObject);
    procedure AddLog(s: String);
  private

  public

  end;

  ProcessScript = class
    class procedure RunScript(f: string);
    class procedure RunScriptThread(f: string);
    class procedure RefreshFormDisplay();
    class function Count(): Integer;
  end;

  ThreadProcess = class(TThread)
  protected
    fileExec: string;
    procedure Execute; override;
  end;

  TCache = record
    Name: string;
    Data: TStringList;
  end;

  TProcessScripts = record
    enabled: Boolean;
    Name: string;
    Data: TPSScript;
  end;

var
  Form1: TForm1;
  ProcessScripts: array of TProcessScripts;
  Cache: array of TCache;
  currentPath, dataPath: String;
  RunNextScript: string;
  CanEraseProcessScripts: Integer;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.AddLog(s: String);
begin
  if MenuItemDisableLog.Checked then Exit;
  Memo2.Lines.Add(s);
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
  SynEdit1.Clear;   
  SynEdit1.Enabled := False;
  Memo2.Clear;
  RunNextScript:= '';
  currentPath := ExtractFileDir(Application.ExeName);
  dataPath := currentPath + '\data';
  if not DirectoryExists(dataPath) then mkdir(dataPath);
  ShellTreeView1.Root := dataPath;
                                            
  Form1.Caption:=ShellTreeView1.Path;
  ProcessScript.RefreshFormDisplay();

  Panel4.Visible:=False;
  Splitter4.Visible:=False;

  CanEraseProcessScripts := 0;
end;


procedure TForm1.MenuItemFunctionGeneratorClick(Sender: TObject);
begin
  if not SynEdit1.Enabled then
  begin
    ShowMessage('Please open a script');
    Exit;
  end;
  Panel4.Visible:=True;
  Splitter4.Visible:=True; 
  ComboBoxCodeSelect(ComboBoxCode);

end;


procedure TForm1.ComboBoxCodeSelect(Sender: TObject);
begin
  TimerRecordTimer(nil);
end;


procedure TForm1.MenuItem10Click(Sender: TObject);
begin
  if (ShellTreeView1.Path = '')
  or not FileExists(ShellTreeView1.Path) then Exit;
  MenuItemClearCacheClick(nil);
  ProcessScript.RunScriptThread(ShellTreeView1.Path);
end;


procedure TForm1.MenuItem15Click(Sender: TObject);
begin
  MenuItemStopClick(nil);
  Application.Terminate;;
end;


procedure TForm1.MenuItem17Click(Sender: TObject);
begin
  Hide;
end;


procedure TForm1.MenuItem18Click(Sender: TObject);
begin
  Show;
  BringToFront;
end;


procedure TForm1.MenuItemClearCacheClick(Sender: TObject);
var i: Integer;
begin
  for i := 0 to Length(Cache) - 1 do
  begin
    Cache[i].Data.Free;
    AddLog('[Cache cleared] ' + Cache[i].Name.Replace(dataPath, ''));
  end;
  SetLength(Cache, 0);
end;


procedure TForm1.MenuItemCopyClipClick(Sender: TObject);
begin
  SynEdit1.CopyToClipboard;
end;


procedure TForm1.MenuItemCreateDirClick(Sender: TObject);
var
  dir, cdir: string;
begin
  if DirectoryExists(ShellTreeView1.Path) then
  begin
    cdir := ShellTreeView1.Path;
  end else begin
    cdir := dataPath+'\';
  end;

  if not InputQuery('New dir in:', ' '+cdir+'', dir) then Exit;

  if dir = '' then
  begin
    ShowMessage('Name is empty!');
    Exit;
  end;

  mkdir(cdir+dir);
                                 
  ShellTreeView1.Root := currentPath;
  ShellTreeView1.Root := dataPath;
  ShellTreeView1.Path:=cdir+dir;
end;


procedure TForm1.MenuItemCutClipClick(Sender: TObject);
begin
  SynEdit1.CutToClipboard;
end;


procedure TForm1.MenuItemDeleteClick(Sender: TObject);
begin
  SynEdit1.ClearSelection;
end;


procedure TForm1.MenuItemDeleteDirOrFileClick(Sender: TObject);
begin
  if ShellTreeView1.Path = '' then
  begin
    ShowMessage('No file or dir selected');
    Exit;
  end;

  if ShellTreeView1.Path = dataPath+'\' then
  begin
    if MessageDlg('Erase all database?', 'Erase all database?', mtConfirmation,
     [mbYes, mbNo],0) <> mrYes
    then Exit;

    if MessageDlg('Erase all database?', 'Erase all database? ARE YOU SURE ? ', mtConfirmation,
     [mbYes, mbNo],0) <> mrYes
    then Exit;

    MenuItemStopClick(nil);

    DeleteDirectory(ShellTreeView1.Path, True);

    ShellTreeView1.Root := currentPath;
    ShellTreeView1.Root := dataPath;
    Exit;
  end;

  if MessageDlg('Delete?', ShellTreeView1.Path, mtConfirmation,
   [mbYes, mbNo],0) <> mrYes
  then Exit;

  if FileExists(ShellTreeView1.Path) then
  begin
    DeleteFile(PChar(ShellTreeView1.Path));
  end;
  if DirectoryExists(ShellTreeView1.Path)
  and not (ShellTreeView1.Path = dataPath) then
  begin
    DeleteDirectory(ShellTreeView1.Path, false);
  end;

  ShellTreeView1.Root := currentPath;
  ShellTreeView1.Root := dataPath;
end;

procedure TForm1.MenuItemDisableLogClick(Sender: TObject);
begin
  MenuItemDisableLog.Checked := not MenuItemDisableLog.Checked;
end;


procedure TForm1.MenuItemNewFileClick(Sender: TObject);
var
  filescript, cdir: string;
begin

  if DirectoryExists(ShellTreeView1.Path) then
  begin
    cdir := ShellTreeView1.Path;
  end else begin
    cdir := dataPath+'\';
  end;

  if not InputQuery('New file in:', ' '+cdir+'', filescript) then Exit;

  if filescript = '' then
  begin
    ShowMessage('Name is empty!');
    Exit;
  end;

  SynEdit1.Clear;
  SynEdit1.Lines.Add('//var i: Integer;');
  SynEdit1.Lines.Add('begin');
  SynEdit1.Lines.Add('//RunScript('''+filescript+'.pss''); ');
  SynEdit1.Lines.Add('//RunScriptAndContinue('''+filescript+'.pss''); ');
  SynEdit1.Lines.Add('//SetNextScript('''+filescript+'.pss''); ');
  SynEdit1.Lines.Add('//Log('''+filescript+'.pss''); ');
  SynEdit1.Lines.Add('');
  SynEdit1.Lines.SaveToFile(cdir+filescript+'.pss');
  ShellTreeView1.Root := currentPath;
  ShellTreeView1.Root := dataPath;
  ShellTreeView1.Path:=cdir+filescript+'.pss';

  Form1.Caption := cdir+filescript+'.pss';
end;


procedure TForm1.MenuItemPasteClick(Sender: TObject);
begin
  SynEdit1.PasteFromClipboard;
end;


procedure TForm1.MenuItemRenameClick(Sender: TObject);
var
  newName, newNameInput: String;
  f:TextFile;
begin
  if FileExists(ShellTreeView1.Path) then
  begin
    newName := ExtractFileName(ShellTreeView1.Path);
    newName := ExtractFileNameWithoutExt(newName);
    if not InputQuery('Rename', ShellTreeView1.Path, newName) then Exit;
    if newName = '' then
    begin
      ShowMessage('Name is empty!');
      Exit;
    end;
    newName := ExtractFileDir(ShellTreeView1.Path) + '\' +  newName + '.pss';

    RenameFile(ShellTreeView1.Path, newName);

    ShellTreeView1.Root := currentPath;
    ShellTreeView1.Root := dataPath;
    ShellTreeView1.Path:=newName;
  end;

  if DirectoryExists(ShellTreeView1.Path) then
  begin
    if ShellTreeView1.Path = dataPath+'\' then
    begin
      ShowMessage('Renaming disabled on root directory');
      Exit;
    end;                  
    newNameInput := ExtractFileDir(ShellTreeView1.Path);
    newNameInput := newNameInput.Remove(0, newNameInput.LastIndexOf('\') + 1);
    if not InputQuery('Rename', ShellTreeView1.Path, newNameInput) then Exit;
    if newNameInput = '' then
    begin
      ShowMessage('Name is empty!');
      Exit;
    end;

    newName := ExtractFileDir(ShellTreeView1.Path);
    newName := newName.Remove(newName.LastIndexOf('\') + 1);
    newName := newName + newNameInput;

    AssignFile(f, ShellTreeView1.Path);
    Rename(f, newName);

    ShellTreeView1.Root := currentPath;
    ShellTreeView1.Root := dataPath;
    ShellTreeView1.Path:=newName;
  end;
end;


procedure TForm1.MenuItemRunFromCacheClick(Sender: TObject);
begin
  if (ShellTreeView1.Path = '')
  or not FileExists(ShellTreeView1.Path) then Exit;
  ProcessScript.RunScriptThread(ShellTreeView1.Path);
end;


procedure TForm1.MenuItemSaveAsClick(Sender: TObject);
begin
  SaveDialog1.DefaultExt:='pss';
  SaveDialog1.InitialDir:=ExtractFileDir(ShellTreeView1.Path);
  if not SaveDialog1.Execute then Exit;
  SynEdit1.Lines.SaveToFile(SaveDialog1.FileName);
end;


procedure TForm1.MenuItemSaveClick(Sender: TObject);
var
  i: Integer;
begin
  if (ShellTreeView1.Path = '')
  or not FileExists(ShellTreeView1.Path) then Exit;
  SynEdit1.Lines.SaveToFile(ShellTreeView1.Path);
  Form1.Caption:= ShellTreeView1.Path;
  AddLog('[File saved] ' + ShellTreeView1.Path.Replace(dataPath, ''));
  for i := 0 to Length(Cache) - 1 do
  begin
    if Cache[i].Name = ShellTreeView1.Path then
    begin
      Cache[i].Data.Free;
      Cache[i].Data := TStringList.Create;
      Cache[i].Data.LoadFromFile(ShellTreeView1.Path);
      AddLog('[Cache cleared] ' + ShellTreeView1.Path.Replace(dataPath, ''));
    end;
  end;
end;


procedure TForm1.MenuItemStopClick(Sender: TObject);
var
  i: integer;
begin
  if Length(ProcessScripts) = 0 then
  begin                    
      AddLog('[Stop] No process to stop');
  end;
  for i := 0 to Length(ProcessScripts) - 1 do
  begin
    if ProcessScripts[i].enabled then
    begin
      ProcessScripts[i].Data.Exec.Stop;
      while ProcessScripts[i].Data.Exec.Status = uPSRuntime.TPSStatus.isRunning do
      begin
        Application.ProcessMessages;
        Sleep(10);
      end;
      AddLog('[Stop] '+ProcessScripts[i].Name.Replace(dataPath, ''));
      //ProcessScripts[i].Data.Free;
      ProcessScripts[i].enabled := False;
    end;
  end;

  while CanEraseProcessScripts > 0 do
  begin
    Sleep(100);
    Application.ProcessMessages;
  end;

  if ProcessScript.Count() = 0 then
  begin
    SetLength(ProcessScripts, 0);
  end;

  ProcessScript.RefreshFormDisplay();
end;


class procedure ProcessScript.RunScriptThread(f: string);
var
  p: ThreadProcess;
begin
  p := Unit1.ThreadProcess.Create(True);
  p.fileExec := f;
  p.FreeOnTerminate := True;
  p.Start;
end;


class function ProcessScript.Count(): Integer;
var
  i: Integer;
begin
  result := 0;

  for i := 0 to Length(ProcessScripts) - 1 do
  begin
    if ProcessScripts[i].enabled then
      inc(result);
  end;

end;


class procedure ProcessScript.RefreshFormDisplay();
var
  i: Integer;
begin
  inc(CanEraseProcessScripts);
  with Form1 do
  begin
    ListBox1.Items.Clear;
    if Length(ProcessScripts) = 0 then
    begin
      ListBox1.Items.Add('No process running');
    end else begin
      for i := 0 to Length(ProcessScripts) - 1 do
      begin
        if ProcessScripts[i].enabled then
        ListBox1.Items.Add('['+IntToStr(i)+'] '+ProcessScripts[i].Name.Replace(dataPath, ''));
      end;
    end;

  end;
  dec(CanEraseProcessScripts);
end;


class procedure ProcessScript.RunScript(f: string);
var
  i, index, indexCache: integer;
  Compiled, isEmpty, CacheLoaded: boolean;
  Script: TPSScript;
  nScript: String;
begin
  with Form1 do
  begin
    Script := TPSScript.Create(nil);

    // Add Script to array ProcessScripts
    SetLength(ProcessScripts, Length(ProcessScripts) + 1);
    index := Length(ProcessScripts) - 1;
    ProcessScripts[index].Data := Script;
    ProcessScripts[index].Name := f;
    ProcessScripts[index].enabled:= True;
    ProcessScript.RefreshFormDisplay();

    // Script event
    Script.OnCompile := @PSScript1Compile;

    // Try Load cache
    CacheLoaded := False;
    for i := 0 to Length(Cache) - 1 do
    begin
      if Cache[i].Name =  f then
      begin                               
        CacheLoaded := True;
        Script.Script.AddStrings(Cache[i].Data);
      end;
    end;

    if not CacheLoaded then
    begin
      SetLength(Cache, Length(Cache) + 1);
      indexCache := Length(Cache) - 1;
      Cache[indexCache].Name := f;
      Cache[indexCache].Data := TStringList.Create;
      Cache[indexCache].Data.LoadFromFile(f);
      Script.Script.AddStrings(Cache[indexCache].Data);
    end;

    if CacheLoaded then
      AddLog('[Cache loaded] '+f.Replace(dataPath, ''))
    else
      AddLog('[File loaded] '+f.Replace(dataPath, ''));

    Script.Script.Insert(0, 'program script;' + #13#10);
    Script.Script.Add(#13#10 + 'end.');
    Compiled := Script.Compile();
    for i := 0 to Script.CompilerMessageCount - 1 do
      AddLog(Script.CompilerMessages[i].MessageToString);
    if not Compiled then
      if Script.CompilerMessageCount > 0 then
        for i := 0 to Script.CompilerMessageCount - 1 do
          AddLog(Script.CompilerErrorToStr(i));

    AddLog('[Start run] '+f.Replace(dataPath, ''));
    Script.Exec.RunScript;
    AddLog('[End run] '+f.Replace(dataPath, ''));

    // Disable the handle of the process
    if Length(ProcessScripts) > index then
    begin
      if ProcessScripts[index].enabled then
      begin
        Script.Free;
        ProcessScripts[index].enabled:= False;
      end;
    end;

    // if all Handle are disabled
    if ProcessScript.Count() = 0 then
    begin
      // Erase all data
      SetLength(ProcessScripts, 0);
    end;

    ProcessScript.RefreshFormDisplay();

    if RunNextScript <> '' then
    begin
      nScript := RunNextScript;
      RunNextScript := '';
      ProcessScript.RunScript(dataPath + '\' + nScript);
    end;
  end;
end;


procedure ThreadProcess.Execute;
begin
  ProcessScript.RunScript(fileExec);
end;


procedure TForm1.ButtonRunClick(Sender: TObject);
begin
  if (ShellTreeView1.Path = '')
  or not FileExists(ShellTreeView1.Path) then
  begin
    AddLog('[Run] No file selected');
    Exit;
  end;
  MenuItemSaveClick(nil);
  ProcessScript.RunScriptThread(ShellTreeView1.Path);
end;


procedure TForm1.ButtonListenKeyboardClick(Sender: TObject);
begin                                            
  TimerRecord.Enabled := not TimerRecord.Enabled;
  if TimerRecord.Enabled then
  begin
    ButtonListenKeyboard.Caption:= 'Listen ON';
  end
  else begin
    ButtonListenKeyboard.Caption:= 'Listen OFF';
  end;
  TimerRecordTimer(nil);
end;


procedure TForm1.ButtonCodeCopyClick(Sender: TObject);
begin
  LabeledEdit1.SelectAll;
  LabeledEdit1.CopyToClipboard;
end;


procedure TForm1.ButtonCloseGeneratorClick(Sender: TObject);
begin
    Panel4.Visible:=False;
    Splitter4.Visible:=False;
end;


procedure TForm1.ButtonCodeInsertClick(Sender: TObject);
begin  
  LabeledEdit1.SelectAll;
  LabeledEdit1.CopyToClipboard;
  SynEdit1.PasteFromClipboard;
end;


procedure SetNextScript(const s: string);
begin
  RunNextScript := s;
end;


procedure Log(const s: string);
begin
  Form1.Memo2.Lines.add(s);
end;


procedure RunScript(const s: string);
begin
  ProcessScript.RunScript(dataPath + '\' + s);
end;


procedure RunScriptAndContinue(const s: string);
begin
  ProcessScript.RunScriptThread(dataPath + '\' + s);
end;


procedure DoSleep(t: integer);
begin
  Sleep(t);
end;


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
  Sender.AddMethod(Game, @Game.play, 'function play(x1,y1: Integer; c1:String; x2,y2: Integer; c2:String; x,y:Integer):Boolean');
  Sender.AddMethod(ProcessTask, @ProcessTask.ExecAndContinue, 'procedure ExecAndContinue(sExe, sFile: string)');
  Sender.AddMethod(ProcessTask, @ProcessTask.KillTask, 'function KillTask(ExeFileName: string): Integer;');
  Sender.AddMethod(ProcessTask, @ProcessTask.CloseProcessPID, 'procedure CloseProcessPID(pid: Integer)');
{
  ProcessTask = class
    class procedure ExecAndContinue(sExe, sFile: string; wShowWin: Word);
    class procedure ExecAndContinue(sExe, sFile: string);
    class function KillTask(ExeFileName: string): Integer;
    class procedure CloseProcessPID(pid: Integer);
  end;
}

end;


procedure TForm1.ShellTreeView1Changing(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
begin
  if Form1.Caption = '' then
  begin
    //ShowMessage('Empty');
    Exit;
  end;

  if Form1.Caption[Length(Form1.Caption)] <> '*' then
  begin
    //ShowMessage('No change');
    Exit;
  end;

  if MessageDlg('Save modification?', ' Save modification? ', mtConfirmation,
   [mbYes, mbNo],0) <> mrYes
  then Exit;

  MenuItemSaveClick(nil);
end;


procedure TForm1.ShellTreeView1Click(Sender: TObject);
begin
  if (ShellTreeView1.Path = '')
  or not FileExists(ShellTreeView1.Path) then Exit;
  SynEdit1.Enabled := True;
  SynEdit1.Lines.LoadFromFile(ShellTreeView1.Path);
  Form1.Caption:=ShellTreeView1.Path;
end;


procedure TForm1.SynEdit1Change(Sender: TObject);
begin
  if Length(Form1.Caption) = 0 then
  begin
    Form1.Caption := '*';
    Exit;
  end;
  if Form1.Caption[Length(Form1.Caption)] <> '*' then
  Form1.Caption := Form1.Caption + '*';
end;


procedure TForm1.SynEdit1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) and (Upcase(Char(Key)) = 'S') then
  begin
    MenuItemSaveClick(nil);
  end;
  if (Shift = [ssCtrl]) and (Upcase(Char(Key)) = 'D') then
  begin
    ButtonRunClick(nil);
  end;
  if (Shift = [ssCtrl]) and (Upcase(Char(Key)) = 'F') then
  begin
    MenuItemStopClick(nil);
  end;
end;


var
  P1_value: Integer = 0;
  P2_value: Integer = 0;
  P3_value: String = '';
  P4_value: Integer = 0;
  P5_value: Integer = 0;
  P6_value: String = '';
  P7_value: Integer = 0;
  P8_value: Integer = 0;

procedure TForm1.TimerRecordTimer(Sender: TObject);
var
  p: TPixelColor;
  index: Integer;
begin
  if Sender <> nil then TTimer(Sender).Enabled:=False;

  if Actions.IsKeyPressed(VK_F1) then
  begin
    p := Actions.getMousePix();
    P1_value := p.position.x;
    P2_value := p.position.y;
    P3_value := p.color.ToHexString;
    p.Free;
  end;

  if Actions.IsKeyPressed(VK_F2) then
  begin
    p := Actions.getMousePix();
    P4_value := p.position.x;
    P5_value := p.position.y;
    P6_value := p.color.ToHexString;
    p.Free;
  end;

  if Actions.IsKeyPressed(VK_F3) then
  begin
    p := Actions.getMousePix();
    P7_value := p.position.x;
    P8_value := p.position.y;
    p.Free;
  end;

  index := ComboBoxCode.ItemIndex;

  if index = -1 then LabeledEdit1.Text := '';
  if index = 0 then LabeledEdit1.Text := 'if (getColorHexPositionPix('+IntToStr(P1_value)+', '+IntToStr(P2_value)+') = '''+P3_value+''') then';
  if index = 1 then LabeledEdit1.Text := 'MouseClick('+IntToStr(P1_value)+', '+IntToStr(P2_value)+');';   
  if index = 2 then LabeledEdit1.Text := 'waitColorHexPositionPix('+IntToStr(P1_value)+', '+IntToStr(P2_value)+', '''+P3_value+''');';
  if index = 3 then LabeledEdit1.Text := 'waitColorHexPositionPix2('+IntToStr(P1_value)+', '+IntToStr(P2_value)+', '''+P3_value+''', '+IntToStr(P4_value)+', '+IntToStr(P5_value)+', '''+P6_value+''');';
  if index = 4 then LabeledEdit1.Text := 'waitNotColorHexPositionPix('+IntToStr(P1_value)+', '+IntToStr(P2_value)+', '''+P3_value+''');';
  if index = 5 then LabeledEdit1.Text := 'waitNotColorHexPositionPix2('+IntToStr(P1_value)+', '+IntToStr(P2_value)+', '''+P3_value+''', '+IntToStr(P4_value)+', '+IntToStr(P5_value)+', '''+P6_value+''');';
  if index = 6 then LabeledEdit1.Text := 'play('+IntToStr(P1_value)+', '+IntToStr(P2_value)+', '''+P3_value+''', '+IntToStr(P4_value)+', '+IntToStr(P5_value)+', '''+P6_value+''', '+IntToStr(P7_value)+', '+IntToStr(P8_value)+'); ';
  if index = 7 then LabeledEdit1.Text := 'ExecAndContinue(''application.exe'', ''-parameters'');';
  if index = 8 then LabeledEdit1.Text := 'KillTask(''application.exe'');';

  if Sender <> nil then TTimer(Sender).Enabled:=True;

  if TimerRecord.Enabled then
  begin
    if ComboBoxCode.ItemIndex = -1 then
    begin
      Label5.Caption:='Select a function';
    end else begin
      if index = 0 then Label5.Caption:='Move your mouse and press F1';
      if index = 1 then Label5.Caption:='Move your mouse and press F1';
      if index = 2 then Label5.Caption:='Move your mouse and press F1';
      if index = 3 then Label5.Caption:='Move your mouse and press F1 or F2';
      if index = 4 then Label5.Caption:='Move your mouse and press F1';
      if index = 5 then Label5.Caption:='Move your mouse and press F1 or F2';
      if index = 6 then Label5.Caption:='Move your mouse and press F1 or F2 or F3';
    end;
  end
  else begin
    if ComboBoxCode.ItemIndex = -1 then
    begin
      Label5.Caption:='Select a function';
    end else begin
      if (index >= 0) and (index <= 6) then Label5.Caption:='Press button listen';
    end;
  end;

  if (index = 7) or (index = 8) then Label5.Caption:='Copy the code';
end;


end.
