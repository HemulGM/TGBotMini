unit TgBotProc.Test;

interface

uses
  System.SysUtils, TgBotApi, TgBotApi.Client;

function ProcMenu(u: TtgUpdate): Boolean;

function ProcStart(u: TtgUpdate): Boolean;

function ProcInfo(u: TtgUpdate): Boolean;

function ProcA(u: TtgUpdate): Boolean;

function ProcPhoto(u: TtgUpdate): Boolean;

function ProcVideo(u: TtgUpdate): Boolean;

function ProcContact(u: TtgUpdate): Boolean;

function ProcTest(u: TtgUpdate): Boolean;

function ProcWeather(u: TtgUpdate): Boolean;

function ProcFood(u: TtgUpdate): Boolean;

function ProcCallbackQuery(u: TtgUpdate): Boolean;

function UploadAllFiles(u: TtgUpdate): Boolean;

function Logging(u: TtgUpdate): Boolean;

function ProcDeleteTest(u: TtgUpdate): Boolean;

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

function ProcDeleteTest(u: TtgUpdate): Boolean;
begin
  Result := True;
  try
    Client.DeleteMessage(-1001525223801, 2236);
  except
    on E: TtgBadRequest do
      Writeln('Сообщение не удалено: ' + E.Message);
  end;
end;

function ProcWeather(u: TtgUpdate): Boolean;
begin
  Result := True;
  Client.SendMessageToChat(u.CallbackQuery.Message.Chat.Id, 'Погода збс!').Free;
end;

function ProcFood(u: TtgUpdate): Boolean;
begin
  Result := True;
  Client.SendMessageToChat(u.CallbackQuery.Message.Chat.Id, 'Еда норм!').Free;
end;

function Logging(u: TtgUpdate): Boolean;
begin
  Result := False;
  Writeln('Data: ', u.ToString);
end;

function UploadAllFiles(u: TtgUpdate): Boolean;
const
  UploadPath = 'D:\Temp\';
begin
  Result := False;
  if Assigned(u.Message) and Assigned(u.Message.Document) then
  begin
    var FileName := UploadPath + u.Message.Document.FileName;
    var FileNameTemp := UploadPath + u.Message.Document.FileName + '.tmp';
    var FileStream := TFileStream.Create(FileNameTemp, fmCreate);
    try
      try
        Client.GetFile(u.Message.Document.FileId, FileStream);
      finally
        FileStream.Free;
      end;
      TFile.Move(FileNameTemp, FileName);
      SendMailFile('Файл из Телеги', FileName);
      TFile.Delete(FileName);
    except
      TFile.Delete(FileNameTemp);
    end;
  end;
end;

function ProcMenu(u: TtgUpdate): Boolean;
begin
  Result := False;
  Client.SendMessageToChat(u.Message.Chat.Id, 'Меню',
    TtgInlineKeyboardMarkup.Create([
    [TtgKey.Create('🌦️ Погода', '{"cmd":"weather"}'), TtgKey.Create('🥐 Еда', '{"cmd":"food"}')],
    [TtgKey.Create('3', '{"cmd":"command3"}'), TtgKey.Create('Contact', '{"cmd":"command4"}', '', True)]]).ToString(True)).Free;
end;

function ProcStart(u: TtgUpdate): Boolean;
begin
  Result := False;
  var KeyBoard := TtgReplyKeyboardMarkup.Create([
    [TtgKey.Create('1', ''), TtgKey.Create('2', '', '')],
    [TtgKey.Create('3', ''), TtgKey.Create('/info', '')]
    ]);
  Client.SendMessageToChat(u.Message.Chat.Id, 'Меню 2', KeyBoard.ToString(True)).Free;
end;

function ProcInfo(u: TtgUpdate): Boolean;
begin
  Result := False;
  Client.SendMessageToChat(u.Message.Chat.Id, 'Нет информации').Free;
end;

function ProcA(u: TtgUpdate): Boolean;
begin
  Result := False;
  Client.SendMessageToChat(u.Message.Chat.Id, 'Не Ааа!').Free;
end;

function ProcTest(u: TtgUpdate): Boolean;
begin
  Result := False;
  var Message := TtgMessageNew.Create;
  Message.ChatId := u.Message.Chat.Id;
  Message.Text := '`code'#13#10'line 2'#13#10'line3`';
  Message.ParseMode := 'MarkdownV2';
  Client.Execute<TtgMessageResponse>('sendMessage', Message.ToString(True)).Free;
end;

function ProcPhoto(u: TtgUpdate): Boolean;
begin
  Result := False;
  Client.SendPhotoToChat(u.Message.Chat.Id, 'Фото', 'D:\Temp\Iconion\HGM\Material Icons_e80e(0)_1024_Fill.png').Free;
end;

function ProcContact(u: TtgUpdate): Boolean;
begin
  Result := False;
  var Contact := TtgContactParams.Create;
  try
    Contact.PhoneNumber('+79991234567');
    Contact.FirstName('Test');
    Contact.LastName('Contact');
    Contact.ChatId(u.Message.Chat.Id);
    Client.SendContact(Contact).Free;
  finally
    Contact.Free;
  end;
end;

function ProcVideo(u: TtgUpdate): Boolean;
begin
  Result := False;
  Client.SendVideoToChat(u.Message.Chat.Id, 'Видео', 'D:\Downloads\Telegram Desktop\IMG_7719.MP4').Free;
end;

function ProcCallbackQuery(u: TtgUpdate): Boolean;
begin
  Result := False;
  if Assigned(u.CallbackQuery) and
    Assigned(u.CallbackQuery.Message) and
    Assigned(u.CallbackQuery.Message.Chat)
    then
  begin
    Client.SendMessageToChat(u.CallbackQuery.Message.Chat.Id, 'Вы выбрали ' + u.CallbackQuery.Data).Free;
  end;
end;

end.

