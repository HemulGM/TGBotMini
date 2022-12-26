# TGBotMini
 Telegram Bot Mini API

```Pascal
program TGBotMini;

uses
  System.SysUtils,
  TgBotApi in 'TgBotApi.pas',
  TgBotApi.Client in 'TgBotApi.Client.pas',
  HGM.ArrayHelpers in 'ArrayHelpers\HGM.ArrayHelpers.pas',
  HGM.JSONParams in 'JSONParam\HGM.JSONParams.pas',
  TgBotProc.Test in 'TgBotProc.Test.pas';

begin
  Client := TtgClient.Create({$INCLUDE BOT_TOKEN.key});
  Client.Logging := True;
  Client.OnTextOut :=
    procedure(const Text: string)
    begin
      Writeln(Text);
    end;
  Client.Subscribe(ProcCallbackQuery);
  Client.Subscribe(ProcMenu, '/menu');
  Client.Subscribe(ProcStart, '/start');
  Client.Subscribe(ProcPhoto, '/photo');
  while True do
  try
    Client.Hello;
    Client.Polling;
  except
    on E: Exception do
    begin
      Writeln('Error: ' + E.Message);
      Sleep(5000);
    end;
  end;
  Client.Free;
end.
```
