program TGBotMini;

uses
  System.SysUtils,
  System.Classes,
  TgBotApi in 'TgBotApi.pas',
  HGM.JSONParams in '..\JSONParam\HGM.JSONParams.pas',
  HGM.ArrayHelpers in '..\ArrayHelpers\HGM.ArrayHelpers.pas',
  TgBotProc.Test in 'TgBotProc.Test.pas',
  TgBotApi.Client in 'TgBotApi.Client.pas';

begin
  ReportMemoryLeaksOnShutdown := True;
  Client := TtgClient.Create({$INCLUDE BOT_TOKEN.key});
  try
    Client.Hello;
    //LongPoll
    while True do
    try
      Client.Polling(
        procedure(u: TtgUpdate)
        begin
          if Assigned(u.CallbackQuery) and
            Assigned(u.CallbackQuery.Message) and
            Assigned(u.CallbackQuery.Message.Chat)
            then
          begin
            Client.SendMessageToChat(u.CallbackQuery.Message.Chat.Id, 'Вы выбрали ' + u.CallbackQuery.Data);
          end;
          Writeln('Data: ', u.ToString);
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
    except
      on E: Exception do
        Writeln('Error: ' + E.Message);
    end;
  finally
    Client.Free;
  end;
end.

