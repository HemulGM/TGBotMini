unit TgBotApi;

interface

uses
  System.SysUtils, System.Classes, System.Json, REST.Json, System.Net.HttpClient,
  REST.JsonReflect, REST.Json.Interceptors, HGM.JSONParams,
  System.Generics.Collections, System.Net.Mime;

{$SCOPEDENUMS ON}

type
  TTgUpdateSubscribe = class(TCustomAttribute);

  TtgException = class(Exception)
  private
    FCode: Int64;
    procedure SetCode(const Value: Int64);
  public
    property Code: Int64 read FCode write SetCode;
    constructor Create(const Code: Int64; const Message: string); reintroduce;
  end;

  TtgBadRequest = class(TtgException);

  TtgObject = class
  public
    constructor Create; virtual;
    function ToString(AutoFree: Boolean = False): string; reintroduce;
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

  TtgMessageDel = class(TtgObject)
  private
    FChat_id: int64;
    FMessage_id: int64;
  public
    property ChatId: int64 read FChat_id write FChat_id;
    property MessageId: int64 read FMessage_id write FMessage_id;
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
    FId: Int64;
    FType: string;
    FLast_name: string;
    FUsername: string;
  public
    property Id: Int64 read FId;
    property &Type: string read FType;
    property Username: string read FUsername;
    property FirstName: string read FFirst_name;
    property LastName: string read FLast_name;
    property Title: string read FTitle;
  end;

  TtgMessageEntity = class(TtgObject)
  private
    FLength: Int64;
    FType: string;
    FOffset: Int64;
  public
    property Length: Int64 read FLength;
    property Offset: Int64 write FOffset;
    // mention
    property &Type: string read FType;
  end;

  TtgFile = class(TtgObject)
  private
    FFile_id: string;
    FFile_size: Int64;
    FFile_unique_id: string;
    FFile_path: string;
  public
    property FileId: string read FFile_id write FFile_id;
    /// <summary>
    /// Размер файла в байтах
    /// </summary>
    property FileSize: Int64 read FFile_size write FFile_size;
    property FileUniqueId: string read FFile_unique_id write FFile_unique_id;
    /// <summary>
    /// Путь к файлу для его загрузки. Не пустой только после вызова getFile
    /// </summary>
    property FilePath: string read FFile_path write FFile_path;
  end;

  TtgPhoto = class(TtgFile)
  private
    FWidth: Int64;
    FHeight: Int64;
  public
    property Height: Int64 read FHeight write FHeight;
    property Width: Int64 read FWidth write FWidth;
  end;

  TtgSticker = class(TtgFile)
  private
    FEmoji: string;
    FHeight: Int64;
    FIs_animated: Boolean;
    FIs_video: Boolean;
    FSet_name: string;
    FThumb: TtgPhoto;
    FWidth: Int64;
  public
    property Emoji: string read FEmoji write FEmoji;
    property Height: Int64 read FHeight write FHeight;
    property IsAnimated: Boolean read FIs_animated write FIs_animated;
    property IsVideo: Boolean read FIs_video write FIs_video;
    property SetName: string read FSet_name write FSet_name;
    property Thumb: TtgPhoto read FThumb write FThumb;
    property Width: Int64 read FWidth write FWidth;
    destructor Destroy; override;
  end;

  TtgDocument = class(TtgFile)
  private
    FFile_name: string;
    FThumb: TtgPhoto;
    FMime_type: string;
  public
    property FileName: string read FFile_name write FFile_name;
    property MimeType: string read FMime_type write FMime_type;
    property Thumb: TtgPhoto read FThumb write FThumb;
    destructor Destroy; override;
  end;

  TtgVideo = class(TtgFile)
  private
    FDuration: Int64;
    FFile_name: string;
    FHeight: Int64;
    FMime_type: string;
    FThumb: TtgPhoto;
    FWidth: Int64;
  public
    property Duration: Int64 read FDuration write FDuration;
    property MimeType: string read FMime_type write FMime_type;
    property FileName: string read FFile_name write FFile_name;
    property Height: Int64 read FHeight write FHeight;
    property Thumb: TtgPhoto read FThumb write FThumb;
    property Width: Int64 read FWidth write FWidth;
    destructor Destroy; override;
  end;

  TtgAnimation = class(TtgDocument)
  private
    FDuration: Int64;
    FHeight: Int64;
    FWidth: Int64;
  public
    property Duration: Int64 read FDuration write FDuration;
    property Height: Int64 read FHeight write FHeight;
    property Width: Int64 read FWidth write FWidth;
  end;

  TtgVoiceChatStarted = class(TtgObject);

  TtgVoiceChatEnded = class(TtgObject)
  private
    FDuration: Int64;
  public
    property Duration: Int64 read FDuration;
  end;

  TtgVoiceChatScheduled = class(TtgObject)
  private
    [JsonReflectAttribute(ctString, rtString, TUnixDateTimeInterceptor)]
    FStart_date: TDateTime;
  public
    property StartDate: TDateTime read FStart_date;
  end;

  TtgPollOption = class(TtgObject)
  private
    FText: string;
    FVoter_count: Int64;
  public
    property Text: string read FText write FText;
    property VoterCount: Int64 read FVoter_count write FVoter_count;
  end;

  TtgPoll = class(TtgObject)
  private
    FAllows_multiple_answers: Boolean;
    FId: string;
    FIs_anonymous: Boolean;
    FIs_closed: Boolean;
    FOptions: TArray<TtgPollOption>;
    FQuestion: string;
    FTotal_voter_count: Int64;
    FType: string;
  public
    property AllowsMultipleAnswers: Boolean read FAllows_multiple_answers write FAllows_multiple_answers;
    property Id: string read FId write FId;
    property IsAnonymous: Boolean read FIs_anonymous write FIs_anonymous;
    property IsClosed: Boolean read FIs_closed write FIs_closed;
    property Options: TArray<TtgPollOption> read FOptions write FOptions;
    property Question: string read FQuestion write FQuestion;
    property TotalVoterCount: Int64 read FTotal_voter_count write FTotal_voter_count;
    // regular, quiz
    property &Type: string read FType write FType;
    destructor Destroy; override;
  end;

  TtgPollAnswer = class(TtgObject)
  private
    FUser: TtgUser;
    FPoll_id: string;
    FOption_ids: TArray<Integer>;
  public
    property User: TtgUser read FUser;
    property PollId: string read FPoll_id;
    property OptionIds: TArray<Integer> read FOption_ids;
    destructor Destroy; override;
  end;

  TtgVoice = class(TtgFile)
  private
    FMime_type: string;
    FDuration: Int64;
  public
    property Duration: Int64 read FDuration write FDuration;
    property MimeType: string read FMime_type write FMime_type;
  end;

  TtgLocation = class(TtgObject)
  private
    FLive_period: Int64;
    FLatitude: Extended;
    FLongitude: Extended;
    FHeading: Int64;
    FHorizontal_accuracy: Extended;
  public
    property Heading: Int64 read FHeading write FHeading;
    property HorizontalAccuracy: Extended read FHorizontal_accuracy write FHorizontal_accuracy;
    property Latitude: Extended read FLatitude write FLatitude;
    property LivePeriod: Int64 read FLive_period write FLive_period;
    property Longitude: Extended read FLongitude write FLongitude;
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
    FPhoto: TArray<TtgPhoto>;
    FSender_chat: TtgChat;
    FVoice_chat_started: TtgVoiceChatStarted;
    FVoice_chat_ended: TtgVoiceChatEnded;
    FVoice_chat_scheduled: TtgVoiceChatEnded;
    FNew_chat_title: string;
    FNew_chat_photo: TArray<TtgPhoto>;
    FPoll: TtgPoll;
    [JsonReflectAttribute(ctString, rtString, TUnixDateTimeInterceptor)]
    FEdit_date: TDateTime;
    FAnimation: TtgAnimation;
    FVideo: TtgVideo;
    FCaption: string;
    FVoice: TtgVoice;
    [JsonReflectAttribute(ctString, rtString, TUnixDateTimeInterceptor)]
    FForward_date: TDateTime;
    FForward_from: TTgUser;
    FLeft_chat_member: TTgUser;
    FLeft_chat_participant: TtgUser;
    FLocation: TtgLocation;
    FDocument: TtgDocument;
  public
    property Animation: TtgAnimation read FAnimation;
    property Caption: string read FCaption;
    property Document: TtgDocument read FDocument;
    property Chat: TtgChat read FChat;
    property Date: TDateTime read FDate;
    property EditDate: TDateTime read FEdit_date;
    property Entities: TArray<TtgMessageEntity> read FEntities;
    property ForwardDate: TDateTime read FForward_date;
    property ForwardFrom: TTgUser read FForward_from;
    property From: TtgUser read FFrom;
    property LeftChatMember: TTgUser read FLeft_chat_member;
    property LeftChatParticipant: TtgUser read FLeft_chat_participant;
    property Location: TtgLocation read FLocation;
    property MessageId: Int64 read FMessage_id;
    property NewChatMember: TtgUser read FNew_chat_member;
    property NewChatMembers: TArray<TtgUser> read FNew_chat_members;
    property NewChatParticipant: TtgUser read FNew_chat_participant;
    property NewChatPhoto: TArray<TtgPhoto> read FNew_chat_photo;
    property NewChatTitle: string read FNew_chat_title;
    property Photo: TArray<TtgPhoto> read FPhoto;
    property Poll: TtgPoll read FPoll;
    property ReplyToMessage: TtgMessage read FReply_to_message;
    property SenderChat: TtgChat read FSender_chat;
    property Text: string read FText;
    property Video: TtgVideo read FVideo;
    property Voice: TtgVoice read FVoice;
    property VoiceChatEnded: TtgVoiceChatEnded read FVoice_chat_ended;
    property VoiceChatScheduled: TtgVoiceChatEnded read FVoice_chat_scheduled;
    property VoiceChatStarted: TtgVoiceChatStarted read FVoice_chat_started;
    destructor Destroy; override;
  end;

  TtgResponse = class(TtgObject)
  private
    FOk: Boolean;
    FError_code: Int64;
    FDescription: string;
  public
    property Ok: Boolean read FOk;
    property ErrorCode: int64 read FError_code;
    property Description: string read FDescription;
  end;

  TtgResponse<T: class, constructor> = class(TtgResponse)
  private
    FResult: T;
  public
    property Result: T read FResult;
    destructor Destroy; override;
  end;

  TtgResponseSimple<T> = class(TtgResponse)
  private
    FResult: T;
  public
    property Result: T read FResult;
  end;

  TtgResponseDelete = TtgResponseSimple<Boolean>;

  TtgResponseItems<T: class, constructor> = class(TtgResponse)
  private
    FResult: TArray<T>;
  public
    property Result: TArray<T> read FResult;
    destructor Destroy; override;
  end;

  TtgUserResponse = TtgResponse<TtgUser>;

  TtgMessageResponse = TtgResponse<TtgMessage>;

  TtgGetFile = class(TtgObject)
  private
    FFile_id: string;
  public
    property FileId: string read FFile_id write FFile_id;
  end;

  TtgGetFileResponse = class(TtgResponse<TtgFile>);

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
    FEdited_message: TtgMessage;
    FPoll_answer: TtgPollAnswer;
  public
    property Message: TtgMessage read FMessage;
    property EditedMessage: TtgMessage read FEdited_message;
    property UpdateId: int64 read FUpdate_id;
    property CallbackQuery: TtgCallbackQuery read FCallback_query;
    property PollAnswer: TtgPollAnswer read FPoll_answer;
    destructor Destroy; override;
  end;

  TtgUpdates = TtgResponseItems<TtgUpdate>;

  /// <summary>
  /// Title, Command, Url
  /// </summary>
  TtgKey = TArray<string>;

  TtgKeysArray = TArray<TtgKey>;

  TtgInlineKeysArray = TArray<TtgKeysArray>;

  TtgInlineKeyboardMarkup = class
  private
    FJSON: TJSONObject;
  public
    constructor Create; overload;
    constructor Create(Keys: TtgInlineKeysArray); overload;
    destructor Destroy; override;
    function ToString(AutoFree: Boolean = False): string; reintroduce;
  end;

  TtgReplyKeyboardMarkup = class
  private
    FJSON: TJSONObject;
  public
    constructor Create; overload;
    constructor Create(Keys: TtgKeysArray); overload;
    destructor Destroy; override;
    function ToString(AutoFree: Boolean = False): string; reintroduce;
  end;

  TtgUpdateFunc = reference to function(Update: TtgUpdate): Boolean;

  TtgUpdateProc = reference to procedure(Update: TtgUpdate);

  TtgParamsHistory = class(TJSONParam)
  end;

  TtgPollType = (Regular, Quiz);

  TtgPollTypeHelper = record helper for TtgPollType
    function ToString: string;
  end;

  TtgPollParams = class(TJSONParam)
    function ChatId(const Value: string): TtgPollParams; overload;
    function ChatId(const Value: Int64): TtgPollParams; overload;
    function Question(const Value: string): TtgPollParams;
    function Options(const Value: TArray<string>): TtgPollParams;
    function IsNotAnonymous(const Value: Boolean = True): TtgPollParams;
    function &Type(const Value: TtgPollType): TtgPollParams;
    function OpenPeriod(const Value: Word): TtgPollParams; overload;
  end;

  TtgAudioParams = class(TJSONParam)
    function ChatId(const Value: string): TtgAudioParams; overload;
    function ChatId(const Value: Int64): TtgAudioParams; overload;
    function Audio(const Url: string): TtgAudioParams; overload;
  end;

  TtgUpdateSubscriber = record
    ConditionText: string;
    Func: TtgUpdateFunc;
    class function Create(Func: TtgUpdateFunc; const ConditionText: string = ''): TtgUpdateSubscriber; static;
  end;

  TOnTextOut = reference to procedure(const Text: string);

  TtgClient = class
  private
    FBaseUrl: string;
    FToken: string;
    FLastUpdateId: Int64;
    FDoPolling: Boolean;
    FOnTextOut: TOnTextOut;
    FSubscribers: TList<TtgUpdateSubscriber>;
    FLogging: Boolean;
    function ProccessUpdate(u: TtgUpdate): Boolean;
    procedure SetLogging(const Value: Boolean);
    procedure DoError(Response: TStringStream; StatusCode: Integer);
    function GetIsStop: Boolean;
    procedure CollectSubscribers;
  protected
    procedure DoTextOut(const Text: string);
  public
    constructor Create(const AToken: string);
    destructor Destroy; override;
    //
    function BuildUrl(const Method: string): string;
    function BuildDownloadFileUrl(const FilePath: string): string;
    //
    function Execute<T: class, constructor>(const Method: string; const Json: string = ''): T; overload;
    function Execute<T: class, constructor>(const Method: string; const Form: TMultipartFormData): T; overload;
    //
    function GetMe: TtgUserResponse;
    function GetUpdates: TtgUpdates;
    function SendMessageToChat(ChatId: Int64; const Text: string; const KeyBoard: string = ''): TtgMessageResponse;
    function SendPhotoToChat(ChatId: Int64; const Caption: string; const FileName: string): TtgMessageResponse; overload;
    function SendPhotoToChat(ChatId: Int64; const Caption: string; const FileName: string; Stream: TStream): TtgMessageResponse; overload;
    function SendPoll(Params: TtgPollParams): TtgMessageResponse;
    function SendAudio(Params: TtgAudioParams): TtgMessageResponse;
    procedure DeleteMessage(ChatId: Int64; MessageId: Int64);
    //
    procedure GetFile(const FileId: string; Stream: TStream);
    //
    procedure Polling(Proc: TtgUpdateProc = nil); overload;
    procedure StopPolling;
    procedure Hello;
    //
    procedure Subscribe(Func: TtgUpdateFunc; const Text: string = ''); overload;
    procedure Unsubscribe(Func: TtgUpdateFunc);
    //
    property BaseUrl: string read FBaseUrl write FBaseUrl;
    property LastUpdateId: Int64 read FLastUpdateId write FLastUpdateId;
    property Token: string read FToken write FToken;
    property OnTextOut: TOnTextOut read FOnTextOut write FOnTextOut;
    property Logging: Boolean read FLogging write SetLogging;
    property IsStop: Boolean read GetIsStop;
  end;

  TArrayHelp = class
  public
    class procedure FreeArrayOfObject<T: class>(var Target: TArray<T>); overload; inline; static;
  end;

implementation

uses
  System.NetConsts, System.Net.URLClient, System.NetEncoding, System.Rtti;

class procedure TArrayHelp.FreeArrayOfObject<T>(var Target: TArray<T>);
  {$IFNDEF AUTOREFCOUNT}
var
  Item: T;
  {$ENDIF}
begin
  {$IFNDEF AUTOREFCOUNT}
  for Item in Target do
    if Assigned(Item) then
      Item.Free;
  SetLength(Target, 0);
  {$ENDIF}
end;

{ TtgClient }

procedure TtgClient.Hello;
begin
  DoTextOut('Telegram Bot Mini API Inited');
  var Me := GetMe;
  try
    if Assigned(Me.Result) then
      DoTextOut('Bot name is ' + Me.Result.Username);
  finally
    Me.Free;
  end;
end;

function TtgClient.GetMe: TtgUserResponse;
begin
  Result := Execute<TtgUserResponse>('getMe');
end;

function TtgClient.SendAudio(Params: TtgAudioParams): TtgMessageResponse;
begin
  Result := Execute<TtgMessageResponse>('sendAudio', Params.ToJsonString);
end;

function TtgClient.SendMessageToChat(ChatId: Int64; const Text, KeyBoard: string): TtgMessageResponse;
begin
  var Message := TtgMessageNew.Create;
  Message.ChatId := ChatId;
  Message.Text := Text;
  if not KeyBoard.IsEmpty then
    Message.ReplyMarkup := KeyBoard;
  Result := Execute<TtgMessageResponse>('sendMessage', Message.ToString(True));
end;

function TtgClient.SendPhotoToChat(ChatId: Int64; const Caption: string; const FileName: string): TtgMessageResponse;
begin
  var Stream := TFileStream.Create(FileName, fmShareDenyWrite);
  try
    Result := SendPhotoToChat(ChatId, Caption, FileName, Stream);
  finally
    Stream.Free;
  end;
end;

procedure TtgClient.DoError(Response: TStringStream; StatusCode: Integer);
begin
  var ErrorText := 'Unknown error';
  var ErrorCode: Int64 := StatusCode;
  var RespObj: TtgResponse;
  try
    RespObj := TJSON.JsonToObject<TtgResponse>(Response.DataString);
  except
    RespObj := nil;
  end;
  if Assigned(RespObj) then
  try
    ErrorText := RespObj.Description;
    ErrorCode := RespObj.ErrorCode;
    case RespObj.ErrorCode of
      400:
        raise TtgBadRequest.Create(ErrorCode, ErrorText);
    end;
  finally
    RespObj.Free;
  end;
  raise TtgException.Create(ErrorCode, ErrorText);
end;

function TtgClient.SendPhotoToChat(ChatId: Int64; const Caption: string; const FileName: string; Stream: TStream): TtgMessageResponse;
var
  Form: TMultipartFormData;
begin
  Form := TMultipartFormData.Create;
  try
    Form.AddStream('photo', Stream, FileName);
    Result := Execute<TtgMessageResponse>(Format('sendPhoto?chat_id=%d&caption=%s', [ChatId, TURLEncoding.URL.Encode(Caption)]), Form);
  finally
    Form.Free;
  end;
end;

function TtgClient.SendPoll(Params: TtgPollParams): TtgMessageResponse;
begin
  Result := Execute<TtgMessageResponse>('sendPoll', Params.ToJsonString);
end;

procedure TtgClient.SetLogging(const Value: Boolean);
begin
  FLogging := Value;
end;

procedure TtgClient.StopPolling;
begin
  FDoPolling := False;
end;

procedure TtgClient.Subscribe(Func: TtgUpdateFunc; const Text: string);
begin
  FSubscribers.Add(TtgUpdateSubscriber.Create(Func, Text));
end;

procedure TtgClient.DoTextOut(const Text: string);
begin
  if Assigned(OnTextOut) then
    OnTextOut(Text);
end;

procedure TtgClient.Unsubscribe(Func: TtgUpdateFunc);
begin
  for var i := 0 to Pred(FSubscribers.Count) do
    if FSubscribers[i].Func = TtgUpdateFunc(Func) then
    begin
      FSubscribers.Delete(i);
      Exit;
    end;
end;

function TtgClient.BuildDownloadFileUrl(const FilePath: string): string;
begin
  Result := Format('%s/file/bot%s/%s', [FBaseUrl, FToken, FilePath]);
end;

function TtgClient.BuildUrl(const Method: string): string;
begin
  Result := Format('%s/bot%s/%s', [FBaseUrl, FToken, Method]);
end;

procedure TtgClient.CollectSubscribers;
{var
  Context: TRttiContext;  }
begin
  //Context.GetType(TTgUpdateSubscribe)
end;

constructor TtgClient.Create(const AToken: string);
begin
  inherited Create;
  FSubscribers := TList<TtgUpdateSubscriber>.Create;
  FBaseUrl := 'https://api.telegram.org';
  FToken := AToken;
  CollectSubscribers;
end;

procedure TtgClient.DeleteMessage(ChatId, MessageId: Int64);
begin
  var Msg := TtgMessageDel.Create;
  Msg.ChatId := ChatId;
  Msg.MessageId := MessageId;
  var Resp := Execute<TtgResponseDelete>('deleteMessage', Msg.ToString(True));
  Resp.Free;
end;

destructor TtgClient.Destroy;
begin
  FSubscribers.Free;
  inherited;
end;

function TtgClient.Execute<T>(const Method: string; const Json: string): T;
var
  Response: TStringStream;
  StatusCode: Integer;
begin
  if Method.IsEmpty then
    raise TtgException.Create(-1, 'Method is empty');
  Result := nil;
  var HTTP := THTTPClient.Create;
  Response := TStringStream.Create;
  try
    HTTP.HandleRedirects := True;
    HTTP.ContentType := 'application/json';
    var Body := TStringStream.Create;
    try
      Body.WriteString(Json);
      Body.Position := 0;
      StatusCode := HTTP.Post(BuildUrl(Method), Body, Response).StatusCode;
    finally
      Body.Free;
    end;
    if FLogging then
      DoTextOut(Response.DataString);
    if StatusCode = 200 then
      Result := TJSON.JsonToObject<T>(Response.DataString)
    else
      DoError(Response, StatusCode);
    if not Assigned(Result) then
      raise TtgException.Create(-1, 'Empty object');
  finally
    HTTP.Free;
    Response.Free;
  end;
end;

function TtgClient.Execute<T>(const Method: string; const Form: TMultipartFormData): T;
var
  Response: TStringStream;
  StatusCode: Integer;
begin
  if Method.IsEmpty then
    raise TtgException.Create(-1, 'Method is empty');
  Result := nil;
  var HTTP := THTTPClient.Create;
  Response := TStringStream.Create;
  try
    HTTP.HandleRedirects := True;
    HTTP.ContentType := 'application/json';
    StatusCode := HTTP.Post(BuildUrl(Method), Form, Response).StatusCode;
    if StatusCode = 200 then
      Result := TJSON.JsonToObject<T>(Response.DataString)
    else
      DoError(Response, StatusCode);
    if not Assigned(Result) then
      raise TtgException.Create(-1, 'Empty object');
  finally
    HTTP.Free;
    Response.Free;
  end;
end;

procedure TtgClient.GetFile(const FileId: string; Stream: TStream);
var
  HTTP: THTTPClient;
begin
  var Params := TtgGetFile.Create;
  Params.FileId := FileId;
  var Value := Execute<TtgGetFileResponse>('getFile', Params.ToString(True));
  try
    Stream.Size := 0;
    HTTP := THTTPClient.Create;
    try
      HTTP.HandleRedirects := True;
      if HTTP.Get(BuildDownloadFileUrl(Value.Result.FilePath), Stream).StatusCode <> 200 then
        raise TtgException.Create(-1, 'Download error');
      Stream.Position := 0;
    finally
      HTTP.Free;
    end;
  finally
    Value.Free;
  end;
end;

function TtgClient.GetIsStop: Boolean;
begin
  Result := not FDoPolling;
end;

function TtgClient.GetUpdates: TtgUpdates;
begin
  var Params := TtgUpdateNew.Create;
  Params.Offset := FLastUpdateId;
  Result := Execute<TtgUpdates>('getUpdates', Params.ToString(True));
  if Length(Result.Result) > 0 then
    FLastUpdateId := Result.Result[High(Result.Result)].UpdateId + 1;
end;

function TtgClient.ProccessUpdate(u: TtgUpdate): Boolean;
begin
  Result := False;
  for var Subscriber in FSubscribers do
  begin
    if Subscriber.ConditionText.IsEmpty then
    begin
      if Subscriber.Func(u) then
        Exit(True);
    end
    else
    begin
      if Assigned(u.Message) and (u.Message.Text.Trim = Subscriber.ConditionText) then
        if Subscriber.Func(u) then
          Exit(True);
    end;
  end;
end;

procedure TtgClient.Polling(Proc: TtgUpdateProc);
begin
  FDoPolling := True;
  while FDoPolling do
  begin
    var Updates := GetUpdates;
    try
      for var u in Updates.Result do
        if FDoPolling then
        try
          if not ProccessUpdate(u) then
            if Assigned(Proc) then
              Proc(u);
        except
          on E: Exception do
            DoTextOut('Update processing error: "' + E.Message + '"');
        end
        else
          Exit;
    finally
      Updates.Free;
    end;
  end;
end;

{ TtgObject }

constructor TtgObject.Create;
begin
  inherited;
end;

function TtgObject.ToString(AutoFree: Boolean): string;
begin
  Result := TJSON.ObjectToJsonString(Self, [joIgnoreEmptyStrings, joIgnoreEmptyArrays]);
  if AutoFree then
    Free;
end;

{ TtgMessage }

destructor TtgMessage.Destroy;
begin
  if Assigned(FFrom) then
    FFrom.Free;
  if Assigned(FLocation) then
    FLocation.Free;
  if Assigned(FDocument) then
    FDocument.Free;
  if Assigned(FLeft_chat_participant) then
    FLeft_chat_participant.Free;
  if Assigned(FLeft_chat_member) then
    FLeft_chat_member.Free;
  if Assigned(FForward_from) then
    FForward_from.Free;
  if Assigned(FVoice) then
    FVoice.Free;
  if Assigned(FVideo) then
    FVideo.Free;
  if Assigned(FAnimation) then
    FAnimation.Free;
  if Assigned(FPoll) then
    FPoll.Free;
  if Assigned(FVoice_chat_started) then
    FVoice_chat_started.Free;
  if Assigned(FVoice_chat_ended) then
    FVoice_chat_ended.Free;
  if Assigned(FVoice_chat_scheduled) then
    FVoice_chat_scheduled.Free;
  if Assigned(FSender_chat) then
    FSender_chat.Free;
  if Assigned(Fchat) then
    Fchat.Free;
  if Assigned(FReply_to_message) then
    FReply_to_message.Free;
  if Assigned(Fnew_chat_member) then
    Fnew_chat_member.Free;
  TArrayHelp.FreeArrayOfObject<TtgPhoto>(FPhoto);
  TArrayHelp.FreeArrayOfObject<TtgUser>(Fnew_chat_members);
  TArrayHelp.FreeArrayOfObject<TtgPhoto>(FNew_chat_photo);
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
  if Assigned(FEdited_message) then
    FEdited_message.Free;
  if Assigned(FCallback_query) then
    FCallback_query.Free;
  if Assigned(FPoll_answer) then
    FPoll_answer.Free;
  inherited;
end;

{ TtgInlineKeyboardMarkup }

constructor TtgInlineKeyboardMarkup.Create(Keys: TtgInlineKeysArray);
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
      if Length(Button) > 1 then
      begin
        var JSButton := TJSONObject.Create;
        JSButton.AddPair('text', Button[0]);
        JSButton.AddPair('callback_data', Button[1]);
        if Length(Button) > 2 then
          JSButton.AddPair('url', Button[2]);
        JSRow.Add(JSButton);
      end;
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

function TtgInlineKeyboardMarkup.ToString(AutoFree: Boolean): string;
begin
  Result := FJSON.ToJSON;
  if AutoFree then
    Free;
end;

{ TtgReplyKeyboardMarkup }

constructor TtgReplyKeyboardMarkup.Create;
begin
  inherited;
  FJSON := TJSONObject.Create;
end;

constructor TtgReplyKeyboardMarkup.Create(Keys: TtgKeysArray);
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

function TtgReplyKeyboardMarkup.ToString(AutoFree: Boolean): string;
begin
  Result := FJSON.ToJSON;
  if AutoFree then
    Free;
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

{ TtgDocument }

destructor TtgDocument.Destroy;
begin
  if Assigned(FThumb) then
    FThumb.Free;
  inherited;
end;

{ TtgResponseItems<T> }

destructor TtgResponseItems<T>.Destroy;
begin
  TArrayHelp.FreeArrayOfObject<T>(Fresult);
  inherited;
end;

{ TtgPoll }

destructor TtgPoll.Destroy;
begin
  TArrayHelp.FreeArrayOfObject<TtgPollOption>(FOptions);
  inherited;
end;

{ TtgSticker }

destructor TtgSticker.Destroy;
begin
  if Assigned(FThumb) then
    FThumb.Free;
  inherited;
end;

{ TtgVideo }

destructor TtgVideo.Destroy;
begin
  if Assigned(FThumb) then
    FThumb.Free;
  inherited;
end;

{ TtgPollParams }

function TtgPollParams.&Type(const Value: TtgPollType): TtgPollParams;
begin
  Result := Self;
  Add('type', Value.ToString);
end;

function TtgPollParams.ChatId(const Value: string): TtgPollParams;
begin
  Result := Self;
  Add('chat_id', Value);
end;

function TtgPollParams.ChatId(const Value: Int64): TtgPollParams;
begin
  Result := Self;
  Add('chat_id', Value);
end;

function TtgPollParams.IsNotAnonymous(const Value: Boolean): TtgPollParams;
begin
  Result := Self;
  Add('is_anonymous', not Value);
end;

function TtgPollParams.OpenPeriod(const Value: Word): TtgPollParams;
begin
  Result := Self;
  Add('open_period', Value);
end;

function TtgPollParams.Options(const Value: TArray<string>): TtgPollParams;
begin
  Result := Self;
  Add('options', Value);
end;

function TtgPollParams.Question(const Value: string): TtgPollParams;
begin
  Result := Self;
  Add('question', Value);
end;

{ TtgPollTypeHelper }

function TtgPollTypeHelper.ToString: string;
begin
  case Self of
    TtgPollType.Regular:
      Result := 'regular';
    TtgPollType.Quiz:
      Result := 'quiz';
  else
    Result := 'regular';
  end;
end;

{ TtgAudioParams }

function TtgAudioParams.Audio(const Url: string): TtgAudioParams;
begin
  Result := Self;
  Add('audio', Url);
end;

function TtgAudioParams.ChatId(const Value: string): TtgAudioParams;
begin
  Result := Self;
  Add('chat_id', Value);
end;

function TtgAudioParams.ChatId(const Value: Int64): TtgAudioParams;
begin
  Result := Self;
  Add('chat_id', Value);
end;

{ TtgPollAnswer }

destructor TtgPollAnswer.Destroy;
begin
  if Assigned(FUser) then
    FUser.Free;
  inherited;
end;

{ TtgUpdateSubscriber }

class function TtgUpdateSubscriber.Create(Func: TtgUpdateFunc; const ConditionText: string): TtgUpdateSubscriber;
begin
  Result.Func := Func;
  Result.ConditionText := ConditionText;
end;

{ TtgException }

constructor TtgException.Create(const Code: Int64; const Message: string);
begin
  inherited Create(Message);
  FCode := Code;
end;

procedure TtgException.SetCode(const Value: Int64);
begin
  FCode := Value;
end;

end.

