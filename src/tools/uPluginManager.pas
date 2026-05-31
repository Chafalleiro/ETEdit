unit uPluginManager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dynlibs, LCLIntf, LCLType, Forms, Controls, ExtCtrls, Menus,
  uPluginHostForm, gd_dockingbase, uDebugLog;

type
  // Tipos de funciones exportadas por los plugins
  TGetPluginName = function: pchar; stdcall;
  TGetFileExtensions = function: pchar; stdcall;
  TLoadPlugin = procedure(ParentWindow, ParentControl: HWND); stdcall;
  TUnloadPlugin = procedure; stdcall;
  TPluginPosition = procedure(X, Y, W, H: integer); stdcall;
  TOpenFile = procedure(FileName: pchar); stdcall;
  TProcessFile = function(FileName: pchar): integer; stdcall;

  TPluginKind = (pkNone, pkVisual, pkNonVisual);

  TPluginInfo = record
    Name: string;
    FileName: string;
    Handle: TLibHandle;
    Kind: TPluginKind;
    Extensions: TStringList;
    // Funciones comunes
    GetPluginName: TGetPluginName;
    GetFileExtensions: TGetFileExtensions;
    // Visuales
    LoadPlugin: TLoadPlugin;
    UnloadPlugin: TUnloadPlugin;
    PluginPosition: TPluginPosition;
    OpenFile: TOpenFile;
    // No visuales
    ProcessFile: TProcessFile;
    // Panel contenedor (solo para visuales)
    Container: TWinControl;
    Loaded: boolean;  // <-- Nuevo campo
  end;
  PPluginInfo = ^TPluginInfo;

  TPluginManager = class
  private
    FPlugins: TList;
    FPluginDir: string;
    FDockMaster: TGlassDockMaster;   // <-- Nuevo campo

    procedure LoadPluginFromFile(const FileName: string);
    function GetPluginInfo(Index: integer): PPluginInfo;
    function GetCount: integer;
  public
    constructor Create(const PluginDir: string; ADockMaster: TGlassDockMaster);
    destructor Destroy; override;
    procedure LoadAllPlugins;
    function FindPluginForExt(const Ext: string): PPluginInfo;
    function ShowVisualPlugin(Info: PPluginInfo; const FileName: string): boolean;
    function ProcessFileWithPlugin(Info: PPluginInfo; const FileName: string): boolean;
    procedure UnloadAllPlugins;
    procedure HostFormResize(Sender: TObject);
    function GetPluginsForExt(const Ext: string): TList; // Devuelve lista de PPluginInfo
    procedure OpenFileWithPlugin(Info: PPluginInfo; const FileName: string);

    property Count: integer read GetCount;
    property Plugins[Index: integer]: PPluginInfo read GetPluginInfo;
  end;

implementation

constructor TPluginManager.Create(const PluginDir: string; ADockMaster: TGlassDockMaster);
begin
  FPlugins := TList.Create;
  FPluginDir := PluginDir;
  FDockMaster := ADockMaster;   // <-- Guardar referencia
end;

destructor TPluginManager.Destroy;
begin
  TDebugLogger.DebugFmt('TPluginManager.Destroy plugins: %d', [FPlugins.Count], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  UnloadAllPlugins;
  FPlugins.Free;
  inherited Destroy;
end;

procedure TPluginManager.UnloadAllPlugins;
var
  i: integer;
  Info: PPluginInfo;
begin
  TDebugLogger.DebugFmt('UnloadAllPlugins: %d', [FPlugins.Count], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  for i := 0 to FPlugins.Count - 1 do
  begin
    Info := PPluginInfo(FPlugins[i]);
    if Info^.Kind = pkVisual then
    begin
      TDebugLogger.DebugFmt('Unloading visual plugin: %s', [Info^.Name], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      if Assigned(Info^.UnloadPlugin) then
      begin
        TDebugLogger.DebugFmt('Unloading plugin: %s', [Info^.Name], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        Info^.UnloadPlugin;
      end;
      if Assigned(Info^.Container) then
      begin
        TDebugLogger.DebugFmt('Unloading container: %s', [Info^.Name], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        Info^.Container.Free;
      end;
    end
    else if Info^.Kind = pkNonVisual then
    begin
      if Assigned(Info^.UnloadPlugin) then
        Info^.UnloadPlugin;
    end;
    if Info^.Handle <> NilHandle then
      FreeLibrary(Info^.Handle);
    Info^.Extensions.Free;
    Dispose(Info);
  end;
  FPlugins.Clear;
end;

procedure TPluginManager.LoadPluginFromFile(const FileName: string);
var
  LibHandle: TLibHandle;
  Info: PPluginInfo;
  GetNameFunc: TGetPluginName;
  GetExtFunc: TGetFileExtensions;
  ExtStr: string;
begin
  LibHandle := LoadLibrary(FileName);
  if LibHandle = NilHandle then
  begin
    TDebugLogger.Error('Failed to load library: ' + FileName);
    Exit;
  end;

  New(Info);
  FillChar(Info^, SizeOf(TPluginInfo), 0);
  Info^.Handle := LibHandle;
  Info^.FileName := FileName;

  // Obtener funciones comunes
  GetNameFunc := TGetPluginName(GetProcAddress(LibHandle, 'GetPluginName'));
  GetExtFunc := TGetFileExtensions(GetProcAddress(LibHandle, 'GetFileExtensions'));

  if (GetNameFunc = nil) or (GetExtFunc = nil) then
  begin
    TDebugLogger.Error('Plugin missing GetPluginName or GetFileExtensions: ' + FileName);
    FreeLibrary(LibHandle);
    Dispose(Info);
    Exit;
  end;

  Info^.Name := string(GetNameFunc());
  ExtStr := string(GetExtFunc());
  Info^.Extensions := TStringList.Create;
  Info^.Extensions.CommaText := ExtStr;

  // Detectar si es visual: buscar LoadPlugin
  Info^.LoadPlugin := TLoadPlugin(GetProcAddress(LibHandle, 'LoadPlugin'));
  if Assigned(Info^.LoadPlugin) then
  begin
    // Es visual: también necesita UnloadPlugin, PluginPosition, OpenFile
    Info^.UnloadPlugin := TUnloadPlugin(GetProcAddress(LibHandle, 'UnloadPlugin'));
    Info^.PluginPosition := TPluginPosition(GetProcAddress(LibHandle, 'PluginPosition'));
    Info^.OpenFile := TOpenFile(GetProcAddress(LibHandle, 'OpenFile'));
    if Assigned(Info^.UnloadPlugin) and Assigned(Info^.PluginPosition) and Assigned(Info^.OpenFile) then
    begin
      Info^.Kind := pkVisual;
      FPlugins.Add(Info);
      TDebugLogger.InfoFmt('Loaded visual plugin: %s (%s)', [Info^.Name, ExtStr], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      Exit;
    end
    else
      TDebugLogger.Error('Visual plugin missing required functions: ' + FileName, {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  end
  else
  begin
    // No visual: buscar ProcessFile
    Info^.ProcessFile := TProcessFile(GetProcAddress(LibHandle, 'ProcessFile'));
    if Assigned(Info^.ProcessFile) then
    begin
      Info^.Kind := pkNonVisual;
      FPlugins.Add(Info);
      TDebugLogger.Info(Format('Loaded non-visual plugin: %s (%s)', [Info^.Name, ExtStr]));
      Exit;
    end;
  end;

  // Si llegamos aquí, no cumple con ningún tipo
  FreeLibrary(LibHandle);
  Info^.Extensions.Free;
  Dispose(Info);
end;

procedure TPluginManager.LoadAllPlugins;
var
  SR: TSearchRec;
  PluginPath: string;
begin
  if not DirectoryExists(FPluginDir) then
  begin
    CreateDir(FPluginDir);
    Exit;
  end;

  if FindFirst(FPluginDir + '*.dll', faAnyFile, SR) = 0 then
  begin
    repeat
      PluginPath := FPluginDir + SR.Name;
      LoadPluginFromFile(PluginPath);
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
end;

function TPluginManager.FindPluginForExt(const Ext: string): PPluginInfo;
var
  i: integer;
  Info: PPluginInfo;
begin
  Result := nil;
  for i := 0 to FPlugins.Count - 1 do
  begin
    Info := PPluginInfo(FPlugins[i]);
    if Info^.Extensions.IndexOf(Ext) >= 0 then
      Exit(Info);
  end;
end;

function TPluginManager.GetPluginsForExt(const Ext: string): TList; // Devuelve lista de PPluginInfo
var
  i: Integer;
  Info: PPluginInfo;
begin
  Result := TList.Create;
  for i := 0 to FPlugins.Count - 1 do
  begin
    Info := PPluginInfo(FPlugins[i]);
    if Info^.Extensions.IndexOf(Ext) >= 0 then
      Result.Add(Info);
  end;
end;

procedure TPluginManager.OpenFileWithPlugin(Info: PPluginInfo; const FileName: string);
begin
  TDebugLogger.Info('OpenFileWithPlugin: Entering', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  if Info = nil then Exit;
  if Info^.Kind = pkVisual then
    ShowVisualPlugin(Info, FileName)
  else if Assigned(Info^.ProcessFile) then
    Info^.ProcessFile(PChar(FileName));
end;

function TPluginManager.ShowVisualPlugin(Info: PPluginInfo; const FileName: string): boolean;
var
  HostForm: TPluginHostForm;
  SafeName: string;
  i: integer;
begin
  Result := False;
  TDebugLogger.Info('ShowVisualPlugin: Entering', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  if (Info = nil) then
  begin
    TDebugLogger.Error('ShowVisualPlugin: Info is nil', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    Exit;
  end;
  if Info^.Kind <> pkVisual then
  begin
    TDebugLogger.Error('ShowVisualPlugin: Plugin is not visual', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    Exit;
  end;
  TDebugLogger.DebugFmt('ShowVisualPlugin: Plugin name = %s', [Info^.Name], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  // Sanear nombre
  SafeName := Info^.Name;
  for i := 1 to Length(SafeName) do
    if not (SafeName[i] in ['A'..'Z', 'a'..'z', '0'..'9', '_']) then
      SafeName[i] := '_';
  if (SafeName <> '') and not (SafeName[1] in ['A'..'Z', 'a'..'z']) then
    SafeName := 'Plugin_' + SafeName;
  SafeName := SafeName + 'Host';
  TDebugLogger.DebugFmt('ShowVisualPlugin: SafeName = %s', [SafeName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  // Buscar o crear el formulario
  HostForm := TPluginHostForm(Screen.FindForm(SafeName));
  if HostForm = nil then
  begin
    HostForm := CreatePluginHostForm(SafeName, Info^.Name, True);
    if HostForm = nil then
    begin
      TDebugLogger.Error('ShowVisualPlugin: Failed to create host form', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      Exit;
    end;
    // Registrar como acoplable y mostrar
    FDockMaster.MakeDockable(HostForm);
    Application.ProcessMessages;
    TDebugLogger.DebugFmt('ShowVisualPlugin: Created %s dockable form', [HostForm.Name], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  end;

  TDebugLogger.Debug('ShowVisualPlugin: Host form exists', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  // Asegurar que esté visible y al frente
//  HostForm.HandleNeeded;
  TDebugLogger.Debug('ShowVisualPlugin: Host Handle Needed', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  Application.ProcessMessages;
  TDebugLogger.Debug('ShowVisualPlugin: Form brought to front', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  // Verificar Memo1
  if HostForm.Memo1 = nil then
  begin
    TDebugLogger.Error('ShowVisualPlugin: Memo1 is nil after creation', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    Exit;
  end;
  HostForm.Memo1.Lines.Text := 'Plugin container ready. Plugin not loaded yet.';
  TDebugLogger.Debug('ShowVisualPlugin: Memo1 text set', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  Info^.Container := HostForm.ClientPanel;
  // Asociar el plugin info con el HostForm (para poder acceder a PluginPosition)
  HostForm.Tag := PtrInt(Info);
  // Conectar evento de redimensionado
  HostForm.OnResize := @HostFormResize;
  // Una vez que el HostForm está listo, incrustamos el plugin real
  if Assigned(Info^.LoadPlugin) then
  begin
    if Info^.Loaded then
      TDebugLogger.Info('Plugin already loaded...', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%})
    else
    begin
      // Asegurar que ClientPanel tenga handle
      if not HostForm.ClientPanel.HandleAllocated then
        HostForm.ClientPanel.HandleNeeded;
      TDebugLogger.Debug('Calling LoadPlugin...', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      Info^.LoadPlugin(HostForm.ClientPanel.Handle, HostForm.ClientPanel.Handle);
      Info^.Loaded := True;
      TDebugLogger.Debug('LoadPlugin returned', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    end;
  end
  else
    TDebugLogger.Error('LoadPlugin is nil', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  if Assigned(Info^.OpenFile) then
  begin
    TDebugLogger.InfoFmt('Calling OpenFile with %s', [FileName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    Info^.OpenFile(PChar(FileName));
    TDebugLogger.InfoFmt('Called OpenFile with %s', [FileName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  end;
  FDockMaster.ShowControl(HostForm.Name, True);
  HostForm.Show;

  HostFormResize(HostForm);
  TDebugLogger.Debug('ShowVisualPlugin: Exiting successfully', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  Result := True;
end;

function TPluginManager.ProcessFileWithPlugin(Info: PPluginInfo; const FileName: string): boolean;
begin
  Result := False;
  if (Info = nil) or (Info^.Kind <> pkNonVisual) or not Assigned(Info^.ProcessFile) then Exit;
  Result := Info^.ProcessFile(PChar(FileName)) = 0;
end;

function TPluginManager.GetPluginInfo(Index: integer): PPluginInfo;
begin
  if (Index >= 0) and (Index < FPlugins.Count) then
    Result := PPluginInfo(FPlugins[Index])
  else
    Result := nil;
end;

function TPluginManager.GetCount: integer;
begin
  Result := FPlugins.Count;
end;

procedure TPluginManager.HostFormResize(Sender: TObject);
var
  HostForm: TPluginHostForm;
  Info: PPluginInfo;
  R: TRect;
begin
  TDebugLogger.Debug('HostFormResize', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  HostForm := Sender as TPluginHostForm;
  if HostForm = nil then Exit;
  Info := PPluginInfo(HostForm.Tag);
  if (Info = nil) or not Assigned(Info^.PluginPosition) then Exit;
  R := HostForm.ClientPanel.BoundsRect; // o HostForm.ClientRect
  Info^.PluginPosition(R.Left, R.Top, R.Width, R.Height);
end;

end.
