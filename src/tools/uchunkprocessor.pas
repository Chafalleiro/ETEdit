unit uChunkProcessor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TChunkProcessor = class
  private
    FChunksPath: String;
    FVariables: TStringList;

    function LoadChunk(const ChunkName: String): String;
    function ReplaceVariables(const Content: String): String;
  public
    constructor Create(const ChunksPath: String);
    destructor Destroy; override;

    procedure AddVariable(const Name, Value: String);
    function ProcessContent(const Content: String): String;
    function ProcessFile(const FilePath: String): Boolean;
  end;

implementation

constructor TChunkProcessor.Create(const ChunksPath: String);
begin
  FChunksPath := IncludeTrailingPathDelimiter(ChunksPath);
  FVariables := TStringList.Create;

  // Variables por defecto
  AddVariable('YEAR', FormatDateTime('yyyy', Now));
  AddVariable('DATE', FormatDateTime('yyyy-mm-dd', Now));
end;

destructor TChunkProcessor.Destroy;
begin
  FVariables.Free;
  inherited Destroy;
end;

procedure TChunkProcessor.AddVariable(const Name, Value: String);
begin
  FVariables.Values[Name] := Value;
end;

function TChunkProcessor.LoadChunk(const ChunkName: String): String;
var
  FullPath: String;
  SL: TStringList;
begin
  Result := '';
  FullPath := FChunksPath + ChunkName;

  if ExtractFileExt(ChunkName) = '' then
    FullPath := FullPath + '.tpl';

  if FileExists(FullPath) then
  begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile(FullPath);
      Result := ProcessContent(SL.Text);
    finally
      SL.Free;
    end;
  end;
end;

function TChunkProcessor.ReplaceVariables(const Content: String): String;
var
  I: Integer;
  Processed: String;
begin
  Processed := Content;

  for I := 0 to FVariables.Count - 1 do
  begin
    Processed := StringReplace(Processed,
      '{{' + FVariables.Names[I] + '}}',
      FVariables.ValueFromIndex[I],
      [rfReplaceAll]);
  end;

  Result := Processed;
end;

function TChunkProcessor.ProcessContent(const Content: String): String;
var
  Lines: TStringList;
  I: Integer;
  Line, ChunkName, ChunkContent: String;
  PosStart, PosEnd: Integer;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := Content;

    for I := 0 to Lines.Count - 1 do
    begin
      Line := Lines[I];
      PosStart := Pos('<!-- @chunk:', Line);

      if PosStart > 0 then
      begin
        PosEnd := Pos('-->', Line);
        if PosEnd > PosStart then
        begin
          // Extraer nombre del chunk
          ChunkName := Copy(Line, PosStart + 12, PosEnd - PosStart - 12);
          ChunkName := Trim(ChunkName);

          // Cargar y procesar chunk (puede tener chunks anidados)
          ChunkContent := LoadChunk(ChunkName);
          if ChunkContent <> '' then
          begin
            Lines[I] := ChunkContent;
          end;
        end;
      end;
    end;

    Result := ReplaceVariables(Lines.Text);
  finally
    Lines.Free;
  end;
end;

function TChunkProcessor.ProcessFile(const FilePath: String): Boolean;
var
  SL: TStringList;
  ProcessedContent: String;
begin
  Result := False;

  if FileExists(FilePath) then
  begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile(FilePath);
      ProcessedContent := ProcessContent(SL.Text);

      if ProcessedContent <> SL.Text then
      begin
        SL.Text := ProcessedContent;
        SL.SaveToFile(FilePath);
        Result := True;
      end;
    finally
      SL.Free;
    end;
  end;
end;

end.
