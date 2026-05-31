object ProjectSettingsForm: TProjectSettingsForm
  Left = 0
  Height = 500
  Top = 0
  Width = 600
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Project Settings'
  ClientHeight = 500
  ClientWidth = 600
  Color = clBtnFace
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Position = poScreenCenter
  LCLVersion = '4.4.0.0'
  OnCreate = FormCreate
  object PageControl1: TPageControl
    Left = 0
    Height = 500
    Top = 0
    Width = 600
    ActivePage = TabSheetGeneral
    Align = alClient
    TabIndex = 0
    TabOrder = 0
    object TabSheetGeneral: TTabSheet
      Caption = 'General'
      ClientHeight = 472
      ClientWidth = 592
      object Label1: TLabel
        Left = 20
        Height = 15
        Top = 20
        Width = 35
        Caption = 'Name:'
      end
      object Label2: TLabel
        Left = 20
        Height = 15
        Top = 60
        Width = 41
        Caption = 'Version:'
      end
      object Label3: TLabel
        Left = 20
        Height = 15
        Top = 100
        Width = 78
        Caption = 'Template Path:'
      end
      object Label4: TLabel
        Left = 20
        Height = 15
        Top = 140
        Width = 75
        Caption = 'Working Path:'
      end
      object Label5: TLabel
        Left = 20
        Height = 15
        Top = 180
        Width = 68
        Caption = 'Output Path:'
      end
      object edtProjectName: TEdit
        Left = 120
        Height = 23
        Top = 17
        Width = 300
        TabOrder = 0
      end
      object edtProjectVersion: TEdit
        Left = 120
        Height = 23
        Top = 57
        Width = 100
        TabOrder = 1
      end
      object edtTemplatePath: TEdit
        Left = 120
        Height = 23
        Top = 97
        Width = 350
        TabOrder = 2
      end
      object edtWorkingPath: TEdit
        Left = 120
        Height = 23
        Top = 137
        Width = 350
        TabOrder = 3
      end
      object edtOutputPath: TEdit
        Left = 120
        Height = 23
        Top = 177
        Width = 350
        TabOrder = 4
      end
      object btnBrowseTemplate: TButton
        Left = 480
        Height = 25
        Top = 96
        Width = 75
        Caption = 'Browse...'
        TabOrder = 5
        OnClick = btnBrowseTemplateClick
      end
      object btnBrowseWorking: TButton
        Left = 480
        Height = 25
        Top = 136
        Width = 75
        Caption = 'Browse...'
        TabOrder = 6
        OnClick = btnBrowseWorkingClick
      end
      object btnBrowseOutput: TButton
        Left = 480
        Height = 25
        Top = 176
        Width = 75
        Caption = 'Browse...'
        TabOrder = 7
        OnClick = btnBrowseOutputClick
      end
    end
    object TabSheetPublish: TTabSheet
      Caption = 'Publish'
      ClientHeight = 472
      ClientWidth = 592
      ImageIndex = 1
      object rgPublishMethod: TRadioGroup
        Left = 20
        Height = 120
        Top = 20
        Width = 550
        AutoFill = True
        Caption = 'Publish Method'
        ChildSizing.LeftRightSpacing = 6
        ChildSizing.EnlargeHorizontal = crsHomogenousChildResize
        ChildSizing.EnlargeVertical = crsHomogenousChildResize
        ChildSizing.ShrinkHorizontal = crsScaleChilds
        ChildSizing.ShrinkVertical = crsScaleChilds
        ChildSizing.Layout = cclLeftToRightThenTopToBottom
        ChildSizing.ControlsPerLine = 1
        ClientHeight = 100
        ClientWidth = 546
        Items.Strings = (
          'None'
          'FTP'
          'IPFS'
          'GitHub'
          'Neutralino'
          'Local'
        )
        ParentBackground = False
        TabOrder = 0
        OnClick = rgPublishMethodClick
      end
      object GroupBox1: TGroupBox
        Left = 20
        Height = 200
        Top = 160
        Width = 550
        Caption = 'FTP Settings'
        ClientHeight = 180
        ClientWidth = 546
        ParentBackground = False
        TabOrder = 1
        object Label6: TLabel
          Left = 20
          Height = 15
          Top = 30
          Width = 28
          Caption = 'Host:'
        end
        object Label7: TLabel
          Left = 20
          Height = 15
          Top = 70
          Width = 26
          Caption = 'User:'
        end
        object Label8: TLabel
          Left = 20
          Height = 15
          Top = 110
          Width = 53
          Caption = 'Password:'
        end
        object Label9: TLabel
          Left = 20
          Height = 15
          Top = 150
          Width = 27
          Caption = 'Path:'
        end
        object edtFTPHost: TEdit
          Left = 100
          Height = 23
          Top = 27
          Width = 400
          TabOrder = 0
        end
        object edtFTPUser: TEdit
          Left = 100
          Height = 23
          Top = 67
          Width = 200
          TabOrder = 1
        end
        object edtFTPPass: TEdit
          Left = 100
          Height = 23
          Top = 107
          Width = 200
          EchoMode = emPassword
          PasswordChar = '*'
          TabOrder = 2
        end
        object edtFTPPath: TEdit
          Left = 100
          Height = 23
          Top = 147
          Width = 400
          TabOrder = 3
        end
      end
    end
  end
  object btnApply: TButton
    Left = 480
    Height = 25
    Top = 460
    Width = 100
    Anchors = [akRight, akBottom]
    Caption = 'Apply'
    TabOrder = 1
    OnClick = btnApplyClick
  end
end
