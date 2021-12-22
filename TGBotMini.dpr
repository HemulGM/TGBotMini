program TGBotMini;

uses
  System.SysUtils,
  TgBotApi in 'TgBotApi.pas',
  System.Classes;

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
        if Assigned(u.CallbackQuery) and
          Assigned(u.CallbackQuery.Message) and
          Assigned(u.CallbackQuery.Message.Chat)
          then
        begin
          TtgClient.SendMessageToChat(u.CallbackQuery.Message.Chat.Id, 'Вы выбрали ' + u.CallbackQuery.Data);
        end;
        Writeln('Data: ', u.ToString);
        if Assigned(u.Message) and Assigned(u.Message.Chat) then
        begin
          if u.Message.Text = '/menu' then
          begin
            var KeyBoard := TtgInlineKeyboardMarkup.Create([
              [['🌦️ Погода', 'command1'], ['🥐 Еда', 'command2']],
              [['3', 'command3'], ['4', 'command4']]
              ]);
            try
              TtgClient.SendMessageToChat(u.Message.Chat.Id, 'Меню', KeyBoard.ToString);
            finally
              KeyBoard.Free;
            end;
          end
          else if u.Message.Text = '/start' then
          begin
            var KeyBoard := TtgReplyKeyboardMarkup.Create([
              ['1', '2'],
              ['3', '/info']
              ]);
            try
              TtgClient.SendMessageToChat(u.Message.Chat.Id, 'Меню 2', KeyBoard.ToString);
            finally
              KeyBoard.Free;
            end;
          end
          else if u.Message.Text = '/info' then
          begin
            TtgClient.SendMessageToChat(u.Message.Chat.Id, 'Нет информации');
          end
          else if u.Message.Text = 'А?' then
          begin
            TtgClient.SendMessageToChat(u.Message.Chat.Id, 'Не Ааа!');
          end
          else if u.Message.Text = '/photo' then
          begin
            TtgClient.SendPhotoToChat(u.Message.Chat.Id, 'Фото', 'D:\Temp\Iconion\HGM\Material Icons_e80e(0)_1024_Fill.png');
          end;
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

