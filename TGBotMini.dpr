program TGBotMini;

uses
  System.SysUtils,
  System.Classes,
  TgBotApi in 'TgBotApi.pas',
  HGM.ArrayHelper,
  HGM.JSONParams in '..\JSONParam\HGM.JSONParams.pas',
  HGM.ArrayHelpers in '..\ArrayHelpers\HGM.ArrayHelpers.pas';

var
  Client: TtgClient;


procedure WriteHello;
begin
  Write('Telegram Bot Mini API Inited');
  var Me: TtgUserResponse;
  if Client.GetMe(Me) then
    with Me do
    try
      if Ok and Assigned(Me.Result) then
        Writeln(' - ', Me.Result.Username);
    finally
      Free;
    end;
end;

procedure ProcMenu(u: TtgUpdate);
begin
  var KeyBoard := TtgInlineKeyboardMarkup.Create([
    [['🌦️ Погода', 'command1'], ['🥐 Еда', 'command2']],
    [['3', 'command3'], ['4', 'command4']]
    ]);
  try
    Client.SendMessageToChat(u.Message.Chat.Id, 'Меню', KeyBoard.ToString);
  finally
    KeyBoard.Free;
  end;
end;

procedure ProcStart(u: TtgUpdate);
begin
  var KeyBoard := TtgReplyKeyboardMarkup.Create([
    ['1', '2'],
    ['3', '/info']
    ]);
  try
    Client.SendMessageToChat(u.Message.Chat.Id, 'Меню 2', KeyBoard.ToString);
  finally
    KeyBoard.Free;
  end;
end;

procedure ProcInfo(u: TtgUpdate);
begin
  Client.SendMessageToChat(u.Message.Chat.Id, 'Нет информации');
end;

procedure ProcA(u: TtgUpdate);
begin
  Client.SendMessageToChat(u.Message.Chat.Id, 'Не Ааа!');
end;

procedure ProcPhoto(u: TtgUpdate);
begin
  Client.SendPhotoToChat(u.Message.Chat.Id, 'Фото', 'D:\Temp\Iconion\HGM\Material Icons_e80e(0)_1024_Fill.png');
end;

begin
  ReportMemoryLeaksOnShutdown := True;
  Client := TtgClient.Create({$INCLUDE BOT_TOKEN.key});
  try
    WriteHello;
    //LongPoll
    try
      var Params := TtgParamsHistory.Create;
      try
        var History: TArray<TtgMessage>;
        if Client.GetHistory(History, Params) then
        try

        finally
          TArrayHelp.FreeArrayOfObject<TtgMessage>(History);
        end;
      finally
        Params.Free;
      end;

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

