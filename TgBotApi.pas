unit TgBotApi;

interface

uses
  System.SysUtils, REST.Json, System.Net.HttpClient, REST.JsonReflect,
  REST.Json.Interceptors, HGM.Common.Download;

type
  TtgObject = class
    constructor Create; virtual;
    function ToString: string; override;
  end;

  TtgMessageNew = class(TtgObject)
  private
    FChat_id: int64;
    FText: string;
  public
    property ChatId: int64 read FChat_id write FChat_id;
    property Text: string read FText write FText;
  end;

  TtgUser = class(TtgObject)
  private
    FFirst_name: string;
    FId: int64;
    FIs_bot: Boolean;
    FLast_name: string;
    FLanguage_code: string;
    FUsername: string;
  public
    property FirstName: string read FFirst_name;
    property LastName: string read FLast_name;
    property Username: string read FUsername;
    property LanguageCode: string read FLanguage_code;
    property IsBot: Boolean read FIs_bot;
    property Id: int64 read FId;
  end;

  TtgChat = class(TtgObject)
  private
    FFirst_name: string;
    FTitle: string;
    FId: int64;
    FType: string;
    FLast_name: string;
    FUsername: string;
  public
    property Id: int64 read FId;
    property &Type: string read FType;
    property Username: string read FUsername;
    property FirstName: string read FFirst_name;
    property LastName: string read FLast_name;
    property Title: string read FTitle;
  end;

  TtgMessage = class(TtgObject)
  private
    [JsonReflectAttribute(ctString, rtString, TUnixDateTimeInterceptor)]
    FDate: TDateTime;
    FMessage_id: Int64;
    FFrom: TtgUser;
    FChat: TtgChat;
    FText: string;
  public
    property MessageId: Int64 read FMessage_id;
    property From: TtgUser read FFrom;
    property Chat: TtgChat read FChat;
    property Date: TDateTime read FDate;
    property Text: string read FText;
    destructor Destroy; override;
  end;

  TtgResponse<T: class, constructor> = class(TtgObject)
  private
    FOk: Boolean;
    FError_code: int64;
    FDescription: string;
    FResult: T;
  public
    property Ok: Boolean read FOk;
    property ErrorCode: int64 read FError_code;
    property Description: string read FDescription;
    property Result: T read FResult;
    destructor Destroy; override;
  end;

  TtgUserResponse = TtgResponse<TtgUser>;

  TtgMessageResponse = class(TtgResponse<TtgMessage>)
  private
    Fok: Boolean;
    FError_code: int64;
    FDescription: string;
  public
    property Ok: Boolean read Fok;
    property ErrorCode: int64 read FError_code;
    property Description: string read FDescription;
  end;

  TtgUpdateNew = class(TtgObject)
  private
    FOffset: int64;
  public
    property Offset: int64 read FOffset write FOffset;
  end;

  TtgUpdateMessage = class(TtgObject)
  private
    [JsonReflectAttribute(ctString, rtString, TUnixDateTimeInterceptor)]
    FDate: TDateTime;
    FNew_chat_members: TArray<TtgUser>;
    FNew_chat_participant: TtgUser;
    FNew_chat_member: TtgUser;
    Fmessage_id: int64;
    FFrom: TtgUser;
    FChat: TtgChat;
    FText: string;
  public
    property Chat: TtgChat read FChat;
    property Date: TDateTime read FDate;
    property From: TtgUser read FFrom;
    property MessageId: int64 read Fmessage_id;
    property Text: string read FText;
    property NewChatMember: TtgUser read FNew_chat_member;
    property NewChatMembers: TArray<TtgUser> read FNew_chat_members;
    property NewChatParticipant: TtgUser read FNew_chat_participant;
    destructor Destroy; override;
  end;

  TtgUpdate = class(TtgObject)
  private
    FMessage: TtgUpdateMessage;
    FUpdate_id: int64;
  public
    property Message: TtgUpdateMessage read FMessage;
    property UpdateId: int64 read FUpdate_id;
    destructor Destroy; override;
  end;

  TtgUpdates = class(TtgObject)
  private
    FOk: Boolean;
    Ferror_code: int64;
    Fdescription: string;
    Fresult: TArray<TtgUpdate>;
  public
    property Ok: Boolean read FOk;
    property ErrorCode: int64 read Ferror_code;
    property Description: string read Fdescription;
    property Result: TArray<TtgUpdate> read Fresult;
    destructor Destroy; override;
  end;

  TtgClient = class
  public
    class var
      BASE_URL: string;
    class var
      TOKEN: string;
    class var
      LastUpdateId: int64;
    class function BuildUrl(const tg_method: string): string;
    class function Get<T: class, constructor>(out Value: T; const Method: string; const Json: string = ''): Boolean; overload;
    class function Get(const Method, Json: string): Boolean; overload;
  public
    //
    class procedure SendMessageToChat(ChatId: Int64; const Text: string); static;
    class function GetUpdates(out Value: TtgUpdates): Boolean;
    class function GetMe(out Value: TtgUserResponse): Boolean; static;
  end;

implementation

uses
  HGm.ArrayHelper;

{ TtgClient }

class function TtgClient.GetMe(out Value: TtgUserResponse): Boolean;
begin
  Result := Get(Value, 'getMe') and Assigned(Value);
end;

class procedure TtgClient.SendMessageToChat(ChatId: Int64; const Text: string);
begin
  var Message := TtgMessageNew.Create;
  try
    Message.ChatId := ChatId;
    Message.Text := Text;
    var Resp: TtgMessageResponse := nil;
    if Get(Resp, 'sendMessage', Message.ToString) and Assigned(Resp) then
      Resp.Free;
  finally
    Message.Free;
  end;
end;

class function TtgClient.BuildUrl(const tg_method: string): string;
begin
  Result := Format('%s%s/%s', [BASE_URL, TOKEN, tg_method]);
end;

class function TtgClient.Get(const Method, Json: string): Boolean;
begin
  var Response: string;
  Result := TDownload.PostJson(BuildUrl(Method), Json, Response);
end;

class function TtgClient.Get<T>(out Value: T; const Method, Json: string): Boolean;
begin
  Value := nil;
  var Response: string;
  TDownload.PostJson(BuildUrl(Method), Json, Response);
  try
    Value := TJSON.JsonToObject<T>(Response);
    Result := Assigned(Value);
  except
    Result := False;
  end;
end;

class function TtgClient.GetUpdates(out Value: TtgUpdates): Boolean;
begin
  Result := False;
  var Params := TtgUpdateNew.Create;
  try
    Params.Offset := LastUpdateId;
    if Get(Value, 'getUpdates', Params.ToString) and Assigned(Value) then
    begin
      Result := True;
      if Value.Ok and (Length(Value.Result) > 0) then
        LastUpdateId := Value.Result[High(Value.Result)].UpdateId + 1;
    end;
  finally
    Params.Free;
  end;
end;

{ TtgObject }

constructor TtgObject.Create;
begin
  inherited;
end;

function TtgObject.ToString: string;
begin
  Result := TJSON.ObjectToJsonString(Self);
end;

{ TtgMessage }

destructor TtgMessage.Destroy;
begin
  if Assigned(Ffrom) then
    Ffrom.Free;
  if Assigned(Fchat) then
    Fchat.Free;
  inherited;
end;

{ TtgResponse<T> }

destructor TtgResponse<T>.Destroy;
begin
  if Assigned(Fresult) then
    Fresult.Free;
  inherited;
end;

{ TtgUpdate }

destructor TtgUpdate.Destroy;
begin
  if Assigned(Fmessage) then
    Fmessage.Free;
  inherited;
end;

{ TtgUpdateMessage }

destructor TtgUpdateMessage.Destroy;
begin
  if Assigned(Ffrom) then
    Ffrom.Free;
  if Assigned(Fchat) then
    Fchat.Free;
  if Assigned(Fnew_chat_member) then
    Fnew_chat_member.Free;
  TArrayHelp.FreeArrayOfObject<TtgUser>(Fnew_chat_members);
  if Assigned(Fnew_chat_participant) then
    Fnew_chat_participant.Free;
  inherited;
end;

{ TtgUpdates }

destructor TtgUpdates.Destroy;
begin
  if Assigned(result) then
    TArrayHelp.FreeArrayOfObject<TtgUpdate>(Fresult);
end;

end.

