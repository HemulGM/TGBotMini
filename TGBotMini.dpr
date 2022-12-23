program TGBotMini;

uses
  System.SysUtils,
  System.Classes,
  TgBotApi in 'TgBotApi.pas',
  TgBotApi.Client in 'TgBotApi.Client.pas',
  HGM.JSONParams in 'JSONParam\HGM.JSONParams.pas',
  TgBotProc.Test in 'TgBotProc.Test.pas',
  TgBotProc.BlogItBlackCat in 'TgBotProc.BlogItBlackCat.pas',
  HGM.ArrayHelpers in 'ArrayHelpers\HGM.ArrayHelpers.pas';

begin
  ReportMemoryLeaksOnShutdown := True;
  Client := TtgClient.Create({$INCLUDE BOT_TOKEN.key});
  Client.Logging := True;
  Client.OnTextOut :=
    procedure(const Text: string)
    begin
      Writeln(Text);
    end;
  Client.Subscribe(Logging);
  Client.Subscribe(UploadAllFiles);
  Client.Subscribe(ProcCallbackQuery);
  Client.Subscribe(ProcMenu, '/menu');
  Client.Subscribe(ProcStart, '/start');
  Client.Subscribe(ProcInfo, '/info');
  Client.Subscribe(ProcA, 'А?');
  Client.Subscribe(ProcPhoto, '/photo');
  while True do
  try
    Client.Hello;
    Client.Polling;
    if Client.IsStop then
      Break;
    Sleep(5000);
  except
    on E: Exception do
      Writeln('Error: ' + E.Message);
  end;
  Client.Free;
end.

