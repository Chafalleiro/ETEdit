object Settings: TSettings
  Left = 487
  Height = 332
  Top = 256
  Width = 732
  Caption = 'Settings'
  ClientHeight = 332
  ClientWidth = 732
  LCLVersion = '8.8'
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  object Tree: TVirtualStringTree
    AnchorSideRight.Control = PanelDetails
    AnchorSideBottom.Control = btnOK
    Left = 8
    Height = 250
    Top = 38
    Width = 362
    Anchors = [akTop, akLeft, akRight, akBottom]
    BorderSpacing.Right = 10
    BorderSpacing.Bottom = 10
    DefaultText = 'Node'
    Header.AutoSizeIndex = -1
    Header.Columns = <>
    Header.MainColumn = -1
    Header.Options = [hoColumnResize, hoDblClickResize, hoDrag, hoShowSortGlyphs, hoVisible]
    TabOrder = 0
    OnFocusChanged = TreeFocusChanged
    OnGetText = TreeGetText
    OnGetNodeDataSize = TreeGetNodeDataSize
  end
  object PanelDetails: TPanel
    AnchorSideBottom.Control = btnOK
    Left = 380
    Height = 250
    Top = 38
    Width = 339
    Anchors = [akTop, akRight, akBottom]
    BorderSpacing.Bottom = 10
    Caption = 'PanelDetails'
    TabOrder = 1
  end
  object btnOK: TButton
    Left = 175
    Height = 24
    Top = 298
    Width = 75
    Anchors = [akBottom]
    BorderSpacing.Bottom = 10
    Caption = 'OK'
    TabOrder = 2
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    AnchorSideLeft.Control = btnOK
    AnchorSideLeft.Side = asrBottom
    Left = 260
    Height = 25
    Top = 298
    Width = 75
    Anchors = [akLeft, akBottom]
    BorderSpacing.Left = 10
    BorderSpacing.Bottom = 10
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = btnCancelClick
  end
  object btnApply: TButton
    AnchorSideLeft.Control = btnCancel
    AnchorSideLeft.Side = asrBottom
    Left = 345
    Height = 25
    Top = 298
    Width = 75
    Anchors = [akLeft, akBottom]
    BorderSpacing.Left = 10
    BorderSpacing.Bottom = 10
    Caption = 'Apply'
    TabOrder = 4
    OnClick = btnApplyClick
  end
  object fontDialog: TFontDialog
    OnShow = fontDialogShow
    Font.CharSet = ANSI_CHARSET
    Font.Height = -19
    Font.Name = 'IBM Plex Mono'
    Font.Pitch = fpFixed
    Font.Quality = fqDraft
    Font.Style = [fsBold]
    MinFontSize = 8
    MaxFontSize = 72
    Options = [fdEffects, fdFixedPitchOnly, fdWysiwyg, fdLimitSize]
    Left = 16
    Top = 8
  end
end
