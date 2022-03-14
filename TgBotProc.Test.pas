unit TgBotProc.Test;

interface

uses
  TgBotApi, TgBotApi.Client;

procedure ProcMenu(u: TtgUpdate);

procedure ProcStart(u: TtgUpdate);

procedure ProcInfo(u: TtgUpdate);

procedure ProcA(u: TtgUpdate);

procedure ProcPhoto(u: TtgUpdate);

procedure ProcCallbackQuery(u: TtgUpdate);

implementation

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

procedure ProcCallbackQuery(u: TtgUpdate);
begin
  if Assigned(u.CallbackQuery) and
    Assigned(u.CallbackQuery.Message) and
    Assigned(u.CallbackQuery.Message.Chat)
    then
  begin
    Client.SendMessageToChat(u.CallbackQuery.Message.Chat.Id, 'Вы выбрали ' + u.CallbackQuery.Data);
  end;
end;

end.

