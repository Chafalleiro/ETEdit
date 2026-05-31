// File: uJSParser.pas
unit uJSParser;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Types, uDebugLog;

type
  // ============ GLOBAL VARIABLE TYPE ============
  TJSGlobalVar = record
    Name: String;
    VarType: String;
    Value: String;
    Line: Integer;
    Description: String;
  end;
  PJSGlobalVar = ^TJSGlobalVar;

  // ============ PARAMETER DATA TYPE ============
  TParamDataRecord = record
    pName: String;
    pType: String;
    pValue: String;
    pDesc: String;
  end;

  // ============ VARIABLE DATA TYPE ============
  TVarDataRecord = record
    vName: String;
    vType: String;
    vValue: String;
    vDesc: String;
  end;

  // ============ FUNCTION INFO TYPE ============
  TJSFunctionInfo = record
    Name: String;
    Code: TStringList;
    StartLine: Integer;
    EndLine: Integer;
    Parameters: TStringList;
    ReturnType: String;
    ReturnDesc: String;
    Description: String;
    Summary: String;           // Added for @summary
    ReturnExample: String;     // Added for @example return
    ExampleCode: String;       // Added for @example code
    IsAsync: Boolean;
    IsArrow: Boolean;
    IsMethod: Boolean;
    ParentClass: String;
    Calls: TStringList;
    CalledBy: TStringList;
    FileName: String;
    ParamData: array of TParamDataRecord;
    VarData: array of TVarDataRecord;
  end;
  PJSFunctionInfo = ^TJSFunctionInfo;

  // ============ SEE TAGS ============
  SeeTags = record
   sTagText : String;
   sTagLink : String;
   sTagLinkText : String;
  end;
  // ============ FILE INFO TYPE ============
  TJSFileInfo = record
   FileName: String;
   Author: String;
   Summary: String;
   See: array of SeeTags;
   FilePath: String;
   Functions: array of TJSFunctionInfo;
   GlobalVars: array of TJSGlobalVar;
   Classes: TStringList;
   Imports: TStringList;
   ExportedItems: TStringList;
   FileDescription: String;
  end;
  PJSFileInfo = ^TJSFileInfo;

  { TJSParser }
  TJSParser = class
  private
    class function IsFunctionDeclarationInternal(const Line: String): Boolean;
    class function ExtractMultiLineCommentInternal(const Lines: TStringList; var LineIndex: Integer): String;
    class function CountBracesInternal(const Line: String; CurrentCount: Integer): Integer;
    class function ParseGlobalVariableSimpleInternal(const Lines: TStringList; LineIndex: Integer;
      const PrecedingComment: String): TJSGlobalVar;
    class function ExtractDescriptionFromCommentInternal(const Comment: String): String;
    class function ExtractParamNameInternal(const ParamStr: String): String;
    class function ExtractParamTypeInternal(const Param: String): String;
    class function ExtractParamDescInternal(const Param: String): String;
    class function ParseDoxygenCommentInternal(const Lines: TStringList; LineBeforeFunction: Integer): String;
    class function ExtractReturnTypeFromCommentInternal(const Comment: String): String;
    class function ExtractParamDescriptionFromCommentInternal(const Comment: String;
      const ParamName: String): String;
    class function ExtractReturnDescriptionFromCommentInternal(const Comment: String): String;
    class function InferReturnTypeFromBodyInternal(const Lines: TStringList;
      StartLine, EndLine: Integer): String;
    class function ExtractFileLevelDocumentationInternal(const Lines: TStringList): String;
    class function ExtractFileLevelCommentInternal(const Lines: TStringList): String;
    class procedure ParseParameterStringInternal(const ParamStr: String;
      out ParamName, ParamType, ParamDesc: String);
    class function ExtractParamTypeFromJSDoc(const Comment: String; const ParamName: String): String;
    class function IsColonInGeneric(const Str: String; ColonPos: Integer): Boolean;
    class function ParseParameterDetails(const ParamStr: String; const Comment: String; ParamIndex: Integer): TParamDataRecord;
    class procedure ParseJSDocComment(const Comment: String; var FuncInfo: TJSFunctionInfo);
    class procedure ParseExampleLines(ExampleLines: TStringList; out ReturnExample, ExampleCode: String);
    class procedure LogFunctionInfo(const FuncInfo: TJSFunctionInfo);

  public
    // File analysis
    class procedure AnalyzeJavaScriptFile(const FilePath: String; IsTemplate: Boolean;
      var FilesInfo: array of TJSFileInfo; var FileCount: Integer);

    // Function parsing
    class function ParseFunction(const Lines: TStringList; StartLine: Integer): TJSFunctionInfo;
    class function ExtractParameters(const FunctionDef: String): TStringList;
    class procedure ExtractFunctionCalls(const Lines: TStringList; StartLine, EndLine: Integer; Calls: TStringList);

    // Comment parsing
    class function ParseDoxygenComment(const Lines: TStringList; LineBeforeFunction: Integer): String;
    class function ExtractReturnTypeFromComment(const Comment: String): String;

    // File-level parsing
    class procedure ParseImportExport(const Lines: TStringList; LineIndex: Integer;
      Imports: TStringList; ExportedItems: TStringList);
    class procedure ParseClassDeclaration(const Lines: TStringList; LineIndex: Integer;
      const PrecedingComment: String; Classes: TStringList);

    // Helper functions
    class function IsFunctionDeclaration(const Line: String): Boolean;
    class function ExtractMultiLineComment(const Lines: TStringList; var LineIndex: Integer): String;
    class function CountBraces(const Line: String; CurrentCount: Integer): Integer;
    class function ParseGlobalVariableSimple(const Lines: TStringList; LineIndex: Integer; const PrecedingComment: String): TJSGlobalVar;
    class function ExtractDescriptionFromComment(const Comment: String): String;
    class function ExtractParamName(const ParamStr: String): String;
    class function ExtractParamType(const Param: String): String;
    class function ExtractParamDesc(const Param: String): String;
    class function ExtractParamDescriptionFromComment(const Comment: String; const ParamName: String): String;

    class function ExtractReturnDescriptionFromComment(const Comment: String): String;
    class function InferReturnTypeFromBody(const Lines: TStringList; StartLine, EndLine: Integer): String;
    class procedure ParseParameterString(const ParamStr: String; out ParamName, ParamType, ParamDesc: String);

    class function ExtractFileLevelDocumentation(const Lines: TStringList): String;
    class function ExtractFileLevelComment(const Lines: TStringList): String;
    class procedure ParseFileLevelJSDoc(const Comment: String; var FileInfo: TJSFileInfo);

    class procedure ParseSeeTag(const TagContent: String; var FileInfo: TJSFileInfo; SeeIndex: Integer);

    // JSDoc generation
    class procedure GenerateJSDocComment(const FuncInfo: TJSFunctionInfo; CommentLines: TStringList);
    class function FormatParameterString(const ParamName, ParamType, ParamDesc: String): String;

    // Cleanup
    class procedure CleanupFunctionInfo(var FuncInfo: TJSFunctionInfo);
    class procedure CleanupFileInfo(var FileInfo: TJSFileInfo);

  end;

implementation

{ TJSParser }
// Add this at the top of uJSParser.pas implementation section
function BoolToYesNo(Value: Boolean): String;
begin
  if Value then Result := 'Yes' else Result := 'No';
end;

class function TJSParser.CountBracesInternal(const Line: String; CurrentCount: Integer): Integer;
var
  I: Integer;
begin
  Result := CurrentCount;
  for I := 1 to Length(Line) do
  begin
    if Line[I] = '{' then Inc(Result);
    if Line[I] = '}' then Dec(Result);
  end;
end;

class procedure TJSParser.AnalyzeJavaScriptFile(const FilePath: String; IsTemplate: Boolean;
  var FilesInfo: array of TJSFileInfo; var FileCount: Integer);
var
  Lines: TStringList;
  FileInfo: TJSFileInfo;
  I: Integer;
  Line, TrimLine: String;
  InMultiLineComment: Boolean;
  FuncInfo: TJSFunctionInfo;
  GlobalVar: TJSGlobalVar;
  CurrentComment: String;
  AlreadyProcessed: Boolean;
  LineCount: Integer;
  FileLevelDoc: String;
  LastCommentEndLine: Integer;  // Track where the last comment ended
  InFunctionComment: Boolean;   // Track if we're in a function's comment block
begin
  TDebugLogger.InfoFmt('=== START AnalyzeJavaScriptFile: %s ===', [ExtractFileName(FilePath)], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TDebugLogger.InfoFmt('  FilePath: %s', [FilePath], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  TDebugLogger.InfoFmt('  IsTemplate: %s', [BoolToYesNo(IsTemplate)], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  if not FileExists(FilePath) then
  begin
    TDebugLogger.Error('  File does not exist', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    Exit;
  end;

  // Check if file already processed
  AlreadyProcessed := False;
  for I := 0 to FileCount - 1 do
  begin
    if FilesInfo[I].FilePath = FilePath then
    begin
      AlreadyProcessed := True;
      Break;
    end;
  end;

  if AlreadyProcessed then
  begin
    TDebugLogger.Info('  File already processed, skipping', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    Exit;
  end;

  Lines := TStringList.Create;
  try
    TDebugLogger.InfoFmt('Loading file: %s', [FilePath], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    Lines.LoadFromFile(FilePath);
    LineCount := Lines.Count;
    TDebugLogger.InfoFmt('Lines in file:: %d', [LineCount], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

    // Initialize file info with default values
    FileInfo.FileName := ExtractFileName(FilePath);
    FileInfo.FilePath := FilePath;
    FileInfo.Author := '';
    FileInfo.Summary := '';
    SetLength(FileInfo.See, 0);
    FileInfo.Classes := TStringList.Create;
    FileInfo.Imports := TStringList.Create;
    FileInfo.ExportedItems := TStringList.Create;
    FileInfo.FileDescription := '';
    SetLength(FileInfo.Functions, 0);
    SetLength(FileInfo.GlobalVars, 0);

    if IsTemplate then
      FileInfo.FileName := '[Templates] ' + FileInfo.FileName
    else
      FileInfo.FileName := '[Project] ' + FileInfo.FileName;

    TDebugLogger.InfoFmt('Processing file: %s', [FileInfo.FileName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

    // Extract and parse file-level documentation
    FileLevelDoc := ExtractFileLevelDocumentationInternal(Lines);
    if FileLevelDoc <> '' then
    begin
      TDebugLogger.InfoFmt('Parsing file-level JSDoc: %s %s', [FileLevelDoc, FileInfo.FileName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      ParseFileLevelJSDoc(FileLevelDoc, FileInfo);
    end
    else
    begin
      TDebugLogger.Info('No file-level JSDoc found', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    end;

    InMultiLineComment := False;
    CurrentComment := '';
    LastCommentEndLine := -1;
    InFunctionComment := False;

    // Get file-level comment
    FileInfo.FileDescription := ExtractFileLevelCommentInternal(Lines);
    TDebugLogger.InfoFmt('File description extracted: %s', [FileInfo.FileDescription], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

    I := 0;
    while I < Lines.Count do
    begin
      TrimLine := Trim(Lines[I]);

      // Skip empty lines but track them for comment distance
      if TrimLine = '' then
      begin
        Inc(I);
        Continue;
      end;

      // ========== COMMENT HANDLING ==========

      // Handle single-line comments
      if Pos('//', TrimLine) = 1 then
      begin
        // Check if this comment is close to the last comment (within 1 line)
        if (LastCommentEndLine <> -1) and (I - LastCommentEndLine <= 1) then
        begin
          // Continuation of previous comment
          CurrentComment := CurrentComment + Copy(TrimLine, 3, MaxInt) + LineEnding;
        end
        else
        begin
          // New comment block
          CurrentComment := Copy(TrimLine, 3, MaxInt) + LineEnding;
          InFunctionComment := False; // Not a function comment until we see a function
        end;
        LastCommentEndLine := I;
        Inc(I);
        Continue;
      end;

      // Handle multi-line comment start
      if not InMultiLineComment and (Pos('/*', TrimLine) > 0) then
      begin
        InMultiLineComment := True;
        // Extract the comment and update I to the line where comment ends
        CurrentComment := CurrentComment + ExtractMultiLineCommentInternal(Lines, I);
        LastCommentEndLine := I;  // Update to the line where comment ended
        InFunctionComment := False;
        Continue;  // I is already updated by ExtractMultiLineCommentInternal
      end;

      // Handle being inside a multi-line comment
      if InMultiLineComment then
      begin
        if Pos('*/', TrimLine) > 0 then
        begin
          InMultiLineComment := False;
          LastCommentEndLine := I;
        end;
        Inc(I);
        Continue;
      end;

      // ========== FUNCTION DETECTION ==========

      // Check for function declarations (only if not in comment)
      if IsFunctionDeclarationInternal(TrimLine) then
      begin
        TDebugLogger.InfoFmt('Function declarations: %s', [Format('  [Line %d] Function found: %s', [I+1, Copy(TrimLine, 1, 60)])], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

        // Check if there's a comment immediately before this function
        // A comment is "immediately before" if:
        // 1. It ended on the previous line, OR
        // 2. It ended 2 lines ago with an empty line in between
        if (LastCommentEndLine <> -1) then
        begin
          if (I - LastCommentEndLine <= 1) then
          begin
            // Comment is directly before function
            TDebugLogger.InfoFmt('  Comment found %d lines before function', [I - LastCommentEndLine], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
            InFunctionComment := True;
          end
          else if (I - LastCommentEndLine = 2) and (Trim(Lines[I-1]) = '') then
          begin
            // Comment ended 2 lines ago with an empty line in between
            TDebugLogger.Info('  Comment found with empty line before function', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
            InFunctionComment := True;
          end
          else
          begin
            // Comment is too far away, don't associate it with this function
            TDebugLogger.InfoFmt('  Comment too far (%d lines), resetting', [I - LastCommentEndLine], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
            CurrentComment := '';
            InFunctionComment := False;
          end;
        end;

        try
          FuncInfo := ParseFunction(Lines, I);
          if FuncInfo.Name <> '' then
          begin
            // Only use the comment if it's a function comment
            if InFunctionComment and (CurrentComment <> '') then
            begin
              // The comment will be processed inside ParseFunction via ParseDoxygenCommentInternal
              TDebugLogger.Info('  Using preceding comment for function documentation', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
            end
            else
            begin
              TDebugLogger.Info('  No valid comment for this function', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
            end;

            FuncInfo.FileName := FileInfo.FileName;

            SetLength(FileInfo.Functions, Length(FileInfo.Functions) + 1);
            FileInfo.Functions[High(FileInfo.Functions)] := FuncInfo;
            TDebugLogger.InfoFmt('FileInfo.Functions: %s', [Format('    -> Added: %s (lines %d-%d)', [FuncInfo.Name, FuncInfo.StartLine+1, FuncInfo.EndLine+1])], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});


            // Log detailed function info for debugging
            LogFunctionInfo(FuncInfo);

            I := FuncInfo.EndLine;
          end
          else
          begin
            TDebugLogger.Error('    -> Failed to parse function', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
          end;
        except
          on E: Exception do
          begin
            TDebugLogger.ErrorFmt('    -> ERROR parsing function at line %d: "%s"', [I + 1, E.Message], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
          end;
        end;

        // Reset comment tracking after processing a function
        CurrentComment := '';
        LastCommentEndLine := -1;
        InFunctionComment := False;
      end
      else
      begin
        // ========== NON-FUNCTION CODE ==========

        // Reset comment if we're processing non-function code and comment is old
        if (LastCommentEndLine <> -1) and (I - LastCommentEndLine > 2) then
        begin
          CurrentComment := '';
          LastCommentEndLine := -1;
          InFunctionComment := False;
        end;

        // Check for global variables (not arrow functions)
        if (Pos('const ', TrimLine) = 1) or (Pos('let ', TrimLine) = 1) or (Pos('var ', TrimLine) = 1) then
        begin
          if Pos('=>', TrimLine) = 0 then
          begin
            GlobalVar := ParseGlobalVariableSimpleInternal(Lines, I, CurrentComment);
            if GlobalVar.Name <> '' then
            begin
              SetLength(FileInfo.GlobalVars, Length(FileInfo.GlobalVars) + 1);
              FileInfo.GlobalVars[High(FileInfo.GlobalVars)] := GlobalVar;
              TDebugLogger.InfoFmt('    -> [Line %d] Global var: %s', [I + 1, GlobalVar.Name], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
            end;

            // Reset comment after using it for a variable
            if CurrentComment <> '' then
            begin
              CurrentComment := '';
              LastCommentEndLine := -1;
            end;
          end;
        end;

        ParseImportExport(Lines, I, FileInfo.Imports, FileInfo.ExportedItems);
        ParseClassDeclaration(Lines, I, CurrentComment, FileInfo.Classes);

        // Reset comment if it was used for class or other non-function
        if CurrentComment <> '' then
        begin
          CurrentComment := '';
          LastCommentEndLine := -1;
        end;
      end;

      Inc(I);

      // Progress indicator for large files
      if (I mod 100 = 0) then
      TDebugLogger.InfoFmt('    -> Processed %d OF %d lines', [I, LineCount], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    end;

    // Always add the file, even if no functions found
    FilesInfo[FileCount] := FileInfo;
    Inc(FileCount);

    // Log file info summary
    TDebugLogger.InfoFmt('File completed: %s', [FileInfo.FileName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    TDebugLogger.InfoFmt('  Author: %s', [FileInfo.Author], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    TDebugLogger.InfoFmt('  Summary: %s', [FileInfo.Summary], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    TDebugLogger.InfoFmt('  Description: %s', [Copy(FileInfo.FileDescription, 1, 50)], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    TDebugLogger.InfoFmt('  See tags: %d', [Length(FileInfo.See)], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    TDebugLogger.InfoFmt('  Functions: %d', [Length(FileInfo.Functions)], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    TDebugLogger.InfoFmt('  Globals: %d', [Length(FileInfo.GlobalVars)], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    TDebugLogger.InfoFmt('  Classes: %d', [FileInfo.Classes.Count], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  except
    on E: Exception do
    begin
      TDebugLogger.ErrorFmt('    -> in AnalyzeJavaScriptFile %s, Class %s', [E.Message, E.ClassName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      if Assigned(Lines) then Lines.Free;
      Exit;
    end;
  end;
  TDebugLogger.Info('=== END AnalyzeJavaScriptFile ===', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
end;

class procedure TJSParser.ParseImportExport(const Lines: TStringList; LineIndex: Integer;
  Imports: TStringList; ExportedItems: TStringList);
var
  Line: String;
  ImportName, ExportName: String;
begin
  Line := Trim(Lines[LineIndex]);

  if (Pos('import ', Line) = 1) then
  begin
    if Pos('from ', Line) > 0 then
    begin
      ImportName := Copy(Line, Pos('from ', Line) + 5, MaxInt);
      ImportName := StringReplace(ImportName, '''', '', [rfReplaceAll]);
      ImportName := StringReplace(ImportName, '"', '', [rfReplaceAll]);
      ImportName := StringReplace(ImportName, ';', '', [rfReplaceAll]);
      Imports.Add(Trim(ImportName));
    end;
  end
  else if (Pos('export ', Line) = 1) then
  begin
    if Pos('export default', Line) = 1 then
    begin
      ExportName := Copy(Line, 15, MaxInt);
      ExportName := StringReplace(ExportName, ';', '', [rfReplaceAll]);
      ExportedItems.Add('default: ' + Trim(ExportName));
    end
    else if Pos('export ', Line) = 1 then
    begin
      ExportName := Copy(Line, 8, MaxInt);
      ExportName := StringReplace(ExportName, ';', '', [rfReplaceAll]);
      ExportedItems.Add(Trim(ExportName));
    end;
  end;
end;

class procedure TJSParser.ParseClassDeclaration(const Lines: TStringList; LineIndex: Integer;
  const PrecedingComment: String; Classes: TStringList);
var
  Line: String;
  ClsName: String;
  I: Integer;
begin
  Line := Trim(Lines[LineIndex]);

  if Pos('class ', Line) = 1 then
  begin
    Line := Copy(Line, 7, MaxInt);
    Line := Trim(Line);

    ClsName := '';
    I := 1;
    while (I <= Length(Line)) and not (Line[I] in [' ', '{', #9, ':']) do
    begin
      ClsName := ClsName + Line[I];
      Inc(I);
    end;

    if ClsName <> '' then
    begin
      if PrecedingComment <> '' then
        Classes.Add(ClsName + ' - ' + ExtractDescriptionFromCommentInternal(PrecedingComment))
      else
        Classes.Add(ClsName);
    end;
  end;
end;

//=========== RETURNS ============

class function TJSParser.ExtractReturnTypeFromComment(const Comment: String): String;
var
  Lines: TStringList;
  I: Integer;
  Line, Temp: String;
  StartPos, EndPos: Integer;
begin
  Result := '';
  if Comment = '' then Exit;

  Lines := TStringList.Create;
  try
    Lines.Text := Comment;

    // First, check for explicit @returns tag
    for I := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[I]);

      // Check for @returns {type} description
      if (Pos('@returns', LowerCase(Line)) > 0) then
      begin
        // Extract type from @returns {type} description
        if Pos('{', Line) > 0 then
        begin
          StartPos := Pos('{', Line) + 1;
          EndPos := Pos('}', Line);
          if EndPos > StartPos then
            Result := Copy(Line, StartPos, EndPos - StartPos);
        end;
        Break;
      end
      // Also check for @return (singular)
      else if (Pos('@return', LowerCase(Line)) > 0) and
              (Pos('@returns', LowerCase(Line)) = 0) then
      begin
        if Pos('{', Line) > 0 then
        begin
          StartPos := Pos('{', Line) + 1;
          EndPos := Pos('}', Line);
          if EndPos > StartPos then
            Result := Copy(Line, StartPos, EndPos - StartPos);
        end;
        Break;
      end;
    end;

    // If no @returns tag found, try to extract from function body or name
    if Result = '' then
    begin
      // Look for type hints in function name
      if (Pos('get', LowerCase(Comment)) > 0) or
         (Pos('is', LowerCase(Comment)) > 0) or
         (Pos('has', LowerCase(Comment)) > 0) then
      begin
        Result := 'boolean';
      end
      else if (Pos('create', LowerCase(Comment)) > 0) or
              (Pos('make', LowerCase(Comment)) > 0) or
              (Pos('build', LowerCase(Comment)) > 0) then
      begin
        Result := 'Object';
      end
      else if (Pos('to', LowerCase(Comment)) > 0) then
      begin
        Result := 'string';
      end;
    end;

  finally
    Lines.Free;
  end;
end;

class function TJSParser.ExtractReturnDescriptionFromComment(const Comment: String): String;
var
  Lines: TStringList;
  I: Integer;
  Line, Temp: String;
  StartPos, EndPos: Integer;
begin
  Result := '';
  if Comment = '' then Exit;

  Lines := TStringList.Create;
  try
    Lines.Text := Comment;

    for I := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[I]);

      if (Pos('@returns', LowerCase(Line)) > 0) or
         (Pos('@return', LowerCase(Line)) > 0) then
      begin
        Temp := Line;

        // Remove the @returns/@return tag
        if Pos('@returns', LowerCase(Temp)) > 0 then
          Delete(Temp, 1, Pos('@returns', Temp) + 7)
        else if Pos('@return', LowerCase(Temp)) > 0 then
          Delete(Temp, 1, Pos('@return', Temp) + 6);

        Temp := Trim(Temp);

        // Remove type annotation if present
        if (Length(Temp) > 0) and (Temp[1] = '{') then
        begin
          EndPos := Pos('}', Temp);
          if EndPos > 0 then
            Delete(Temp, 1, EndPos);
        end;

        // Clean up the description
        Temp := Trim(Temp);
        if (Length(Temp) > 0) and (Temp[1] = '-') then
          Delete(Temp, 1, 1);

        Result := Trim(Temp);
        Break;
      end;
    end;
  finally
    Lines.Free;
  end;
end;

class function TJSParser.InferReturnTypeFromBody(const Lines: TStringList;
  StartLine, EndLine: Integer): String;
begin
  Result := InferReturnTypeFromBodyInternal(Lines, StartLine, EndLine);
end;

class function TJSParser.ExtractReturnTypeFromCommentInternal(const Comment: String): String;
begin
  Result := ExtractReturnTypeFromComment(Comment);
end;

class function TJSParser.InferReturnTypeFromBodyInternal(const Lines: TStringList;
  StartLine, EndLine: Integer): String;
var
  I: Integer;
  Line, LowerLine: String;
begin
  Result := '';

  for I := StartLine to Min(EndLine, Lines.Count - 1) do
  begin
    Line := Lines[I];
    LowerLine := LowerCase(Line);

    if (Trim(Line) = '') or (Pos('//', Trim(Line)) = 1) then
      Continue;

    if Pos('return', LowerLine) > 0 then
    begin
      Delete(Line, 1, Pos('return', LowerLine) + 5);
      Line := Trim(Line);

      if (Line <> '') and (Line[Length(Line)] = ';') then
        Delete(Line, Length(Line), 1);

      if Line = '' then
        Result := 'void'
      else if (Line = 'true') or (Line = 'false') then
        Result := 'boolean'
      else if (Pos('"', Line) = 1) or (Pos('''', Line) = 1) then
        Result := 'string'
      else if (Pos('parseint', LowerLine) > 0) or (Pos('parsefloat', LowerLine) > 0) or
              (Pos('number(', LowerLine) > 0) then
        Result := 'number'
      else if (Pos('[]', Line) > 0) or (Pos('new array', LowerLine) > 0) then
        Result := 'Array'
      else if (Pos('{}', Line) > 0) or (Pos('new object', LowerLine) > 0) then
        Result := 'Object'
      else if (Pos('=>', Line) > 0) then
        Result := 'Function'
      else if (Pos('promise', LowerLine) > 0) then
        Result := 'Promise'
      else
        Result := 'any';
      Break;
    end;
  end;

  if Result = '' then
    Result := 'void';
end;

//=========== DESCRIPTIONS ============

class function TJSParser.ExtractDescriptionFromComment(const Comment: String): String;
var
  Lines: TStringList;
  I: Integer;
  Line, Description, TempStr: String;
  InDescription: Boolean;
begin
  Result := '';
  if Comment = '' then Exit;

  Lines := TStringList.Create;
  try
    Lines.Text := Comment;
    Description := '';
    InDescription := True;
    TempStr := '';

    for I := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[I]);

      // Skip empty lines at the beginning
      if (I = 0) and (Line = '') then Continue;

      // Check for @summary tag
      if Pos('@summary', Line) > 0 then
      begin
        TempStr := Line;
        // Remove @summary tag and get the text
        System.Delete(TempStr, 1, Pos('@summary', TempStr) + 7);
        TempStr := Trim(TempStr);
        if TempStr <> '' then
          Result := TempStr;
        InDescription := False;
        Continue;
      end;

      // Stop at other JSDoc tags
      if (Pos('@param', Line) > 0) or
         (Pos('@returns', Line) > 0) or
         (Pos('@return', Line) > 0) or
         (Pos('@example', Line) > 0) then
      begin
        InDescription := False;
        Continue;
      end;

      if InDescription then
      begin
        // Clean up JSDoc markers
        if (Length(Line) >= 3) and (Copy(Line, 1, 3) = '/**') then
        begin
          Line := Copy(Line, 4, MaxInt);
        end
        else if (Length(Line) >= 2) and (Copy(Line, 1, 2) = ' *') then
        begin
          Line := Copy(Line, 3, MaxInt);
        end
        else if (Length(Line) >= 1) and (Line[1] = '*') then
        begin
          Line := Copy(Line, 2, MaxInt);
        end;

        Line := Trim(Line);
        if Line <> '' then
        begin
          if Description <> '' then
            Description := Description + ' ' + Line
          else
            Description := Line;
        end;
      end;
    end;

    // If we found @summary, use it, otherwise use the description
    if Result = '' then
      Result := Description;

  finally
    Lines.Free;
  end;
end;

class function TJSParser.ExtractDescriptionFromCommentInternal(const Comment: String): String;
begin
  Result := Trim(Comment);
  if Pos(LineEnding, Result) > 0 then
    Result := Copy(Result, 1, Pos(LineEnding, Result) - 1);
end;

class function TJSParser.ExtractParamDescriptionFromCommentInternal(const Comment: String;
  const ParamName: String): String;
var
  Lines: TStringList;
  I: Integer;
  Line, TempLine: String;
  ParamPos, DashPos, NextTagPos: Integer;
begin
  Result := '';
  if (Comment = '') or (ParamName = '') then Exit;

  Lines := TStringList.Create;
  try
    Lines.Text := Comment;

    for I := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[I]);
      TempLine := LowerCase(Line);

      if Pos('@param', TempLine) > 0 then
      begin
        // Check if this line contains our parameter
        ParamPos := Pos(LowerCase(ParamName), TempLine);

        if (ParamPos > 0) then
        begin
          TDebugLogger.InfoFmt('Found @param for "%s": "%s"', [ParamName, Line], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

          // Remove everything before and including the parameter name
          ParamPos := Pos(ParamName, Line);
          if ParamPos > 0 then
          begin
            Delete(Line, 1, ParamPos + Length(ParamName) - 1);
            Line := Trim(Line);
          end;

          // Look for dash separator
          DashPos := Pos('-', Line);
          if DashPos > 0 then
          begin
            // Take everything after the dash
            Result := Trim(Copy(Line, DashPos + 1, MaxInt));

            // Stop at the next @ tag if present
            NextTagPos := Pos('@', Result);
            if NextTagPos > 0 then
              Result := Trim(Copy(Result, 1, NextTagPos - 1));
          end;

          TDebugLogger.InfoFmt('  Extracted description: "%s"', [Result], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
          Break;
        end;
      end;
    end;
  finally
    Lines.Free;
  end;
end;

class function TJSParser.ExtractReturnDescriptionFromCommentInternal(const Comment: String): String;
var
  Lines: TStringList;
  I: Integer;
  Line: String;
begin
  Result := '';
  if Comment = '' then Exit;

  Lines := TStringList.Create;
  try
    Lines.Text := Comment;

    for I := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[I]);
      if Pos('@returns', Line) > 0 then
      begin
        Delete(Line, 1, Pos('@returns', Line) + 7);
        Line := Trim(Line);
        if (Length(Line) > 0) and (Line[1] = '{') then
        begin
          Delete(Line, 1, Pos('}', Line));
          Line := Trim(Line);
        end;
        Result := Line;
        Break;
      end
      else if Pos('@return', Line) > 0 then
      begin
        Delete(Line, 1, Pos('@return', Line) + 6);
        Line := Trim(Line);
        if (Length(Line) > 0) and (Line[1] = '{') then
        begin
          Delete(Line, 1, Pos('}', Line));
          Line := Trim(Line);
        end;
        Result := Line;
        Break;
      end;
    end;
  finally
    Lines.Free;
  end;
end;

//=========== FUNCTIONS ============

class function TJSParser.IsFunctionDeclaration(const Line: String): Boolean;
begin
  Result := IsFunctionDeclarationInternal(Line);
end;

class function TJSParser.IsFunctionDeclarationInternal(const Line: String): Boolean;
var
  CleanLine: String;
begin
  CleanLine := Trim(Line);

  if (CleanLine = '') or (Pos('//', CleanLine) = 1) or (Pos('/*', CleanLine) = 1) then
  begin
    Result := False;
    Exit;
  end;

  // Remove export keyword
  if Pos('export ', CleanLine) = 1 then
    CleanLine := Trim(Copy(CleanLine, 8, MaxInt));

  // Remove async keyword for checking
  if Pos('async ', CleanLine) = 1 then
    CleanLine := Trim(Copy(CleanLine, 7, MaxInt));

  Result := False;

  // Traditional function
  if Pos('function ', CleanLine) = 1 then
    Result := True

  // Arrow function with const/let/var
  else if ((Pos('const ', CleanLine) = 1) or
           (Pos('let ', CleanLine) = 1) or
           (Pos('var ', CleanLine) = 1)) and
          (Pos('=>', CleanLine) > 0) then
    Result := True

  // Method definition
  else if (Pos('(', CleanLine) > 0) and
          (Pos(')', CleanLine) > Pos('(', CleanLine)) and
          (Pos('{', CleanLine) = Length(CleanLine)) and
          (Pos('function ', CleanLine) = 0) and
          (Pos('=>', CleanLine) = 0) then
    Result := True;
end;

class function TJSParser.ParseFunction(const Lines: TStringList; StartLine: Integer): TJSFunctionInfo;
var
  I, J: Integer;
  Line, FuncDef: String;
  BraceCount, BracketCount, ParenCount: Integer;
  Pos1, Pos2: Integer;
  FoundStart: Boolean;
  InString: Boolean;
  StringChar: Char;
  InTemplateLiteral: Boolean;
  InLineComment, InMultiComment: Boolean;
  MaxLinesToScan: Integer;
  BacktickDepth: Integer;
  ReturnTypeInferred: String;
  ExtractedName: String;  // Add this variable
begin
  // Initialize with safe defaults
  Result.Name := '';
  Result.Code := TStringList.Create;
  Result.StartLine := StartLine;
  Result.EndLine := StartLine;
  Result.Parameters := TStringList.Create;
  Result.ReturnType := '';
  Result.ReturnDesc := '';
  Result.Description := '';
  Result.Summary := '';
  Result.ReturnExample := '';
  Result.ExampleCode := '';
  Result.IsAsync := False;
  Result.IsArrow := False;
  Result.IsMethod := False;
  Result.ParentClass := '';
  Result.Calls := TStringList.Create;
  Result.CalledBy := TStringList.Create;
  Result.FileName := '';
  SetLength(Result.ParamData, 0);
  SetLength(Result.VarData, 0);

  TDebugLogger.InfoFmt('ParseFunction called for line %d', [StartLine + 1], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  if (StartLine < 0) or (StartLine >= Lines.Count) then
  begin
    TDebugLogger.ErrorFmt('Invalid StartLine: %d', [StartLine], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    Exit;
  end;

  try
    // Get preceding comment
    if StartLine > 0 then
    begin
      TDebugLogger.Info('Looking for JSDoc comment before function...', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      Result.Description := ParseDoxygenCommentInternal(Lines, StartLine - 1);

      if Result.Description <> '' then
      begin
        TDebugLogger.InfoFmt('Found JSDoc comment', [], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

        // Store the function name we extract from the code
        ExtractedName := '';

        // Extract function name from signature FIRST
        Line := Trim(Lines[StartLine]);

        if Pos('function ', Line) > 0 then
        begin
          if Pos('function* ', Line) = 1 then
            Pos1 := Pos('function* ', Line) + 10
          else
            Pos1 := Pos('function ', Line) + 9;

          Pos2 := Pos('(', Line);
          if (Pos2 > Pos1) then
            ExtractedName := Trim(Copy(Line, Pos1, Pos2 - Pos1))
          else
            ExtractedName := 'anonymous';
        end
        else if Pos('=>', Line) > 0 then  // Arrow function
        begin
          if Pos('const ', Line) > 0 then
            Pos1 := Pos('const ', Line) + 6
          else if Pos('let ', Line) > 0 then
            Pos1 := Pos('let ', Line) + 4
          else if Pos('var ', Line) > 0 then
            Pos1 := Pos('var ', Line) + 4
          else if Pos('async ', Line) = 1 then
          begin
            Pos1 := 7;
            Line := Copy(Line, 7, MaxInt);
            Line := Trim(Line);
          end
          else
            Pos1 := 1;

          Pos2 := Pos('=', Line);
          if (Pos2 > Pos1) then
            ExtractedName := Trim(Copy(Line, Pos1, Pos2 - Pos1))
          else
            ExtractedName := 'anonymous';
        end
        else if (Pos('(', Line) > 0) and (Pos(')', Line) > Pos('(', Line)) then
        begin
          Pos1 := 1;
          Pos2 := Pos('(', Line);
          if (Pos2 > Pos1) then
          begin
            ExtractedName := Trim(Copy(Line, Pos1, Pos2 - Pos1));
            Result.IsMethod := True;
          end;
        end;

        // Set the name from the code
        if ExtractedName <> '' then
          Result.Name := ExtractedName;

        TDebugLogger.InfoFmt('Function name from code: "%s"', [Result.Name], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

        // Now parse the JSDoc comment
        ParseJSDocComment(Result.Description, Result);
      end
      else
      begin
        TDebugLogger.Info('No JSDoc comment found', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      end;
    end;

    Line := Trim(Lines[StartLine]);
    FuncDef := Line;

    TDebugLogger.InfoFmt('Function definition: "%s"', [Copy(Line, 1, 80)], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

    // Check function type
    Result.IsAsync := Pos('async ', Line) = 1;
    Result.IsArrow := Pos('=>', Line) > 0;

    // Extract function name from signature (only if not set by JSDoc @name)
    if Result.Name = '' then
    begin
      Line := Trim(Lines[StartLine]);
      if Pos('function ', Line) > 0 then
      begin
        if Pos('function* ', Line) = 1 then
          Pos1 := Pos('function* ', Line) + 10
        else
          Pos1 := Pos('function ', Line) + 9;

        Pos2 := Pos('(', Line);
        if (Pos2 > Pos1) then
          Result.Name := Trim(Copy(Line, Pos1, Pos2 - Pos1))
        else
          Result.Name := 'anonymous';
      end
      else if Result.IsArrow then
      begin
        if Pos('const ', Line) > 0 then
          Pos1 := Pos('const ', Line) + 6
        else if Pos('let ', Line) > 0 then
          Pos1 := Pos('let ', Line) + 4
        else if Pos('var ', Line) > 0 then
          Pos1 := Pos('var ', Line) + 4
        else if Pos('async ', Line) = 1 then
        begin
          Pos1 := 7;
          Line := Copy(Line, 7, MaxInt);
          Line := Trim(Line);
        end
        else
          Pos1 := 1;

        Pos2 := Pos('=', Line);
        if (Pos2 > Pos1) then
          Result.Name := Trim(Copy(Line, Pos1, Pos2 - Pos1))
        else
          Result.Name := 'anonymous';
      end
      else if (Pos('(', Line) > 0) and (Pos(')', Line) > Pos('(', Line)) then
      begin
        Pos1 := 1;
        Pos2 := Pos('(', Line);
        if (Pos2 > Pos1) then
        begin
          Result.Name := Trim(Copy(Line, Pos1, Pos2 - Pos1));
          Result.IsMethod := True;
        end;
      end
      else
      begin
        Result.Name := 'unknown';
      end;
    end;

    TDebugLogger.InfoFmt('Function name: "%s"', [Result.Name], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

    // Find function end
    I := StartLine;
    BraceCount := 0;
    BracketCount := 0;
    ParenCount := 0;
    FoundStart := False;
    InString := False;
    InTemplateLiteral := False;
    StringChar := #0;
    InLineComment := False;
    InMultiComment := False;
    BacktickDepth := 0;
    MaxLinesToScan := Min(StartLine + 200, Lines.Count);

    while (I < MaxLinesToScan) and (I < Lines.Count) do
    begin
      Line := Lines[I];
      if I > StartLine then
        FuncDef := FuncDef + ' ' + Line;

      J := 1;
      while J <= Length(Line) do
      begin
        if not InString and not InTemplateLiteral then
        begin
          if (J < Length(Line)) and (Line[J] = '/') and (Line[J+1] = '/') then
            Break;

          if (J < Length(Line)) and (Line[J] = '/') and (Line[J+1] = '*') then
          begin
            InMultiComment := True;
            Inc(J, 2);
            Continue;
          end;

          if InMultiComment and (J < Length(Line)) and (Line[J] = '*') and (Line[J+1] = '/') then
          begin
            InMultiComment := False;
            Inc(J, 2);
            Continue;
          end;

          if InMultiComment then
          begin
            Inc(J);
            Continue;
          end;
        end;

        if not InLineComment and not InMultiComment then
        begin
          if InString then
          begin
            if Line[J] = '\' then
            begin
              Inc(J);
              if J <= Length(Line) then Inc(J);
              Continue;
            end
            else if Line[J] = StringChar then
            begin
              InString := False;
              StringChar := #0;
            end;
          end
          else if InTemplateLiteral then
          begin
            if Line[J] = '\' then
            begin
              Inc(J);
              if J <= Length(Line) then Inc(J);
              Continue;
            end
            else if Line[J] = '`' then
            begin
              Dec(BacktickDepth);
              if BacktickDepth = 0 then
                InTemplateLiteral := False;
            end
            else if (J < Length(Line)) and (Line[J] = '$') and (Line[J+1] = '{') then
            begin
              Inc(BacktickDepth);
              Inc(J, 2);
              Continue;
            end;
          end
          else
          begin
            if Line[J] = '''' then
            begin
              InString := True;
              StringChar := '''';
            end
            else if Line[J] = '"' then
            begin
              InString := True;
              StringChar := '"';
            end
            else if Line[J] = '`' then
            begin
              InTemplateLiteral := True;
              BacktickDepth := 1;
            end;
          end;

          if not InString and not InTemplateLiteral and not InLineComment and not InMultiComment then
          begin
            case Line[J] of
              '{':
              begin
                Inc(BraceCount);
                FoundStart := True;
              end;
              '}':
              begin
                Dec(BraceCount);
                if FoundStart and (BraceCount = 0) and (BracketCount = 0) and (ParenCount = 0) then
                begin
                  Result.EndLine := I;
                  Break;
                end;
              end;
              '[': Inc(BracketCount);
              ']': Dec(BracketCount);
              '(': Inc(ParenCount);
              ')': Dec(ParenCount);
            end;
          end;
        end;

        Inc(J);
      end;

      if FoundStart and (BraceCount = 0) and (BracketCount = 0) and (ParenCount = 0) then
      begin
        Result.EndLine := I;
        Break;
      end;

      Inc(I);

      if (I - StartLine) > 150 then
      begin
        TDebugLogger.WarningFmt('Function parsing truncated at %d lines for: %s', [I-StartLine, Result.Name], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        Result.EndLine := I;
        Break;
      end;
    end;

    if not FoundStart or (BraceCount > 0) then
    begin
      Result.EndLine := Min(StartLine + 50, Lines.Count - 1);
      TDebugLogger.WarningFmt('Function end not properly detected for: %s', [Result.Name], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    end;
    // Store function code to make preview.
    for I := StartLine to Min(Result.EndLine, Lines.Count - 1) do
    begin
        Result.Code.Add(Lines[I]);
    end;
    // Extract parameters
    Result.Parameters := ExtractParameters(FuncDef);

    // DEBUG: Log raw parameters
    TDebugLogger.InfoFmt('Function "%s" has %d parameters', [Result.Name, Result.Parameters.Count], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

    // Parse detailed parameter information
    SetLength(Result.ParamData, Result.Parameters.Count);
    for I := 0 to Result.Parameters.Count - 1 do
    begin
      TDebugLogger.InfoFmt('Parsing parameter %d', [I + 1], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      Result.ParamData[I] := ParseParameterDetails(
        Result.Parameters[I],
        Result.Description,
        I
      );
    end;

    // Extract function calls
    ExtractFunctionCalls(Lines, StartLine, Result.EndLine, Result.Calls);

    ReturnTypeInferred := InferReturnTypeFromBodyInternal(Lines, StartLine, Result.EndLine);
    if (Result.ReturnType = '') and (ReturnTypeInferred <> '') then
      Result.ReturnType := ReturnTypeInferred;
  except
    on E: Exception do
    begin
      TDebugLogger.ErrorFmt('ERROR in ParseFunction at line %d: %s', [StartLine+1, E.Message], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      Result.EndLine := Min(StartLine + 10, Lines.Count - 1);
    end;
  end;
end;

class procedure TJSParser.ExtractFunctionCalls(const Lines: TStringList;
  StartLine, EndLine: Integer; Calls: TStringList);
var
  I: Integer;
  Line: String;
  Pos1, Pos2: Integer;
  CallName: String;
begin
  if Calls = nil then Exit;

  for I := StartLine to EndLine do
  begin
    Line := Lines[I];

    Pos1 := Pos('(', Line);
    while Pos1 > 0 do
    begin
      Pos2 := Pos1;
      while (Pos2 > 1) and (Line[Pos2-1] in ['a'..'z','A'..'Z','0'..'9','_','.']) do
        Dec(Pos2);

      if Pos2 < Pos1 then
      begin
        CallName := Copy(Line, Pos2, Pos1 - Pos2);
        if (CallName <> '') and (Calls.IndexOf(CallName) = -1) then
          Calls.Add(CallName);
      end;

      Pos1 := Pos('(', Line, Pos1 + 1);
    end;
  end;
end;

//=========== VARS ============

class function TJSParser.ParseGlobalVariableSimple(const Lines: TStringList; LineIndex: Integer;
  const PrecedingComment: String): TJSGlobalVar;
begin
  Result := ParseGlobalVariableSimpleInternal(Lines, LineIndex, PrecedingComment);
end;

class function TJSParser.ParseGlobalVariableSimpleInternal(const Lines: TStringList; LineIndex: Integer;
  const PrecedingComment: String): TJSGlobalVar;
var
  Line: String;
  VarName, VarType, Value: String;
  I, StartPos, EndPos: Integer;
begin
  Result.Name := '';
  Result.VarType := '';
  Result.Value := '';
  Result.Line := LineIndex + 1;
  Result.Description := ExtractDescriptionFromCommentInternal(PrecedingComment);

  Line := Trim(Lines[LineIndex]);

  if Pos('const ', Line) = 1 then
    VarType := 'const'
  else if Pos('let ', Line) = 1 then
    VarType := 'let'
  else if Pos('var ', Line) = 1 then
    VarType := 'var'
  else
    Exit;

  Delete(Line, 1, Length(VarType) + 1);
  Line := Trim(Line);

  VarName := '';
  I := 1;
  while (I <= Length(Line)) and not (Line[I] in ['=', ';', ' ', #9, ':']) do
  begin
    VarName := VarName + Line[I];
    Inc(I);
  end;

  Value := '';
  if Pos('=', Line) > 0 then
  begin
    StartPos := Pos('=', Line) + 1;
    EndPos := Length(Line) + 1;

    if Pos(';', Line) > StartPos then
      EndPos := Pos(';', Line);

    Value := Trim(Copy(Line, StartPos, EndPos - StartPos));

    if Length(Value) > 100 then
      Value := Copy(Value, 1, 100) + '...';
  end;

  Result.Name := VarName;
  Result.VarType := VarType;
  Result.Value := Value;
end;

//=========== COMMENTS ============

class function TJSParser.ExtractMultiLineCommentInternal(const Lines: TStringList;
  var LineIndex: Integer): String;
var
  Comment: String;
  I: Integer;
  Line: String;
  CommentEnded: Boolean;
begin
  Result := '';
  Comment := '';
  I := LineIndex;
  CommentEnded := False;

  if I >= Lines.Count then Exit;

  Line := Lines[I];

  // Extract from start of comment
  if Pos('/*', Line) > 0 then
  begin
    Comment := Copy(Line, Pos('/*', Line) + 2, MaxInt);
  end
  else
  begin
    Comment := Line;
  end;

  // Check if comment ends on same line
  if Pos('*/', Line) > 0 then
  begin
    Comment := Copy(Comment, 1, Pos('*/', Comment) - 1);
    CommentEnded := True;
    LineIndex := I; // Stay on same line
  end;

  // Continue to next lines if needed
  while (I < Lines.Count - 1) and not CommentEnded do
  begin
    Inc(I);
    Line := Lines[I];

    if Pos('*/', Line) > 0 then
    begin
      Comment := Comment + LineEnding + Copy(Line, 1, Pos('*/', Line) - 1);
      CommentEnded := True;
      LineIndex := I; // Update to the line where comment ended
    end
    else
    begin
      Comment := Comment + LineEnding + Line;
    end;

    // Safety check: don't go too far
    if (I - LineIndex) > 100 then
    begin
      TDebugLogger.WarningFmt('Multi-line comment too long, truncated at line %d', [I+1], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      Break;
    end;
  end;

  Result := Trim(Comment);
end;

class function TJSParser.ExtractMultiLineComment(const Lines: TStringList; var LineIndex: Integer): String;
begin
  Result := ExtractMultiLineCommentInternal(Lines, LineIndex);
end;

class function TJSParser.ParseDoxygenComment(const Lines: TStringList;
  LineBeforeFunction: Integer): String;
var
  I: Integer;
  Line, Comment: String;
  InDoxygenComment: Boolean;
  StartLine: Integer;
begin
  Result := '';
  Comment := '';
  InDoxygenComment := False;
  StartLine := -1;

  for I := LineBeforeFunction downto 0 do
  begin
    Line := Trim(Lines[I]);

    if Line = '' then Continue;

    if Pos('*/', Line) > 0 then
      Break;

    if (Pos('/**', Line) = 1) or (Pos('/*!', Line) = 1) then
    begin
      StartLine := I;
      Break;
    end;

    if (Pos('/*', Line) = 1) and (Line[3] <> '*') and (Line[3] <> '!') then
    begin
      StartLine := I;
      Break;
    end;
  end;

  if StartLine = -1 then Exit;

  InDoxygenComment := True;
  for I := StartLine to LineBeforeFunction do
  begin
    Line := Lines[I];

    if InDoxygenComment then
    begin
      if Pos('/**', Line) > 0 then
        Line := Copy(Line, 4, MaxInt)
      else if Pos('/*!', Line) > 0 then
        Line := Copy(Line, 4, MaxInt)
      else if Pos('/*', Line) > 0 then
        Line := Copy(Line, 3, MaxInt)
      else if (Length(Line) >= 1) and (Line[1] = '*') then
        Line := Copy(Line, 2, MaxInt)
      else if (Length(Line) >= 2) and (Line[1] = ' ') and (Line[2] = '*') then
        Line := Copy(Line, 3, MaxInt);

      if Pos('*/', Line) > 0 then
      begin
        Line := Copy(Line, 1, Pos('*/', Line) - 1);
        InDoxygenComment := False;
      end;

      Comment := Comment + Trim(Line) + LineEnding;
    end;
  end;

  Result := Trim(Comment);
end;

class function TJSParser.CountBraces(const Line: String; CurrentCount: Integer): Integer;
begin
  Result := CountBracesInternal(Line, CurrentCount);
end;

class function TJSParser.ParseDoxygenCommentInternal(const Lines: TStringList;
  LineBeforeFunction: Integer): String;
var
  I, J, CommentEndLine: Integer;
  Line: String;
  CommentLines: TStringList;
  InComment: Boolean;
  StartLine: Integer;
begin
  Result := '';

  TDebugLogger.InfoFmt('Looking for JSDoc comment immediately before line %d', [LineBeforeFunction + 2], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  // Find the comment end (*/)
  CommentEndLine := -1;
  for I := LineBeforeFunction downto Max(0, LineBeforeFunction - 10) do
  begin
    Line := Trim(Lines[I]);
    if Pos('*/', Line) > 0 then
    begin
      CommentEndLine := I;
      TDebugLogger.InfoFmt('Found comment end at line %d', [CommentEndLine + 1], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      Break;
    end;
  end;

  if CommentEndLine = -1 then
  begin
    TDebugLogger.Info('No comment end found', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    Exit;
  end;

  // Find the comment start (/**)
  StartLine := -1;
  for J := CommentEndLine downto Max(0, CommentEndLine - 20) do
  begin
    Line := Trim(Lines[J]);
    if Pos('/**', Line) = 1 then
    begin
      StartLine := J;
      TDebugLogger.InfoFmt('Found comment start at line %d', [StartLine + 1], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      Break;
    end;
  end;

  if StartLine = -1 then
  begin
    TDebugLogger.Info('No comment start found', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    Exit;
  end;

  // Extract and clean the comment lines
  CommentLines := TStringList.Create;
  try
    InComment := True;
    for J := StartLine to CommentEndLine do
    begin
      Line := Lines[J];

      if InComment then
      begin
        // Clean the line - remove JSDoc markers
        if Pos('/**', Line) > 0 then
        begin
          Line := Copy(Line, 4, MaxInt);  // Remove /**
        end;

        // Remove leading asterisks and spaces
        Line := Trim(Line);
        while (Length(Line) > 0) and (Line[1] = '*') do
        begin
          Delete(Line, 1, 1);
          Line := Trim(Line);
        end;

        // Check for comment end
        if Pos('*/', Line) > 0 then
        begin
          Line := Copy(Line, 1, Pos('*/', Line) - 1);
          Line := Trim(Line);
          InComment := False;
        end;

        // Only add non-empty lines
        if Line <> '' then
          CommentLines.Add(Line);

        if not InComment then Break;
      end;
    end;

    // Join with line breaks
    Result := CommentLines.Text;
    TDebugLogger.InfoFmt('Extracted %d cleaned comment lines', [CommentLines.Count], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

    // Debug: show cleaned comment
    if CommentLines.Count > 0 then
    begin
      TDebugLogger.Info('Cleaned JSDoc comment:', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      for J := 0 to Min(CommentLines.Count - 1, 10) do
        TDebugLogger.InfoFmt('  [%d] "%s"', [J + 1, CommentLines[J]], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    end;

  finally
    CommentLines.Free;
  end;
end;

//=========== PARAMETERS ============

class function TJSParser.ExtractParameters(const FunctionDef: String): TStringList;
var
  ParamsStart, ParamsEnd: Integer;
  ParamsStr, Param: String;
  I, Pos1: Integer;
  InString: Boolean;
  StringChar: Char;
  InParen, InBrace, InBracket: Integer;
begin
  Result := TStringList.Create;

  TDebugLogger.InfoFmt('ExtractParameters called with: "%s"', [Copy(FunctionDef, 1, 100)], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  ParamsStart := Pos('(', FunctionDef);
  ParamsEnd := Pos(')', FunctionDef);

  if (ParamsStart > 0) and (ParamsEnd > ParamsStart) then
  begin
    ParamsStr := Copy(FunctionDef, ParamsStart + 1, ParamsEnd - ParamsStart - 1);
    TDebugLogger.InfoFmt('Raw parameters string: "%s"', [ParamsStr], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

    // Manual parsing to handle default values with commas
    Param := '';
    InString := False;
    StringChar := #0;
    InParen := 0;
    InBrace := 0;
    InBracket := 0;

    for I := 1 to Length(ParamsStr) do
    begin
      // Handle strings
      if not InString then
      begin
        if ParamsStr[I] in ['''', '"', '`'] then
        begin
          InString := True;
          StringChar := ParamsStr[I];
        end;
      end
      else
      begin
        if (ParamsStr[I] = StringChar) and (I > 1) and (ParamsStr[I-1] <> '\') then
          InString := False;
      end;

      if not InString then
      begin
        // Track nesting
        case ParamsStr[I] of
          '(': Inc(InParen);
          ')': Dec(InParen);
          '{': Inc(InBrace);
          '}': Dec(InBrace);
          '[': Inc(InBracket);
          ']': Dec(InBracket);
        end;
      end;

      // If we're at a comma and not inside any nesting or string, end the parameter
      if (ParamsStr[I] = ',') and not InString and
         (InParen = 0) and (InBrace = 0) and (InBracket = 0) then
      begin
        Param := Trim(Param);
        if Param <> '' then
        begin
          TDebugLogger.InfoFmt('  Adding parameter: "%s"', [Param], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
          Result.Add(Param);
        end;
        Param := '';
      end
      else
      begin
        Param := Param + ParamsStr[I];
      end;
    end;

    // Add the last parameter
    Param := Trim(Param);
    if Param <> '' then
    begin
      TDebugLogger.InfoFmt('  Adding last parameter: "%s"', [Param], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      Result.Add(Param);
    end;

    TDebugLogger.InfoFmt('Total parameters found: %d', [Result.Count], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  end
  else
  begin
    TDebugLogger.Info('No parameters found or invalid function definition', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  end;
end;

class function TJSParser.ExtractParamDescInternal(const Param: String): String;
var
  DescStart: Integer;
begin
  Result := '';
  DescStart := Pos('//', Param);
  if DescStart > 0 then
    Result := Trim(Copy(Param, DescStart + 2, MaxInt));
end;

class function TJSParser.ExtractParamName(const ParamStr: String): String;
begin
  Result := ExtractParamNameInternal(ParamStr);
end;

class function TJSParser.ExtractParamType(const Param: String): String;
begin
  Result := ExtractParamTypeInternal(Param);
end;

class function TJSParser.ExtractParamDesc(const Param: String): String;
begin
  Result := ExtractParamDescInternal(Param);
end;

class function TJSParser.ExtractParamDescriptionFromComment(const Comment: String;
  const ParamName: String): String;
var
  Lines: TStringList;
  I: Integer;
  Line, Temp: String;
  ParamPos, DashPos: Integer;
begin
  Result := '';
  if (Comment = '') or (ParamName = '') then Exit;

  Lines := TStringList.Create;
  try
    Lines.Text := Comment;

    for I := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[I]);

      // Look for @param lines
      if Pos('@param', Line) > 0 then
      begin
        // Check if this is for our parameter
        Temp := LowerCase(Line);
        ParamPos := Pos(LowerCase(ParamName), Temp);

        if (ParamPos > 0) and (ParamPos > Pos('@param', Temp)) then
        begin
          // Extract everything after the parameter name
          Delete(Line, 1, ParamPos + Length(ParamName) - 1);
          Line := Trim(Line);

          // Check for dash separator
          DashPos := Pos('-', Line);
          if DashPos > 0 then
            Line := Copy(Line, DashPos + 1, MaxInt);

          Result := Trim(Line);
          Break;
        end;
      end;
    end;
  finally
    Lines.Free;
  end;
end;

class procedure TJSParser.ParseParameterString(const ParamStr: String;
  out ParamName, ParamType, ParamDesc: String);
begin
  ParseParameterStringInternal(ParamStr, ParamName, ParamType, ParamDesc);
end;

class function TJSParser.ExtractParamNameInternal(const ParamStr: String): String;
var
  Temp: String;
  ColonPos, EqualPos, I: Integer;
  InString: Boolean;
  StringChar: Char;
begin
  Temp := Trim(ParamStr);

  TDebugLogger.InfoFmt('ExtractParamNameInternal called with: "%s"', [Temp], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  // Find the first = that's not inside quotes
  InString := False;
  StringChar := #0;
  EqualPos := 0;

  for I := 1 to Length(Temp) do
  begin
    if not InString then
    begin
      if Temp[I] in ['''', '"', '`'] then
      begin
        InString := True;
        StringChar := Temp[I];
      end
      else if Temp[I] = '=' then
      begin
        EqualPos := I;
        Break;
      end;
    end
    else
    begin
      if (Temp[I] = StringChar) and (I > 1) and (Temp[I-1] <> '\') then
        InString := False;
    end;
  end;

  if EqualPos > 0 then
  begin
    Temp := Copy(Temp, 1, EqualPos - 1);
    TDebugLogger.InfoFmt('  Found default value, trimming to: "%s"', [Temp], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  end;

  // Check for type annotation
  ColonPos := Pos(':', Temp);
  if ColonPos > 0 then
  begin
    // Check if : is inside brackets (TypeScript generic)
    if not IsColonInGeneric(Temp, ColonPos) then
    begin
      Temp := Copy(Temp, 1, ColonPos - 1);
      TDebugLogger.InfoFmt('  Found type annotation, trimming to: "%s"', [Temp], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    end;
  end;

  // Clean up
  Temp := StringReplace(Temp, '{', '', [rfReplaceAll]);
  Temp := StringReplace(Temp, '}', '', [rfReplaceAll]);
  Temp := StringReplace(Temp, '[', '', [rfReplaceAll]);
  Temp := StringReplace(Temp, ']', '', [rfReplaceAll]);

  Result := Trim(Temp);
  TDebugLogger.InfoFmt('  Result: "%s"', [Result], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
end;

class function TJSParser.ExtractParamTypeInternal(const Param: String): String;
var
  Temp: String;
  ColonPos, EqualPos, I: Integer;
  InString: Boolean;
  StringChar: Char;
begin
  Result := 'any';
  Temp := Trim(Param);

  TDebugLogger.InfoFmt('ExtractParamTypeInternal called with: "%s"', [Temp], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  // First, remove default value if present
  InString := False;
  StringChar := #0;
  EqualPos := 0;

  for I := 1 to Length(Temp) do
  begin
    if not InString then
    begin
      if Temp[I] in ['''', '"', '`'] then
      begin
        InString := True;
        StringChar := Temp[I];
      end
      else if Temp[I] = '=' then
      begin
        EqualPos := I;
        Break;
      end;
    end
    else
    begin
      if (Temp[I] = StringChar) and (I > 1) and (Temp[I-1] <> '\') then
        InString := False;
    end;
  end;

  if EqualPos > 0 then
  begin
    Temp := Copy(Temp, 1, EqualPos - 1);
    TDebugLogger.InfoFmt('  Removed default value, now: "%s"', [Temp], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  end;

  // Now look for type annotation
  ColonPos := Pos(':', Temp);
  if ColonPos > 0 then
  begin
    // Check if it's a TypeScript generic (Array<string>: is not a type annotation)
    if not IsColonInGeneric(Temp, ColonPos) then
    begin
      Temp := Copy(Temp, ColonPos + 1, MaxInt);
      Temp := Trim(Temp);

      // Clean up optional indicator
      if (Length(Temp) > 0) and (Temp[1] = '?') then
        Delete(Temp, 1, 1);

      Result := Trim(Temp);
      if Result = '' then Result := 'any';
      TDebugLogger.InfoFmt('  Extracted type: "%s"', [Result], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    end;
  end
  else
  begin
    TDebugLogger.Info('  No type annotation found', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  end;
end;

class procedure TJSParser.ParseParameterStringInternal(const ParamStr: String;
  out ParamName, ParamType, ParamDesc: String);
var
  Temp: String;
  ColonPos, EqualPos, CommentPos: Integer;
begin
  Temp := Trim(ParamStr);
  ParamName := '';
  ParamType := 'any';
  ParamDesc := '';

  CommentPos := Pos('//', Temp);
  if CommentPos > 0 then
  begin
    ParamDesc := Trim(Copy(Temp, CommentPos + 2, MaxInt));
    Temp := Trim(Copy(Temp, 1, CommentPos - 1));
  end;

  EqualPos := Pos('=', Temp);
  if EqualPos > 0 then
    Temp := Trim(Copy(Temp, 1, EqualPos - 1));

  ColonPos := Pos(':', Temp);
  if ColonPos > 0 then
  begin
    ParamName := Trim(Copy(Temp, 1, ColonPos - 1));
    ParamType := Trim(Copy(Temp, ColonPos + 1, MaxInt));
  end
  else
  begin
    ParamName := Temp;
  end;

  ParamName := StringReplace(ParamName, '{', '', [rfReplaceAll]);
  ParamName := StringReplace(ParamName, '}', '', [rfReplaceAll]);
  ParamName := Trim(ParamName);

  if ParamType = '' then
    ParamType := 'any';
end;

//=========== JSDOC PARSING ============

class function TJSParser.ExtractParamTypeFromJSDoc(const Comment: String; const ParamName: String): String;
var
  Lines: TStringList;
  I: Integer;
  Line, TempLine: String;
  ParamPos, TypeStart, TypeEnd: Integer;
begin
  Result := 'any';  // Default type

  if (Comment = '') or (ParamName = '') then Exit;

  Lines := TStringList.Create;
  try
    Lines.Text := Comment;

    for I := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[I]);
      TempLine := LowerCase(Line);

      if Pos('@param', TempLine) > 0 then
      begin
        // Check if this line contains our parameter
        ParamPos := Pos(LowerCase(ParamName), TempLine);

        if (ParamPos > 0) then
        begin
          TDebugLogger.InfoFmt('Extracting type from @param for "%s": "%s"', [ParamName, Line], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

          // Extract type from braces {type}
          TypeStart := Pos('{', Line);
          TypeEnd := Pos('}', Line);

          if (TypeStart > 0) and (TypeEnd > TypeStart) then
          begin
            Result := Copy(Line, TypeStart + 1, TypeEnd - TypeStart - 1);
            TDebugLogger.InfoFmt('  Type from JSDoc: %s', [Result], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
          end
          else
          begin
            TDebugLogger.Info('  No type specified in JSDoc, using default: any', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
          end;

          Break;
        end;
      end;
    end;
  finally
    Lines.Free;
  end;
end;

class function TJSParser.IsColonInGeneric(const Str: String; ColonPos: Integer): Boolean;
var
  I, AngleCount: Integer;
begin
  Result := False;
  AngleCount := 0;

  for I := 1 to Min(ColonPos, Length(Str)) do
  begin
    case Str[I] of
      '<': Inc(AngleCount);
      '>': if AngleCount > 0 then Dec(AngleCount);
    end;
  end;

  Result := AngleCount > 0;

  if Result then
    TDebugLogger.InfoFmt('Colon at position %d is inside generic type', [ColonPos], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
end;

class function TJSParser.ParseParameterDetails(const ParamStr: String;
  const Comment: String; ParamIndex: Integer): TParamDataRecord;
var
  TempParam: String;
  EqualPos, I: Integer;
  InString: Boolean;
  StringChar: Char;
begin
  // Initialize result
  Result.pName := '';
  Result.pType := 'any';
  Result.pValue := '';
  Result.pDesc := '';

  TempParam := Trim(ParamStr);

  TDebugLogger.InfoFmt('ParseParameterDetails for param %d: "%s"', [ParamIndex + 1, TempParam], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  // Extract parameter name
  Result.pName := ExtractParamNameInternal(TempParam);

  if Result.pName = '' then
  begin
    TDebugLogger.WarningFmt('Parameter %d has no name: "%s"', [ParamIndex + 1, TempParam], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    Exit;
  end;

  // Extract default value
  InString := False;
  StringChar := #0;
  EqualPos := 0;

  for I := 1 to Length(TempParam) do
  begin
    if not InString then
    begin
      if TempParam[I] in ['''', '"', '`'] then
      begin
        InString := True;
        StringChar := TempParam[I];
      end
      else if TempParam[I] = '=' then
      begin
        EqualPos := I;
        Break;
      end;
    end
    else
    begin
      if (TempParam[I] = StringChar) and (I > 1) and (TempParam[I-1] <> '\') then
        InString := False;
    end;
  end;

  if EqualPos > 0 then
  begin
    Result.pValue := Trim(Copy(TempParam, EqualPos + 1, MaxInt));

    // Remove trailing comma if present
    if (Result.pValue <> '') and (Result.pValue[Length(Result.pValue)] = ',') then
      Result.pValue := Copy(Result.pValue, 1, Length(Result.pValue) - 1);

    TDebugLogger.InfoFmt('  Default value: "%s"', [Result.pValue], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  end;

  // Get type from JSDoc if available
  if Comment <> '' then
  begin
    Result.pType := ExtractParamTypeFromJSDoc(Comment, Result.pName);
    Result.pDesc := ExtractParamDescriptionFromCommentInternal(Comment, Result.pName);

    if Result.pType <> 'any' then
      TDebugLogger.InfoFmt('  Using JSDoc type: "%s"', [Result.pType], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%})
    else
      TDebugLogger.Info('  No JSDoc type found, will try signature', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  end;

  // If no JSDoc type or still "any", try to get from function signature
  if Result.pType = 'any' then
  begin
    Result.pType := ExtractParamTypeInternal(TempParam);
    TDebugLogger.InfoFmt('  Using signature type: "%s"', [Result.pType], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  end;

  TDebugLogger.InfoFmt('  Final: Name="%s", Type="%s", Default="%s", Desc="%s"', [Result.pName, Result.pType, Result.pValue, Result.pDesc], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
end;

class procedure TJSParser.ParseJSDocComment(const Comment: String; var FuncInfo: TJSFunctionInfo);
var
  Lines: TStringList;
  I: Integer;
  Line, CleanLine, TagName: String;
  InDescription, InExample: Boolean;
  DescriptionLines: TStringList;
  ExampleLines: TStringList;
  JSDocName: String;
begin
  if Comment = '' then Exit;

  TDebugLogger.InfoFmt('ParseJSDocComment for function "%s"', [FuncInfo.Name], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  Lines := TStringList.Create;
  try
    Lines.Text := Comment;

    TDebugLogger.InfoFmt('Parsing %d lines of JSDoc', [Lines.Count], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

    DescriptionLines := TStringList.Create;
    ExampleLines := TStringList.Create;
    try
      InDescription := True;
      InExample := False;
      JSDocName := '';

      for I := 0 to Lines.Count - 1 do
      begin
        Line := Lines[I];
        CleanLine := Trim(Line);
        if CleanLine = '' then Continue;

        TDebugLogger.InfoFmt('  Line %d: "%s"', [I + 1, CleanLine], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

        // Check for @ tags
        if CleanLine[1] = '@' then
        begin
          // Extract the tag name
          TagName := Copy(CleanLine, 1, Pos(' ', CleanLine + ' ') - 1);
          TDebugLogger.InfoFmt('    Found tag: %s', [TagName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

          InDescription := False;  // Stop collecting description

          if TagName = '@name' then
          begin
            Delete(CleanLine, 1, Length('@name'));
            CleanLine := Trim(CleanLine);
            JSDocName := CleanLine;
            TDebugLogger.InfoFmt('    Function name from JSDoc: %s', [JSDocName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
            // Check JSDoc name vs actual function name
            if (JSDocName <> '') and (FuncInfo.Name <> '') and (JSDocName <> FuncInfo.Name) then
               begin
                 // We empty the comment loaded and skip parsing.
                  TDebugLogger.WarningFmt('  JSDoc @name "%s" does not match function name "%s"', [JSDocName, FuncInfo.Name], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
                  FuncInfo.Description := '';
                  Exit;
               end;
          end
          else if TagName = '@summary' then
          begin
            Delete(CleanLine, 1, Length('@summary'));
            CleanLine := Trim(CleanLine);
            FuncInfo.Summary := CleanLine;
            TDebugLogger.InfoFmt('    Summary: %s', [FuncInfo.Summary], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
          end
          else if TagName = '@example' then
          begin
            InExample := True;
            TDebugLogger.Info('    Starting example block', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

            // Get example text on same line if any
            Delete(CleanLine, 1, Length('@example'));
            CleanLine := Trim(CleanLine);
            if CleanLine <> '' then
              ExampleLines.Add(CleanLine);
          end
          else if (TagName = '@returns') or (TagName = '@return') then
          begin
            TDebugLogger.Info('    Return extraction', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
            FuncInfo.ReturnDesc := ExtractReturnDescriptionFromComment(CleanLine);
            FuncInfo.ReturnType := ExtractReturnTypeFromComment(CleanLine);
            TDebugLogger.InfoFmt('    ReturnDesc: %s', [FuncInfo.ReturnDesc], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
            TDebugLogger.InfoFmt('    ReturnDesc: %s', [FuncInfo.ReturnType], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
            if (TagName = '@returns') then Delete(CleanLine, 1, Length('@returns'));
            if (TagName = '@return') then Delete(CleanLine, 1, Length('@return'));
          end
          else if (TagName = '@param') or (TagName = '@function') then
          begin
            // These are handled elsewhere or ignored for now
            TDebugLogger.InfoFmt('    Skipping %s tag (handled elsewhere)', [TagName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
          end
          else
          begin
            TDebugLogger.InfoFmt('    Ignoring unknown tag: %s', [TagName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
          end;
        end
        else if InExample then
        begin
          // Inside example block
          ExampleLines.Add(CleanLine);
        end
        else if InDescription then
        begin
          // Description text (before any @ tags)
          DescriptionLines.Add(CleanLine);
        end;
      end;

      // Build description
      if DescriptionLines.Count > 0 then
      begin
        FuncInfo.Description := '';
        for I := 0 to DescriptionLines.Count - 1 do
        begin
          if I > 0 then
            FuncInfo.Description := FuncInfo.Description + ' ' + DescriptionLines[I]
          else
            FuncInfo.Description := DescriptionLines[I];
        end;
        FuncInfo.Description := Trim(FuncInfo.Description);
        TDebugLogger.InfoFmt('  Description: "%s"', [FuncInfo.Description], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      end;

      // Parse examples
      if ExampleLines.Count > 0 then
      begin
        TDebugLogger.InfoFmt('  Found %d example lines', [ExampleLines.Count], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        ParseExampleLines(ExampleLines, FuncInfo.ReturnExample, FuncInfo.ExampleCode);
      end;

    finally
      DescriptionLines.Free;
      ExampleLines.Free;
    end;

  finally
    Lines.Free;
  end;
end;

class procedure TJSParser.ParseExampleLines(ExampleLines: TStringList;
  out ReturnExample, ExampleCode: String);
var
  I: Integer;
  Line: String;
begin
  ReturnExample := '';
  ExampleCode := '';

  TDebugLogger.Info('ParseExampleLines:', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  for I := 0 to ExampleLines.Count - 1 do
  begin
    Line := Trim(ExampleLines[I]);

    if Line = '' then Continue;

    TDebugLogger.InfoFmt('  Line %d: "%s"', [I + 1, Line], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

    // Look for "// returns X" pattern
    if (Pos('//', Line) = 1) then
    begin
      Delete(Line, 1, 2);
      Line := Trim(Line);

      if Pos('returns', LowerCase(Line)) = 1 then
      begin
        Delete(Line, 1, 7);
        Line := Trim(Line);
        ReturnExample := Line;
        TDebugLogger.InfoFmt('    Return example: "%s"', [ReturnExample], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      end;
    end
    // Look for function call (ends with ;)
    else if (Pos('(', Line) > 0) and (Pos(')', Line) > Pos('(', Line)) and
            (Pos(';', Line) = Length(Line)) then
    begin
      ExampleCode := Line;
      TDebugLogger.InfoFmt('    Example code: "%s"', [ExampleCode], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    end;
  end;
end;

class procedure TJSParser.ParseSeeTag(const TagContent: String; var FileInfo: TJSFileInfo; SeeIndex: Integer);
var
  TagText, LinkText, LinkTarget: String;
  BraceStart, BraceEnd, PipePos, SpacePos: Integer;
begin
  TDebugLogger.InfoFmt('ParseSeeTag: "%s"', [TagContent], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  // Initialize the See tag record
  if SeeIndex >= Length(FileInfo.See) then
    SetLength(FileInfo.See, SeeIndex + 1);

  with FileInfo.See[SeeIndex] do
  begin
    sTagText := '';
    sTagLink := '';
    sTagLinkText := '';

    // Check for {@link ...} format
    if Pos('{@link', TagContent) = 1 then
    begin
      BraceStart := Pos('{', TagContent);
      BraceEnd := Pos('}', TagContent);

      if (BraceStart > 0) and (BraceEnd > BraceStart) then
      begin
        // Extract content inside braces
        LinkText := Copy(TagContent, BraceStart + 6, BraceEnd - BraceStart - 6); // +6 for {@link
        LinkText := Trim(LinkText);

        TDebugLogger.InfoFmt('  Link text inside braces: "%s"', [LinkText], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

        // Check for pipe separator: {@link target | link text}
        PipePos := Pos('|', LinkText);
        if PipePos > 0 then
        begin
          // Has both target and link text
          sTagLink := Trim(Copy(LinkText, 1, PipePos - 1));
          sTagLinkText := Trim(Copy(LinkText, PipePos + 1, MaxInt));
          TDebugLogger.InfoFmt('    Link target: "%s"', [sTagLink], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
          TDebugLogger.InfoFmt('    Link text: "%s"', [sTagLinkText], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        end
        else
        begin
          // Just the link target
          sTagLink := LinkText;
          TDebugLogger.InfoFmt('    Link target: "%s"', [sTagLink], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        end;

        // Get text after the closing brace
        if BraceEnd < Length(TagContent) then
        begin
          TagText := Copy(TagContent, BraceEnd + 1, MaxInt);
          TagText := Trim(TagText);
          sTagText := TagText;
          TDebugLogger.InfoFmt('    Tag text: "%s"', [sTagText], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
        end;
      end;
    end
    else
    begin
      // Simple @see without link
      sTagText := TagContent;
      TDebugLogger.InfoFmt('  Simple @see text: "%s"', [sTagText], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    end;
  end;
end;

//=========== LOGGING ============

class procedure TJSParser.LogFunctionInfo(const FuncInfo: TJSFunctionInfo);
var
  I: Integer;
begin
  TDebugLogger.InfoFmt('=== FUNCTION INFO: %s ===', [FuncInfo.Name], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TDebugLogger.InfoFmt('  File: %s', [FuncInfo.FileName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TDebugLogger.InfoFmt('  Lines: %d-%d', [FuncInfo.StartLine + 1, FuncInfo.EndLine + 1], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TDebugLogger.InfoFmt('  Async: %s, Arrow: %s, Method: %s', [BoolToYesNo(FuncInfo.IsAsync), BoolToYesNo(FuncInfo.IsArrow), BoolToYesNo(FuncInfo.IsMethod)], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TDebugLogger.InfoFmt('  Return type: %s', [FuncInfo.ReturnType], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TDebugLogger.InfoFmt('  Description: %s', [FuncInfo.Description], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TDebugLogger.InfoFmt('  Summary: %s', [FuncInfo.Summary], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TDebugLogger.InfoFmt('  Return example: %s', [FuncInfo.ReturnExample], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TDebugLogger.InfoFmt('  Example code: %s', [FuncInfo.ExampleCode], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  TDebugLogger.InfoFmt('  Detailed Parameter Data (%d):', [Length(FuncInfo.ParamData)], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  for I := 0 to Length(FuncInfo.ParamData) - 1 do
  begin
    with FuncInfo.ParamData[I] do
    begin
      TDebugLogger.InfoFmt('    [%d] Name="%s", Type="%s", Default="%s", Desc="%s"', [I + 1, pName, pType, pValue, pDesc], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
    end;
  end;

  TDebugLogger.Info('=== END FUNCTION INFO ===', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
end;

//=========== FILES ============

class function TJSParser.ExtractFileLevelDocumentation(const Lines: TStringList): String;
begin
  Result := ExtractFileLevelDocumentationInternal(Lines);
end;

class function TJSParser.ExtractFileLevelComment(const Lines: TStringList): String;
begin
  Result := ExtractFileLevelCommentInternal(Lines);
end;

class function TJSParser.ExtractFileLevelDocumentationInternal(const Lines: TStringList): String;
var
  I, J: Integer;
  Line, Comment: String;
  InFileComment: Boolean;
  CommentLines: TStringList;
begin
  Result := '';
  Comment := '';
  InFileComment := False;

  TDebugLogger.Info('ExtractFileLevelDocumentationInternal', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  for I := 0 to Min(20, Lines.Count - 1) do
  begin
    Line := Trim(Lines[I]);

    if Line = '' then Continue;

    // Check for file-level JSDoc (/** at start of file)
    if (I = 0) and (Pos('/**', Line) = 1) then
    begin
      TDebugLogger.Info('Found file-level JSDoc at start of file', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      InFileComment := True;
      CommentLines := TStringList.Create;
      try
        J := I;
        while (J < Lines.Count) and (Pos('*/', Lines[J]) = 0) do
        begin
          Line := Lines[J];

          // Clean JSDoc markers
          if Pos('/**', Line) > 0 then
            Line := Copy(Line, 4, MaxInt)
          else if (Length(Line) > 0) and (Line[1] = '*') then
          begin
            if (Length(Line) > 1) and (Line[2] = ' ') then
              Line := Copy(Line, 3, MaxInt)
            else
              Line := Copy(Line, 2, MaxInt);
          end;

          CommentLines.Add(Trim(Line));
          Inc(J);
        end;

        // Add the last line (with */)
        if (J < Lines.Count) and (Pos('*/', Lines[J]) > 0) then
        begin
          Line := Lines[J];
          Line := Copy(Line, 1, Pos('*/', Line) - 1);
          Line := Trim(Line);
          if (Length(Line) > 0) and (Line[1] = '*') then
            Delete(Line, 1, 1);
          CommentLines.Add(Trim(Line));
        end;

        Result := CommentLines.Text;
        TDebugLogger.InfoFmt('Extracted %d lines of file JSDoc', [CommentLines.Count], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

      finally
        CommentLines.Free;
      end;

      Break;
    end
    else if (Pos('///', Line) = 1) then
    begin
      // Triple-slash comments
      Delete(Line, 1, 3);
      Comment := Comment + Trim(Line) + LineEnding;
    end
    else if (Line <> '') and not (Pos('//', Line) = 1) then
    begin
      // Non-comment line, stop looking for file-level docs
      Break;
    end;
  end;

  // If no JSDoc found, use triple-slash comments
  if Result = '' then
    Result := Trim(Comment);
end;

class function TJSParser.ExtractFileLevelCommentInternal(const Lines: TStringList): String;
var
  I: Integer;
  Line: String;
  Comment: String;
  InComment: Boolean;
begin
  Result := '';
  Comment := '';
  InComment := False;

  for I := 0 to Lines.Count - 1 do
  begin
    Line := Trim(Lines[I]);

    if (I = 0) and (Line = '') then Continue;

    if (Pos('/**', Line) > 0) and not InComment then
    begin
      InComment := True;
      Comment := Copy(Line, Pos('*', Line) + 1, MaxInt);
    end
    else if InComment then
    begin
      if Pos('*/', Line) > 0 then
      begin
        Comment := Comment + ' ' + Copy(Line, 1, Pos('*/', Line) - 1);
        Break;
      end
      else if Pos('*', Line) = 1 then
        Comment := Comment + ' ' + Copy(Line, 2, MaxInt);
    end
    else if (Line <> '') and not (Pos('//', Line) = 1) then
    begin
      Break;
    end;
  end;

  Result := Trim(Comment);
end;

class procedure TJSParser.ParseFileLevelJSDoc(const Comment: String; var FileInfo: TJSFileInfo);
var
  Lines: TStringList;
  I: Integer;
  Line, CleanLine, TagName: String;
  InDescription: Boolean;
  DescriptionLines: TStringList;
  SeeIndex: Integer;
begin
  if Comment = '' then Exit;

  TDebugLogger.Info('ParseFileLevelJSDoc', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

  Lines := TStringList.Create;
  try
    Lines.Text := Comment;

    TDebugLogger.InfoFmt('Parsing %d lines of file JSDoc', [Lines.Count], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

    DescriptionLines := TStringList.Create;
    try
      InDescription := True;
      SeeIndex := 0;

      for I := 0 to Lines.Count - 1 do
      begin
        Line := Lines[I];
        CleanLine := Trim(Line);

        // Remove leading asterisks
        while (Length(CleanLine) > 0) and (CleanLine[1] = '*') do
        begin
          Delete(CleanLine, 1, 1);
          CleanLine := Trim(CleanLine);
        end;

        if CleanLine = '' then Continue;
        TDebugLogger.InfoFmt('  Line %d: "%s"', [I + 1, CleanLine], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});

        // Check for @ tags
        if CleanLine[1] = '@' then
        begin
          InDescription := False;  // Stop collecting description

          // Extract the tag name
          TagName := Copy(CleanLine, 1, Pos(' ', CleanLine + ' ') - 1);

          case TagName of
            '@file':
              begin
                TDebugLogger.Info('    Found @file tag', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
                // This confirms it's a file-level JSDoc
              end;

            '@name':
              begin
                Delete(CleanLine, 1, Length('@name'));
                CleanLine := Trim(CleanLine);
                // The @name tag usually contains the filename
                TDebugLogger.InfoFmt('    File name from @name: %s', [CleanLine], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
              end;

            '@author':
              begin
                Delete(CleanLine, 1, Length('@author'));
                CleanLine := Trim(CleanLine);
                FileInfo.Author := CleanLine;
                TDebugLogger.InfoFmt('    Author: %s', [FileInfo.Author], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
              end;

            '@summary':
              begin
                Delete(CleanLine, 1, Length('@summary'));
                CleanLine := Trim(CleanLine);
                FileInfo.Summary := CleanLine;
                TDebugLogger.InfoFmt('    Summary: %s', [FileInfo.Summary], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
              end;

            '@see':
              begin
                Delete(CleanLine, 1, Length('@see'));
                CleanLine := Trim(CleanLine);

                // Parse @see tag: {@link target | link text} description
                ParseSeeTag(CleanLine, FileInfo, SeeIndex);
                Inc(SeeIndex);
              end;

            else
              TDebugLogger.InfoFmt('    Ignoring file-level tag: %s', [TagName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
          end;
        end
        else if InDescription then
        begin
          // Description text (before any @ tags)
          DescriptionLines.Add(CleanLine);
        end;
      end;

      // Build description
      if DescriptionLines.Count > 0 then
      begin
        FileInfo.FileDescription := '';
        for I := 0 to DescriptionLines.Count - 1 do
        begin
          if I > 0 then
            FileInfo.FileDescription := FileInfo.FileDescription + ' ' + DescriptionLines[I]
          else
            FileInfo.FileDescription := DescriptionLines[I];
        end;
        FileInfo.FileDescription := Trim(FileInfo.FileDescription);
        TDebugLogger.InfoFmt('  File description: "%s"', [FileInfo.FileDescription], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
      end;

    finally
      DescriptionLines.Free;
    end;

  finally
    Lines.Free;
  end;
end;

//=========== GENERATE ============

class procedure TJSParser.GenerateJSDocComment(const FuncInfo: TJSFunctionInfo; CommentLines: TStringList);
var
  I: Integer;
  ParamName, ParamType, ParamDesc: String;
begin
  TDebugLogger.Info('GenerateJSDocComment', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  CommentLines.Clear;
  CommentLines.Add('/**');

  if FuncInfo.Description <> '' then
  begin
    CommentLines.Add(' * ' + FuncInfo.Description);
    CommentLines.Add(' *');
  end;

  if Assigned(FuncInfo.Parameters) and (FuncInfo.Parameters.Count > 0) then
  begin
    for I := 0 to FuncInfo.Parameters.Count - 1 do
    begin
      ParseParameterStringInternal(FuncInfo.Parameters[I], ParamName, ParamType, ParamDesc);

      if ParamDesc <> '' then
        CommentLines.Add(' * @param {' + ParamType + '} ' + ParamName + ' - ' + ParamDesc)
      else
        CommentLines.Add(' * @param {' + ParamType + '} ' + ParamName);
    end;
    CommentLines.Add(' *');
  end;

  if FuncInfo.ReturnType <> '' then
    CommentLines.Add(' * @returns {' + FuncInfo.ReturnType + '}');

  CommentLines.Add(' */');
end;

class function TJSParser.FormatParameterString(const ParamName, ParamType, ParamDesc: String): String;
begin
  TDebugLogger.InfoFmt('FormatParameterString %s',[ParamName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  Result := ParamName;

  if (ParamType <> '') and (ParamType <> 'any') then
    Result := Result + ': ' + ParamType;

  if ParamDesc <> '' then
    Result := Result + ' // ' + ParamDesc;
end;

class procedure TJSParser.CleanupFunctionInfo(var FuncInfo: TJSFunctionInfo);
begin
  if Assigned(FuncInfo.Parameters) then FuncInfo.Parameters.Free;
  if Assigned(FuncInfo.Calls) then FuncInfo.Calls.Free;
  if Assigned(FuncInfo.CalledBy) then FuncInfo.CalledBy.Free;
  SetLength(FuncInfo.ParamData, 0);
  SetLength(FuncInfo.VarData, 0);
end;

class procedure TJSParser.CleanupFileInfo(var FileInfo: TJSFileInfo);
var
  I: Integer;
begin
  if Assigned(FileInfo.Classes) then FileInfo.Classes.Free;
  if Assigned(FileInfo.Imports) then FileInfo.Imports.Free;
  if Assigned(FileInfo.ExportedItems) then FileInfo.ExportedItems.Free;

  for I := 0 to Length(FileInfo.Functions) - 1 do
    CleanupFunctionInfo(FileInfo.Functions[I]);

  SetLength(FileInfo.Functions, 0);
  SetLength(FileInfo.GlobalVars, 0);
  SetLength(FileInfo.See, 0);  // Clear See tags array
end;

end.
