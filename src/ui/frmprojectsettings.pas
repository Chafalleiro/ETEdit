unit frmProjectSettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, ComCtrls, uProject;

type
  TProjectSettingsForm = class(TForm)
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    PageControl1: TPageControl;
    TabSheetGeneral: TTabSheet;
    TabSheetPublish: TTabSheet;
    edtProjectName: TEdit;
    edtProjectVersion: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtTemplatePath: TEdit;
    Label4: TLabel;
    edtWorkingPath: TEdit;
    Label5: TLabel;
    edtOutputPath: TEdit;
    btnBrowseTemplate: TButton;
    btnBrowseWorking: TButton;
    btnBrowseOutput: TButton;
    rgPublishMethod: TRadioGroup;
    GroupBox1: TGroupBox;
    edtFTPHost: TEdit;
    edtFTPUser: TEdit;
    edtFTPPass: TEdit;
    edtFTPPath: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    btnApply: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnBrowseTemplateClick(Sender: TObject);
    procedure btnBrowseWorkingClick(Sender: TObject);
    procedure btnBrowseOutputClick(Sender: TObject);
    procedure rgPublishMethodClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FProject: TETEditProject;
    FOriginalProject: TETEditProject; // For cancel/rollback
    FOnSettingsApplied: TNotifyEvent;
    FOnSettingsCancelled: TNotifyEvent;
    procedure UpdatePublishControls;
    procedure SaveCurrentState;
    procedure RestoreOriginalState;
  public
    procedure LoadFromProject(AProject: TETEditProject);
    procedure SaveToProject(AProject: TETEditProject);
    property Project: TETEditProject read FProject;
    property OnSettingsApplied: TNotifyEvent read FOnSettingsApplied write FOnSettingsApplied;
    property OnSettingsCancelled: TNotifyEvent read FOnSettingsCancelled write FOnSettingsCancelled;
  end;

//var
//  ProjectSettingsForm: ProjectSettingsForm;

implementation

{$R *.frm}

procedure TProjectSettingsForm.FormCreate(Sender: TObject);
begin
  Caption := 'Project Settings';
  BorderStyle := bsNone; // For docking
  PageControl1.ActivePage := TabSheetGeneral;
end;

procedure TProjectSettingsForm.btnBrowseTemplateClick(Sender: TObject);
var
  SD: TSelectDirectoryDialog;
begin
  SD := TSelectDirectoryDialog.Create(Self);
  try
    if SD.Execute then
      edtTemplatePath.Text := SD.FileName;
  finally
    SD.Free;
  end;
end;

procedure TProjectSettingsForm.btnBrowseWorkingClick(Sender: TObject);
var
  SD: TSelectDirectoryDialog;
begin
  SD := TSelectDirectoryDialog.Create(Self);
  try
    if SD.Execute then
      edtWorkingPath.Text := SD.FileName;
  finally
    SD.Free;
  end;
end;

procedure TProjectSettingsForm.btnBrowseOutputClick(Sender: TObject);
var
  SD: TSelectDirectoryDialog;
begin
  SD := TSelectDirectoryDialog.Create(Self);
  try
    if SD.Execute then
      edtOutputPath.Text := SD.FileName;
  finally
    SD.Free;
  end;
end;

procedure TProjectSettingsForm.rgPublishMethodClick(Sender: TObject);
begin
  UpdatePublishControls;
end;

procedure TProjectSettingsForm.UpdatePublishControls;
begin
  // Mostrar/ocultar controles según el método de publicación
  GroupBox1.Visible := (rgPublishMethod.ItemIndex = 1); // FTP
end;

procedure TProjectSettingsForm.SaveCurrentState;
begin
  if Assigned(FProject) then
  begin
    SaveToProject(FProject);
  end;
end;

procedure TProjectSettingsForm.RestoreOriginalState;
begin
  if Assigned(FOriginalProject) then
  begin
    LoadFromProject(FOriginalProject);
  end;
end;

procedure TProjectSettingsForm.btnApplyClick(Sender: TObject);
begin
  SaveCurrentState;
  if Assigned(FProject) then
  begin
    FProject.SaveProject;
    // Notify main form
    if Assigned(FOnSettingsApplied) then
      FOnSettingsApplied(Self);
  end;
end;

procedure TProjectSettingsForm.btnCancelClick(Sender: TObject);
begin
  RestoreOriginalState;
  // Notify main form
  if Assigned(FOnSettingsCancelled) then
    FOnSettingsCancelled(Self);
end;

procedure TProjectSettingsForm.LoadFromProject(AProject: TETEditProject);
begin
  FProject := AProject;

  // Save original state for cancel
  if Assigned(AProject) and (AProject.ProjectFile <> '') then
  begin
    // Create a temporary copy of the project config
    FOriginalProject := TETEditProject.Create('');
    FOriginalProject.Config.LoadFromFile(AProject.ProjectFile);

    edtProjectName.Text := AProject.ProjectName;
    edtProjectVersion.Text := AProject.Config.GetProjectVersion;
    edtTemplatePath.Text := AProject.TemplatePath;
    edtWorkingPath.Text := AProject.WorkingPath;
    edtOutputPath.Text := AProject.OutputPath;

    // Método de publicación
    case AProject.Config.GetPublishMethod of
      pmNone: rgPublishMethod.ItemIndex := 0;
      pmFTP: rgPublishMethod.ItemIndex := 1;
      pmIPFS: rgPublishMethod.ItemIndex := 2;
      pmGitHub: rgPublishMethod.ItemIndex := 3;
      pmNeutralino: rgPublishMethod.ItemIndex := 4;
      pmLocal: rgPublishMethod.ItemIndex := 5;
    end;

    // Configuración FTP
    edtFTPHost.Text := AProject.Config.GetPublishConfig('host');
    edtFTPUser.Text := AProject.Config.GetPublishConfig('user');
    edtFTPPass.Text := AProject.Config.GetPublishConfig('password');
    edtFTPPath.Text := AProject.Config.GetPublishConfig('path');

    UpdatePublishControls;
  end;
end;

procedure TProjectSettingsForm.SaveToProject(AProject: TETEditProject);
begin
  if Assigned(AProject) then
  begin
    AProject.Config.SetProjectName(edtProjectName.Text);
    AProject.Config.SetProjectVersion(edtProjectVersion.Text);
    AProject.Config.SetTemplatePath(ExtractRelativePath(
      AProject.ProjectPath, edtTemplatePath.Text));
    AProject.Config.SetWorkingPath(ExtractRelativePath(
      AProject.ProjectPath, edtWorkingPath.Text));
    AProject.Config.SetOutputPath(ExtractRelativePath(
      AProject.ProjectPath, edtOutputPath.Text));

    // Método de publicación
    case rgPublishMethod.ItemIndex of
      0: AProject.Config.SetPublishMethod(pmNone);
      1: AProject.Config.SetPublishMethod(pmFTP);
      2: AProject.Config.SetPublishMethod(pmIPFS);
      3: AProject.Config.SetPublishMethod(pmGitHub);
      4: AProject.Config.SetPublishMethod(pmNeutralino);
      5: AProject.Config.SetPublishMethod(pmLocal);
    end;

    // Configuración FTP
    if rgPublishMethod.ItemIndex = 1 then
    begin
      AProject.Config.SetPublishConfig('host', edtFTPHost.Text);
      AProject.Config.SetPublishConfig('user', edtFTPUser.Text);
      AProject.Config.SetPublishConfig('password', edtFTPPass.Text);
      AProject.Config.SetPublishConfig('path', edtFTPPath.Text);
    end;
  end;
end;

end.
