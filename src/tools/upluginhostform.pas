unit uPluginHostForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, Forms, Controls, ExtCtrls, StdCtrls, DAV_GuiButton;  // Añadido 'Classes'

type

  { TPluginHostForm }

  TPluginHostForm = class(TForm)
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  public
    ClientPanel: TPanel;
    Memo1: TMemo;
    constructor Create(AOwner: TComponent); reintroduce;  // reintroduce, no override
  end;

function CreatePluginHostForm(const aName, aTitle: string; DisableAutoSizing: boolean): TPluginHostForm;

implementation

procedure TPluginHostForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin

end;

constructor TPluginHostForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ClientPanel := TPanel.Create(Self);
  ClientPanel.Parent := Self;
  ClientPanel.Align := alClient;
  ClientPanel.BevelOuter := bvNone;
  BorderStyle := bsNone;

  Memo1 := TMemo.Create(ClientPanel);
  Memo1.Parent := ClientPanel;
  Memo1.Align := alClient;
  Memo1.ReadOnly := True;
  Memo1.Lines.Text := 'Plugin container ready';
end;

function CreatePluginHostForm(const aName, aTitle: string; DisableAutoSizing: boolean): TPluginHostForm;
begin
  Result := TPluginHostForm(Screen.FindForm(aName));
  if Result <> nil then
  begin
    if DisableAutoSizing then Result.DisableAutoSizing;
    Exit;
  end;
  Result := TPluginHostForm.Create(Application);
  if DisableAutoSizing then Result.DisableAutoSizing;
  Result.Name := aName;
  Result.Caption := aTitle;
  Result.SetBounds(200, 200, 600, 400);
  if not DisableAutoSizing then Result.EnableAutoSizing;
end;

end.
