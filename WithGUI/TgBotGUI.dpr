program TgBotGUI;

uses
  System.StartUpCopy,
  FMX.Forms,
  TgBotGui.Main in 'TgBotGui.Main.pas' {Form4},
  TgBotApi.Client in '..\TgBotApi.Client.pas',
  TgBotApi in '..\TgBotApi.pas',
  HGM.ArrayHelpers in '..\ArrayHelpers\HGM.ArrayHelpers.pas',
  HGM.JSONParams in '..\JSONParam\HGM.JSONParams.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm4, Form4);
  Application.Run;
end.
