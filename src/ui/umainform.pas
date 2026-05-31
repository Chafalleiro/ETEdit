unit uMainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ActnList, Menus,
  ExtCtrls, LCLType, ImgList, gd_dockingbase, gd_dockingStorage, gd_dockingOptionsDlg,
  Synedit, XMLPropStorage, uConfig, cyPageControl, cyTabControl,
  uResOperations, uDebug, uEditorTabs, uProject, uDebugLog, uPluginManager,
  uPluginHostForm, uEditorForm, uThemeManager,
  frmProjectTree, frmProjectSettings, frmSettings, frmJSAnalyzer, frmThemeTester;

type
  { TMainForm }
  TMainForm = class(TForm)
    actDockigOptions: TAction;
    actSettings: TAction;
    actThemeTester: TAction;
    actNextTheme: TAction;
    actViewEditor: TAction;
    actViewProject: TAction;
    actTJSAnalyzer: TAction;
    // Actions
    ActionList1: TActionList;
    actNewProject: TAction;
    actOpenProject: TAction;
    actCloseProject: TAction;
    actSave: TAction;
    actSaveAs: TAction;
    actSaveAll: TAction;
    actExit: TAction;
    actProjectSettings: TAction;
    actCompileProject: TAction;
    actOpenFile: TAction;
    actNewFile: TAction;
    actNewFolder: TAction;
    actNewTab: TAction;
    actCloseTab: TAction;
    actCloseAllTabs: TAction;
    actUndo: TAction;
    actRedo: TAction;
    actCut: TAction;
    actCopy: TAction;
    actPaste: TAction;
    actRefreshProject: TAction;
    actSaveProject: TAction;
    actPreview: TAction;
    actIPFSUpload: TAction;
    actSaveLayout: TAction;
    actSaveLayoutAs: TAction;
    actOpenLayout: TAction;
    AnchorDockPanel2: TGlassDockPanel;

    // Main Menu
    MainMenu: TMainMenu;
    mnuDocking: TMenuItem;
    mnuPlugins: TMenuItem;
    mnuSettings: TMenuItem;
    mnuThemeTester: TMenuItem;
    mnuNextTheme: TMenuItem;
    mnuTheme: TMenuItem;
    mnuThemeLight: TMenuItem;
    mnuThemeDark: TMenuItem;
    mnuThemeBlue: TMenuItem;
    mnuViewEditor: TMenuItem;
    mnuJsAnalyzer: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem3: TMenuItem;

    // File Menu
    mnuFile: TMenuItem;
    mnuNewProject: TMenuItem;
    mnuOpenProject: TMenuItem;
    mnuCloseProject: TMenuItem;
    mnuProjectExit: TMenuItem;
    mnuProjectTree: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    Project: TMenuItem;
    Separator1: TMenuItem;
    mnuOpenFile: TMenuItem;
    mnuSave: TMenuItem;
    mnuSaveAs: TMenuItem;
    mnuSaveAll: TMenuItem;
    Separator2: TMenuItem;
    mnuSaveProject: TMenuItem;
    Separator3: TMenuItem;
    mnuSaveLayout: TMenuItem;
    mnuSaveLayoutAs: TMenuItem;
    mnuOpenLayout: TMenuItem;
    Separator4: TMenuItem;
    mnuExit: TMenuItem;

    // Edit Menu
    mnuEdit: TMenuItem;
    mnuUndo: TMenuItem;
    mnuRedo: TMenuItem;
    Separator5: TMenuItem;
    mnuCut: TMenuItem;
    mnuCopy: TMenuItem;
    mnuPaste: TMenuItem;

    // View Menu
    mnuView: TMenuItem;
    mnuViewProjectTree: TMenuItem;
    mnuViewProjectSettings: TMenuItem;
    mnuViewJSAnalyzer: TMenuItem;
    mnuViewCSSAnalyzer: TMenuItem;
    mnuViewHTMLAnalyzer: TMenuItem;
    mnuViewDataViewer: TMenuItem;
    mnuViewVariables: TMenuItem;

    // Project Menu
    mnuProject: TMenuItem;
    mnuProjectSettings: TMenuItem;
    mnuCompileProject: TMenuItem;
    mnuPreview: TMenuItem;
    mnuIPFSUpload: TMenuItem;

    // Tools Menu
    mnuTools: TMenuItem;
    mnuCSSProps: TMenuItem;

    // Help Menu
    mnuHelp: TMenuItem;
    mnuAbout: TMenuItem;

    Separator6: TMenuItem;
    Separator7: TMenuItem;

    // Toolbar
    ToolBar1: TToolBar;
    btnNewProject: TToolButton;
    btnOpenProject: TToolButton;
    Sep1: TToolButton;
    ToolButton1: TToolButton;
    ToolButton10: TToolButton;
    ToolButton12: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    ToolButton8: TToolButton;
    tooOpenFile: TToolButton;
    tooSaveFile: TToolButton;
    tooSaveFileAs: TToolButton;
    tooSaveFileAll: TToolButton;
    tooCloseAllTabs: TToolButton;
    Sep2: TToolButton;
    tooSaveProject: TToolButton;
    tooCloseProject: TToolButton;
    tooProjectSettings: TToolButton;
    tooCompileProject: TToolButton;


    // Docking
    AnchorDockPanel1: TGlassDockPanel;

    // Status Bar
    StatusBar1: TStatusBar;


    // Timer
    StatusTimer: TTimer;

    // Popup Menus
    tabPopupMenu1: TPopupMenu;
    popCloseTab: TMenuItem;

    // Image List
    ImageList1: TImageList;

    procedure actCloseAllTabsExecute(Sender: TObject);
    procedure actCloseTabExecute(Sender: TObject);
    procedure actDockigOptionsExecute(Sender: TObject);
    procedure actNextThemeExecute(Sender: TObject);
    procedure actRefreshProjectExecute(Sender: TObject);
    procedure actSettingsExecute(Sender: TObject);
    procedure actThemeTesterExecute(Sender: TObject);
    procedure actTJSAnalyzerExecute(Sender: TObject);
    procedure actSaveLayoutAsExecute(Sender: TObject);
    procedure actSaveLayoutExecute(Sender: TObject);
    procedure actViewEditorExecute(Sender: TObject);
    procedure actViewProjectExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    // File actions
    procedure actNewProjectExecute(Sender: TObject);
    procedure actOpenProjectExecute(Sender: TObject);
    procedure actCloseProjectExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actSaveAsExecute(Sender: TObject);
    procedure actSaveAllExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actOpenFileExecute(Sender: TObject);

    // Project actions
    procedure actProjectSettingsExecute(Sender: TObject);
    procedure actCompileProjectExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure mnuSettingsClick(Sender: TObject);
    procedure mnuThemeBlueClick(Sender: TObject);
    procedure mnuThemeDarkClick(Sender: TObject);
    procedure mnuThemeLightClick(Sender: TObject);


    // View menu
    procedure mnuViewProjectTreeClick(Sender: TObject);
    procedure mnuViewProjectSettingsClick(Sender: TObject);
    procedure refreshProjectTree;

    // Editor events
    procedure EditorTabsActiveEditorChanged(Sender: TObject; Editor: TSynEdit);
    procedure StatusBar1Resize(Sender: TObject);
    procedure StatusTimerTimer(Sender: TObject);

    procedure ApplyCurrentThemeToAllForms;
    procedure ThemeChangedHandler(Sender: TObject);

    procedure PopulatePluginMenu(Popup: TPopupMenu; const FileName: string);
    procedure OpenWithPluginClick(Sender: TObject);

  private
    FPluginManager: TPluginManager;
    FCheckTimer: TTimer;   // <-- Añade esto
    FProject: TETEditProject;
    FEditorForm: TEditorForm;  // Replace FEditorTabs with FEditorForm
    JSAnalyzerForm: TJSAnalyzerForm;

    FProjectName: string;
    FProjectPath: string;

    procedure InitializeDocking;
    procedure DockMasterCreateControl(Sender: TObject; aName: string; var AControl: TControl; DoDisableAutoSizing: boolean);

    procedure SaveLayout(const Filename: string);
    procedure LoadLayout(const Filename: string);

    // Form getters
    function GetProjectTreeForm: TProjectTreeForm;
    function GetProjectSettingsForm: TProjectSettingsForm;
    function GetJSAnalyzerForm: TJSAnalyzerForm;
    function GetEditorForm: TEditorForm;  // Add this

    // UI Updates
    procedure UpdateProjectUI;
    procedure UpdateStatusBar;

    // File operations
    procedure OpenFileFromProjectTree(Sender: TObject);
    procedure CheckExternalChanges(Sender: TObject);
  public
    { Public declarations }
    property EditorForm: TEditorForm read GetEditorForm;

    procedure FileCheckTimerTimer(Sender: TObject);
    procedure ReloadTab(Tab: TEditorTab);

    function GetPluginsForFile(const FileName: string): TList;
    procedure OpenFileWithPlugin(PluginInfo: PPluginInfo; const FileName: string);

  end;

var
  MainForm: TMainForm;

implementation

{$R *.frm}

{ TMainForm }
uses
  LCLProc, FileUtil;

// Replace the entire CreateDockableForm function with this:
function CreateDockableForm(FormClass: TFormClass; FormName, FormTitle: string; DoDisableAutoSizing: boolean): TForm;
var
  NewBounds: TRect;
begin
  // First check if the form already exists
  TDebugLogger.InfoFmt('  CreateDockableForm called for: %s', [FormName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  Result := TForm(Screen.FindForm(FormName));
  if (Result <> nil) and (Result is FormClass) then
  begin
    if DoDisableAutoSizing then
      Result.DisableAutoSizing;
    Exit;
  end;

  // Set default bounds
  NewBounds := Rect(200, 200, 500, 400);

  // Create the form
  Result := FormClass.CreateNew(Application);

  Result.DisableAutoSizing;
  Result.Caption := FormTitle;
  Result.Name := FormName;
  Result.BoundsRect := NewBounds;

  if not DoDisableAutoSizing then
    Result.EnableAutoSizing;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  Li: Tmenuitem;
  Info: PPluginInfo;
  i: integer;
  FPlugins: TList;
begin
  ResOp_SetDebugLevel(dlInfo); // Solo mostrar warnings y errores

  if Assigned(ConfigManager) then
  begin
    TDebugLogger.SetLogLevel(TDebugLogLevel(ConfigManager.GetDebugLevel));
    TDebugLogger.SetLogFile(ConfigManager.GetLogFileName);
  end;

  Caption := 'ETEdit - Static HTML IDE';
  FProjectName := 'Untitled Project';
  FProject := TETEditProject.Create('');
  // Initialize docking BEFORE loading layout
  VarBaseDockMaster := TGlassDockMaster.Create(self);
  InitializeDocking;
  TDebugLogger.InfoFmt('  InitializeDocking: %s', [Caption], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  // Load default layout - this will create the editor form
  LoadLayout('default_layout.xml');
  TDebugLogger.DebugFmt('  LoadLayout: %s', [Caption], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  // Setup status bar
  with StatusBar1 do
  begin
    SimplePanel := False;
    Panels.Clear;
    with Panels.Add do
    begin
      Text := 'Ready';
      Width := 100;
    end;
    with Panels.Add do
    begin
      Text := 'Line: 1, Col: 1';
      Width := 120;
    end;
    with Panels.Add do
    begin
      Text := 'Saved';
      Width := 80;
    end;
    with Panels.Add do
    begin
      Text := '';
      Width := 200;
    end;
    with Panels.Add do
    begin
      Text := 'UTF-8';
      Width := 60;
    end;
  end;
  StatusBar1.Panels[3].Width :=
    ClientWidth - StatusBar1.Panels[0].Width - StatusBar1.Panels[1].Width - StatusBar1.Panels[2].Width - StatusBar1.Panels[4].Width - 20;
  // Update UI
  // Connect theme change
  ThemeManager.OnThemeChanged := @ThemeChangedHandler;

  if not DirectoryExists('plugins') then
    CreateDir('plugins');

  FPluginManager := TPluginManager.Create('plugins/', VarBaseDockMaster);
  FPluginManager.LoadAllPlugins;

  // Crear temporizador para monitorear cambios externos
  FCheckTimer := TTimer.Create(Self);
  FCheckTimer.Interval := 500; // 1 segundo
  FCheckTimer.OnTimer := @CheckExternalChanges;
  FCheckTimer.Enabled := True;

  UpdateProjectUI;
  UpdateStatusBar;
  //  PluginInfo := FindPluginForExt(Ext);
  for i := 0 to FPluginManager.Count - 1 do
    //Plugins.Count - 1 do
  begin
    Info := PPluginInfo(FPluginManager.Plugins[i]);
    TDebugLogger.DebugFmt('  Plugin Found: %d %s', [i, Info^.Name], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    Li := Tmenuitem.Create(Menu);
    Li.Caption := Info^.Name;
    mnuPlugins.Add(Li);
  end;

end;

procedure TMainForm.ThemeChangedHandler(Sender: TObject);
begin
  ApplyCurrentThemeToAllForms;
end;

procedure TMainForm.actSaveLayoutAsExecute(Sender: TObject);
begin

end;

procedure TMainForm.actSaveLayoutExecute(Sender: TObject);
begin
  SaveLayout('default_layout.xml');
end;

// Update FormDestroy to clean up properly
procedure TMainForm.FormDestroy(Sender: TObject);
begin
  // Save layout on exit
  TDebugLogger.Info('MainForm.Destroy called', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  SaveLayout('default_layout.xml');
  // Cleanup
  FCheckTimer.Free;
  //  if Assigned(FPluginManager) then
  FPluginManager.Free;
  //  if Assigned(FProject) then
  FProject.Free;

  //  TDebugLogger.CloseLogFile;
end;

// ============ DOCKING SYSTEM ============
procedure TMainForm.InitializeDocking;
begin
  // Make the panel a dock panel FIRST
  VarBaseDockMaster.MakeDockPanel(AnchorDockPanel1, admrpChild);
  TDebugLogger.InfoFmt('  InitializeDocking: %s', ['InitializeDocking'], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TDebugLogger.DebugFmt('  AnchorDockPanel1: %s', [AnchorDockPanel1.Caption], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  // Set up the docking master
  VarBaseDockMaster.OnCreateControl := @DockMasterCreateControl;
  VarBaseDockMaster.OnShowOptions := @ShowGlassDockOptions;
  // Show editor by default
  VarBaseDockMaster.ShowControl('EditorForm', True);
  // Show project tree by default
  VarBaseDockMaster.ShowControl('ProjectTree', True);
end;

// Then update DockMasterCreateControl to match:
procedure TMainForm.DockMasterCreateControl(Sender: TObject; aName: string; var AControl: TControl; DoDisableAutoSizing: boolean);
var
  ExistingControl: TControl;
begin
  TDebugLogger.InfoFmt('  DockMasterCreateControl called for: %s', [aName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  // First check if control exists in Screen
  ExistingControl := Screen.FindForm(aName);

  if (ExistingControl <> nil) and (ExistingControl is TForm) then
  begin
    TDebugLogger.InfoFmt('  Found existing form: %s', [aName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

    AControl := ExistingControl;

    // Ensure it has reasonable bounds
    if AControl.Width < 100 then
      AControl.Width := 300;
    if AControl.Height < 100 then
      AControl.Height := 400;

    if DoDisableAutoSizing and (AControl <> nil) then
      AControl.DisableAutoSizing;
    Exit;
  end;
  if aName = 'EditorForm' then
  begin
    AControl := TEditorForm.Create(Application);
    TEditorForm(AControl).Name := 'EditorForm';
    TEditorForm(AControl).Caption := 'Editor';
    TEditorForm(AControl).OnActiveEditorChanged := @EditorTabsActiveEditorChanged;
    // Connect event

    if DoDisableAutoSizing then
      AControl.DisableAutoSizing;
  end
  else if aName = 'ProjectTree' then
  begin
    // Just create it normally
    AControl := TProjectTreeForm.Create(Application);
    TProjectTreeForm(AControl).Name := 'ProjectTree';
    TProjectTreeForm(AControl).Caption := 'Project';
    TProjectTreeForm(AControl).SetProject(FProject);
    TProjectTreeForm(AControl).OnDblClick := @OpenFileFromProjectTree;
    TProjectTreeForm(AControl).OnPopulatePluginMenu := @PopulatePluginMenu; // <-- Asignar callback

    if DoDisableAutoSizing then
      AControl.DisableAutoSizing;
  end
  else if aName = 'ProjectSettings' then
  begin
    AControl := TProjectSettingsForm.Create(Application);
    TProjectSettingsForm(AControl).Name := 'ProjectSettings';
    TProjectSettingsForm(AControl).Caption := 'Settings';
    //    TProjectSettingsForm(AControl).OnSettingsApplied := @ProjectSettingsApplied;
    //    TProjectSettingsForm(AControl).OnSettingsCancelled := @ProjectSettingsCancelled;

    if DoDisableAutoSizing then
      AControl.DisableAutoSizing;
  end
  else if aName = 'JSAnalyzer' then
  begin
    AControl := TJSAnalyzerForm.Create(Application);
    TJSAnalyzerForm(AControl).Name := 'JSAnalyzer';
    TJSAnalyzerForm(AControl).Caption := 'JavaScript Analyzer';
    TJSAnalyzerForm(AControl).SetProject(FProject);
    //    TJSAnalyzerForm(AControl).FormShow(FProject);
    if DoDisableAutoSizing then
      AControl.DisableAutoSizing;
  end
  else if Pos('Host', aName) > 0 then
  begin
    AControl := CreatePluginHostForm(aName, Copy(aName, 1, Length(aName) - 4), DoDisableAutoSizing);
    TDebugLogger.DebugFmt('DockMasterCreateControl Pos Host %s', [aName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  end;
end;

function TMainForm.GetEditorForm: TEditorForm;
begin
  Result := TEditorForm(VarBaseDockMaster.FindControl('EditorForm'));
end;

function TMainForm.GetProjectTreeForm: TProjectTreeForm;
begin
  Result := TProjectTreeForm(VarBaseDockMaster.FindControl('ProjectTree'));
end;

procedure TMainForm.actViewProjectExecute(Sender: TObject);
var
  Form: TProjectTreeForm;
begin
  VarBaseDockMaster.ShowControl('ProjectTree', True);
  // Update project data if needed
  Form := GetProjectTreeForm;
  if (Form <> nil) and (Form.Project <> FProject) then
    Form.SetProject(FProject);
  // Set project AFTER the form is shown/created
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  AnalyzerForm: TJSAnalyzerForm;
begin
  TDebugLogger.Info('MainForm.FormClose called', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  // Get analyzer form
  AnalyzerForm := GetJSAnalyzerForm;

  // Final cleanup if browser is still active
  if Assigned(AnalyzerForm) and AnalyzerForm.FBrowserCreated then
  begin
    TDebugLogger.Info('Final CEF cleanup in MainForm.FormClose', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    AnalyzerForm.ForceCloseCEF;

    // Free the form if it exists
    try
      AnalyzerForm.Free;
    except
      // Ignore cleanup errors
    end;
  end;

  // Save layout
  SaveLayout('default_layout.xml');

  FPluginManager.Free;
  // Cleanup project
  if Assigned(FProject) then
    FProject.Free;

  // Allow application to close
  CloseAction := caFree;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  AnalyzerForm: TJSAnalyzerForm;
  MaxWait: integer;
begin
  TDebugLogger.Info('MainForm.FormCloseQuery called', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  // Get the analyzer form
  AnalyzerForm := GetJSAnalyzerForm;

  if Assigned(AnalyzerForm) then
  begin
    // Mark that we're closing from main form
    AnalyzerForm.FClosingFromMain := True;

    if AnalyzerForm.FBrowserCreated then
    begin
      TDebugLogger.Info('Starting CEF shutdown from MainForm...', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

      // First try graceful shutdown
      AnalyzerForm.CloseCEFBrowser;

      // Wait with timeout
      MaxWait := 20; // 2 seconds (20 * 100ms)
      while AnalyzerForm.FBrowserCreated and (MaxWait > 0) do
      begin
        Sleep(100);
        Dec(MaxWait);
        Application.ProcessMessages;
      end;

      // If still not closed, force it
      if AnalyzerForm.FBrowserCreated then
      begin
        TDebugLogger.Warning('CEF not closed after timeout, forcing...', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        AnalyzerForm.ForceCloseCEF;
      end;
    end;
  end;

  // Always allow close - we'll handle cleanup in FormClose
  CanClose := True;
end;

function TMainForm.GetProjectSettingsForm: TProjectSettingsForm;
begin
  Result := TProjectSettingsForm(VarBaseDockMaster.FindControl('ProjectSettings'));
end;

function TMainForm.GetJSAnalyzerForm: TJSAnalyzerForm;
begin
  Result := TJSAnalyzerForm(VarBaseDockMaster.FindControl('JSAnalyzer'));
end;

procedure TMainForm.actTJSAnalyzerExecute(Sender: TObject);
var
  Form: TJSAnalyzerForm;
begin
  if FProject.ProjectFile = '' then
  begin
    ShowMessage('No project open.');
    Exit;
  end;

  VarBaseDockMaster.ShowControl('JSAnalyzer', True);
  // Set project AFTER the form is shown/created
  Form := GetJSAnalyzerForm;
  if (Form <> nil) and (Form.Project <> FProject) then
  begin
    Form.SetProject(FProject);
  end;
  Form.RefreshAnalysis;
end;

// Update actCloseAllTabs
procedure TMainForm.actCloseAllTabsExecute(Sender: TObject);
var
  Editor: TEditorForm;
begin
  Editor := GetEditorForm;
  if Assigned(Editor) then
  begin
    Editor.CloseAllTabs;
    UpdateProjectUI;
    refreshProjectTree;
  end;
end;

procedure TMainForm.actCloseTabExecute(Sender: TObject);
begin

end;

procedure TMainForm.actDockigOptionsExecute(Sender: TObject);
begin
  ShowGlassDockOptions(VarBaseDockMaster);
  VarBaseDockMaster.ShowHeader := True;
end;

// ============ VIEW MENU HANDLERS ============

procedure TMainForm.mnuViewProjectTreeClick(Sender: TObject);
var
  Form: TProjectTreeForm;
begin
  VarBaseDockMaster.ShowControl('ProjectTree', True);

  // Set project AFTER the form is shown/created
  Form := GetProjectTreeForm;
  if (Form <> nil) and (Form.Project <> FProject) then
    Form.SetProject(FProject);
end;

procedure TMainForm.mnuViewProjectSettingsClick(Sender: TObject);
var
  Form: TProjectSettingsForm;
begin
  if FProject.ProjectFile = '' then
  begin
    ShowMessage('No project open.');
    Exit;
  end;

  VarBaseDockMaster.ShowControl('ProjectSettings', True);

  // Load project data into settings form
  Form := GetProjectSettingsForm;
  if Form <> nil then
    Form.LoadFromProject(FProject);
end;

// ============ LAYOUT MANAGEMENT ============

procedure TMainForm.SaveLayout(const Filename: string);
var
  XMLConfig: TXMLConfigStorage;
begin
  try
    XMLConfig := TXMLConfigStorage.Create(Filename, False);
    try
      VarBaseDockMaster.SaveLayoutToConfig(XMLConfig, '');
      VarBaseDockMaster.SaveSettingsToConfig(XMLConfig, '');
      XMLConfig.WriteToDisk;
    finally
      XMLConfig.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Error saving layout: ' + E.Message);
  end;
end;

procedure TMainForm.LoadLayout(const Filename: string);
var
  XMLConfig: TXMLConfigStorage;
begin
  if FileExists(Filename) then
  begin
    try
      XMLConfig := TXMLConfigStorage.Create(Filename, True);
      try
        VarBaseDockMaster.LoadLayoutFromConfig(XMLConfig, '', True);
        VarBaseDockMaster.LoadSettingsFromConfig(XMLConfig, '');
      finally
        XMLConfig.Free;
      end;
    except
      on E: Exception do
        ShowMessage('Error loading layout: ' + E.Message);
    end;
  end;
end;

// ============ FILE ACTIONS ============

// Update actions to use the editor form
procedure TMainForm.actSaveExecute(Sender: TObject);
var
  Editor: TEditorForm;
begin
  Editor := GetEditorForm;
  if Assigned(Editor) then
    Editor.SaveActiveTab;
end;

procedure TMainForm.actSaveAsExecute(Sender: TObject);
var
  Editor: TEditorForm;
begin
  Editor := GetEditorForm;
  if Assigned(Editor) and Assigned(Editor.ActiveTab) then
    Editor.ActiveTab.SaveFileAs('');
end;

procedure TMainForm.actSaveAllExecute(Sender: TObject);
var
  Editor: TEditorForm;
begin
  Editor := GetEditorForm;
  if Assigned(Editor) then
    Editor.SaveAllTabs;
end;

procedure TMainForm.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.actOpenFileExecute(Sender: TObject);
var
  OD: TOpenDialog;
  Editor: TEditorForm;
begin
  Editor := GetEditorForm;
  if not Assigned(Editor) then Exit;

  OD := TOpenDialog.Create(Self);
  try
    OD.Filter := 'Web files|*.html;*.htm;*.css;*.js|All files|*.*';
    if OD.Execute then
      ConfigManager.AddRecentFile(OD.FileName);
    Editor.OpenFile(OD.FileName);
  finally
    OD.Free;
  end;
end;

// ============ PROJECT ACTIONS ============

procedure TMainForm.actNewProjectExecute(Sender: TObject);
var
  ProjectName, BasePath: string;
  SD: TSelectDirectoryDialog;
begin
  ProjectName := 'MyWebProject';
  if not InputQuery('New Project', 'Enter project name:', ProjectName) then
    Exit;

  if ProjectName = '' then
  begin
    ShowMessage('Project name cannot be empty.');
    Exit;
  end;

  SD := TSelectDirectoryDialog.Create(Self);
  try
    SD.Title := 'Select project location';
    if SD.Execute then
    begin
      BasePath := IncludeTrailingPathDelimiter(SD.FileName);
      if FProject.NewProject(ProjectName, BasePath) then
      begin
        FProjectName := FProject.ProjectName;
        FProjectPath := FProject.ProjectPath;
        refreshProjectTree;
        ShowMessage('Project created successfully.');
      end
      else
        ShowMessage('Failed to create project.');
    end;
  finally
    SD.Free;
  end;
end;

procedure TMainForm.actOpenProjectExecute(Sender: TObject);
var
  OD: TOpenDialog;
begin
  OD := TOpenDialog.Create(Self);
  try
    OD.Filter := 'ETEdit Projects (*.etproj)|*.etproj|All files (*.*)|*.*';
    if OD.Execute then
    begin
      if FProject.OpenProject(OD.FileName) then
      begin
        FProjectName := FProject.ProjectName;
        FProjectPath := FProject.ProjectPath;
        refreshProjectTree;
        ShowMessage('Project opened successfully.');
        ConfigManager.AddRecentProject(FProject.ProjectFile);
      end
      else
        ShowMessage('Failed to open project.');
    end;
  finally
    OD.Free;
  end;
end;

procedure TMainForm.actCloseProjectExecute(Sender: TObject);
var
  Editor: TEditorForm;
begin
  Editor := GetEditorForm;
  if Assigned(Editor) then
  begin
    if MessageDlg('Close Project', 'Close current project?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin

      Editor.CloseAllTabs;
      Editor.SaveAllTabs;
      UpdateProjectUI;
      refreshProjectTree;
      FProject.CloseProject;
      FProjectName := 'No Project';
      FProjectPath := '';
      UpdateProjectUI;
      refreshProjectTree;
      ShowMessage('Project closed.');
    end;
  end;
end;

procedure TMainForm.refreshProjectTree;
var
  TreeForm: TProjectTreeForm;
  FormA: TJSAnalyzerForm;
begin
  UpdateProjectUI;
  TreeForm := GetProjectTreeForm;
  if Assigned(TreeForm) then
  begin
    TreeForm.SetProject(FProject);
    TreeForm.RefreshTree;
  end;
  FormA := GetJSAnalyzerForm;
  if Assigned(FormA) then
  begin
    FormA.RefreshAnalysis;
  end;

end;

procedure TMainForm.actProjectSettingsExecute(Sender: TObject);
begin
  mnuViewProjectSettingsClick(Sender);
end;

procedure TMainForm.actCompileProjectExecute(Sender: TObject);
var
  Editor: TEditorForm;
begin
  Editor := GetEditorForm;
  if Assigned(Editor) then
  begin
    if FProject.ProjectFile = '' then
    begin
      ShowMessage('No project open.');
      Exit;
    end;

    Editor.SaveAllTabs;
    if FProject.CompileProject then
      ShowMessage('Project compiled successfully.')
    else
      ShowMessage('Failed to compile project.');
  end;

end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (Key = VK_F11) and (ssCtrl in Shift) then
  begin
    actNextThemeExecute(Sender);
    Key := 0;
  end;
end;

procedure TMainForm.mnuSettingsClick(Sender: TObject);
begin
  actSettingsExecute(Sender);
end;

procedure TMainForm.mnuThemeBlueClick(Sender: TObject);
begin
  ThemeManager.ApplyTheme(etBlue);
  ApplyCurrentThemeToAllForms;
end;

procedure TMainForm.mnuThemeDarkClick(Sender: TObject);
begin
  ThemeManager.ApplyTheme(etDark);
  ApplyCurrentThemeToAllForms;
end;

procedure TMainForm.mnuThemeLightClick(Sender: TObject);
begin
  ThemeManager.ApplyTheme(etLight);
  ApplyCurrentThemeToAllForms;
end;

// Add new action for showing editor
procedure TMainForm.actViewEditorExecute(Sender: TObject);
begin
  VarBaseDockMaster.ShowControl('EditorForm', True);
end;

// ============ EDITOR EVENTS ============

// Update the event handler to use the editor form
procedure TMainForm.EditorTabsActiveEditorChanged(Sender: TObject; Editor: TSynEdit);
begin
  UpdateStatusBar;
end;

procedure TMainForm.StatusBar1Resize(Sender: TObject);
begin
  UpdateStatusBar;
end;

procedure TMainForm.StatusTimerTimer(Sender: TObject);
begin
  UpdateStatusBar;
end;

// ============ PROJECT UI ============

procedure TMainForm.UpdateProjectUI;
var
  HasProject: boolean;
begin
  if FProject.ProjectFile <> '' then
    Caption := 'ETEdit - ' + FProjectName + ' [' + FProjectPath + ']'
  else
    Caption := 'ETEdit - No Project';

  HasProject := FProject.ProjectFile <> '';
  // Check if components exist before accessing them
  if Assigned(mnuSave) then mnuSave.Enabled := HasProject;
  if Assigned(mnuSaveAs) then mnuSaveAs.Enabled := HasProject;
  if Assigned(mnuSaveAll) then mnuSaveAll.Enabled := HasProject;
  if Assigned(mnuCloseProject) then mnuCloseProject.Enabled := HasProject;
  if Assigned(mnuCompileProject) then mnuCompileProject.Enabled := HasProject;
  if Assigned(mnuProjectSettings) then mnuProjectSettings.Enabled := HasProject;
  if Assigned(tooSaveFile) then tooSaveFile.Enabled := HasProject;
  if Assigned(tooSaveFileAll) then tooSaveFileAll.Enabled := HasProject;
  if Assigned(tooCloseProject) then tooCloseProject.Enabled := HasProject;
  if Assigned(tooProjectSettings) then tooProjectSettings.Enabled := HasProject;
  if Assigned(tooCompileProject) then tooCompileProject.Enabled := HasProject;

end;

// Update status bar to use editor form
procedure TMainForm.UpdateStatusBar;
var
  Editor: TEditorForm;
  ActiveEditor: TSynEdit;
  ActiveTab: TEditorTab;
begin
  Editor := GetEditorForm;
  if not Assigned(Editor) then Exit;

  if StatusBar1.Panels.Count >= 5 then
  begin
    ActiveEditor := Editor.ActiveEditor;
    ActiveTab := Editor.ActiveTab;

    if ActiveEditor <> nil then
    begin
      StatusBar1.Panels[0].Text := 'Ready';
      StatusBar1.Panels[1].Text :=
        Format('Line: %d, Col: %d', [ActiveEditor.CaretY, ActiveEditor.CaretX]);

      if ActiveEditor.Modified then
        StatusBar1.Panels[2].Text := 'Modified *'
      else
        StatusBar1.Panels[2].Text := 'Saved';

      if (ActiveTab <> nil) and (ActiveTab.FileName <> '') then
        StatusBar1.Panels[3].Text := ExtractFileName(ActiveTab.FileName)
      else
        StatusBar1.Panels[3].Text := '';

      StatusBar1.Panels[4].Text := 'UTF-8';
    end;
  end;
  StatusBar1.Panels[3].Width :=
    ClientWidth - StatusBar1.Panels[0].Width - StatusBar1.Panels[1].Width - StatusBar1.Panels[2].Width - StatusBar1.Panels[4].Width - 20;
end;

procedure TMainForm.ApplyCurrentThemeToAllForms;
var
  i: integer;
  EdForm: TEditorForm;
  TreeForm: TProjectTreeForm;
  AnalyzerForm: TJSAnalyzerForm;
  SettingsForm: TProjectSettingsForm;
begin
  // Apply to main form and all its child controls
  ThemeManager.ApplyToContainer(Self);

  // Apply to docked forms
  EdForm := GetEditorForm;
  if EdForm <> nil then
    ThemeManager.ApplyToContainer(EdForm);

  TreeForm := GetProjectTreeForm;
  if TreeForm <> nil then
    ThemeManager.ApplyToContainer(TreeForm);

  AnalyzerForm := GetJSAnalyzerForm;
  if AnalyzerForm <> nil then
    ThemeManager.ApplyToContainer(AnalyzerForm);

  SettingsForm := GetProjectSettingsForm;
  if SettingsForm <> nil then
    ThemeManager.ApplyToContainer(SettingsForm);

  // Apply to any other forms
  for i := 0 to Screen.FormCount - 1 do
  begin
    // Skip forms we've already handled
    if (Screen.Forms[i] = Self) or (Screen.Forms[i] = EdForm) or (Screen.Forms[i] = TreeForm) or (Screen.Forms[i] = AnalyzerForm) or (Screen.Forms[i] = SettingsForm) then
      Continue;

    ThemeManager.ApplyToContainer(Screen.Forms[i]);
  end;
end;

// In implementation
procedure TMainForm.actThemeTesterExecute(Sender: TObject);
begin
  if not Assigned(ThemeTesterForm) then
    ThemeTesterForm := TThemeTesterForm.Create(Application);

  ThemeTesterForm.Show;
  ThemeTesterForm.RefreshFromTheme;
end;

procedure TMainForm.actNextThemeExecute(Sender: TObject);
begin
  ThemeManager.NextTheme;
  ApplyCurrentThemeToAllForms;
  ShowMessage('Theme: ' + ThemeManager.GetCurrentThemeName);
end;

procedure TMainForm.actRefreshProjectExecute(Sender: TObject);
begin

end;

procedure TMainForm.actSettingsExecute(Sender: TObject);
var
  frm: TSettings;
begin
  frm := TSettings.Create(Self);
  try
    if frm.ShowModal = mrOk then
    begin
      // Actualizar variables globales si es necesario
      TDebugLogger.SetLogLevel(TDebugLogLevel(ConfigManager.GetDebugLevel));
      TDebugLogger.SetLogFile(ConfigManager.GetLogFileName);
    end;
  finally
    frm.Free;
  end;
end;


// ============ FILE OPERATIONS ============

// Update OpenFileFromProjectTree

procedure TMainForm.OpenFileFromProjectTree(Sender: TObject);
var
  FileName: string;
  Ext: string;
  PluginInfo: PPluginInfo;
begin
  FileName := GetProjectTreeForm.GetSelectedFile;
  if (FileName = '') or not FileExists(FileName) then Exit;
  ConfigManager.AddRecentFile(FileName);
  Ext := LowerCase(ExtractFileExt(FileName));
  PluginInfo := FPluginManager.FindPluginForExt(Ext);
  if PluginInfo <> nil then
  begin
    if PluginInfo^.Kind = pkVisual then
    begin
      FPluginManager.ShowVisualPlugin(PluginInfo, FileName);
      GetEditorForm.OpenFile(FileName);
    end
    else
      FPluginManager.ProcessFileWithPlugin(PluginInfo, FileName);
  end
  else
    GetEditorForm.OpenFile(FileName);
end;

procedure TMainForm.FileCheckTimerTimer(Sender: TObject);
var
  i: integer;
  Tab: TEditorTab;
  AutoReload: boolean;
begin
  TDebugLogger.Debug('FileCheckTimerTimer:', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  if not Assigned(FEditorForm) then Exit;
  AutoReload := ConfigManager.GetAutoReloadFiles;
  for i := 0 to FEditorForm.EditorTabs.TabCount - 1 do
  begin
    Tab := FEditorForm.EditorTabs.Tabs[i];
    if (Tab <> nil) and (Tab.FileName <> '') and Tab.IsFileChangedExternally then
    begin
      if AutoReload then
        ReloadTab(Tab)
      else
      begin
        if MessageDlg(Format('El archivo "%s" ha cambiado en disco. ¿Recargar?', [ExtractFileName(Tab.FileName)]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
          ReloadTab(Tab);
      end;
    end;
  end;
end;

procedure TMainForm.ReloadTab(Tab: TEditorTab);
var
  SavedTopLine: integer;
  SavedLeftChar: integer;
  SavedCaretX: integer;
  SavedCaretY: integer;
begin
  if Tab = nil then Exit;
  if Tab.Editor <> nil then
  begin
    SavedTopLine := Tab.Editor.TopLine;
    SavedLeftChar := Tab.Editor.LeftChar;
    SavedCaretX := Tab.Editor.CaretX;
    SavedCaretY := Tab.Editor.CaretY;
  end;

  Tab.LoadFile;  // Recarga el archivo
  Tab.UpdateLastWriteTime;

  if Tab.Editor <> nil then
  begin
    // Restaurar posición del cursor
    Tab.Editor.CaretX := SavedCaretX;
    Tab.Editor.CaretY := SavedCaretY;
    // Restaurar desplazamiento
    Tab.Editor.TopLine := SavedTopLine;
    Tab.Editor.LeftChar := SavedLeftChar;
  end;
end;

procedure TMainForm.CheckExternalChanges(Sender: TObject);
var
  i: integer;
  Tab: TEditorTab;
  AutoReload: boolean;
begin
  FEditorForm := GetEditorForm;
  if not Assigned(FEditorForm) then Exit;
  AutoReload := ConfigManager.GetAutoReloadFiles;
  for i := 0 to FEditorForm.EditorTabs.TabCount - 1 do
  begin
    Tab := FEditorForm.EditorTabs.Tabs[i];
    if (Tab <> nil) and (Tab.FileName <> '') and Tab.IsFileChangedExternally then
    begin
      if AutoReload then
        ReloadTab(Tab)
      else
      begin
        if MessageDlg(Format('El archivo "%s" ha cambiado en disco. ¿Recargar?', [ExtractFileName(Tab.FileName)]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
          ReloadTab(Tab);
      end;
    end;
  end;
end;

function TMainForm.GetPluginsForFile(const FileName: string): TList;
var
  Ext: string;
begin
  Ext := LowerCase(ExtractFileExt(FileName));
  Result := FPluginManager.GetPluginsForExt(Ext);
end;

procedure TMainForm.OpenFileWithPlugin(PluginInfo: PPluginInfo; const FileName: string);
begin
  TDebugLogger.Debug('  OpenFileWithPlugin', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  GetEditorForm.OpenFile(FileName);
  FPluginManager.OpenFileWithPlugin(PluginInfo, FileName);
end;

procedure TMainForm.PopulatePluginMenu(Popup: TPopupMenu; const FileName: string);
var
  Plugins: TList;
  i: integer;
  Info: PPluginInfo;
  MenuItem, SubMenu: TMenuItem;
  Ext: string;
begin
  TDebugLogger.Debug('  PopulatePluginMenu', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  Ext := LowerCase(ExtractFileExt(FileName));
  Plugins := FPluginManager.GetPluginsForExt(Ext);
  try
    // Buscar o crear submenú "Open with"
    SubMenu := nil;
    for i := 0 to Popup.Items.Count - 1 do
    begin
      TDebugLogger.DebugFmt('  PopulatePluginMenu %s', [Popup.Items[i].Caption], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      if Popup.Items[i].Caption = 'Open With' then
      begin
        TDebugLogger.DebugFmt('  PopulatePluginMenu %s', [Popup.Items[i].Caption], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        SubMenu := Popup.Items[i];
        Break;
      end;
    end;
    if SubMenu = nil then
    begin
      TDebugLogger.Debug('  SubMenu = nil', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      SubMenu := TMenuItem.Create(Popup);
      SubMenu.Caption := 'Open With';
      Popup.Items.Insert(1, SubMenu);
    end
    else
    begin
      TDebugLogger.Debug('  SubMenu clear', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      SubMenu.Clear; // Limpiar ítems anteriores
      if (Plugins = nil) or (Plugins.Count = 0) then
      begin
        Exit;
      end;
    end;

    for i := 0 to Plugins.Count - 1 do
    begin
      Info := PPluginInfo(Plugins[i]);
      MenuItem := TMenuItem.Create(SubMenu);
      MenuItem.Caption := Info^.Name;
      MenuItem.Tag := PtrInt(Info);
      MenuItem.OnClick := @OpenWithPluginClick;
      SubMenu.Add(MenuItem);
    end;
  finally
    Plugins.Free;
  end;
end;

procedure TMainForm.OpenWithPluginClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  Info: PPluginInfo;
  TreeForm: TProjectTreeForm;
  FileName: string;
begin
  MenuItem := Sender as TMenuItem;
  Info := PPluginInfo(MenuItem.Tag);
  TreeForm := GetProjectTreeForm;
  if TreeForm <> nil then
  begin
    FileName := TreeForm.GetSelectedFile;
    if (FileName <> '') and FileExists(FileName) then
      FPluginManager.OpenFileWithPlugin(Info, FileName);
    GetEditorForm.OpenFile(FileName);
  end;
end;

end.
