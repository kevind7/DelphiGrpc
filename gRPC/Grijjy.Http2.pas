unit Grijjy.Http2;

{ Windows (and Linux?) Cross-platform HTTP/2 protocol
  support class using scalable client �nd server sockets.

  Modified version of the Grijjy.Http.pas unit to support gRPC
  and both client and server implementations.

  Build on top of ngHttp2.dll:
  - https://nghttp2.org/documentation/nghttp2.h.html
  - https://nghttp2.org/documentation/tutorial-client.html
  - https://nghttp2.org/documentation/tutorial-server.html
}

interface

{$I Grijjy.inc}

{$DEFINE HTTP2}

uses
  Dialogs, //REMOVE THIS LATER
  Vcl.ExtCtrls,
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  System.SyncObjs,
  System.DateUtils,
  System.Messaging,
  System.Net.URLClient,
  System.Net.Socket,
  System.Generics.Collections,
  Grijjy.Http,
  {$IFDEF MSWINDOWS}
  Winapi.Winsock,
  Grijjy.SocketPool.Win,
  Windows,
  {$ELSE IFDEF MOBILE}
  Grijjy.SocketPool.Dummy,
  {$ELSE IFDEF LINUX}
  Grijjy.SocketPool.Linux,
  Posix.Pthread,
  {$ENDIF}
  {$IFDEF HTTP2}
  Nghttp2,
  {$ENDIF}
  Grijjy.BinaryCoding;

type
  TSessionContext = class;
  TStreamRequest = class;

  TStreamNotify = procedure(const aStream: TStreamRequest; out aHandled: Boolean) of object;
  TStreamCleanup = procedure(pStreamRequest: TStreamRequest) of object;
  TStreamCallback = reference to procedure(const aStream: TStreamRequest; out aHandled: Boolean);

  { Http headers class }
  TgoHttpHeaders2 = class(TgoHttpHeaders)
  public
    { Reads headers as ngHttp2 compatible header array }
    procedure AsNgHttp2Array(var AHeaders: TArray<nghttp2_nv>);
  end;

  TgoHttp2Base = class
  protected
    FPort: Integer;
    FAddress: string;
    { SSL }
    FSSL: Boolean;
    FCertificate: TBytes;
    FPrivateKey: TBytes;

    { ngHttp2 }
    FCallbacks_http2: pnghttp2_session_callbacks;
    FSessions: TObjectList<TSessionContext>;
  public
    constructor Create(const aAddress: string = '127.0.0.1'; aPort: Integer = 12345; aSSL: Boolean = false); virtual;
    destructor  Destroy; override;
  end;

  TgoHttp2Server = class(TgoHttp2Base)
  private
    FOnStreamReceived: TStreamNotify;
    FListenThread: TThread;
  protected
    procedure OnSocketAccepted(aConnection: TgoSocketConnection);
  public
    constructor Create(const aBindAddress: string = '127.0.0.1'; aBindPort: Integer = 12345; aSSL: Boolean = false); override;

    destructor  Destroy; override;

    procedure StartListen;
    procedure Stop;

    property  BindAddress: string read FAddress write FAddress;
    property  BindPort: Integer read FPort write FPort;
    property  OnStreamFrameReceived: TStreamNotify read FOnStreamReceived write FOnStreamReceived;
  end;

  { Http server }
  TgoHttp2Client = class(TgoHttp2Base)
  private
    FSession: TSessionContext;
    { Http request }
    FAuthorization: String;
    FUserName: String;
    FPassword: String;
    FUserAgent: String;
  private
    Fauthority: String;
    function DoRequest(const AMethod, APath: String;
      const ARequest: TBytes; const AConnectTimeout, ARecvTimeout: Integer): Boolean;
  protected
    function GetOrCreateSession: TSessionContext;
  public
    function Connect(const AConnectTimeout: Integer = TIMEOUT_CONNECT): TSessionContext;
    procedure ConnectAsync(pOnConnect, pOnConnectTimeout: TProc; const AConnectTimeout: Integer = 10);

    { Get method }
    function Get(const AURL: String; out AResponse: TBytes;
      const AConnectTimeout: Integer = TIMEOUT_CONNECT;
      const ARecvTimeout: Integer = TIMEOUT_RECV): Boolean; overload;

    { Head method }
    function Head(const AURL: String;
      const AConnectTimeout: Integer = TIMEOUT_CONNECT;
      const ARecvTimeout: Integer = TIMEOUT_RECV): Boolean;

    { Post method }
    function Post(const APath: String; const ARequest: TBytes;
      const AConnectTimeout: Integer = TIMEOUT_CONNECT;
      const ARecvTimeout: Integer = TIMEOUT_RECV): Boolean; overload;

    { Put method }
    function Put(const AURL: String; out AResponse: TBytes;
      const AConnectTimeout: Integer = TIMEOUT_CONNECT;
      const ARecvTimeout: Integer = TIMEOUT_RECV): Boolean; overload;

    { Delete method }
    function Delete(const AURL: String; out AResponse: TBytes;
      const AConnectTimeout: Integer = TIMEOUT_CONNECT;
      const ARecvTimeout: Integer = TIMEOUT_RECV): Boolean; overload;

    { Options method }
    function Options(const AURL: String; out AResponse: TBytes;
      const AConnectTimeout: Integer = TIMEOUT_CONNECT;
      const ARecvTimeout: Integer = TIMEOUT_RECV): Boolean; overload;
  public
    constructor Create(const aRemoteAddress: string = '127.0.0.1'; aRemotePort: Integer = 12345; aSSL: Boolean = false); override;
    destructor  Destroy; override;
  public
    { Close connection }
    procedure Close;

    { Convert bytes to string }
    function BytesToString(const ABytes: TBytes; const ACharset: String): String;
  public
    { State }
//    property State: TgoHttpClientState read FState;

    { Idle time in milliseconds }
//    property IdleTime: Integer read GetIdleTime;

    { Cookies sent to the server and received from the server }
//    property Cookies: TStrings read GetCookies write SetCookies;

    { Optional body for a request.
      You can either use RequestBody or RequestData. If both are specified then
      only RequestBody is used. }
//    property RequestBody: String read FRequestBody write FRequestBody;

    { Optional binary body data for a request.
      You can either use RequestBody or RequestData. If both are specified then
      only RequestBody is used. }
//    property RequestData: TBytes read FRequestData write FRequestData;

    { Request headers }
//    property RequestHeaders: TgoHttpHeaders read FRequestHeaders;

    { Response headers from the server }
//    property ResponseHeaders: TgoHttpHeaders read FResponseHeaders;

    { Response status code }
//    property ResponseStatusCode: Integer read FResponseStatusCode;

    { Response content type }
//    property ResponseContentType: String read FResponseContentType;

    { Response charset }
//    property ResponseContentCharset: String read FResponseContentCharset;

    { Response content length }
//    property ContentLength: Int64 read FContentLength;

    { Allow 301 and other redirects }
//    property FollowRedirects: Boolean read FFollowRedirects write FFollowRedirects;

    { Called when a redirect is requested }
//    property OnRedirect: TOnRedirect read FOnRedirect write FOnRedirect;

    { Called when a password is needed }
//    property OnPassword: TOnPassword read FOnPassword write FOnPassword;

    { Called when a buffer is received from the socket }
//    property OnRecv: TOnRecv read FOnRecv write FOnRecv;

    { Username and password for Basic Authentication }
    property Session: TSessionContext read FSession;
    property UserName: String read FUserName write FUserName;
    property Password: String read FPassword write FPassword;

    { Content type }
//    property ContentType: String read FContentType write FContentType;

    { User agent }
    property UserAgent: String read FUserAgent write FUserAgent;

    { Range }
//    property Range: String read FRange write FRange;

    { Authorization }
    property Authority: String read Fauthority write Fauthority;
    property Authorization: String read FAuthorization write FAuthorization;

    { Certificate in PEM format }
    property Certificate: TBytes read FCertificate write FCertificate;
    { Private key in PEM format }
    property PrivateKey: TBytes read FPrivateKey write FPrivateKey;
  end;

  TSessionState = (Disconnected, Connecting, Connected);

  TSessionContext = class
  private
    function nghttp2_on_data_chunk_recv_callback(session: pnghttp2_session; flags: uint8; stream_id: int32;
      const data: puint8; len: size_t; user_data: Pointer): Integer;
    function nghttp2_on_stream_close_callback(session: pnghttp2_session; stream_id: int32; error_code: uint32;
      user_data: Pointer): Integer;
    function nghttp2_on_frame_recv_callback(session: pnghttp2_session; const frame: pnghttp2_frame;
      user_data: Pointer): Integer;
    function nghttp2_on_header_callback(session: pnghttp2_session;
      const frame: pnghttp2_frame; const name: puint8; namelen: size_t;
      const value: puint8; valuelen: size_t; flags: uint8;
      user_data: Pointer): Integer; cdecl;
  private
    FHttpOwner: TgoHttp2Base;
    FConnection: TgoSocketConnection;
    FState: TSessionState;

    FOnStreamReceived: TStreamNotify;
    FOnSessionConnected: TProc;
    FOnSessionConnectedTimeout: TProc;

    FConnected: TEvent;
    FPendingSendCount: Integer;
    FConnectionTimeoutCounter: Integer;
    FConnectionTimeoutLimit: Integer;

    FConnectionTimeout: TTimer;
    FStreamsTimerOut: TTimer;

    procedure OnConnectionTimeout(pSender: TObject);
    procedure OnStreamsTimeouts(pSender: TObject);
    procedure OnSocketConnected;
    procedure OnSocketDisconnected;
    procedure OnSocketRecv(const ABuffer: Pointer; const ASize: Integer);
    function OnFrameReceived(session: pnghttp2_session; session_data: TSessionContext;
      stream_data: TStreamRequest): Integer;

    procedure HandleListNotify(Sender: TObject; const Item: TStreamRequest; Action: TCollectionNotification);

    procedure ResetTimeout;

    function Send404Response(session: pnghttp2_session; stream_data: TStreamRequest): Integer;
    function SubmitResponse(session: pnghttp2_session; stream_data: TStreamRequest): Integer;
    function GetSSL: Boolean;
  protected
    FStreams: TDictionary<Integer, TStreamRequest>;
    FUnaryStreams: TObjectList<TStreamRequest>;
    function GetTotalRequestSize: Integer;
    function GetTotalResponseSize: Integer;
    function IsRequestEOF: Boolean;
    function IsResponseEOF: Boolean;
  protected
    FSession_http2: pnghttp2_session;
    FOptions_http2: pnghttp2_option;
    FCallbacks_http2: pnghttp2_session_callbacks;
    function nghttp2_Send: Boolean;
  protected
    function  Connect(const AConnectTimeout: Integer): Boolean;
    procedure ConnectAsync(pOnConnect, pOnConnectTimeout: TProc; const AConnectTimeout: Integer);
    procedure AddStream(aStream: TStreamRequest);
  public
    constructor Create(aOwner: TgoHttp2Base; aConnection: TgoSocketConnection; aCallback: pnghttp2_session_callbacks);
    destructor  Destroy; override;
    procedure   Disconnect;

    function IsConnected: Boolean;
    function IsServerContext: Boolean;
    function GetOrCreateStream(aStreamID: Integer): TStreamRequest;

    procedure HandleValueNotify(pSender: TObject; const pItem: Grijjy.Http2.TStreamRequest; pAction: TCollectionNotification);
    procedure RemoveStream(pStreamRequest: TStreamRequest);

    property OnSessionConnected: TProc read FOnSessionConnected write FOnSessionConnected;
    property OnSessionConnectedTimeout: TProc read FOnSessionConnectedTimeout write FOnSessionConnectedTimeout;
    property OnStreamFrameReceived: TStreamNotify read FOnStreamReceived write FOnStreamReceived;
    property State: TSessionState read FState;
    property SSL: Boolean read GetSSL;
    property Session_http2: pnghttp2_session read FSession_http2;
  end;

  TListenThread = class(TThread)
  protected
    FServer: TgoHttp2Server;
    FConnection: TgoSocketConnection;
    FPort: Integer;
    FAddress: string;

    procedure Execute; override;
    procedure TerminatedSet; override;
    procedure DoListen;
  public
    destructor Destroy; override;
  end;

  TBoolean = class
  private
    FValue: Boolean;
    procedure SetValue(const aValue: Boolean);
  public
    property Value: Boolean read FValue write SetValue;
    function Wait(ATimeout: Integer; aCheckSynchronize: Boolean = False): Boolean;
  end;

  IRequestThread = interface
    ['{A247BD6D-7DD8-4DD1-9D57-713C96DDB3EE}']
    procedure Close;
  end;

  TRequestThread = class(TThread, IInterface, IRequestThread)
  protected
    FRefCount: Integer;
    {IInterface}
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  protected
    {IRequestThread}
    procedure Close; virtual;
  end;

  TStreamRequest = class
  private
    {client side}
    FPath: string;
    FMethod: String;
    FInternalHeaders: TgoHttpHeaders2;
  private
    FContext: TSessionContext;
    FReqClosed, FRespClosed: TBoolean;
    FStreamID: Integer;

    FRequestBuffer: TThreadSafeBuffer;
    FRequestPath: String;
    FRequestHeaders: TgoHttpHeaders2;
    FRequestProvider: nghttp2_data_provider;
    FPendingRequest: Boolean;
    FIsUnary: Boolean;

    FResponseBuffer: TThreadSafeBuffer;
    FResponseHeaders: TgoHttpHeaders2;
    FResponseProvider: nghttp2_data_provider;
    FPendingResponse: Boolean;

    FTimeOutBegin, FTimeoutEnd: UInt64;

    FOnFrameReceived: TStreamCallback;
    FRemoveSelfFromContext: TStreamCleanup;
    FOnStreamClose: TProc<TPair<string,string>, TPair<string,string>>;
    FOnTimeout: TProc<Integer>;

    FRequestThread: IRequestThread;
    FOnDestroy: TNotifyEvent;
    procedure CreateRequest;
    function  SendRequest: Boolean;
  public
    constructor Create(aContext: TSessionContext; aStreamID: Integer); overload;
    constructor Create(aContext: TSessionContext; aPath: string); overload;
    procedure   AfterConstruction; override;
    destructor  Destroy; override;

    function  DoRequest(const AMethod, APath: String;
      const ARequest: TBytes; const AConnectTimeout, ARecvTimeout: Integer; aCloseRequest: Boolean): Boolean;

    procedure SendRequestData(const aData: TBytes; aClose: Boolean);
    procedure SendResponseData(const aData: TBytes; aClose: Boolean);
    procedure SendErrorResponse(const aException: Exception);
    function  IsRequestEOF: Boolean;
    function  IsResponseEOF: Boolean;

    function  WaitForRecvClosed(ARecvTimeout: Integer): Boolean;
    function  IsResponseClosed: Boolean;
    function  IsRequestClosed: Boolean;
    procedure CloseRequest;
    procedure CloseRequestEx(ErrorCode: Integer);
    procedure CloseResponse;

    property RequestHeaders: TgoHttpHeaders2 read FRequestHeaders;
    property RequestBuffer: TThreadSafeBuffer read FRequestBuffer;
    property RequestPath: string read FRequestPath;

    property ResponseHeaders: TgoHttpHeaders2 read FResponseHeaders;
    property ResponseBuffer: TThreadSafeBuffer read FResponseBuffer;

    property Context: TSessionContext read FContext;
    property StreamID: Integer read FStreamID;

    property RequestThread: IRequestThread read FRequestThread write FRequestThread;
    property OnFrameReceived: TStreamCallback read FOnFrameReceived write FOnFrameReceived;
    property RemoveSelfFromContext: TStreamCleanup read FRemoveSelfFromContext write FRemoveSelfFromContext;
    property OnStreamClose: TProc<TPair<string,string>, TPair<string,string>> read FOnStreamClose write FOnStreamClose;
    property OnTimeout: TProc<Integer> read FOnTimeout write FOnTimeout;
    property OnDestroy: TNotifyEvent read FOnDestroy write FOnDestroy;
    property TimeoutBegin: UInt64 read FTimeOutBegin write FTimeOutBegin;
    property TimeoutEnd: UInt64 read FTimeoutEnd write FTimeoutEnd;
    property IsUnary: Boolean read FIsUnary write FIsUnary;
  end;

implementation

uses
  Grijjy.SysUtils;

procedure OutputDebug(const aString: string);
begin
  {$ifdef MSWINDOWS}
  OutputDebugString(PChar(aString))
  {$endif}
end;

{ ngHttp2 callback cdecl }

function on_header_callback(session: pnghttp2_session; const frame: pnghttp2_frame;
  const name: puint8; namelen: size_t; const value: puint8; valuelen: size_t;
  flags: uint8; user_data: Pointer): Integer; cdecl;
var
  context: TSessionContext;
begin
  Assert(Assigned(user_data));
  context := TObject(user_data) as TSessionContext;
  Result := context.nghttp2_on_header_callback(session, frame, name, namelen, value, valuelen, flags, user_data);
end;

function on_begin_headers_callback(session: pnghttp2_session; const frame: pnghttp2_frame; user_data: Pointer): Integer; cdecl;
var
  context: TSessionContext;
  stream_data: TStreamRequest;
begin
  Assert(Assigned(user_data));
  Result := 0;
  if frame.hd.&type = _NGHTTP2_HEADERS then
  begin
    context := TObject(user_data) as TSessionContext;

    if (frame.headers.cat = NGHTTP2_HCAT_RESPONSE) then
    begin
    end
    else if (frame.headers.cat = NGHTTP2_HCAT_REQUEST) then
    begin
      stream_data := context.GetOrCreateStream(frame.hd.stream_id);
      Result := TNGHTTP2.GetInstance.nghttp2_session_set_stream_user_data(session, frame.hd.stream_id, stream_data);
    end;
  end;
end;

function on_frame_recv_callback(session: pnghttp2_session;
  const frame: pnghttp2_frame; user_data: Pointer): Integer; cdecl;
var
  context: TSessionContext;
begin
  Assert(Assigned(user_data));
  context := TObject(user_data) as TSessionContext;
  Result := context.nghttp2_on_frame_recv_callback(session, frame, user_data);
end;

function on_data_chunk_recv_callback(session: pnghttp2_session;
  flags: uint8; stream_id: int32; const data: puint8; len: size_t;
  user_data: Pointer): Integer; cdecl;
var
  context: TSessionContext;
begin
  Assert(Assigned(user_data));
  context := TObject(user_data) as TSessionContext;
  Result  := context.nghttp2_on_data_chunk_recv_callback(session, flags, stream_id, data, len, user_data);
end;

function on_stream_close_callback(session: pnghttp2_session;
  stream_id: int32; error_code: uint32; user_data: Pointer): Integer; cdecl;
var
  context: TSessionContext;
begin
  Assert(Assigned(user_data));
  context := TObject(user_data) as TSessionContext;
  Result  := context.nghttp2_on_stream_close_callback(session, stream_id, error_code, user_data);
end;

function data_source_response_read_callback(session: pnghttp2_session;
  stream_id: int32; buf: puint8; len: size_t; data_flags: puint32;
  source: pnghttp2_data_source; user_data: Pointer): ssize_t; cdecl;
var
  stream: TStreamRequest;
  ctx: TSessionContext;
begin
  ctx := TObject(user_data) as TSessionContext;
  stream := source.ptr;
  if stream = nil then
  begin
    data_flags^ := data_flags^ or NGHTTP2_DATA_FLAG_EOF;
    Exit(0);
  end;

  if NativeUInt(stream.ResponseBuffer.Size) <= len then
  begin
    Result := stream.ResponseBuffer.Size;
    if not stream.FPendingResponse then
      data_flags^ := data_flags^ or NGHTTP2_DATA_FLAG_EOF
    else if Result = 0 then
      //Result := -1;             //does not work with streaming?
      TInterlocked.Decrement(ctx.FPendingSendCount);
  end
  else
    Result := len;

  stream.ResponseBuffer.Read(buf, Result);
end;

function data_source_submit_data_read_callback(session: pnghttp2_session;
  stream_id: int32; buf: puint8; len: size_t; data_flags: puint32;
  source: pnghttp2_data_source; user_data: Pointer): ssize_t; cdecl;
var
  stream: TStreamRequest;
  ctx: TSessionContext;
begin
  ctx := TObject(user_data) as TSessionContext;
  stream := TObject(source.ptr) as TStreamRequest;

  if stream = nil then
  begin
    data_flags^ := data_flags^ or NGHTTP2_DATA_FLAG_EOF;
    Exit(0);
  end;

  if NativeUInt(stream.RequestBuffer.Size) <= len then
  begin
    Result := stream.RequestBuffer.Size;
    if not stream.FPendingRequest then
      data_flags^ := data_flags^ or NGHTTP2_DATA_FLAG_EOF
    else if Result = 0 then
      TInterlocked.Decrement(ctx.FPendingSendCount);
  end
  else
    Result := len;

  stream.RequestBuffer.Read(buf, Result);
end;

function data_source_request_read_callback(session: pnghttp2_session;
  stream_id: int32; buf: puint8; len: size_t; data_flags: puint32;
  source: pnghttp2_data_source; user_data: Pointer): ssize_t; cdecl;
var
  stream: TStreamRequest;
  ctx: TSessionContext;
begin
  ctx := TObject(user_data) as TSessionContext;
  stream := TObject(source.ptr) as TStreamRequest;

  if stream = nil then
  begin
    data_flags^ := data_flags^ or NGHTTP2_DATA_FLAG_EOF;
    Exit(0);
  end;

  if NativeUInt(stream.RequestBuffer.Size) <= len then
  begin
    Result := stream.RequestBuffer.Size;
    if not stream.FPendingRequest then
    begin
      data_flags^ := data_flags^ or NGHTTP2_DATA_FLAG_EOF;
    end
    else if Result = 0 then
      TInterlocked.Decrement(ctx.FPendingSendCount);
  end
  else
    Result := len;

  stream.RequestBuffer.Read(buf, Result);
end;

{ TgoHttpHeaders2 }

procedure TgoHttpHeaders2.AsNgHttp2Array(var AHeaders: TArray<nghttp2_nv>);
var
  Header: TgoHttpHeader;
  NgHttp2Header: nghttp2_nv;
begin
  for Header in Self.Headers do
  begin
    NgHttp2Header.name := MarshaledAString(Header.NameAsISO8859);
    NgHttp2Header.value := MarshaledAString(Header.ValueAsISO8859);
    NgHttp2Header.namelen := Length(Header.Name);
    NgHttp2Header.valuelen := Length(Header.Value);
    NgHttp2Header.flags := NGHTTP2_NV_FLAG_NONE;
    AHeaders := AHeaders + [NgHttp2Header];
  end;
end;

{ TgoHttpServer }

constructor TgoHttp2Client.Create(const aRemoteAddress: string; aRemotePort: Integer; aSSL: Boolean);
begin
  inherited Create(aRemoteAddress, aRemotePort, aSSL);

  { initialize nghttp2 library }
  if TNGHTTP2.GetInstance.nghttp2_session_callbacks_new(FCallbacks_http2) = 0 then
  begin
    TNGHTTP2.GetInstance.nghttp2_session_callbacks_set_on_header_callback(FCallbacks_http2, on_header_callback);
    TNGHTTP2.GetInstance.nghttp2_session_callbacks_set_on_begin_headers_callback(FCallbacks_http2, on_begin_headers_callback);
    TNGHTTP2.GetInstance.nghttp2_session_callbacks_set_on_frame_recv_callback(FCallbacks_http2, on_frame_recv_callback);
    TNGHTTP2.GetInstance.nghttp2_session_callbacks_set_on_data_chunk_recv_callback(FCallbacks_http2, on_data_chunk_recv_callback);
    TNGHTTP2.GetInstance.nghttp2_session_callbacks_set_on_stream_close_callback(FCallbacks_http2, on_stream_close_callback);
  end
  else
    raise Exception.Create('Unable to setup ngHttp2 callbacks.');

  FAuthorization := '';
  FUserAgent := '';
end;

destructor TgoHttp2Client.Destroy;
begin
  TNGHTTP2.GetInstance.nghttp2_session_callbacks_del(FCallbacks_http2);
  inherited Destroy;
end;

function TgoHttp2Client.DoRequest(const AMethod, APath: String; const ARequest: TBytes; const AConnectTimeout,
  ARecvTimeout: Integer): Boolean;
var
  request: TStreamRequest;
begin
  request := GetOrCreateSession.GetOrCreateStream(-1);
  Result := request.DoRequest(AMethod, APath, ARequest, AConnectTimeout, ARecvTimeout, True);
end;

procedure TgoHttp2Client.Close;
begin
  Assert(false);
end;

function TgoHttp2Client.Connect(const AConnectTimeout: Integer): TSessionContext;
begin
  Result := GetOrCreateSession;
  Result.Connect(AConnectTimeout);
end;

procedure TgoHttp2Client.ConnectAsync(pOnConnect, pOnConnectTimeout: TProc;
  const AConnectTimeout: Integer);
var
  FSession: TSessionContext;
begin
  FSession := GetOrCreateSession;
  FSession.ConnectAsync(pOnConnect, pOnConnectTimeout, AConnectTimeout);
end;

function TgoHttp2Client.GetOrCreateSession: TSessionContext;
var
  connection: TgoSocketConnection;
begin
  if FSession <> nil then
  begin
    if (FSession.FConnection = nil) or FSession.FConnection.Shutdown then
      FreeAndNil(FSession);             //todo: make this threadsafe? Use locks?
  end;

  if FSession = nil then
  begin
    connection := TgoSocketConnection.Create(HttpClientSocketManager, FAddress, FPort);

    if FSSL then
    begin
      connection.SSL := True;
      connection.ALPN := True;
      if FCertificate <> nil then
        connection.Certificate := FCertificate;
      if FPrivateKey <> nil then
        connection.PrivateKey := FPrivateKey;
    end
    else
      connection.SSL := False;

    FSession := TSessionContext.Create(Self, connection, FCallbacks_http2);
    FSessions.Add(FSession);
  end;
  Result := FSession;
end;

function TgoHttp2Client.BytesToString(const ABytes: TBytes; const ACharset: String): String;
begin
  if ACharset = 'iso-8859-1' then
    Result := TEncoding.ANSI.GetString(ABytes)
  else
  if ACharset = 'utf-8' then
    Result := TEncoding.UTF8.GetString(ABytes)
  else
    Result := TEncoding.ANSI.GetString(ABytes)
end;

function TgoHttp2Client.Get(const AURL: String; out AResponse: TBytes;
  const AConnectTimeout, ARecvTimeout: Integer): Boolean;
begin
  Result := DoRequest('GET', AURL, AResponse, AConnectTimeout, ARecvTimeout);
end;

function TgoHttp2Client.Head(const AURL: String; const AConnectTimeout, ARecvTimeout: Integer): Boolean;
var
  AResponse: TBytes;
begin
  Result := DoRequest('HEAD', AURL, AResponse, AConnectTimeout, ARecvTimeout);
end;

function TgoHttp2Client.Post(const APath: String; const ARequest: TBytes;
  const AConnectTimeout, ARecvTimeout: Integer): Boolean;
begin
  Result := DoRequest('POST', APath, ARequest, AConnectTimeout, ARecvTimeout);
end;

function TgoHttp2Client.Put(const AURL: String; out AResponse: TBytes;
  const AConnectTimeout, ARecvTimeout: Integer): Boolean;
begin
  Result := DoRequest('PUT', AURL, AResponse, AConnectTimeout, ARecvTimeout);
end;

function TgoHttp2Client.Delete(const AURL: String; out AResponse: TBytes;
  const AConnectTimeout, ARecvTimeout: Integer): Boolean;
begin
  Result := DoRequest('DELETE', AURL, AResponse, AConnectTimeout, ARecvTimeout);
end;

function TgoHttp2Client.Options(const AURL: String; out AResponse: TBytes;
  const AConnectTimeout, ARecvTimeout: Integer): Boolean;
begin
  Result := DoRequest('OPTIONS', AURL, AResponse, AConnectTimeout, ARecvTimeout);
end;

{ TgoHttpServer }

constructor TgoHttp2Server.Create(const aBindAddress: string; aBindPort: Integer; aSSL: Boolean);

begin
  inherited Create(aBindAddress, aBindPort, aSSL);

  { initialize nghttp2 library }
  if TNGHTTP2.GetInstance.nghttp2_session_callbacks_new(FCallbacks_http2) = 0 then
  begin
    TNGHTTP2.GetInstance.nghttp2_session_callbacks_set_on_header_callback(FCallbacks_http2, on_header_callback);
    TNGHTTP2.GetInstance.nghttp2_session_callbacks_set_on_begin_headers_callback(FCallbacks_http2, on_begin_headers_callback);

    TNGHTTP2.GetInstance.nghttp2_session_callbacks_set_on_frame_recv_callback(FCallbacks_http2, on_frame_recv_callback);
    TNGHTTP2.GetInstance.nghttp2_session_callbacks_set_on_data_chunk_recv_callback(FCallbacks_http2, on_data_chunk_recv_callback);
    TNGHTTP2.GetInstance.nghttp2_session_callbacks_set_on_stream_close_callback(FCallbacks_http2, on_stream_close_callback);
  end
  else
    raise Exception.Create('Unable to setup ngHttp2 callbacks.');
end;

{ TListenThread }

procedure TListenThread.Execute;
begin
  inherited;
  NameThreadForDebugging(Self.ClassName);

  System.TMonitor.Enter(Self);
  DoListen;
  //wait till terminated
  while not Terminated do
    System.TMonitor.Wait(Self, 5*1000);

  FConnection.CloseAccept;
  FConnection.Free;
end;

procedure TListenThread.TerminatedSet;
begin
  inherited;
  System.TMonitor.Pulse(Self);
end;

destructor TListenThread.Destroy;
begin
  inherited;
end;

procedure TListenThread.DoListen;
begin
  FConnection := TgoSocketConnection.Create(HttpClientSocketManager, FAddress, FPort);
  FConnection.OnAccept := FServer.OnSocketAccepted;

  if not FConnection.Accept(False{no nagle}) then
    Assert(False, 'accept failed');
end;

{ TgoHttp2Server }

destructor TgoHttp2Server.Destroy;
begin
  Stop;
  inherited;
end;

procedure TgoHttp2Server.OnSocketAccepted(aConnection: TgoSocketConnection);
var
  session: TSessionContext;
begin
  session := TSessionContext.Create(Self, aConnection, FCallbacks_http2);

  System.TMonitor.Enter(FSessions);
  try
    FSessions.Add(session);
  finally
    System.TMonitor.Exit(FSessions);
  end;

  aConnection.OnRecv := session.OnSocketRecv;
  session.OnStreamFrameReceived := Self.OnStreamFrameReceived;
end;

procedure TgoHttp2Server.StartListen;
var thread: TListenThread;
begin
  thread := TListenThread.Create(True{suspended});
  FListenThread := thread;

  thread.FAddress := BindAddress; // '127.0.0.1';
  thread.FPort := BindPort; // 1000;
  thread.FServer := Self;
  thread.Start;
end;

procedure TgoHttp2Server.Stop;
var
  session: TSessionContext;
begin
  if FListenThread <> nil then
  begin
    FListenThread.Terminate;
    FListenThread.WaitFor;
    FListenThread.Free;
    FListenThread := nil;
  end;

  System.TMonitor.Enter(FSessions);
  try
    for session in FSessions do
      session.Disconnect;
    FSessions.Clear;
  finally
    System.TMonitor.Exit(FSessions);
  end;
end;

{ TSessionContext }

procedure TSessionContext.AddStream(aStream: TStreamRequest);
begin
  System.TMonitor.Enter(FStreams);
  System.TMonitor.Enter(FUnaryStreams);
  try
    FStreams.AddOrSetValue(aStream.StreamID, aStream);
    if (aStream.IsUnary) and (not FUnaryStreams.Contains(aStream)) then
      FUnaryStreams.Add(aStream);
  finally
    System.TMonitor.Exit(FStreams);
    System.TMonitor.Exit(FUnaryStreams);
  end;
end;

function TSessionContext.Connect(const AConnectTimeout: Integer): Boolean;
var
  connection: TgoSocketConnection;
begin
  if IsConnected then
    Exit(True);

  if FConnection.Shutdown then
  begin
    connection := TgoSocketConnection.Create(HttpClientSocketManager, FConnection.Hostname, FConnection.Port);
    FConnection.Free;
    FConnection := connection;
    FConnection.OnConnected := Self.OnSocketConnected;
    FConnection.OnDisconnected := Self.OnSocketDisconnected;
    FConnection.OnRecv := Self.OnSocketRecv;
  end;

  if SSL then
  begin
    FConnection.SSL  := True;
    FConnection.ALPN := True;

    if FHttpOwner.FCertificate <> nil then
      FConnection.Certificate := FHttpOwner.FCertificate;
    if FHttpOwner.FPrivateKey <> nil then
      FConnection.PrivateKey := FHttpOwner.FPrivateKey;
  end;

  FConnected.ResetEvent;
  FConnection.Connect(False{no nagle});
  FState := TSessionState.Connecting;
  Result := FConnected.WaitFor(AConnectTimeout) <> wrTimeout;

  if IsConnected then
    Exit(True);
end;

procedure TSessionContext.ConnectAsync(pOnConnect, pOnConnectTimeout: TProc; const AConnectTimeout: Integer);
var
  connection: TgoSocketConnection;
begin
  if IsConnected then
    Exit;

  if State in [TSessionState.Connecting, TSessionState.Connected] then
    Exit;

  FConnectionTimeoutLimit := AConnectTimeout;
  OnSessionConnected := pOnConnect;
  OnSessionConnectedTimeout := pOnConnectTimeout;

  if FConnection.Shutdown then
  begin
    connection := TgoSocketConnection.Create(HttpClientSocketManager, FConnection.Hostname, FConnection.Port);
    FConnection.Free;
    FConnection := connection;
    FConnection.OnConnected := Self.OnSocketConnected;
    FConnection.OnDisconnected := Self.OnSocketDisconnected;
    FConnection.OnRecv := Self.OnSocketRecv;
  end;

  if SSL then
  begin
    FConnection.SSL  := True;
    FConnection.ALPN := True;

    if FHttpOwner.FCertificate <> nil then
      FConnection.Certificate := FHttpOwner.FCertificate;
    if FHttpOwner.FPrivateKey <> nil then
      FConnection.PrivateKey := FHttpOwner.FPrivateKey;
  end;

  FConnected.ResetEvent;
  FState := TSessionState.Connecting;
  FConnection.Connect(False);
  FConnectionTimeout.Enabled := True;
end;

constructor TSessionContext.Create(aOwner: TgoHttp2Base; aConnection: TgoSocketConnection; aCallback: pnghttp2_session_callbacks);
var
  settings: nghttp2_settings_entry;
  error: Integer;
begin
  FHttpOwner := aOwner;
  FConnection := aConnection;
  FConnection.OnConnected := Self.OnSocketConnected;
  FConnection.OnDisconnected := Self.OnSocketDisconnected;
  FConnection.OnRecv := Self.OnSocketRecv;
  FState := TSessionState.Disconnected;
  FConnectionTimeoutCounter := 0;
  FCallbacks_http2 := aCallback;

  FStreamsTimerOut := TTimer.Create(nil);
  FStreamsTimerOut.Interval := 1000;
  FStreamsTimerOut.Enabled := False;
  FStreamsTimerOut.OnTimer := OnStreamsTimeouts;

  FConnectionTimeout := TTimer.Create(nil);
  FConnectionTimeout.Interval := 1000;
  FConnectionTimeout.Enabled := False;
  FConnectionTimeout.OnTimer := OnConnectionTimeout;

  FStreams := TObjectDictionary<Integer, TStreamRequest>.Create;
  FStreams.OnValueNotify := HandleValueNotify;
  FUnaryStreams := TObjectList<TStreamRequest>.Create(False);
  FUnaryStreams.OnNotify := HandleListNotify;

  //init client or server session
  if IsServerContext then
  begin
    error := TNGHTTP2.GetInstance.nghttp2_session_server_new(FSession_http2, FCallbacks_http2, Self)
  end
  else
  begin
    error := TNGHTTP2.GetInstance.nghttp2_session_client_new(FSession_http2, FCallbacks_http2, Self);
    FConnected := TEvent.Create(nil, False, False, '');
  end;
  if error <> 0 then
    raise Exception.CreateFmt('Unable to setup ngHttp2 session (errorcode: %d)', [error]);

  {$IFNDEF WIN32}
  if TNGHTTP2.GetInstance.nghttp2_option_new(FOptions_http2) = 0 then
    TNGHTTP2.GetInstance.nghttp2_option_set_no_closed_streams(FOptions_http2, 1);
  {$ENDIF WIN32}

  //init settings
  settings.settings_id := NGHTTP2_SETTINGS_ENABLE_PUSH;
  settings.value := 0;
  error := TNGHTTP2.GetInstance.nghttp2_submit_settings(FSession_http2, NGHTTP2_FLAG_NONE, @settings, 1);
  if (error <> 0) then
    raise Exception.CreateFmt('Unable to submit ngHttp2 settings (errorcode: %d)', [error]);

  settings.settings_id := NGHTTP2_SETTINGS_MAX_CONCURRENT_STREAMS;
  settings.value := 300;
  error := TNGHTTP2.GetInstance.nghttp2_submit_settings(FSession_http2, NGHTTP2_FLAG_NONE, @settings, 1);
  if (error <> 0) then
    raise Exception.CreateFmt('Unable to submit ngHttp2 settings (errorcode: %d)', [error]);

  settings.settings_id := NGHTTP2_SETTINGS_INITIAL_WINDOW_SIZE;
  settings.value := 1048576;
  error := TNGHTTP2.GetInstance.nghttp2_submit_settings(FSession_http2, NGHTTP2_FLAG_NONE, @settings, 1);
  if (error <> 0) then
    raise Exception.CreateFmt('Unable to submit ngHttp2 settings (errorcode: %d)', [error]);

  settings.settings_id := NGHTTP2_SETTINGS_MAX_HEADER_LIST_SIZE;
  settings.value := 16384;
  error := TNGHTTP2.GetInstance.nghttp2_submit_settings(FSession_http2, NGHTTP2_FLAG_NONE, @settings, 1);
  if (error <> 0) then
    raise Exception.CreateFmt('Unable to submit ngHttp2 settings (errorcode: %d)', [error]);
end;

destructor TSessionContext.Destroy;
begin
  FStreamsTimerOut.Free;
  FConnectionTimeout.Free;
  FStreams.Free;
  FUnaryStreams.Free;
  {$IFNDEF WIN32}
  TNGHTTP2.GetInstance.nghttp2_option_del(FOptions_http2);
  {$ENDIF}
  TNGHTTP2.GetInstance.nghttp2_session_terminate_session(FSession_http2, NGHTTP2_NO_ERROR);
  TNGHTTP2.GetInstance.nghttp2_session_del(FSession_http2);
  Disconnect;
  FConnected.Free;
  FOnSessionConnected := nil;
  FOnSessionConnectedTimeout := nil;
  inherited;
end;

procedure TSessionContext.Disconnect;
begin
  if Self.FConnection <> nil then
  begin
    System.TMonitor.Enter(Self);
    try
      HttpClientSocketManager.Release(Self.FConnection);
      FConnection := nil;
      FState := TSessionState.Disconnected;
    finally
      System.TMonitor.Exit(Self);
    end;
  end;
end;

function TSessionContext.nghttp2_Send: Boolean;
var
  data: Pointer;
  len: Integer;
  bytes: TBytes;
  iLoop: Integer;
begin
  Result := True;
  System.TMonitor.Enter(Self);
  try
    if FConnection = nil then
      Exit(False);

    iLoop := TNGHTTP2.GetInstance.nghttp2_session_want_write(FSession_http2);
    TInterlocked.Increment(Self.FPendingSendCount);

    //see data_source_response_read_callback
    while TNGHTTP2.GetInstance.nghttp2_session_want_write(FSession_http2) > 0 do
    begin
      len := TNGHTTP2.GetInstance.nghttp2_session_mem_send(FSession_http2, data);

      if (len > 0) then
      begin
        SetLength(bytes, len);
        Move(data^, bytes[0], len);

        if FPendingSendCount <= 0 then  //no more data? nghttp2_session_mem_send always generates empty data (9 zero bytes?)
        begin
          dec(iLoop);
          if iLoop < 0 then
          begin
            FPendingSendCount := 0;
            Break;
          end;
        end
        else if FConnection.Send(bytes) then
        begin
          Result := True;
        end
        else
        begin
          Break;
        end;
      end
      else
      begin
        // there can be more than one stream without EOF (not closed yet), so countdown till we have had all streams (and not infinite loop!)
        dec(iLoop);
        if iLoop < 0 then
          Break;
      end;

      if not Result then
        Break;
    end;
  finally
    System.TMonitor.Exit(Self);
  end;
end;

function TSessionContext.nghttp2_on_data_chunk_recv_callback(session: pnghttp2_session;
  flags: uint8; stream_id: int32; const data: puint8; len: size_t;
  user_data: Pointer): Integer;
var
  stream: TStreamRequest;
begin
  stream := GetOrCreateStream(stream_id);

  if IsServerContext then
    stream.RequestBuffer.Write(data, len)
  else
    stream.ResponseBuffer.Write(data, len);
  Result := 0;
end;

function TSessionContext.nghttp2_on_stream_close_callback(session: pnghttp2_session;
  stream_id: int32; error_code: uint32; user_data: Pointer): Integer;
var
  stream: TStreamRequest;
  Header: TgoHttpHeader;
  vGrpcStatus, vGrpcMessage: TPair<string, string>;
begin
  stream := GetOrCreateStream(stream_id);

  if IsServerContext then
    stream.CloseRequest
  else
    stream.CloseResponse;
  Result := 0;

  if stream.ResponseBuffer.Size > 0 then
    Result := OnFrameReceived(session, Self, stream);

  if Assigned(stream.OnStreamClose) then
  begin
    for Header in stream.ResponseHeaders.Headers do
      if Header.Name = 'grpc-status' then
      begin
        vGrpcStatus.Key := Header.Name;
        vGrpcStatus.Value := Header.Value;
      end
      else if Header.Name = 'grpc-message' then
      begin
        vGrpcMessage.Key := Header.Name;
        vGrpcMessage.Value := Header.Value;
      end;
    stream.OnStreamClose(vGrpcStatus, vGrpcMessage);
  end;

  if Assigned(stream.RemoveSelfFromContext) then
    stream.RemoveSelfFromContext(stream);

  { Note : connection is still open at this point unless you call
    nghttp2_session_terminate_session(session, NGHTTP2_NO_ERROR) }
end;

function TSessionContext.nghttp2_on_frame_recv_callback(session: pnghttp2_session;
  const frame: pnghttp2_frame; user_data: Pointer): Integer;
var
  stream_data: TStreamRequest;
  context: TSessionContext;
begin
  Result := 0;
  context := TObject(user_data) as TSessionContext;

  case frame.hd.&type of
    NGHTTP2_DATA,
    _NGHTTP2_HEADERS:
    // Checks that the client request has finished
    begin
      stream_data := TNGHTTP2.GetInstance.nghttp2_session_get_stream_user_data(session, frame.hd.stream_id);
      // For DATA and HEADERS frame, this callback may be called after on_stream_close_callback. Check that stream still alive. */
      if stream_data = nil then
        Exit(0);

      // TODO -> Create a OnHeadersDone event on TStreamRequest
      // if (frame.hd.&type = _NGHTTP2_HEADERS) and (frame.hd.flags = NGHTTP2_FLAG_END_HEADERS) then
      //   if Assigned(stream_data.OnHeadersDone)
      //     stream_data.OnHeadersDone;

      //Golang sometimes sends an EOF on a HEADER
      if (frame.hd.flags AND NGHTTP2_DATA_FLAG_EOF > 0) then
      begin
        if IsServerContext then
          stream_data.CloseRequest
        else
          stream_data.CloseResponse;
      end;

      Result := OnFrameReceived(session, context, stream_data);
    end;
  end;
end;

//nghttp2_on_header_callback: Called when nghttp2 library emits single header name/value pair.
function TSessionContext.nghttp2_on_header_callback(session: pnghttp2_session; const frame: pnghttp2_frame;
  const name: puint8; namelen: size_t; const value: puint8; valuelen: size_t; flags: uint8;
  user_data: Pointer): Integer;
var
  AName, AValue: String;
  stream_data: TStreamRequest;
begin
  if frame.hd.&type = _NGHTTP2_HEADERS then
  begin
    AName := TEncoding.ASCII.GetString(BytesOf(name, namelen));
    AValue := TEncoding.ASCII.GetString(BytesOf(value, valuelen));
    if (frame.headers.cat = NGHTTP2_HCAT_RESPONSE) or (frame.headers.cat = NGHTTP2_HCAT_HEADERS) then
    begin
      stream_data := TNGHTTP2.GetInstance.nghttp2_session_get_stream_user_data(session, frame.hd.stream_id);
      stream_data.ResponseHeaders.AddOrSet(AName, AValue);
    end
    else if (frame.headers.cat = NGHTTP2_HCAT_REQUEST) then
    begin
      stream_data := TNGHTTP2.GetInstance.nghttp2_session_get_stream_user_data(session, frame.hd.stream_id);
      stream_data.RequestHeaders.AddOrSet(AName, AValue);

      { path }
      if AName = ':path' then
      begin
        stream_data.FRequestPath := PChar(AValue);          //percent_decode?
      end;
    end;
  end;
  Result := 0;
end;

procedure TSessionContext.OnConnectionTimeout(pSender: TObject);
begin
  Inc(FConnectionTimeoutCounter);
  if FConnectionTimeoutCounter >= FConnectionTimeoutLimit then
  begin
    ResetTimeout;
    if Assigned(Self.OnSessionConnectedTimeout) then
      Self.OnSessionConnectedTimeout();
    Self.Disconnect;
  end;
end;

function TSessionContext.OnFrameReceived(session: pnghttp2_session; session_data: TSessionContext; stream_data: TStreamRequest): Integer;
var
  handled: Boolean;
begin
  Result := 0;
  handled := False;
  if Assigned(stream_data.OnFrameReceived) then
    stream_data.OnFrameReceived(stream_data, handled);

  if not handled and Assigned(OnStreamFrameReceived) then
    OnStreamFrameReceived(stream_data, handled);

  if not handled and IsServerContext then
    Exit(Send404Response(session, stream_data));
end;

function TSessionContext.Send404Response(session: pnghttp2_session; stream_data: TStreamRequest): Integer;
const
  ERROR_HTML = '<html><head><title>404</title></head>' + '<body><h1>404 Not Found</h1></body></html>';
var
  b: TBytes;
begin
  stream_data.ResponseHeaders.AddOrSet(':status', '404');

  b := TEncoding.UTF8.GetBytes(ERROR_HTML);
  stream_data.ResponseBuffer.Write(b);

  Result := SubmitResponse(session, stream_data);
end;

function TSessionContext.SubmitResponse(session: pnghttp2_session; stream_data: TStreamRequest): Integer;
var
  ngheaders: TArray<nghttp2_nv>;
begin
  { setup data callback }
  if stream_data.FResponseProvider.source.ptr = nil then
  begin
    stream_data.ResponseHeaders.AsNgHttp2Array(ngheaders);
    stream_data.FResponseProvider.source.ptr := stream_data;
    stream_data.FResponseProvider.read_callback := data_source_response_read_callback;

    System.TMonitor.Enter(Self);
    try
      if stream_data.ResponseBuffer.Size > 0 then
        Result := TNGHTTP2.GetInstance.nghttp2_submit_response(session, stream_data.StreamID, @ngheaders[0], Length(ngheaders), @stream_data.FResponseProvider)
      else
        Result := TNGHTTP2.GetInstance.nghttp2_submit_response(session, stream_data.StreamID, @ngheaders[0], Length(ngheaders), nil);
    finally
      System.TMonitor.Exit(Self);
    end;
  end
  else
    Result := 0;

  if not nghttp2_Send then
    Assert(False, 'submit response failed');
end;

function TSessionContext.GetOrCreateStream(aStreamID: Integer): TStreamRequest;
begin
  System.TMonitor.Enter(FStreams);
  try
    if not FStreams.TryGetValue(aStreamID, Result) then
    begin
      Result := TStreamRequest.Create(Self, aStreamID);
      Result.RemoveSelfFromContext := RemoveStream;
      if aStreamID >= 0 then
        AddStream(Result);
    end;
  finally
    System.TMonitor.Exit(FStreams);
  end;
end;

function TSessionContext.GetSSL: Boolean;
begin
  Result := FHttpOwner.FSSL;
end;

function TSessionContext.IsConnected: Boolean;
begin
  Result := (FConnection.State = TgoConnectionState.Connected);
end;

function TSessionContext.IsRequestEOF: Boolean;
var
  strm: TStreamRequest;
begin
  Result := True;
  System.TMonitor.Enter(FStreams);
  try
    for strm in FStreams.Values do
      if not strm.IsRequestEOF then
        Exit(False);
  finally
    System.TMonitor.Exit(FStreams);
  end;
end;

function TSessionContext.IsResponseEOF: Boolean;
var
  strm: TStreamRequest;
begin
  Result := True;
  System.TMonitor.Enter(FStreams);
  try
    for strm in FStreams.Values do
      if not strm.IsResponseEOF then
        Exit(False);
  finally
    System.TMonitor.Exit(FStreams);
  end;
end;

function TSessionContext.GetTotalRequestSize: Integer;
var strm: TStreamRequest;
begin
  Result := 0;
  System.TMonitor.Enter(FStreams);
  try
    for strm in FStreams.Values do
      Inc(Result, strm.RequestBuffer.Size);
  finally
    System.TMonitor.Exit(FStreams);
  end;
end;

function TSessionContext.GetTotalResponseSize: Integer;
var strm: TStreamRequest;
begin
  Result := 0;
  System.TMonitor.Enter(FStreams);
  try
    for strm in FStreams.Values do
      Inc(Result, strm.ResponseBuffer.Size);
  finally
    System.TMonitor.Exit(FStreams);
  end;
end;

procedure TSessionContext.HandleListNotify(Sender: TObject;
  const Item: TStreamRequest; Action: TCollectionNotification);
begin
  if FUnaryStreams.Count = 0 then
    FStreamsTimerOut.Enabled := False
  else
    FStreamsTimerOut.Enabled := True;
end;

procedure TSessionContext.HandleValueNotify(pSender: TObject;
  const pItem: Grijjy.Http2.TStreamRequest; pAction: TCollectionNotification);
begin
  if pAction in [TCollectionNotification.cnExtracting, TCollectionNotification.cnRemoved] then
    if pItem <> nil then
      pItem.Free;
end;

function TSessionContext.IsServerContext: Boolean;
begin
  Result := FHttpOwner is TgoHttp2Server;
end;

procedure TSessionContext.OnSocketConnected;
begin
//  if Assigned(FOnSessionConnected) then
//    FOnSessionConnected;
  if FConnected <> nil then
    FConnected.SetEvent;
  FState := TSessionState.Connected;
//  ResetTimeout;
end;

procedure TSessionContext.OnSocketDisconnected;
begin
  System.TMonitor.Enter(Self);
  try
    HttpClientSocketManager.Release(Self.FConnection);
    Self.FConnection := nil;
    FState := TSessionState.Disconnected;
  finally
    System.TMonitor.Exit(Self);
  end;
end;

{ OnSocketRecv can be called by multiple threads from the socket pool in relation
  to the same http request.  These threads are always different from the main
  thread.  This can create issues with FIFO buffer ordering so we write the buffer
  into our main buffer in a thread safe manner, and we do it as quickly as possible. }
procedure TSessionContext.OnSocketRecv(const ABuffer: Pointer; const ASize: Integer);
begin
  TNGHTTP2.GetInstance.nghttp2_session_mem_recv(FSession_http2, ABuffer, ASize);
end;

procedure TSessionContext.OnStreamsTimeouts(pSender: TObject);
var
  vStream: TStreamRequest;
  vStreamCount: Integer;
begin
  System.TMonitor.Enter(FUnaryStreams);
  try
    if FUnaryStreams.Count <> 0 then
      for vStreamCount := FUnaryStreams.Count - 1 downto 0 do
      begin
        vStream := FUnaryStreams[vStreamCount];
        if vStream = nil then
          Continue;

        vStream.TimeoutBegin := vStream.TimeoutBegin + 1;

        if vStream.TimeOutEnd = 0 then
        begin
          vStream.CloseRequestEx(NGHTTP2_REFUSED_STREAM);
          vStream.RemoveSelfFromContext(vStream);
          Continue;
        end;

        if not vStream.IsUnary then
        begin
          FUnaryStreams.Extract(vStream);
          Continue;
        end;

        if vStream.IsResponseClosed or vStream.IsRequestClosed  then
        begin
          FUnaryStreams.Extract(vStream);
          Continue;
        end;

        if vStream.TimeoutBegin >= (vStream.TimeOutEnd + 1) then
        begin
          if Assigned(vStream.OnTimeout) then
            vStream.OnTimeout(vStream.StreamID);
          vStream.CloseRequestEx(NGHTTP2_REFUSED_STREAM);
          vStream.RemoveSelfFromContext(vStream);
        end;
      end;
  finally
    System.TMonitor.Exit(FUnaryStreams);
  end;
end;

procedure TSessionContext.RemoveStream(pStreamRequest: TStreamRequest);
begin
  System.TMonitor.Enter(FStreams);
  System.TMonitor.Enter(FUnaryStreams);

  FUnaryStreams.Remove(pStreamRequest);
  FStreams.Remove(pStreamRequest.StreamID);

  System.TMonitor.Exit(FStreams);
  System.TMonitor.Exit(FUnaryStreams);
end;

procedure TSessionContext.ResetTimeout;
begin
  FConnectionTimeout.Enabled := False;
  FConnectionTimeoutCounter := 0;
  FConnectionTimeoutLimit := 0;
end;

{ TStreamRequest }

constructor TStreamRequest.Create(aContext: TSessionContext; aStreamID: Integer);
begin
  FContext := aContext;
  FStreamID := aStreamID;
end;

procedure TStreamRequest.CloseRequest;
begin
  FReqClosed.Value := True;
end;

procedure TStreamRequest.CloseRequestEx(ErrorCode: Integer);
begin
  if not (ErrorCode in [0..13]) then
    Exit;
  TNGHTTP2.GetInstance.nghttp2_submit_rst_stream(FContext.Session_http2, NGHTTP2_FLAG_NONE, FStreamID, ErrorCode);
  SendRequestData(nil, True);
end;

procedure TStreamRequest.CloseResponse;
begin
  FRespClosed.Value := True;
end;

constructor TStreamRequest.Create(aContext: TSessionContext; aPath: string);
begin
  FContext := aContext;
  FPath    := aPath;
end;

procedure TStreamRequest.AfterConstruction;
begin
  inherited;
  FIsUnary := False;
  FRequestHeaders := TgoHttpHeaders2.Create;
  FRequestBuffer := TThreadSafeBuffer.Create;

  FResponseBuffer := TThreadSafeBuffer.Create;
  FResponseHeaders := TgoHttpHeaders2.Create;
  FInternalHeaders := TgoHttpHeaders2.Create;

  FReqClosed  := TBoolean.Create;
  FRespClosed := TBoolean.Create;
  FTimeOutBegin := 0;
end;

procedure TStreamRequest.CreateRequest;
var
  _Username: String;
  _Password: String;
begin
  FInternalHeaders.Headers := nil;

  { credentials provided? }
  _Username := (FContext.FHttpOwner as TgoHttp2Client).FUserName;
  _Password := (FContext.FHttpOwner as TgoHttp2Client).FPassword;

  { add method }
  FInternalHeaders.AddOrSet(':method', FMethod.ToUpper);

  { add scheme }
  if FContext.FConnection.SSL then
    FInternalHeaders.AddOrSet(':scheme', 'https')
  else
    FInternalHeaders.AddOrSet(':scheme', 'http');

  { add path }
  FInternalHeaders.AddOrSet(':path', FPath);

  if (FContext.FHttpOwner as TgoHttp2Client).FAuthority <> '' then
    FInternalHeaders.AddOrSet(':authority', (FContext.FHttpOwner as TgoHttp2Client).FAuthority) //'speech.googleapis.com:443');
  else   //not both for google apis?
    { add host }
    FInternalHeaders.AddOrSet('host', Self.Context.FHttpOwner.FAddress);

  { add authorization }
  if (_Username <> '') then
  begin
    { basic authentication }
    FInternalHeaders.AddOrSet('authorization', 'Basic ' +
      TEncoding.Utf8.GetString(goBase64Encode(TEncoding.Utf8.GetBytes(_Username + ':' + _Password))));
  end
  else
    if ((FContext.FHttpOwner as TgoHttp2Client).FAuthorization <> '') then
      FInternalHeaders.AddOrSet('authorization', (FContext.FHttpOwner as TgoHttp2Client).FAuthorization);
end;

destructor TStreamRequest.Destroy;
begin
  if RequestThread <> nil then
  begin
    RequestThread.Close;
    RequestThread := nil;
  end;
  if Assigned(OnDestroy) then
    OnDestroy(Self);
  FInternalHeaders.Free;
  FRequestHeaders.Free;
  FRequestBuffer.Free;
  FResponseBuffer.Free;
  FResponseHeaders.Free;
  FReqClosed.Free;
  FRespClosed.Free;
  inherited;
end;

function TStreamRequest.DoRequest(const AMethod, APath: String; const ARequest: TBytes; const AConnectTimeout,
  ARecvTimeout: Integer; aCloseRequest: Boolean): Boolean;

  function Connect: Boolean;
  begin
    Result := FContext.Connect(AConnectTimeout);
  end;

begin
  Result := False;
  FPath := aPath;
  FMethod := AMethod;
  FPendingRequest := not aCloseRequest;
  CreateRequest;
  if Connect then
  begin
    FRequestBuffer.Write(ARequest);
    Result := SendRequest;
  end;
end;

function TStreamRequest.SendRequest: Boolean;
var
  headers: TArray<nghttp2_nv>;
  priority: nghttp2_priority_spec;
begin
  Result := False;
  if (FContext <> nil) then
  begin
    { setup data callback }
    FRequestProvider.source.ptr := Self;
    FRequestProvider.read_callback := data_source_request_read_callback;

    { create nghttp2 compatible headers }
    FInternalHeaders.AsNgHttp2Array(headers);
    FRequestHeaders.AsNgHttp2Array(headers);

    { submit request }
    System.TMonitor.Enter(FContext);
    try
      TNGHTTP2.GetInstance.nghttp2_priority_spec_init(@priority, 0, 255, 1);
      TNGHTTP2.GetInstance.nghttp2_session_change_stream_priority(FContext.Session_http2, Self.FStreamID, @priority);
      FStreamId := TNGHTTP2.GetInstance.nghttp2_submit_request(FContext.FSession_http2, @priority, @headers[0], Length(headers), @FRequestProvider, Self);
    finally
      System.TMonitor.Exit(FContext);
    end;

    if FStreamId >= 0 then
    begin
      Self.FStreamID := FStreamID;
      FContext.AddStream(Self);
      Result := FContext.nghttp2_Send;
    end;
  end;
end;

function TStreamRequest.IsResponseClosed: Boolean;
begin
  Result := FRespClosed.Value;
end;

function TStreamRequest.IsRequestClosed: Boolean;
begin
  Result := FReqClosed.Value;
end;

function TStreamRequest.IsRequestEOF: Boolean;
begin
  Result := FRequestBuffer.Size <= 0;
end;

function TStreamRequest.IsResponseEOF: Boolean;
begin
  Result := FResponseBuffer.Size <= 0;
end;

procedure TStreamRequest.SendRequestData(const aData: TBytes; aClose: Boolean);
var
  priority: nghttp2_priority_spec;
begin
  if Self.FReqClosed.Value then
    Assert(False, 'Cannot send: request already closed');    //todo: better exception handling

  FPendingRequest := not aClose;
  if aClose then
    Self.FReqClosed.Value := True;

  TNGHTTP2.GetInstance.nghttp2_priority_spec_init(@priority, 0, 255, 1);
  TNGHTTP2.GetInstance.nghttp2_session_change_stream_priority(FContext.Session_http2, Self.FStreamID, @priority);

  FRequestBuffer.Write(aData);
  if not FContext.nghttp2_Send and not aClose then
    Assert(False, 'Send failed');    //todo: better exception handling
end;

procedure TStreamRequest.SendResponseData(const aData: TBytes; aClose: Boolean);
begin
  FResponseHeaders.AddOrSet(':status', '200');
  FResponseHeaders.AddOrSet('content-type', 'application/grpc');
  FPendingResponse := True;
  FResponseBuffer.Write(aData);
  FContext.SubmitResponse(Self.FContext.FSession_http2, Self);

  if aClose then
  begin
    FPendingResponse := False;
    Self.FRespClosed.Value := True;
    FResponseHeaders.Headers := nil;
    FResponseHeaders.AddOrSet('grpc-status', '0');
    FResponseHeaders.AddOrSet('grpc-message', '');
    Self.FResponseProvider.source.ptr := nil;
    FContext.SubmitResponse(Self.FContext.FSession_http2, Self);
  end;
end;

procedure TStreamRequest.SendErrorResponse(const aException: Exception);
begin
  FResponseHeaders.AddOrSet(':status', '500');
  FResponseHeaders.AddOrSet('content-type', 'application/grpc');
  //https://github.com/grpc/grpc-go/blob/master/codes/codes.go
  FResponseHeaders.AddOrSet('grpc-status', '2');  //unknown, exception
  FResponseHeaders.AddOrSet('grpc-message', aException.Message);
end;

function TStreamRequest.WaitForRecvClosed(ARecvTimeout: Integer): Boolean;
begin
  Result := FRespClosed.Value;
  if not Result then
    Result := FRespClosed.Wait(ARecvTimeout);
end;

constructor TgoHttp2Base.Create(const aAddress: string; aPort: Integer; aSSL: Boolean);
begin
  FAddress := aAddress;
  FPort := aPort;
  FSSL := aSSL;

  FSessions := TObjectList<TSessionContext>.Create(True);
end;

{ TBoolean }

procedure TBoolean.SetValue(const aValue: Boolean);
begin
  FValue := aValue;
  System.TMonitor.PulseAll(Self);
end;

function TBoolean.Wait(ATimeout: Integer; aCheckSynchronize: Boolean): Boolean;
var
  tStart: TDateTime;
  mainthread: Boolean;
begin
  mainthread := (TThread.CurrentThread.ThreadID = MainThreadID);

  if aCheckSynchronize then
  begin
    tStart := Now;
    repeat
      if Self.Value then Break;
      if mainthread then
        CheckSynchronize(10);
      if Self.Wait(10, False) then Break;
    until MilliSecondsBetween(Now, tStart) > ATimeout;
  end
  else if not Self.Value then
  begin
    System.TMonitor.Enter(Self);
    System.TMonitor.Wait(Self, ATimeout);
  end;
  Result := Self.Value;
end;

destructor TgoHttp2Base.Destroy;
begin
  FreeAndNil(FSessions);
  inherited;
end;

{ TRequestThread }

procedure TRequestThread.Close;
begin
  while not Started do
    Sleep(1);
  Terminate;
end;

function TRequestThread.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TRequestThread._AddRef: Integer;
begin
{$IFNDEF AUTOREFCOUNT}
  Result := AtomicIncrement(FRefCount);
{$ELSE}
  Result := __ObjAddRef;
{$ENDIF}
end;

function TRequestThread._Release: Integer;
begin
{$IFNDEF AUTOREFCOUNT}
  Result := AtomicDecrement(FRefCount);
  if Result = 0 then
    Destroy;
{$ELSE}
  Result := __ObjRelease;
{$ENDIF}
end;

end.
