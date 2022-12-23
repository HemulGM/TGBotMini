unit TgBotApi;

interface

uses
  System.SysUtils, System.Classes, System.Json, REST.Json, System.Net.HttpClient,
  REST.JsonReflect, REST.Json.Interceptors, HGM.Common.Download, HGM.JSONParams,
  System.Generics.Collections;

{$SCOPEDENUMS ON}

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
    FError_code: int64;
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
  /// Title, Command
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
    function ToString: string; override;
  end;

  TtgReplyKeyboardMarkup = class
  private
    FJSON: TJSONObject;
  public
    constructor Create; overload;
    constructor Create(Keys: TtgKeysArray); overload;
    destructor Destroy; override;
    function ToString: string; override;
  end;

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

  TtgClient = class
  private
    FBaseUrl: string;
    FToken: string;
    FLastUpdateId: Int64;
  public
    constructor Create(const AToken: string);
    function BuildUrl(const Method: string): string;
    function BuildDownloadFileUrl(const FilePath: string): string;
    function Get(const Method, Json: string): Boolean; overload;
    function Get(const Method, Json: string; Stream: TStream): Boolean; overload;
    function Get<T: class, constructor>(out Value: T; const Method: string; const Json: string = ''): Boolean; overload;
    function GetMe(out Value: TtgUserResponse): Boolean;
    function GetUpdates(out Value: TtgUpdates): Boolean; overload;
    function GetFile(const FileId: string; Stream: TStream): Boolean;
    function Polling(Proc: TtgUpdateProc): Boolean; overload;
    procedure Hello;
    procedure SendMessageToChat(ChatId: Int64; const Text: string; const KeyBoard: string = '');
    procedure SendPhotoToChat(ChatId: Int64; const Caption: string; const FileName: string); overload;
    procedure SendPhotoToChat(ChatId: Int64; const Caption: string; const FileName: string; Stream: TStream); overload;
    procedure SendPoll(Params: TtgPollParams; var Message: TtgMessage);
    procedure SendAudio(Params: TtgAudioParams; var Message: TtgMessage);
    property BaseUrl: string read FBaseUrl write FBaseUrl;
    property LastUpdateId: Int64 read FLastUpdateId write FLastUpdateId;
    property Token: string read FToken write FToken;
  end;

implementation

uses
  HGm.ArrayHelper, System.NetEncoding;

{ TtgClient }

procedure TtgClient.Hello;
begin
  Write('Telegram Bot Mini API Inited');
  var Me: TtgUserResponse;
  if GetMe(Me) then
    with Me do
    try
      if Ok and Assigned(Me.Result) then
        Writeln(' - ', Me.Result.Username);
    finally
      Free;
    end;
end;

function TtgClient.GetMe(out Value: TtgUserResponse): Boolean;
begin
  Result := Get(Value, 'getMe');
end;

procedure TtgClient.SendAudio(Params: TtgAudioParams; var Message: TtgMessage);
begin
  var Resp: TtgMessageResponse := nil;
  if Get(Resp, 'sendAudio', Params.ToJsonString) then
    Resp.Free;
end;

procedure TtgClient.SendMessageToChat(ChatId: Int64; const Text, KeyBoard: string);
begin
  var Message := TtgMessageNew.Create;
  try
    Message.ChatId := ChatId;
    Message.Text := Text;
    if not KeyBoard.IsEmpty then
      Message.ReplyMarkup := KeyBoard;
    var Resp: TtgMessageResponse := nil;
    if Get(Resp, 'sendMessage', Message.ToString) then
      Resp.Free;
  finally
    Message.Free;
  end;
end;

procedure TtgClient.SendPhotoToChat(ChatId: Int64; const Caption: string; const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmShareDenyWrite);
  try
    SendPhotoToChat(ChatId, Caption, FileName, Stream);
  finally
    Stream.Free;
  end;
end;

procedure TtgClient.SendPhotoToChat(ChatId: Int64; const Caption: string; const FileName: string; Stream: TStream);
var
  Resp: TStringStream;
  Fields: TStringList;
begin
  Resp := TStringStream.Create;
  Fields := TStringList.Create;
  try
    Stream.Position := 0;
    Fields.Add('photo');
    if not TDownload.PostFile(
      Format(BuildUrl('sendPhoto') + '?chat_id=%d&caption=%s', [ChatId, TURLEncoding.URL.Encode(Caption)]),
      Fields.ToStringArray, [FileName], [Stream], Resp)
      then
      Writeln('Error: ' + Resp.DataString);
  finally
    Fields.Free;
    Resp.Free;
  end;
end;

procedure TtgClient.SendPoll(Params: TtgPollParams; var Message: TtgMessage);
begin
  var Resp: TtgMessageResponse := nil;
  if Get(Resp, 'sendPoll', Params.ToJsonString) then
    Resp.Free;
end;

function TtgClient.BuildDownloadFileUrl(const FilePath: string): string;
begin
  Result := Format('%s/file/bot%s/%s', [FBaseUrl, FToken, FilePath]);
end;

function TtgClient.BuildUrl(const Method: string): string;
begin
  Result := Format('%s/bot%s/%s', [FBaseUrl, FToken, Method]);
end;

constructor TtgClient.Create(const AToken: string);
begin
  inherited Create;
  FBaseUrl := 'https://api.telegram.org';
  FToken := AToken;
end;

function TtgClient.Get(const Method, Json: string): Boolean;
begin
  var Response: string;
  Result := TDownload.PostJson(BuildUrl(Method), Json, Response);
end;

function TtgClient.Get(const Method, Json: string; Stream: TStream): Boolean;
begin
  Result := TDownload.PostJson(BuildUrl(Method), Json, Stream);
end;

function TtgClient.Get<T>(out Value: T; const Method, Json: string): Boolean;
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

function TtgClient.GetFile(const FileId: string; Stream: TStream): Boolean;
var
  Value: TtgGetFileResponse;
begin
  Result := False;
  var Params := TtgGetFile.Create;
  try
    Params.FileId := FileId;
    if Get(Value, 'getFile', Params.ToString) then
    try
      Result := TDownload.Get(BuildDownloadFileUrl(Value.Result.FilePath), Stream);
    finally
      Value.Free;
    end;
  finally
    Params.Free;
  end;
end;

function TtgClient.GetUpdates(out Value: TtgUpdates): Boolean;
begin
  Result := False;
  var Params := TtgUpdateNew.Create;
  try
    Params.Offset := FLastUpdateId;
    if Get(Value, 'getUpdates', Params.ToString) then
    begin
      Result := True;
      if Value.Ok and (Length(Value.Result) > 0) then
        FLastUpdateId := Value.Result[High(Value.Result)].UpdateId + 1;
    end;
  finally
    Params.Free;
  end;
end;

function TtgClient.Polling(Proc: TtgUpdateProc): Boolean;
begin
  while True do
  begin
    var Updates: TtgUpdates;
    if GetUpdates(Updates) then
    try
      for var u in Updates.Result do
        Proc(u);
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

function TtgObject.ToString: string;
begin
  Result := TJSON.ObjectToJsonString(Self, [joIgnoreEmptyStrings, joIgnoreEmptyArrays]);
end;

{ TtgMessage }

destructor TtgMessage.Destroy;
begin
  if Assigned(Ffrom) then
    Ffrom.Free;
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

end.

