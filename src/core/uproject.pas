unit uProject;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, fpjson, jsonparser, FileUtil, LazFileUtils,
  uFileUtils, uChunkProcessor,uDebugLog;

type
  TPublishMethod = (pmNone, pmIPFS, pmFTP, pmGitHub, pmNeutralino, pmLocal);

  TProjectConfig = class
  private
    FJSON: TJSONObject;
    procedure LoadDefaults; // ¡AGREGA ESTA DECLARACIÓN!
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadFromFile(const FileName: String);
    procedure SaveToFile(const FileName: String);

    // Getters y setters
    function GetProjectName: String;
    function GetProjectVersion: String;
    function GetTemplatePath: String;
    function GetWorkingPath: String;
    function GetOutputPath: String;
    function GetPublishMethod: TPublishMethod;
    function GetPublishConfig(const Key: String): String;

    procedure SetProjectName(const Value: String);
    procedure SetProjectVersion(const Value: String);
    procedure SetTemplatePath(const Value: String);
    procedure SetWorkingPath(const Value: String);
    procedure SetOutputPath(const Value: String);
    procedure SetPublishMethod(Value: TPublishMethod);
    procedure SetPublishConfig(const Key, Value: String);
  end;

  TETEditProject = class
  private
    FProjectFile: String;
    FConfig: TProjectConfig;
    FProjectPath: String;

    function GetProjectName: String;
    function GetTemplatePath: String;
    function GetWorkingPath: String;
    function GetOutputPath: String;

    procedure CreateDirectoryStructure(const BasePath: String);
    procedure CopyTemplateFiles(const TemplatePath, DestPath: String);
    procedure CreateSampleTemplate(const TemplatePath: String);
    procedure CreateDefaultFiles(const Path: String);

    procedure ProcessOutputFiles;
    function ProcessChunkFile(const ChunkPath, ChunkName: String): String;

  public
    constructor Create(const AProjectFile: String);
    destructor Destroy; override;

    // Creación y gestión de proyectos
    function NewProject(const ProjectName, BasePath: String): Boolean;
    function OpenProject(const ProjectFile: String): Boolean;
    function SaveProject: Boolean;
    function CreateSampleProject(const BasePath: String): Boolean;
    function CloseProject: Boolean;

    // Operaciones con archivos
    function AddFileToProject(const FilePath: String): Boolean;
    function RemoveFileFromProject(const FilePath: String): Boolean;
    function CompileProject: Boolean; // "Compila" el proyecto al directorio de salida
    function ShouldProcessFile(const FilePath: String): Boolean;
    // Propiedades
    property ProjectName: String read GetProjectName;
    property ProjectPath: String read FProjectPath;
    property ProjectFile: String read FProjectFile;
    property TemplatePath: String read GetTemplatePath;
    property WorkingPath: String read GetWorkingPath;
    property OutputPath: String read GetOutputPath;
    property Config: TProjectConfig read FConfig;
  end;

implementation
const
  // Estructura básica de directorios
  ProjectDirectories: array[0..31] of String = (
    'templates',
    'working',
    'output',
    'templates/docs/',
    'templates/docs/js',
    'templates/docs/css',
    'templates/docs/res/fonts',
    'templates/docs/res/images',
    'templates/docs/res/video',
    'templates/docs/res/audio',
    'templates/res/fonts',
    'templates/res/images',
    'templates/res/video',
    'templates/res/audio',
    'templates/data',
    'templates/styles',
    'templates/js',
    'templates/chunks',
    'working/res/fonts',
    'working/res/images',
    'working/res/video',
    'working/res/audio',
    'working/data',
    'working/styles',
    'working/js',
    'working/docs/',
    'working/docs/js',
    'working/docs/css',
    'working/docs/res/fonts',
    'working/docs/res/images',
    'working/docs/res/video',
    'working/docs/res/audio'
  );
  // Lista de archivos a copiar de templates a working
  const ProjectFiles: array of String = (
    'index.html',
    'README.md',
    'LICENSE'
  );

  // Archivos principales del proyecto
  ProjectMainFiles: array[0..2] of String = (
    'index.html',
    'README.md',
    'LICENSE'
  );

  // Archivos de configuración del proyecto
  ProjectConfigFiles: array[0..2] of String = (
    '.gitignore',
    '.editorconfig',
    '.etproj'
  );
{ TProjectConfig }

constructor TProjectConfig.Create;
begin
  FJSON := TJSONObject.Create;
  LoadDefaults;
end;

destructor TProjectConfig.Destroy;
begin
  FJSON.Free;
  inherited Destroy;
end;

// ¡IMPLEMENTA ESTE MÉTODO!
procedure TProjectConfig.LoadDefaults;
begin
  FJSON.Clear;

  FJSON.Add('project', TJSONObject.Create);
  with FJSON.Objects['project'] do
  begin
    Add('name', TJSONString.Create('NewProject'));
    Add('version', TJSONString.Create('1.0.0'));
    Add('created', TJSONString.Create(FormatDateTime('yyyy-mm-dd', Now)));
    Add('modified', TJSONString.Create(FormatDateTime('yyyy-mm-dd', Now)));
  end;

  FJSON.Add('paths', TJSONObject.Create);
  with FJSON.Objects['paths'] do
  begin
    Add('template', TJSONString.Create('templates'));
    Add('working', TJSONString.Create('working'));
    Add('output', TJSONString.Create('output'));
  end;

  FJSON.Add('publish', TJSONObject.Create);
  with FJSON.Objects['publish'] do
  begin
    Add('method', TJSONString.Create('none'));

    // Create config object with default FTP values
    Add('config', TJSONObject.Create);
    with Objects['config'] do
    begin
      Add('host', TJSONString.Create(''));
      Add('user', TJSONString.Create(''));
      Add('password', TJSONString.Create(''));
      Add('path', TJSONString.Create(''));
    end;
  end;

  FJSON.Add('files', TJSONArray.Create);
end;

procedure TProjectConfig.LoadFromFile(const FileName: String);
var
  FileStream: TFileStream;
  Parser: TJSONParser;
  FileContent: TStringList;
begin
  if FileExists(FileName) then
  begin
    try
      // Método alternativo: leer como texto y luego parsear
      FileContent := TStringList.Create;
      try
        FileContent.LoadFromFile(FileName);
        Parser := TJSONParser.Create(FileContent.Text, True); // True = usar UTF8
        try
          FJSON.Free;
          FJSON := Parser.Parse as TJSONObject;
        finally
          Parser.Free;
        end;
      finally
        FileContent.Free;
      end;
    except
      on E: Exception do
      begin
        ShowMessage('Error loading project config: ' + E.Message);
        LoadDefaults;
      end;
    end;
  end
  else
  begin
    LoadDefaults;
  end;
end;

procedure TProjectConfig.SaveToFile(const FileName: String);
var
  FileStream: TFileStream;
  ConfigText: String;
begin
  try
    ConfigText := FJSON.FormatJSON([foUseTabchar], 2);
    FileStream := TFileStream.Create(FileName, fmCreate);
    try
      if ConfigText <> '' then
        FileStream.WriteBuffer(ConfigText[1], Length(ConfigText));
    finally
      FileStream.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Error saving config: ' + E.Message);
  end;
end;

// Getters
function TProjectConfig.GetProjectName: String;
begin
  Result := FJSON.GetPath('project.name').AsString;
end;

function TProjectConfig.GetProjectVersion: String;
begin
  Result := FJSON.GetPath('project.version').AsString;
end;

function TProjectConfig.GetTemplatePath: String;
begin
  Result := FJSON.GetPath('paths.template').AsString;
end;

function TProjectConfig.GetWorkingPath: String;
begin
  Result := FJSON.GetPath('paths.working').AsString;
end;

function TProjectConfig.GetOutputPath: String;
begin
  Result := FJSON.GetPath('paths.output').AsString;
end;

function TProjectConfig.GetPublishMethod: TPublishMethod;
var
  Data: TJSONData;
  MethodStr: String;
begin
  Result := pmNone;

  Data := FJSON.FindPath('publish.method');
  if (Data <> nil) and (Data.JSONType = jtString) then
  begin
    MethodStr := LowerCase(Data.AsString);
    if MethodStr = 'ipfs' then Result := pmIPFS
    else if MethodStr = 'ftp' then Result := pmFTP
    else if MethodStr = 'github' then Result := pmGitHub
    else if MethodStr = 'neutralino' then Result := pmNeutralino
    else if MethodStr = 'local' then Result := pmLocal;
  end;
end;

function TProjectConfig.GetPublishConfig(const Key: String): String;
var
  ConfigObj: TJSONObject;
  Data: TJSONData;
begin
  Result := '';

  // Get the publish object
  Data := FJSON.Find('publish');
  if (Data <> nil) and (Data.JSONType = jtObject) then
  begin
    // Get the config object
    ConfigObj := TJSONObject(Data).Objects['config'];
    if ConfigObj <> nil then
    begin
      Data := ConfigObj.Find(Key);
      if (Data <> nil) and (Data.JSONType = jtString) then
        Result := Data.AsString;
    end;
  end;
end;

// Setters
procedure TProjectConfig.SetProjectName(const Value: String);
begin
  FJSON.GetPath('project.name').AsString := Value;
end;

procedure TProjectConfig.SetProjectVersion(const Value: String);
begin
  FJSON.GetPath('project.version').AsString := Value;
end;

procedure TProjectConfig.SetTemplatePath(const Value: String);
begin
  FJSON.GetPath('paths.template').AsString := Value;
end;

procedure TProjectConfig.SetWorkingPath(const Value: String);
begin
  FJSON.GetPath('paths.working').AsString := Value;
end;

procedure TProjectConfig.SetOutputPath(const Value: String);
begin
  FJSON.GetPath('paths.output').AsString := Value;
end;

procedure TProjectConfig.SetPublishMethod(Value: TPublishMethod);
var
  MethodStr: String;
begin
  case Value of
    pmIPFS: MethodStr := 'ipfs';
    pmFTP: MethodStr := 'ftp';
    pmGitHub: MethodStr := 'github';
    pmNeutralino: MethodStr := 'neutralino';
    pmLocal: MethodStr := 'local';
  else
    MethodStr := 'none';
  end;
  FJSON.GetPath('publish.method').AsString := MethodStr;
end;

procedure TProjectConfig.SetPublishConfig(const Key, Value: String);
var
  PublishObj, ConfigObj: TJSONObject;
  Data: TJSONData;
begin
  // Get or create publish object
  Data := FJSON.Find('publish');
  if (Data = nil) or (Data.JSONType <> jtObject) then
  begin
    PublishObj := TJSONObject.Create;
    FJSON.Add('publish', PublishObj);
  end
  else
  begin
    PublishObj := TJSONObject(Data);
  end;

  // Get or create config object
  Data := PublishObj.Find('config');
  if (Data = nil) or (Data.JSONType <> jtObject) then
  begin
    ConfigObj := TJSONObject.Create;
    PublishObj.Add('config', ConfigObj);
  end
  else
  begin
    ConfigObj := TJSONObject(Data);
  end;

  // Set the value
  ConfigObj.Delete(Key); // Remove if exists
  ConfigObj.Add(Key, TJSONString.Create(Value));
end;

{ TETEditProject }

constructor TETEditProject.Create(const AProjectFile: String);
begin
  FConfig := TProjectConfig.Create;
  FProjectFile := AProjectFile;

  if AProjectFile <> '' then
  begin
    FProjectPath := ExtractFilePath(AProjectFile);
    FConfig.LoadFromFile(AProjectFile);
  end
  else
  begin
    FProjectPath := '';
  end;
end;

destructor TETEditProject.Destroy;
begin
  FConfig.Free;
  inherited Destroy;
end;

function TETEditProject.GetProjectName: String;
begin
  Result := FConfig.GetProjectName;
end;

function TETEditProject.GetTemplatePath: String;
begin
  Result := IncludeTrailingPathDelimiter(FProjectPath) + FConfig.GetTemplatePath;
end;

function TETEditProject.GetWorkingPath: String;
begin
  Result := IncludeTrailingPathDelimiter(FProjectPath) + FConfig.GetWorkingPath;
end;

function TETEditProject.GetOutputPath: String;
begin
  Result := IncludeTrailingPathDelimiter(FProjectPath) + FConfig.GetOutputPath;
end;

procedure TETEditProject.CreateDirectoryStructure(const BasePath: String);
begin
  // Usar CreateProjectStructure de uFileUtils
  if not CreateProjectStructure(BasePath, ProjectDirectories) then
  begin
    raise Exception.Create('Failed to create project directory structure');
  end;
end;

procedure TETEditProject.CopyTemplateFiles(const TemplatePath, DestPath: String);
begin
  // Usar CopyDirectory de uFileUtils
  if not CopyDirectory(TemplatePath, DestPath, True, '*.*') then
  begin
    raise Exception.Create('Failed to copy template files');
  end;
end;

procedure TETEditProject.CreateSampleTemplate(const TemplatePath: String);
var
  SL: TStringList;
  TemplateDir: String;
begin
  SL := TStringList.Create;
  try
    TemplateDir := IncludeTrailingPathDelimiter(TemplatePath);

    // 1. index.html
    SL.Text :=
      '<!DOCTYPE html>' + LineEnding +
      '<html lang="es">' + LineEnding +
      '<head>' + LineEnding +
      '    <meta charset="UTF-8">' + LineEnding +
      '    <meta name="viewport" content="width=device-width, initial-scale=1.0">' + LineEnding +
      '    <title>{{PROJECT_NAME}}</title>' + LineEnding +
      '    <link rel="stylesheet" href="styles/main.css">' + LineEnding +
      '</head>' + LineEnding +
      '<body>' + LineEnding +
      '    <header>' + LineEnding +
      '        <h1>{{PROJECT_NAME}}</h1>' + LineEnding +
      '        <p>{{PROJECT_DESCRIPTION}}</p>' + LineEnding +
      '    </header>' + LineEnding +
      '    ' + LineEnding +
      '    <main>' + LineEnding +
      '        <!-- Los chunks se insertarán aquí -->' + LineEnding +
      '        <div id="content"></div>' + LineEnding +
      '    </main>' + LineEnding +
      '    ' + LineEnding +
      '    <footer>' + LineEnding +
      '        <p>&copy; ' + FormatDateTime('yyyy', Now) + ' {{PROJECT_NAME}}. Todos los derechos reservados.</p>' + LineEnding +
      '    </footer>' + LineEnding +
      '    ' + LineEnding +
      '    <script src="js/main.js"></script>' + LineEnding +
      '</body>' + LineEnding +
      '</html>';
    SL.SaveToFile(TemplateDir + 'index.html');

    // 2. README.md
    SL.Text :=
      '# {{PROJECT_NAME}}' + LineEnding +
      '' + LineEnding +
      '{{PROJECT_DESCRIPTION}}' + LineEnding +
      '' + LineEnding +
      '## Estructura del proyecto' + LineEnding +
      '' + LineEnding +
      '- `templates/` - Plantillas y recursos base' + LineEnding +
      '  - `res/` - Recursos (fuentes, imágenes, etc.)' + LineEnding +
      '  - `data/` - Datos en JSON, CSV o XML' + LineEnding +
      '  - `styles/` - Hojas de estilo CSS' + LineEnding +
      '  - `js/` - Scripts JavaScript' + LineEnding +
      '  - `chunks/` - Fragmentos HTML reutilizables' + LineEnding +
      '- `working/` - Directorio de trabajo editable' + LineEnding +
      '- `output/` - Directorio de salida (solo lectura)' + LineEnding +
      '' + LineEnding +
      '## Uso' + LineEnding +
      '' + LineEnding +
      '1. Edita los archivos en el directorio `working/`' + LineEnding +
      '2. Usa los chunks desde `templates/chunks/`' + LineEnding +
      '3. Compila el proyecto para generar el output' + LineEnding;
    SL.SaveToFile(TemplateDir + 'README.md');

    // 3. LICENSE (MIT por defecto)
    SL.Text :=
      'MIT License' + LineEnding +
      '' + LineEnding +
      'Copyright (c) ' + FormatDateTime('yyyy', Now) + ' {{PROJECT_NAME}}' + LineEnding +
      '' + LineEnding +
      'Se concede permiso, libre de cargos, a cualquier persona que obtenga una copia' + LineEnding +
      'de este software y de los archivos de documentación asociados (el "Software"),' + LineEnding +
      'a utilizar el Software sin restricción, incluyendo sin limitación los derechos' + LineEnding +
      'a usar, copiar, modificar, fusionar, publicar, distribuir, sublicenciar, y/o vender' + LineEnding +
      'copias del Software, y a permitir a las personas a las que se les proporcione el Software' + LineEnding +
      'a hacer lo mismo, sujeto a las siguientes condiciones:' + LineEnding +
      '' + LineEnding +
      'El aviso de copyright anterior y este aviso de permiso se incluirán en todas' + LineEnding +
      'las copias o partes sustanciales del Software.' + LineEnding +
      '' + LineEnding +
      'EL SOFTWARE SE PROPORCIONA "COMO ESTÁ", SIN GARANTÍA DE NINGÚN TIPO,' + LineEnding +
      'EXPRESA O IMPLÍCITA, INCLUYENDO PERO NO LIMITADO A GARANTÍAS DE COMERCIALIZACIÓN,' + LineEnding +
      'IDONEIDAD PARA UN PROPÓSITO PARTICULAR Y NO INFRACCIÓN. EN NINGÚN CASO LOS' + LineEnding +
      'AUTORES O TITULARES DEL COPYRIGHT SERÁN RESPONSABLES DE NINGUNA RECLAMACIÓN,' + LineEnding +
      'DAÑOS U OTRAS RESPONSABILIDADES, YA SEA EN UNA ACCIÓN DE CONTRATO, AGRAVIO O CUALQUIER' + LineEnding +
      'OTRO MOTIVO, QUE SURJA DE O EN CONEXIÓN CON EL SOFTWARE O EL USO U OTRO TIPO DE' + LineEnding +
      'ACCIONES EN EL SOFTWARE.' + LineEnding;
    SL.SaveToFile(TemplateDir + 'LICENSE');

    // 4. CSS básico
    SL.Text :=
      '/* Estilos principales para {{PROJECT_NAME}} */' + LineEnding +
      '' + LineEnding +
      '* {' + LineEnding +
      '    margin: 0;' + LineEnding +
      '    padding: 0;' + LineEnding +
      '    box-sizing: border-box;' + LineEnding +
      '}' + LineEnding +
      '' + LineEnding +
      'body {' + LineEnding +
      '    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;' + LineEnding +
      '    line-height: 1.6;' + LineEnding +
      '    color: #333;' + LineEnding +
      '    background-color: #f9f9f9;' + LineEnding +
      '}' + LineEnding +
      '' + LineEnding +
      'header {' + LineEnding +
      '    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);' + LineEnding +
      '    color: white;' + LineEnding +
      '    padding: 2rem;' + LineEnding +
      '    text-align: center;' + LineEnding +
      '}' + LineEnding +
      '' + LineEnding +
      'main {' + LineEnding +
      '    max-width: 1200px;' + LineEnding +
      '    margin: 2rem auto;' + LineEnding +
      '    padding: 0 1rem;' + LineEnding +
      '}' + LineEnding +
      '' + LineEnding +
      'footer {' + LineEnding +
      '    text-align: center;' + LineEnding +
      '    padding: 1rem;' + LineEnding +
      '    background: #333;' + LineEnding +
      '    color: white;' + LineEnding +
      '    margin-top: 2rem;' + LineEnding +
      '}' + LineEnding;
    SL.SaveToFile(TemplateDir + 'styles' + PathDelim + 'main.css');

    // 5. JavaScript básico
    SL.Text :=
      '// Script principal para {{PROJECT_NAME}}' + LineEnding +
      '' + LineEnding +
      'document.addEventListener("DOMContentLoaded", function() {' + LineEnding +
      '    console.log("{{PROJECT_NAME}} cargado");' + LineEnding +
      '    ' + LineEnding +
      '    // Cargar chunks dinámicamente' + LineEnding +
      '    loadChunks();' + LineEnding +
      '});' + LineEnding +
      '' + LineEnding +
      'async function loadChunks() {' + LineEnding +
      '    try {' + LineEnding +
      '        const response = await fetch("data/chunks.json");' + LineEnding +
      '        const chunks = await response.json();' + LineEnding +
      '        ' + LineEnding +
      '        const contentDiv = document.getElementById("content");' + LineEnding +
      '        if (contentDiv && chunks.length > 0) {' + LineEnding +
      '            contentDiv.innerHTML = chunks.join("");' + LineEnding +
      '        }' + LineEnding +
      '    } catch (error) {' + LineEnding +
      '        console.error("Error cargando chunks:", error);' + LineEnding +
      '    }' + LineEnding +
      '}' + LineEnding;
    SL.SaveToFile(TemplateDir + 'js' + PathDelim + 'main.js');

    // 6. Ejemplo de chunk
    SL.Text :=
      '<section class="feature">' + LineEnding +
      '    <h2>Característica Principal</h2>' + LineEnding +
      '    <p>Este es un ejemplo de chunk que puede ser reutilizado en diferentes páginas.</p>' + LineEnding +
      '    <button class="btn-primary">Acción</button>' + LineEnding +
      '</section>' + LineEnding;
    SL.SaveToFile(TemplateDir + 'chunks' + PathDelim + 'feature.tpl');

    // 7. Datos de ejemplo
    SL.Text :=
      '{' + LineEnding +
      '    "project": {' + LineEnding +
      '        "name": "{{PROJECT_NAME}}",' + LineEnding +
      '        "description": "{{PROJECT_DESCRIPTION}}",' + LineEnding +
      '        "version": "1.0.0"' + LineEnding +
      '    },' + LineEnding +
      '    "chunks": [' + LineEnding +
      '        "<section><h2>Bienvenido</h2><p>Este contenido se carga dinámicamente.</p></section>"' + LineEnding +
      '    ]' + LineEnding +
      '}' + LineEnding;
    SL.SaveToFile(TemplateDir + 'data' + PathDelim + 'project.json');

  finally
    SL.Free;
  end;
end;

procedure TETEditProject.CreateDefaultFiles(const Path: String);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    // Archivo .gitignore
    SL.Text :=
      '# Directorios del proyecto' + LineEnding +
      '/output/' + LineEnding +
      '*.etproj' + LineEnding +
      '' + LineEnding +
      '# Archivos temporales' + LineEnding +
      '*.tmp' + LineEnding +
      '*.bak' + LineEnding +
      '*.swp' + LineEnding +
      '' + LineEnding +
      '# Sistema' + LineEnding +
      '.DS_Store' + LineEnding +
      'Thumbs.db' + LineEnding;
    SL.SaveToFile(Path + '.gitignore');

    // Archivo .editorconfig
    SL.Text :=
      'root = true' + LineEnding +
      '' + LineEnding +
      '[*]' + LineEnding +
      'charset = utf-8' + LineEnding +
      'end_of_line = lf' + LineEnding +
      'insert_final_newline = true' + LineEnding +
      'trim_trailing_whitespace = true' + LineEnding +
      '' + LineEnding +
      '[*.{html,htm}]' + LineEnding +
      'indent_style = space' + LineEnding +
      'indent_size = 4' + LineEnding +
      '' + LineEnding +
      '[*.{css,scss,less}]' + LineEnding +
      'indent_style = space' + LineEnding +
      'indent_size = 2' + LineEnding +
      '' + LineEnding +
      '[*.{js,json}]' + LineEnding +
      'indent_style = space' + LineEnding +
      'indent_size = 2' + LineEnding +
      '' + LineEnding +
      '[*.md]' + LineEnding +
      'trim_trailing_whitespace = false' + LineEnding;
    SL.SaveToFile(Path + '.editorconfig');

  finally
    SL.Free;
  end;
end;

function TETEditProject.NewProject(const ProjectName, BasePath: String): Boolean;
begin
  Result := False;
  try
    FProjectPath := EnsurePathDelimiter(BasePath) + ProjectName + PathDelim;
    FProjectFile := FProjectPath + ProjectName + '.etproj';

    // Configurar proyecto
    FConfig.SetProjectName(ProjectName);
    FConfig.SetProjectVersion('1.0.0');

    // Crear estructura de directorios
    CreateDirectoryStructure(FProjectPath);

    // Crear plantilla de ejemplo
    CreateSampleTemplate(TemplatePath);

    // Copiar archivos principales usando CopyProjectFiles
    if not CopyProjectFiles(TemplatePath, WorkingPath, ProjectFiles) then
    begin
      ShowMessage('Warning: Some project files could not be copied');
    end;

    // Copiar directorios
    CopyTemplateFiles(
      EnsurePathDelimiter(TemplatePath) + 'res',
      EnsurePathDelimiter(WorkingPath) + 'res'
    );

    CopyTemplateFiles(
      EnsurePathDelimiter(TemplatePath) + 'data',
      EnsurePathDelimiter(WorkingPath) + 'data'
    );

    CopyTemplateFiles(
      EnsurePathDelimiter(TemplatePath) + 'styles',
      EnsurePathDelimiter(WorkingPath) + 'styles'
    );

    CopyTemplateFiles(
      EnsurePathDelimiter(TemplatePath) + 'js',
      EnsurePathDelimiter(WorkingPath) + 'js'
    );

    // Crear archivos por defecto
    CreateDefaultFiles(FProjectPath);

    // Guardar configuración del proyecto
    SaveProject;

    Result := True;

  except
    on E: Exception do
    begin
      ShowMessage('Error creando proyecto: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TETEditProject.OpenProject(const ProjectFile: String): Boolean;
begin
  Result := False;
  try
    if not FileExists(ProjectFile) then
      Exit;

    FProjectFile := ProjectFile;
    FProjectPath := ExtractFilePath(ProjectFile);

    // Cargar configuración
    FConfig.LoadFromFile(ProjectFile);

    // Verificar que existan los directorios necesarios
    if not DirectoryExists(TemplatePath) or
       not DirectoryExists(WorkingPath) or
       not DirectoryExists(OutputPath) then
    begin
      ShowMessage('Estructura del proyecto incompleta. Se recrearán los directorios.');
      CreateDirectoryStructure(FProjectPath);
    end;

    Result := True;

  except
    on E: Exception do
    begin
      ShowMessage('Error abriendo proyecto: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TETEditProject.SaveProject: Boolean;
begin
  Result := False;
  try
    if FProjectFile <> '' then
    begin
      // Actualizar fecha de modificación
      FConfig.FJSON.GetPath('project.modified').AsString :=
        FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);

      // Guardar configuración
      FConfig.SaveToFile(FProjectFile);
      Result := True;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Error guardando proyecto: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TETEditProject.CreateSampleProject(const BasePath: String): Boolean;
begin
  Result := NewProject('SampleProject', BasePath);
end;

function TETEditProject.CloseProject: Boolean;
begin
  Result := SaveProject;
  FProjectFile := '';
  FProjectPath := '';
  FConfig.LoadDefaults;
end;

function TETEditProject.AddFileToProject(const FilePath: String): Boolean;
var
  FilesArray: TJSONArray;
  RelPath: String;
begin
  Result := False;
  try
    // Obtener ruta relativa al proyecto
    RelPath := ExtractRelativePath(FProjectPath, FilePath);

    // Agregar a la lista de archivos en la configuración
    FilesArray := FConfig.FJSON.Arrays['files'];
    FilesArray.Add(RelPath);

    Result := True;
  except
    on E: Exception do
    begin
      ShowMessage('Error agregando archivo al proyecto: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TETEditProject.RemoveFileFromProject(const FilePath: String): Boolean;
var
  FilesArray: TJSONArray;
  RelPath: String;
  I: Integer;
begin
  Result := False;
  try
    RelPath := ExtractRelativePath(FProjectPath, FilePath);
    FilesArray := FConfig.FJSON.Arrays['files'];

    for I := 0 to FilesArray.Count - 1 do
    begin
      if FilesArray.Strings[I] = RelPath then
      begin
        FilesArray.Delete(I);
        Result := True;
        Break;
      end;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Error removiendo archivo del proyecto: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TETEditProject.CompileProject: Boolean;
var
  Operations: TFileCopyOperations;
  OperationCount: Integer;
  SearchRec: TSearchRec;
  SourceFile, DestFile: String;
  ErrorMsg: String;
  TemplateDir, OutputDir: String;
begin
  Result := False;

  try
    WriteLn('=== Starting project compilation ===');
    WriteLn('Project: ', FConfig.GetProjectName);
    WriteLn('Working dir: ', WorkingPath);
    WriteLn('Output dir: ', OutputPath);
    WriteLn('Template dir: ', TemplatePath);

    // Limpiar directorio de output
    if DirectoryExists(OutputPath) then
    begin
      WriteLn('Cleaning output directory...');
      DeleteDirectory(OutputPath, False);
    end;

    ForceDirectories(OutputPath);

    // Recolectar operaciones de copia
    WriteLn('Collecting files to copy...');
    OperationCount := 0;
    SetLength(Operations, 100); // Tamaño inicial

    // Copiar todo de working a output
    if FindFirst(EnsurePathDelimiter(WorkingPath) + '*', faAnyFile, SearchRec) = 0 then
    begin
      try
        repeat
          if (SearchRec.Name = '.') or (SearchRec.Name = '..') then
            Continue;

          SourceFile := EnsurePathDelimiter(WorkingPath) + SearchRec.Name;
          DestFile := EnsurePathDelimiter(OutputPath) + SearchRec.Name;

          if OperationCount >= Length(Operations) then
            SetLength(Operations, Length(Operations) + 100);

          Operations[OperationCount].Source := SourceFile;
          Operations[OperationCount].Destination := DestFile;
          Operations[OperationCount].Overwrite := True;
          Operations[OperationCount].Recursive := (SearchRec.Attr and faDirectory) <> 0;

          Inc(OperationCount);
          WriteLn('  Adding: ', SearchRec.Name);
        until FindNext(SearchRec) <> 0;
      finally
        FindClose(SearchRec);
      end;
    end;

    // Añadir archivos de templates que no están en working
    TemplateDir := EnsurePathDelimiter(TemplatePath);
    OutputDir := EnsurePathDelimiter(OutputPath);

    // index.html desde templates (reemplaza el de working si existe)
    Operations[OperationCount].Source := TemplateDir + 'index.html';
    Operations[OperationCount].Destination := OutputDir + 'index.html';
    Operations[OperationCount].Overwrite := True;
    Operations[OperationCount].Recursive := False;
    Inc(OperationCount);

    // README.md y LICENSE si existen
    // index.html desde working (no desde templates)
    if FileExists(EnsurePathDelimiter(WorkingPath) + 'index.html') then
    begin
      Operations[OperationCount].Source := EnsurePathDelimiter(WorkingPath) + 'index.html';
      Operations[OperationCount].Destination := OutputDir + 'index.html';
      Operations[OperationCount].Overwrite := True;
      Operations[OperationCount].Recursive := False;
      Inc(OperationCount);
    end
    else if FileExists(TemplateDir + 'index.html') then
    begin
      // Fallback to template if working version doesn't exist
      Operations[OperationCount].Source := TemplateDir + 'index.html';
      Operations[OperationCount].Destination := OutputDir + 'index.html';
      Operations[OperationCount].Overwrite := True;
      Operations[OperationCount].Recursive := False;
      Inc(OperationCount);
    end;

    // README.md desde working
    if FileExists(EnsurePathDelimiter(WorkingPath) + 'README.md') then
    begin
      Operations[OperationCount].Source := EnsurePathDelimiter(WorkingPath) + 'README.md';
      Operations[OperationCount].Destination := OutputDir + 'README.md';
      Operations[OperationCount].Overwrite := True;
      Operations[OperationCount].Recursive := False;
      Inc(OperationCount);
    end
    else if FileExists(TemplateDir + 'README.md') then
    begin
      // Fallback to template
      Operations[OperationCount].Source := TemplateDir + 'README.md';
      Operations[OperationCount].Destination := OutputDir + 'README.md';
      Operations[OperationCount].Overwrite := True;
      Operations[OperationCount].Recursive := False;
      Inc(OperationCount);
    end;

    // LICENSE desde working
    if FileExists(EnsurePathDelimiter(WorkingPath) + 'LICENSE') then
    begin
      Operations[OperationCount].Source := EnsurePathDelimiter(WorkingPath) + 'LICENSE';
      Operations[OperationCount].Destination := OutputDir + 'LICENSE';
      Operations[OperationCount].Overwrite := True;
      Operations[OperationCount].Recursive := False;
      Inc(OperationCount);
    end
    else if FileExists(TemplateDir + 'LICENSE') then
    begin
      // Fallback to template
      Operations[OperationCount].Source := TemplateDir + 'LICENSE';
      Operations[OperationCount].Destination := OutputDir + 'LICENSE';
      Operations[OperationCount].Overwrite := True;
      Operations[OperationCount].Recursive := False;
      Inc(OperationCount);
    end;
    // Ajustar tamaño
    SetLength(Operations, OperationCount);

    WriteLn('Copying ', OperationCount, ' files/directories...');

    // Ejecutar todas las copias
    if not CopyFiles(Operations, ErrorMsg) then
    begin
      ShowMessage('Error copying files: ' + ErrorMsg);
      WriteLn('Copy errors: ', ErrorMsg);
      Exit;
    end;

    WriteLn('Files copied successfully');

    // Procesar archivos HTML para incluir chunks y variables
    WriteLn('Processing HTML files...');
    ProcessOutputFiles;

    WriteLn('=== Project compilation completed ===');
    Result := True;

  except
    on E: Exception do
    begin
      WriteLn('COMPILATION ERROR: ', E.Message);
      ShowMessage('Error compiling project: ' + E.Message);
      Result := False;
    end;
  end;
end;

function EnsurePathDelimiter(const Path: String): String;
begin
  Result := Path;
  if (Result <> '') and (Result[Length(Result)] <> PathDelim) then
    Result := Result + PathDelim;
end;

function TETEditProject.ProcessChunkFile(const ChunkPath, ChunkName: String): String;
var
  FullPath: String;
  SL: TStringList;
begin
  Result := '';

  // Construir path completo al chunk
  FullPath := EnsurePathDelimiter(TemplatePath) + 'chunks' + PathDelim + ChunkName;

  // Asegurar extensión .tpl si no la tiene
  if ExtractFileExt(ChunkName) = '' then
    FullPath := FullPath + '.tpl';

  if FileExists(FullPath) then
  begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile(FullPath);

      // Reemplazar variables dentro del chunk
      Result := SL.Text;
    finally
      SL.Free;
    end;
  end
  else
  begin
    TDebugLogger.InfoFmt('Chunk not found: %s',[ChunkName], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
  end;
end;

procedure TETEditProject.ProcessOutputFiles;
var
  Processor: TChunkProcessor;
  ProcessedCount: Integer;
  procedure ProcessDirectory(const DirPath: String);
  var
    SearchRec: TSearchRec;
    FilePath: String;
  begin
    // Process all files in current directory
    if FindFirst(EnsurePathDelimiter(DirPath) + '*', faAnyFile, SearchRec) = 0 then
    begin
      try
        repeat
          if (SearchRec.Name = '.') or (SearchRec.Name = '..') then
            Continue;

          FilePath := EnsurePathDelimiter(DirPath) + SearchRec.Name;

          if (SearchRec.Attr and faDirectory) <> 0 then
          begin
            // Recursively process subdirectories
            ProcessDirectory(FilePath);
          end
          else
          begin
            // Check if file should be processed based on extension
            if ShouldProcessFile(FilePath) then
            begin
              if Processor.ProcessFile(FilePath) then
              begin
                Inc(ProcessedCount);
                TDebugLogger.InfoFmt('Processed: %s',[ExtractRelativePath(OutputPath, FilePath)], {$I %CURRENTROUTINE%}, {$I %FILE%}, {$I %lineNum%});
              end;
            end;
          end;
        until FindNext(SearchRec) <> 0;
      finally
        FindClose(SearchRec);
      end;
    end;
  end;

begin
  ProcessedCount := 0;

  // Crear procesador de chunks
  Processor := TChunkProcessor.Create(EnsurePathDelimiter(TemplatePath) + 'chunks');
  try
    // Agregar variables del proyecto
    Processor.AddVariable('PROJECT_NAME', FConfig.GetProjectName);
    Processor.AddVariable('PROJECT_VERSION', FConfig.GetProjectVersion);
    Processor.AddVariable('PROJECT_DESCRIPTION', 'Proyecto web estático creado con ETEdit');
    Processor.AddVariable('STYLES_PATH', 'styles/');
    Processor.AddVariable('SCRIPTS_PATH', 'js/');
    Processor.AddVariable('IMAGES_PATH', 'res/images/');
    Processor.AddVariable('FONTS_PATH', 'res/fonts/');
    Processor.AddVariable('VIDEO_PATH', 'res/video/');
    Processor.AddVariable('AUDIO_PATH', 'res/audio/');
    Processor.AddVariable('DATA_PATH', 'data/');

    // Add path variables relative to output directory
    Processor.AddVariable('ROOT_PATH', './');

//    WriteLn('Processing chunks in output directory...');

    // Process all files recursively
    ProcessDirectory(OutputPath);

//    WriteLn('Processed ', ProcessedCount, ' files with chunks');

  finally
    Processor.Free;
  end;
end;
// Implementation:
function TETEditProject.ShouldProcessFile(const FilePath: String): Boolean;
var
  Ext: String;
begin
  Ext := LowerCase(ExtractFileExt(FilePath));
  // Process HTML files and any other text files that might contain chunks
  Result := (Ext = '.html') or (Ext = '.htm') or
            (Ext = '.xhtml') or (Ext = '.php') or
            (Ext = '.asp') or (Ext = '.aspx') or
            (Ext = '.jsp') or (Ext = '.tpl') or
            (Ext = '.txt') or (Ext = '.md') or
            (Ext = '.xml') or (Ext = '.svg');
  // You could also check file content to be more precise
end;

end.
