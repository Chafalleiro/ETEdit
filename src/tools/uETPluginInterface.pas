unit uETPluginInterface;

{$mode objfpc}{$H+}

interface

uses
  Classes,ComCtrls , SysUtils, Forms, Menus, ActnList;

type
  IETPlugin = interface
    ['{8E6F3D2A-4B5C-4E7F-9A1B-2C3D4E5F6A7B}']
    function GetName: string;
    function GetDescription: string;
    function GetVersion: string;
    function Initialize(MainForm: TForm): Boolean;
    procedure Finalize;
    procedure RegisterMenuItems(MainMenu: TMainMenu);
    procedure RegisterToolbarButtons(Toolbar: TToolBar; ActionList: TActionList);
//    function GetFileExtensions: TStrings;
    function GetFileExtensions: string;   // antes: TStrings
    function CreateDockablePanel: TForm;
    function HandleFile(const FileName: string): Boolean;
  end;

  TGetPluginFunction = function: IETPlugin;

implementation

end.
