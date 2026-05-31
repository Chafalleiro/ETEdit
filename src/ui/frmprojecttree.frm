object ProjectTreeForm: TProjectTreeForm
  Left = 344
  Height = 496
  Top = 256
  Width = 416
  Align = alClient
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'ProjectTree'
  ChildSizing.Layout = cclLeftToRightThenTopToBottom
  ClientHeight = 496
  ClientWidth = 416
  DockSite = True
  FormStyle = fsMDIChild
  ShowInTaskBar = stAlways
  UseDockManager = True
  LCLVersion = '8.8'
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  object VirtualStringTree1: TVirtualStringTree
    AnchorSideTop.Control = TreeFilterEdit1
    AnchorSideTop.Side = asrBottom
    AnchorSideBottom.Side = asrBottom
    Left = 0
    Height = 211
    Top = 30
    Width = 416
    Align = alClient
    Anchors = [akTop, akLeft, akRight]
    BorderSpacing.Top = 30
    Constraints.MinHeight = 100
    DefaultText = 'Node'
    DragMode = dmAutomatic
    Header.AutoSizeIndex = -1
    Header.Columns = <>
    Header.Height = 20
    Header.MainColumn = -1
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs]
    TabOrder = 0
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toEditable, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toReportMode, toToggleOnDblClick, toWheelPanning, toVariableNodeHeight, toNodeHeightResize, toEditOnClick]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages, toGhostedIfUnfocused, toUseBlendedSelection]
    TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect, toRightClickSelect]
    OnContextPopup = VirtualStringTree1ContextPopup
    OnFreeNode = VirtualStringTree1FreeNode
  end
  object PanelDetails: TPanel
    Left = 0
    Height = 250
    Top = 246
    Width = 416
    Align = alBottom
    Caption = 'NO PREVIEW'
    ClientHeight = 250
    ClientWidth = 416
    Constraints.MinHeight = 150
    TabOrder = 1
    Visible = False
    object PageControl1: TPageControl
      Left = 1
      Height = 248
      Top = 1
      Width = 414
      ActivePage = TabSheetDetails
      Align = alClient
      TabIndex = 0
      TabOrder = 0
      object TabSheetDetails: TTabSheet
        Caption = 'Details'
        ClientHeight = 220
        ClientWidth = 406
        object ScrollBox1: TScrollBox
          Left = 0
          Height = 220
          Top = 0
          Width = 406
          HorzScrollBar.Page = 235
          VertScrollBar.Page = 95
          Align = alClient
          ClientHeight = 216
          ClientWidth = 402
          TabOrder = 0
          object GroupBox2: TGroupBox
            Left = 0
            Height = 216
            Top = 0
            Width = 402
            Align = alClient
            ClientHeight = 196
            ClientWidth = 398
            TabOrder = 0
            object lblFileName: TLabel
              AnchorSideLeft.Control = GroupBox2
              AnchorSideTop.Control = lblFilePath
              AnchorSideTop.Side = asrBottom
              Left = 5
              Height = 15
              Top = 15
              Width = 63
              BorderSpacing.Left = 5
              Caption = 'lblFileName'
            end
            object lblFilePath: TLabel
              AnchorSideLeft.Control = GroupBox2
              AnchorSideTop.Control = GroupBox2
              Left = 5
              Height = 15
              Top = 0
              Width = 55
              BorderSpacing.Left = 5
              Caption = 'lblFilePath'
              Constraints.MaxWidth = 380
              WordWrap = True
            end
            object lblFileSize: TLabel
              AnchorSideLeft.Control = GroupBox2
              AnchorSideTop.Control = lblFileType
              AnchorSideTop.Side = asrBottom
              Left = 5
              Height = 15
              Top = 45
              Width = 51
              BorderSpacing.Left = 5
              Caption = 'lblFileSize'
            end
            object lblModified: TLabel
              AnchorSideLeft.Control = lblFileName
              AnchorSideLeft.Side = asrBottom
              AnchorSideTop.Control = lblFilePath
              AnchorSideTop.Side = asrBottom
              AnchorSideRight.Control = GroupBox2
              AnchorSideRight.Side = asrBottom
              Left = 78
              Height = 15
              Top = 15
              Width = 61
              BorderSpacing.Left = 10
              BorderSpacing.Right = 80
              Caption = 'lblModified'
            end
            object lblFileType: TLabel
              AnchorSideLeft.Control = GroupBox2
              AnchorSideTop.Control = lblModified
              AnchorSideTop.Side = asrBottom
              Left = 5
              Height = 15
              Top = 30
              Width = 55
              BorderSpacing.Left = 5
              Caption = 'lblFileType'
            end
            object lblDimensions: TLabel
              AnchorSideLeft.Control = lblFileSize
              AnchorSideLeft.Side = asrBottom
              AnchorSideTop.Control = lblFileType
              AnchorSideTop.Side = asrBottom
              Left = 66
              Height = 15
              Top = 45
              Width = 75
              BorderSpacing.Left = 10
              Caption = 'lblDimensions'
            end
            object lblFontInfo: TLabel
              AnchorSideLeft.Control = lblFileSize
              AnchorSideLeft.Side = asrBottom
              AnchorSideTop.Control = lblFileType
              AnchorSideTop.Side = asrBottom
              Left = 66
              Height = 15
              Top = 45
              Width = 46
              BorderSpacing.Left = 10
              Caption = 'font info'
            end
            object lblColorDepth: TLabel
              AnchorSideLeft.Control = lblFileType
              AnchorSideLeft.Side = asrBottom
              AnchorSideTop.Control = lblFileName
              AnchorSideTop.Side = asrBottom
              Left = 70
              Height = 1
              Top = 30
              Width = 1
              BorderSpacing.Left = 10
            end
            object lblPreviewInfo: TLabel
              AnchorSideLeft.Control = GroupBox2
              AnchorSideTop.Control = lblFileSize
              AnchorSideTop.Side = asrBottom
              AnchorSideBottom.Control = btnOpenLocation
              Left = 5
              Height = 15
              Top = 60
              Width = 64
              BorderSpacing.Left = 5
              Caption = 'preview info'
              Font.Color = clGrayText
              Font.Style = [fsItalic]
              ParentFont = False
            end
            object btnProperties: TButton
              AnchorSideLeft.Control = btnOpenLocation
              AnchorSideLeft.Side = asrBottom
              AnchorSideBottom.Control = GroupBox2
              AnchorSideBottom.Side = asrBottom
              Left = 156
              Height = 25
              Top = 161
              Width = 75
              Anchors = [akLeft, akBottom]
              BorderSpacing.Left = 10
              BorderSpacing.Bottom = 10
              Caption = 'Properties'
              TabOrder = 0
              OnClick = btnPropertiesClick
            end
            object btnOpenLocation: TButton
              AnchorSideLeft.Control = GroupBox2
              AnchorSideBottom.Control = GroupBox2
              AnchorSideBottom.Side = asrBottom
              Left = 10
              Height = 25
              Top = 161
              Width = 136
              Anchors = [akLeft, akBottom]
              BorderSpacing.Left = 10
              BorderSpacing.Bottom = 10
              Caption = 'Open location'
              TabOrder = 1
              OnClick = btnOpenLocationClick
            end
          end
        end
      end
      object TabSheetPreview: TTabSheet
        Caption = 'Preview'
        ClientHeight = 220
        ClientWidth = 290
        object memoPreview: TMemo
          Left = 0
          Height = 220
          Top = 0
          Width = 290
          Align = alClient
          Lines.Strings = (
            'memoPreview'
          )
          ScrollBars = ssAutoBoth
          TabOrder = 0
          WordWrap = False
        end
        object PanelImageInfo: TPanel
          Left = 0
          Height = 220
          Top = 0
          Width = 290
          Align = alClient
          ClientHeight = 220
          ClientWidth = 290
          TabOrder = 1
          object imgPreview: TImage
            AnchorSideTop.Control = PanelImageInfo
            AnchorSideTop.Side = asrBottom
            Left = 6
            Height = 178
            Top = 36
            Width = 278
            Align = alClient
            Anchors = [akTop]
            AutoSize = True
            BorderSpacing.Top = 30
            BorderSpacing.Around = 5
            Center = True
            Proportional = True
          end
          object btnCopyImage: TSpeedButton
            AnchorSideLeft.Control = PanelImageInfo
            AnchorSideTop.Control = PanelImageInfo
            Left = 6
            Height = 24
            Top = 6
            Width = 24
            BorderSpacing.Around = 5
            Visible = False
            OnClick = btnCopyImageClick
          end
          object btnSaveImage: TSpeedButton
            AnchorSideLeft.Control = btnCopyImage
            AnchorSideLeft.Side = asrBottom
            AnchorSideTop.Control = PanelImageInfo
            Left = 40
            Height = 24
            Top = 6
            Width = 24
            BorderSpacing.Left = 5
            BorderSpacing.Around = 5
            Visible = False
            OnClick = btnSaveImageClick
          end
          object btnOpenInBrowser: TSpeedButton
            AnchorSideLeft.Control = btnSaveImage
            AnchorSideLeft.Side = asrBottom
            AnchorSideTop.Control = PanelImageInfo
            Left = 69
            Height = 24
            Top = 6
            Width = 24
            BorderSpacing.Left = 5
            BorderSpacing.Top = 5
            Visible = False
            OnClick = btnOpenInBrowserClick
          end
          object lblImageFormat: TLabel
            AnchorSideLeft.Control = btnOpenInBrowser
            AnchorSideLeft.Side = asrBottom
            AnchorSideTop.Control = PanelImageInfo
            Left = 98
            Height = 15
            Top = 11
            Width = 84
            BorderSpacing.Left = 5
            BorderSpacing.Top = 10
            Caption = 'lblImageFormat'
            Visible = False
          end
          object lblImageSizeKB: TLabel
            AnchorSideLeft.Control = lblImageFormat
            AnchorSideLeft.Side = asrBottom
            AnchorSideTop.Control = PanelImageInfo
            Left = 187
            Height = 15
            Top = 6
            Width = 80
            BorderSpacing.Left = 5
            BorderSpacing.Top = 5
            Caption = 'lblImageSizeKB'
            Visible = False
          end
          object lblImageResolution: TLabel
            AnchorSideLeft.Control = lblImageSizeKB
            AnchorSideLeft.Side = asrBottom
            AnchorSideTop.Control = PanelImageInfo
            Left = 272
            Height = 15
            Top = 6
            Width = 102
            BorderSpacing.Left = 5
            BorderSpacing.Top = 5
            Caption = 'lblImageResolution'
            Visible = False
          end
        end
        object PanelFontPreview: TPanel
          Left = 0
          Height = 220
          Top = 0
          Width = 290
          Align = alClient
          Caption = 'PanelFontPreview'
          ClientHeight = 220
          ClientWidth = 290
          TabOrder = 2
          Visible = False
          object GroupBox1: TGroupBox
            Left = 1
            Height = 218
            Top = 1
            Width = 288
            Align = alClient
            ClientHeight = 198
            ClientWidth = 284
            TabOrder = 0
            object cmbFontSize: TComboBox
              AnchorSideLeft.Control = GroupBox1
              AnchorSideTop.Control = GroupBox1
              Left = 5
              Height = 23
              Top = 10
              Width = 100
              BorderSpacing.Top = 5
              BorderSpacing.Around = 5
              ItemHeight = 15
              Items.Strings = (
                '8'
                '9'
                '10'
                '11'
                '12'
                '14'
                '16'
                '18'
                '20'
                '24'
                '28'
                '30'
                '40'
              )
              TabOrder = 0
              Text = 'cmbFontSize'
              OnChange = cmbFontSizeChange
            end
            object lblFontFormat: TLabel
              AnchorSideLeft.Control = cmbFontSize
              AnchorSideLeft.Side = asrBottom
              AnchorSideTop.Control = lblFontName
              AnchorSideTop.Side = asrBottom
              Left = 145
              Height = 15
              Top = 15
              Width = 75
              BorderSpacing.Left = 40
              Caption = 'lblFontFormat'
            end
            object btnIncreaseFont: TSpeedButton
              AnchorSideLeft.Control = cmbFontSize
              AnchorSideLeft.Side = asrBottom
              AnchorSideTop.Control = GroupBox1
              Left = 115
              Height = 22
              Top = 0
              Width = 23
              BorderSpacing.Left = 10
              OnClick = btnIncreaseFontClick
            end
            object btnDecreaseFont: TSpeedButton
              AnchorSideLeft.Control = cmbFontSize
              AnchorSideLeft.Side = asrBottom
              AnchorSideTop.Control = btnIncreaseFont
              AnchorSideTop.Side = asrBottom
              Left = 115
              Height = 22
              Top = 27
              Width = 23
              BorderSpacing.Left = 10
              BorderSpacing.Top = 5
              OnClick = btnDecreaseFontClick
            end
            object lblFontStyle: TLabel
              AnchorSideLeft.Control = cmbFontSize
              AnchorSideLeft.Side = asrBottom
              AnchorSideTop.Control = lblFontFormat
              AnchorSideTop.Side = asrBottom
              Left = 145
              Height = 15
              Top = 30
              Width = 62
              BorderSpacing.Left = 40
              Caption = 'lblFontStyle'
            end
            object lblFontName: TLabel
              AnchorSideLeft.Control = cmbFontSize
              AnchorSideLeft.Side = asrBottom
              AnchorSideTop.Control = GroupBox1
              Left = 145
              Height = 15
              Top = 0
              Width = 69
              BorderSpacing.Left = 40
              Caption = 'lblFontName'
            end
            object lblFontSample: TLabel
              AnchorSideTop.Control = GroupBox1
              AnchorSideTop.Side = asrBottom
              Left = 0
              Height = 148
              Top = 50
              Width = 284
              Align = alClient
              Anchors = [akTop]
              BorderSpacing.Top = 50
              Caption = 'lblFontSample'
            end
          end
        end
      end
    end
  end
  object Splitter1: TSplitter
    Cursor = crVSplit
    Left = 0
    Height = 5
    Top = 241
    Width = 416
    Align = alBottom
    ResizeAnchor = akBottom
    Visible = False
  end
  object TreeFilterEdit1: TTreeFilterEdit
    AnchorSideLeft.Control = FilterComboBox1
    AnchorSideLeft.Side = asrBottom
    AnchorSideTop.Control = Owner
    AnchorSideRight.Control = Owner
    AnchorSideRight.Side = asrBottom
    AnchorSideBottom.Control = Owner
    AnchorSideBottom.Side = asrBottom
    Left = 122
    Height = 23
    Top = 5
    Width = 284
    ButtonWidth = 23
    Align = alCustom
    Anchors = [akTop, akLeft, akRight]
    BorderSpacing.Left = 10
    BorderSpacing.Top = 5
    BorderSpacing.Right = 10
    BorderSpacing.Bottom = 10
    NumGlyphs = 1
    MaxLength = 0
    TabOrder = 3
  end
  object btnFilterSort: TSpeedButton
    AnchorSideLeft.Control = Owner
    AnchorSideTop.Control = Owner
    Left = 5
    Height = 22
    Top = 5
    Width = 22
    BorderSpacing.Left = 5
    BorderSpacing.Top = 5
    Glyph.Data = {
      C6070000424DC607000000000000360000002800000016000000160000000100
      2000000000009007000064000000640000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000FF000000FF0000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      FFBF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF40FFFF
      FF00FFFFFF000000000000000000050405FF050505FF0000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FFBF0000FFFF0000
      FFFF0000FFCF0000FFBF0000FFBF0000FFBF0000FF30FFFFFF00FFFFFF000000
      00000A0A0AFF09090AFF090A09FF0A0A0AFF00000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000FF400000FFFF0000FFFF0000FFBFFFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000101010FF1010
      0FFF100F10FF0F1010FF00000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000FF800000FFFF0000FFFF0000FF80FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00161616FF161617FF171616FF171617FF1616
      16FF171616FFFFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000FFCF0000FFFF0000FFFF0000FF30FFFFFF00FFFFFF00FFFF
      FF00FFFFFF001E1D1DFF1D1D1DFF1E1D1DFF1D1D1DFF1D1D1DFF1E1D1DFFFFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      FF200000FFEF0000FFFF0000FFDF0000FF10FFFFFF00FFFFFF00FFFFFF000000
      000000000000252525FF252525FF0000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF600000
      FFFF0000FFFF0000FF9FFFFFFF00FFFFFF00FFFFFF0000000000000000002D2D
      2DFF2D2D2DFF0000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000FF800000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000
      FFFFFFFFFF00FFFFFF00FFFFFF000000000000000000363636FF363636FF0000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      FF600000FFBF0000FFBF0000FFBF0000FFBF0000FFBF0000FFBFFFFFFF00FFFF
      FF00FFFFFF0000000000000000003F3F3FFF3F3F3FFF0000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      000000000000494848FF484948FF0000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000005252
      52FF525252FF0000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00C55800BFC55800BFC5580040FFFFFF00FFFFFF00C5580050C558
      00BFC55800BFFFFFFF00FFFFFF0000000000000000005C5C5BFF5C5C5CFF0000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C558
      00CFC55800FFC558009FFFFFFF00FFFFFF00C55800AFC55800FFC55800CFFFFF
      FF00FFFFFF000000000000000000666666FF666666FF0000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C5580070C55800FFC558
      00FFC55800FFC55800FFC55800FFC55800FFC5580070FFFFFF00FFFFFF000000
      000000000000707070FF707070FF0000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00C5580020C55800FFC55800FFC55800CFC558
      00DFC55800FFC55800FFC5580020FFFFFF00FFFFFF0000000000000000007B7B
      7AFF7A7B7AFF0000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00C55800CFC55800FFC5580080C558008FC55800FFC558
      00CFFFFFFF00FFFFFF00FFFFFF000000000000000000858484FF858585FF0000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00C5580070C55800FFC55800CFC55800DFC55800FFC5580070FFFFFF00FFFF
      FF00FFFFFF0000000000000000008F8F8FFF8F8F8FFF0000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C5580020C558
      00FFC55800FFC55800FFC55800FFC5580020FFFFFF00FFFFFF00FFFFFF000000
      000000000000999999FF999999FF0000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C55800CFC55800FFC558
      00FFC55800CFFFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000A3A3
      A3FFA3A3A3FF0000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00C5580070C55800FFC55800FFC5580070FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000ADADADFFADADADFF0000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00
    }
  end
  object FilterComboBox1: TComboBox
    AnchorSideLeft.Control = btnFilterSort
    AnchorSideLeft.Side = asrBottom
    AnchorSideTop.Control = Owner
    Left = 32
    Height = 23
    Top = 5
    Width = 80
    BorderSpacing.Left = 5
    BorderSpacing.Top = 5
    Constraints.MaxWidth = 80
    ItemHeight = 15
    ItemIndex = 0
    Items.Strings = (
      'All'
      'Html'
      'Css'
      'JavaScript'
      'Json'
      'Svg'
      'Xml'
      'Images'
      'Fonts'
    )
    TabOrder = 4
    Text = 'All'
    OnChange = FilterComboBox1Change
  end
  object PopupMenu1: TPopupMenu
    OwnerDraw = True
    OnPopup = PopupMenu1Popup
    Left = 16
    Top = 48
    object Open1: TMenuItem
      Caption = '&Open'
      ShortCut = 13
      OnClick = Open1Click
    end
    object mnuOpenWith: TMenuItem
      Caption = 'Open With'
    end
    object NewFile1: TMenuItem
      Caption = 'New File...'
      ShortCut = 16462
      OnClick = NewFile1Click
    end
    object NewFolder1: TMenuItem
      Caption = '&New Folder'
      ShortCut = 24654
      OnClick = NewFolder1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Rename1: TMenuItem
      Caption = '&Rename'
      ShortCut = 113
      OnClick = Rename1Click
    end
    object Delete1: TMenuItem
      Caption = '&Delete'
      ShortCut = 46
      OnClick = Delete1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Refresh1: TMenuItem
      Caption = '&Refresh'
      ShortCut = 116
      OnClick = Refresh1Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object OptimizeImage1: TMenuItem
      Caption = 'Optimize Image'
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object OpenLoc: TMenuItem
      Caption = 'Open Location'
      OnClick = btnOpenLocationClick
    end
    object Properties1: TMenuItem
      Caption = 'Properties'
      OnClick = btnPropertiesClick
    end
  end
  object ImageList1: TImageList
    Left = 16
    Top = 104
    Bitmap = {
      4C7A100000001000000010000000121600000000000078DAED9B095814C7B6C7
      1B114444340AEE2B0CEB2046D1004A22C125A2808AC14445DC972CA202EE22E3
      4E24372A51E31245E30E82A0898AA8EC228ACA0E32A8AC332CB208030828E79E
      1A6AB0196658726FDECBBBF7CDF7FDBEEAAEE97F9DAAEA3E55A76A7A008081BF
      190E0EA0386142C5622466F4E8B2A4C1835FEFD6D028EEDE5EFDA44995ABE7CC
      A96970727A0BD6D622D0D72F013535E1158649516E8FDECAAAE2C5D2A575E0EC
      5C0FF6F6D53062442974EF5E50C130B9C6EDD18F1D5B566E6B5B055F7E590D58
      16703825D0A58BB08E61F2CCDBA31F3EBC3868E4C832C0B6839E5E09F4EC5900
      0A0A824C8629E8235FC728547ACF302C3F386363A8F3F25FCC380F4A7AF410D6
      A9A808DF29F71154E9F05E077C1C5BE63130AAF87326143A4BEB2B0E3BCCAA3A
      E154567D7211541CB2877C0FAB9A9D93DC8F6B5A09374E7D202A9D9D5A0D93E2
      2B41FF414983FA3DC16E142948B4453C4B35D191AF126BCFAF86FACB2E203A36
      1F4AF64D04E146A314FB98577F3865BC8535AFEAC121AD06463F2A839EF70A2A
      99908211127D81D7943E9587EC6B6B7C9643ED6FDF40E591AFA064CFE720D8C0
      AD9D199E5AF525DA5E94510BB6C95530E26129A8DD133630B7F21C24FA129EA9
      3ADA7B517EC00EDE1C9C09A53F4C81C26D6320DF45EFD5F87BE90F4CE3CAE1B3
      671562DB03238A403138BF9A09C93363B71FAF5F59B8DDB4BAC8C30C0A367F0C
      F96EFA35F9AE3AABFB861698F50D2B2C1E105E04BD420B412958F09EB99DEF83
      A24E6C7DDC0A1325A1ABAE75BEABDEA97C575D9F3C171D1B386EA244BE53BA27
      18AD182CF446DD05E6966025135CD00DFE867EF7BFC9D088AAFE3AA1952B9155
      9C30D102CE4D7E978EE88D23AB6E1ECDA98763B9F5B039A30EB09C639CB06A87
      0F543AE88557CE21A9615425B785CF4657C5C7550210C2CB1BE0C7AC7AF07A55
      F7217DD598EE79212EFB92B4DE284214BF2EAD165C907552B8A47F385E9D5A2B
      53AF13268A47A0752A25C72DF5A1A80F95BA3EB4525E592DF4BAEDB22F5FCFAE
      3F47865DBCA70DAC36FCC9F637A22B535F19C4091509D18E10BF17A7E45C37EC
      0392EFB08CFDFFEF737F1F4CE24049E7BE683FDE9BDFF01EFDA61356E5CD89A8
      D46CAF9E135EB1C439F52DF816BE07DF8277E0915907BAE195813A61158BF15E
      2F16A711A245E4583B5CB4F0E3D0B29E6CBD76A8C895F8B9C4FFEF9536000FCB
      F0E0D7D1B4B6E97C7A5C0D6887557EDECC77C2518FE3C355B4FF6BDE3B389957
      2F4E9BC8FF70FC55FC5BE0848B36E29864CEB6EF857AF307D5AD3FFBCDFD2A81
      6DDF0DC7980EF82FF1A19FD87A1B6C5747F43AE1D5F6ECFA1B84B37C5D96FF37
      CFAB1F74AF7A60937DD477C87658651AC3FB30FF6ACBD387CAEBC7AA63CD9E9F
      30914B7B6DD376CC65EBB90FA0976E58C5A75AA11516BA84A81A0B2D761A5A63
      21F95E2FA27A3CE72674F93BF91F7E3A23D3118756D06A45BF01A9445EC8E10D
      52828C96A3FF19B9D04AF94795953BBD955786442FCCB2F91E392C41F0CAE690
      20CE5695E8572ED78ADCBC5E3F148FCB90B1B2F4397C6BEDBC2C6B2B367CBEB5
      3AD12F5F3A3C469065F3DA71DE90285A8F51D2FAC25C3B6341D6747B367979B3
      7AE377FF40408A172DEAFFCA7682B49E90FC74F2DCB3A7C6AC27ECDF67B404AF
      5D8D94B3F45EC8A9DC17363A455976A35AA3307BBA165E6B8514B2F4DD919E1D
      785E14110EEBFC29A284E8215791FDAC7B9F81CC429E2326F4FA05081F1948CF
      C9F3D1051989C422E49ECD438248BD90EFA8FE20BD3E929E1BB0F4C4EE1DA2A7
      7976881F3D26FA434826B149F511527A6B64452B7A1E429E9FD3F47997D637D5
      BF15BD2BD240FB89AD3F4D7D7030B29BE68D46D6D2E3C9C897C870E4179A47CA
      EBFF77F17F4545C56A8D5E3DCB357B7FF4A68F46AF8ABE9ABD45FD90017D35AB
      55BBAAD477EBAAF2565555758C3CFF3737D64D86C89350157506C21EDF875044
      147D0EE0C159F8C67E2274EDA206DD5555EA06F6ED652653FFB1614AD0FE07C0
      737D0E2BB6BC16C3DB9009D571B7701D6E01E69FAE822FBFD807DD54BBD60D19
      30C0A2857EF48814417814DC0D4880CDD74B9032B81398067989A130C4A61F0C
      32FD12A68FCF061BABF5A0AEA656DFBBB7FAD866FAB1A35232235221E4721A04
      5DC98220DF1C08BF9A05471E7883EACCEED2BE0FCACACA396CBD99A949EA89A0
      DBB0E6E41938733916C2AFE5819F5F124C3CB41DCCBDD6C3D88D6BE1938D2E60
      B67319CCD9F61574EAD4A942A2EFD2A5CB8171D6E6053303D7C1A44B6BC1C97F
      2F1C090E82D5413FC3B42B9B60FA952D60EBBB0DECFCB6C3AC3F3681A3CF4AC0
      FB5522D17B5D3C68BCF991277C1DB706E6C5AD83054FD6C3D2675B61F1B3CDB0
      247E1B2C4FD80E2B1276C0AAC45DF05DD25EF821C3071CD72F9A2AD19F8EBC6A
      3A79A51D68EA0C1033C37331ACBDEF091C0B23E8395003742C46C0BECC0BB0E4
      F4261864A4059A83FBC1C061838F36D55FA5CB0995AE2A79DF6C5FB7907772BF
      93FDD2AFB771B87A377B69F64E8B294D99BFE9D00EF798F2D465EA1FF5108E9B
      FCD99D5861F286CFAC3EFB8CD57FF9C826A97B3A07A9477E4726D0BC23483572
      8CF812EBDA0264AB8CE74A9F8CABD4673FA17993E8F85184A8D0BC13482EF205
      628ECCA5F6472066C87B64221D5F38C4AF693DBA527D37EACFF791606426B218
      09A363CE77F4BA9F9018E40619C3FF9BE67F1C5EDB9CFFD1ADBE470EB3C0311F
      541BF52E78CFF6B63AFFE3B5DA889514EA8DFA75D8EF0DAF1966A5DCF91FAF35
      46ECA568F7FC8FD91364E891627C9E6EAC6FE484DCF91FAFD54146B541ABF33F
      6917725CD247F47925F3B91FF5054BE9F95FAA2FBFA6ED5B489E6FA41849A4F3
      3999FFDCDA7816D9FA7ED4F7887E643B9FE5263D3D5F467D959CC4131FED889E
      E62923781F1801429EC38F64E89469BF4AEE3599FF8DA87D2DDA8F71D44FBACA
      D09338E715ADAB2F2D8F68C2E9335B4AC7824FFF1BE37F0565A64DFF1F96CCAC
      1D9ECC1C97302C85393A204E1C4B1E555FC8447EB48669D5FFB553188E562A33
      890D87CF88FD5FDD8989C1325F777760E4FA3FDAFB78780AE3C046F739A3D15E
      FF1F9ACC7C2EAD270C89661CFB1D63361234768A9F2799FEAF95C6E86A273226
      ADC14962B4FF82F89FCC7337FE85E76F1C79F6E9F117749C188074A2F32869EF
      20D6391983969335075B8FE0F8C7E4505F25E39827720BD94BBF27F36C1D721E
      4945564AE9BBD3312294C6E84FC87C4FAF21F3B536BD774AB4ECDD743D41EA97
      42C605A42F8D2FBC68ECB195C600E4B9EBC1D2EFA57A73BA162031C310E42E72
      93AC0D68FC1188842053A9EE26ED7F323E3AFDD7C4FF6ADDDA8CFF0393A2C023
      2D1D96BF2C16E3919E01D5498DF1BFD9D66530FBC0AED6E3FFF42808C948804D
      2F4B903208CEC4F89FDF18FF0F5C3F13AC73D261FA1617B9F13F3F2705EE64A5
      4260F62B08CCC986B0BC577024A9FDF1FF71FE2D704EF2019FAC871026CC05DF
      DC44B08A7507B3483718736D0D8CBDB60E4C7D97CA8DFF67C4AE85890FD7C082
      A77BE07046207C9FE80DD68F36C2B4479BC1E6F156B08D7387998FFFFDF1FF28
      8BB19BFA71068226A73F2CF5DB0C834669C30AFF6DB08B7F06363DFC1906196B
      C1EEB4B3B0F0B81B0C1FA32F8EFFD5BAAB3D203E4DF40A0A0A422BDB295B0F5E
      3F6DB3FFE2B1B9FD070F88D01F69783DA62CCD7ED26CEB5303860E4C70F3DABE
      57B173E7B7ABB6AF3D76FF79CC166363635BB25EA6FD47E64B21B29EFA08D96F
      C84614683C4D7CE507EAF7EA340E2768B2C6B379741DB187C4F5D45F89CF5550
      0DF1E72B748C5841E7344B3A4F3BD139FE066B8F82ACE95F927D097A4EFCBC86
      D6C588CEE79258EA188DEB7F453458D713BF9FC87A4EA620FEC843DA967F7DFD
      FFFEBD3BD4569D855AD16FC859A8A169ADCCB4F9F1FB7A2F28CD8B86C813407C
      17221AD392E8F3D09827E1642351BF22A7D0A77D00A2CF0014BFE48BF511C781
      5017790A22626EC1B1A7CFE059CC75288EB902107316E0218E03B1181E3CBA0C
      F018F3E2FC009EFA0394E5F2E18D201A1EFE86D7A0CD4717E17CEA73D895FF1E
      0E6416C1BBA7D7009E0502C45F87BC276720FB29DAC4F10052EE00A4DE057853
      C8878AC268880F0248FC1D4293E2C0F3D51BE00900F6E6BE858B5816A4874276
      D215E813D01354AFAAC0EF4F7E0478198B3C02A82AE523D1F03C0C202302EA32
      A2E04086107ECC16C13F325F43C9CB7868C87A020EF7A640673F2550BAAA0CFD
      82FA40FA0BAC434106C0DB4A3ED4544463C5007212A0212F09AAF2D220284B00
      B5423ED41564420CDF1F34AFF74706409FEB83A0DFEF43C136DC066A8A5F02D4
      56E345D5D150F412EAB029912FAE4145513A40492E9207EF31757CE0083AB747
      827EF06830B863028677C6825188191C4FF58686B7445F13FDAE2407B6A2AF1B
      DF1D070B6216434531D6AD341FA2B36E8269E864300BFB02CCC3A6C2F8F0E9F0
      69842D4C8898015F44CD01FE1B3EEA6BA37DD24F88F32C23668155E46C70C3B1
      2343F008963E5E03D6687F7A8C13D83C5CD860F77009CC78B80C66C5AE00FBD8
      5510551AC7CFAACA8EB6C77371DEA355E0F0F83B98F3F87BF15834376E2DCC7F
      E20A8E4FDCC0E9E9465844C6232C7B59823B8E491E105B96C44FADC88C16E7C5
      37E6AD4CDC01DF24EE866F719CFA3EC9139C53F6C39A941F615DEA4FE0927A10
      DCD2BC6143DA61D894FE0BC45764F2F955B9D16EA91FF2363F3F0E5B9E9F00F7
      8C53B09DEF033CFE59D8C1FF0D76669E87DD2F2E8AD9F3F232EC7D7119522AB3
      F9A27735E7D245B94919C8F3AABCC40C515E12BF4A909459254864A7B28E2BDE
      D5FCF117EEEB2FECE0F9BF123F58D2B551692B5C97B5EEA1FA7FD01868921C02
      E8BC192267EDF49378AF7511B3081633BB9AE1C0A8913179F200265E579DC992
      5546935E7EFB0E7EA3C744D53A3169BA3DC465903559B716FA258C1DD6E17033
      1CC56BB883435499FC955886557F717C09EC78B91DF63FA1F1A684CB241E95D1
      FE552DECB76415ED53B67E062B1626731359B398B0633EFC18D398589DAE1FB6
      B0BEB3A0EB3C25BA0F46E6C242248D7EDF95AE0FFF40C693FE93D1C624BA477F
      8B9E17D3F87B38DD9B7F44635F797A67DAAFB3587A2F3A579372F7B5A1DF4363
      FC6F597A6BFABB420A9D7B65EA690C406207B23793C0D29358A19CCEEDA6ADE8
      BFA26B05B2BEC9A2737F313D277EB193A597C411A4BFE7537D7FB2EEA0C7C390
      5E08979E0FA67B0B5DE97D51A2F796D0FB2FFB4DD1F7F9C00E6B003A31BE29E1
      8C6F522E7325F90D73314EE3CFD94EFA15CB2966AE26AFEBB03620A10FE39B2C
      607C5327639A86E52877CC76E226E64AD22FE4FD38AC4718B6C3B6DDDAB83825
      B49985FA538C5FCA663CBE81F6C978A5D02EFDE5247BD43C433D8F607AF6DAB9
      4D4777D78878A32E8107D71F78867B61ABF660995ABF9489682B86F14B3ECCF8
      A78AE3CA1B5E4EBC1FBDD7972D3DEE9DE2E5BD61236C37580F3C6E3AF086A9B4
      D05F493A84B62F60191718BFA471346F0E967751F14AD225954B4FB60069C776
      C378D8A637BC5D7DC2D31F8775BE0F1E06B8983344B8B998D6C32E23ED36B5EE
      865CD4BDC2FADA21CAC0E37582BDFABD1BEBAFABD5A67EBBC13768FB74D339A9
      BB3B773CE617C13663BD36F55B86F7C5BA3EC33AFC81E939AC7B021E3FC1B40C
      CFB3B16D361D7A3679C6D2EF7E2AFC45BE7BBB83E74C6D6DADCF92254BC0C2C2
      02705D069696963061C204717A649F7BD339F94E5F5F1F264F9E0CF1F1F145A8
      15EFA3161515C5DBDBDB43696929B8BABA02FBF3FEB16FD3714040001C3A7448
      9C7A7B7B932CF1FBB8858585091A1A1A307EFCF816FA5B89BF34D373381C3032
      321297839F916CFB252525E0E6E6D64C3F337A5ED3B1BFBF7F937DAA37A67AB9
      F6BF4DDCD3CCBE8E8E0E70B9DC16F667CD9A256E3FA9DBD4A953C1DADA5A9CEE
      FC79BF38258C1A35AAC9FEC1830765DA77767686EAEAEA26C83A89A435353570
      F9F26571FB59F69BFA4FD2FE356BD634AB7F4AF21599FD2FD5FE784D4D4DB17D
      69BD23AE27A4FB9FD8A7F51F29B14FDA4FECAF5DBBB6999EEC3BB4C7BEA4FDE3
      C68D034F4FCF267C822E361D2F58B040BAFD2DFA9FE86FDEBC09B76EDD6A06C9
      73777717D75BD6FD97B49F9423EFC36E3F5B8F76631C1D1DC5F6DBD24BDA7FFA
      F4E9F7982519879C6EDFBE5DC7E3F1E0DCB97372F5C9C9C9B075EB56387CF830
      8844A2EB98A5F89FFA4EA1B1B1FF202E37C0C5D0F09A757B35E6E6BE5DB9DCC0
      6FB9DC6B378D8C02CFE3F13C4C9BE25C23A3BB360606772E1A1ADE3795A53732
      0AB0C1EBDD4C4C6EA83A38F82A1A18044E63EBB9DC9079FAFA21CB0D0D434E63
      A0D0A2EFB9DC203BACEF6A43C3C04358877B587F4F69BDAEEEDDB1F2EA4FF458
      E713A8133FD71CCE4DF58EEAF17AF1DC6D60E03F1AEBB257A23730B81B80F57E
      264F8FB6BA181A063848F44646D7CE211E2346046DD3D10936E572EFEC343008
      F949961E033F056C6F309221D1633B2E181A06AD22F783C30931333008DE8DFA
      23D8862132EACD3132F2DF83FA6DC8271FEEC5B573A40F48F958F7AB5CEEDD5F
      65BE7F6A725C89F6772497EBABF6A7DE6135F1ED41F8BFEA2FF43713CF56D84E
      D63372B4644DF88EAEEF7C657083AECDA2659541D72FC07E2743EAFB418DDFF7
      17CA2AA3FDFA345C7B73C97B6364EF59BDE3FABBB8EEBF13864BA94A763DA4F5
      0C2318CA30792B91DDB81C5E8DBACF31F3B58CDF0097CBD6E7E27A3117DB9A9B
      88BC453033F7B8549DC8DAF87BD9FA9C011FAE13E8A3B6969631A23D7A29DFC4
      35686E31D59BB6578FCBD31E78FD72C49F6AB1BF3EFCEFA86D7DCE14AA4BC7E3
      45D2FFDD6A5B9F3FBE519FE723E79EB6A10745D44E4706B543DF95AED359CF54
      CED7B4FE2972F43EE4F705F9FE98CD45EDEF88C7FF80EFF7413CDAF0FFF1ADBF
      9F237E9FD3570E3974CF628A1CFD0584EC4DF58305780F24383143E8F797FA76
      15BF1721B38C26FD6266212C645C9B58C4AC0507F1EF2B97F69B30F72E5888F7
      4FC87B043672EC4F95D2BB601DC8FB3B97BED56322CBE6328F176A8B7FFF6F56
      8F263D5EDBACFE044BF16FAB5E327C3FAD857E21F35D8BFDCB9690F740E74B7E
      2F6FA65FC1A8629D7BB6CA6AF17BAAB2F5EDDF3F94AD6FFFF3D63EFD12464B86
      7D7BB9FAC58C668BFE9706AF91AB5FC8CC6E76FF65335B867E23B2AA03ED27FB
      A541FF29B1F6DF65FF1F2FC17902764921DEFF67982F121846AF5DFBFF64CEB3
      B078633A7A74E98AA1434BCC19A6F32186598DF357DD4B5A86CCFD7FD4D92147
      468CA879347B764DC3B469225CCF973474EB761AE78A61F90CF32D963129A1B5
      FDFF31632AF4ECECAACA9D9DDF01F9FFB2A9E91BF8E8234135C37C7EAAADFD7F
      2C7655AF5EB501132654BE9F33A7066C6C44606C5C0ADDBA091B18A62A88BE13
      296BFF9FEC294F23C7C38615F5D3D129C91935AA0CD7A9A5A0A959089D3A090A
      18A6981553887D684BF3FD2907E537DEB3E7BE3930F3CC05A70D0FB8839E95AB
      A8086A550709CB0D3CCB624D1E959D1912F97A81BCFDD4CAA35F6FAB39B5ACBE
      E6D45228FFC91632374EC89BEFE467332DB62ADBF1790D4C4B1291FF1EBF53BB
      2FDCC1FEEF8FC476E591AF8AEA2E3843DDF9D550E13D1B8AB69BC2CFA77F7842
      FE73BC26EB9DF8BFC7C60FB12FEE0A8B99D0A266313E7F35A74BD98FD32BAA8E
      CD07D12FF3A074FF54F17F80BD4EEECBB67C560176C9554052ADA8D7D0395850
      C184BC681EE7F3789D8A768C3F53B2C7B2E1F56E4BF17F8F05AEFAA59EC776CC
      181AF9BA04EB0D43238B41354408E2FF00FBB65C77E7AEE3F6126CE01EC85F6F
      9091EFAA1B9EE7A24B7EF7575009C9B5540911DE570CCEE7A3F667E68640E3DF
      E9BBFF048105124D
    }
  end
  object SaveDialog1: TSaveDialog
    Left = 16
    Top = 160
  end
end
