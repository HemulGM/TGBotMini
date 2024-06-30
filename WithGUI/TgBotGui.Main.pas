unit TgBotGui.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Threading, FMX.Memo.Types, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.Memo;

type
  TForm4 = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FPolling: iTask;
    procedure StartPolling;
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

uses
  TgBotApi, TgBotApi.Client;

{$R *.fmx}

procedure TForm4.FormCreate(Sender: TObject);
begin
  FPolling := nil;
  Client := TtgClient.Create({$INCLUDE ..\BOT_TOKEN.key});
  Client.Subscribe(
    function(u: TtgUpdate): Boolean
    begin
      Client.SendMessageToChat(u.Message.Chat.Id, 'Menu',
        TtgInlineKeyboardMarkup.Create([
        [TtgKey.Create('🌦️ Погода', '{"cmd":"weather"}'), TtgKey.Create('🥐 Еда', '{"cmd":"food"}')],
        [TtgKey.Create('3', '{"cmd":"command3"}'), TtgKey.Create('Contact', '{"cmd":"command4"}', '', True)]]).ToString(True)).Free;
      Result := True;
    end, '/menu');
  Client.SubscribeCallBack(
    function(u: TtgUpdate): Boolean
    begin

      var Response := Client.SendMessageToChat(u.CallbackQuery.Message.Chat.Id, 'Погода так себе');
      try
        var MsgId := Response.Result.MessageId;
      finally
        Response.Free;
      end;
      Result := True;
    end, '{"cmd":"weather"}');
  Client.Subscribe(
    function(u: TtgUpdate): Boolean
    begin
      if Assigned(u.Message) and (Length(u.Message.Photo) > 0) then
      begin
        var Photos: TArray<string>;
        SetLength(Photos, Length(u.Message.Photo));
        for var i := 0 to High(u.Message.Photo) do
          Photos[i] := u.Message.Photo[i].FileId;
        TThread.Queue(nil,
          procedure
          begin
            for var i := 0 to High(Photos) do
              Memo1.Lines.Add(Photos[i]);
          end);
      end;
      Result := False;
    end);

  StartPolling;
end;

procedure TForm4.FormDestroy(Sender: TObject);
begin
  FPolling := nil;
end;

procedure TForm4.StartPolling;
begin
  FPolling := TTask.Run(Client.Polling);
end;

end.

