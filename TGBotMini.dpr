program TGBotMini;

uses
  System.SysUtils,
  TgBotApi in 'TgBotApi.pas';

begin
  ReportMemoryLeaksOnShutdown := True;
  TtgClient.BASE_URL := 'https://api.telegram.org/bot';
  TtgClient.TOKEN := {$INCLUDE BOT_TOKEN.key};
  Writeln('Telegram Bot Mini API Inited');
  while True do
  try
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
  except
    on E: Exception do Writeln('Error: ' + E.Message);
  end;
end.

