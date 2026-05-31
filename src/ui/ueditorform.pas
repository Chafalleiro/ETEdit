unit uEditorForm;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, Forms, Controls, ComCtrls, AsyncProcess, SynEdit,
  SynHighlighterHTML, SynHighlighterxML, SynHighlighterCss, SynCompletion,
  SynHighlighterJScript, SynHighlighterMulti,
  pl_ExControls, cyPageControl, cyTabControl,
  uEditorTabs;
type
  { TEditorForm }
  TEditorForm = class(TForm)
    PageControl1: TcyPageControl;
  private
    FEditorTabs: TEditorTabsManager;
    FOnActiveEditorChanged: TEditorChangeEvent;

    procedure TabEditorChange(Sender: TObject; Editor: TSynEdit);
    function GetActiveEditor: TSynEdit;
    function GetActiveTab: TEditorTab;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // Forward methods to TEditorTabsManager
    function NewTab(const Title: String = 'Untitled'): TEditorTab;
    function OpenFile(const FileName: String): TEditorTab;
    function CloseTab(Index: Integer; Force: Boolean = False): Boolean;
    function CloseActiveTab(Force: Boolean = False): Boolean;
    function SaveTab(Index: Integer): Boolean;
    function SaveActiveTab: Boolean;
    procedure SaveAllTabs;
    function CloseAllTabs(Force: Boolean = False): Boolean;
    function FindTabByFileName(const FileName: String): TEditorTab;
    procedure NextTab;
    procedure PreviousTab;

    // Properties
    property EditorTabs: TEditorTabsManager read FEditorTabs;
    property ActiveEditor: TSynEdit read GetActiveEditor;
    property ActiveTab: TEditorTab read GetActiveTab;

    // Events
    property OnActiveEditorChanged: TEditorChangeEvent
      read FOnActiveEditorChanged write FOnActiveEditorChanged;
  end;

implementation

{$R *.frm}

{ TEditorForm }

constructor TEditorForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Caption := 'Editor';
  Name := 'EditorForm';

  // Setup page control
  PageControl1 := TcyPageControl.Create(Self);  // Changed to TcyPageControl
  PageControl1.Parent := Self;
  PageControl1.Align := alClient;
  PageControl1.ActiveTabColors.FromColor := $00FE526B;
  PageControl1.ActiveTabColors.ToColor := $00FE526B;
  PageControl1.InActiveTabColors.FromColor := $0000526B;
  PageControl1.InActiveTabColors.ToColor := $0000526B;

  // Configure cyPageControl styling options
  PageControl1.TabPosition := tpTop;

  // Create tabs manager
  FEditorTabs := TEditorTabsManager.Create(PageControl1);
  FEditorTabs.OnActiveEditorChanged := @TabEditorChange;
end;

destructor TEditorForm.Destroy;
begin
  FEditorTabs.Free;
  inherited Destroy;
end;

procedure TEditorForm.TabEditorChange(Sender: TObject; Editor: TSynEdit);
begin
  if Assigned(FOnActiveEditorChanged) then
    FOnActiveEditorChanged(Sender, Editor);
end;

function TEditorForm.GetActiveEditor: TSynEdit;
begin
  Result := FEditorTabs.GetActiveEditor;
end;

function TEditorForm.GetActiveTab: TEditorTab;
begin
  Result := FEditorTabs.ActiveTab;
end;

function TEditorForm.NewTab(const Title: String = 'Untitled'): TEditorTab;
begin
  Result := FEditorTabs.NewTab(Title);
end;

function TEditorForm.OpenFile(const FileName: String): TEditorTab;
begin
  Result := FEditorTabs.OpenFile(FileName);
end;

function TEditorForm.CloseTab(Index: Integer; Force: Boolean = False): Boolean;
begin
  Result := FEditorTabs.CloseTab(Index, Force);
end;

function TEditorForm.CloseActiveTab(Force: Boolean = False): Boolean;
begin
  Result := FEditorTabs.CloseActiveTab(Force);
end;

function TEditorForm.SaveTab(Index: Integer): Boolean;
begin
  Result := FEditorTabs.SaveTab(Index);
end;

function TEditorForm.SaveActiveTab: Boolean;
begin
  Result := FEditorTabs.SaveActiveTab;
end;

procedure TEditorForm.SaveAllTabs;
begin
  FEditorTabs.SaveAllTabs;
end;

function TEditorForm.CloseAllTabs(Force: Boolean = False): Boolean;
begin
  Result := FEditorTabs.CloseAllTabs(Force);
end;

function TEditorForm.FindTabByFileName(const FileName: String): TEditorTab;
begin
  Result := FEditorTabs.FindTabByFileName(FileName);
end;

procedure TEditorForm.NextTab;
begin
  FEditorTabs.NextTab;
end;

procedure TEditorForm.PreviousTab;
begin
  FEditorTabs.PreviousTab;
end;

end.
