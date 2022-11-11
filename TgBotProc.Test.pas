unit TgBotProc.Test;

interface

uses
  System.SysUtils, TgBotApi, TgBotApi.Client;

procedure ProcMenu(u: TtgUpdate);

procedure ProcStart(u: TtgUpdate);

procedure ProcInfo(u: TtgUpdate);

procedure ProcA(u: TtgUpdate);

procedure ProcPhoto(u: TtgUpdate);

procedure ProcCallbackQuery(u: TtgUpdate);

procedure UploadAllFiles(u: TtgUpdate);

implementation

uses
  System.Classes, System.IOUtils, IdSMTP, IdMessage, IdAttachmentFile,
  IdExplicitTLSClientServerBase, IdSSLOpenSSL;

procedure SendMailFile(const Comment, AFile: string);
var
  SMTP: TIdSMTP;
  Msg: TIdMessage;
begin
  if not TFile.Exists(AFile) then
    Exit;
  Msg := TIdMessage.Create(nil);
  try
    Msg.From.Address := '@mail.ru';
    Msg.Recipients.EMailAddresses := '@inbox.ru';
    Msg.Body.Text := Comment;
    TIdAttachmentFile.Create(Msg.MessageParts, AFile);
    Msg.CharSet := 'utf-8';
    Msg.Subject := AFile;
    SMTP := TIdSMTP.Create(nil);
    try
      SMTP.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(SMTP);
      SMTP.Host := 'smtp.mail.ru';
      SMTP.Port := 25;
      SMTP.AuthType := satDefault;
      SMTP.UseTLS := utUseRequireTLS;
      SMTP.Username := '@mail.ru';
      SMTP.Password := '';
      SMTP.Connect;
      SMTP.Send(Msg);
    finally
      SMTP.Free;
    end;
  finally
    Msg.Free;
  end;
end;

procedure UploadAllFiles(u: TtgUpdate);
begin
  if Assigned(u.Message) and Assigned(u.Message.Document) then
  begin
    var FileStream := TFileStream.Create('D:\Temp\' + u.Message.Document.FileName + '.tmp', fmCreate);
    var Success: Boolean;
    try
      Success := Client.GetFile(u.Message.Document.FileId, FileStream);
    finally
      FileStream.Free;
    end;
    if Success then
    begin
      TFile.Move('D:\Temp\' + u.Message.Document.FileName + '.tmp', 'D:\Temp\' + u.Message.Document.FileName);
      SendMailFile('Файл из Телеги', 'D:\Temp\' + u.Message.Document.FileName);
      TFile.Delete('D:\Temp\' + u.Message.Document.FileName);
    end
    else
      TFile.Delete('D:\Temp\' + u.Message.Document.FileName + '.tmp');
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
  Client.SendPhotoToChat(u.Message.Chat.Id, 'Фото',
    [
    'D:\Temp\Iconion\HGM\Material Icons_e80e(0)_1024_Fill.png',
    'D:\Temp\Iconion\HGM\Material Icons_e80e(0)_1024_Fill.png'
    ]);
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

