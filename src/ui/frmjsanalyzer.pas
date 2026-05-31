unit frmJSAnalyzer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, VirtualTrees, ComCtrls,
  Menus, FileUtil, LazFileUtils, LazUTF8, SysThreadsGroup, TreeFilterEdit,
  IpHtml, LCLType, LCLIntf, Math, ExtCtrls, StdCtrls, Buttons, Clipbrd,
  FileCtrl, ComboEx, Grids, uCEFWindowParent, uCEFChromium, uProject,
  uFileUtils, uDebugLog, uJSParser, uJSDocHTMLFormatter,
  // Add the parser unit
  {$ifdef windows}
  ActiveX
  {$else}
  FakeActiveX
  {$endif}, Types, uCEFWinControl, uCEFTypes, uCEFApplication,
  uCEFConstants, uCEFInterfaces, uCEFChromiumEvents, uCEFChromiumWindow;

type
  TNodeType = (ntFile, ntFunction);

  TTreeNodeData = record
    NodeType: TNodeType;
    DisplayName: string;
    FileIndex: integer;
    FunctionCount: integer;
    FuncInfo: TJSFunctionInfo;
  end;
  PTreeNodeData = ^TTreeNodeData;

  TGridCellData = class
  public
    EditType: integer;  // 0=readonly
    CellRow: integer;
    CellCol: integer;
    FileIdx: integer;
    FuncIdx: integer;
    ParamIdx: integer;  // -1 if not a parameter
    IsDirty: boolean;   // Track if this cell has been modified
    constructor Create(AEditType, AFileIdx, AFuncIdx, AParamIdx: integer);
  end;

  { TJSAnalyzerForm }

  TJSAnalyzerForm = class(TForm)
    btnSaveFunction: TButton;
    btnCancelEdit: TButton;
    CEFWindowParent1: TCEFWindowParent;
    ChromiumBrowser1: TChromium;
    Label1: TLabel;
    lblDescription: TLabel;
    lblReturnType: TLabel;
    lblParameters: TLabel;
    lblFunctionName: TLabel;
    lblFunctionCount: TLabel;
    memoCodePreview: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    PageControl1: TPageControl;
    PageControl2: TPageControl;
    pnlTrees: TPanel;
    PopupMenu1: TPopupMenu;
    ProgressBar1: TProgressBar;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    StringGridFunctions: TStringGrid;
    tabCalls: TTabSheet;
    tabFunctionList: TTabSheet;
    tabGlobals: TTabSheet;
    TabSheet3: TTabSheet;
    tabEditDocs: TTabSheet;
    tabPreview: TTabSheet;
    TabSheetFunctions: TTabSheet;
    TabSheetVariables: TTabSheet;
    TreeView1: TVirtualStringTree;
    pnlInfo: TPanel;
    lblFileName: TLabel;
    pnlDetails: TPanel;
    treeCalls: TVirtualStringTree;
    ImageList1: TImageList;
    btnSort: TSpeedButton;
    TreeFilterEdit1: TTreeFilterEdit;
    FilterComboBox1: TComboBox;
    CheckComboBoxFilterOptions: TCheckComboBox;
    lblChckFntOpt: TLabel;
    PanelFilter: TPanel;
    TreeViewGlobals: TVirtualStringTree;
    TabSheetDocumentation: TTabSheet;

    procedure btnCancelEditClick(Sender: TObject);
    procedure btnSaveFunctionClick(Sender: TObject);
    procedure btnSortClick(Sender: TObject);
    procedure CheckComboBoxFilterOptionsItemChange(Sender: TObject; AIndex: integer);
    procedure ChromiumBrowser1AfterCreated(Sender: TObject; const browser: ICefBrowser);
    procedure ChromiumBrowser1BeforeClose(Sender: TObject; const browser: ICefBrowser);
    procedure ChromiumBrowser1BeforeContextMenu(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; const params: ICefContextMenuParams; const model: ICefMenuModel);
    procedure ChromiumBrowser1LoadEnd(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: integer);
    procedure ChromiumBrowser1LoadError(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; errorCode: TCefErrorCode; const errorText, failedUrl: ustring);

    procedure FilterCheckComboBoxChange(Sender: TObject);
    procedure FilterComboBox1Change(Sender: TObject);

    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);

    procedure PageControl1Change(Sender: TObject);
    procedure StringGridFunctionsKeyPress(Sender: TObject; var Key: char);
    procedure StringGridFunctionsSelectCell(Sender: TObject; aCol, aRow: integer; var CanSelect: boolean);
    procedure StringGridFunctionsSetEditText(Sender: TObject; ACol, ARow: integer; const Value: string);
    procedure TabSheetCallsContextPopup(Sender: TObject; MousePos: TPoint; var Handled: boolean);
    procedure TreeFilterEdit1Change(Sender: TObject);
    procedure TreeView1GetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure TreeView1GetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: boolean; var ImageIndex: integer);
    procedure TreeView1FocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
    procedure TreeView1InitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure TreeView1FreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure FilterEdit1AfterFilter(Sender: TObject);
    procedure TreeViewGlobalsFreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure TreeViewGlobalsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure TreeViewGlobalsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: boolean; var ImageIndex: integer);
    procedure TreeViewGlobalsFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);

    procedure UpdateParamDescriptionInJSDoc(var FuncInfo: TJSFunctionInfo; const ParamName, NewDescription: string);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure UpdateFunctionInfoFromGrid(FileIdx, FuncIdx: integer; var FuncInfo: TJSFunctionInfo);
    procedure CloseCEFBrowser;

  private
    FProject: TETEditProject;
    FFilesInfo: array of TJSFileInfo;
    FCurrentFileIndex: integer;
    FCurrentFunctionIndex: integer;

    FSortColumn: integer;
    FSortDirection: integer;
    FCurrentFilterType: integer;

    FEditingFunction: TJSFunctionInfo;
    FCurrentFilePath: string;

    FEditingFileIdx: integer;
    FEditingFuncIdx: integer;
    FIsEditing: boolean;

    FLastDocFile: string;                // For HTML documentation
    FLastTempFile: string;

    FLastHTMLContent: string;
    FCEFInitialized: boolean;
    FPendingHTML: string;  // HTML pendiente para cuando CEF se inicialice

    FCreatingBrowser: boolean;
    FRetryTimer: TTimer;
    FTimer: TTimer;  // Add this one too

    FFileChangeTracker: TFileChangeTracker;
    FProjectBasePath: string;
    FDocFormatter: TJSDocHTMLFormatter;  // Already exists, update usage

    procedure ApplyFilter;
    procedure CompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: integer);
    procedure ApplySorting;

    procedure SortByNameAscClick(Sender: TObject);
    procedure SortByNameDescClick(Sender: TObject);
    procedure SortByTypeClick(Sender: TObject);
    procedure SortByLinesClick(Sender: TObject);

    function FunctionMatchesFilterType(NodeData: PTreeNodeData; FilterType: integer): boolean;
    function FunctionMatchesSearchText(NodeData: PTreeNodeData; SearchText: string): boolean;

    procedure AnalyzeJavaScriptFile(const FilePath: string; IsTemplate: boolean);
    procedure BuildCallGraph;
    procedure UpdateFunctionDetails(FileIndex, FuncIndex: integer);
    procedure LoadTemplatesJSFiles;
    procedure LoadJSFilesFromDirectory(const DirPath: string; IsTemplate: boolean);
    function GetTotalFunctionCount: integer;
    procedure PopulateTreeViews;
    procedure PopulateGlobalsTree;
    procedure CleanupFunctionInfo(var FuncInfo: TJSFunctionInfo);

    procedure GenerateCommentLines(const FuncInfo: TJSFunctionInfo; CommentLines: TStringList);
    procedure FindExistingComment(Lines: TStringList; FuncStart: integer; out CommentStartLine, CommentEndLine: integer; out HasComment: boolean);
    function GetFunctionTypeString(const FuncInfo: TJSFunctionInfo): string;
    procedure ParseParameterString(const ParamStr: string; out ParamName, ParamType, ParamDesc: string);
    function FormatParameterString(const ParamName, ParamType, ParamDesc: string): string;
    procedure FindFunctionIndices(const FuncName: string; StartLine: integer; out FileIdx, FuncIdx: integer);
    function SaveFunctionDocumentation(const FilePath: string; const FuncInfo: TJSFunctionInfo): boolean;
    procedure GenerateJSDocComment(const FuncInfo: TJSFunctionInfo; CommentLines: TStringList);
    procedure UpdateTreeViewNode(FileIdx, FuncIdx: integer);
    procedure RefreshCurrentView;
    procedure UpdateReturnDescriptionInJSDoc(var FuncInfo: TJSFunctionInfo; const NewDescription: string);

    procedure DisplayFunctionInGrid(FileIdx, FuncIdx: integer);
    procedure DisplayFileInGrid(FileIdx: integer);

    function IsGridInEditMode: boolean;
    procedure ClearGridData;
    procedure ClearGrid;

    procedure OpenTempHTMLFile;
    procedure DisplayHTMLDocumentation(const HTML: string);
    function FindFileForGlobalVar(const GlobalVar: TJSGlobalVar): string;
    procedure InitializeCEF;

    function SaveDocumentation(const DocType: string; const aName: string; const HTML: string): string;
    function NeedsDocumentationUpdate(const FilePath: string): boolean;
    procedure GenerateAllDocumentation;

    // Helper to clean up a file info
    procedure CleanupFileInfo(var FileInfo: TJSFileInfo);

    // Debuggin
    // IStatusUpdater implementation
    procedure LogToStatusBar(const Msg: string; Level: TDebugLogLevel);
    procedure CreateCEFBrowser;
  public
    FAppClosing: boolean; // Add this flag
    FBrowserCreated: boolean; // Add this flag
    FClosingFromMain: boolean;

    procedure SetProject(AProject: TETEditProject);
    procedure RefreshAnalysis;
    property Project: TETEditProject read FProject;
    function ExtractParamName(const ParamStr: string): string;
    property AppClosing: boolean read FAppClosing write FAppClosing;
    procedure ForceCloseCEF;
  end;

implementation

{$R *.frm}

function BoolToYesNo(Value: boolean): string;
begin
  if Value then Result := 'Yes'
  else
    Result := 'No';
end;
{ TGridCellData }

constructor TGridCellData.Create(AEditType, AFileIdx, AFuncIdx, AParamIdx: integer);
begin
  inherited Create;
  EditType := AEditType;
  FileIdx := AFileIdx;
  FuncIdx := AFuncIdx;
  ParamIdx := AParamIdx;
  IsDirty := False;
end;

{ TJSAnalyzerForm }

//============= FORM SETTING ========================

procedure TJSAnalyzerForm.FormCreate(Sender: TObject);
begin
  Caption := 'JavaScript Analyzer';
  BorderStyle := bsNone;

  // Add to FormCreate
  FClosingFromMain := False;


  // Configure TreeView1 with hierarchical view
  TreeView1.NodeDataSize := SizeOf(TTreeNodeData);
  TreeView1.Header.Columns.Clear;

  TreeView1.Images := ImageList1;
  TreeView1.StateImages := ImageList1;
  TreeView1.DefaultNodeHeight := 20;

  with TreeView1.Header.Columns.Add do
  begin
    Text := 'Name';
    Width := 250;
  end;
  with TreeView1.Header.Columns.Add do
  begin
    Text := 'Type';
    Width := 100;
  end;
  with TreeView1.Header.Columns.Add do
  begin
    Text := 'Lines';
    Width := 80;
  end;
  with TreeView1.Header.Columns.Add do
  begin
    Text := 'Description';
    Width := 300;
  end;

  // Configure treeCalls
  treeCalls.NodeDataSize := SizeOf(TJSFunctionInfo);
  treeCalls.Header.Options := treeCalls.Header.Options + [hoVisible];

  // Configure TreeFilterEdit1
  TreeFilterEdit1.TextHint := 'Filter functions...';
  if Assigned(TreeFilterEdit1) then
  begin
    TreeFilterEdit1.OnChange := @TreeFilterEdit1Change;
    TreeFilterEdit1.OnAfterFilter := @FilterEdit1AfterFilter;
  end;
  TreeView1.OnGetImageIndex := @TreeView1GetImageIndex;

  TreeView1.OnGetText := @TreeView1GetText;
  TreeView1.OnGetImageIndex := @TreeView1GetImageIndex;
  TreeView1.OnFocusChanged := @TreeView1FocusChanged;
  TreeView1.OnInitNode := @TreeView1InitNode;
  TreeView1.OnFreeNode := @TreeView1FreeNode;
  TreeView1.OnCompareNodes := @CompareNodes;

  // Check all by default
  CheckComboBoxFilterOptions.CheckAll(cbChecked);

  // Set display text when items are checked
  CheckComboBoxFilterOptions.Hint := 'Search in: All';
  lblChckFntOpt.Caption := 'Search in: All';

  // Configure Sort button
  btnSort.Hint := 'Sort options';
  btnSort.ShowHint := True;
  btnSort.OnClick := @btnSortClick;

  // Configure TreeViewGlobals
  TreeViewGlobals.NodeDataSize := SizeOf(TJSGlobalVar);
  TreeViewGlobals.Images := ImageList1;
  TreeViewGlobals.Header.Options := TreeViewGlobals.Header.Options + [hoVisible];

  with TreeViewGlobals.Header.Columns.Add do
  begin
    Text := 'Name';
    Width := 150;
  end;
  with TreeViewGlobals.Header.Columns.Add do
  begin
    Text := 'Type';
    Width := 80;
  end;
  with TreeViewGlobals.Header.Columns.Add do
  begin
    Text := 'Value';
    Width := 200;
  end;
  with TreeViewGlobals.Header.Columns.Add do
  begin
    Text := 'Line';
    Width := 60;
  end;
  with TreeViewGlobals.Header.Columns.Add do
  begin
    Text := 'Description';
    Width := 300;
  end;

  TreeViewGlobals.OnGetText := @TreeViewGlobalsGetText;
  TreeViewGlobals.OnGetImageIndex := @TreeViewGlobalsGetImageIndex;
  TreeViewGlobals.OnFocusChanged := @TreeViewGlobalsFocusChanged;

  // Set up debug logging with a callback to update status bar
  TDebugLogger.SetCallback(@LogToStatusBar);

  ChromiumBrowser1.DefaultUrl := 'about:blank';
  ChromiumBrowser1.OnAfterCreated := @ChromiumBrowser1AfterCreated;
  ChromiumBrowser1.OnLoadEnd := @ChromiumBrowser1LoadEnd;

  FDocFormatter := TJSDocHTMLFormatter.Create;

  FDocFormatter := TJSDocHTMLFormatter.Create;
  FDocFormatter.SetProjectInfo('JavaScript Analysis', '1.0');
  FDocFormatter.SetIncludeLineNumbers(True);
  FDocFormatter.SetExternalResourcesEnabled(True);

  FFileChangeTracker := nil;  // Will be created when project is set
  //  InitializeCEF;

  KeyPreview := True;
  PageControl1.ActivePage := TabSheetFunctions;
end;

procedure TJSAnalyzerForm.FilterCheckComboBoxChange(Sender: TObject);
begin
  ApplyFilter;
end;

procedure TJSAnalyzerForm.FormDestroy(Sender: TObject);
begin
  TDebugLogger.Info('Closing FormDestroy...', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  // Add to FormDestroy

  CloseCEFBrowser;
  // Clean up logging
  // Clean up timers
  if Assigned(FRetryTimer) then
    FRetryTimer.Free;
  if Assigned(FTimer) then
    FTimer.Free;
  if Assigned(FFileChangeTracker) then
    FFileChangeTracker.Free;

  FDocFormatter.Free;

  TDebugLogger.SetCallback(nil);
end;

// Add FormCloseQuery to handle application closing
// Update FormClose
procedure TJSAnalyzerForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  TDebugLogger.Info('FormClose called', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  if not FClosingFromMain then
  begin
    // Close CEF browser normally
    CloseCEFBrowser;
  end;

  // Allow form to close
  CloseAction := caFree;
end;

// Update FormCloseQuery
procedure TJSAnalyzerForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  TDebugLogger.Info('FormCloseQuery called - AppClosing: ' + BoolToStr(AppClosing), {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  // If we're already closing from main form, allow it
  if FClosingFromMain then
  begin
    CanClose := True;
    Exit;
  end;

  // Otherwise, close CEF first
  if FBrowserCreated then
  begin
    TDebugLogger.Info('Starting CEF shutdown from FormCloseQuery...', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    CloseCEFBrowser;
  end;

  CanClose := True;
end;

procedure TJSAnalyzerForm.SetProject(AProject: TETEditProject);
begin
  TDebugLogger.Info('  SetProject', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  FProject := AProject;
  RefreshAnalysis;
end;

//============= FORM SETTING ========================

procedure TJSAnalyzerForm.LogToStatusBar(const Msg: string; Level: TDebugLogLevel);
begin
  // Update status bar with the message

  if Assigned(StatusBar1) and (StatusBar1.Panels.Count > 0) then
  begin
    // Only show first 50 characters in status bar
    StatusBar1.Panels[0].Text := Copy(Msg, 1, 50);
    Application.ProcessMessages;
  end;
end;

//============= FORM FILTERS ========================
// Update PageControl1Change - SIMPLIFIED

procedure TJSAnalyzerForm.FilterComboBox1Change(Sender: TObject);
begin
  FCurrentFilterType := FilterComboBox1.ItemIndex;
  ApplyFilter;
end;

procedure TJSAnalyzerForm.btnSortClick(Sender: TObject);
var
  P: TPoint;
  SortPopupMenu: TPopupMenu;
  MenuItem: TMenuItem;
begin
  SortPopupMenu := TPopupMenu.Create(Self);
  try
    MenuItem := TMenuItem.Create(SortPopupMenu);
    MenuItem.Caption := 'Sort by Name (A-Z)';
    MenuItem.OnClick := @SortByNameAscClick;
    MenuItem.Checked := (FSortColumn = 0) and (FSortDirection = 1);
    SortPopupMenu.Items.Add(MenuItem);

    MenuItem := TMenuItem.Create(SortPopupMenu);
    MenuItem.Caption := 'Sort by Name (Z-A)';
    MenuItem.OnClick := @SortByNameDescClick;
    MenuItem.Checked := (FSortColumn = 0) and (FSortDirection = -1);
    SortPopupMenu.Items.Add(MenuItem);

    SortPopupMenu.Items.Add(NewLine);

    MenuItem := TMenuItem.Create(SortPopupMenu);
    MenuItem.Caption := 'Sort by Function Type';
    MenuItem.OnClick := @SortByTypeClick;
    MenuItem.Checked := (FSortColumn = 1);
    SortPopupMenu.Items.Add(MenuItem);

    MenuItem := TMenuItem.Create(SortPopupMenu);
    MenuItem.Caption := 'Sort by Line Count';
    MenuItem.OnClick := @SortByLinesClick;
    MenuItem.Checked := (FSortColumn = 2);
    SortPopupMenu.Items.Add(MenuItem);

    P := Point(btnSort.Left, btnSort.Top + btnSort.Height);
    P := ClientToScreen(P);
    SortPopupMenu.Popup(P.X, P.Y);
  finally
    // Menu freed automatically
  end;
end;

procedure TJSAnalyzerForm.PageControl1Change(Sender: TObject);
begin
  TDebugLogger.InfoFmt('PageControl1.ActivePage: %s', [PageControl1.ActivePage.Caption], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  // Only handle Documentation tab
  if PageControl1.ActivePage = TabSheetDocumentation then
  begin
    TDebugLogger.Info('Documentation tab activated', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

    // Ensure CEF is marked as initialized (check global state)
    if not FCEFInitialized then
    begin
      FCEFInitialized := Assigned(GlobalCEFApp) and GlobalCEFApp.GlobalContextInitialized;
      TDebugLogger.InfoFmt('Re-checked CEF: %s', [BoolToYesNo(FCEFInitialized)], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    end;

    // Create browser if needed
    if FCEFInitialized and not ChromiumBrowser1.Initialized then
    begin
      // Small delay to ensure UI is ready
      Sleep(50);
      Application.ProcessMessages;
      CreateCEFBrowser;
    end;
  end;
end;

procedure TJSAnalyzerForm.StringGridFunctionsKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then // Enter key
  begin
    // If editing, finish editing
    if StringGridFunctions.EditorMode then
    begin
      StringGridFunctions.EditorMode := False;
    end;
  end;
end;

procedure TJSAnalyzerForm.TabSheetCallsContextPopup(Sender: TObject; MousePos: TPoint; var Handled: boolean);
begin
  Handled := False;
end;

procedure TJSAnalyzerForm.TreeFilterEdit1Change(Sender: TObject);
begin
  ApplyFilter;
end;

procedure TJSAnalyzerForm.CheckComboBoxFilterOptionsItemChange(Sender: TObject; AIndex: integer);
var
  CheckedCount: integer;
  I: integer;
  ndx: integer;
  str: string;
begin
  str := 'NFPD';
  CheckedCount := 0;
  ndx := 0;
  for I := 0 to CheckComboBoxFilterOptions.Items.Count - 1 do
    if CheckComboBoxFilterOptions.Checked[I] then
    begin
      Inc(CheckedCount);
    end
    else
    begin
      ndx := I + 1;
      str[ndx] := '-';
    end;

  CheckComboBoxFilterOptions.Hint := Format('Search in: %d field(s)', [CheckedCount]);
  lblChckFntOpt.Caption := 'Search in: ' + str;

  if CheckedCount = CheckComboBoxFilterOptions.Items.Count then
  begin
    CheckComboBoxFilterOptions.Hint := 'Search in: All';
    lblChckFntOpt.Caption := 'Search in: All';
  end
  else if CheckedCount = 0 then
  begin
    CheckComboBoxFilterOptions.Hint := 'Search in: None';
    lblChckFntOpt.Caption := 'Search in: None';
  end;

  ApplyFilter;
end;

function TJSAnalyzerForm.FunctionMatchesSearchText(NodeData: PTreeNodeData; SearchText: string): boolean;
begin
  Result := False;

  if CheckComboBoxFilterOptions.Checked[0] and (Pos(SearchText, LowerCase(NodeData^.FuncInfo.FileName)) > 0) then
    Result := True
  else if CheckComboBoxFilterOptions.Checked[1] and (Pos(SearchText, LowerCase(NodeData^.FuncInfo.Name)) > 0) then
    Result := True
  else if CheckComboBoxFilterOptions.Checked[2] and Assigned(NodeData^.FuncInfo.Parameters) and (Pos(SearchText, LowerCase(NodeData^.FuncInfo.Parameters.Text)) > 0) then
    Result := True
  else if CheckComboBoxFilterOptions.Checked[3] and (Pos(SearchText, LowerCase(NodeData^.FuncInfo.Description)) > 0) then
    Result := True;
end;

function TJSAnalyzerForm.FunctionMatchesFilterType(NodeData: PTreeNodeData; FilterType: integer): boolean;
begin
  Result := False;
  if not Assigned(NodeData) or (NodeData^.NodeType <> ntFunction) then Exit;

  case FilterType of
    0: Result := True;
    1: Result := not NodeData^.FuncInfo.IsAsync and not NodeData^.FuncInfo.IsArrow and not NodeData^.FuncInfo.IsMethod;
    2: Result := NodeData^.FuncInfo.IsAsync;
    3: Result := NodeData^.FuncInfo.IsArrow;
    4: Result := NodeData^.FuncInfo.IsMethod;
  end;
end;

procedure TJSAnalyzerForm.ApplyFilter;
var
  Node, ChildNode: PVirtualNode;
  NodeData: PTreeNodeData;
  SearchText: string;
  HasVisibleChildren: boolean;
  FileNode: PVirtualNode;
begin
  TreeView1.BeginUpdate;
  try
    SearchText := LowerCase(Trim(TreeFilterEdit1.Text));

    // Reset all nodes to visible first
    Node := TreeView1.GetFirst;
    while Assigned(Node) do
    begin
      TreeView1.IsVisible[Node] := True;
      Node := TreeView1.GetNext(Node);
    end;

    // If no filtering needed, exit early
    if (SearchText = '') and (FCurrentFilterType = 0) then
    begin
      TreeView1.Invalidate;
      Exit;
    end;

    // Filter nodes
    Node := TreeView1.GetFirst;
    while Assigned(Node) do
    begin
      NodeData := PTreeNodeData(TreeView1.GetNodeData(Node));
      if Assigned(NodeData) then
      begin
        if NodeData^.NodeType = ntFunction then
        begin
          // Check function type filter
          if not FunctionMatchesFilterType(NodeData, FCurrentFilterType) then
          begin
            TreeView1.IsVisible[Node] := False;
            Node := TreeView1.GetNext(Node);
            Continue;
          end;

          // Check text search
          if (SearchText <> '') and (not FunctionMatchesSearchText(NodeData, SearchText)) then
          begin
            TreeView1.IsVisible[Node] := False;
            Node := TreeView1.GetNext(Node);
            Continue;
          end;

          TreeView1.IsVisible[Node] := True;
        end;
      end;
      Node := TreeView1.GetNext(Node);
    end;

    // After filtering functions, handle file nodes
    Node := TreeView1.GetFirst;
    while Assigned(Node) do
    begin
      NodeData := PTreeNodeData(TreeView1.GetNodeData(Node));
      if Assigned(NodeData) and (NodeData^.NodeType = ntFile) then
      begin
        HasVisibleChildren := False;
        ChildNode := TreeView1.GetFirstChild(Node);
        while Assigned(ChildNode) do
        begin
          if TreeView1.IsVisible[ChildNode] then
          begin
            HasVisibleChildren := True;
            Break;
          end;
          ChildNode := TreeView1.GetNextSibling(ChildNode);
        end;

        TreeView1.IsVisible[Node] := HasVisibleChildren;
      end;
      Node := TreeView1.GetNext(Node);
    end;

  finally
    TreeView1.EndUpdate;
  end;
end;

procedure TJSAnalyzerForm.SortByNameAscClick(Sender: TObject);
begin
  FSortColumn := 0;
  FSortDirection := 1;
  ApplySorting;
end;

procedure TJSAnalyzerForm.SortByNameDescClick(Sender: TObject);
begin
  FSortColumn := 0;
  FSortDirection := -1;
  ApplySorting;
end;

procedure TJSAnalyzerForm.SortByTypeClick(Sender: TObject);
begin
  FSortColumn := 1;
  FSortDirection := 1;
  ApplySorting;
end;

procedure TJSAnalyzerForm.SortByLinesClick(Sender: TObject);
begin
  FSortColumn := 2;
  FSortDirection := 1;
  ApplySorting;
end;

procedure TJSAnalyzerForm.CompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: integer);
var
  Data1, Data2: PTreeNodeData;
  Type1, Type2: string;
begin
  Data1 := PTreeNodeData(TreeView1.GetNodeData(Node1));
  Data2 := PTreeNodeData(TreeView1.GetNodeData(Node2));

  if (Data1 = nil) or (Data2 = nil) then
  begin
    Result := 0;
    Exit;
  end;

  if (Data1^.NodeType = ntFile) and (Data2^.NodeType <> ntFile) then
    Result := -1
  else if (Data1^.NodeType <> ntFile) and (Data2^.NodeType = ntFile) then
    Result := 1
  else if (Data1^.NodeType = ntFile) and (Data2^.NodeType = ntFile) then
    Result := CompareText(Data1^.DisplayName, Data2^.DisplayName)
  else
  begin
    case FSortColumn of
      0: Result := CompareText(Data1^.FuncInfo.Name, Data2^.FuncInfo.Name);
      1: begin
        if Data1^.FuncInfo.IsAsync then Type1 := 'A'
        else if Data1^.FuncInfo.IsArrow then Type1 := 'R'
        else if Data1^.FuncInfo.IsMethod then Type1 := 'M'
        else
          Type1 := 'F';

        if Data2^.FuncInfo.IsAsync then Type2 := 'A'
        else if Data2^.FuncInfo.IsArrow then Type2 := 'R'
        else if Data2^.FuncInfo.IsMethod then Type2 := 'M'
        else
          Type2 := 'F';

        Result := CompareText(Type1, Type2);
        if Result = 0 then
          Result := CompareText(Data1^.FuncInfo.Name, Data2^.FuncInfo.Name);
      end;
      2: begin
        Result := CompareValue(Data1^.FuncInfo.EndLine - Data1^.FuncInfo.StartLine, Data2^.FuncInfo.EndLine - Data2^.FuncInfo.StartLine);
        if Result = 0 then
          Result := CompareText(Data1^.FuncInfo.Name, Data2^.FuncInfo.Name);
      end;
      else
        Result := CompareText(Data1^.FuncInfo.Name, Data2^.FuncInfo.Name);
    end;

    if FSortDirection < 0 then
      Result := -Result;
  end;
end;

procedure TJSAnalyzerForm.ApplySorting;
begin
  TreeView1.TreeOptions.AutoOptions := TreeView1.TreeOptions.AutoOptions + [toAutoSort];
  TreeView1.SortTree(FSortColumn, VirtualTrees.sdAscending);
end;

//============= FORM TREEVIEW1 ========================

procedure TJSAnalyzerForm.TreeView1GetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  NodeData: PTreeNodeData;
  FuncType: string;
begin
  CellText := '';
  NodeData := PTreeNodeData(TreeView1.GetNodeData(Node));
  if not Assigned(NodeData) then Exit;

  case NodeData^.NodeType of
    ntFile:
    begin
      case Column of
        0: CellText := NodeData^.DisplayName;
        1: CellText := 'File';
        2: CellText := IntToStr(NodeData^.FunctionCount) + ' functions';
        3: CellText := '';
      end;
    end;
    ntFunction:
    begin
      case Column of
        0: CellText := NodeData^.FuncInfo.Name;
        1: begin
          if NodeData^.FuncInfo.IsAsync then
            FuncType := 'async'
          else if NodeData^.FuncInfo.IsArrow then
            FuncType := 'arrow'
          else if NodeData^.FuncInfo.IsMethod then
            FuncType := 'method'
          else
            FuncType := 'function';

          if NodeData^.FuncInfo.ParentClass <> '' then
            CellText := FuncType + ' (' + NodeData^.FuncInfo.ParentClass + ')'
          else
            CellText := FuncType;
        end;
        2: CellText := Format('%d-%d', [NodeData^.FuncInfo.StartLine, NodeData^.FuncInfo.EndLine]);
        3: begin
          if NodeData^.FuncInfo.Description <> '' then
            CellText := Copy(NodeData^.FuncInfo.Description, 1, 100) + '...'
          else
            CellText := '';
        end;
      end;
    end;
  end;
end;

procedure TJSAnalyzerForm.TreeView1GetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: boolean; var ImageIndex: integer);
var
  NodeData: PTreeNodeData;
begin
  ImageIndex := -1;
  if (Column = 0) and (Kind in [ikNormal, ikSelected]) then
  begin
    NodeData := PTreeNodeData(TreeView1.GetNodeData(Node));
    if Assigned(NodeData) then
    begin
      case NodeData^.NodeType of
        ntFile: ImageIndex := 1;
        ntFunction:
        begin
          if NodeData^.FuncInfo.IsAsync then ImageIndex := 3
          else if NodeData^.FuncInfo.IsArrow then ImageIndex := 4
          else if NodeData^.FuncInfo.IsMethod then ImageIndex := 5
          else
            ImageIndex := 6;
        end;
      end;
    end;
  end;
end;

procedure TJSAnalyzerForm.TreeView1FocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
var
  NodeData: PTreeNodeData;
  FileIdx, FuncIdx: integer;
  FileDoc: string;
  HTML: string;  // Declare local variable
begin
  if Node <> nil then
  begin
    NodeData := PTreeNodeData(TreeView1.GetNodeData(Node));
    if Assigned(NodeData) then
    begin
      if NodeData^.NodeType = ntFunction then
      begin
        // Find the actual file and function index
        FileIdx := -1;
        FuncIdx := -1;

        FindFunctionIndices(NodeData^.FuncInfo.Name, NodeData^.FuncInfo.StartLine,
          FileIdx, FuncIdx);
        if (FileIdx >= 0) and (FuncIdx >= 0) then
        begin
          // Generate HTML documentation
          HTML := FDocFormatter.FormatFunctionAsHTML(FFilesInfo[FileIdx].Functions[FuncIdx], FFilesInfo[FileIdx].FileName, FileIdx);
          // Display in browser or HTML viewer
          DisplayHTMLDocumentation(HTML);

          DisplayFunctionInGrid(FileIdx, FuncIdx);
          if PageControl1.ActivePage <> TabSheetFunctions then
            PageControl1.ActivePage := TabSheetFunctions;
        end
        else
        begin
          ClearGrid;
          StringGridFunctions.Visible := False;
          ShowMessage('Function not found in data structure: ' + NodeData^.FuncInfo.Name);
        end;

        // Update other displays if needed
        lblFunctionName.Caption := 'Function: ' + NodeData^.FuncInfo.Name;
        if Assigned(NodeData^.FuncInfo.Parameters) then
          lblParameters.Caption :=
            'Parameters: ' + NodeData^.FuncInfo.Parameters.CommaText
        else
          lblParameters.Caption := 'Parameters: ';
        lblReturnType.Caption := 'Return: ' + NodeData^.FuncInfo.ReturnType;
        lblDescription.Caption :=
          'Description: ' + Copy(NodeData^.FuncInfo.Description, 1, 200);
        lblFileName.Caption := 'File: ' + NodeData^.FuncInfo.FileName;

      end
      else if NodeData^.NodeType = ntFile then
      begin
        ClearGrid;
        //        StringGridFunctions.Visible := False;
        TDebugLogger.Info('NodeData^.NodeType = ntFile', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        lblFunctionName.Caption := 'File: ' + NodeData^.DisplayName;
        lblParameters.Caption := 'Functions: ' + IntToStr(NodeData^.FunctionCount);
        lblReturnType.Caption := '';
        lblDescription.Caption := '';
        lblFileName.Caption := '';
        // Generate file documentation
        HTML := FDocFormatter.FormatFileAsHTML(FFilesInfo[NodeData^.FileIndex]);
        DisplayHTMLDocumentation(HTML);
        TDebugLogger.Info('DisplayFileInGrid(FileIdx);', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        DisplayFileInGrid(NodeData^.FileIndex);

        if PageControl1.ActivePage <> tabEditDocs then
          PageControl1.ActivePage := tabEditDocs;
      end;
    end
    else
    begin
      ClearGrid;
      StringGridFunctions.Visible := False;
    end;
  end
  else
  begin
    StringGridFunctions.Visible := False;
  end;
end;

procedure TJSAnalyzerForm.TreeView1InitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
begin
  // ¡NO intentes inicializar NodeData aquí!
  // VirtualTrees maneja esto internamente
  if ParentNode = nil then
    Include(InitialStates, ivsExpanded);
end;

procedure TJSAnalyzerForm.TreeView1FreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  NodeData: PTreeNodeData;
begin
  NodeData := PTreeNodeData(TreeView1.GetNodeData(Node));
  if Assigned(NodeData) then
  begin
    if NodeData^.NodeType = ntFunction then
      CleanupFunctionInfo(NodeData^.FuncInfo);
    Finalize(NodeData^);
  end;
end;

procedure TJSAnalyzerForm.FilterEdit1AfterFilter(Sender: TObject);
begin
  TreeView1.Invalidate;
end;

procedure TJSAnalyzerForm.TreeViewGlobalsFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin

end;

procedure TJSAnalyzerForm.PopulateTreeViews;
var
  FileIdx, FuncIdx: integer;
  RootNode, TemplateNode, ProjectNode, FileNode, FuncNode: PVirtualNode;
  NodeData: PTreeNodeData;
begin
  TreeView1.BeginUpdate;
  try
    TreeView1.Clear;

    RootNode := TreeView1.AddChild(nil);
    NodeData := TreeView1.GetNodeData(RootNode);
    if Assigned(NodeData) and (High(FFilesInfo) > 0) then
    begin
      NodeData^.NodeType := ntFile;
      NodeData^.DisplayName := 'JavaScript Analysis';
      NodeData^.FunctionCount := GetTotalFunctionCount();
    end;


    TemplateNode := TreeView1.AddChild(RootNode);
    NodeData := TreeView1.GetNodeData(TemplateNode);
    if Assigned(NodeData) then
    begin
      NodeData^.NodeType := ntFile;
      NodeData^.DisplayName := 'Templates';
      NodeData^.FunctionCount := 0;
    end;

    ProjectNode := TreeView1.AddChild(RootNode);
    NodeData := TreeView1.GetNodeData(ProjectNode);
    if Assigned(NodeData) then
    begin
      NodeData^.NodeType := ntFile;
      NodeData^.DisplayName := 'Working';
      NodeData^.FunctionCount := 0;
    end;

    for FileIdx := 0 to High(FFilesInfo) do
    begin
      if Pos('[Templates]', FFilesInfo[FileIdx].FileName) > 0 then
      begin
        FileNode := TreeView1.AddChild(TemplateNode);
        NodeData := TreeView1.GetNodeData(TemplateNode);
        if Assigned(NodeData) then
          NodeData^.FunctionCount :=
            NodeData^.FunctionCount + Length(FFilesInfo[FileIdx].Functions);
      end
      else
      begin
        FileNode := TreeView1.AddChild(ProjectNode);
        NodeData := TreeView1.GetNodeData(ProjectNode);
        if Assigned(NodeData) then
          NodeData^.FunctionCount :=
            NodeData^.FunctionCount + Length(FFilesInfo[FileIdx].Functions);
      end;

      NodeData := TreeView1.GetNodeData(FileNode);
      if Assigned(NodeData) then
      begin
        NodeData^.NodeType := ntFile;
        NodeData^.DisplayName := FFilesInfo[FileIdx].FileName;
        NodeData^.FileIndex := FileIdx;
        NodeData^.FunctionCount := Length(FFilesInfo[FileIdx].Functions);
      end;

      for FuncIdx := 0 to High(FFilesInfo[FileIdx].Functions) do
      begin
        FuncNode := TreeView1.AddChild(FileNode);
        NodeData := TreeView1.GetNodeData(FuncNode);
        if Assigned(NodeData) then
        begin
          NodeData^.NodeType := ntFunction;
          NodeData^.DisplayName := FFilesInfo[FileIdx].Functions[FuncIdx].Name;
          NodeData^.FuncInfo := FFilesInfo[FileIdx].Functions[FuncIdx];
          NodeData^.FuncInfo.Parameters := TStringList.Create;
          NodeData^.FuncInfo.Parameters.Assign(
            FFilesInfo[FileIdx].Functions[FuncIdx].Parameters);
          NodeData^.FuncInfo.Calls := TStringList.Create;
          NodeData^.FuncInfo.Calls.Assign(FFilesInfo[FileIdx].Functions[FuncIdx].Calls);
          NodeData^.FuncInfo.CalledBy := TStringList.Create;
          NodeData^.FuncInfo.CalledBy.Assign(
            FFilesInfo[FileIdx].Functions[FuncIdx].CalledBy);
        end;
      end;
    end;

    TreeView1.Expanded[RootNode] := True;
    TreeView1.Expanded[TemplateNode] := True;
    TreeView1.Expanded[ProjectNode] := True;

  finally
    TreeView1.EndUpdate;
  end;
  ApplyFilter;
end;

procedure TJSAnalyzerForm.UpdateTreeViewNode(FileIdx, FuncIdx: integer);
var
  Node: PVirtualNode;
  ChildNode: PVirtualNode;
  NodeData: PTreeNodeData;
  FuncInfo: TJSFunctionInfo;
begin
  TDebugLogger.Info('UpdateTreeViewNode', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  if (FileIdx < 0) or (FileIdx > High(FFilesInfo)) then Exit;
  if (FuncIdx < 0) or (FuncIdx > High(FFilesInfo[FileIdx].Functions)) then Exit;

  FuncInfo := FFilesInfo[FileIdx].Functions[FuncIdx];

  Node := TreeView1.GetFirst;
  while Assigned(Node) do
  begin
    NodeData := PTreeNodeData(TreeView1.GetNodeData(Node));
    if Assigned(NodeData) and (NodeData^.NodeType = ntFile) and (NodeData^.FileIndex = FileIdx) then
    begin
      ChildNode := TreeView1.GetFirstChild(Node);
      while Assigned(ChildNode) do
      begin
        NodeData := PTreeNodeData(TreeView1.GetNodeData(ChildNode));
        if Assigned(NodeData) and (NodeData^.NodeType = ntFunction) and (NodeData^.FuncInfo.Name = FuncInfo.Name) and (NodeData^.FuncInfo.StartLine = FuncInfo.StartLine) then
        begin
          NodeData^.FuncInfo.Description := FuncInfo.Description;
          NodeData^.FuncInfo.ReturnType := FuncInfo.ReturnType;
          if Assigned(NodeData^.FuncInfo.Parameters) and Assigned(FuncInfo.Parameters) then
            NodeData^.FuncInfo.Parameters.Assign(FuncInfo.Parameters);

          TreeView1.InvalidateNode(ChildNode);
          Break;
        end;
        ChildNode := TreeView1.GetNextSibling(ChildNode);
      end;
      Break;
    end;
    Node := TreeView1.GetNext(Node);
  end;
end;

//============= GLOBALS TREEVIEW ========================

procedure TJSAnalyzerForm.TreeViewGlobalsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  GlobalVar: PJSGlobalVar;
begin
  GlobalVar := PJSGlobalVar(TreeViewGlobals.GetNodeData(Node));
  if Assigned(GlobalVar) then
  begin
    case Column of
      0: CellText := GlobalVar^.Name;
      1: CellText := GlobalVar^.VarType;
      2: CellText := GlobalVar^.Value;
      3: CellText := IntToStr(GlobalVar^.Line);
      4: CellText := GlobalVar^.Description;
    end;
  end;
end;

procedure TJSAnalyzerForm.TreeViewGlobalsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: boolean; var ImageIndex: integer);
var
  GlobalVar: PJSGlobalVar;
begin
  ImageIndex := -1;
  if (Column = 0) and (Kind in [ikNormal, ikSelected]) then
  begin
    GlobalVar := PJSGlobalVar(TreeViewGlobals.GetNodeData(Node));
    if Assigned(GlobalVar) then
    begin
      if GlobalVar^.VarType = 'file' then
        ImageIndex := 1
      else
      begin
        case GlobalVar^.VarType of
          'const': ImageIndex := 20;
          'let': ImageIndex := 21;
          'var': ImageIndex := 22;
          else
            ImageIndex := 23;
        end;
      end;
    end;
  end;
end;

procedure TJSAnalyzerForm.TreeViewGlobalsFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
var
  GlobalVar: PJSGlobalVar;
  FileName: string;
  HTML: string;  // Declare local variable
begin
  TDebugLogger.Info('TreeViewGlobalsFocusChanged', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  if Node <> nil then
  begin
    GlobalVar := PJSGlobalVar(TreeViewGlobals.GetNodeData(Node));
    TDebugLogger.InfoFmt('FileName: %s', [GlobalVar^.Name], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    FileName := GlobalVar^.Name;
    if Assigned(GlobalVar) and (GlobalVar^.VarType <> 'file') then
    begin
      if FileName <> '' then
      begin
        TDebugLogger.Info('***********************************************', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        TDebugLogger.InfoFmt('iGlobalVar.Name: %s', [GlobalVar^.Name], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        TDebugLogger.InfoFmt('GlobalVar.VarType: %s', [GlobalVar^.VarType], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        TDebugLogger.InfoFmt('GlobalVar.Value: %s', [GlobalVar^.Value], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        TDebugLogger.InfoFmt('GlobalVar.Line: %d', [GlobalVar^.Line], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        TDebugLogger.InfoFmt('GlobalVar.Description: %s', [GlobalVar^.Description], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

        HTML := FDocFormatter.FormatGlobalVarAsHTML(GlobalVar^, FileName);
        DisplayHTMLDocumentation(HTML);
      end;
    end;
  end;
end;

function TJSAnalyzerForm.FindFileForGlobalVar(const GlobalVar: TJSGlobalVar): string;
var
  I, J: integer;
begin
  Result := '';
  for I := 0 to High(FFilesInfo) do
  begin
    for J := 0 to High(FFilesInfo[I].GlobalVars) do
    begin
      if (FFilesInfo[I].GlobalVars[J].Name = GlobalVar.Name) and (FFilesInfo[I].GlobalVars[J].Line = GlobalVar.Line) then
      begin
        Result := FFilesInfo[I].FileName;
        Exit;
      end;
    end;
  end;
end;

procedure TJSAnalyzerForm.PopulateGlobalsTree;
var
  FileIdx, VarIdx: integer;
  FileNode, VarNode: PVirtualNode;
  GlobalVarData: PJSGlobalVar;
begin
  TreeViewGlobals.BeginUpdate;
  try
    TreeViewGlobals.Clear;

    for FileIdx := 0 to High(FFilesInfo) do
    begin
      if Length(FFilesInfo[FileIdx].GlobalVars) = 0 then Continue;

      FileNode := TreeViewGlobals.AddChild(nil);
      GlobalVarData := TreeViewGlobals.GetNodeData(FileNode);

      GlobalVarData^.Name := FFilesInfo[FileIdx].FileName;
      GlobalVarData^.VarType := 'file';
      GlobalVarData^.Value := '';
      GlobalVarData^.Line := 0;
      GlobalVarData^.Description :=
        Format('%d global variables', [Length(FFilesInfo[FileIdx].GlobalVars)]);

      for VarIdx := 0 to High(FFilesInfo[FileIdx].GlobalVars) do
      begin
        VarNode := TreeViewGlobals.AddChild(FileNode);
        GlobalVarData := TreeViewGlobals.GetNodeData(VarNode);
        GlobalVarData^ := FFilesInfo[FileIdx].GlobalVars[VarIdx];
      end;

      TreeViewGlobals.Expanded[FileNode] := True;
    end;

  finally
    TreeViewGlobals.EndUpdate;
  end;
end;

//============= CALLS TREEVIEW ========================

procedure TJSAnalyzerForm.BuildCallGraph;
begin
  // TODO: Implement call graph building
end;

//============= ANALYSIS ========================

procedure TJSAnalyzerForm.RefreshAnalysis;
var
  TemplateCount, ProjectCount: integer;
  I: integer;
begin
  TDebugLogger.Info('  RefreshAnalysis', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TreeView1.Clear;
  treeCalls.Clear;
  TreeViewGlobals.Clear;
  ClearGridData;

  // Clean up existing file info
  for I := 0 to High(FFilesInfo) do
    CleanupFileInfo(FFilesInfo[I]);
  SetLength(FFilesInfo, 0);
  TDebugLogger.InfoFmt('  Assigned(FProject) %s', [BoolToYesNo(Assigned(FProject))], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  if Assigned(FProject) then
  begin
    LoadTemplatesJSFiles;
    TemplateCount := 0;
    ProjectCount := 0;
    for I := 0 to High(FFilesInfo) do
    begin
      if Pos('[Templates]', FFilesInfo[I].FileName) > 0 then
        Inc(TemplateCount)
      else
        Inc(ProjectCount);
    end;
    if High(FFilesInfo) > 0 then
    begin
      PopulateTreeViews;
      PopulateGlobalsTree;
      BuildCallGraph;
    end;
  end;
  lblFunctionCount.Caption :=
    Format('%d functions found (%d template files, %d project files)', [GetTotalFunctionCount(), TemplateCount, ProjectCount]);
  TDebugLogger.InfoFmt('RefreshAnalysis - %s', [lblFunctionCount.Caption], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
end;

procedure TJSAnalyzerForm.CleanupFunctionInfo(var FuncInfo: TJSFunctionInfo);
begin
  TJSParser.CleanupFunctionInfo(FuncInfo);
end;

procedure TJSAnalyzerForm.CleanupFileInfo(var FileInfo: TJSFileInfo);
begin
  TJSParser.CleanupFileInfo(FileInfo);
end;

procedure TJSAnalyzerForm.LoadTemplatesJSFiles;
var
  JSDir: string;
begin
  if not Assigned(FProject) then Exit;

  // Load from templates directory
  JSDir := IncludeTrailingPathDelimiter(FProject.TemplatePath) + 'js' + PathDelim;
  LoadJSFilesFromDirectory(JSDir, True);

  // Load from project directory
  JSDir := IncludeTrailingPathDelimiter(FProject.WorkingPath) + 'js' + PathDelim;
  LoadJSFilesFromDirectory(JSDir, False);
end;

procedure TJSAnalyzerForm.LoadJSFilesFromDirectory(const DirPath: string; IsTemplate: boolean);
var
  SearchRec: TSearchRec;
  FilePath: string;
  TempFilesInfo: array of TJSFileInfo;
  TempFileCount: integer;
begin
  TDebugLogger.InfoFmt('  LoadJSFilesFromDirectory called for: %s', [DirPath], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  if not DirectoryExists(DirPath) then
  begin
    TDebugLogger.InfoFmt('  ERROR: Directory does not exist:: %s', [DirPath], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    Exit;
  end;

  if FindFirst(DirPath + PathDelim + '*.js', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        if (SearchRec.Attr and faDirectory) <> 0 then
        begin
          Continue;
        end;

        //        FilePath := DirPath + PathDelim + SearchRec.Name;
        FilePath := DirPath + SearchRec.Name;
        // Use the parser to analyze the file
        SetLength(TempFilesInfo, 1);
        TempFileCount := 0;
        TJSParser.AnalyzeJavaScriptFile(FilePath, IsTemplate,
          TempFilesInfo, TempFileCount);

        // Add to main array if successful
        if TempFileCount > 0 then
        begin
          SetLength(FFilesInfo, Length(FFilesInfo) + 1);
          FFilesInfo[High(FFilesInfo)] := TempFilesInfo[0];
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end
  else
  begin
    TDebugLogger.InfoFmt('  ERROR: FindFirst failed. Error code: %s', [SysErrorMessage(GetLastOSError)], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    if FindFirst(DirPath + PathDelim + '*.*', faAnyFile, SearchRec) = 0 then
    begin
      try
        repeat
        until FindNext(SearchRec) <> 0;
      finally
        FindClose(SearchRec);
      end;
    end;
  end;
end;

procedure TJSAnalyzerForm.AnalyzeJavaScriptFile(const FilePath: string; IsTemplate: boolean);
var
  TempFilesInfo: array of TJSFileInfo;
  TempFileCount: integer;
begin
  // This is now just a wrapper around the parser
  SetLength(TempFilesInfo, 1);
  TempFileCount := 0;
  TJSParser.AnalyzeJavaScriptFile(FilePath, IsTemplate, TempFilesInfo, TempFileCount);

  if TempFileCount > 0 then
  begin
    SetLength(FFilesInfo, Length(FFilesInfo) + 1);
    FFilesInfo[High(FFilesInfo)] := TempFilesInfo[0];
  end;
end;

function TJSAnalyzerForm.GetTotalFunctionCount: integer;
var
  I: integer;
begin
  Result := 0;
  for I := 0 to High(FFilesInfo) do
    Result := Result + Length(FFilesInfo[I].Functions);
end;

procedure TJSAnalyzerForm.UpdateFunctionDetails(FileIndex, FuncIndex: integer);
begin
  // TODO: Implement function details display
end;

procedure TJSAnalyzerForm.FindExistingComment(Lines: TStringList; FuncStart: integer; out CommentStartLine, CommentEndLine: integer; out HasComment: boolean);
var
  I: integer;
begin
  TDebugLogger.Info('  FindExistingComment', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  CommentStartLine := -1;
  CommentEndLine := -1;
  HasComment := False;

  I := FuncStart - 1;
  while (I >= 0) and (Trim(Lines[I]) = '') do
    Dec(I);

  if I < 0 then Exit;

  if Pos('*/', Lines[I]) > 0 then
  begin
    CommentEndLine := I;
    while (I >= 0) and (Pos('/**', Lines[I]) = 0) and (Pos('/*', Lines[I]) = 0) do
      Dec(I);

    if I >= 0 then
    begin
      CommentStartLine := I;
      HasComment := True;
    end;
  end
  else if (Pos('/**', Lines[I]) > 0) or (Pos('/*', Lines[I]) > 0) then
  begin
    CommentStartLine := I;
    while (I < Lines.Count) and (Pos('*/', Lines[I]) = 0) do
      Inc(I);

    if I < Lines.Count then
    begin
      CommentEndLine := I;
      HasComment := True;
    end;
  end;
end;

procedure TJSAnalyzerForm.ParseParameterString(const ParamStr: string; out ParamName, ParamType, ParamDesc: string);
begin
  TDebugLogger.Info('  ParseParameterString', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TJSParser.ParseParameterString(ParamStr, ParamName, ParamType, ParamDesc);
end;

function TJSAnalyzerForm.FormatParameterString(const ParamName, ParamType, ParamDesc: string): string;
begin
  TDebugLogger.Info('FormatParameterString', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  Result := TJSParser.FormatParameterString(ParamName, ParamType, ParamDesc);
end;

procedure TJSAnalyzerForm.FindFunctionIndices(const FuncName: string; StartLine: integer; out FileIdx, FuncIdx: integer);
var
  I, J: integer;
begin
  TDebugLogger.Info('FormatParameterString', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  FileIdx := -1;
  FuncIdx := -1;

  for I := 0 to High(FFilesInfo) do
  begin
    for J := 0 to High(FFilesInfo[I].Functions) do
    begin
      if (FFilesInfo[I].Functions[J].Name = FuncName) and (FFilesInfo[I].Functions[J].StartLine = StartLine) then
      begin
        FileIdx := I;
        FuncIdx := J;
        Exit;
      end;
    end;
  end;

  if (FileIdx = -1) then
  begin
    for I := 0 to High(FFilesInfo) do
    begin
      for J := 0 to High(FFilesInfo[I].Functions) do
      begin
        if FFilesInfo[I].Functions[J].Name = FuncName then
        begin
          FileIdx := I;
          FuncIdx := J;
          Exit;
        end;
      end;
    end;
  end;
end;

//============= GRIDS ========================

//============= FUNCTIONS GRID ========================

procedure TJSAnalyzerForm.ClearGridData;
var
  I: integer;
begin
  TDebugLogger.Info('ClearGridData', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  for I := 1 to StringGridFunctions.RowCount - 1 do
  begin
    StringGridFunctions.Objects[0, I] := nil;
    StringGridFunctions.Objects[1, I] := nil;
    StringGridFunctions.Objects[2, I] := nil;
    StringGridFunctions.Objects[3, I] := nil;
    StringGridFunctions.Objects[4, I] := nil;
  end;
  StringGridFunctions.RowCount := 1;
end;

procedure TJSAnalyzerForm.StringGridFunctionsSelectCell(Sender: TObject; ACol, ARow: integer; var CanSelect: boolean);
var
  CellData: TGridCellData;
begin
  TDebugLogger.Info('StringGridFunctionsSelectCell', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  // If editing is disabled globally, don't allow selection
  if not (goEditing in StringGridFunctions.Options) then
  begin
    CanSelect := False;
    Exit;
  end;

  // Original logic for function cells
  if (ARow < 1) or (ARow >= StringGridFunctions.RowCount) then
  begin
    CanSelect := False;
    Exit;
  end;

  CellData := TGridCellData(StringGridFunctions.Objects[Acol, ARow]);
  if Assigned(CellData) then
  begin
    TDebugLogger.Info('Assigned', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    CanSelect := CellData.EditType in [1, 2, 3, 4, 5, 6, 7]; // Only editable cell types
    if CanSelect then     TDebugLogger.Info('CanSelect', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  end
  else
  begin
    CanSelect := False; // No cell data = read-only
  end;
end;

procedure TJSAnalyzerForm.StringGridFunctionsSetEditText(Sender: TObject; ACol, ARow: integer; const Value: string);
var
  CellData: TGridCellData;
  FuncInfo: TJSFunctionInfo;
  ParamName: string;
begin
  TDebugLogger.Info('StringGridFunctionsSetEditText', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  if (ARow < 1) then Exit;

  CellData := TGridCellData(StringGridFunctions.Objects[Acol, ARow]);
  if not Assigned(CellData) then Exit;

  if (CellData.FileIdx < 0) or (CellData.FileIdx > High(FFilesInfo)) then Exit;
  if (CellData.FuncIdx < 0) or (CellData.FuncIdx > High(FFilesInfo[CellData.FileIdx].Functions)) then Exit;

  FuncInfo := FFilesInfo[CellData.FileIdx].Functions[CellData.FuncIdx];
  TDebugLogger.InfoFmt(' Case %d Value %s', [CellData.EditType, Value], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  case CellData.EditType of
    0: Exit;
    1: // Description
    begin
      FuncInfo.Description := Value;
    end;
    2: // Return type
    begin
        FuncInfo.ReturnType := Value
    end;
    3: // Parameter type
    begin
      if ACol = 3 then
      begin
        if Assigned(FuncInfo.Parameters) and (CellData.ParamIdx >= 0) and (CellData.ParamIdx < FuncInfo.Parameters.Count) then
        begin
          TDebugLogger.InfoFmt(' Case %d Value %s ParamIdx %d', [CellData.EditType, Value, CellData.ParamIdx], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
          FuncInfo.Parameters[CellData.ParamIdx] := Value;
        end;
      end
      else if ACol = 4 then
      begin
        if Assigned(FuncInfo.Parameters) and (CellData.ParamIdx >= 0) and (CellData.ParamIdx < FuncInfo.Parameters.Count) then
        begin
          ParamName := ExtractParamName(FuncInfo.Parameters[CellData.ParamIdx]);
//          UpdateParamDescriptionInJSDoc(FuncInfo, ParamName, Value);
        end;
      end;
    end;
    4: TDebugLogger.Info('ReturnType EDIT', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    5: TDebugLogger.Info('ReturnDesc EDIT', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    6: TDebugLogger.Info('Summary EDIT', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    7: TDebugLogger.Info('Example EDIT', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  end;

  FFilesInfo[CellData.FileIdx].Functions[CellData.FuncIdx] := FuncInfo;

  CellData.IsDirty := True;

  btnSaveFunction.Visible := True;
  btnCancelEdit.Visible := True;

  if Assigned(StatusBar1) then
    StatusBar1.SimpleText := 'Changes made - click Save to apply';
end;

procedure TJSAnalyzerForm.DisplayFunctionInGrid(FileIdx, FuncIdx: integer);
var
  FuncInfo: TJSFunctionInfo;
  Row: integer;
  I: integer;
  CellData: TGridCellData;
  ParamName, ParamDesc, ReturnDesc: string;
begin
  TDebugLogger.Info('DisplayFunctionInGrid', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  ClearGrid;
  if (FileIdx < 0) or (FileIdx > High(FFilesInfo)) then
  begin
    StringGridFunctions.Visible := False;
    Exit;
  end;

  if (FuncIdx < 0) or (FuncIdx > High(FFilesInfo[FileIdx].Functions)) then
  begin
    StringGridFunctions.Visible := False;
    Exit;
  end;

  FuncInfo := FFilesInfo[FileIdx].Functions[FuncIdx];

  StringGridFunctions.BeginUpdate;

  FEditingFileIdx := FileIdx;
  FEditingFuncIdx := FuncIdx;
  FIsEditing := True;

  btnSaveFunction.Visible := False;
  btnCancelEdit.Visible := False;

  try
    // ENABLE EDITING for function grid
    StringGridFunctions.Options := StringGridFunctions.Options + [goEditing];
    if Assigned(FuncInfo.Parameters) and (FuncInfo.Parameters.Count > 0) then
      StringGridFunctions.RowCount := 1 + 6 + 1 + FuncInfo.Parameters.Count
    else
      StringGridFunctions.RowCount := 1 + 6;

    for Row := 1 to StringGridFunctions.RowCount - 1 do
    begin
      if Assigned(StringGridFunctions.Objects[0, Row]) then
        TGridCellData(StringGridFunctions.Objects[0, Row]).Free;
      StringGridFunctions.Objects[0, Row] := nil;
      StringGridFunctions.Cells[0, Row] := '';
      StringGridFunctions.Cells[1, Row] := '';
      StringGridFunctions.Cells[2, Row] := '';
      StringGridFunctions.Cells[3, Row] := '';
      StringGridFunctions.Cells[4, Row] := '';
    end;
    TDebugLogger.Info('***********************************************', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

    //Code preview
    memoCodePreview.Lines.Clear;
    memoCodePreview.Lines := FuncInfo.Code;

    Row := 1;
    TDebugLogger.InfoFmt('FuncInfo.Name: %s', [FuncInfo.Name], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    TDebugLogger.DebugFmt('FuncInfo.Summary: %s', [FuncInfo.Summary], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    TDebugLogger.DebugFmt('GetFunctionTypeString(FuncInfo): %s', [GetFunctionTypeString(FuncInfo)], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    // Row 1: Function Name, summary and type
    StringGridFunctions.Cells[0, Row] := 'Function';
    StringGridFunctions.Cells[2, Row] := FuncInfo.Name;
    StringGridFunctions.Cells[3, Row] := GetFunctionTypeString(FuncInfo);
    if FuncInfo.Description <> '' then
    begin
      StringGridFunctions.Cells[4, Row] := FuncInfo.Description;
      CellData := TGridCellData.Create(1, FileIdx, FuncIdx, -1);
      StringGridFunctions.Objects[4, Row] := CellData;
    end;
    Inc(Row);

    TDebugLogger.DebugFmt('FuncInfo.ReturnType: %s', [FuncInfo.ReturnType], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    TDebugLogger.DebugFmt('FuncInfo.ReturnDesc: %s', [FuncInfo.ReturnDesc], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    TDebugLogger.DebugFmt('FuncInfo.Description: %s', [FuncInfo.Description], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    TDebugLogger.DebugFmt('FuncInfo.ExampleCode: %s', [FuncInfo.ExampleCode], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    TDebugLogger.DebugFmt('FuncInfo.ReturnExample: %s', [FuncInfo.ReturnExample], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});


    // Row 2: File (read-only)
    StringGridFunctions.Cells[0, Row] := 'File';
    StringGridFunctions.Cells[1, Row] := FFilesInfo[FileIdx].FileName;
    Inc(Row);

    // Row 3: Location (read-only)
    StringGridFunctions.Cells[0, Row] := 'Location';
    StringGridFunctions.Cells[1, Row] :=
      Format('Lines %d-%d', [FuncInfo.StartLine + 1, FuncInfo.EndLine + 1]);
    Inc(Row);

    // Row 4: Return Type (editable)
    StringGridFunctions.Cells[0, Row] := 'Return Type';
    StringGridFunctions.Cells[3, Row] := FuncInfo.ReturnType;
    CellData := TGridCellData.Create(2, FileIdx, FuncIdx, -1);
    StringGridFunctions.Objects[3, Row] := CellData;
    StringGridFunctions.Cells[4, Row] := FuncInfo.ReturnDesc;
    CellData := TGridCellData.Create(5, FileIdx, FuncIdx, -1);
    StringGridFunctions.Objects[4, Row] := CellData;
    Inc(Row);

    if Assigned(FuncInfo.ParamData) and (Length(FuncInfo.ParamData) > 0) then
    begin
      StringGridFunctions.Cells[0, Row] := 'Parameters';
      StringGridFunctions.Cells[1, Row] := '';
      StringGridFunctions.Cells[2, Row] := '';
      Inc(Row);

      for I := 0 to FuncInfo.Parameters.Count - 1 do
      begin
        ParamName := TJSParser.ExtractParamName(FuncInfo.Parameters[I]);
        ParamDesc := TJSParser.ExtractParamDescriptionFromComment(FuncInfo.Description, ParamName);
        if FuncInfo.ParamData <> nil then
        begin
          TDebugLogger.DebugFmt('FuncInfo.ParamData[%d].pName: %s', [I, FuncInfo.ParamData[I].pName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
          TDebugLogger.DebugFmt('FuncInfo.ParamData[%d].pType: %s', [I, FuncInfo.ParamData[I].pType], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
          TDebugLogger.DebugFmt('FuncInfo.ParamData[%d].pValue: %s', [I, FuncInfo.ParamData[I].pValue], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
          TDebugLogger.DebugFmt('FuncInfo.ParamData[%d].pDesc: %s', [I, FuncInfo.ParamData[I].pDesc], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

          StringGridFunctions.Cells[0, Row] := Format('  Parameter %d', [I + 1]);
          StringGridFunctions.Cells[1, Row] := FuncInfo.ParamData[I].pValue;
          StringGridFunctions.Cells[2, Row] := FuncInfo.ParamData[I].pName;

          StringGridFunctions.Cells[3, Row] := FuncInfo.ParamData[I].pType;
          CellData := TGridCellData.Create(3, FileIdx, FuncIdx, I);
          StringGridFunctions.Objects[0, Row] := CellData;

          StringGridFunctions.Cells[4, Row] := FuncInfo.ParamData[I].pDesc;
          CellData := TGridCellData.Create(3, FileIdx, FuncIdx, I);
          StringGridFunctions.Objects[0, Row] := CellData;
          Inc(Row);
        end;
      end;
    end;

    StringGridFunctions.Cells[0, Row] := 'Example';
    StringGridFunctions.Cells[1, Row] := FuncInfo.ReturnExample;
    StringGridFunctions.Cells[4, Row] := FuncInfo.ExampleCode;
    CellData := TGridCellData.Create(7, FileIdx, FuncIdx, -1);
    StringGridFunctions.Objects[0, Row] := CellData;

    StringGridFunctions.Visible := True;
    StringGridFunctions.Invalidate;
  finally
    StringGridFunctions.EndUpdate;
  end;
end;

function TJSAnalyzerForm.GetFunctionTypeString(const FuncInfo: TJSFunctionInfo): string;
begin
  TDebugLogger.Info('  GetFunctionTypeString', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  if FuncInfo.IsAsync then
    Result := 'Async Function'
  else if FuncInfo.IsArrow then
    Result := 'Arrow Function'
  else if FuncInfo.IsMethod then
    Result := 'Class Method'
  else
    Result := 'Function';

  if FuncInfo.ParentClass <> '' then
    Result := Result + ' of ' + FuncInfo.ParentClass;
end;

procedure TJSAnalyzerForm.btnSaveFunctionClick(Sender: TObject);
var
  FuncInfo: TJSFunctionInfo;
  FilePath: string;
  I: integer;
  CellData: TGridCellData;
  HasChanges: boolean;
  JSDocLines: TStringList;
begin
  TDebugLogger.Info('btnSaveFunctionClick', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  if not FIsEditing then Exit;

  if (FEditingFileIdx < 0) or (FEditingFileIdx > High(FFilesInfo)) then Exit;
  if (FEditingFuncIdx < 0) or (FEditingFuncIdx > High(FFilesInfo[FEditingFileIdx].Functions)) then Exit;

  HasChanges := False;

  // Check for changes
  for I := 1 to StringGridFunctions.RowCount - 1 do
  begin
    CellData := TGridCellData(StringGridFunctions.Objects[0, I]);
    if Assigned(CellData) and (CellData.FileIdx = FEditingFileIdx) and (CellData.FuncIdx = FEditingFuncIdx) and CellData.IsDirty then
    begin
      HasChanges := True;
      Break;
    end;
  end;

  if not HasChanges then
  begin
    ShowMessage('No changes to save.');
    Exit;
  end;

  FuncInfo := FFilesInfo[FEditingFileIdx].Functions[FEditingFuncIdx];
  FilePath := FFilesInfo[FEditingFileIdx].FilePath;

  try
    // **REUSE**: Use the existing parser method to update function info from grid
    UpdateFunctionInfoFromGrid(FEditingFileIdx, FEditingFuncIdx, FuncInfo);

    // **REUSE**: Use existing method to save documentation
    SaveFunctionDocumentation(FilePath, FuncInfo);

    // Update the in-memory structure
    FFilesInfo[FEditingFileIdx].Functions[FEditingFuncIdx] := FuncInfo;

    // Clear dirty flags
    for I := 1 to StringGridFunctions.RowCount - 1 do
    begin
      CellData := TGridCellData(StringGridFunctions.Objects[0, I]);
      if Assigned(CellData) and (CellData.FileIdx = FEditingFileIdx) and (CellData.FuncIdx = FEditingFuncIdx) then
      begin
        CellData.IsDirty := False;
      end;
    end;

    // **REUSE**: Use existing method to update tree view
    UpdateTreeViewNode(FEditingFileIdx, FEditingFuncIdx);

    // **REUSE**: Refresh the display using existing method
    // Instead of calling DisplayFunctionInGrid again, just update the info panel
    // The grid already shows the latest data since we edited it

    btnSaveFunction.Visible := False;
    btnCancelEdit.Visible := False;
    FIsEditing := False;

    ShowMessage('Changes saved to ' + ExtractFileName(FilePath));

    if Assigned(StatusBar1) then
      StatusBar1.SimpleText := 'Changes saved successfully';

  except
    on E: Exception do
    begin
      ShowMessage('Error saving changes: ' + E.Message);
    end;
  end;
end;

procedure TJSAnalyzerForm.btnCancelEditClick(Sender: TObject);
var
  I: integer;
  CellData: TGridCellData;
begin
  // Reload the current function from the data structure
  if (FEditingFileIdx >= 0) and (FEditingFuncIdx >= 0) then
  begin
    // **REUSE**: Just redisplay the function using existing method
    DisplayFunctionInGrid(FEditingFileIdx, FEditingFuncIdx);

    // Clear dirty flags
    for I := 1 to StringGridFunctions.RowCount - 1 do
    begin
      CellData := TGridCellData(StringGridFunctions.Objects[0, I]);
      if Assigned(CellData) and CellData.IsDirty then
      begin
        CellData.IsDirty := False;
      end;
    end;
  end;

  btnSaveFunction.Visible := False;
  btnCancelEdit.Visible := False;
  FIsEditing := False;

  if Assigned(StatusBar1) then
    StatusBar1.SimpleText := 'Changes cancelled';

  ShowMessage('Changes discarded.');
end;

procedure TJSAnalyzerForm.UpdateFunctionInfoFromGrid(FileIdx, FuncIdx: integer; var FuncInfo: TJSFunctionInfo);
var
  I, Row: integer;
  CellData: TGridCellData;
  ParamName, ParamType, ParamDesc: string;
  JSDocLines: TStringList;
begin
  TDebugLogger.Info('UpdateFunctionInfoFromGrid', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  if (FileIdx < 0) or (FileIdx > High(FFilesInfo)) then Exit;
  if (FuncIdx < 0) or (FuncIdx > High(FFilesInfo[FileIdx].Functions)) then Exit;

  JSDocLines := TStringList.Create;
  try
    // **REUSE**: Start with the parser's JSDoc generation method
    TJSParser.GenerateJSDocComment(FuncInfo, JSDocLines);

    // But we need to customize it with grid data
    // Clear and rebuild with actual grid data
    JSDocLines.Clear;
    JSDocLines.Add('/**');

    // Extract description from grid (row with EditType = 1)
    Row := 1;
    while Row < StringGridFunctions.RowCount do
    begin
      CellData := TGridCellData(StringGridFunctions.Objects[0, Row]);
      if Assigned(CellData) and (CellData.FileIdx = FileIdx) and (CellData.FuncIdx = FuncIdx) and (CellData.EditType = 1) then
      begin
        FuncInfo.Description := StringGridFunctions.Cells[1, Row];
        if FuncInfo.Description <> '' then
        begin
          JSDocLines.Add(' * ' + FuncInfo.Description);
          JSDocLines.Add(' *');
        end;
        Break;
      end;
      Inc(Row);
    end;

    // Extract and update parameters from grid
    if not Assigned(FuncInfo.Parameters) then
      FuncInfo.Parameters := TStringList.Create
    else
      FuncInfo.Parameters.Clear;

    Row := 1;
    while Row < StringGridFunctions.RowCount do
    begin
      CellData := TGridCellData(StringGridFunctions.Objects[0, Row]);
      if Assigned(CellData) and (CellData.FileIdx = FileIdx) and (CellData.FuncIdx = FuncIdx) and (CellData.EditType = 3) then
      begin
        // **REUSE**: Use parser's parameter parsing methods
        TJSParser.ParseParameterString(StringGridFunctions.Cells[1, Row],
          ParamName, ParamType, ParamDesc);

        // Use description from JSDoc column if available
        if StringGridFunctions.Cells[2, Row] <> '' then
          ParamDesc := StringGridFunctions.Cells[2, Row];

        // **REUSE**: Format parameter using parser
        FuncInfo.Parameters.Add(
          TJSParser.FormatParameterString(ParamName, ParamType, ParamDesc));

        // Add to JSDoc
        if ParamDesc <> '' then
          JSDocLines.Add(' * @param {' + ParamType + '} ' + ParamName + ' - ' + ParamDesc)
        else
          JSDocLines.Add(' * @param {' + ParamType + '} ' + ParamName);
      end;
      Inc(Row);
    end;

    if FuncInfo.Parameters.Count > 0 then
      JSDocLines.Add(' *');

    // Extract return type from grid (row with EditType = 2)
    Row := 1;
    while Row < StringGridFunctions.RowCount do
    begin
      CellData := TGridCellData(StringGridFunctions.Objects[0, Row]);
      if Assigned(CellData) and (CellData.FileIdx = FileIdx) and (CellData.FuncIdx = FuncIdx) and (CellData.EditType = 2) then
      begin
        FuncInfo.ReturnType := StringGridFunctions.Cells[1, Row];
        ParamDesc := StringGridFunctions.Cells[2, Row]; // Return description

        if FuncInfo.ReturnType <> '' then
        begin
          if ParamDesc <> '' then
            JSDocLines.Add(' * @returns {' + FuncInfo.ReturnType + '} ' + ParamDesc)
          else
            JSDocLines.Add(' * @returns {' + FuncInfo.ReturnType + '}');
        end;
        Break;
      end;
      Inc(Row);
    end;

    JSDocLines.Add(' */');

    // Update the function's JSDoc description
    FuncInfo.Description := JSDocLines.Text;

  finally
    JSDocLines.Free;
  end;
end;

procedure TJSAnalyzerForm.ClearGrid;
var
  I, J: integer;
  CellData: TGridCellData;
begin
  TDebugLogger.Info('ClearGrid', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  StringGridFunctions.BeginUpdate;
  try
    // First clear all cell objects
    for I := 0 to StringGridFunctions.RowCount - 1 do
    begin
      for J := 0 to 4 do
      begin
        CellData := TGridCellData(StringGridFunctions.Objects[J, I]);
        if Assigned(CellData) then
        begin
          CellData.Free;
          StringGridFunctions.Objects[J, I] := nil;
        end;
        StringGridFunctions.Cells[J, I] := '';
      end;
    end;

    // Reset row count
    StringGridFunctions.RowCount := 1;

    // Clear any selection
    StringGridFunctions.Row := -1;
    StringGridFunctions.Col := -1;

    // IMPORTANT: Disable editing
    StringGridFunctions.Options := StringGridFunctions.Options - [goEditing];

    // Hide edit buttons
    btnSaveFunction.Visible := False;
    btnCancelEdit.Visible := False;

    // Reset editing state
    FIsEditing := False;
    FEditingFileIdx := -1;
    FEditingFuncIdx := -1;

    // Clear the grid visually
    StringGridFunctions.Visible := False;

  finally
    StringGridFunctions.EndUpdate;
  end;
end;

//============= DOCUMENTATION ========================

procedure TJSAnalyzerForm.UpdateReturnDescriptionInJSDoc(var FuncInfo: TJSFunctionInfo; const NewDescription: string);
var
  Lines: TStringList;
  I: integer;
  Line: string;
  Found: boolean;
begin
  if FuncInfo.Description = '' then
  begin
    FuncInfo.Description := '/**' + LineEnding + ' * @returns ' + NewDescription + LineEnding + ' */';
    Exit;
  end;

  Lines := TStringList.Create;
  try
    Lines.Text := FuncInfo.Description;
    Found := False;

    for I := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[I]);
      if (Pos('@returns', Line) > 0) or (Pos('@return', Line) > 0) then
      begin
        if Pos('@returns', Line) > 0 then
          Lines[I] := ' * @returns ' + NewDescription
        else
          Lines[I] := ' * @return ' + NewDescription;
        Found := True;
        Break;
      end;
    end;

    if not Found then
    begin
      for I := Lines.Count - 1 downto 0 do
      begin
        if Trim(Lines[I]) = '*/' then
        begin
          Lines.Insert(I, ' * @returns ' + NewDescription);
          Break;
        end;
      end;
    end;

    FuncInfo.Description := Lines.Text;

  finally
    Lines.Free;
  end;
end;

procedure TJSAnalyzerForm.UpdateParamDescriptionInJSDoc(var FuncInfo: TJSFunctionInfo; const ParamName, NewDescription: string);
var
  Lines: TStringList;
  I: integer;
  Line: string;
  Found: boolean;
begin
  if (ParamName = '') or (FuncInfo.Description = '') then Exit;

  Lines := TStringList.Create;
  try
    Lines.Text := FuncInfo.Description;
    Found := False;

    for I := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[I]);
      if (Pos('@param', Line) > 0) and (Pos(ParamName, Line) > Pos('@param', Line)) then
      begin
        Lines[I] := ' * @param ' + ParamName + ' - ' + NewDescription;
        Found := True;
        Break;
      end;
    end;

    if not Found then
    begin
      for I := Lines.Count - 1 downto 0 do
      begin
        Line := Trim(Lines[I]);
        if (Line = '*/') or (Pos('@returns', Line) > 0) or (Pos('@return', Line) > 0) then
        begin
          Lines.Insert(I, ' * @param ' + ParamName + ' - ' + NewDescription);
          Break;
        end;
      end;
    end;

    FuncInfo.Description := Lines.Text;

  finally
    Lines.Free;
  end;
end;

procedure TJSAnalyzerForm.GenerateCommentLines(const FuncInfo: TJSFunctionInfo; CommentLines: TStringList);
begin
  TDebugLogger.Info('  GenerateCommentLines', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TJSParser.GenerateJSDocComment(FuncInfo, CommentLines);
end;

function TJSAnalyzerForm.SaveFunctionDocumentation(const FilePath: string; const FuncInfo: TJSFunctionInfo): boolean;
var
  Lines: TStringList;
  I, J: integer;
  FuncStart: integer;
  CommentStart, CommentEnd: integer;
  HasExistingComment: boolean;
  InComment: boolean;
  NewComment: TStringList;
  BackupPath: string;
begin
  Result := False;
  TDebugLogger.Info(' =========================================== ', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TDebugLogger.Info('SaveFunctionDocumentation', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  if not FileExists(FilePath) then
  begin
    ShowMessage('File does not exist: ' + FilePath);
    Exit;
  end;

  Lines := TStringList.Create;
  NewComment := TStringList.Create;
  try
    try
      // Create backup
      BackupPath := FilePath + '.bak';
      if FileExists(BackupPath) then
        DeleteFile(BackupPath);
      CopyFile(FilePath, BackupPath);

      Lines.LoadFromFile(FilePath);

      FuncStart := FuncInfo.StartLine;
      if FuncStart >= Lines.Count then
      begin
        ShowMessage('Function start line out of bounds: ' + IntToStr(FuncStart));
        Exit;
      end;

      // **REUSE**: Use the existing FindExistingComment logic
      FindExistingComment(Lines, FuncStart, CommentStart, CommentEnd,
        HasExistingComment);

      if HasExistingComment then
      begin
        // Remove existing comment
        for I := CommentEnd downto CommentStart do
          Lines.Delete(I);

        // Adjust function start line
        FuncStart := FuncStart - (CommentEnd - CommentStart + 1);
      end;

      // **REUSE**: Use the function's Description field which already contains JSDoc
      NewComment.Text := FuncInfo.Description;

      // Insert new comment before function
      // Add a blank line before the comment if there isn't one
      if (FuncStart > 0) and (Trim(Lines[FuncStart - 1]) <> '') then
        Lines.Insert(FuncStart, '');

      for I := NewComment.Count - 1 downto 0 do
        Lines.Insert(FuncStart, NewComment[I]);

      // Save file
      Lines.SaveToFile(FilePath);
      TDebugLogger.InfoFmt('Documentation saved to: %s', [FilePath], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      TDebugLogger.Info(' =========================================== ', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      Result := True;

    except
      on E: Exception do
      begin
        ShowMessage('Error saving documentation: ' + E.Message);
        // Try to restore from backup
        if FileExists(BackupPath) then
          CopyFile(BackupPath, FilePath);
      end;
    end;
  finally
    Lines.Free;
    NewComment.Free;
  end;
end;

procedure TJSAnalyzerForm.GenerateJSDocComment(const FuncInfo: TJSFunctionInfo; CommentLines: TStringList);
begin
  TDebugLogger.Info('GenerateJSDocComment', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TJSParser.GenerateJSDocComment(FuncInfo, CommentLines);
end;

function TJSAnalyzerForm.ExtractParamName(const ParamStr: string): string;
begin
  Result := TJSParser.ExtractParamName(ParamStr);
end;

procedure TJSAnalyzerForm.DisplayFileInGrid(FileIdx: integer);
var
  FileInfo: TJSFileInfo;
  Row: integer;
  I, J: integer;
begin
  TDebugLogger.InfoFmt('DisplayFileInGrid %d', [FileIdx], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  // Clear grid COMPLETELY first
  ClearGrid;

  if (FileIdx < 0) or (FileIdx > High(FFilesInfo)) then
  begin
    StringGridFunctions.Visible := False;
    Exit;
  end;

  FileInfo := FFilesInfo[FileIdx];
  StringGridFunctions.BeginUpdate;
  try
    // IMPORTANT: Reset editing state for file view
    FIsEditing := False;
    btnSaveFunction.Visible := False;
    btnCancelEdit.Visible := False;

    // Calculate row count
    StringGridFunctions.RowCount := 1 + 6; // Base rows

    if FileInfo.Imports.Count > 0 then
      StringGridFunctions.RowCount :=
        StringGridFunctions.RowCount + 1 + FileInfo.Imports.Count;

    if FileInfo.Classes.Count > 0 then
      StringGridFunctions.RowCount :=
        StringGridFunctions.RowCount + 1 + FileInfo.Classes.Count;

    // Clear all cells (just in case)
    for I := 0 to StringGridFunctions.RowCount - 1 do
    begin
      for J := 0 to 4 do
      begin
        StringGridFunctions.Cells[J, I] := '';
      end;
    end;

    // Set column headers
    StringGridFunctions.Cells[0, 0] := 'Property';
    StringGridFunctions.Cells[1, 0] := 'Value';
    StringGridFunctions.Cells[2, 0] := 'Description';
    StringGridFunctions.Cells[3, 0] := '';
    StringGridFunctions.Cells[4, 0] := '';

    // Populate rows...
    Row := 1;

    StringGridFunctions.Cells[0, Row] := 'Filename';
    StringGridFunctions.Cells[1, Row] := ExtractFileName(FileInfo.FilePath);
    StringGridFunctions.Cells[2, Row] := FileInfo.FileDescription;
    Inc(Row);

    StringGridFunctions.Cells[0, Row] := 'Path';
    StringGridFunctions.Cells[1, Row] := FileInfo.FilePath;
    Inc(Row);

    StringGridFunctions.Cells[0, Row] := 'Functions';
    StringGridFunctions.Cells[1, Row] := IntToStr(Length(FileInfo.Functions));
    Inc(Row);

    StringGridFunctions.Cells[0, Row] := 'Global Variables';
    StringGridFunctions.Cells[1, Row] := IntToStr(Length(FileInfo.GlobalVars));
    Inc(Row);

    StringGridFunctions.Cells[0, Row] := 'Classes';
    StringGridFunctions.Cells[1, Row] := IntToStr(FileInfo.Classes.Count);
    Inc(Row);

    if FileInfo.Imports.Count > 0 then
    begin
      StringGridFunctions.Cells[0, Row] := 'Imports';
      Inc(Row);

      for I := 0 to FileInfo.Imports.Count - 1 do
      begin
        StringGridFunctions.Cells[1, Row] := FileInfo.Imports[I];
        Inc(Row);
      end;
    end;

    if FileInfo.Classes.Count > 0 then
    begin
      StringGridFunctions.Cells[0, Row] := 'Classes';
      Inc(Row);

      for I := 0 to FileInfo.Classes.Count - 1 do
      begin
        StringGridFunctions.Cells[1, Row] := FileInfo.Classes[I];
        Inc(Row);
      end;
    end;

    StringGridFunctions.Visible := True;

  finally
    StringGridFunctions.EndUpdate;
  end;
end;

function TJSAnalyzerForm.IsGridInEditMode: boolean;
begin
  Result := (goEditing in StringGridFunctions.Options) and FIsEditing;
end;

procedure TJSAnalyzerForm.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  // Only process edit-related keys if we're in edit mode
  if not IsGridInEditMode then
  begin
    // Still allow F5 for refresh
    if (Key = VK_F5) then // F5 to refresh
    begin
      if Assigned(TreeView1.FocusedNode) then
        TreeView1FocusChanged(TreeView1, TreeView1.FocusedNode, 0);
      Key := 0;
    end;
    Exit;
  end;

  if (Key = VK_S) and (ssCtrl in Shift) then // Ctrl+S
  begin
    if btnSaveFunction.Visible then
      btnSaveFunctionClick(Sender);
    Key := 0;
  end
  else if (Key = VK_F5) then // F5 to refresh
  begin
    if Assigned(TreeView1.FocusedNode) then
      TreeView1FocusChanged(TreeView1, TreeView1.FocusedNode, 0);
    Key := 0;
  end
  else if (Key = VK_ESCAPE) then
  begin
    if btnCancelEdit.Visible then
      btnCancelEditClick(Sender);
  end
  else if (Key = VK_RETURN) and (ssCtrl in Shift) then // Ctrl+Enter
  begin
    if btnSaveFunction.Visible then
      btnSaveFunctionClick(Sender);
    Key := 0;
  end;
end;

procedure TJSAnalyzerForm.RefreshCurrentView;
begin
  // Trigger the existing focus changed event to refresh everything
  if Assigned(TreeView1.FocusedNode) then
    TreeView1FocusChanged(TreeView1, TreeView1.FocusedNode, 0);
end;

// Simplify DisplayHTMLDocumentation ===========================
// Update DisplayHTMLDocumentation to use the new system
procedure TJSAnalyzerForm.DisplayHTMLDocumentation(const HTML: string);
var
  NodeData: PTreeNodeData;
  DocType, aName: string;
  FilePath: string;
begin
  // Determine what we're documenting
  TDebugLogger.Info('DisplayHTMLDocumentation', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  if Assigned(TreeView1.FocusedNode) then
  begin
    NodeData := PTreeNodeData(TreeView1.GetNodeData(TreeView1.FocusedNode));
    if Assigned(NodeData) then
    begin
      case NodeData^.NodeType of
        ntFunction:
        begin
          DocType := 'function';
          aName := NodeData^.FuncInfo.Name + '_' + ExtractFileName(NodeData^.FuncInfo.FileName);
        end;
        ntFile:
        begin
          DocType := 'file';
          TDebugLogger.InfoFmt('DocType: %s', [DocType], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
          aName := ExtractFileName(NodeData^.DisplayName);
          TDebugLogger.InfoFmt('Name: %s', [aName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        end;
        else
          DocType := 'unknown';
          aName := 'documentation';
      end;

      // Save documentation with change tracking
      FilePath := SaveDocumentation(DocType, aName, HTML);

      if FilePath <> '' then
      begin
        FLastHTMLContent := HTML;

        // Switch to documentation tab
        if PageControl1.ActivePage <> TabSheetDocumentation then
          PageControl1.ActivePage := TabSheetDocumentation;

        // Display in browser
        if ChromiumBrowser1.Initialized then
          ChromiumBrowser1.LoadURL('file://' + FilePath)
        else
          FLastTempFile := FilePath;  // Store for later
      end;
    end;
  end;
end;

// New method to save documentation with change tracking

function TJSAnalyzerForm.SaveDocumentation(const DocType: string; const aName: string; const HTML: string): string;
var
  SafeName, FileName: string;
  FullPath: string;
begin
  Result := '';
  TDebugLogger.Info('***************** SaveDocumentation ******************', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  FProjectBasePath := FProject.ProjectPath;
  if Pos('[Templates]', aName) > 0 then
  begin
    FProjectBasePath := IncludeTrailingPathDelimiter(FProject.TemplatePath);
  end;
  if Pos('[Working]', aName) > 0 then
  begin
    FProjectBasePath := IncludeTrailingPathDelimiter(FProject.WorkingPath);
  end;
  TDebugLogger.InfoFmt('FProjectPath: %s', [FProjectBasePath], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  if not Assigned(FProject) or (FProjectBasePath = '') then
    Exit;

  // Create safe filename
  SafeName := StringReplace(aName, ' ', '_', [rfReplaceAll]);
  SafeName := StringReplace(SafeName, '/', '_', [rfReplaceAll]);
  SafeName := StringReplace(SafeName, '\', '_', [rfReplaceAll]);
  SafeName := StringReplace(SafeName, ':', '_', [rfReplaceAll]);
  SafeName := StringReplace(SafeName, '*', '_', [rfReplaceAll]);
  SafeName := StringReplace(SafeName, '?', '_', [rfReplaceAll]);
  SafeName := StringReplace(SafeName, '"', '_', [rfReplaceAll]);
  SafeName := StringReplace(SafeName, '<', '_', [rfReplaceAll]);
  SafeName := StringReplace(SafeName, '>', '_', [rfReplaceAll]);
  SafeName := StringReplace(SafeName, '|', '_', [rfReplaceAll]);

  TDebugLogger.InfoFmt('SafeName: %s', [SafeName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  // Create filename based on type
  if DocType = 'function' then
    FileName := SafeName + '_function.html'
  else if DocType = 'file' then
    FileName := SafeName + '_file.html'
  else if DocType = 'global' then
    FileName := SafeName + '_global.html'
  else
    FileName := SafeName + '.html';

  // Save using uFileUtils function
  FLastTempFile := SaveDocumentationFile(FProjectBasePath, FileName, HTML, True);
  Result := FLastTempFile;
end;

procedure TJSAnalyzerForm.OpenTempHTMLFile;
begin
  if FileExists(FLastTempFile) then
    OpenURL('file://' + FLastTempFile);
end;

// Add method to check if documentation needs regeneration
function TJSAnalyzerForm.NeedsDocumentationUpdate(const FilePath: string): boolean;
begin
  Result := True;

  if not Assigned(FFileChangeTracker) then
    Exit;

  if not FileExists(FilePath) then
    Exit;

  Result := FFileChangeTracker.HasFileChanged(FilePath);
end;

// Add method to generate all project documentation
procedure TJSAnalyzerForm.GenerateAllDocumentation;
var
  I, J: integer;
  HTML, FilePath: string;
begin
  if not Assigned(FProject) then Exit;

  // Generate project summary
  HTML := FDocFormatter.FormatProjectSummaryAsHTML(FFilesInfo);
  SaveDocumentation('project', 'index', HTML);

  // Generate documentation for each file
  for I := 0 to High(FFilesInfo) do
  begin
    // File documentation
    HTML := FDocFormatter.FormatFileAsHTML(FFilesInfo[I]);
    SaveDocumentation('file', FFilesInfo[I].FileName, HTML);

    // Function documentation
    for J := 0 to High(FFilesInfo[I].Functions) do
    begin
      HTML := FDocFormatter.FormatFunctionAsHTML(FFilesInfo[I].Functions[J], FFilesInfo[I].FileName, I);
      SaveDocumentation('function',
        FFilesInfo[I].Functions[J].Name + '_' + FFilesInfo[I].FileName,
        HTML
        );
    end;

    // Global variable documentation
    for J := 0 to High(FFilesInfo[I].GlobalVars) do
    begin
      HTML := FDocFormatter.FormatGlobalVarAsHTML(FFilesInfo[I].GlobalVars[J], FFilesInfo[I].FileName);
      SaveDocumentation('global',
        FFilesInfo[I].GlobalVars[J].Name + '_' + FFilesInfo[I].FileName,
        HTML
        );
    end;
  end;

  ShowMessage('Documentation generated successfully in ' + IncludeTrailingPathDelimiter(FProjectBasePath) + 'docs/');
end;

// Update ChromiumBrowser1AfterCreated
procedure TJSAnalyzerForm.ChromiumBrowser1AfterCreated(Sender: TObject; const browser: ICefBrowser);
begin
  TDebugLogger.Info('=== ChromiumBrowser1AfterCreated ===', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TDebugLogger.Info('CEF Browser successfully created!', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  FBrowserCreated := True;
  FCEFInitialized := True;
  FCreatingBrowser := False;
  // Load pending HTML if any
  if FLastHTMLContent <> '' then
  begin
    TDebugLogger.Info('Loading saved HTML content', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    ChromiumBrowser1.LoadURL('file://' + FLastTempFile);
  end
  else
  begin
    // Load a simple placeholder
    ChromiumBrowser1.LoadURL('data:text/html,' + '<!DOCTYPE html><html><head><title>ETEdit Docs</title>' + '<style>body { margin: 20px; font-family: Arial; }</style>' + '</head><body>' +
      '<h2 style="color: #007acc;">Documentation Viewer</h2>' + '<p>Select a function or file to view documentation.</p>' + '</body></html>');
  end;
end;

// Update ChromiumBrowser1BeforeClose if you have it
procedure TJSAnalyzerForm.ChromiumBrowser1BeforeClose(Sender: TObject; const browser: ICefBrowser);
begin
  TDebugLogger.Info('=== ChromiumBrowser1BeforeClose START ===', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  // Signal that browser is closing
  FBrowserCreated := False;
  FCEFInitialized := False;

  TDebugLogger.Info('=== ChromiumBrowser1BeforeClose END ===', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
end;

procedure TJSAnalyzerForm.ChromiumBrowser1BeforeContextMenu(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; const params: ICefContextMenuParams; const model: ICefMenuModel);
begin
  Model.Clear; // Clear the context menu items
end;

procedure TJSAnalyzerForm.ChromiumBrowser1LoadEnd(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: integer);
begin
  TDebugLogger.Info('=== ChromiumBrowser1LoadEnd ===', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TDebugLogger.InfoFmt('Status code: %d', [httpStatusCode], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TDebugLogger.InfoFmt('Frame URL: %s', [frame.Url], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  if httpStatusCode = 200 then
    TDebugLogger.Info('Page loaded successfully', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%})
  else
    TDebugLogger.Warning('Page load returned non-200 status', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
end;

procedure TJSAnalyzerForm.ChromiumBrowser1LoadError(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; errorCode: TCefErrorCode; const errorText, failedUrl: ustring);
begin

end;

procedure TJSAnalyzerForm.InitializeCEF;
begin
  TDebugLogger.Info('=== InitializeCEF START ===', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  // Don't initialize CEF here - it should already be done at application level
  // Just check if it's ready
  FCEFInitialized := Assigned(GlobalCEFApp) and GlobalCEFApp.GlobalContextInitialized;

  TDebugLogger.InfoFmt('CEF Global Context Initialized: %s', [BoolToYesNo(FCEFInitialized)], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  if FCEFInitialized then
  begin
    // Configure components but DON'T create browser yet
    CEFWindowParent1.Parent := TabSheetDocumentation;
    CEFWindowParent1.Align := alClient;
    CEFWindowParent1.Visible := False; // Hide until needed

    // Configure Chromium events
    ChromiumBrowser1.DefaultUrl := 'about:blank';
    ChromiumBrowser1.OnAfterCreated := @ChromiumBrowser1AfterCreated;
    ChromiumBrowser1.OnLoadEnd := @ChromiumBrowser1LoadEnd;
  end;

  TDebugLogger.Info('=== InitializeCEF END ===', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
end;

procedure TJSAnalyzerForm.CreateCEFBrowser;
begin
  // Don't create if already created
  if ChromiumBrowser1.Initialized then
  begin
    TDebugLogger.Info('Browser already initialized', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    Exit;
  end;

  // Don't create if CEF not ready
  if not FCEFInitialized then
  begin
    TDebugLogger.Warning('Cannot create browser: CEF not initialized', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    Exit;
  end;

  TDebugLogger.Info('=== CreateCEFBrowser ===', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  // Make sure parent is visible and has proper bounds
  CEFWindowParent1.Visible := True;
  CEFWindowParent1.BringToFront;

  // Ensure parent has a valid handle
  if not CEFWindowParent1.HandleAllocated then
    CEFWindowParent1.HandleNeeded;

  // Force a layout update
  CEFWindowParent1.Invalidate;
  Application.ProcessMessages;

  // Simple, direct browser creation
  try
    TDebugLogger.Info('Creating CEF browser...', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    // Use the simplest approach
    if not ChromiumBrowser1.CreateBrowser(CEFWindowParent1) then
    begin
      TDebugLogger.Error('CreateBrowser returned false', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    end;
  except
    on E: Exception do
      TDebugLogger.Error('Exception in CreateCEFBrowser: ' + E.Message, {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  end;
end;

// Add this method to close CEF browser properly
procedure TJSAnalyzerForm.CloseCEFBrowser;
var
  MaxWaitTime: integer;
begin
  if FBrowserCreated and Assigned(ChromiumBrowser1) then
  begin
    TDebugLogger.Info('CloseCEFBrowser: Starting browser shutdown...', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

    // Set closing flag
    AppClosing := True;

    try
      // Stop loading first
      if ChromiumBrowser1.Initialized then
      begin
        TDebugLogger.Info('CloseCEFBrowser: Stopping load...', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        ChromiumBrowser1.StopLoad;
      end;

      // Close the browser
      if ChromiumBrowser1.Initialized then
      begin
        TDebugLogger.Info('CloseCEFBrowser: Closing browser...', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        // Use False first for graceful shutdown
        ChromiumBrowser1.CloseBrowser(False);

        // Simple timeout loop
        MaxWaitTime := 30; // 3 seconds timeout (30 * 100ms)
        while FBrowserCreated and (MaxWaitTime > 0) do
        begin
          Sleep(100);
          Dec(MaxWaitTime);
          Application.ProcessMessages;

          // If closing is taking too long, force it
          if MaxWaitTime <= 10 then
          begin
            TDebugLogger.Info('CloseCEFBrowser: Force closing...', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
            ChromiumBrowser1.CloseBrowser(True);
          end;
        end;

        if FBrowserCreated then
          TDebugLogger.Warning('CloseCEFBrowser: Timeout waiting for browser close', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      end;

      // Wait a bit more for CEF to clean up
      Sleep(50);

    except
      on E: Exception do
        TDebugLogger.Error('CloseCEFBrowser exception: ' + E.Message, {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    end;

    // Clean up parent window
    try
      if Assigned(CEFWindowParent1) then
      begin
        TDebugLogger.Info('CloseCEFBrowser: Freeing CEFWindowParent...', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        CEFWindowParent1.Free;
        CEFWindowParent1 := nil;
      end;
    except
      on E: Exception do
        TDebugLogger.Error('CloseCEFBrowser CEFWindowParent exception: ' + E.Message, {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    end;

    FBrowserCreated := False;
    FCEFInitialized := False;

    TDebugLogger.Info('CloseCEFBrowser: Browser closed successfully', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  end;
end;

// Add a new ForceCloseCEF method
procedure TJSAnalyzerForm.ForceCloseCEF;
begin
  TDebugLogger.Info('ForceCloseCEF: Forcing CEF shutdown...', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  // Set flags immediately
  AppClosing := True;
  FBrowserCreated := False;
  FCEFInitialized := False;


  // Forcefully clean up components
  try
    if Assigned(ChromiumBrowser1) then
    begin
      // Stop any pending operations
      try
        ChromiumBrowser1.StopLoad;
      except
        // Ignore errors
      end;

      // Destroy the browser component
      ChromiumBrowser1.Free;
      ChromiumBrowser1 := nil;
    end;

    if Assigned(CEFWindowParent1) then
    begin
      CEFWindowParent1.Free;
      CEFWindowParent1 := nil;
    end;
  except
    on E: Exception do
      TDebugLogger.Error('ForceCloseCEF exception: ' + E.Message, {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  end;

  TDebugLogger.Info('ForceCloseCEF: Complete', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
end;


end.
