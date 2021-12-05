program TGBotMini;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  REST.Json,
  TgBotApi in 'TgBotApi.pas';

begin
  ReportMemoryLeaksOnShutdown := True;
  TtgClient.BASE_URL := 'https://api.telegram.org/bot';
  TtgClient.TOKEN := {$INCLUDE BOT_TOKEN.key};
  while True do
  begin
    var Updates: TtgUpdates := TtgClient.GetUpdates;
    try
      for var u in Updates.Result do
      begin
        if Assigned(u.Message) and Assigned(u.Message.Chat) then
        begin
          var Text := Format('Пошёл нахуй, %s %s!', [u.Message.Chat.FirstName, u.Message.Chat.LastName]);
          TtgClient.SendMessageToChat(u.Message.Chat.Id, Text);
        end;
      end;
    finally
      Updates.Free;
    end;
  end;
end.
