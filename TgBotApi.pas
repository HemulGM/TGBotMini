unit TgBotApi;

interface

uses
  System.SysUtils, System.Json, REST.Json, System.Net.HttpClient,
  REST.JsonReflect, REST.Json.Interceptors, HGM.Common.Download, System.Classes;

type
  TtgObject = class
    constructor Create; virtual;
    function ToString: string; override;
  end;

  TtgMessageNew = class(TtgObject)
  private
    FChat_id: int64;
    FText: string;
    FReply_markup: string;
  public
    property ChatId: int64 read FChat_id write FChat_id;
    property Text: string read FText write FText;
    property ReplyMarkup: string read FReply_markup write FReply_markup;
  end;

  TtgUser = class(TtgObject)
  private
    FFirst_name: string;
    FId: int64;
    FIs_bot: Boolean;
    FLast_name: string;
    FLanguage_code: string;
    FUsername: string;
    FCan_join_groups: Boolean;
    FCan_read_all_group_messages: Boolean;
    FSupports_inline_queries: Boolean;
  public
    property FirstName: string read FFirst_name;
    property LastName: string read FLast_name;
    property Username: string read FUsername;
    property LanguageCode: string read FLanguage_code;
    property IsBot: Boolean read FIs_bot;
    property Id: int64 read FId;
    property CanJoinGroups: Boolean read FCan_join_groups write FCan_join_groups;
    property CanReadAllGroupMessages: Boolean read FCan_read_all_group_messages write FCan_read_all_group_messages;
    property SupportsInlineQueries: Boolean read FSupports_inline_queries write FSupports_inline_queries;
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

  TtgMessageEntity = class(TtgObject)
  private
    FLength: int64;
    FType: string;
    FOffset: int64;
  public
    property Length: int64 read FLength;
    property Offset: int64 write FOffset;
    property &Type: string read FType;
  end;

  TtgMessage = class(TtgObject)
  private
    [JsonReflectAttribute(ctString, rtString, TUnixDateTimeInterceptor)]
    FDate: TDateTime;
    FMessage_id: Int64;
    FFrom: TtgUser;
    FChat: TtgChat;
    FText: string;
    FEntities: TArray<TtgMessageEntity>;
    FReply_to_message: TtgMessage;
    FNew_chat_participant: TtgUser;
    FNew_chat_member: TtgUser;
    FNew_chat_members: TArray<TtgUser>;
  public
    property MessageId: Int64 read FMessage_id;
    property From: TtgUser read FFrom;
    property Chat: TtgChat read FChat;
    property Date: TDateTime read FDate;
    property Text: string read FText;
    property Entities: TArray<TtgMessageEntity> read FEntities;
    property ReplyToMessage: TtgMessage read FReply_to_message;
    property NewChatMember: TtgUser read FNew_chat_member;
    property NewChatMembers: TArray<TtgUser> read FNew_chat_members;
    property NewChatParticipant: TtgUser read FNew_chat_participant;
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

  TtgCallbackQuery = class(TtgObject)
  private
    FMessage: TtgMessage;
    FFrom: TtgUser;
    FChat_instance: int64;
    FData: string;
    FId: int64;
  public
    property Message: TtgMessage read FMessage;
    property From: TtgUser read FFrom;
    property ChatInstance: int64 read FChat_instance;
    property Data: string read FData;
    property Id: int64 read FId;
    destructor Destroy; override;
  end;

  TtgUpdate = class(TtgObject)
  private
    FMessage: TtgMessage;
    FUpdate_id: int64;
    FCallback_query: TtgCallbackQuery;
  public
    property Message: TtgMessage read FMessage;
    property UpdateId: int64 read FUpdate_id;
    property CallbackQuery: TtgCallbackQuery read FCallback_query;
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

  TInlineKeysArray = array of array of array of string;

  TtgInlineKeyboardMarkup = class
  private
    FJSON: TJSONObject;
  public
    constructor Create; overload;
    constructor Create(Keys: TInlineKeysArray); overload;
    destructor Destroy; override;
    function ToString: string; override;
  end;

  TKeysArray = array of array of string;

  TtgReplyKeyboardMarkup = class
  private
    FJSON: TJSONObject;
  public
    constructor Create; overload;
    constructor Create(Keys: TKeysArray); overload;
    destructor Destroy; override;
    function ToString: string; override;
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
    class procedure SendMessageToChat(ChatId: Int64; const Text: string; const KeyBoard: string = ''); static;
    class procedure SendPhotoToChat(ChatId: Int64; const Caption, FileName: string; Stream: TStream); overload; static;
    class procedure SendPhotoToChat(ChatId: Int64; const Caption, FileName: string); overload; static;
    class function GetUpdates(out Value: TtgUpdates): Boolean;
    class function GetMe(out Value: TtgUserResponse): Boolean; static;
  end;

implementation

uses
  HGm.ArrayHelper, System.NetEncoding;

{ TtgClient }

class function TtgClient.GetMe(out Value: TtgUserResponse): Boolean;
begin
  Result := Get(Value, 'getMe') and Assigned(Value);
end;

class procedure TtgClient.SendMessageToChat(ChatId: Int64; const Text, KeyBoard: string);
begin
  var Message := TtgMessageNew.Create;
  try
    Message.ChatId := ChatId;
    Message.Text := Text;
    if not KeyBoard.IsEmpty then
      Message.ReplyMarkup := KeyBoard;
    var Resp: TtgMessageResponse := nil;
    if Get(Resp, 'sendMessage', Message.ToString) and Assigned(Resp) then
      Resp.Free;
  finally
    Message.Free;
  end;
end;

class procedure TtgClient.SendPhotoToChat(ChatId: Int64; const Caption, FileName: string);
begin
  var Photo := TFileStream.Create(FileName, fmShareDenyWrite);
  try
    TtgClient.SendPhotoToChat(ChatId, Caption, FileName, Photo);
  finally
    Photo.Free;
  end;
end;

class procedure TtgClient.SendPhotoToChat(ChatId: Int64; const Caption, FileName: string; Stream: TStream);
var
  Resp: TStringStream;
begin
  Resp := TStringStream.Create;
  try
    Stream.Position := 0;
    TDownload.PostFile(Format(BuildUrl('sendPhoto') + '?chat_id=%d&caption=%s',
      [ChatId, TURLEncoding.URL.Encode(Caption)]), ['photo'], [ExtractFileName(FileName)], [Stream], Resp);
  finally
    Resp.Free
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
    writeln(Response);
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
  Result := TJSON.ObjectToJsonString(Self, [joIgnoreEmptyStrings, joIgnoreEmptyArrays]);
end;

{ TtgMessage }

destructor TtgMessage.Destroy;
begin
  if Assigned(Ffrom) then
    Ffrom.Free;
  if Assigned(Fchat) then
    Fchat.Free;
  if Assigned(FReply_to_message) then
    FReply_to_message.Free;
  if Assigned(Fnew_chat_member) then
    Fnew_chat_member.Free;
  TArrayHelp.FreeArrayOfObject<TtgUser>(Fnew_chat_members);
  if Assigned(Fnew_chat_participant) then
    Fnew_chat_participant.Free;
  TArrayHelp.FreeArrayOfObject<TtgMessageEntity>(FEntities);
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
  if Assigned(FCallback_query) then
    FCallback_query.Free;
  inherited;
end;

{ TtgUpdates }

destructor TtgUpdates.Destroy;
begin
  if Assigned(result) then
    TArrayHelp.FreeArrayOfObject<TtgUpdate>(Fresult);
end;

{ TtgInlineKeyboardMarkup }

constructor TtgInlineKeyboardMarkup.Create(Keys: TInlineKeysArray);
begin
  Create;
  var KB := TJSONArray.Create;
  FJSON.AddPair('inline_keyboard', KB);
  for var Row in Keys do
  begin
    var JSRow := TJSONArray.Create;
    KB.Add(JSRow);
    for var Button in Row do
    begin
      var JSButton := TJSONObject.Create;
      JSButton.AddPair('text', Button[0]);
      JSButton.AddPair('callback_data', Button[1]);
      JSRow.Add(JSButton);
    end;
  end;
end;

constructor TtgInlineKeyboardMarkup.Create;
begin
  inherited;
  FJSON := TJSONObject.Create;
end;

destructor TtgInlineKeyboardMarkup.Destroy;
begin
  FJSON.Free;
  inherited;
end;

function TtgInlineKeyboardMarkup.ToString: string;
begin
  Result := FJSON.ToJSON;
end;

{ TtgReplyKeyboardMarkup }

constructor TtgReplyKeyboardMarkup.Create;
begin
  inherited;
  FJSON := TJSONObject.Create;
end;

constructor TtgReplyKeyboardMarkup.Create(Keys: TKeysArray);
begin
  Create;
  var KB := TJSONArray.Create;
  FJSON.AddPair('keyboard', KB);
  for var Row in Keys do
  begin
    var JSRow := TJSONArray.Create;
    KB.Add(JSRow);
    for var Button in Row do
    begin
      var JSButton := TJSONObject.Create;
      JSButton.AddPair('text', Button);
      JSRow.Add(JSButton);
    end;
  end;
end;

destructor TtgReplyKeyboardMarkup.Destroy;
begin
  FJSON.Free;
  inherited;
end;

function TtgReplyKeyboardMarkup.ToString: string;
begin
  Result := FJSON.ToJSON;
end;

{ TtgCallbackQuery }

destructor TtgCallbackQuery.Destroy;
begin
  if Assigned(Ffrom) then
    Ffrom.Free;
  if Assigned(FMessage) then
    FMessage.Free;
  inherited;
end;

end.

