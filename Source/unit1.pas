unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterPas, uPSComponent, Forms,
  Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, Menus, ComCtrls, ShellCtrls,
  uPSRuntime;

type

  { TForm1 }

  TForm1 = class(TForm)
    ListBox1: TListBox;
    MainMenu1: TMainMenu;
    Memo2: TMemo;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
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
    Panel2: TPanel;
    Panel3: TPanel;
    PopupMenuSynEdit1: TPopupMenu;
    PopupMenuShellView: TPopupMenu;
    PSScript1: TPSScript;
    SaveDialog1: TSaveDialog;
    ShellTreeView1: TShellTreeView;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    SynEdit1: TSynEdit;
    SynPasSyn1: TSynPasSyn;
    TrayIcon1: TTrayIcon;
    procedure ButtonRunClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItemClearCacheClick(Sender: TObject);
    procedure MenuItemCopyClipClick(Sender: TObject);
    procedure MenuItemCreateDirClick(Sender: TObject);
    procedure MenuItemCutClipClick(Sender: TObject);
    procedure MenuItemDeleteClick(Sender: TObject);
    procedure MenuItemDeleteDirOrFileClick(Sender: TObject);
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
implementation

{$R *.lfm}

{ TForm1 }


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
end;

procedure TForm1.MenuItem10Click(Sender: TObject);
begin
  if (ShellTreeView1.Path = '')
  or not FileExists(ShellTreeView1.Path) then Exit;
  MenuItemClearCacheClick(nil);
  ProcessScript.RunScriptThread(ShellTreeView1.Path);
end;

procedure TForm1.MenuItemClearCacheClick(Sender: TObject);
var i: Integer;
begin
  for i := 0 to Length(Cache) - 1 do
  begin
    Cache[i].Data.Free;
    Memo2.Lines.Add('[Cache cleared] ' + Cache[i].Name.Replace(dataPath, ''));
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

  if FileExists(ShellTreeView1.Path) then
  begin
    cdir := ExtractFileDir(ShellTreeView1.Path)+'\';
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
    DeleteFile(ShellTreeView1.Path);
  end;
  if DirectoryExists(ShellTreeView1.Path)
  and not (ShellTreeView1.Path = dataPath) then
  begin
    DeleteDirectory(ShellTreeView1.Path, false);
  end;

  ShellTreeView1.Root := currentPath;
  ShellTreeView1.Root := dataPath;
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
      ShowMessage('Rename is disabled on root directory');
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
  Memo2.Lines.Add('[File saved] ' + ShellTreeView1.Path.Replace(dataPath, ''));
  for i := 0 to Length(Cache) - 1 do
  begin
    if Cache[i].Name = ShellTreeView1.Path then
    begin
      Cache[i].Data.Free;
      Cache[i].Data := TStringList.Create;
      Cache[i].Data.LoadFromFile(ShellTreeView1.Path);
      Memo2.Lines.Add('[Cache cleared] ' + ShellTreeView1.Path.Replace(dataPath, ''));
    end;
  end;
end;

procedure TForm1.MenuItemStopClick(Sender: TObject);
var
  i: integer;
begin
  if Length(ProcessScripts) = 0 then
  begin                    
      Memo2.Lines.Add('[Stop] No process to stop');
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
      Memo2.Lines.Add('[Stop] '+ProcessScripts[i].Name.Replace(dataPath, ''));
      ProcessScripts[i].Data.Free;
      ProcessScripts[i].enabled := False;
    end;
  end;
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
      Memo2.Lines.Add('[Cache loaded] '+f.Replace(dataPath, ''))
    else
      Memo2.Lines.Add('[File loaded] '+f.Replace(dataPath, ''));

    Script.Script.Insert(0, 'program script;' + #13#10);
    Script.Script.Add(#13#10 + 'end.');
    Compiled := Script.Compile();
    for i := 0 to Script.CompilerMessageCount - 1 do
      Memo2.Lines.add(Script.CompilerMessages[i].MessageToString);
    if not Compiled then
      if Script.CompilerMessageCount > 0 then
        for i := 0 to Script.CompilerMessageCount - 1 do
          Memo2.Lines.add(Script.CompilerErrorToStr(i));

    Memo2.Lines.add('[Start run] '+f.Replace(dataPath, ''));
    Script.Exec.RunScript;
    Memo2.Lines.add('[End run] '+f.Replace(dataPath, ''));

    if ProcessScripts[index].enabled then
    begin
      Script.Free;
      ProcessScripts[index].enabled:= False;

      isEmpty := True;
      for i := 0 to Length(ProcessScripts) - 1 do
      begin
        if ProcessScripts[i].enabled then isEmpty := False;
      end;
      if isEmpty then
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
    Memo2.Lines.Add('[Run] No file selected');
    Exit;
  end;
  MenuItemSaveClick(nil);
  ProcessScript.RunScriptThread(ShellTreeView1.Path);
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


procedure TForm1.PSScript1Compile(Sender: TPSScript);
begin
  Sender.AddFunction(@SetNextScript, 'procedure SetNextScript(const s: string)');
  Sender.AddFunction(@Log, 'procedure Log(const s: string)');
  Sender.AddFunction(@RunScript, 'procedure RunScript(const f: String)');
  Sender.AddFunction(@RunScriptAndContinue,'procedure RunScriptAndContinue(const f: String)');
  Sender.AddFunction(@Sleep, 'procedure Sleep(i: Integer)');
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
end;


end.
