program TGBotMini;

uses
  System.SysUtils,
  System.Classes,
  TgBotApi in 'TgBotApi.pas',
  HGM.JSONParams in 'JSONParam\HGM.JSONParams.pas',
  HGM.ArrayHelpers in 'ArrayHelpers\HGM.ArrayHelpers.pas',
  TgBotProc.Test in 'TgBotProc.Test.pas',
  TgBotApi.Client in 'TgBotApi.Client.pas',
  TgBotProc.BlogItBlackCat in 'TgBotProc.BlogItBlackCat.pas';

begin
  ReportMemoryLeaksOnShutdown := True;
  Client := TtgClient.Create({$INCLUDE BOT_TOKEN.key});
  while True do
  try
    Client.Hello;
    Client.Polling(
      procedure(u: TtgUpdate)
      begin
        Writeln('Data: ', u.ToString);                                  // DEBUG
        UploadAllFiles(u);
        ProcCallbackQuery(u);
        if Assigned(u.Message) and Assigned(u.Message.Chat) then
        begin
          if u.Message.Text = '/menu' then
            ProcMenu(u)
          else if u.Message.Text = '/start' then
            ProcStart(u)
          else if u.Message.Text = '/info' then
            ProcInfo(u)
          else if u.Message.Text = 'А?' then
            ProcA(u)
          else if u.Message.Text = '/photo' then
            ProcPhoto(u);
        end;
      end);
    Sleep(5000);
  except
    on E: Exception do
      Writeln('Error: ' + E.Message);
  end;
end.

