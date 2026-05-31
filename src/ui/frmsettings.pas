unit frmSettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Dialogs, VirtualTrees,
  TypInfo, uConfig, uDebugLog;

type
  PParamNode = ^TParamNode;
  TParamNode = record
    Name: string;
    ParamKey: string;
    ValueType: (vtBoolean, vtInteger, vtString, vtEnum);
    EnumValues: TStrings;
    IntMin, IntMax: Integer;
    TempBoolean: Boolean;
    TempInteger: Integer;
    TempString: string;
  end;

  { TSettings }

  TSettings = class(TForm)
    fontDialog: TFontDialog;
    Tree: TVirtualStringTree;
    PanelDetails: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    btnApply: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure fontDialogShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure TreeGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
    procedure TreeFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
    procedure btnApplyClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    FRootNode: PVirtualNode;
    procedure LoadSettings;
    procedure SaveSettings;
    procedure ShowEditorForNode(Node: PVirtualNode);
    procedure ClearDetails;
    // Event handlers for controls
    procedure OnCheckBoxChange(Sender: TObject);
    procedure OnEditChange(Sender: TObject);
    procedure OnComboBoxChange(Sender: TObject);
  end;

implementation

{$R *.frm}

procedure TSettings.FormCreate(Sender: TObject);
begin
  // Configurar columnas del árbol
  Tree.Header.Columns.Clear;
  with Tree.Header.Columns.Add do
  begin
    Text := 'Parameter';
    Width := 205;
  end;
  with Tree.Header.Columns.Add do
  begin
    Text := 'Value';
    Width := 135;
  end;

  Tree.NodeDataSize := SizeOf(TParamNode);
  Tree.OnGetText := @TreeGetText;
  Tree.OnGetNodeDataSize := @TreeGetNodeDataSize;
  Tree.OnFocusChanged := @TreeFocusChanged;
  LoadSettings;
end;

procedure TSettings.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;


procedure TSettings.fontDialogShow(Sender: TObject);
begin
  fontDialog.DoShow;
end;

procedure TSettings.FormDestroy(Sender: TObject);
var
  Node: PVirtualNode;
  Data: PParamNode;
begin
  Node := Tree.GetFirst;
  while Node <> nil do
  begin
    Data := Tree.GetNodeData(Node);
    if (Data <> nil) and (Data^.EnumValues <> nil) then
      Data^.EnumValues.Free;
    Node := Tree.GetNext(Node);
  end;
end;

procedure TSettings.LoadSettings;
var
  RootNode, Node: PVirtualNode;
  Data: PParamNode;
begin
  Tree.Clear;
  // Categoría General
  FRootNode := Tree.AddChild(nil);
  Data := Tree.GetNodeData(FRootNode);
  Data^.Name := 'General';
  Data^.ParamKey := '';
  Data^.ValueType := vtString;

  // Debug Level
  Node := Tree.AddChild(FRootNode);
  Data := Tree.GetNodeData(Node);
  Data^.Name := 'Debug Level';
  Data^.ParamKey := 'debugLevel';
  Data^.ValueType := vtEnum;
  Data^.EnumValues := TStringList.Create;
  Data^.EnumValues.Add('Debug (0)');
  Data^.EnumValues.Add('Info (1)');
  Data^.EnumValues.Add('Warning (2)');
  Data^.EnumValues.Add('Error (3)');
  Data^.EnumValues.Add('Off (4)');
  Data^.TempInteger := ConfigManager.GetDebugLevel;

  // Log File
  Node := Tree.AddChild(FRootNode);
  Data := Tree.GetNodeData(Node);
  Data^.Name := 'Log File';
  Data^.ParamKey := 'logFileName';
  Data^.ValueType := vtString;
  Data^.TempString := ConfigManager.GetLogFileName;

  // Auto reload files
  Node := Tree.AddChild(FRootNode);
  Data := Tree.GetNodeData(Node);
  Data^.Name := 'Auto reload external changes';
  Data^.ParamKey := 'autoReloadFiles';
  Data^.ValueType := vtBoolean;
  Data^.TempBoolean := ConfigManager.GetAutoReloadFiles;

  // Editor Font Name
  Node := Tree.AddChild(FRootNode);
  Data := Tree.GetNodeData(Node);
  Data^.Name := 'Editor Font Name';
  Data^.ParamKey := 'editorFontName';
  Data^.ValueType := vtString;
  Data^.TempString := ConfigManager.GetEditorFontName;

  // Editor Font Size
  Node := Tree.AddChild(FRootNode);
  Data := Tree.GetNodeData(Node);
  Data^.Name := 'Editor Font Size';
  Data^.ParamKey := 'editorFontSize';
  Data^.ValueType := vtInteger;
  Data^.TempInteger := ConfigManager.GetEditorFontSize;
  Data^.IntMin := 6;
  Data^.IntMax := 72;

  Tree.Expanded[FRootNode] := True;
end;

procedure TSettings.TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  Data: PParamNode;
begin
  Data := Tree.GetNodeData(Node);
  if Data = nil then Exit;
  if Column = 0 then
    CellText := Data^.Name
  else if Column = 1 then
  begin
    case Data^.ValueType of
      vtBoolean: if Data^.TempBoolean then CellText := 'True' else CellText := 'False';
      vtInteger: CellText := IntToStr(Data^.TempInteger);
      vtString: CellText := Data^.TempString;
      vtEnum: if (Data^.TempInteger >= 0) and (Data^.TempInteger < Data^.EnumValues.Count) then
                CellText := Data^.EnumValues[Data^.TempInteger]
              else
                CellText := 'Unknown';
    end;
  end;
end;

procedure TSettings.TreeGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(TParamNode);
end;

procedure TSettings.TreeFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
begin
  ShowEditorForNode(Node);
end;

procedure TSettings.OnCheckBoxChange(Sender: TObject);
var
  chk: TCheckBox;
  Node: PVirtualNode;
  Data: PParamNode;
begin
  chk := Sender as TCheckBox;
  Node := PVirtualNode(chk.Tag);
  if Node <> nil then
  begin
    Data := Tree.GetNodeData(Node);
    if Data <> nil then
      Data^.TempBoolean := chk.Checked;
    Tree.InvalidateNode(Node);
  end;
end;

procedure TSettings.OnEditChange(Sender: TObject);
var
  ed: TEdit;
  Node: PVirtualNode;
  Data: PParamNode;
begin
  ed := Sender as TEdit;
  Node := PVirtualNode(ed.Tag);
  if Node <> nil then
  begin
    Data := Tree.GetNodeData(Node);
    if Data <> nil then
    begin
      case Data^.ValueType of
        vtInteger: Data^.TempInteger := StrToIntDef(ed.Text, Data^.TempInteger);
        vtString: Data^.TempString := ed.Text;
        else ;
      end;
      Tree.InvalidateNode(Node);
    end;
  end;
end;

procedure TSettings.OnComboBoxChange(Sender: TObject);
var
  cb: TComboBox;
  Node: PVirtualNode;
  Data: PParamNode;
begin
  cb := Sender as TComboBox;
  Node := PVirtualNode(cb.Tag);
  if Node <> nil then
  begin
    Data := Tree.GetNodeData(Node);
    if Data <> nil then
      Data^.TempInteger := cb.ItemIndex;
    Tree.InvalidateNode(Node);
  end;
end;

procedure TSettings.ShowEditorForNode(Node: PVirtualNode);
var
  Data: PParamNode;
  cb: TComboBox;
  ed: TEdit;
  chk: TCheckBox;
begin
  ClearDetails;
  if Node = nil then Exit;
  Data := Tree.GetNodeData(Node);
  if (Data = nil) or (Data^.ParamKey = '') then Exit;

  case Data^.ValueType of
    vtBoolean:
      begin
        chk := TCheckBox.Create(PanelDetails);
        chk.Parent := PanelDetails;
        chk.Align := alTop;
        chk.Caption := 'Enabled';
        chk.Checked := Data^.TempBoolean;
        chk.Tag := PtrInt(Node);
        chk.OnChange := @OnCheckBoxChange;
      end;
    vtInteger:
      begin
        ed := TEdit.Create(PanelDetails);
        ed.Parent := PanelDetails;
        ed.Align := alTop;
        ed.Text := IntToStr(Data^.TempInteger);
        ed.Tag := PtrInt(Node);
        ed.OnChange := @OnEditChange;
      end;
    vtString:
      begin
        ed := TEdit.Create(PanelDetails);
        ed.Parent := PanelDetails;
        ed.Align := alTop;
        ed.Text := Data^.TempString;
        ed.Tag := PtrInt(Node);
        ed.OnChange := @OnEditChange;
      end;
    vtEnum:
      begin
        cb := TComboBox.Create(PanelDetails);
        cb.Parent := PanelDetails;
        cb.Align := alTop;
        cb.Items.Assign(Data^.EnumValues);
        cb.ItemIndex := Data^.TempInteger;
        cb.Tag := PtrInt(Node);
        cb.OnChange := @OnComboBoxChange;
      end;
  end;
end;

procedure TSettings.ClearDetails;
begin
  while PanelDetails.ControlCount > 0 do
    PanelDetails.Controls[0].Free;
end;

procedure TSettings.SaveSettings;
var
  Node: PVirtualNode;
  Data: PParamNode;
begin
  Node := Tree.GetFirst;
  while Node <> nil do
  begin
    Data := Tree.GetNodeData(Node);
    if (Data <> nil) and (Data^.ParamKey <> '') then
    begin
      case Data^.ParamKey of
        'editorFontName': ConfigManager.SetEditorFontName(Data^.TempString);
        'editorFontSize': ConfigManager.SetEditorFontSize(Data^.TempInteger);
        'logFileName':    ConfigManager.SetLogFileName(Data^.TempString);
        'debugLevel':     ConfigManager.SetDebugLevel(Data^.TempInteger);
        'autoReloadFile': ConfigManager.SetAutoReloadFiles(Data^.TempBoolean);
      end;
    end;
    Node := Tree.GetNext(Node);
  end;
  ConfigManager.SaveConfig;
end;

procedure TSettings.btnApplyClick(Sender: TObject);
begin
  SaveSettings;
  // Actualizar el logger
  TDebugLogger.SetLogLevel(TDebugLogLevel(ConfigManager.GetDebugLevel));
  TDebugLogger.SetLogFile(ConfigManager.GetLogFileName);
end;

procedure TSettings.btnOKClick(Sender: TObject);
begin
  SaveSettings;
  TDebugLogger.SetLogLevel(TDebugLogLevel(ConfigManager.GetDebugLevel));
  TDebugLogger.SetLogFile(ConfigManager.GetLogFileName);
  ModalResult := mrOk;
end;

end.
