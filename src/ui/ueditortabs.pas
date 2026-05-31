unit uEditorTabs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ComCtrls, Dialogs, cyPageControl,
  SynEdit,               // For TSynEdit component
  SynEditTypes,          // For TSynStatusChanges type
  SynEditMiscClasses,    // For eoAutoIndent and other editor options
  SynEditKeyCmds,
  SynHighlighterJScript, SynHighlighterHTML, SynHighlighterCss, SynHighlighterxML, SynHighlighterMulti, SynEditHighlighter,
  Graphics, uThemeManager, uDebugLog;

type
  // Method pointer types for events
  TEditorChangeEvent = procedure(Sender: TObject; Editor: TSynEdit) of object;

  TEditorTab = class(TTabSheet)  // Changed from TTabSheet to TcyTabSheet
  private
    FEditor: TSynEdit;
    FFileName: String;
    FFileType: String;
    FSaved: Boolean;
    FHighlighter: TSynCustomHighlighter;
    FOnEditorChange: TNotifyEvent;
    FLastWriteTime: TDateTime;

    function CreateHighlighter: TSynCustomHighlighter;
    function GetDisplayName: String;
    procedure EditorChange(Sender: TObject);
    procedure EditorStatusChange(Sender: TObject; Changes: TSynStatusChanges);
  public
    constructor Create(AOwner: TComponent; const AFileName: String); reintroduce;
    destructor Destroy; override;

    procedure LoadFile;
    function SaveFile: Boolean;
    function SaveFileAs(const NewFileName: String): Boolean;
    procedure ReloadHighlighter;

    property Editor: TSynEdit read FEditor;
    property FileName: String read FFileName;
    property FileType: String read FFileType;
    property Saved: Boolean read FSaved write FSaved;
    property DisplayName: String read GetDisplayName;
    property OnEditorChange: TNotifyEvent read FOnEditorChange write FOnEditorChange;

    procedure UpdateLastWriteTime;
    function IsFileChangedExternally: Boolean;
  end;

  TEditorTabsManager = class
  private
    FPageControl: TcyPageControl;  // Changed from TPageControl
    FTabs: TList;
    FOnActiveEditorChanged: TEditorChangeEvent;

    procedure PageControlChange(Sender: TObject);
    function GetActiveTab: TEditorTab;
    function GetTabCount: Integer;
    function GetTab(Index: Integer): TEditorTab;
    procedure TabEditorChange(Sender: TObject);
  public
    constructor Create(APageControl: TcyPageControl);  // Changed parameter type
    destructor Destroy; override;

    // Tab management
    function NewTab(const Title: String = 'Untitled'): TEditorTab;
    function OpenFile(const FileName: String): TEditorTab;
    function CloseTab(Index: Integer; Force: Boolean = False): Boolean;
    function CloseActiveTab(Force: Boolean = False): Boolean;
    function SaveTab(Index: Integer): Boolean;
    function SaveActiveTab: Boolean;
    procedure SaveAllTabs;
    function CloseAllTabs(Force: Boolean = False): Boolean;
    function GetActiveEditor: TSynEdit;

    // Tab navigation
    procedure NextTab;
    procedure PreviousTab;
    function FindTabByFileName(const FileName: String): TEditorTab;

    // Getters
    property ActiveTab: TEditorTab read GetActiveTab;
    property TabCount: Integer read GetTabCount;
    property Tabs[Index: Integer]: TEditorTab read GetTab;

    // Events
    property OnActiveEditorChanged: TEditorChangeEvent
      read FOnActiveEditorChanged write FOnActiveEditorChanged;

  end;

implementation

constructor TEditorTab.Create(AOwner: TComponent; const AFileName: String);
begin
  inherited Create(AOwner);
  PageControl := TcyPageControl(AOwner);  // Changed to TcyPageControl

  FFileName := AFileName;
  FSaved := False;

  // Create editor
  FEditor := TSynEdit.Create(Self);
  FEditor.Parent := Self;
  FEditor.Align := alClient;
  FEditor.Font.Name := 'IBM Plex Mono Text';
  FEditor.Font.Size := 12;
  FEditor.Options := [eoAutoIndent, eoBracketHighlight, eoEnhanceHomeKey,
                     eoGroupUndo, eoKeepCaretX, eoShowScrollHint, eoSmartTabs,
                     eoTabsToSpaces, eoTrimTrailingSpaces, eoDragDropEditing];
  FEditor.Options2 := [eoEnhanceEndKey, eoFoldedCopyPaste, eoOverwriteBlock,
                      eoAcceptDragDropEditing];
  FEditor.TabWidth := 2;

  // Connect editor events
  FEditor.OnChange := @EditorChange;
  FEditor.OnStatusChange := @EditorStatusChange;

  // Set up highlighter
  FHighlighter := CreateHighlighter;
  FEditor.Highlighter := FHighlighter;

  // Apply theme to highlighter
  if FHighlighter <> nil then
    ThemeManager.ApplyToHighlighter(FHighlighter);

  // Load file if it exists
  if (FFileName <> '') and FileExists(FFileName) then
    LoadFile;

  Caption := GetDisplayName;
end;

destructor TEditorTab.Destroy;
begin
  if FHighlighter <> nil then
    FHighlighter.Free;
  inherited Destroy;
end;

procedure TEditorTab.EditorChange(Sender: TObject);
begin
  FSaved := False;
  Caption := GetDisplayName;

  // Notify about changes
  if Assigned(FOnEditorChange) then
    FOnEditorChange(Self);
end;

// In uEditorTabs.pas, add to TEditorTab
procedure TEditorTab.EditorStatusChange(Sender: TObject; Changes: TSynStatusChanges);
begin
  // This fires when cursor moves, text changes, MODIFIED status changes, etc.
  if (scCaretY in Changes) or (scCaretX in Changes) or (scModified in Changes) then
  begin
    // Update our saved flag based on editor's modified state
    FSaved := not FEditor.Modified;
    Caption := GetDisplayName;

    // Trigger tab change to update status bar
    if Assigned(FOnEditorChange) then
      FOnEditorChange(Self);
  end;
end;

function TEditorTab.CreateHighlighter: TSynCustomHighlighter;
var
  Ext: String;
begin
  Ext := LowerCase(ExtractFileExt(FFileName));

  if (Ext = '.html') or (Ext = '.htm') or (Ext = '.xhtml') then
  begin
    FFileType := 'html';
    Result := TSynHTMLSyn.Create(Self);
  end
  else if (Ext = '.css') or (Ext = '.scss') or (Ext = '.less') then
  begin
    FFileType := 'css';
    Result := TSynCssSyn.Create(Self);
  end
  else if (Ext = '.js') or (Ext = '.javascript') or (Ext = '.mjs') or
          (Ext = '.ts') or (Ext = '.tsx') then
  begin
    FFileType := 'javascript';
    Result := TSynJScriptSyn.Create(Self);
  end
  else if (Ext = '.svg') or (Ext = '.xml') or (Ext = '.rss') or
          (Ext = '.atom') or (Ext = '.xsl') then
  begin
    FFileType := 'xml';
    Result := TSynXMLSyn.Create(Self);
  end
  else
  begin
    FFileType := 'text';
    Result := nil;
  end;
end;

function TEditorTab.GetDisplayName: String;
begin
  if FFileName = '' then
    Result := 'Untitled'
  else
    Result := ExtractFileName(FFileName);

  if not FSaved then
    Result := Result + ' *';
end;

procedure TEditorTab.LoadFile;
begin
  if FileExists(FFileName) then
  begin
    FEditor.Lines.LoadFromFile(FFileName);
    FSaved := True;
    Caption := GetDisplayName;
  end;
end;

function TEditorTab.SaveFile: Boolean;
begin
  Result := False;

  if FFileName = '' then
  begin
    // No filename yet, treat as Save As
    Result := SaveFileAs('');
  end
  else
  begin
    try
      FEditor.Lines.SaveToFile(FFileName);
      FEditor.Modified := False;  // Ensure editor knows it's saved
      FSaved := True;
      Caption := GetDisplayName;
      // Notify that editor state changed (important!)
      if Assigned(FOnEditorChange) then
        FOnEditorChange(Self);
      Result := True;
    except
      on E: Exception do
        ShowMessage('Error saving file: ' + E.Message);
    end;
  end;
end;

function TEditorTab.SaveFileAs(const NewFileName: String): Boolean;
var
  SaveDialog: TSaveDialog;
  ActualFileName: String;
begin
  Result := False;
  ActualFileName := NewFileName;

  if ActualFileName = '' then
  begin
    SaveDialog := TSaveDialog.Create(Application);
    try
      SaveDialog.Filter :=
        'HTML files (*.html;*.htm)|*.html;*.htm|' +
        'CSS files (*.css)|*.css|' +
        'JavaScript files (*.js)|*.js|' +
        'JSON files (*.json)|*.json|' +
        'SVG files (*.svg)|*.svg|' +
        'All files (*.*)|*.*';
      SaveDialog.DefaultExt := '.html';
      SaveDialog.FileName := ExtractFileName(FFileName);

      if SaveDialog.Execute then
        ActualFileName := SaveDialog.FileName
      else
        Exit;
    finally
      SaveDialog.Free;
    end;
  end;

  if ActualFileName <> '' then
  begin
    FFileName := ActualFileName;
    ReloadHighlighter;
    Result := SaveFile;
  end;
end;

procedure TEditorTab.ReloadHighlighter;
begin
  if FHighlighter <> nil then
    FHighlighter.Free;

  FHighlighter := CreateHighlighter;
  FEditor.Highlighter := FHighlighter;
end;

procedure TEditorTab.UpdateLastWriteTime;
var
  SearchRec: TSearchRec;
begin
  if FileExists(FFileName) and (FindFirst(FFileName, faAnyFile, SearchRec) = 0) then
  begin
    TDebugLogger.DebugFmt('UpdateLastWriteTime = %s', [FFileName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    FLastWriteTime := FileDateToDateTime(SearchRec.Time);
    FindClose(SearchRec);
  end
  else
    FLastWriteTime := 0;
end;

function TEditorTab.IsFileChangedExternally: Boolean;
var
  CurrentTime: TDateTime;
  SearchRec: TSearchRec;
begin
  Result := False;
  if not FileExists(FFileName) then Exit;
  if FindFirst(FFileName, faAnyFile, SearchRec) = 0 then
  begin
    CurrentTime := FileDateToDateTime(SearchRec.Time);
    FindClose(SearchRec);
    Result := (CurrentTime <> FLastWriteTime) and (CurrentTime > FLastWriteTime);
  end;
end;

{ TEditorTabsManager }

constructor TEditorTabsManager.Create(APageControl: TcyPageControl);
begin
  FPageControl := APageControl;
  FTabs := TList.Create;
  APageControl.ActiveTabColors.FromColor:=$00FE526B;
  APageControl.ActiveTabColors.ToColor:=$00FE526B;


  // Track tab changes
  FPageControl.OnChange := @PageControlChange;
end;

destructor TEditorTabsManager.Destroy;
begin
  CloseAllTabs(True);
  FTabs.Free;
  inherited Destroy;
end;

procedure TEditorTabsManager.TabEditorChange(Sender: TObject);
begin
  // A tab's editor changed - update status bar
  if Assigned(FOnActiveEditorChanged) then
    FOnActiveEditorChanged(Self, GetActiveEditor);
end;

procedure TEditorTabsManager.PageControlChange(Sender: TObject);
begin
  // Trigger active editor changed event
  if Assigned(FOnActiveEditorChanged) then
    FOnActiveEditorChanged(Self, GetActiveEditor);
end;

function TEditorTabsManager.NewTab(const Title: String = 'Untitled'): TEditorTab;
begin
  Result := TEditorTab.Create(FPageControl, '');
  Result.Caption := Title;
  Result.OnEditorChange := @TabEditorChange;  // Connect event
  FTabs.Add(Result);
  FPageControl.ActivePage := Result;
end;

function TEditorTabsManager.OpenFile(const FileName: String): TEditorTab;
var
  ExistingTab: TEditorTab;
begin
  // Check if file is already open
  ExistingTab := FindTabByFileName(FileName);
  if ExistingTab <> nil then
  begin
    FPageControl.ActivePage := ExistingTab;
    Result := ExistingTab;
    Exit;
  end;

  // Open new tab
  Result := TEditorTab.Create(FPageControl, FileName);
  Result.OnEditorChange := @TabEditorChange;  // Connect event
  FTabs.Add(Result);
  FPageControl.ActivePage := Result;
end;

function TEditorTabsManager.CloseTab(Index: Integer; Force: Boolean = False): Boolean;
var
  Tab: TEditorTab;
begin
  Result := False;

  if (Index < 0) or (Index >= FTabs.Count) then
    Exit;

  Tab := TEditorTab(FTabs[Index]);

  // Check if we need to save
  if (not Force) and (not Tab.Saved) then
  begin
    case MessageDlg('Save changes to ' + Tab.DisplayName + '?',
                   mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
      mrYes:
        if not SaveTab(Index) then
          Exit; // User cancelled save
      mrCancel:
        Exit; // User cancelled close
      // mrNo: just close without saving
    end;
  end;

  Tab.Free;
  FTabs.Delete(Index);
  Result := True;
end;

function TEditorTabsManager.CloseActiveTab(Force: Boolean = False): Boolean;
begin
  if FPageControl.ActivePageIndex >= 0 then
    Result := CloseTab(FPageControl.ActivePageIndex, Force)
  else
    Result := False;
end;

function TEditorTabsManager.SaveTab(Index: Integer): Boolean;
begin
  Result := False;

  if (Index >= 0) and (Index < FTabs.Count) then
    Result := TEditorTab(FTabs[Index]).SaveFile;
end;

function TEditorTabsManager.SaveActiveTab: Boolean;
begin
  if FPageControl.ActivePageIndex >= 0 then
    Result := SaveTab(FPageControl.ActivePageIndex)
  else
    Result := False;
end;

procedure TEditorTabsManager.SaveAllTabs;
var
  I: Integer;
begin
  for I := 0 to FTabs.Count - 1 do
    if not TEditorTab(FTabs[I]).Saved then
      TEditorTab(FTabs[I]).SaveFile;
end;

function TEditorTabsManager.CloseAllTabs(Force: Boolean = False): Boolean;
var
  I: Integer;
begin
  Result := True;

  // Close from last to first to avoid index shifting issues
  for I := FTabs.Count - 1 downto 0 do
  begin
    if not CloseTab(I, Force) then
      Result := False;
  end;
end;

function TEditorTabsManager.GetActiveEditor: TSynEdit;
var
  myActiveTab: TEditorTab;
begin
  myActiveTab := GetActiveTab;
  if myActiveTab <> nil then
    Result := ActiveTab.Editor
  else
    Result := nil;
end;

procedure TEditorTabsManager.NextTab;
begin
  if FPageControl.PageCount > 0 then
    FPageControl.ActivePageIndex := (FPageControl.ActivePageIndex + 1) mod FPageControl.PageCount;
end;

procedure TEditorTabsManager.PreviousTab;
begin
  if FPageControl.PageCount > 0 then
  begin
    if FPageControl.ActivePageIndex = 0 then
      FPageControl.ActivePageIndex := FPageControl.PageCount - 1
    else
      FPageControl.ActivePageIndex := FPageControl.ActivePageIndex - 1;
  end;
end;

function TEditorTabsManager.FindTabByFileName(const FileName: String): TEditorTab;
var
  I: Integer;
  Tab: TEditorTab;
begin
  Result := nil;

  for I := 0 to FTabs.Count - 1 do
  begin
    Tab := TEditorTab(FTabs[I]);
    if CompareText(Tab.FileName, FileName) = 0 then
    begin
      Result := Tab;
      Break;
    end;
  end;
end;

function TEditorTabsManager.GetActiveTab: TEditorTab;
begin
  if (FPageControl.ActivePageIndex >= 0) and
     (FPageControl.ActivePageIndex < FTabs.Count) then
    Result := TEditorTab(FTabs[FPageControl.ActivePageIndex])
  else
    Result := nil;
end;

function TEditorTabsManager.GetTabCount: Integer;
begin
  Result := FTabs.Count;
end;

function TEditorTabsManager.GetTab(Index: Integer): TEditorTab;
begin
  if (Index >= 0) and (Index < FTabs.Count) then
    Result := TEditorTab(FTabs[Index])
  else
    Result := nil;
end;

end.
