object PluginHostForm: TPluginHostForm
  Left = 315
  Height = 344
  Top = 256
  Width = 460
  Align = alClient
  AutoSize = True
  Caption = 'PluginHostForm'
  ChildSizing.EnlargeHorizontal = crsSameSize
  ChildSizing.EnlargeVertical = crsHomogenousChildResize
  ChildSizing.ShrinkHorizontal = crsHomogenousChildResize
  ChildSizing.ShrinkVertical = crsHomogenousSpaceResize
  ClientHeight = 344
  ClientWidth = 460
  ShowInTaskBar = stAlways
  LCLVersion = '8.8'
  OnClose = FormClose
  object Memo1: TMemo
    Left = 0
    Height = 344
    Top = 0
    Width = 460
    Align = alClient
    Lines.Strings = (
      'Memo1'
    )
    TabOrder = 0
  end
end
