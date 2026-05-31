{%RunFlags MESSAGES+}
unit frmProjectTree;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, VirtualTrees, ComCtrls,
  Menus, FileUtil, LazFileUtils, LazUTF8, TreeFilterEdit,
  LCLType, LCLIntf, Math, ExtCtrls, StdCtrls, Buttons,
  Clipbrd, FileCtrl,
  {$ifdef windows}
    ActiveX,
  {$else}
  FakeActiveX,
  {$endif}
  uPluginManager, uProject, uFileUtils, uDebugLog, Types;

type
  TPluginMenuCallback = procedure(PopupMenu: TPopupMenu; const FileName: string) of object;
  PTreeNodeData = ^TTreeNodeData;

  TTreeNodeData = record
    FileName: string;
    FullPath: string;
    IsDirectory: boolean;
    FileSize: int64;
    ModifiedDate: TDateTime;
    FileType: TWebFileType;
  end;

  { TProjectTreeForm }

  TProjectTreeForm = class(TForm)
    FilterComboBox1: TComboBox;
    mnuOpenWith: TMenuItem;
    N5: TMenuItem;
    // Agrega este menú para ordenamiento (creado en tiempo de ejecución)
    PopupMenuSort: TPopupMenu;
    SortByNameAsc: TMenuItem;
    SortByNameDesc: TMenuItem;
    SortByType: TMenuItem;
    SortBySize: TMenuItem;
    SortByDate: TMenuItem;
    N6: TMenuItem;
    FilterAll: TMenuItem;
    FilterHTML: TMenuItem;
    FilterCSS: TMenuItem;
    FilterJS: TMenuItem;
    FilterImages: TMenuItem;
    FilterJSON: TMenuItem;
    FilterSVG: TMenuItem;
    FilterxML: TMenuItem;
    FilterFonts: TMenuItem;

    btnCopyImage: TSpeedButton;
    btnOpenInBrowser: TSpeedButton;
    btnSaveImage: TSpeedButton;

    btnFilterSort: TSpeedButton;
    TreeFilterEdit1: TTreeFilterEdit;

    VirtualStringTree1: TVirtualStringTree;
    ImageList1: TImageList;

    PopupMenu1: TPopupMenu;
    Open1: TMenuItem;
    N1: TMenuItem;
    NewFile1: TMenuItem;
    NewFolder1: TMenuItem;
    N2: TMenuItem;
    Rename1: TMenuItem;
    Delete1: TMenuItem;
    N3: TMenuItem;
    Refresh1: TMenuItem;
    N4: TMenuItem;
    OptimizeImage1: TMenuItem;
    PanelImageInfo: TPanel;

    OpenLoc: TMenuItem;
    Properties1: TMenuItem;

    SaveDialog1: TSaveDialog;

    // Details panel components

    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    lblImageFormat: TLabel;
    lblImageResolution: TLabel;
    lblImageSizeKB: TLabel;

    Splitter1: TSplitter;
    PanelDetails: TPanel;
    PageControl1: TPageControl;
    TabSheetDetails: TTabSheet;
    TabSheetPreview: TTabSheet;
    ScrollBox1: TScrollBox;
    lblFileName: TLabel;
    lblFilePath: TLabel;
    lblFileSize: TLabel;
    lblModified: TLabel;
    lblFileType: TLabel;
    lblDimensions: TLabel;
    lblColorDepth: TLabel;
    lblFontInfo: TLabel;
    imgPreview: TImage;
    memoPreview: TMemo;
    btnOpenLocation: TButton;
    btnProperties: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    lblPreviewInfo: TLabel;
    PanelFontPreview: TPanel;
    lblFontSample: TLabel;
    lblFontName: TLabel;
    lblFontStyle: TLabel;
    lblFontFormat: TLabel;
    cmbFontSize: TComboBox;
    btnIncreaseFont: TSpeedButton;
    btnDecreaseFont: TSpeedButton;

    procedure btnCopyImageClick(Sender: TObject);
    procedure btnOpenInBrowserClick(Sender: TObject);
    procedure btnSaveImageClick(Sender: TObject);
    procedure FilterComboBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure VirtualStringTree1DblClick(Sender: TObject);
    procedure VirtualStringTree1FreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure VirtualStringTree1GetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure VirtualStringTree1GetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: boolean; var ImageIndex: integer);
    procedure VirtualStringTree1KeyPress(Sender: TObject; var Key: char);
    procedure VirtualStringTree1Editing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: boolean);
    procedure VirtualStringTree1NewText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; const NewText: string);
    procedure VirtualStringTree1ContextPopup(Sender: TObject; MousePos: TPoint; var Handled: boolean);
    procedure Open1Click(Sender: TObject);
    procedure NewFile1Click(Sender: TObject);
    procedure NewFolder1Click(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);

    // Selection changed event
    procedure VirtualStringTree1FocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);


    // Drag and Drop Events
    procedure VirtualStringTree1DragAllowed(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: boolean);

    procedure VirtualStringTree1DragDrop(Sender: TBaseVirtualTree;
      Source: TObject; DataObject: IDataObject; Formats: TFormatArray;
      Shift: TShiftState; const Pt: TPoint; var Effect: LongWord; Mode: TDropMode);

    procedure VirtualStringTree1DragOver(Sender: TBaseVirtualTree; Source: TObject; Shift: TShiftState; State: TDragState; const Pt: TPoint; Mode: TDropMode; var Effect: longword; var Accept: boolean);
    procedure VirtualStringTree1StartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure VirtualStringTree1EndDrag(Sender, Target: TObject; X, Y: integer);

    // Button events
    procedure btnOpenLocationClick(Sender: TObject);
    procedure btnPropertiesClick(Sender: TObject);
    procedure btnIncreaseFontClick(Sender: TObject);
    procedure btnDecreaseFontClick(Sender: TObject);
    procedure cmbFontSizeChange(Sender: TObject);

    procedure FormShow(Sender: TObject);
    procedure VirtualStringTree2DragDrop(Sender: TBaseVirtualTree;
      Source: TObject; DataObject: IDataObject; Formats: TFormatArray;
      Shift: TShiftState; const Pt: TPoint; var Effect: longword;
      Mode: TDropMode);
    procedure VirtualStringTree2DragOver(Sender: TBaseVirtualTree;
      Source: TObject; Shift: TShiftState; State: TDragState; const Pt: TPoint;
      Mode: TDropMode; var Effect: longword; var Accept: boolean);


  private
    FProject: TETEditProject;
    FRootNode: PVirtualNode;
    FDragNode: PVirtualNode;
    FIsDragging: boolean;
    FCurrentPreviewFile: string;
    FCurrentFontName: string;

    FOnPopulatePluginMenu: TPluginMenuCallback;

    // ============ VARIABLES PARA FILTRADO Y ORDENAMIENTO ============
    FSortColumn: integer;           // Columna por la que se ordena (0=nombre, 1=tamaño, etc.)
    FSortDirection: integer;        // 1 = Ascendente, -1 = Descendente
    FCurrentFilter: string;         // Texto actual del filtro
    FFilterFileType: TWebFileType;  // Tipo de archivo para filtrar

    // Size limits for preview (in bytes)
  const
    MAX_TEXT_PREVIEW_SIZE = 1024 * 100; // 100KB max for text preview
    MAX_IMAGE_PREVIEW_SIZE = 1024 * 1024 * 10; // 10MB max for image preview
    MAX_FONT_PREVIEW_SIZE = 1024 * 1024 * 5; // 5MB max for font preview
    MAX_PREVIEW_LINES = 100;
    PREVIEW_CHUNK_SIZE = 1024 * 10;

    function GetNodeData(Node: PVirtualNode): PTreeNodeData;
    procedure LoadProjectTree;
    procedure AddDirectory(ParentNode: PVirtualNode; const Path: string);
    function IsDirectory(const Path: string): boolean;
    function GetSelectedNode: PVirtualNode;
    function CanDeleteNode(Node: PVirtualNode): boolean;
    function GetNodePath(Node: PVirtualNode): string;
    function GetNodeParentPath(Node: PVirtualNode): string;
    procedure UpdateNodeFileInfo(Node: PVirtualNode);
    function GetFileSizeAndDate(const FilePath: string; out FileSize: int64; out ModifiedDate: TDateTime): boolean;

    // Drag and Drop helper methods
    function CanDragNode(Node: PVirtualNode): boolean;
    function CanDropNode(TargetNode, SourceNode: PVirtualNode; Mode: TDropMode): boolean;
    function GetDropTargetPath(TargetNode: PVirtualNode; Mode: TDropMode): string;
    function MoveFileOrFolder(const SourcePath, DestPath: string): boolean;
    procedure UpdateNodeAfterMove(Node: PVirtualNode; NewPath: string);
    procedure UpdateChildPaths(ParentNode: PVirtualNode; NewParentPath: string);

    // Details panel methods
    procedure UpdateDetailsPanel(Node: PVirtualNode);
    procedure ClearDetailsPanel;
    procedure SafeLoadImagePreview(const FilePath: string);
    procedure SafeLoadFontPreview(const FilePath: string);
    procedure SafeLoadTextPreview(const FilePath: string);
    function FormatFileSize(Size: int64): string;
    function GetFileTypeDescription(FileType: TWebFileType): string;
    function IsBinaryFile(const FilePath: string): boolean;
    function GetFileEncoding(const FilePath: string): string;
    function GetFirstLines(const FilePath: string; MaxLines: integer): TStringList;
    function GetFileSample(const FilePath: string; MaxBytes: integer): string;

    // Image utility functions
    function GetImageInfo(const FilePath: string; out ImgWidth, ImgHeight: integer; out ColorDepth: integer; out Format: string): boolean;

    // Font utility functions
    function GetFontInfo(const FilePath: string; out FontName, FontStyle, FontFormat: string): boolean;
    procedure UpdateFontPreview;

    // ============ MÉTODOS PARA EXPANSIÓN/COLAPSADO ============
    procedure VirtualStringTree1Expanded(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VirtualStringTree1Collapsed(Sender: TBaseVirtualTree; Node: PVirtualNode);

    // ============ MÉTODOS PARA FILTRADO ============
    procedure TreeFilterEdit1Change(Sender: TObject);
    procedure ApplyFilter;
    procedure TreeFilterEdit1AfterFilter(Sender: TObject);

    // ============ MÉTODOS PARA ORDENAMIENTO ============
    procedure CompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: integer);
    procedure ApplySorting;

    // ============ MÉTODO PARA EL BOTÓN ============
    procedure btnFilterSortClick(Sender: TObject);

    // ============ MÉTODOS PARA CONFIGURAR MENÚ ============
    procedure SetupSortMenu;
    procedure UpdateMenuChecks(Sender: TObject);

    // ============ EVENTOS DE ORDENAMIENTO ============
    procedure SortByNameAscClick(Sender: TObject);
    procedure SortByNameDescClick(Sender: TObject);
    procedure SortByTypeClick(Sender: TObject);
    procedure SortBySizeClick(Sender: TObject);
    procedure SortByDateClick(Sender: TObject);

    procedure ApplyFilterByType(FilterType: TWebFileType);
  public
    procedure SetProject(AProject: TETEditProject);
    function GetSelectedFile: string;
    procedure RefreshTree;
    procedure SelectFile(const FilePath: string);
    property Project: TETEditProject read FProject;  // Add this line

    property OnPopulatePluginMenu: TPluginMenuCallback read FOnPopulatePluginMenu write FOnPopulatePluginMenu;
  end;

implementation

{$R *.frm}

const
  DROPEFFECT_NONE = 0;
  DROPEFFECT_MOVE = 1;

  // ============ IMAGE UTILITY FUNCTIONS ============

function TProjectTreeForm.GetImageInfo(const FilePath: string; out ImgWidth, ImgHeight: integer; out ColorDepth: integer; out Format: string): boolean;
var
  Picture: TPicture;
  Ext: string;
begin
  Result := False;
  ImgWidth := 0;
  ImgHeight := 0;
  ColorDepth := 0;
  Format := '';

  if not FileExists(FilePath) then Exit;

  Ext := LowerCase(ExtractFileExt(FilePath));
  Format := UpperCase(Copy(Ext, 2, Length(Ext)));

  try
    Picture := TPicture.Create;
    try
      Picture.LoadFromFile(FilePath);

      ImgWidth := Picture.Width;
      ImgHeight := Picture.Height;

      // Estimate color depth based on file type
      if (Ext = '.png') or (Ext = '.bmp') then
        ColorDepth := 32
      else if (Ext = '.jpg') or (Ext = '.jpeg') then
        ColorDepth := 24
      else if Ext = '.gif' then
        ColorDepth := 8
      else
        ColorDepth := 24; // Default

      Result := True;
    finally
      Picture.Free;
    end;
  except
    Result := False;
  end;
end;

// ============ FONT UTILITY FUNCTIONS ============

function TProjectTreeForm.GetFontInfo(const FilePath: string; out FontName, FontStyle, FontFormat: string): boolean;
var
  Ext: string;
  FS: TFileStream;
  Buffer: array[0..255] of byte;
  BytesRead: integer;
  I: integer;
  LowerName: string;
begin
  Result := False;
  FontName := '';
  FontStyle := 'Unknown';
  FontFormat := '';

  if not FileExists(FilePath) then Exit;

  Ext := LowerCase(ExtractFileExt(FilePath));

  // Determine format from extension
  if Ext = '.ttf' then
    FontFormat := 'TrueType'
  else if Ext = '.otf' then
    FontFormat := 'OpenType'
  else if Ext = '.woff' then
    FontFormat := 'WOFF'
  else if Ext = '.woff2' then
    FontFormat := 'WOFF2'
  else
    FontFormat := 'Unknown';

  // Try to extract basic info from font file
  try
    FS := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyWrite);
    try
      FillChar(Buffer, SizeOf(Buffer), 0);
      BytesRead := FS.Read(Buffer, SizeOf(Buffer));

      if BytesRead > 0 then
      begin
        // Simple detection - for real apps use a proper font library
        FontName := ExtractFileName(FilePath);
        FontName := Copy(FontName, 1, Pos('.', FontName) - 1);

        // Capitalize font name
        if Length(FontName) > 0 then
        begin
          FontName[1] := UpCase(FontName[1]);
          for I := 2 to Length(FontName) do
          begin
            if FontName[I - 1] in ['-', '_', ' '] then
              FontName[I] := UpCase(FontName[I])
            else
              FontName[I] := LowerCase(FontName[I]);
          end;
        end;

        FontStyle := 'Regular'; // Default

        // Try to detect style from filename
        LowerName := LowerCase(ExtractFileName(FilePath));
        if Pos('bold', LowerName) > 0 then
          FontStyle := 'Bold'
        else if Pos('italic', LowerName) > 0 then
          FontStyle := 'Italic'
        else if Pos('light', LowerName) > 0 then
          FontStyle := 'Light'
        else if Pos('medium', LowerName) > 0 then
          FontStyle := 'Medium';

        Result := True;
      end;
    finally
      FS.Free;
    end;
  except
    Result := False;
  end;
end;

procedure TProjectTreeForm.UpdateFontPreview;
begin
  if FCurrentFontName = '' then Exit;

  lblFontSample.Font.Name := FCurrentFontName;
  lblFontSample.Font.Size := StrToIntDef(cmbFontSize.Text, 24);

  // Sample text in different languages
  lblFontSample.Caption :=
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ' + LineEnding + 'abcdefghijklmnopqrstuvwxyz' + LineEnding + '0123456789 !@#$%^&*()' + LineEnding + 'The quick brown fox jumps over the lazy dog';
end;

// ============ SMART PREVIEW FUNCTIONS ============

function TProjectTreeForm.IsBinaryFile(const FilePath: string): boolean;
var
  FS: TFileStream;
  Buffer: array[0..511] of byte;
  I: integer;
  BytesRead: integer;
begin
  Result := False;
  if not FileExists(FilePath) then Exit;

  try
    FS := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyWrite);
    try
      FillChar(Buffer, SizeOf(Buffer), 0);
      BytesRead := FS.Read(Buffer, SizeOf(Buffer));

      for I := 0 to BytesRead - 1 do
      begin
        if (Buffer[I] = 0) or (Buffer[I] > $7F) then
        begin
          Result := True;
          Break;
        end;
      end;
    finally
      FS.Free;
    end;
  except
    Result := True;
  end;
end;

function TProjectTreeForm.GetFileEncoding(const FilePath: string): string;
var
  FS: TFileStream;
  BOM: array[0..3] of byte;
  BytesRead: integer;
begin
  Result := 'Unknown';
  if not FileExists(FilePath) then Exit;

  try
    FS := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyWrite);
    try
      FillChar(BOM, SizeOf(BOM), 0);
      BytesRead := FS.Read(BOM, SizeOf(BOM));

      if BytesRead >= 3 then
      begin
        if (BOM[0] = $EF) and (BOM[1] = $BB) and (BOM[2] = $BF) then
          Result := 'UTF-8 with BOM'
        else if (BOM[0] = $FF) and (BOM[1] = $FE) then
          Result := 'UTF-16 LE'
        else if (BOM[0] = $FE) and (BOM[1] = $FF) then
          Result := 'UTF-16 BE'
        else
          Result := 'UTF-8 (no BOM) or ASCII';
      end;
    finally
      FS.Free;
    end;
  except
    Result := 'Unknown (cannot read)';
  end;
end;

function TProjectTreeForm.GetFirstLines(const FilePath: string; MaxLines: integer): TStringList;
var
  FS: TFileStream;
  Buffer: array[0..PREVIEW_CHUNK_SIZE - 1] of char;
  BytesRead: integer;
  Content: string;
  Lines: TStringList;
  I, LineCount: integer;
begin
  Result := TStringList.Create;

  if not FileExists(FilePath) then Exit;

  try
    FS := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyWrite);
    try
      FillChar(Buffer, SizeOf(Buffer), 0);
      BytesRead := FS.Read(Buffer, SizeOf(Buffer));
      if BytesRead > 0 then
      begin
        SetString(Content, Buffer, BytesRead);

        Content := StringReplace(Content, #13#10, #10, [rfReplaceAll]);
        Content := StringReplace(Content, #13, #10, [rfReplaceAll]);

        Lines := TStringList.Create;
        try
          Lines.Text := Content;

          LineCount := Min(Lines.Count, MaxLines);
          for I := 0 to LineCount - 1 do
            Result.Add(Lines[I]);

          if Lines.Count > MaxLines then
            Result.Add('... (truncated, ' + IntToStr(Lines.Count - MaxLines) + ' more lines)');
        finally
          Lines.Free;
        end;
      end;
    finally
      FS.Free;
    end;
  except
    on E: Exception do
      Result.Add('Error reading file: ' + E.Message);
  end;
end;

function TProjectTreeForm.GetFileSample(const FilePath: string; MaxBytes: integer): string;
var
  FS: TFileStream;
  Buffer: pchar;
  BytesRead: integer;
begin
  Result := '';
  if not FileExists(FilePath) then Exit;

  try
    FS := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyWrite);
    try
      GetMem(Buffer, MaxBytes + 1);
      try
        FillChar(Buffer^, MaxBytes + 1, 0);
        BytesRead := FS.Read(Buffer^, MaxBytes);
        if BytesRead > 0 then
        begin
          SetString(Result, Buffer, BytesRead);
          if BytesRead = MaxBytes then
            Result := Result + '... (truncated)';
        end;
      finally
        FreeMem(Buffer);
      end;
    finally
      FS.Free;
    end;
  except
    on E: Exception do
      Result := 'Error reading file: ' + E.Message;
  end;
end;

// ============ UTILITY FUNCTIONS ============

function TProjectTreeForm.FormatFileSize(Size: int64): string;
begin
  if Size < 1024 then
    Result := Format('%d bytes', [Size])
  else if Size < 1024 * 1024 then
    Result := Format('%.1f KB', [Size / 1024])
  else if Size < 1024 * 1024 * 1024 then
    Result := Format('%.1f MB', [Size / (1024 * 1024)])
  else
    Result := Format('%.1f GB', [Size / (1024 * 1024 * 1024)]);
end;

function TProjectTreeForm.GetFileTypeDescription(FileType: TWebFileType): string;
begin
  case FileType of
    wftHTML: Result := 'HTML Document';
    wftCSS: Result := 'CSS Stylesheet';
    wftJavaScript: Result := 'JavaScript File';
    wftJSON: Result := 'JSON Data';
    wftSVG: Result := 'SVG Image';
    wftXML: Result := 'XML Document';
    wftImage: Result := 'Image File';
    wftFont: Result := 'Font File';
    wftVideo: Result := 'Video File';
    wftAudio: Result := 'Audio File';
    wftOther: Result := 'Other File';
    wftText: Result := 'Text File';
    wftProject: Result := 'Project File';
    else
      Result := 'Unknown';
  end;
end;

// ============ FORM CREATION ============

procedure TProjectTreeForm.btnCopyImageClick(Sender: TObject);
begin

end;

procedure TProjectTreeForm.btnOpenInBrowserClick(Sender: TObject);
begin

end;

procedure TProjectTreeForm.btnSaveImageClick(Sender: TObject);
begin

end;

procedure TProjectTreeForm.FormCreate(Sender: TObject);
begin

  Caption := 'Project';
  Width := 400;
  Height := 600;

  FCurrentPreviewFile := '';
  FCurrentFontName := '';

  FCurrentFilter := '';
  FFilterFileType := wftOther; // Todos los archivos
  FSortColumn := 0;
  FSortDirection := 1;

  cmbFontSize.ItemIndex := 2; // Default to 16px

  // Create ImageList first

  ImageList1.Width := 16;
  ImageList1.Height := 16;

  // Configure VirtualStringTree

  with VirtualStringTree1 do
  begin
    Parent := Self;
    Align := alClient;

    NodeDataSize := SizeOf(TTreeNodeData);

    Images := ImageList1;
    DefaultNodeHeight := 20;
    Header.AutoSizeIndex := 0;

    Header.Columns.Clear;
    with Header.Columns.Add do
    begin
      Text := 'Name';
      Width := 300;
    end;

    OnGetText := @VirtualStringTree1GetText;
    OnGetImageIndex := @VirtualStringTree1GetImageIndex;
    OnDblClick := @VirtualStringTree1DblClick;
    OnKeyPress := @VirtualStringTree1KeyPress;
    OnEditing := @VirtualStringTree1Editing;
    OnNewText := @VirtualStringTree1NewText;
    OnFocusChanged := @VirtualStringTree1FocusChanged;

    OnDragAllowed := @VirtualStringTree1DragAllowed;
    OnDragOver := @VirtualStringTree1DragOver;
    OnDragDrop := @VirtualStringTree1DragDrop;
    OnStartDrag := @VirtualStringTree1StartDrag;
    OnEndDrag := @VirtualStringTree1EndDrag;

    // Configurar para ordenamiento
    OnCompareNodes := @CompareNodes;
    OnExpanded := @VirtualStringTree1Expanded;
    OnCollapsed := @VirtualStringTree1Collapsed;

    VirtualStringTree1.PopupMenu := PopupMenu1;
  end;

  // Configurar TreeFilterEdit

  TreeFilterEdit1.TextHint := 'Filter files...';
  TreeFilterEdit1.OnChange := @TreeFilterEdit1Change;
  TreeFilterEdit1.Visible := True;

  // Configurar botón de filtro/ordenamiento
  btnFilterSort.Hint := 'Sort and filter options';
  btnFilterSort.ShowHint := True;
  btnFilterSort.OnClick := @btnFilterSortClick;

  // Configurar menú de ordenamiento
  SetupSortMenu;

  // Configure details panel

  memoPreview.ReadOnly := True;
  memoPreview.ScrollBars := ssBoth;
  memoPreview.WordWrap := False;

  // Font controls
  PanelFontPreview.Visible := False;
  lblFontSample.AutoSize := False;
  lblFontSample.WordWrap := True;
  lblFontSample.Alignment := taCenter;
  lblFontSample.Layout := tlCenter;

  btnIncreaseFont.Caption := '+';
  btnDecreaseFont.Caption := '-';

  btnOpenLocation.Caption := 'Open File Location';
  btnProperties.Caption := 'Properties';

  // Connect events
  btnOpenLocation.OnClick := @btnOpenLocationClick;
  btnProperties.OnClick := @btnPropertiesClick;
  btnIncreaseFont.OnClick := @btnIncreaseFontClick;
  btnDecreaseFont.OnClick := @btnDecreaseFontClick;
  cmbFontSize.OnChange := @cmbFontSizeChange;

  FDragNode := nil;
  FIsDragging := False;
end;

// ============ TREE METHODS ============

function TProjectTreeForm.GetNodeData(Node: PVirtualNode): PTreeNodeData;
begin
  if (Node <> nil) and (VirtualStringTree1 <> nil) then
    Result := PTreeNodeData(VirtualStringTree1.GetNodeData(Node))
  else
    Result := nil;
end;

procedure TProjectTreeForm.VirtualStringTree1GetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  NodeData: PTreeNodeData;
begin
  CellText := '';
  NodeData := GetNodeData(Node);

  if (NodeData <> nil) and (Column = 0) then
    CellText := NodeData^.FileName;
end;

procedure TProjectTreeForm.VirtualStringTree1GetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: boolean; var ImageIndex: integer);
var
  NodeData: PTreeNodeData;
  IsExpanded: boolean;
begin
  if Column = 0 then
  begin
    if Node = FRootNode then
      ImageIndex := 0 // Project icon
    else
    begin
      NodeData := GetNodeData(Node);
      IsExpanded := VirtualStringTree1.Expanded[Node];
      if (NodeData <> nil) and (NodeData^.FullPath <> '') then
      begin
        IsExpanded := VirtualStringTree1.Expanded[Node];
        // Usar función actualizada de uFileUtils
        ImageIndex := GetFileIconIndex(NodeData^.FullPath, NodeData^.IsDirectory, IsExpanded);
      end
      else
        ImageIndex := 9; // Other
    end;
  end;
end;

procedure TProjectTreeForm.VirtualStringTree1Expanded(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  VirtualStringTree1.InvalidateNode(Node);
end;

procedure TProjectTreeForm.VirtualStringTree1Collapsed(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  VirtualStringTree1.InvalidateNode(Node);
end;

// ============ SORT METHODS ============

procedure TProjectTreeForm.TreeFilterEdit1Change(Sender: TObject);
begin
  FCurrentFilter := LowerCase(Trim(TreeFilterEdit1.Text));
  ApplyFilter;
end;

procedure TProjectTreeForm.ApplyFilter;
var
  Node: PVirtualNode;
  NodeData: PTreeNodeData;
  ParentNode: PVirtualNode;
  ShouldShow: boolean;
begin
  VirtualStringTree1.BeginUpdate;
  try
    // Primero ocultar todos los nodos (excepto root)
    Node := VirtualStringTree1.GetFirst;
    while Node <> nil do
    begin
      if Node = FRootNode then
        VirtualStringTree1.IsVisible[Node] := True
      else
        VirtualStringTree1.IsVisible[Node] := False;
      Node := VirtualStringTree1.GetNext(Node);
    end;

    // Luego mostrar los que coinciden con el filtro
    Node := VirtualStringTree1.GetFirst;
    while Node <> nil do
    begin
      if Node <> FRootNode then
      begin
        NodeData := GetNodeData(Node);
        if NodeData <> nil then
        begin
          ShouldShow := True;

          // Filtrar por tipo
          if (FFilterFileType <> wftOther) and (NodeData^.FileType <> FFilterFileType) then
            ShouldShow := False;

          // Filtrar por texto
          if ShouldShow and (FCurrentFilter <> '') then
            ShouldShow := Pos(FCurrentFilter, LowerCase(NodeData^.FileName)) > 0;

          if ShouldShow then
          begin
            VirtualStringTree1.IsVisible[Node] := True;

            // Asegurar que todos los padres sean visibles y expandidos
            ParentNode := VirtualStringTree1.NodeParent[Node];
            while ParentNode <> nil do
            begin
              VirtualStringTree1.IsVisible[ParentNode] := True;
              VirtualStringTree1.Expanded[ParentNode] := True;
              ParentNode := VirtualStringTree1.NodeParent[ParentNode];
            end;
          end;
        end;
      end;
      Node := VirtualStringTree1.GetNext(Node);
    end;
  finally
    VirtualStringTree1.EndUpdate;
  end;
end;

procedure TProjectTreeForm.SetupSortMenu;
begin
  PopupMenuSort := TPopupMenu.Create(Self);
  PopupMenuSort.AutoPopup := True;

  // Ordenamiento
  SortByNameAsc := TMenuItem.Create(PopupMenuSort);
  SortByNameAsc.Caption := 'Sort by Name (A-Z)';
  SortByNameAsc.OnClick := @SortByNameAscClick;
  SortByNameAsc.Checked := True;
  PopupMenuSort.Items.Add(SortByNameAsc);

  SortByNameDesc := TMenuItem.Create(PopupMenuSort);
  SortByNameDesc.Caption := 'Sort by Name (Z-A)';
  SortByNameDesc.OnClick := @SortByNameDescClick;
  PopupMenuSort.Items.Add(SortByNameDesc);

  SortByType := TMenuItem.Create(PopupMenuSort);
  SortByType.Caption := 'Sort by File Type';
  SortByType.OnClick := @SortByTypeClick;
  PopupMenuSort.Items.Add(SortByType);

  SortBySize := TMenuItem.Create(PopupMenuSort);
  SortBySize.Caption := 'Sort by Size';
  SortBySize.OnClick := @SortBySizeClick;
  PopupMenuSort.Items.Add(SortBySize);

  SortByDate := TMenuItem.Create(PopupMenuSort);
  SortByDate.Caption := 'Sort by Date (newest first)';
  SortByDate.OnClick := @SortByDateClick;
  PopupMenuSort.Items.Add(SortByDate);

  PopupMenuSort.Items.Add(NewLine);
end;

// ============ SORT EVENTS ============

procedure TProjectTreeForm.SortByTypeClick(Sender: TObject);
begin
  FSortColumn := 2;
  FSortDirection := 1;
  ApplySorting;
  UpdateMenuChecks(Sender);
end;

procedure TProjectTreeForm.SortBySizeClick(Sender: TObject);
begin
  FSortColumn := 1;
  FSortDirection := 1;
  ApplySorting;
  UpdateMenuChecks(Sender);
end;

procedure TProjectTreeForm.SortByDateClick(Sender: TObject);
begin
  FSortColumn := 3;
  FSortDirection := -1; // Más reciente primero
  ApplySorting;
  UpdateMenuChecks(Sender);
end;

// Eventos de filtrado

procedure TProjectTreeForm.btnFilterSortClick(Sender: TObject);
var
  P: TPoint;
begin
  // Mostrar menú cerca del botón
  P := Point(btnFilterSort.Left, btnFilterSort.Top + btnFilterSort.Height);
  P := ClientToScreen(P);
  PopupMenuSort.Popup(P.X, P.Y);
end;

// Ordenamiento
procedure TProjectTreeForm.SortByNameAscClick(Sender: TObject);
begin
  FSortColumn := 0;
  FSortDirection := 1;
  ApplySorting;
end;

procedure TProjectTreeForm.SortByNameDescClick(Sender: TObject);
begin
  FSortColumn := 0;
  FSortDirection := -1;
  ApplySorting;
end;

// Método auxiliar para aplicar filtro por tipo
procedure TProjectTreeForm.ApplyFilterByType(FilterType: TWebFileType);
begin
  FFilterFileType := FilterType;
  ApplyFilter;
end;

// ============ COMPARE AND REFRESH MENUS ============

procedure TProjectTreeForm.CompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: integer);
var
  Data1, Data2: PTreeNodeData;
begin
  Data1 := GetNodeData(Node1);
  Data2 := GetNodeData(Node2);

  if (Data1 = nil) or (Data2 = nil) then Exit;

  // Root siempre al inicio
  if Node1 = FRootNode then
    Result := -1
  else if Node2 = FRootNode then
    Result := 1
  else
  begin
    // Directorios primero
    if Data1^.IsDirectory and not Data2^.IsDirectory then
      Result := -1
    else if not Data1^.IsDirectory and Data2^.IsDirectory then
      Result := 1
    else
    begin
      case FSortColumn of
        0: // Nombre
          Result := CompareText(Data1^.FileName, Data2^.FileName);
        1: // Tamaño
          Result := CompareValue(Data1^.FileSize, Data2^.FileSize);
        2: // Tipo
          Result := CompareText(GetFileTypeDescription(Data1^.FileType), GetFileTypeDescription(Data2^.FileType));
        3: // Fecha
          Result := CompareValue(Data1^.ModifiedDate, Data2^.ModifiedDate);
        else
          Result := CompareText(Data1^.FileName, Data2^.FileName);
      end;

      if FSortDirection < 0 then
        Result := -Result;
    end;
  end;
end;

procedure TProjectTreeForm.ApplySorting;
begin
  VirtualStringTree1.SortTree(0, VirtualTrees.sdAscending);
end;


// Actualizar checks del menú de ordenamiento
procedure TProjectTreeForm.UpdateMenuChecks(Sender: TObject);
begin
  SortByNameAsc.Checked := (FSortColumn = 0) and (FSortDirection = 1);
  SortByNameDesc.Checked := (FSortColumn = 0) and (FSortDirection = -1);
  SortByType.Checked := (FSortColumn = 2);
  SortBySize.Checked := (FSortColumn = 1);
  SortByDate.Checked := (FSortColumn = 3);
end;

procedure TProjectTreeForm.FilterComboBox1Change(Sender: TObject);
begin
  case FilterComboBox1.ItemIndex of  //what entry (which item) has currently been chosen
    0: ApplyFilterByType(wftOther);
    1: ApplyFilterByType(wftHTML);
    2: ApplyFilterByType(wftCSS);
    3: ApplyFilterByType(wftJavaScript);
    4: ApplyFilterByType(wftJSON);
    5: ApplyFilterByType(wftSVG);
    6: ApplyFilterByType(wftXML);
    7: ApplyFilterByType(wftImage);
    8: ApplyFilterByType(wftFont);
  end;
end;

procedure TProjectTreeForm.TreeFilterEdit1AfterFilter(Sender: TObject);
begin
  // Actualizar contador de elementos visibles
  FCurrentFilter := TreeFilterEdit1.Text;

  // Si hay filtro de texto, limpiar filtro por tipo
  if FCurrentFilter <> '' then
    FFilterFileType := wftOther;
end;

// Eventos expandir/colapsar para iconos dinámicos


// ============ PROJECT MANAGEMENT ============

procedure TProjectTreeForm.SetProject(AProject: TETEditProject);
begin
  FProject := AProject;
  RefreshTree;
end;

procedure TProjectTreeForm.FormShow(Sender: TObject);
begin
  inherited;
  // Refresh tree whenever the form is shown
  RefreshTree;
end;

procedure TProjectTreeForm.VirtualStringTree2DragDrop(Sender: TBaseVirtualTree;
  Source: TObject; DataObject: IDataObject; Formats: TFormatArray;
  Shift: TShiftState; const Pt: TPoint; var Effect: longword; Mode: TDropMode);
begin

end;

procedure TProjectTreeForm.VirtualStringTree2DragOver(Sender: TBaseVirtualTree;
  Source: TObject; Shift: TShiftState; State: TDragState; const Pt: TPoint;
  Mode: TDropMode; var Effect: longword; var Accept: boolean);
begin

end;

procedure TProjectTreeForm.RefreshTree;
begin
  LoadProjectTree;
end;

procedure TProjectTreeForm.LoadProjectTree;
begin
  if VirtualStringTree1 = nil then
    Exit;

  VirtualStringTree1.BeginUpdate;
  try
    VirtualStringTree1.Clear;

    if (FProject <> nil) and DirectoryExists(FProject.ProjectPath) then
    begin
      // Add project root node
      FRootNode := VirtualStringTree1.AddChild(nil);
      with GetNodeData(FRootNode)^ do
      begin
        FileName := FProject.ProjectName;
        FullPath := ExcludeTrailingPathDelimiter(FProject.ProjectPath);
        IsDirectory := True;
        FileSize := 0;
        ModifiedDate := Now;
        FileType := wftOther;
      end;

      // Load actual directory contents
      AddDirectory(FRootNode, FProject.ProjectPath);

      VirtualStringTree1.Expanded[FRootNode] := True;
    end;

  finally
    VirtualStringTree1.EndUpdate;
  end;

  // Force redraw
  VirtualStringTree1.Invalidate;
end;

procedure TProjectTreeForm.AddDirectory(ParentNode: PVirtualNode; const Path: string);
var
  SearchRec: TSearchRec;
  ChildNode: PVirtualNode;
  NodeData: PTreeNodeData;
  NormalizedPath: string;
begin
  // Normalizar la ruta: eliminar delimitador final
  NormalizedPath := ExcludeTrailingPathDelimiter(Path);

  if FindFirst(NormalizedPath + PathDelim + '*', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        // Saltar directorios especiales
        if (SearchRec.Name = '.') or (SearchRec.Name = '..') then
          Continue;

        ChildNode := VirtualStringTree1.AddChild(ParentNode);
        NodeData := GetNodeData(ChildNode);

        if NodeData <> nil then
        begin
          NodeData^.FileName := SearchRec.Name;
          NodeData^.FullPath := NormalizedPath + PathDelim + SearchRec.Name;
          NodeData^.IsDirectory := (SearchRec.Attr and faDirectory) <> 0;
          NodeData^.FileType := wftOther;

          if not NodeData^.IsDirectory then
          begin
            NodeData^.FileSize := SearchRec.Size;
            NodeData^.ModifiedDate := FileDateToDateTime(SearchRec.Time);
            NodeData^.FileType := DetectWebFileType(NodeData^.FullPath);
          end
          else
          begin
            NodeData^.FileSize := 0;
            NodeData^.ModifiedDate := 0;
            // Recursión para subdirectorios
            AddDirectory(ChildNode, NodeData^.FullPath);
          end;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;
end;

// ============ FILE OPERATIONS ============

function TProjectTreeForm.IsDirectory(const Path: string): boolean;
begin
  Result := DirectoryExists(Path);
end;

function TProjectTreeForm.GetSelectedNode: PVirtualNode;
begin
  if VirtualStringTree1 <> nil then
    Result := VirtualStringTree1.GetFirstSelected
  else
    Result := nil;
end;

function TProjectTreeForm.CanDeleteNode(Node: PVirtualNode): boolean;
var
  Path: string;
begin
  Result := False;
  if (Node = nil) or (Node = FRootNode) then
    Exit;

  Path := GetNodePath(Node);
  if Path = '' then
    Exit;

  // Can't delete the project root
  if (FProject <> nil) and (Path = FProject.ProjectPath) then
    Exit;

  Result := True;
end;

function TProjectTreeForm.GetNodePath(Node: PVirtualNode): string;
var
  NodeData: PTreeNodeData;
begin
  Result := '';
  if Node <> nil then
  begin
    NodeData := GetNodeData(Node);
    if NodeData <> nil then
      Result := NodeData^.FullPath;
  end;
end;

function TProjectTreeForm.GetNodeParentPath(Node: PVirtualNode): string;
var
  Path: string;
begin
  Path := GetNodePath(Node);
  if Path <> '' then
    Result := ExtractFilePath(ExcludeTrailingPathDelimiter(Path))
  else
    Result := '';
end;

function TProjectTreeForm.GetFileSizeAndDate(const FilePath: string; out FileSize: int64; out ModifiedDate: TDateTime): boolean;
var
  SearchRec: TSearchRec;
begin
  Result := False;
  if FindFirst(FilePath, faAnyFile, SearchRec) = 0 then
  begin
    try
      FileSize := SearchRec.Size;
      ModifiedDate := FileDateToDateTime(SearchRec.Time);
      Result := True;
    finally
      FindClose(SearchRec);
    end;
  end;
end;

procedure TProjectTreeForm.UpdateNodeFileInfo(Node: PVirtualNode);
var
  NodeData: PTreeNodeData;
  FileSize: int64;
  ModifiedDate: TDateTime;
begin
  NodeData := GetNodeData(Node);
  if (NodeData <> nil) and (NodeData^.FullPath <> '') then
  begin
    if GetFileSizeAndDate(NodeData^.FullPath, FileSize, ModifiedDate) then
    begin
      NodeData^.FileSize := FileSize;
      NodeData^.ModifiedDate := ModifiedDate;
    end
    else
    begin
      NodeData^.FileSize := 0;
      NodeData^.ModifiedDate := 0;
    end;
  end;
end;

// ============ DRAG AND DROP ============

function TProjectTreeForm.CanDragNode(Node: PVirtualNode): boolean;
begin
  Result := (Node <> nil) and (Node <> FRootNode) and (VirtualStringTree1.SelectedCount > 0);
end;

function TProjectTreeForm.CanDropNode(TargetNode, SourceNode: PVirtualNode; Mode: TDropMode): boolean;
var
  SourceData, TargetData: PTreeNodeData;
  SourcePath, TargetPath: string;
begin
  Result := False;

  if (TargetNode = nil) or (SourceNode = nil) then
    Exit;

  if TargetNode = SourceNode then
    Exit;

  if VirtualStringTree1.HasAsParent(TargetNode, SourceNode) then
    Exit;

  SourceData := GetNodeData(SourceNode);
  TargetData := GetNodeData(TargetNode);

  if (SourceData = nil) or (TargetData = nil) then
    Exit;

  SourcePath := SourceData^.FullPath;
  TargetPath := TargetData^.FullPath;

  if SourcePath = TargetPath then
    Exit;

  if not TargetData^.IsDirectory and (Mode = dmOnNode) then
    Exit;

  Result := True;
end;

function TProjectTreeForm.GetDropTargetPath(TargetNode: PVirtualNode; Mode: TDropMode): string;
var
  TargetData: PTreeNodeData;
  ParentNode: PVirtualNode;
  ParentData: PTreeNodeData;
begin
  Result := '';

  if TargetNode = nil then
    Exit;

  TargetData := GetNodeData(TargetNode);
  if TargetData = nil then
    Exit;

  case Mode of
    dmNowhere:
      Result := '';

    dmAbove, dmBelow:
    begin
      ParentNode := VirtualStringTree1.NodeParent[TargetNode];
      if ParentNode <> nil then
      begin
        ParentData := GetNodeData(ParentNode);
        if (ParentData <> nil) and ParentData^.IsDirectory then
          Result := ParentData^.FullPath
        else if (ParentNode = FRootNode) and (FProject <> nil) then
          Result := FProject.ProjectPath;
      end;
    end;

    dmOnNode:
    begin
      if TargetData^.IsDirectory then
        Result := TargetData^.FullPath;
    end;
  end;
end;

function TProjectTreeForm.MoveFileOrFolder(const SourcePath, DestPath: string): boolean;
var
  DestFullPath: string;
begin
  Result := False;

  if (SourcePath = '') or (DestPath = '') then
    Exit;

  DestFullPath := IncludeTrailingPathDelimiter(DestPath) + ExtractFileName(SourcePath);

  if FileExists(DestFullPath) or DirectoryExists(DestFullPath) then
  begin
    if MessageDlg('File exists', Format('"%s" already exists in destination. Overwrite?', [ExtractFileName(SourcePath)]), mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
      Exit;

    if DirectoryExists(DestFullPath) then
      DeleteDirectory(DestFullPath, False)
    else
      DeleteFile(DestFullPath);
  end;

  try
    Result := RenameFile(SourcePath, DestFullPath);

    if not Result then
      ShowMessage('Failed to move: ' + SourcePath);

  except
    on E: Exception do
      ShowMessage('Error moving: ' + E.Message);
  end;
end;

procedure TProjectTreeForm.UpdateNodeAfterMove(Node: PVirtualNode; NewPath: string);
var
  NodeData: PTreeNodeData;
  NewFileName: string;
begin
  NodeData := GetNodeData(Node);
  if NodeData <> nil then
  begin
    NewFileName := ExtractFileName(NewPath);
    NodeData^.FileName := NewFileName;
    NodeData^.FullPath := NewPath;
    UpdateNodeFileInfo(Node);

    if NodeData^.IsDirectory then
      UpdateChildPaths(Node, NewPath);
  end;
end;

procedure TProjectTreeForm.UpdateChildPaths(ParentNode: PVirtualNode; NewParentPath: string);
var
  ChildNode: PVirtualNode;
  ChildData: PTreeNodeData;
begin
  ChildNode := VirtualStringTree1.GetFirstChild(ParentNode);
  while ChildNode <> nil do
  begin
    ChildData := GetNodeData(ChildNode);
    if ChildData <> nil then
    begin
      ChildData^.FullPath := IncludeTrailingPathDelimiter(NewParentPath) + ChildData^.FileName;

      if ChildData^.IsDirectory then
        UpdateChildPaths(ChildNode, ChildData^.FullPath);
    end;

    ChildNode := VirtualStringTree1.GetNextSibling(ChildNode);
  end;
end;

// ============ DRAG AND DROP EVENTS ============

procedure TProjectTreeForm.VirtualStringTree1DragAllowed(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: boolean);
begin
  Allowed := CanDragNode(Node);
  if Allowed then
    FDragNode := Node;
end;

procedure TProjectTreeForm.VirtualStringTree1StartDrag(Sender: TObject; var DragObject: TDragObject);
begin
  FDragNode := VirtualStringTree1.GetFirstSelected;
  FIsDragging := True;
  Screen.Cursor := crDrag;
end;

procedure TProjectTreeForm.VirtualStringTree1EndDrag(Sender, Target: TObject; X, Y: integer);
begin
  Screen.Cursor := crDefault;
  FDragNode := nil;
  FIsDragging := False;
end;

procedure TProjectTreeForm.VirtualStringTree1DragOver(Sender: TBaseVirtualTree; Source: TObject; Shift: TShiftState; State: TDragState; const Pt: TPoint; Mode: TDropMode; var Effect: longword; var Accept: boolean);
var
  TargetNode: PVirtualNode;
  DragNodes: TNodeArray;
  I: integer;
begin
  Accept := False;
  Effect := DROPEFFECT_NONE;

  if (Source <> Sender) or not FIsDragging then
    Exit;

  TargetNode := VirtualStringTree1.DropTargetNode;
  if TargetNode = nil then
    Exit;

  DragNodes := VirtualStringTree1.GetSortedSelection(True);

  for I := 0 to High(DragNodes) do
  begin
    if CanDropNode(TargetNode, DragNodes[I], Mode) then
    begin
      Accept := True;
      Effect := DROPEFFECT_MOVE;
      Break;
    end;
  end;
end;

procedure TProjectTreeForm.VirtualStringTree1DragDrop(
  Sender: TBaseVirtualTree; Source: TObject; DataObject: IDataObject;
  Formats: TFormatArray; Shift: TShiftState; const Pt: TPoint;
  var Effect: LongWord; Mode: TDropMode);
var
  TargetNode: PVirtualNode;
  DragNodes: TNodeArray;
  I: Integer;
  SourceData: PTreeNodeData;
  TargetPath, NewPath: String;
  NewParentNode: PVirtualNode;
  MovedCount: Integer;
begin
  if (Source <> Sender) or (Effect = DROPEFFECT_NONE) or not FIsDragging then
    Exit;

  TargetNode := VirtualStringTree1.DropTargetNode;
  if TargetNode = nil then
    Exit;

  TargetPath := GetDropTargetPath(TargetNode, Mode);
  if TargetPath = '' then
    Exit;

  DragNodes := VirtualStringTree1.GetSortedSelection(True);
  MovedCount := 0;

  VirtualStringTree1.BeginUpdate;
  try
    for I := 0 to High(DragNodes) do
    begin
      if not CanDropNode(TargetNode, DragNodes[I], Mode) then
        Continue;

      SourceData := GetNodeData(DragNodes[I]);
      if SourceData = nil then
        Continue;

      if MessageDlg('Move Item',
                    Format('Move "%s" to "%s"?',
                    [SourceData^.FileName, ExtractFileName(TargetPath)]),
                    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
        Continue;

      if MoveFileOrFolder(SourceData^.FullPath, TargetPath) then
      begin
        NewPath := IncludeTrailingPathDelimiter(TargetPath) + SourceData^.FileName;

        if Mode = dmOnNode then
          NewParentNode := TargetNode
        else
          NewParentNode := VirtualStringTree1.NodeParent[TargetNode];

        VirtualStringTree1.MoveTo(DragNodes[I], NewParentNode, amAddChildLast, False);

        UpdateNodeAfterMove(DragNodes[I], NewPath);

        Inc(MovedCount);
      end;
    end;

    if MovedCount > 0 then
    begin
      if Mode = dmOnNode then
        VirtualStringTree1.Sort(TargetNode, 0, VirtualTrees.sdAscending)
      else if NewParentNode <> nil then
        VirtualStringTree1.Sort(NewParentNode, 0, VirtualTrees.sdAscending);
    end;

  finally
    VirtualStringTree1.EndUpdate;
    if MovedCount > 0 then
      VirtualStringTree1.Invalidate;
  end;

  VirtualStringTree1.ClearSelection;
end;

// ============ EXISTING EVENT HANDLERS ============

procedure TProjectTreeForm.FormDestroy(Sender: TObject);
begin
  // Components will be freed automatically by Parent
end;

procedure TProjectTreeForm.PopupMenu1Popup(Sender: TObject);
begin

end;


procedure TProjectTreeForm.VirtualStringTree1DblClick(Sender: TObject);
var
  SelectedFile: string;
begin
  SelectedFile := GetSelectedFile;
  if (SelectedFile <> '') and FileExists(SelectedFile) then
  begin
    if Assigned(OnDblClick) then
      OnDblClick(Self);
  end;
end;

procedure TProjectTreeForm.VirtualStringTree1FreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
Data: PTreeNodeData;
begin
if Node = nil then Exit;
Data := GetNodeData(Node);
if Data <> nil then
  Finalize(Data^);   // libera strings internamente
end;

procedure TProjectTreeForm.VirtualStringTree1KeyPress(Sender: TObject; var Key: char);
begin
  case Key of
    #13: // Enter key - open file/folder
      VirtualStringTree1DblClick(Sender);
  end;
end;

procedure TProjectTreeForm.VirtualStringTree1Editing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: boolean);
begin
  Allowed := (Column = 0) and (Node <> FRootNode);
end;

procedure TProjectTreeForm.VirtualStringTree1NewText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; const NewText: string);
var
  NodeData: PTreeNodeData;
  OldPath, NewPath, ParentPath: string;
begin
  if (Column = 0) and (Node <> FRootNode) then
  begin
    NodeData := GetNodeData(Node);
    if (NodeData <> nil) and (NewText <> '') and (NewText <> NodeData^.FileName) then
    begin
      OldPath := NodeData^.FullPath;
      ParentPath := GetNodeParentPath(Node);
      NewPath := IncludeTrailingPathDelimiter(ParentPath) + NewText;

      try
        if RenameFile(OldPath, NewPath) then
        begin
          NodeData^.FileName := NewText;
          NodeData^.FullPath := NewPath;
          UpdateNodeFileInfo(Node);
          VirtualStringTree1.InvalidateNode(Node);
        end
        else
          ShowMessage('Could not rename: ' + OldPath);
      except
        on E: Exception do
          ShowMessage('Error renaming: ' + E.Message);
      end;
    end;
  end;
end;

procedure TProjectTreeForm.VirtualStringTree1ContextPopup(Sender: TObject; MousePos: TPoint; var Handled: boolean);
var
  Node: PVirtualNode;
  Path: string;
  ScreenPos: TPoint;
begin
  TDebugLogger.Debug('  VirtualStringTree1ContextPopup START', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  Node := VirtualStringTree1.GetNodeAt(MousePos.X, MousePos.Y);

  if Node <> nil then
  begin
    VirtualStringTree1.ClearSelection;
    VirtualStringTree1.Selected[Node] := True;

    Path := GetNodePath(Node);

    Open1.Enabled := (Path <> '') and FileExists(Path);
    Rename1.Enabled := (Node <> FRootNode);
    Delete1.Enabled := CanDeleteNode(Node);

    if IsDirectory(Path) then
    begin
      NewFile1.Caption := 'New File in Folder';
      NewFolder1.Caption := 'New Subfolder';
    end
    else
    begin
      NewFile1.Caption := 'New File';
      NewFolder1.Caption := 'New Folder';
    end;
    if Assigned(FOnPopulatePluginMenu) then
    FOnPopulatePluginMenu(PopupMenu1, Path);
    // Convertir coordenadas relativas a pantalla
    ScreenPos := VirtualStringTree1.ClientToScreen(MousePos);
    PopupMenu1.Popup(ScreenPos.X, ScreenPos.Y);
  end;

  Handled := True;
end;

procedure TProjectTreeForm.Open1Click(Sender: TObject);
begin
  VirtualStringTree1DblClick(Sender);
end;

procedure TProjectTreeForm.NewFile1Click(Sender: TObject);
var
  SelectedNode, NewNode: PVirtualNode;
  ParentPath, NewFileName, NewFilePath: string;
  NodeData: PTreeNodeData;
  Ext: string;
begin
  SelectedNode := GetSelectedNode;
  if SelectedNode = nil then
    SelectedNode := FRootNode;

  ParentPath := GetNodePath(SelectedNode);
  if ParentPath = '' then
    ParentPath := FProject.ProjectPath;

  NodeData := GetNodeData(SelectedNode);
  if (SelectedNode <> FRootNode) and (NodeData <> nil) and (not NodeData^.IsDirectory) then
  begin
    ParentPath := GetNodeParentPath(SelectedNode);
    SelectedNode := VirtualStringTree1.NodeParent[SelectedNode];
  end;

  SaveDialog1.Title := 'Create New File';
  SaveDialog1.InitialDir := ParentPath;
  SaveDialog1.FileName := 'newfile.html';
  SaveDialog1.Filter :=
    'HTML files (*.html;*.htm)|*.html;*.htm|' + 'CSS files (*.css)|*.css|' + 'JavaScript files (*.js)|*.js|' + 'JSON files (*.json)|*.json|' + 'SVG files (*.svg)|*.svg|' + 'All files (*.*)|*.*';
  SaveDialog1.DefaultExt := '.html';
  SaveDialog1.Options := [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing];

  if SaveDialog1.Execute then
  begin
    NewFilePath := SaveDialog1.FileName;
    NewFileName := ExtractFileName(NewFilePath);
    Ext := ExtractFileExt(NewFileName);

    if FileExists(NewFilePath) then
    begin
      if MessageDlg('File exists', 'Overwrite existing file?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
        Exit;
    end;

    with TStringList.Create do
    try
      if (Ext = '.html') or (Ext = '.htm') then
        Text := '<!DOCTYPE html>' + LineEnding + '<html>' + LineEnding + '<head>' + LineEnding + '    <meta charset="utf-8">' + LineEnding +
          '    <title>New Page</title>' + LineEnding + '</head>' + LineEnding + '<body>' + LineEnding + '    ' + LineEnding + '</body>' + LineEnding + '</html>'
      else if Ext = '.css' then
        Text := '/* CSS Styles */' + LineEnding
      else if Ext = '.js' then
        Text := '// JavaScript Code' + LineEnding
      else if Ext = '.json' then
        Text := '{' + LineEnding + '}' + LineEnding
      else if Ext = '.svg' then
        Text := '<?xml version="1.0" encoding="UTF-8"?>' + LineEnding + '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">' + LineEnding + '</svg>';

      SaveToFile(NewFilePath);
    finally
      Free;
    end;

    // Add to tree
    NewNode := VirtualStringTree1.AddChild(SelectedNode);
    NodeData := GetNodeData(NewNode);
    if NodeData <> nil then
    begin
      NodeData^.FileName := NewFileName;
      NodeData^.FullPath := NewFilePath;
      NodeData^.IsDirectory := False;
      NodeData^.FileType := DetectWebFileType(NewFilePath);
      UpdateNodeFileInfo(NewNode);
    end;

    VirtualStringTree1.ValidateNode(NewNode, False);
    VirtualStringTree1.Selected[NewNode] := True;
    VirtualStringTree1.Expanded[SelectedNode] := True;

    // Auto-open the new file
    VirtualStringTree1DblClick(Self);
  end;
end;

procedure TProjectTreeForm.NewFolder1Click(Sender: TObject);
var
  SelectedNode, NewNode: PVirtualNode;
  ParentPath, NewFolderName, NewFolderPath: string;
  NodeData: PTreeNodeData;
  ResultOK: boolean;
begin
  SelectedNode := GetSelectedNode;
  if SelectedNode = nil then
    SelectedNode := FRootNode;

  ParentPath := GetNodePath(SelectedNode);
  if ParentPath = '' then
    ParentPath := FProject.ProjectPath;

  // If selected node is a file, use its parent directory
  NodeData := GetNodeData(SelectedNode);
  if (SelectedNode <> FRootNode) and (NodeData <> nil) and (not NodeData^.IsDirectory) then
  begin
    ParentPath := GetNodeParentPath(SelectedNode);
    SelectedNode := VirtualStringTree1.NodeParent[SelectedNode];
  end;

  // Get folder name with validation
  repeat
    NewFolderName := 'NewFolder';
    ResultOK := InputQuery('New Folder', 'Enter folder name:', NewFolderName);

    if not ResultOK then
      Exit; // User cancelled

    if NewFolderName = '' then
    begin
      ShowMessage('Folder name cannot be empty.');
      Continue;
    end;

    // Check for invalid characters in folder name
    if (Pos('/', NewFolderName) > 0) or (Pos('\', NewFolderName) > 0) or (Pos(':', NewFolderName) > 0) or (Pos('*', NewFolderName) > 0) or (Pos('?', NewFolderName) > 0) or
      (Pos('"', NewFolderName) > 0) or (Pos('<', NewFolderName) > 0) or (Pos('>', NewFolderName) > 0) or (Pos('|', NewFolderName) > 0) then
    begin
      ShowMessage('Folder name contains invalid characters: / \ : * ? " < > |');
      Continue;
    end;

    Break; // Valid name
  until False;

  NewFolderPath := IncludeTrailingPathDelimiter(ParentPath) + NewFolderName;

  if not DirectoryExists(NewFolderPath) then
  begin
    if ForceDirectories(NewFolderPath) then
    begin
      // Add to tree
      NewNode := VirtualStringTree1.AddChild(SelectedNode);
      NodeData := GetNodeData(NewNode);
      if NodeData <> nil then
      begin
        NodeData^.FileName := NewFolderName;
        NodeData^.FullPath := NewFolderPath;
        NodeData^.IsDirectory := True;
        NodeData^.FileSize := 0;
        NodeData^.ModifiedDate := Now;
        NodeData^.FileType := wftOther;
      end;

      VirtualStringTree1.ValidateNode(NewNode, False);
      VirtualStringTree1.Selected[NewNode] := True;
      VirtualStringTree1.Expanded[SelectedNode] := True;
    end
    else
      ShowMessage('Could not create folder: ' + NewFolderPath);
  end
  else
    ShowMessage('Folder already exists: ' + NewFolderPath);
end;

procedure TProjectTreeForm.Rename1Click(Sender: TObject);
var
  Node: PVirtualNode;
begin
  Node := GetSelectedNode;
  if (Node <> nil) and (Node <> FRootNode) then
  begin
    VirtualStringTree1.EditNode(Node, 0);
  end;
end;

procedure TProjectTreeForm.Delete1Click(Sender: TObject);
var
  Node: PVirtualNode;
  NodeData: PTreeNodeData;
  Path, NodeName: string;
  Response: integer;
begin
  Node := GetSelectedNode;
  if not CanDeleteNode(Node) then
    Exit;

  NodeData := GetNodeData(Node);
  if (NodeData = nil) or (NodeData^.FullPath = '') then
    Exit;

  Path := NodeData^.FullPath;
  NodeName := NodeData^.FileName;
  if NodeName = '' then
    NodeName := Path;

  if NodeData^.IsDirectory then
    Response := MessageDlg('Delete Folder', 'Delete folder "' + NodeName + '" and all its contents?', mtConfirmation, [mbYes, mbNo], 0)
  else
    Response := MessageDlg('Delete File', 'Delete file "' + NodeName + '"?', mtConfirmation, [mbYes, mbNo], 0);

  if Response = mrYes then
  begin
    try
      if NodeData^.IsDirectory then
        DeleteDirectory(Path, False)
      else
        DeleteFile(Path);

      // Remove from tree
      VirtualStringTree1.DeleteNode(Node);
    except
      on E: Exception do
        ShowMessage('Error deleting: ' + E.Message);
    end;
  end;
end;

procedure TProjectTreeForm.Refresh1Click(Sender: TObject);
begin
  RefreshTree;
end;

function TProjectTreeForm.GetSelectedFile: string;
var
  Node: PVirtualNode;
  NodeData: PTreeNodeData;
begin
  Result := '';
  Node := GetSelectedNode;

  if (Node <> nil) and (Node <> FRootNode) then
  begin
    NodeData := GetNodeData(Node);
    if (NodeData <> nil) and (not NodeData^.IsDirectory) then
      Result := NodeData^.FullPath;
  end;
end;

procedure TProjectTreeForm.SelectFile(const FilePath: string);
begin
  // TODO: Implement file search and selection
end;

// ============ DETAILS PANEL METHODS ============

procedure TProjectTreeForm.VirtualStringTree1FocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
begin
  UpdateDetailsPanel(Node);
end;

procedure TProjectTreeForm.UpdateDetailsPanel(Node: PVirtualNode);
var
  NodeData: PTreeNodeData;
  ImgWidth, ImgHeight, ColorDepth: integer;
  ImageFormat, FontName, FontStyle, FontFormat: string;
begin
  ClearDetailsPanel;
  if Node = nil then
  begin
    Exit;
  end;

  NodeData := GetNodeData(Node);
  if NodeData = nil then
  begin
    Exit;
  end;

  if FCurrentPreviewFile = NodeData^.FullPath then
    Exit;

  FCurrentPreviewFile := NodeData^.FullPath;

  PanelDetails.Visible := True;
  Splitter1.Visible := True;

  lblFileName.Caption := NodeData^.FileName;
  lblFilePath.Caption := NodeData^.FullPath;

  if NodeData^.IsDirectory then
  begin
    lblFileSize.Caption := '<Directory>';
    lblFileType.Caption := 'Folder';
    lblFileName.Caption := '';
  end
  else
  begin
    lblFileSize.Caption := FormatFileSize(NodeData^.FileSize);

    NodeData^.FileType := DetectWebFileType(NodeData^.FullPath);
    lblFileType.Caption := GetFileTypeDescription(NodeData^.FileType);

    if NodeData^.ModifiedDate > 0 then
      lblModified.Caption := FormatDateTime('yyyy-mm-dd hh:nn:ss', NodeData^.ModifiedDate)
    else
      lblModified.Caption := 'Unknown';

    imgPreview.Picture := nil;
    memoPreview.Clear;

    case NodeData^.FileType of
      wftImage:
      begin
        if NodeData^.FileSize <= MAX_IMAGE_PREVIEW_SIZE then
        begin
          SafeLoadImagePreview(NodeData^.FullPath);

          // Get additional image info
          if GetImageInfo(NodeData^.FullPath, ImgWidth, ImgHeight, ColorDepth, ImageFormat) then
          begin
            lblDimensions.Caption := Format('%d x %d pixels', [ImgWidth, ImgHeight]);
            lblColorDepth.Caption := Format('%d-bit', [ColorDepth]);
          end;
        end
        else
          lblPreviewInfo.Caption := 'Image too large for preview';
      end;

      wftFont:
      begin
        if NodeData^.FileSize <= MAX_FONT_PREVIEW_SIZE then
          SafeLoadFontPreview(NodeData^.FullPath)
        else
          lblPreviewInfo.Caption := 'Font file too large for preview';
      end;

      wftHTML, wftCSS, wftJavaScript, wftJSON, wftXML, wftSVG, wftText, wftProject:
      begin
        if NodeData^.FileSize <= MAX_TEXT_PREVIEW_SIZE then
          SafeLoadTextPreview(NodeData^.FullPath)
        else
          lblPreviewInfo.Caption := 'Text file too large for preview';
      end;

      wftOther:
      begin
        if IsBinaryFile(NodeData^.FullPath) then
          lblPreviewInfo.Caption := 'Binary file - no preview available'
        else if NodeData^.FileSize <= MAX_TEXT_PREVIEW_SIZE then
          SafeLoadTextPreview(NodeData^.FullPath)
        else
          lblPreviewInfo.Caption := 'File too large for preview';
      end;
    end;
  end;
end;

procedure TProjectTreeForm.ClearDetailsPanel;
begin
  FCurrentPreviewFile := '';
  FCurrentFontName := '';
  lblFileName.Caption := '';
  lblFilePath.Caption := '';
  lblFileSize.Caption := '';
  lblModified.Caption := '';
  lblFileType.Caption := '';
  lblDimensions.Caption := '';
  lblColorDepth.Caption := '';
  lblFontInfo.Caption := '';
  imgPreview.Picture := nil;
  memoPreview.Clear;
  lblPreviewInfo.Caption := 'NO PREVIEW';
  PanelFontPreview.Visible := False;
  PanelImageInfo.Visible := False;
  PanelDetails.Visible := False;
  Splitter1.Visible := False;
end;

procedure TProjectTreeForm.SafeLoadImagePreview(const FilePath: string);
begin
  try
    PanelImageInfo.Visible := True;
    PanelFontPreview.Visible := False;
    imgPreview.Picture.LoadFromFile(FilePath);
    PageControl1.ActivePage := TabSheetPreview;
  except
    on E: Exception do
    begin
      imgPreview.Picture := nil;
      lblPreviewInfo.Caption := 'Failed to load image: ' + E.Message;
      PanelImageInfo.Visible := False;
    end;
  end;
end;

procedure TProjectTreeForm.SafeLoadFontPreview(const FilePath: string);
var
  FontName, FontStyle, FontFormat: string;
begin
  try
    if GetFontInfo(FilePath, FontName, FontStyle, FontFormat) then
    begin
      FCurrentFontName := FontName;

      PanelFontPreview.Visible := True;
      lblFontName.Caption := FontName;
      lblFontStyle.Caption := FontStyle;
      lblFontFormat.Caption := FontFormat;

      // Update font preview
      UpdateFontPreview();

      // Switch to preview tab
      PageControl1.ActivePage := TabSheetPreview;

      lblPreviewInfo.Caption := Format('Font: %s (%s)', [FontName, FontFormat]);
    end
    else
    begin
      lblPreviewInfo.Caption := 'Could not read font information';
      PanelFontPreview.Visible := False;
    end;
  except
    on E: Exception do
    begin
      lblPreviewInfo.Caption := 'Error loading font: ' + E.Message;
      PanelFontPreview.Visible := False;
    end;
  end;
end;

procedure TProjectTreeForm.SafeLoadTextPreview(const FilePath: string);
var
  Lines: TStringList;
  EncodingInfo: string;
begin
  try
    EncodingInfo := GetFileEncoding(FilePath);
    PanelFontPreview.Visible := False;
    PanelImageInfo.Visible := False;
    PanelDetails.Visible := True;

    Lines := GetFirstLines(FilePath, MAX_PREVIEW_LINES);
    try
      memoPreview.Lines.BeginUpdate;
      try
        memoPreview.Lines.Clear;

        if EncodingInfo <> '' then
          memoPreview.Lines.Add('// Encoding: ' + EncodingInfo);

        memoPreview.Lines.AddStrings(Lines);

        if Lines.Count >= MAX_PREVIEW_LINES then
          lblPreviewInfo.Caption := Format('Showing first %d lines', [MAX_PREVIEW_LINES])
        else
          lblPreviewInfo.Caption := Format('%d lines', [Lines.Count]);

      finally
        memoPreview.Lines.EndUpdate;
      end;

      PageControl1.ActivePage := TabSheetPreview;

    finally
      Lines.Free;
    end;
  except
    on E: Exception do
    begin
      memoPreview.Clear;
      memoPreview.Lines.Add('Unable to preview file: ' + E.Message);
      lblPreviewInfo.Caption := 'Preview error';
    end;
  end;
end;

// ============ BUTTON EVENTS ============

procedure TProjectTreeForm.btnOpenLocationClick(Sender: TObject);
var
  Node: PVirtualNode;
  NodeData: PTreeNodeData;
  Path: string;
begin
  Node := GetSelectedNode;
  if Node = nil then Exit;

  NodeData := GetNodeData(Node);
  if NodeData = nil then Exit;

  Path := ExtractFilePath(NodeData^.FullPath);
  if DirectoryExists(Path) then
    opendocument(Path);
end;

procedure TProjectTreeForm.btnPropertiesClick(Sender: TObject);
var
  Node: PVirtualNode;
  NodeData: PTreeNodeData;
  ImgWidth, ImgHeight, ColorDepth: integer;
  ImageFormat, FontName, FontStyle, FontFormat: string;
  InfoText: string;
begin
  Node := GetSelectedNode;
  if Node = nil then Exit;

  NodeData := GetNodeData(Node);
  if NodeData = nil then Exit;

  InfoText := 'Properties:' + LineEnding + 'Name: ' + NodeData^.FileName + LineEnding + 'Path: ' + NodeData^.FullPath + LineEnding + 'Type: ' +
    GetFileTypeDescription(NodeData^.FileType) + LineEnding + 'Size: ' + FormatFileSize(NodeData^.FileSize) + LineEnding + 'Modified: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', NodeData^.ModifiedDate);

  // Add extra info based on file type
  case NodeData^.FileType of
    wftImage:
    begin
      if GetImageInfo(NodeData^.FullPath, ImgWidth, ImgHeight, ColorDepth, ImageFormat) then
      begin
        InfoText := InfoText + LineEnding + 'Dimensions: ' + IntToStr(ImgWidth) + ' x ' + IntToStr(ImgHeight) + LineEnding + 'Format: ' + ImageFormat +
          LineEnding + 'Color Depth: ' + IntToStr(ColorDepth) + '-bit';
      end;
    end;

    wftFont:
    begin
      if GetFontInfo(NodeData^.FullPath, FontName, FontStyle, FontFormat) then
      begin
        InfoText := InfoText + LineEnding + 'Font Name: ' + FontName + LineEnding + 'Style: ' + FontStyle + LineEnding + 'Format: ' + FontFormat;
      end;
    end;
  end;

  ShowMessage(InfoText);
end;

procedure TProjectTreeForm.btnIncreaseFontClick(Sender: TObject);
var
  CurrentSize, NewSize: integer;
begin
  CurrentSize := StrToIntDef(cmbFontSize.Text, 16);
  NewSize := CurrentSize + 2;

  if NewSize > 72 then NewSize := 72;

  cmbFontSize.Text := IntToStr(NewSize);
  UpdateFontPreview;
end;

procedure TProjectTreeForm.btnDecreaseFontClick(Sender: TObject);
var
  CurrentSize, NewSize: integer;
begin
  CurrentSize := StrToIntDef(cmbFontSize.Text, 16);
  NewSize := CurrentSize - 2;

  if NewSize < 8 then NewSize := 8;

  cmbFontSize.Text := IntToStr(NewSize);
  UpdateFontPreview;
end;

procedure TProjectTreeForm.cmbFontSizeChange(Sender: TObject);
begin
  UpdateFontPreview;
end;

end.
