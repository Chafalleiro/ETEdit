unit frmThemeTester;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ColorBox, ComCtrls,
  uThemeManager, VirtualTrees, TplTabsPanelsUnit
  ;  // Add uThemeManager here

type
  { TThemeTesterForm }
  TThemeTesterForm = class(TForm)
    cbEditorBG: TColorBox;
    cbEditorText: TColorBox;
    cbGutterBG: TColorBox;
    cbSelectionBG: TColorBox;
    ColorBox5: TColorBox;
    lblThemeName: TLabeledEdit;
    PanelPage1: TplPanelPage;
    PanelPage2: TplPanelPage;
    plPanelPages1: TplPanelPages;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;



    procedure btnApplyClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure RadioButton1Change(Sender: TObject);
  private
    procedure UpdateColorBoxes;
    procedure UpdateThemeInfo;
  public
    procedure RefreshFromTheme;
  end;

var
  ThemeTesterForm: TThemeTesterForm;

implementation

{$R *.frm}

{ TThemeTesterForm }

procedure TThemeTesterForm.FormCreate(Sender: TObject);
begin
  Caption := 'Theme Tester';

  // Setup color boxes with common editor colors
  cbEditorBG.Style := [cbStandardColors, cbExtendedColors, cbCustomColor];
  cbEditorText.Style := [cbStandardColors, cbExtendedColors, cbCustomColor];
  cbGutterBG.Style := [cbStandardColors, cbExtendedColors, cbCustomColor];
  cbSelectionBG.Style := [cbStandardColors, cbExtendedColors, cbCustomColor];

  UpdateThemeInfo;
  UpdateColorBoxes;
end;

procedure TThemeTesterForm.UpdateColorBoxes;
begin
  cbEditorBG.Selected := ThemeManager.EditorBG;
  cbEditorText.Selected := ThemeManager.EditorText;
  cbGutterBG.Selected := ThemeManager.GutterBG;

  // Show current theme info
  lblThemeName.Caption := 'Current: ' + ThemeManager.GetCurrentThemeName;
  lblThemeName.Font.Color := clBlue;
end;

procedure TThemeTesterForm.UpdateThemeInfo;
begin
  case ThemeManager.CurrentTheme of
    etLight: RadioButton1.Checked := True;
    etDark: RadioButton2.Checked := True;
    etBlue: RadioButton3.Checked := True;
    etGreen: RadioButton4.Checked := True;
  end;
end;

procedure TThemeTesterForm.RefreshFromTheme;
begin
  UpdateThemeInfo;
  UpdateColorBoxes;
end;

procedure TThemeTesterForm.RadioButton1Change(Sender: TObject);
begin
  if RadioButton1.Checked then
    ThemeManager.ApplyTheme(etLight)
  else if RadioButton2.Checked then
    ThemeManager.ApplyTheme(etDark)
  else if RadioButton3.Checked then
    ThemeManager.ApplyTheme(etBlue)
  else if RadioButton4.Checked then
    ThemeManager.ApplyTheme(etGreen);

  UpdateColorBoxes;
end;

procedure TThemeTesterForm.btnTestClick(Sender: TObject);
begin
  // Test the selected colors without changing theme
  ThemeManager.TestColorScheme('Custom',
    cbEditorBG.Selected,
    cbEditorText.Selected,
    cbGutterBG.Selected,
    cbSelectionBG.Selected);

  ShowMessage('Test colors applied. Click Reset to revert.');
end;

procedure TThemeTesterForm.btnApplyClick(Sender: TObject);
var
  NewTheme: TEditorTheme;
begin
  // Determine which theme radio is selected
  if RadioButton1.Checked then
    NewTheme := etLight
  else if RadioButton2.Checked then
    NewTheme := etDark
  else if RadioButton3.Checked then
    NewTheme := etBlue
  else
    NewTheme := etGreen;

  // Update theme with custom colors
  ThemeManager.ApplyTheme(NewTheme);

  ShowMessage('Theme applied: ' + ThemeManager.GetCurrentThemeName);
end;

procedure TThemeTesterForm.btnResetClick(Sender: TObject);
begin
  ThemeManager.ResetToDefault;
  UpdateColorBoxes;
  ShowMessage('Reset to theme defaults');
end;

end.
