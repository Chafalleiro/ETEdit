unit uFileUtils;

{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils, FileUtil, LazFileUtils, DCPcrypt2, DCPmd5, DCPsha1, DCPsha256, uDebugLog, LResources, Math,
  uResDefs, uResOperations,
  resource, resreader, reswriter, bitmapresource, groupresource, groupiconresource, groupcursorresource;

type
  TWebFileType = (wftHTML, wftCSS, wftJavaScript, wftJSON,
    wftSVG, wftXML, wftImage, wftFont, wftVideo,
    wftAudio, wftOther, wftText, wftProject);

  TFileTypeInfo = record
    FileType: TWebFileType;
    MimeType: string;
    Description: string;
    CommonExtensions: array of string;
  end;

  TFileCopyOperation = record
    Source: string;
    Destination: string;
    Overwrite: boolean;
    Recursive: boolean; // Para directorios
  end;
  TFileCopyOperations = array of TFileCopyOperation;

  TFileChangeInfo = record
    FilePath: string;
    FileSize: int64;
    LastModified: TDateTime;
    Hash: string;
  end;

  TFileChangeTracker = class
  private
    FTrackedFiles: array of TFileChangeInfo;
    FHashFileDir: string;

    function GenerateFileHash(const FilePath: string): string;
    function GetHashFilePath(const FilePath: string): string;
  public
    constructor Create(const HashFileDir: string = 'docs/.hashes');

    function HasFileChanged(const FilePath: string): boolean;
    procedure UpdateFileHash(const FilePath: string);
    function GetFileHash(const FilePath: string): string;
    procedure RemoveFile(const FilePath: string);

    procedure LoadHashes;
    procedure SaveHashes;
  end;

// Detectar tipo
function DetectWebFileType(const FileName: string): TWebFileType;
function GetFileTypeInfo(FileType: TWebFileType): TFileTypeInfo;
function IsWebFile(const FileName: string): boolean;
function GetFileIconIndex(const FileName: string; IsDirectory: boolean = False; IsExpanded: boolean = False): integer;
// Operaciones con archivos
function CopyFileWithProgress(const Source, Destination: string; Overwrite: boolean = True): boolean;
function CopyFiles(const Operations: TFileCopyOperations; out ErrorMessages: string): boolean;
function CopyDirectory(const SourceDir, DestDir: string; Overwrite: boolean = True; const FileMask: string = '*.*'): boolean;
function CopyProjectFiles(const TemplateDir, WorkingDir: string; const FileList: array of string): boolean;
function CreateProjectStructure(const BasePath: string; const Dirs: array of string): boolean;

// Utilidades de paths
function EnsurePathDelimiter(const Path: string): string;
function GetRelativeProjectPath(const BasePath, FullPath: string): string;
function IsPathInDirectory(const Path, Directory: string): boolean;

// Verificación de archivos
function VerifyFileIntegrity(const FilePath: string; out FileSize: int64; out Checksum: string): boolean;

// File hashing functions
function GetFileHashMD5(const FilePath: string): string;
function GetFileHashSHA1(const FilePath: string): string;
function GetFileHashSHA256(const FilePath: string): string;
function GetFileHashSimple(const FilePath: string): string;

// Content hashing functions (for strings in memory)
function GetContentHashMD5(const Content: string): string;
function GetContentHashSHA1(const Content: string): string;
function GetContentHashSHA256(const Content: string): string;
function GetContentHashSimple(const Content: string): string;

function ExtractResourceToFile(const ResFileName, ResourceName, ResTypeName: string; const DestPath: string; const DestFileName: string = ''): boolean;

function EnsureDocsStructure(const BasePath: string): boolean;
function SaveDocumentationFile(const BasePath, FileName, Content: string; UseChangeTracking: boolean = True): string;

implementation

// ============ Archive types ============
const
  FileTypesInfo: array[TWebFileType] of TFileTypeInfo = (

    // wftHTML
    (FileType: wftHTML;
    MimeType: 'text/html';
    Description: 'HTML Document';
    CommonExtensions: ('.html', '.htm', '.xhtml', '.shtml')),

    // wftCSS
    (FileType: wftCSS;
    MimeType: 'text/css';
    Description: 'CSS Stylesheet';
    CommonExtensions: ('.css', '.scss', '.less', '.sass')),

    // wftJavaScript
    (FileType: wftJavaScript;
    MimeType: 'application/javascript';
    Description: 'JavaScript File';
    CommonExtensions: ('.js', '.mjs', '.ts', '.tsx', '.jsx')),

    // wftJSON
    (FileType: wftJSON;
    MimeType: 'application/json';
    Description: 'JSON Data';
    CommonExtensions: ('.json', '.jsonld', '.geojson', '.topojson')),

    // wftSVG
    (FileType: wftSVG;
    MimeType: 'image/svg+xml';
    Description: 'SVG Vector Image';
    CommonExtensions: ('.svg', '.svgz')),

    // wftXML
    (FileType: wftXML;
    MimeType: 'application/xml';
    Description: 'XML Document';
    CommonExtensions: ('.xml', '.rss', '.atom', '.xsl', '.xslt')),

    // wftImage
    (FileType: wftImage;
    MimeType: 'image/*';
    Description: 'Image File';
    CommonExtensions: ('.png', '.jpg', '.jpeg', '.gif', '.webp', '.ico', '.bmp', '.tif', '.xcf')),

    // wftFont
    (FileType: wftFont;
    MimeType: 'font/*';
    Description: 'Web Font';
    CommonExtensions: ('.woff', '.woff2', '.ttf', '.otf', '.eot')),

    // wftVideo
    (FileType: wftVideo;
    MimeType: 'video/*';
    Description: 'Video file';
    CommonExtensions: ('.avi', '.mpg', '.mp4', '.mkv', '.webm', '.mpeg', '.ogv', '.mov')),

    // wftAudio
    (FileType: wftAudio;
    MimeType: 'audio/*';
    Description: 'Audio File';
    CommonExtensions: ('.mp3', '.ogg', '.wav', '.aac', '.flac')),

    // wftOther
    (FileType: wftOther;
    MimeType: 'application/octet-stream';
    Description: 'Other File';
    CommonExtensions: ()),



    // wftText
    (FileType: wftText;
    MimeType: 'text/*';
    Description: 'documents';
    CommonExtensions: ('.txt', '.doc', '.pdf', '.md', '.csv', '.log')),

    // wftProject
    (FileType: wftProject;
    MimeType: 'text/prj';
    Description: 'Project File';
    CommonExtensions: ('.etproj'))

    );

function DetectWebFileType(const FileName: string): TWebFileType;
var
  Ext: string;
  I: TWebFileType;
  J: integer;
begin
  Ext := LowerCase(ExtractFileExt(FileName));

  for I := Low(TWebFileType) to High(TWebFileType) do
  begin
    for J := 0 to High(FileTypesInfo[I].CommonExtensions) do
    begin
      if Ext = FileTypesInfo[I].CommonExtensions[J] then
      begin
        Result := I;
        Exit;
      end;
    end;
  end;

  Result := wftOther;
end;

function GetFileTypeInfo(FileType: TWebFileType): TFileTypeInfo;
begin
  Result := FileTypesInfo[FileType];
end;

function IsWebFile(const FileName: string): boolean;
begin
  Result := DetectWebFileType(FileName) <> wftOther;
end;

function GetFileIconIndex(const FileName: string; IsDirectory: boolean = False; IsExpanded: boolean = False): integer;
const
  ICON_PROJECT = 0;
  ICON_FOLDER_CLOSED = 1;
  ICON_FOLDER_OPEN = 2;
  ICON_HTML = 3;
  ICON_CSS = 4;
  ICON_JS = 5;
  ICON_JSON = 6;
  ICON_SVG = 7;
  ICON_IMAGE = 8;
  ICON_XML = 9;
  ICON_FONT = 10;
  ICON_VIDEO = 11;
  ICON_AUDIO = 12;
  ICON_OTHER = 13;
  ICON_TEXT = 14;
  ICON_PROJECT_FILE = 15;
begin
  if IsDirectory then
  begin
    if IsExpanded then
      Result := ICON_FOLDER_OPEN
    else
      Result := ICON_FOLDER_CLOSED;
  end
  else
  begin
    case DetectWebFileType(FileName) of
      wftHTML: Result := ICON_HTML;
      wftCSS: Result := ICON_CSS;
      wftJavaScript: Result := ICON_JS;
      wftJSON: Result := ICON_JSON;
      wftSVG: Result := ICON_SVG;
      wftXML: Result := ICON_XML;
      wftImage: Result := ICON_IMAGE;
      wftFont: Result := ICON_FONT;
      wftVideo: Result := ICON_VIDEO;
      wftAudio: Result := ICON_AUDIO;
      wftText: Result := ICON_TEXT;
      wftOther: Result := ICON_OTHER;
      wftProject: Result := ICON_PROJECT_FILE;
      else
        Result := ICON_OTHER;
    end;
  end;
end;

// ============ OPERACIONES CON ARCHIVOS ============

function CopyFileWithProgress(const Source, Destination: string; Overwrite: boolean = True): boolean;
var
  SourceStream, DestStream: TFileStream;
  Buffer: array[0..8191] of byte;
  BytesRead: integer;
begin
  Result := False;

  if not FileExists(Source) then
    Exit;

  if FileExists(Destination) and not Overwrite then
    Exit;

  try
    SourceStream := TFileStream.Create(Source, fmOpenRead or fmShareDenyWrite);
    try
      // Crear directorio destino si no existe
      ForceDirectories(ExtractFilePath(Destination));

      DestStream := TFileStream.Create(Destination, fmCreate);
      try
        repeat
          BytesRead := SourceStream.Read(Buffer, SizeOf(Buffer));
          if BytesRead > 0 then
            DestStream.Write(Buffer, BytesRead);
        until BytesRead = 0;

        Result := True;
      finally
        DestStream.Free;
      end;
    finally
      SourceStream.Free;
    end;
  except
    on E: Exception do
    begin
      // Log del error
      TDebugLogger.ErrorFmt('CopyFileWithProgress error: %s', [E.Message], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      Result := False;
    end;
  end;
end;

function CopyFiles(const Operations: TFileCopyOperations; out ErrorMessages: string): boolean;
var
  I: integer;
  Success: boolean;
  CurrentError: string;
begin
  Result := True;
  ErrorMessages := '';

  for I := 0 to High(Operations) do
  begin
    if Operations[I].Recursive then
    begin
      // Es un directorio
      Success := CopyDirectory(Operations[I].Source, Operations[I].Destination, Operations[I].Overwrite);
    end
    else
    begin
      // Es un archivo
      Success := CopyFileWithProgress(Operations[I].Source, Operations[I].Destination, Operations[I].Overwrite);
    end;

    if not Success then
    begin
      Result := False;
      CurrentError := Format('Failed to copy: %s -> %s' + LineEnding, [Operations[I].Source, Operations[I].Destination]);
      ErrorMessages := ErrorMessages + CurrentError;
    end;
  end;
end;

function CopyDirectory(const SourceDir, DestDir: string; Overwrite: boolean = True; const FileMask: string = '*.*'): boolean;
var
  SearchRec: TSearchRec;
  SourcePath, DestPath: string;
  Operations: TFileCopyOperations;
  OperationCount: integer;
  ErrorMsg: string;
begin
  Result := False;

  if not DirectoryExists(SourceDir) then
    Exit;

  // Crear directorio destino
  ForceDirectories(DestDir);

  // Primero recolectar todas las operaciones
  OperationCount := 0;
  SetLength(Operations, 100); // Tamaño inicial

  if FindFirst(EnsurePathDelimiter(SourceDir) + FileMask, faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        if (SearchRec.Name = '.') or (SearchRec.Name = '..') then
          Continue;

        SourcePath := EnsurePathDelimiter(SourceDir) + SearchRec.Name;
        DestPath := EnsurePathDelimiter(DestDir) + SearchRec.Name;

        if OperationCount >= Length(Operations) then
          SetLength(Operations, Length(Operations) + 100);

        Operations[OperationCount].Source := SourcePath;
        Operations[OperationCount].Destination := DestPath;
        Operations[OperationCount].Overwrite := Overwrite;
        Operations[OperationCount].Recursive := (SearchRec.Attr and faDirectory) <> 0;

        Inc(OperationCount);
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;

  // Ajustar tamaño del array
  SetLength(Operations, OperationCount);

  // Ejecutar todas las copias
  Result := CopyFiles(Operations, ErrorMsg);

  if not Result and (ErrorMsg <> '') then
    TDebugLogger.ErrorFmt('CopyDirectory errors: %s', [ErrorMsg], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
end;

function CopyProjectFiles(const TemplateDir, WorkingDir: string; const FileList: array of string): boolean;
var
  Operations: TFileCopyOperations;
  I: integer;
  SourceFile, DestFile: string;
  ErrorMsg: string;
begin
  Result := False;

  if not DirectoryExists(TemplateDir) then
    Exit;

  // Crear directorio working si no existe
  ForceDirectories(WorkingDir);

  // Preparar operaciones
  SetLength(Operations, Length(FileList));

  for I := 0 to High(FileList) do
  begin
    SourceFile := EnsurePathDelimiter(TemplateDir) + FileList[I];
    DestFile := EnsurePathDelimiter(WorkingDir) + FileList[I];

    Operations[I].Source := SourceFile;
    Operations[I].Destination := DestFile;
    Operations[I].Overwrite := True;
    Operations[I].Recursive := False;
  end;

  // Ejecutar copias
  Result := CopyFiles(Operations, ErrorMsg);

  if not Result then
    TDebugLogger.ErrorFmt('CopyProjectFiles errors: %s', [ErrorMsg], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
end;

function CreateProjectStructure(const BasePath: string; const Dirs: array of string): boolean;
var
  I: integer;
  FullPath: string;
begin
  Result := True;

  for I := 0 to High(Dirs) do
  begin
    FullPath := EnsurePathDelimiter(BasePath) + Dirs[I];
    try
      if not DirectoryExists(FullPath) then
      begin
        ForceDirectories(FullPath);
        TDebugLogger.InfoFmt('  Created directory: %s', [FullPath], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      end;
    except
      on E: Exception do
      begin
        TDebugLogger.ErrorFmt('Creating directory: %s %s', [FullPath, E.Message], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        Result := False;
      end;
    end;
  end;
end;

// ============ UTILIDADES DE PATHS ============

function EnsurePathDelimiter(const Path: string): string;
begin
  Result := Path;
  if (Result <> '') and (Result[Length(Result)] <> PathDelim) then
    Result := Result + PathDelim;
end;

function GetRelativeProjectPath(const BasePath, FullPath: string): string;
begin
  Result := ExtractRelativePath(EnsurePathDelimiter(BasePath), FullPath);
end;

function IsPathInDirectory(const Path, Directory: string): boolean;
var
  RelPath: string;
begin
  RelPath := ExtractRelativePath(EnsurePathDelimiter(Directory), Path);
  Result := (RelPath <> '') and (Pos('..', RelPath) = 0);
end;

// ============ VERIFICACIÓN DE ARCHIVOS ============

function VerifyFileIntegrity(const FilePath: string; out FileSize: int64; out Checksum: string): boolean;
var
  FS: TFileStream;
  Buffer: array[0..1023] of byte;
  BytesRead: integer;
  TotalBytes: int64;
  I: integer;
  TempChecksum: cardinal;
begin
  Result := False;
  FileSize := 0;
  Checksum := '';

  if not FileExists(FilePath) then
    Exit;

  try
    FS := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyWrite);
    try
      FileSize := FS.Size;
      TotalBytes := 0;
      TempChecksum := 0;

      repeat
        BytesRead := FS.Read(Buffer, SizeOf(Buffer));
        for I := 0 to BytesRead - 1 do
          TempChecksum := TempChecksum + Buffer[I];
        Inc(TotalBytes, BytesRead);
      until BytesRead = 0;

      // Checksum simple (para demostración, en producción usaría CRC32 o MD5)
      Checksum := IntToHex(TempChecksum, 8);
      Result := True;
    finally
      FS.Free;
    end;
  except
    on E: Exception do
    begin
      TDebugLogger.ErrorFmt('VerifyFileIntegrity error: %s', [E.Message], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      Result := False;
    end;
  end;
end;

// ============ HASHING AND DOCUMENTATION ============

// File hashing functions
function GetFileHashMD5(const FilePath: string): string;
var
  Hash: TDCP_md5;
  FS: TFileStream;
  Buffer: array[0..8191] of byte;
  BytesRead: integer;
  Digest: array[0..15] of byte;
  I: integer;
begin
  Result := '';
  if not FileExists(FilePath) then Exit;

  Hash := TDCP_md5.Create(nil);
  try
    FS := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyWrite);
    try
      Hash.Init;

      repeat
        BytesRead := FS.Read(Buffer, SizeOf(Buffer));
        if BytesRead > 0 then
          Hash.Update(Buffer[0], BytesRead);
      until BytesRead = 0;

      Hash.Final(Digest);

      // Convert to hex string
      for I := 0 to 15 do
        Result := Result + IntToHex(Digest[I], 2);

      Result := LowerCase(Result);
    finally
      FS.Free;
    end;
  finally
    Hash.Free;
  end;
end;

function GetFileHashSHA1(const FilePath: string): string;
var
  Hash: TDCP_sha1;
  FS: TFileStream;
  Buffer: array[0..8191] of byte;
  BytesRead: integer;
  Digest: array[0..19] of byte;
  I: integer;
begin
  Result := '';
  if not FileExists(FilePath) then Exit;

  Hash := TDCP_sha1.Create(nil);
  try
    FS := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyWrite);
    try
      Hash.Init;

      repeat
        BytesRead := FS.Read(Buffer, SizeOf(Buffer));
        if BytesRead > 0 then
          Hash.Update(Buffer[0], BytesRead);
      until BytesRead = 0;

      Hash.Final(Digest);

      // Convert to hex string
      for I := 0 to 19 do
        Result := Result + IntToHex(Digest[I], 2);

      Result := LowerCase(Result);
    finally
      FS.Free;
    end;
  finally
    Hash.Free;
  end;
end;

function GetFileHashSHA256(const FilePath: string): string;
var
  Hash: TDCP_sha256;
  FS: TFileStream;
  Buffer: array[0..8191] of byte;
  BytesRead: integer;
  Digest: array[0..31] of byte;
  I: integer;
begin
  Result := '';
  if not FileExists(FilePath) then Exit;

  Hash := TDCP_sha256.Create(nil);
  try
    FS := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyWrite);
    try
      Hash.Init;

      repeat
        BytesRead := FS.Read(Buffer, SizeOf(Buffer));
        if BytesRead > 0 then
          Hash.Update(Buffer[0], BytesRead);
      until BytesRead = 0;

      Hash.Final(Digest);

      // Convert to hex string
      for I := 0 to 31 do
        Result := Result + IntToHex(Digest[I], 2);

      Result := LowerCase(Result);
    finally
      FS.Free;
    end;
  finally
    Hash.Free;
  end;
end;

function GetFileHashSimple(const FilePath: string): string;
var
  SR: TSearchRec;
  FileSize: int64;
  Hash: longword;
  I: integer;
begin
  Result := '';
  if not FileExists(FilePath) then Exit;

  if FindFirst(FilePath, faAnyFile, SR) = 0 then
  try
    FileSize := SR.Size;

    // Create a deterministic hash from file properties
    Hash := longword(FileSize) xor longword(SR.Time) xor longword(Length(ExtractFileName(FilePath)));

    // Add filename characters to hash for more uniqueness
    for I := 1 to Length(ExtractFileName(FilePath)) do
      Hash := (Hash shl 5) + Hash + longword(Ord(ExtractFileName(FilePath)[I]));

    Result := IntToHex(Hash, 8);
  finally
    FindClose(SR);
  end;
end;

function ExtractResourceToFile(const ResFileName, ResourceName, ResTypeName: string; const DestPath: string; const DestFileName: string = ''): boolean;
var
  OutFileName: string;
begin
  Result := False;

  if not ResOp_OpenFile(ResFileName) then
    Exit;

  try
    if DestFileName = '' then
      OutFileName := IncludeTrailingPathDelimiter(DestPath) + ResourceName
    else
      OutFileName := IncludeTrailingPathDelimiter(DestPath) + DestFileName;

    // Exportar directamente usando la API que ya maneja strings
    Result := ResOp_ExportResToFile(ResourceName, ResTypeName, OutFileName);
  finally
    ResOp_CloseFile;
  end;
end;

function EnsureDocsStructure(const BasePath: string): boolean;
var
  DocsPath, CSSPath, JSPath, HashesPath, ImgPath: string;
  ResFileName: string;
begin
  Result := False;

  DocsPath := IncludeTrailingPathDelimiter(BasePath) + 'docs';
  CSSPath := IncludeTrailingPathDelimiter(DocsPath) + 'css';
  JSPath := IncludeTrailingPathDelimiter(DocsPath) + 'js';
  HashesPath := IncludeTrailingPathDelimiter(DocsPath) + '.hashes';
  ImgPath := IncludeTrailingPathDelimiter(DocsPath) + 'images';

  try
    // Create directories
    ForceDirectories(DocsPath);
    ForceDirectories(CSSPath);
    ForceDirectories(JSPath);
    ForceDirectories(HashesPath);
    ForceDirectories(ImgPath);

  finally
  end;
  Result := False;
  ResFileName := ExtractFilePath(ParamStr(0)) + 'docs.res';

  // Crear directorios
  ForceDirectories(BasePath + 'docs\css');
  ForceDirectories(BasePath + 'docs\js');

  // Extraer archivos
  if not ExtractResourceToFile(ResFileName, 'DOCUMENTATION_CSS', 'CSS', BasePath + 'docs\css', 'documentation.css') then
    Exit;
  if not ExtractResourceToFile(ResFileName, 'DOCUMENTATION_JS', 'JS', BasePath + 'docs\js', 'documentation.js') then
    Exit;

  Result := True;
end;

function SaveDocumentationFile(const BasePath, FileName, Content: string; UseChangeTracking: boolean = True): string;
var
  DocsPath, FullPath, HashFile: string;
  ExistingHash, NewHash: string;
  SL: TStringList;
  FileSizeValue: int64;
  LastModifiedValue: TDateTime;
begin
  Result := '';

  TDebugLogger.Info('SaveFileDocumentation called', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TDebugLogger.InfoFmt('BasePath: %s', [BasePath], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TDebugLogger.InfoFmt('FileName: %s', [FileName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  // Ensure docs directory exists
  if not EnsureDocsStructure(BasePath) then
    Exit;

  DocsPath := IncludeTrailingPathDelimiter(BasePath) + 'docs';
  FullPath := DocsPath + PathDelim + FileName;
  HashFile := DocsPath + PathDelim + '.hashes' + PathDelim + FileName + '.hash';

  try
    if UseChangeTracking and FileExists(FullPath) then
    begin
      // Get existing hash and file info
      ExistingHash := '';
      FileSizeValue := 0;
      LastModifiedValue := 0;

      if FileExists(HashFile) then
      begin
        SL := TStringList.Create;
        try
          SL.LoadFromFile(HashFile);
          if SL.Count >= 3 then
          begin
            ExistingHash := Trim(SL[0]);
            try
              FileSizeValue := StrToInt64(SL[1]);
              LastModifiedValue := StrToFloat(SL[2]);
            except
              // If we can't parse, we'll regenerate
            end;
          end;
        finally
          SL.Free;
        end;
      end;

      // Generate new hash - USE GetContentHashMD5 instead of undefined function
      NewHash := GetContentHashMD5(Content);  // This should work now

      // Check if file has actually changed
      if (ExistingHash = NewHash) and FileExists(FullPath) then
      begin
        // Double-check file properties
        if (FileSize(FullPath) = FileSizeValue) and (Abs(FileDateToDateTime(FileAge(FullPath)) - LastModifiedValue) < 1 / 86400) then
        begin
          TDebugLogger.InfoFmt('  Documentation unchanged, skipping save: %s', [FileName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
          Result := FullPath;
          Exit;
        end;
      end;
    end;

    // Save the documentation file
    SL := TStringList.Create;
    try
      SL.Text := Content;
      SL.SaveToFile(FullPath);

      // Save hash and file info if tracking is enabled
      if UseChangeTracking then
      begin
        NewHash := GetContentHashMD5(Content);  // And here
        FileSizeValue := FileSize(FullPath);
        LastModifiedValue := FileDateToDateTime(FileAge(FullPath));

        SL.Clear;
        SL.Add(NewHash);
        SL.Add(IntToStr(FileSizeValue));
        SL.Add(FloatToStr(LastModifiedValue));
        SL.SaveToFile(HashFile);
        TDebugLogger.InfoFmt('  Documentation saved with hash: %s  size: %d', [FileName,FileSizeValue], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      end;

      Result := FullPath;
    finally
      SL.Free;
    end;

  except
    on E: Exception do
    begin
      TDebugLogger.ErrorFmt('  Saving documentation: %s', [E.Message], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      Result := '';
    end;
  end;
end;

// Content hashing functions (for strings in memory)

function GetContentHashMD5(const Content: string): string;
var
  Hash: TDCP_md5;
  Digest: array[0..15] of byte;
  I: integer;
begin
  Hash := TDCP_md5.Create(nil);
  try
    Hash.Init;
    Hash.UpdateStr(Content);
    Hash.Final(Digest);

    Result := '';
    for I := 0 to 15 do
      Result := Result + IntToHex(Digest[I], 2);

    Result := LowerCase(Result);
  finally
    Hash.Free;
  end;
end;

function GetContentHashSHA256(const Content: string): string;
var
  Hash: TDCP_sha256;
  Digest: array[0..31] of byte;
  I: integer;
begin
  Hash := TDCP_sha256.Create(nil);
  try
    Hash.Init;
    Hash.UpdateStr(Content);
    Hash.Final(Digest);

    Result := '';
    for I := 0 to 31 do
      Result := Result + IntToHex(Digest[I], 2);

    Result := LowerCase(Result);
  finally
    Hash.Free;
  end;
end;

function GetContentHashSHA1(const Content: string): string;
var
  Hash: TDCP_sha1;
  Digest: array[0..19] of byte;
  I: integer;
begin
  Hash := TDCP_sha1.Create(nil);
  try
    Hash.Init;
    Hash.UpdateStr(Content);
    Hash.Final(Digest);

    Result := '';
    for I := 0 to 19 do
      Result := Result + IntToHex(Digest[I], 2);

    Result := LowerCase(Result);
  finally
    Hash.Free;
  end;
end;

function GetContentHashSimple(const Content: string): string;
var
  I: integer;
  Hash: longword;
begin
  Hash := $89ABCDEF; // Seed value

  for I := 1 to Length(Content) do
  begin
    // Simple but effective hash
    Hash := (Hash shl 7) xor (Hash shr 25) + longword(Ord(Content[I]));
  end;

  Result := IntToHex(Hash, 8);
end;

{ TFileChangeTracker }

constructor TFileChangeTracker.Create(const HashFileDir: string);
begin
  FHashFileDir := HashFileDir;
  ForceDirectories(FHashFileDir);
  LoadHashes;
end;

function TFileChangeTracker.GenerateFileHash(const FilePath: string): string;
begin
  // Use MD5 for reliable change detection
  Result := GetFileHashMD5(FilePath);
end;

function TFileChangeTracker.GetHashFilePath(const FilePath: string): string;
var
  SafeFileName: string;
begin
  // Create a safe filename for the hash file
  SafeFileName := StringReplace(ExtractFileName(FilePath), '.', '_', [rfReplaceAll]);
  SafeFileName := StringReplace(SafeFileName, PathDelim, '_', [rfReplaceAll]);

  Result := IncludeTrailingPathDelimiter(FHashFileDir) + SafeFileName + '.hash';
end;

function TFileChangeTracker.HasFileChanged(const FilePath: string): boolean;
var
  I: integer;
  CurrentHash, StoredHash: string;
  HashFilePath: string;
  SL: TStringList;
begin
  Result := True; // Assume changed by default

  if not FileExists(FilePath) then
    Exit;

  // Check in memory first
  for I := 0 to High(FTrackedFiles) do
  begin
    if SameText(FTrackedFiles[I].FilePath, FilePath) then
    begin
      CurrentHash := GenerateFileHash(FilePath);
      Result := (CurrentHash <> FTrackedFiles[I].Hash);

      if not Result then
      begin
        // Also check file size and modification time
        if (FileSize(FilePath) <> FTrackedFiles[I].FileSize) or (FileDateToDateTime(FileAge(FilePath)) <> FTrackedFiles[I].LastModified) then
        begin
          Result := True;
        end;
      end;

      Exit;
    end;
  end;

  // Check hash file on disk
  HashFilePath := GetHashFilePath(FilePath);
  if FileExists(HashFilePath) then
  begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile(HashFilePath);
      StoredHash := Trim(SL.Text);
      CurrentHash := GenerateFileHash(FilePath);
      Result := (CurrentHash <> StoredHash);

      // Double-check with file properties
      if not Result then
      begin
        // Read additional info from hash file (format: hash|size|timestamp)
        if SL.Count >= 3 then
        begin
          try
            if FileSize(FilePath) <> StrToInt64(SL[1]) then
              Result := True
            else if FileDateToDateTime(FileAge(FilePath)) <> StrToFloat(SL[2]) then
              Result := True;
          except
            // If we can't parse, assume changed
            Result := True;
          end;
        end;
      end;
    finally
      SL.Free;
    end;
  end;
end;

procedure TFileChangeTracker.UpdateFileHash(const FilePath: string);
var
  I: integer;
  Hash: string;
  Found: boolean;
  SL: TStringList;
  FileSizeValue: int64;
  LastModifiedValue: TDateTime;
begin
  if not FileExists(FilePath) then Exit;

  Hash := GenerateFileHash(FilePath);
  FileSizeValue := FileSize(FilePath);
  LastModifiedValue := FileDateToDateTime(FileAge(FilePath));

  Found := False;

  // Update in memory
  for I := 0 to High(FTrackedFiles) do
  begin
    if SameText(FTrackedFiles[I].FilePath, FilePath) then
    begin
      FTrackedFiles[I].Hash := Hash;
      FTrackedFiles[I].FileSize := FileSizeValue;
      FTrackedFiles[I].LastModified := LastModifiedValue;
      Found := True;
      Break;
    end;
  end;

  if not Found then
  begin
    SetLength(FTrackedFiles, Length(FTrackedFiles) + 1);
    FTrackedFiles[High(FTrackedFiles)].FilePath := FilePath;
    FTrackedFiles[High(FTrackedFiles)].Hash := Hash;
    FTrackedFiles[High(FTrackedFiles)].FileSize := FileSizeValue;
    FTrackedFiles[High(FTrackedFiles)].LastModified := LastModifiedValue;
  end;

  // Save to hash file with additional info
  SL := TStringList.Create;
  try
    SL.Add(Hash);
    SL.Add(IntToStr(FileSizeValue));
    SL.Add(FloatToStr(LastModifiedValue));
    SL.SaveToFile(GetHashFilePath(FilePath));
  finally
    SL.Free;
  end;
end;

function TFileChangeTracker.GetFileHash(const FilePath: string): string;
var
  I: integer;
begin
  Result := '';

  for I := 0 to High(FTrackedFiles) do
  begin
    if FTrackedFiles[I].FilePath = FilePath then
    begin
      Result := FTrackedFiles[I].Hash;
      Exit;
    end;
  end;

  // Load from disk if not in memory
  if FileExists(GetHashFilePath(FilePath)) then
  begin
    with TStringList.Create do
    try
      LoadFromFile(GetHashFilePath(FilePath));
      Result := Text;
    finally
      Free;
    end;
  end;
end;

procedure TFileChangeTracker.RemoveFile(const FilePath: string);
var
  I, J: integer;
  HashFilePath: string;
begin
  // Remove from memory
  for I := High(FTrackedFiles) downto 0 do
  begin
    if FTrackedFiles[I].FilePath = FilePath then
    begin
      for J := I to High(FTrackedFiles) - 1 do
        FTrackedFiles[J] := FTrackedFiles[J + 1];
      SetLength(FTrackedFiles, Length(FTrackedFiles) - 1);
      Break;
    end;
  end;

  // Remove hash file
  HashFilePath := GetHashFilePath(FilePath);
  if FileExists(HashFilePath) then
    DeleteFile(HashFilePath);
end;

procedure TFileChangeTracker.LoadHashes;
var
  SearchRec: TSearchRec;
  HashFilePath, OriginalFile: string;
  SL: TStringList;
begin
  SetLength(FTrackedFiles, 0);

  if FindFirst(IncludeTrailingPathDelimiter(FHashFileDir) + '*.hash', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        if (SearchRec.Attr and faDirectory) = 0 then
        begin
          HashFilePath := IncludeTrailingPathDelimiter(FHashFileDir) + SearchRec.Name;
          OriginalFile := Copy(SearchRec.Name, 1, Length(SearchRec.Name) - 5); // Remove .hash

          SL := TStringList.Create;
          try
            SL.LoadFromFile(HashFilePath);

            SetLength(FTrackedFiles, Length(FTrackedFiles) + 1);
            FTrackedFiles[High(FTrackedFiles)].FilePath := OriginalFile;
            FTrackedFiles[High(FTrackedFiles)].Hash := SL.Text;

            // Try to get file info if file exists
            if FileExists(OriginalFile) then
            begin
              FTrackedFiles[High(FTrackedFiles)].FileSize := FileSize(OriginalFile);
              FTrackedFiles[High(FTrackedFiles)].LastModified := FileDateToDateTime(FileAge(OriginalFile));
            end;

          finally
            SL.Free;
          end;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;
end;

procedure TFileChangeTracker.SaveHashes;
var
  I: integer;
  SL: TStringList;
begin
  for I := 0 to High(FTrackedFiles) do
  begin
    SL := TStringList.Create;
    try
      SL.Text := FTrackedFiles[I].Hash;
      SL.SaveToFile(GetHashFilePath(FTrackedFiles[I].FilePath));
    finally
      SL.Free;
    end;
  end;
end;

end.
