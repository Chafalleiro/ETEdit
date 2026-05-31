unit uNonVisualPlugin;

{$mode objfpc}{$H+}

interface

type
  TGetPluginName = function: PChar; stdcall;
  TGetFileExtensions = function: PChar; stdcall;
  TProcessFile = function(FileName: PChar): Integer; stdcall;  // 0 = éxito, otro = error

implementation

end.