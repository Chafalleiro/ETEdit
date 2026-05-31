unit uConfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, jsonscanner, FileUtil, LazFileUtils,
  uDebugLog;

type
  TConfigManager = class
  private
    FConfigFile: String;
    FJSONConfig: TJSONObject;

    FRecentProjects: TStringList;
    FRecentFiles: TStringList;

    procedure LoadDefaultConfig;
    function GetConfigPath: String;

    procedure LoadRecentLists;
    procedure SaveRecentLists;
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadConfig;
    procedure SaveConfig;

    // Editor settings
    function GetEditorFontName: String;
    function GetEditorFontSize: Integer;
    function GetProjectLastPath: String;

    procedure SetEditorFontName(const Value: String);
    procedure SetEditorFontSize(Value: Integer);
    procedure SetProjectLastPath(const Value: String);

    // New: Auto-reload settings
    function GetAutoReloadFiles: Boolean;
    procedure SetAutoReloadFiles(Value: Boolean);

    // Debuf Settings
    function GetDebugLevel: Integer;   // 0=debug, 1=Info, 2=Warning, 3=Error, 4=off
    procedure SetDebugLevel(Value: Integer);
    function GetLogFileName: string;
    procedure SetLogFileName(const Value: string);

    // REcent files
    procedure AddRecentProject(const Path: string);
    procedure AddRecentFile(const Path: string);
    function GetRecentProjects: TStrings;
    function GetRecentFiles: TStrings;
    procedure ClearRecentProjects;
    procedure ClearRecentFiles;
  end;

var
  ConfigManager: TConfigManager;

implementation

// Helper functions
function GetJSONString(Obj: TJSONObject; const Key: String; Default: String = ''): String;
var
  Data: TJSONData;
begin
  Data := Obj.Find(Key);
  if (Data <> nil) and (Data.JSONType = jtString) then
    Result := Data.AsString
  else
    Result := Default;
end;

function GetJSONInteger(Obj: TJSONObject; const Key: String; Default: Integer = 0): Integer;
var
  Data: TJSONData;
begin
  Data := Obj.Find(Key);
  if (Data <> nil) and (Data.JSONType = jtNumber) then
    Result := Data.AsInteger
  else
    Result := Default;
end;

// New helper for boolean values
function GetJSONBoolean(Obj: TJSONObject; const Key: String; Default: Boolean = False): Boolean;
var
  Data: TJSONData;
begin
  Data := Obj.Find(Key);
  if (Data <> nil) and (Data.JSONType = jtBoolean) then
    Result := Data.AsBoolean
  else
    Result := Default;
end;

constructor TConfigManager.Create;
begin
  FConfigFile := GetConfigPath + 'etedit_config.json';
  FJSONConfig := TJSONObject.Create;
  FRecentProjects := TStringList.Create;
  FRecentFiles := TStringList.Create;
  LoadConfig; // ya existente
  LoadRecentLists; // nuevo
end;

destructor TConfigManager.Destroy;
begin
  SaveRecentLists; // guardar antes de liberar
  FRecentProjects.Free;
  FRecentFiles.Free;

  SaveConfig;
  FJSONConfig.Free;
  inherited Destroy;
end;

function TConfigManager.GetConfigPath: String;
begin
  Result := AppendPathDelim(GetAppConfigDir(False));
  ForceDirectories(Result);
end;

procedure TConfigManager.LoadDefaultConfig;
begin
  FJSONConfig.Clear;

  FJSONConfig.Add('editorFontName', TJSONString.Create('IBM Plex Mono Text'));
  FJSONConfig.Add('editorFontSize', TJSONIntegerNumber.Create(12));
  FJSONConfig.Add('projectLastPath', TJSONString.Create(GetUserDir));
  FJSONConfig.Add('windowWidth', TJSONIntegerNumber.Create(1024));
  FJSONConfig.Add('windowHeight', TJSONIntegerNumber.Create(768));
  FJSONConfig.Add('autoReloadFiles', TJSONBoolean.Create(True)); // Default: auto-reload on
  FJSONConfig.Add('debugLevel', TJSONIntegerNumber.Create(4)); // Default: dllDebug
  FJSONConfig.Add('logFileName', TJSONString.Create('ETDebug.log'));
  FJSONConfig.Add('recentProjects', TJSONArray.Create);
  FJSONConfig.Add('recentFiles', TJSONArray.Create);
end;

procedure TConfigManager.LoadConfig;
var
  FileStream: TFileStream;
  Parser: TJSONParser;
begin
  if FileExists(FConfigFile) then
  begin
    try
      FileStream := TFileStream.Create(FConfigFile, fmOpenRead);
      try
        Parser := TJSONParser.Create(FileStream, [joUTF8]);
        try
          FJSONConfig.Free;
          FJSONConfig := Parser.Parse as TJSONObject;
        finally
          Parser.Free;
        end;
      finally
        FileStream.Free;
      end;
    except
      LoadDefaultConfig;
    end;
  end
  else
    LoadDefaultConfig;
end;

procedure TConfigManager.SaveConfig;
var
  FileStream: TFileStream;
  ConfigText: String;
begin
  try
    ConfigText := FJSONConfig.FormatJSON([foUseTabchar], 2);
    FileStream := TFileStream.Create(FConfigFile, fmCreate);
    try
      if ConfigText <> '' then
        FileStream.WriteBuffer(ConfigText[1], Length(ConfigText));
    finally
      FileStream.Free;
    end;
  except
    on E: Exception do
      TDebugLogger.DebugFmt('Error saving config: %s', [E.Message], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  end;
end;

//Fonts
function TConfigManager.GetEditorFontName: String;
begin
  Result := GetJSONString(FJSONConfig, 'editorFontName', 'IBM Plex Mono Text');
end;

function TConfigManager.GetEditorFontSize: Integer;
begin
  Result := GetJSONInteger(FJSONConfig, 'editorFontSize', 12);
end;

procedure TConfigManager.SetEditorFontName(const Value: String);
begin
  FJSONConfig.Delete('editorFontName');
  FJSONConfig.Add('editorFontName', TJSONString.Create(Value));
end;

procedure TConfigManager.SetEditorFontSize(Value: Integer);
begin
  FJSONConfig.Delete('editorFontSize');
  FJSONConfig.Add('editorFontSize', TJSONIntegerNumber.Create(Value));
end;

//Path
function TConfigManager.GetProjectLastPath: String;
begin
  Result := GetJSONString(FJSONConfig, 'projectLastPath', GetUserDir);
end;

procedure TConfigManager.SetProjectLastPath(const Value: String);
begin
  FJSONConfig.Delete('projectLastPath');
  FJSONConfig.Add('projectLastPath', TJSONString.Create(Value));
end;

//Autoreload
function TConfigManager.GetAutoReloadFiles: Boolean;
begin
  Result := GetJSONBoolean(FJSONConfig, 'autoReloadFiles', True);
end;

procedure TConfigManager.SetAutoReloadFiles(Value: Boolean);
begin
  FJSONConfig.Delete('autoReloadFiles');
  FJSONConfig.Add('autoReloadFiles', TJSONBoolean.Create(Value));
end;

//Debug
function TConfigManager.GetDebugLevel: Integer;
begin
  Result := GetJSONInteger(FJSONConfig, 'debugLevel', 4); // por defecto Debug
end;

procedure TConfigManager.SetDebugLevel(Value: Integer);
begin
  FJSONConfig.Delete('debugLevel');
  FJSONConfig.Add('debugLevel', TJSONIntegerNumber.Create(Value));
end;

function TConfigManager.GetLogFileName: string;
begin
  Result := GetJSONString(FJSONConfig, 'logFileName', 'ETdebug.log');
end;

procedure TConfigManager.SetLogFileName(const Value: string);
begin
  FJSONConfig.Delete('logFileName');
  FJSONConfig.Add('logFileName', TJSONString.Create(Value));
end;

// Cargar recientes
procedure TConfigManager.LoadRecentLists;
var
  arr: TJSONArray;
  i: Integer;
begin
  FRecentProjects.Clear;
  arr := FJSONConfig.Arrays['recentProjects'];
  if arr <> nil then
    for i := 0 to arr.Count - 1 do
      FRecentProjects.Add(arr[i].AsString);

  FRecentFiles.Clear;
  arr := FJSONConfig.Arrays['recentFiles'];
  if arr <> nil then
    for i := 0 to arr.Count - 1 do
      FRecentFiles.Add(arr[i].AsString);
end;

// Guardar recientes
procedure TConfigManager.SaveRecentLists;
var
  arr: TJSONArray;
  i: Integer;
begin
  // Eliminar miembros existentes para evitar duplicados
  if FJSONConfig.Find('recentProjects') <> nil then
    FJSONConfig.Delete('recentProjects');
  if FJSONConfig.Find('recentFiles') <> nil then
    FJSONConfig.Delete('recentFiles');

  // Guardar proyectos recientes
  arr := TJSONArray.Create;
  for i := 0 to FRecentProjects.Count - 1 do
    arr.Add(FRecentProjects[i]);
  FJSONConfig.Add('recentProjects', arr);

  // Guardar archivos recientes
  arr := TJSONArray.Create;
  for i := 0 to FRecentFiles.Count - 1 do
    arr.Add(FRecentFiles[i]);
  FJSONConfig.Add('recentFiles', arr);
   SaveConfig;
end;

procedure TConfigManager.AddRecentProject(const Path: string);
var
  idx: Integer;
begin
  idx := FRecentProjects.IndexOf(Path);
  if idx >= 0 then
    FRecentProjects.Delete(idx);
  FRecentProjects.Insert(0, Path);
  while FRecentProjects.Count > 10 do
    FRecentProjects.Delete(10);
  SaveRecentLists;
end;

procedure TConfigManager.AddRecentFile(const Path: string);
var
  idx: Integer;
begin
  idx := FRecentFiles.IndexOf(Path);
  if idx >= 0 then
    FRecentFiles.Delete(idx);
  FRecentFiles.Insert(0, Path);
  while FRecentFiles.Count > 10 do
    FRecentFiles.Delete(10);
  SaveRecentLists;
end;

function TConfigManager.GetRecentProjects: TStrings;
begin
  Result := FRecentProjects;
end;

function TConfigManager.GetRecentFiles: TStrings;
begin
  Result := FRecentFiles;
end;

procedure TConfigManager.ClearRecentProjects;
begin
  FRecentProjects.Clear;
  SaveRecentLists;
end;

procedure TConfigManager.ClearRecentFiles;
begin
  FRecentFiles.Clear;
  SaveRecentLists;
end;

initialization
  ConfigManager := TConfigManager.Create;

finalization
  ConfigManager.Free;

end.
