unit uVisualPlugin;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType;

type
  // Funciones que debe exportar un plugin visual
  TGetPluginName = function: PChar; stdcall;
  TGetFileExtensions = function: PChar; stdcall;  // lista separada por comas, ej: ".arrow,.mission"
  TLoadPlugin = procedure(ParentWindow, ParentControl: HWND); stdcall;
  TUnloadPlugin = procedure; stdcall;
  TPluginPosition = procedure(X, Y, W, H: Integer); stdcall;
  TOpenFile = procedure(FileName: PChar); stdcall;
  // Opcional: TCloseFile, TGetStatus, etc.

implementation

end.