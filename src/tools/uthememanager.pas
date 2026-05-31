unit uThemeManager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Forms, Controls, ComCtrls, StdCtrls,
  ExtCtrls, Buttons, Grids, SynEdit, VirtualTrees, Menus, Math, cyPageControl, cyTabControl,
  SynHighlighterJScript, SynHighlighterHTML, SynHighlighterCss,
  SynHighlighterxML, SynEditHighlighter;

type
  TEditorTheme = (etLight, etDark, etBlue, etGreen);

  { TThemeManager }
  TThemeManager = class
  private
    FCurrentTheme: TEditorTheme;
    FOnThemeChanged: TNotifyEvent;

    // Base colors
    FEditorBG: TColor;
    FEditorText: TColor;
    FGutterBG: TColor;
    FSelectionBG: TColor;
    FSelectionFG: TColor;
    FLineHighlight: TColor;
    FRightEdge: TColor;
    FActiveLine: TColor;

    // Form and control colors
    FFormBG: TColor;
    FFormText: TColor;
    FPanelBG: TColor;
    FPanelText: TColor;
    FButtonBG: TColor;
    FButtonText: TColor;
    FGridBG: TColor;
    FGridText: TColor;
    FGridLine: TColor;
    FTreeBG: TColor;
    FTreeText: TColor;
    FTreeLine: TColor;

    procedure UpdateThemeColors;
    procedure FireThemeChanged;
    function AdjustColor(AColor: TColor; Delta: Integer): TColor;

  public
    constructor Create;

    // Theme control
    procedure ApplyTheme(Theme: TEditorTheme);
    procedure NextTheme;

    // Apply to components
    procedure ApplyToForm(Form: TForm);
    procedure ApplyToPanel(Panel: TPanel);
    procedure ApplyToButton(Button: TButton);
    procedure ApplyToSpeedButton(Button: TSpeedButton);
    procedure ApplyToLabel(LabelCtrl: TLabel);
    procedure ApplyToEdit(Edit: TEdit);
    procedure ApplyToMemo(Memo: TMemo);
    procedure ApplyToComboBox(Combo: TComboBox);
    procedure ApplyToListBox(ListBox: TListBox);
    procedure ApplyToCheckBox(CheckBox: TCheckBox);
    procedure ApplyToRadioButton(Radio: TRadioButton);
    procedure ApplyToStringGrid(Grid: TStringGrid);
    procedure ApplyToVirtualTree(Tree: TVirtualStringTree);
    procedure ApplyToSynEdit(Editor: TSynEdit);
    procedure ApplyToPageControl(PageControl: TcyPageControl);
    procedure ApplyToTabSheet(TabSheet: TTabSheet);
    procedure ApplyToHighlighter(Highlighter: TSynCustomHighlighter);

    // Apply to all controls in a container
    procedure ApplyToContainer(Container: TWinControl);

    // Testing utilities
    procedure TestColorScheme(const Name: string;
      BG, Text, Gutter, Selection: TColor);
    procedure ResetToDefault;

    // Getters for testing
    function GetCurrentThemeName: string;
    function GetColorValues: string;

    // Expose colors for testing
    property CurrentTheme: TEditorTheme read FCurrentTheme;
    property EditorBG: TColor read FEditorBG;
    property EditorText: TColor read FEditorText;
    property GutterBG: TColor read FGutterBG;
    property SelectionBG: TColor read FSelectionBG;

    property OnThemeChanged: TNotifyEvent read FOnThemeChanged write FOnThemeChanged;
  end;

var
  ThemeManager: TThemeManager;

implementation

constructor TThemeManager.Create;
begin
  FCurrentTheme := etLight;
  UpdateThemeColors;
end;

function TThemeManager.AdjustColor(AColor: TColor; Delta: Integer): TColor;
var
  R, G, B: Byte;
begin
  AColor := ColorToRGB(AColor);
  R := Byte(AColor);
  G := Byte(AColor shr 8);
  B := Byte(AColor shr 16);

  // Simple brightness adjustment with clamping
  if Delta > 0 then
  begin
    // Lighten
    R := Byte(Min(255, R + Delta));
    G := Byte(Min(255, G + Delta));
    B := Byte(Min(255, B + Delta));
  end
  else
  begin
    // Darken
    R := Byte(Max(0, R + Delta));
    G := Byte(Max(0, G + Delta));
    B := Byte(Max(0, B + Delta));
  end;

  Result := RGBToColor(R, G, B);
end;

function RGBToColor(R, G, B: Byte): TColor;
begin
  Result := (B shl 16) or (G shl 8) or R;
end;

procedure TThemeManager.UpdateThemeColors;
begin
  case FCurrentTheme of
    etLight:
    begin
      // Classic light theme
      FFormBG := clBtnFace;
      FFormText := clWindowText;
      FPanelBG := clBtnFace;
      FPanelText := clWindowText;
      FButtonBG := clBtnFace;
      FButtonText := clWindowText;
      FGridBG := clWindow;
      FGridText := clWindowText;
      FGridLine := clSilver;
      FTreeBG := clWindow;
      FTreeText := clWindowText;
      FTreeLine := clSilver;

      // Editor colors
      FEditorBG := clWhite;
      FEditorText := clBlack;
      FGutterBG := $00F0F0F0;
      FSelectionBG := clHighlight;
      FSelectionFG := clHighlightText;
      FLineHighlight := $00F8F8F8;
      FRightEdge := $00E0E0E0;
      FActiveLine := $00E8F0FE;
    end;

    etDark:
    begin
      // Dark theme
      FFormBG := $00222222;
      FFormText := $00CCCCCC;
      FPanelBG := $00222222;
      FPanelText := $00CCCCCC;
      FButtonBG := $00333333;
      FButtonText := $00CCCCCC;
      FGridBG := $00111111;
      FGridText := $00CCCCCC;
      FGridLine := $00444444;
      FTreeBG := $00111111;
      FTreeText := $00CCCCCC;
      FTreeLine := $00444444;

      // Editor colors
      FEditorBG := $00111111;
      FEditorText := $00CCCCCC;
      FGutterBG := $00222222;
      FSelectionBG := $00444444;
      FSelectionFG := clWhite;
      FLineHighlight := $00191919;
      FRightEdge := $00333333;
      FActiveLine := $00222222;
    end;

    etBlue:
    begin
      // Blue theme
      FFormBG := $00F0F8FF;
      FFormText := clNavy;
      FPanelBG := $00F0F8FF;
      FPanelText := clNavy;
      FButtonBG := $00E0F0FF;
      FButtonText := clNavy;
      FGridBG := $00F9F9FF;
      FGridText := $00003366;
      FGridLine := $00CCDDFF;
      FTreeBG := $00F9F9FF;
      FTreeText := $00003366;
      FTreeLine := $00CCDDFF;

      // Editor colors
      FEditorBG := $00F9F9FF;
      FEditorText := $00003366;
      FGutterBG := $00E6F0FF;
      FSelectionBG := $006699CC;
      FSelectionFG := clWhite;
      FLineHighlight := $00F0F7FF;
      FRightEdge := $00CCDDFF;
      FActiveLine := $00E8F0FE;
    end;

    etGreen:
    begin
      // Green theme
      FFormBG := $00F0FFF0;
      FFormText := $00336600;
      FPanelBG := $00F0FFF0;
      FPanelText := $00336600;
      FButtonBG := $00E0FFE0;
      FButtonText := $00336600;
      FGridBG := $00F9FFF9;
      FGridText := $00336600;
      FGridLine := $00CCEECC;
      FTreeBG := $00F9FFF9;
      FTreeText := $00336600;
      FTreeLine := $00CCEECC;

      // Editor colors
      FEditorBG := $00F9FFF9;
      FEditorText := $00336600;
      FGutterBG := $00E8FFE8;
      FSelectionBG := $0099CC99;
      FSelectionFG := clWhite;
      FLineHighlight := $00F0FFF0;
      FRightEdge := $00CCEECC;
      FActiveLine := $00E8FEE8;
    end;
  end;

  FireThemeChanged;
end;

procedure TThemeManager.FireThemeChanged;
begin
  if Assigned(FOnThemeChanged) then
    FOnThemeChanged(Self);
end;

procedure TThemeManager.ApplyTheme(Theme: TEditorTheme);
begin
  if FCurrentTheme <> Theme then
  begin
    FCurrentTheme := Theme;
    UpdateThemeColors;
  end;
end;

procedure TThemeManager.NextTheme;
begin
  case FCurrentTheme of
    etLight: ApplyTheme(etDark);
    etDark: ApplyTheme(etBlue);
    etBlue: ApplyTheme(etGreen);
    etGreen: ApplyTheme(etLight);
  end;
end;

procedure TThemeManager.ApplyToForm(Form: TForm);
begin
  if Form = nil then Exit;

  Form.Color := FFormBG;
  Form.Font.Color := FFormText;
end;

procedure TThemeManager.ApplyToPanel(Panel: TPanel);
begin
  if Panel = nil then Exit;

  Panel.Color := FPanelBG;
  Panel.Font.Color := FPanelText;
end;

procedure TThemeManager.ApplyToButton(Button: TButton);
begin
  if Button = nil then Exit;
  Button.GetColorResolvingParent;
  Button.Color := FButtonBG or   Button.GetColorResolvingParent;
  Button.Font.Color := FButtonText;
end;

procedure TThemeManager.ApplyToSpeedButton(Button: TSpeedButton);
begin
  if Button = nil then Exit;

  Button.Font.Color := FButtonText;
end;

procedure TThemeManager.ApplyToLabel(LabelCtrl: TLabel);
begin
  if LabelCtrl = nil then Exit;

  LabelCtrl.Font.Color := FFormText;
end;

procedure TThemeManager.ApplyToEdit(Edit: TEdit);
begin
  if Edit = nil then Exit;

  Edit.Color := FGridBG;
  Edit.Font.Color := FGridText;
end;

procedure TThemeManager.ApplyToMemo(Memo: TMemo);
begin
  if Memo = nil then Exit;

  Memo.Color := FGridBG;
  Memo.Font.Color := FGridText;
end;

procedure TThemeManager.ApplyToComboBox(Combo: TComboBox);
begin
  if Combo = nil then Exit;

  Combo.Color := FGridBG;
  Combo.Font.Color := FGridText;
end;

procedure TThemeManager.ApplyToListBox(ListBox: TListBox);
begin
  if ListBox = nil then Exit;

  ListBox.Color := FGridBG;
  ListBox.Font.Color := FGridText;
end;

procedure TThemeManager.ApplyToCheckBox(CheckBox: TCheckBox);
begin
  if CheckBox = nil then Exit;

  CheckBox.Font.Color := FFormText;
end;

procedure TThemeManager.ApplyToRadioButton(Radio: TRadioButton);
begin
  if Radio = nil then Exit;

  Radio.Font.Color := FFormText;
end;

procedure TThemeManager.ApplyToStringGrid(Grid: TStringGrid);
begin
  if Grid = nil then Exit;

  Grid.Color := FGridBG;
  Grid.Font.Color := FGridText;
  Grid.FixedColor := FPanelBG;
//  Grid.FixedFont.Color := FPanelText;

  try
    Grid.GridLineColor := FGridLine;
  except
  end;

  // Style alternate rows if supported
  try
    Grid.AlternateColor := AdjustColor(FGridBG, 10);
  except
  end;

  // Force redraw
  Grid.Invalidate;
end;

procedure TThemeManager.ApplyToVirtualTree(Tree: TVirtualStringTree);
begin
  if Tree = nil then Exit;

  // Basic tree colors
  Tree.Color := FTreeBG;
  Tree.Font.Color := FTreeText;

  // Try to apply additional VirtualTreeView properties
  try
    Tree.Colors.BorderColor := FGridLine;
    Tree.Colors.TreeLineColor := FTreeLine;

    // Selection colors
    Tree.Colors.FocusedSelectionColor := FSelectionBG;
    Tree.Colors.FocusedSelectionBorderColor := AdjustColor(FSelectionBG, -20);

    // Grid lines
    Tree.Colors.GridLineColor := FGridLine;

    // Header
    Tree.Header.Font.Color := FPanelText;
  except
    // Some properties might not exist in all VirtualTreeView versions
  end;

  // Force redraw
  Tree.Invalidate;
end;

procedure TThemeManager.ApplyToSynEdit(Editor: TSynEdit);
begin
  if Editor = nil then Exit;

  // Apply basic colors that always work
  Editor.Color := FEditorBG;
  Editor.Font.Color := FEditorText;

  // Try to apply optional properties with exception handling
  try
    Editor.Gutter.Color := FGutterBG;
  except
  end;

  try
    Editor.SelectedColor.Background := FSelectionBG;
    Editor.SelectedColor.Foreground := FSelectionFG;
  except
  end;

  try
    Editor.LineHighlightColor.Background := FLineHighlight xor FEditorText;
    Editor.LineHighlightColor.Foreground := Editor.LineHighlightColor.Foreground xor Editor.LineHighlightColor.Background;
  except
  end;

  try
    Editor.RightEdgeColor := FRightEdge;
  except
  end;


  // Always set right edge position
  Editor.RightEdge := 80;

  // Ensure gutter is visible
  Editor.Gutter.Visible := True;
  Editor.Gutter.LineNumberPart(5);
//  Editor.Gutter.CurrentLineColor;
//  Editor.Gutter.ShowLineNumbers := True;

end;

procedure TThemeManager.ApplyToPageControl(PageControl: TcyPageControl);
var
  i: Integer;
begin
  if PageControl = nil then Exit;

  PageControl.Font.Color := FFormText;
  PageControl.ActiveTabColors.FromColor := $0000ff00;
  PageControl.ActiveTabColors.ToColor := $0000ff00;
  PageControl.InActiveTabColors.FromColor := $0000006B;
  PageControl.InActiveTabColors.ToColor := $0000006B;
  // Apply to all tabsheets
  for i := 0 to PageControl.PageCount - 1 do
    ApplyToTabSheet(PageControl.Pages[i] as TTabSheet);
end;

procedure TThemeManager.ApplyToTabSheet(TabSheet: TTabSheet);
begin
  if TabSheet = nil then Exit;

  TabSheet.Color := FPanelBG;
  TabSheet.Font.Color := FPanelText;
end;

procedure TThemeManager.ApplyToHighlighter(Highlighter: TSynCustomHighlighter);
begin
  if Highlighter = nil then Exit;

  case FCurrentTheme of
    etLight:
    begin
      // Light theme highlighter colors
      if Highlighter is TSynJScriptSyn then
        with TSynJScriptSyn(Highlighter) do
        begin
          CommentAttri.Foreground := clGreen;
          CommentAttri.Style := [fsItalic];
          KeyAttri.Foreground := clBlue;
          KeyAttri.Style := [fsBold];
          NumberAttri.Foreground := clPurple;
          StringAttri.Foreground := clMaroon;
        end
      else if Highlighter is TSynHTMLSyn then
        with TSynHTMLSyn(Highlighter) do
        begin
          CommentAttri.Foreground := clGreen;
          CommentAttri.Style := [fsItalic];
          KeyAttri.Foreground := clBlue;
          KeyAttri.Style := [fsBold];
        end
      else if Highlighter is TSynCssSyn then
        with TSynCssSyn(Highlighter) do
        begin
          CommentAttri.Foreground := clGreen;
          CommentAttri.Style := [fsItalic];
          KeyAttri.Foreground := clBlue;
          KeyAttri.Style := [fsBold];
        end;
    end;

    etDark:
    begin
      // Dark theme highlighter colors
      if Highlighter is TSynJScriptSyn then
        with TSynJScriptSyn(Highlighter) do
        begin
          CommentAttri.Foreground := $0088CC88;
          CommentAttri.Style := [fsItalic];
          KeyAttri.Foreground := $0088AAFF;
          KeyAttri.Style := [fsBold];
          NumberAttri.Foreground := $00FFAA88;
          StringAttri.Foreground := $00FFCC88;
        end
      else if Highlighter is TSynHTMLSyn then
        with TSynHTMLSyn(Highlighter) do
        begin
          CommentAttri.Foreground := $0088CC88;
          CommentAttri.Style := [fsItalic];
          KeyAttri.Foreground := $0088AAFF;
          KeyAttri.Style := [fsBold];
        end
      else if Highlighter is TSynCssSyn then
        with TSynCssSyn(Highlighter) do
        begin
          CommentAttri.Foreground := $0088CC88;
          CommentAttri.Style := [fsItalic];
          KeyAttri.Foreground := $0088AAFF;
          KeyAttri.Style := [fsBold];
        end;
    end;

    etBlue:
    begin
      // Blue theme highlighter colors
      if Highlighter is TSynJScriptSyn then
        with TSynJScriptSyn(Highlighter) do
        begin
          CommentAttri.Foreground := $00008800;
          CommentAttri.Style := [fsItalic];
          KeyAttri.Foreground := $00000099;
          KeyAttri.Style := [fsBold];
          NumberAttri.Foreground := $00990099;
          StringAttri.Foreground := $00993300;
        end;
    end;

    etGreen:
    begin
      // Green theme highlighter colors
      if Highlighter is TSynJScriptSyn then
        with TSynJScriptSyn(Highlighter) do
        begin
          CommentAttri.Foreground := $00669900;
          CommentAttri.Style := [fsItalic];
          KeyAttri.Foreground := $00663300;
          KeyAttri.Style := [fsBold];
          NumberAttri.Foreground := $00996666;
          StringAttri.Foreground := $00669966;
        end;
    end;
  end;
end;

procedure TThemeManager.ApplyToContainer(Container: TWinControl);
var
  i: Integer;
  Control: TControl;
begin
  if Container = nil then Exit;

  // First, apply theme to the container itself
  if Container is TForm then
    ApplyToForm(TForm(Container))
  else if Container is TPanel then
    ApplyToPanel(TPanel(Container))
  else if Container is TcyPageControl then
    ApplyToPageControl(TcyPageControl(Container))
  else if Container is TTabSheet then
    ApplyToTabSheet(TTabSheet(Container))
  else if Container is TStringGrid then
    ApplyToStringGrid(TStringGrid(Container))
  else if Container is TVirtualStringTree then
    ApplyToVirtualTree(TVirtualStringTree(Container))
  else if Container is TMemo then
    ApplyToMemo(TMemo(Container))
  else if Container is TComboBox then
    ApplyToComboBox(TComboBox(Container))
  else if Container is TListBox then
    ApplyToListBox(TListBox(Container))
  else if Container is TEdit then
    ApplyToEdit(TEdit(Container))
  else if Container is TSynEdit then
    ApplyToSynEdit(TSynEdit(Container));

  // If this is a "leaf" control, don't process its children
  if (Container is TStringGrid) or
     (Container is TVirtualStringTree) or
     (Container is TSynEdit) or
     (Container is TEdit) or
     (Container is TMemo) or
     (Container is TComboBox) or
     (Container is TListBox) then
    Exit;

  // For actual containers (Form, Panel, etc.), process children
  for i := 0 to Container.ControlCount - 1 do
  begin
    Control := Container.Controls[i];

    if Control is TWinControl then
    begin
      // Recursively apply to child WinControls
      ApplyToContainer(TWinControl(Control));
    end
    else
    begin
      // Apply to non-WinControl children
      if Control is TLabel then
        ApplyToLabel(TLabel(Control))
      else if Control is TButton then
        ApplyToButton(TButton(Control))
      else if Control is TSpeedButton then
        ApplyToSpeedButton(TSpeedButton(Control))
      else if Control is TCheckBox then
        ApplyToCheckBox(TCheckBox(Control))
      else if Control is TRadioButton then
        ApplyToRadioButton(TRadioButton(Control))
      else if Control is TForm then
        ApplyToForm(TForm(Control));
    end;
  end;
end;

procedure TThemeManager.TestColorScheme(const Name: string;
  BG, Text, Gutter, Selection: TColor);
begin
  // Temporary test colors - doesn't change theme
  FEditorBG := BG;
  FEditorText := Text;
  FGutterBG := Gutter;
  FSelectionBG := Selection;
  FSelectionFG := clWhite;

  FireThemeChanged;
end;

procedure TThemeManager.ResetToDefault;
begin
  UpdateThemeColors; // Revert to current theme defaults
end;

function TThemeManager.GetCurrentThemeName: string;
begin
  case FCurrentTheme of
    etLight: Result := 'Light';
    etDark: Result := 'Dark';
    etBlue: Result := 'Blue';
    etGreen: Result := 'Green';
  else
    Result := 'Unknown';
  end;
end;

function TThemeManager.GetColorValues: string;
begin
  Result := Format('Editor: BG=%.6x, Text=%.6x, Gutter=%.6x, Selection=%.6x',
    [FEditorBG, FEditorText, FGutterBG, FSelectionBG]);
end;

initialization
  ThemeManager := TThemeManager.Create;

finalization
  ThemeManager.Free;

end.
