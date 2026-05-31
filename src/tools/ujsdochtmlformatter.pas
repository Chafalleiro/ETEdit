unit uJSDocHTMLFormatter;

//{$mode objfpc}{$M+}
{$mode objfpc}{$H+}
{$M+}  // <-- Add this line
interface

uses
  Classes, SysUtils, uJSParser, Graphics, uDebugLog;

type
  { TJSDocHTMLFormatter }
  TJSDocHTMLFormatter = class
  private
    FProjectName: String;
    FProjectVersion: String;
    FCSSStyle: String;
    FIncludeLineNumbers: Boolean;

    FUseExternalResources: Boolean;
    FCSSPath: String;
    FJSPath: String;
    FImagesPath: String;
    FBasePath: String;  // Add this field

    function GenerateCSS: String;
    function EscapeHTML(const Text: String): String;
    function FormatCodeBlock(const Code: String): String;
    function FormatLink(const Text, URL: String): String;
    function ExtractTagContent(const JSDoc: String; const Tag: String): String;
    function ExtractAllTags(const JSDoc: String; const Tag: String): TStringList;

  public
    constructor Create;

    // Configuration
    procedure SetProjectInfo(const AProjectName, AProjectVersion: String);
    procedure SetCustomCSS(const CSS: String);
    procedure SetIncludeLineNumbers(Value: Boolean);

    // HTML Generation
    function FormatFunctionAsHTML(const FuncInfo: TJSFunctionInfo;
      const FileName: String; FileIdx: Integer = -1): String;
    function FormatFileAsHTML(const FileInfo: TJSFileInfo): String;
    function FormatGlobalVarAsHTML(const GlobalVar: TJSGlobalVar;
      const FileName: String): String;
    function FormatProjectSummaryAsHTML(const FilesInfo: array of TJSFileInfo): String;

  public
    // Add these methods
    procedure SetExternalResourcesEnabled(Value: Boolean);
    procedure SetResourcePaths(const BasePath: String);
    function GenerateResourceLinks: String;

    // Complete Documentation
    function GenerateProjectDocumentation(const FilesInfo: array of TJSFileInfo): String;
  end;

implementation

{ TJSDocHTMLFormatter }

// Update the constructor
constructor TJSDocHTMLFormatter.Create;
begin
  inherited Create;
  FProjectName := 'Project';
  FProjectVersion := '1.0.0';
  FIncludeLineNumbers := True;
  FCSSStyle := '';
  FUseExternalResources := True;
  FCSSPath := 'css/';
  FJSPath := 'js/';
  FImagesPath := 'images/';
end;

procedure TJSDocHTMLFormatter.SetExternalResourcesEnabled(Value: Boolean);
begin
  FUseExternalResources := Value;
end;

procedure TJSDocHTMLFormatter.SetResourcePaths(const BasePath: String);
begin
  FBasePath := BasePath;
  FCSSPath := 'css/';
  FJSPath := 'js/';
  FImagesPath := 'images/';
end;

function TJSDocHTMLFormatter.GenerateResourceLinks: String;
begin
  if not FUseExternalResources then
  begin
    Result := GenerateCSS;
    Exit;
  end;

  Result :=
  '<link rel="stylesheet" href="' + FCSSPath + 'documentation.css">' + LineEnding +
    '<link rel="stylesheet" href="' + FCSSPath + 'syntax-highlight.css">' + LineEnding +
    '<script src="' + FJSPath + 'documentation.js"></script>' + LineEnding +
    '<script src="' + FJSPath + 'syntax-highlight.js"></script>';
end;

// Update GenerateCSS to only return CSS when not using external resources
function TJSDocHTMLFormatter.GenerateCSS: String;
begin
  if FUseExternalResources and (FCSSStyle = '') then
    Result := ''
  else if FCSSStyle <> '' then
    Result := FCSSStyle
  else
  begin
    // Fallback minimal CSS if external resources not available
    Result :=
      '<style>' + LineEnding +
      '  body { font-family: Arial, sans-serif; margin: 20px; }' + LineEnding +
      '  .function-signature { background: #f0f0f0; padding: 10px; }' + LineEnding +
      '  .param-table { border-collapse: collapse; width: 100%; }' + LineEnding +
      '  .param-table th, .param-table td { border: 1px solid #ddd; padding: 8px; }' + LineEnding +
      '  .param-table th { background-color: #4CAF50; color: white; }' + LineEnding +
      '</style>';
  end;
end;

function TJSDocHTMLFormatter.EscapeHTML(const Text: String): String;
begin
  Result := StringReplace(Text, '&', '&amp;', [rfReplaceAll]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);
  Result := StringReplace(Result, '''', '&#39;', [rfReplaceAll]);
end;

function TJSDocHTMLFormatter.FormatCodeBlock(const Code: String): String;
var
  Lines: TStringList;
  I: Integer;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := Code;
    Result := '<pre class="code-block">';
    for I := 0 to Lines.Count - 1 do
    begin
      if FIncludeLineNumbers then
        Result := Result + Format('<span style="color: #6c757d;">%3d:</span> ', [I + 1]);
      Result := Result + EscapeHTML(Lines[I]) + LineEnding;
    end;
    Result := Result + '</pre>';
  finally
    Lines.Free;
  end;
end;

function TJSDocHTMLFormatter.FormatLink(const Text, URL: String): String;
begin
  if URL = '' then
    Result := EscapeHTML(Text)
  else
    Result := Format('<a href="%s">%s</a>', [URL, EscapeHTML(Text)]);
end;

function TJSDocHTMLFormatter.ExtractTagContent(const JSDoc: String; const Tag: String): String;
begin
  Result := '';
  // Use the parser if available, otherwise parse manually
  // For now, implement simple extraction
  // TODO: Integrate with uJSParser methods
end;

function TJSDocHTMLFormatter.ExtractAllTags(const JSDoc: String; const Tag: String): TStringList;
begin
  Result := TStringList.Create;
  // TODO: Implement tag extraction
end;

procedure TJSDocHTMLFormatter.SetProjectInfo(const AProjectName, AProjectVersion: String);
begin
  FProjectName := AProjectName;
  FProjectVersion := AProjectVersion;
end;

procedure TJSDocHTMLFormatter.SetCustomCSS(const CSS: String);
begin
  FCSSStyle := CSS;
end;

procedure TJSDocHTMLFormatter.SetIncludeLineNumbers(Value: Boolean);
begin
  FIncludeLineNumbers := Value;
end;

function TJSDocHTMLFormatter.FormatFunctionAsHTML(const FuncInfo: TJSFunctionInfo;
  const FileName: String; FileIdx: Integer): String;
var
  I: Integer;
  ParamName, ParamType, ParamDesc, ReturnDesc, ExampleText: String;
  Badges: String;
begin
  Result :=
    '<!DOCTYPE html>' + LineEnding +
    '<html lang="en">' + LineEnding +
    '<head>' + LineEnding +
    '  <meta charset="UTF-8">' + LineEnding +
    '  <meta name="viewport" content="width=device-width, initial-scale=1.0">' + LineEnding +
    '  <title>' + EscapeHTML(FuncInfo.Name) + ' - ' + EscapeHTML(FileName) + '</title>' + LineEnding +
    GenerateResourceLinks + LineEnding +
    '</head>' + LineEnding +
    '<body>' + LineEnding +
    '<div class="doc-container">' + LineEnding;

  // Header
  Result := Result +
    '<div class="doc-header">' + LineEnding +
    '  <h1 class="doc-title">' + EscapeHTML(FuncInfo.Name) + '</h1>' + LineEnding +
    '  <p class="doc-subtitle">Function Documentation</p>' + LineEnding +
    '</div>' + LineEnding;

  // File info
  Result := Result +
    '<div class="info-card">' + LineEnding +
    '  <div><span class="info-label">File:</span> <span class="info-value">' +
    EscapeHTML(FileName) + '</span></div>' + LineEnding;

  if FIncludeLineNumbers then
    Result := Result +
      '  <div><span class="info-label">Location:</span> <span class="info-value">Lines ' +
      IntToStr(FuncInfo.StartLine + 1) + '-' + IntToStr(FuncInfo.EndLine + 1) + '</span></div>' + LineEnding;

  // Function type badges
  Badges := '';
  if FuncInfo.IsAsync then
    Badges := Badges + '<span class="badge badge-async">Async</span> ';
  if FuncInfo.IsArrow then
    Badges := Badges + '<span class="badge badge-arrow">Arrow</span> ';
  if FuncInfo.IsMethod then
    Badges := Badges + '<span class="badge badge-method">Method</span> ';
  if FuncInfo.ParentClass <> '' then
    Badges := Badges + '<span class="badge">' + EscapeHTML(FuncInfo.ParentClass) + '</span>';

  if Badges <> '' then
    Result := Result + '  <div><span class="info-label">Type:</span> ' + Badges + '</div>' + LineEnding;

  Result := Result + '</div>' + LineEnding;

  // Function signature
  Result := Result +
    '<div class="section">' + LineEnding +
    '  <h2 class="section-title">Signature</h2>' + LineEnding +
    '  <div class="function-signature">' + LineEnding;

  if FuncInfo.IsAsync then
    Result := Result + '    <span class="function-type">async </span>';

  Result := Result +
    '    <span class="function-name">' + EscapeHTML(FuncInfo.Name) + '</span>(';

  if Assigned(FuncInfo.Parameters) and (FuncInfo.Parameters.Count > 0) then
  begin
    for I := 0 to FuncInfo.Parameters.Count - 1 do
    begin
      if I > 0 then
        Result := Result + ', ';
      TJSParser.ParseParameterString(FuncInfo.Parameters[I], ParamName, ParamType, ParamDesc);
      Result := Result + EscapeHTML(ParamName);
      if ParamType <> '' then
        Result := Result + ': ' + EscapeHTML(ParamType);
    end;
  end;

  Result := Result + ')';

  if FuncInfo.ReturnType <> '' then
    Result := Result + ': <span class="function-type">' + EscapeHTML(FuncInfo.ReturnType) + '</span>';

  Result := Result + LineEnding + '  </div>' + LineEnding + '</div>' + LineEnding;

  // Description
  if FuncInfo.Description <> '' then
  begin
    // Extract main description (text before first @tag)
    Result := Result +
      '<div class="section">' + LineEnding +
      '  <h2 class="section-title">Description</h2>' + LineEnding +
      '  <p>' + EscapeHTML(TJSParser.ExtractDescriptionFromComment(FuncInfo.Description)) + '</p>' + LineEnding +
      '</div>' + LineEnding;
  end;

  // Parameters
  if Assigned(FuncInfo.Parameters) and (FuncInfo.Parameters.Count > 0) then
  begin
    Result := Result +
      '<div class="section">' + LineEnding +
      '  <h2 class="section-title">Parameters</h2>' + LineEnding +
      '  <table class="param-table">' + LineEnding +
      '    <tr>' + LineEnding +
      '      <th>Name</th>' + LineEnding +
      '      <th>Type</th>' + LineEnding +
      '      <th>Description</th>' + LineEnding +
      '    </tr>' + LineEnding;

    for I := 0 to FuncInfo.Parameters.Count - 1 do
    begin
      TJSParser.ParseParameterString(FuncInfo.Parameters[I], ParamName, ParamType, ParamDesc);

      // Get description from JSDoc if param string doesn't have it
      if ParamDesc = '' then
        ParamDesc := TJSParser.ExtractParamDescriptionFromComment(FuncInfo.Description, ParamName);

      Result := Result +
        '    <tr>' + LineEnding +
        '      <td class="param-name">' + EscapeHTML(ParamName) + '</td>' + LineEnding +
        '      <td class="param-type">' + EscapeHTML(ParamType) + '</td>' + LineEnding +
        '      <td>' + EscapeHTML(ParamDesc) + '</td>' + LineEnding +
        '    </tr>' + LineEnding;
    end;

    Result := Result +
      '  </table>' + LineEnding +
      '</div>' + LineEnding;
  end;

  // Return value
  if FuncInfo.ReturnType <> '' then
  begin
    ReturnDesc := TJSParser.ExtractReturnDescriptionFromComment(FuncInfo.Description);

    Result := Result +
      '<div class="section">' + LineEnding +
      '  <h2 class="section-title">Return Value</h2>' + LineEnding +
      '  <div class="info-card">' + LineEnding +
      '    <div><span class="info-label">Type:</span> ' +
      '<span class="param-type">' + EscapeHTML(FuncInfo.ReturnType) + '</span></div>' + LineEnding;

    if ReturnDesc <> '' then
      Result := Result + '    <div><span class="info-label">Description:</span> ' +
        EscapeHTML(ReturnDesc) + '</div>' + LineEnding;

    Result := Result +
      '  </div>' + LineEnding +
      '</div>' + LineEnding;
  end;

  // Examples (from @example tags)
  // TODO: Implement example extraction from JSDoc

  // Function calls
  if Assigned(FuncInfo.Calls) and (FuncInfo.Calls.Count > 0) then
  begin
    Result := Result +
      '<div class="section">' + LineEnding +
      '  <h2 class="section-title">Calls These Functions</h2>' + LineEnding +
      '  <ul>' + LineEnding;

    for I := 0 to FuncInfo.Calls.Count - 1 do
      Result := Result + '    <li>' + EscapeHTML(FuncInfo.Calls[I]) + '</li>' + LineEnding;

    Result := Result +
      '  </ul>' + LineEnding +
      '</div>' + LineEnding;
  end;

  // Called by
  if Assigned(FuncInfo.CalledBy) and (FuncInfo.CalledBy.Count > 0) then
  begin
    Result := Result +
      '<div class="section">' + LineEnding +
      '  <h2 class="section-title">Called By These Functions</h2>' + LineEnding +
      '  <ul>' + LineEnding;

    for I := 0 to FuncInfo.CalledBy.Count - 1 do
      Result := Result + '    <li>' + EscapeHTML(FuncInfo.CalledBy[I]) + '</li>' + LineEnding;

    Result := Result +
      '  </ul>' + LineEnding +
      '</div>' + LineEnding;
  end;

  Result := Result +
'</div>' + LineEnding +
'</body>' + LineEnding +
'</html>';

end;

function TJSDocHTMLFormatter.FormatFileAsHTML(const FileInfo: TJSFileInfo): String;
var
  I: Integer;
begin
  TDebugLogger.Info(' =========================================== ', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  TDebugLogger.Info('SaveFunctionDocumentation', {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});


  Result :=
    '<!DOCTYPE html>' + LineEnding +
    '<html lang="en">' + LineEnding +
    '<head>' + LineEnding +
    '  <meta charset="UTF-8">' + LineEnding +
    '  <meta name="viewport" content="width=device-width, initial-scale=1.0">' + LineEnding +
    '  <title>' + EscapeHTML(FileInfo.FileName) + ' - ' + EscapeHTML(FileInfo.FileDescription) + '</title>' + LineEnding +
    GenerateResourceLinks + LineEnding +
    '</head>' + LineEnding +
    '<body>' + LineEnding +
    '<div class="doc-container">' + LineEnding;

  Result := Result +
    '<div class="doc-header">' + LineEnding +
    '  <h1 class="doc-title">' + EscapeHTML(ExtractFileName(FileInfo.FilePath)) + '</h1>' + LineEnding +
    '  <p class="doc-subtitle">File Documentation</p>' + LineEnding +
    '</div>' + LineEnding;

  // File info
  Result := Result +
    '<div class="info-card">' + LineEnding +
    '  <div><span class="info-label">Path:</span> <span class="info-value">' +
    EscapeHTML(FileInfo.FilePath) + '</span></div>' + LineEnding +
    '  <div><span class="info-label">Functions:</span> <span class="info-value">' +
    IntToStr(Length(FileInfo.Functions)) + '</span></div>' + LineEnding +
    '  <div><span class="info-label">Global Variables:</span> <span class="info-value">' +
    IntToStr(Length(FileInfo.GlobalVars)) + '</span></div>' + LineEnding +
    '  <div><span class="info-label">Classes:</span> <span class="info-value">' +
    IntToStr(FileInfo.Classes.Count) + '</span></div>' + LineEnding +
    '</div>' + LineEnding;

  // File description
  if FileInfo.FileDescription <> '' then
  begin
    Result := Result +
      '<div class="section">' + LineEnding +
      '  <h2 class="section-title">Description</h2>' + LineEnding +
      '  <p>' + EscapeHTML(FileInfo.FileDescription) + '</p>' + LineEnding +
      '</div>' + LineEnding;
  end;

  // Imports
  if FileInfo.Imports.Count > 0 then
  begin
    Result := Result +
      '<div class="section">' + LineEnding +
      '  <h2 class="section-title">Imports</h2>' + LineEnding +
      '  <ul>' + LineEnding;

    for I := 0 to FileInfo.Imports.Count - 1 do
      Result := Result + '    <li>' + EscapeHTML(FileInfo.Imports[I]) + '</li>' + LineEnding;

    Result := Result +
      '  </ul>' + LineEnding +
      '</div>' + LineEnding;
  end;

  // Exports
  if FileInfo.ExportedItems.Count > 0 then
  begin
    Result := Result +
      '<div class="section">' + LineEnding +
      '  <h2 class="section-title">Exports</h2>' + LineEnding +
      '  <ul>' + LineEnding;

    for I := 0 to FileInfo.ExportedItems.Count - 1 do
      Result := Result + '    <li>' + EscapeHTML(FileInfo.ExportedItems[I]) + '</li>' + LineEnding;

    Result := Result +
      '  </ul>' + LineEnding +
      '</div>' + LineEnding;
  end;

  // Classes
  if FileInfo.Classes.Count > 0 then
  begin
    Result := Result +
      '<div class="section">' + LineEnding +
      '  <h2 class="section-title">Classes</h2>' + LineEnding +
      '  <ul>' + LineEnding;

    for I := 0 to FileInfo.Classes.Count - 1 do
      Result := Result + '    <li>' + EscapeHTML(FileInfo.Classes[I]) + '</li>' + LineEnding;

    Result := Result +
      '  </ul>' + LineEnding +
      '</div>' + LineEnding;
  end;

    Result := Result +
  '</div>' + LineEnding +
  '</body>' + LineEnding +
  '</html>';
end;

function TJSDocHTMLFormatter.FormatGlobalVarAsHTML(const GlobalVar: TJSGlobalVar;
  const FileName: String): String;
begin
  Result :=
    '<!DOCTYPE html>' + LineEnding +
    '<html lang="en">' + LineEnding +
    '<head>' + LineEnding +
    '  <meta charset="UTF-8">' + LineEnding +
    '  <meta name="viewport" content="width=device-width, initial-scale=1.0">' + LineEnding +
    '  <title>' + EscapeHTML(GlobalVar.Name) + ' - ' + EscapeHTML(FileName) + '</title>' + LineEnding +
    GenerateResourceLinks + LineEnding +
    '</head>' + LineEnding +
    '<body>' + LineEnding +
    '<div class="doc-container">' + LineEnding;

  Result := Result +
    '<div class="doc-header">' + LineEnding +
    '  <h1 class="doc-title">' + EscapeHTML(GlobalVar.Name) + '</h1>' + LineEnding +
    '  <p class="doc-subtitle">Global Variable</p>' + LineEnding +
    '</div>' + LineEnding;

  // Variable info
  Result := Result +
    '<div class="info-card">' + LineEnding +
    '  <div><span class="info-label">File:</span> <span class="info-value">' +
    EscapeHTML(FileName) + '</span></div>' + LineEnding;

  if FIncludeLineNumbers and (GlobalVar.Line > 0) then
    Result := Result +
      '  <div><span class="info-label">Line:</span> <span class="info-value">' +
      IntToStr(GlobalVar.Line) + '</span></div>' + LineEnding;

  Result := Result +
    '  <div><span class="info-label">Type:</span> <span class="info-value">' +
    EscapeHTML(GlobalVar.VarType) + '</span></div>' + LineEnding;

  if GlobalVar.Value <> '' then
    Result := Result +
      '  <div><span class="info-label">Value:</span> <span class="info-value">' +
      EscapeHTML(GlobalVar.Value) + '</span></div>' + LineEnding;

  Result := Result + '</div>' + LineEnding;

  // Description
  if GlobalVar.Description <> '' then
  begin
    Result := Result +
      '<div class="section">' + LineEnding +
      '  <h2 class="section-title">Description</h2>' + LineEnding +
      '  <p>' + EscapeHTML(GlobalVar.Description) + '</p>' + LineEnding +
      '</div>' + LineEnding;
  end;

  Result := Result +
'</div>' + LineEnding +
'</body>' + LineEnding +
'</html>';
end;

function TJSDocHTMLFormatter.FormatProjectSummaryAsHTML(const FilesInfo: array of TJSFileInfo): String;
var
  I, J, TotalFuncs, TotalGlobals, TotalClasses: Integer;
begin
  TotalFuncs := 0;
  TotalGlobals := 0;
  TotalClasses := 0;

  for I := 0 to High(FilesInfo) do
  begin
    TotalFuncs := TotalFuncs + Length(FilesInfo[I].Functions);
    TotalGlobals := TotalGlobals + Length(FilesInfo[I].GlobalVars);
    TotalClasses := TotalClasses + FilesInfo[I].Classes.Count;
  end;

  Result := '<div class="doc-container">' + LineEnding;

  Result := Result +
    '<div class="doc-header">' + LineEnding +
    '  <h1 class="doc-title">' + EscapeHTML(FProjectName) + '</h1>' + LineEnding +
    '  <p class="doc-subtitle">Version ' + EscapeHTML(FProjectVersion) +
    ' - JavaScript Documentation</p>' + LineEnding +
    '</div>' + LineEnding;

  // Project summary
  Result := Result +
    '<div class="info-card">' + LineEnding +
    '  <div><span class="info-label">Files Analyzed:</span> <span class="info-value">' +
    IntToStr(Length(FilesInfo)) + '</span></div>' + LineEnding +
    '  <div><span class="info-label">Total Functions:</span> <span class="info-value">' +
    IntToStr(TotalFuncs) + '</span></div>' + LineEnding +
    '  <div><span class="info-label">Total Global Variables:</span> <span class="info-value">' +
    IntToStr(TotalGlobals) + '</span></div>' + LineEnding +
    '  <div><span class="info-label">Total Classes:</span> <span class="info-value">' +
    IntToStr(TotalClasses) + '</span></div>' + LineEnding +
    '</div>' + LineEnding;

  // Files list
  Result := Result +
    '<div class="section">' + LineEnding +
    '  <h2 class="section-title">Files</h2>' + LineEnding +
    '  <table class="param-table">' + LineEnding +
    '    <tr>' + LineEnding +
    '      <th>File</th>' + LineEnding +
    '      <th>Functions</th>' + LineEnding +
    '      <th>Globals</th>' + LineEnding +
    '      <th>Classes</th>' + LineEnding +
    '    </tr>' + LineEnding;

  for I := 0 to High(FilesInfo) do
  begin
    Result := Result +
      '    <tr>' + LineEnding +
      '      <td>' + EscapeHTML(FilesInfo[I].FileName) + '</td>' + LineEnding +
      '      <td>' + IntToStr(Length(FilesInfo[I].Functions)) + '</td>' + LineEnding +
      '      <td>' + IntToStr(Length(FilesInfo[I].GlobalVars)) + '</td>' + LineEnding +
      '      <td>' + IntToStr(FilesInfo[I].Classes.Count) + '</td>' + LineEnding +
      '    </tr>' + LineEnding;
  end;

  Result := Result +
    '  </table>' + LineEnding +
    '</div>' + LineEnding;

  Result := Result + '</div>' + LineEnding;
end;

function TJSDocHTMLFormatter.GenerateProjectDocumentation(const FilesInfo: array of TJSFileInfo): String;
var
  I, J: Integer;
  HTML: TStringList;
begin
  HTML := TStringList.Create;
  try
    // Start HTML document
    HTML.Add('<!DOCTYPE html>');
    HTML.Add('<html lang="en">');
    HTML.Add('<head>');
    HTML.Add('  <meta charset="UTF-8">');
    HTML.Add('  <meta name="viewport" content="width=device-width, initial-scale=1.0">');
    HTML.Add('  <title>' + EscapeHTML(FProjectName) + ' - Documentation</title>');
    HTML.Add(GenerateCSS);
    HTML.Add('</head>');
    HTML.Add('<body>');

    // Add project summary
    HTML.Add(FormatProjectSummaryAsHTML(FilesInfo));

    // Add documentation for each file
    for I := 0 to High(FilesInfo) do
    begin
      HTML.Add(FormatFileAsHTML(FilesInfo[I]));

      // Add functions in this file
      for J := 0 to High(FilesInfo[I].Functions) do
        HTML.Add(FormatFunctionAsHTML(FilesInfo[I].Functions[J], FilesInfo[I].FileName, I));

      // Add global variables in this file
      for J := 0 to High(FilesInfo[I].GlobalVars) do
        HTML.Add(FormatGlobalVarAsHTML(FilesInfo[I].GlobalVars[J], FilesInfo[I].FileName));
    end;

    HTML.Add('</body>');
    HTML.Add('</html>');

    Result := HTML.Text;
  finally
    HTML.Free;
  end;
end;

end.
