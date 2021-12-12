program TGBotMini;

uses
  System.SysUtils,
  TgBotApi in 'TgBotApi.pas';

begin
  ReportMemoryLeaksOnShutdown := True;
  TtgClient.BASE_URL := 'https://api.telegram.org/bot';
  TtgClient.TOKEN := {$INCLUDE BOT_TOKEN.key};
  Write('Telegram Bot Mini API Inited');
  //Bot Name
  var Me: TtgUserResponse;
  if TtgClient.GetMe(Me) then
  with Me do
  try
    if Ok and Assigned(Me.Result) then
      Writeln(' - ', Me.Result.Username);
  finally
    Free;
  end;
  //LongPoll
  while True do
  try
    var Updates: TtgUpdates;
    if TtgClient.GetUpdates(Updates) then
    try
      for var u in Updates.Result do
      begin
        if Assigned(u.Message) and Assigned(u.Message.Chat) then
        begin
          Writeln('Message: ', u.Message.Text, '. Answer to: ', u.Message.Chat.Id);
          var Text := Format('Привет, %s %s!', [u.Message.Chat.FirstName, u.Message.Chat.LastName]);
          TtgClient.SendMessageToChat(u.Message.Chat.Id, Text);
        end;
      end;
    finally
      Updates.Free;
    end;
  except
    on E: Exception do
      Writeln('Error: ' + E.Message);
  end;
end.

