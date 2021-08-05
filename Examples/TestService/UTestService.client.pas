unit UTestService.client;

interface

uses
  System.SysUtils, System.Generics.Collections,
  Grijjy.ProtocolBuffers,
  Ultraware.Grpc,
  UTestService.proto, UTestService.grpc;

type
  TTestService = class(TGrpcClientHandler, ITestService)
  strict private
    fBeginStreams, fBeginStreamsEx: TList<IGrpcStream>;
    fClientStreams: TList<ISendClientStream>;
    fClientStreamsEx: TList<ISendClientStreamEx>;
    fDuplexStreams: TList<ISendDuplexStream>;
  public
    {TGrpcClientHandler}
    constructor Create(const aGrpcClient: IGrpcClient); override;
    destructor Destroy; override;
    {ITestService}
    procedure CheckAllTypesAsync(pCallback: TAsyncAllTypesRequestCallback; pOnTimeout: TProc<Integer> = nil);
    procedure OneSimpleAsync(pCallback: TAsyncOneSimpleRequestCallback; pOnTimeout: TProc<Integer> = nil);
    procedure DoubleSimpleAsync(pSimpleData: Simple; pCallback: TAsyncOneSimpleRequestCallback; pOnTimeout: TProc<Integer> = nil);
    procedure SaveSimpleAsync(pSimpleData: Simple; pOnStreamClose: TProc<TPair<string, string>, TPair<string, string>> = nil; pOnTimeout: TProc<Integer> = nil);
    procedure RepSimpleAsync(pRepAllTypes: RepAllTypes; pCallback: TAsyncRepAllTypesRequestCallback; pOnTimeout: TProc<Integer> = nil);
    procedure EmbeddedMessageSimple(pEmbSimple: EmbeddedSimple; pCallback: TAsyncEmbeddedMessageSimpleCallback; pOnTimeout: TProc<Integer> = nil);
    procedure EmbeddedMessageComplex(pEmbComplex: EmbeddedComplex; pCallback: TAsyncEmbeddedMessageComplexCallback; pOnTimeout: TProc<Integer> = nil);
    procedure ReturnAnyType(pInfoString: InfoString; pCallback: TAsyncReturnAnyTypeCallback; pOnTimeout: TProc<Integer>);
    procedure BeginStream(pCallback: TAsyncBeginStreamStreamDataCallbackEx);
    procedure BeginStreamEx(pStreamInfo: StreamInfo; pCallback: TAsyncBeginStreamStreamDataCallbackEx);
    procedure ClientStream(pOnStreamClose: TProc<TPair<string, string>, TPair<string, string>>);
    procedure ClientStreamEx(pCallback: TAsyncClientStreamExDataCallback; pOnStreamClose: TProc<TPair<string, string>, TPair<string, string>>);
    procedure DuplexStream(pCallback: TDuplexStreamDataCallback);
    function  BeginStreamsList: TList<IGrpcStream>;
    function  BeginStreamsExList: TList<IGrpcStream>;
    function  ClientStreamsList: TList<ISendClientStream>;
    function  ClientStreamsExList: TList<ISendClientStreamEx>;
    function  DuplexStreamsList: TList<ISendDuplexStream>;
  end;

  TSendClientStream = class(TGrpcStream, ISendClientStream)
  protected
    {ISendClientStream}
    procedure Send(const pStreamData: StreamData);
    procedure Close;
    function GetStreamID: Integer;
  end;

  TSendClientStreamEx = class(TGrpcStream, ISendClientStreamEx)
  protected
    {ISendClientStreamEx}
    procedure Send(const pStreamData: StreamData);
    procedure Close;
    function GetStreamID: Integer;
  end;

  TSendDuplexStream = class(TGrpcStream, ISendDuplexStream)
  protected
    {ISendDuplexStream}
    procedure Send(const pStreamInfo: StreamInfo);
    procedure SendClose;
    function GetStreamID: Integer;
  end;

implementation

{ TTestService }

constructor TTestService.Create(const aGrpcClient: IGrpcClient);
begin
  inherited Create(aGrpcClient);
  fBeginStreams := TList<IGrpcStream>.Create;
  fBeginStreamsEx := TList<IGrpcStream>.Create;
  fClientStreams := TList<ISendClientStream>.Create;
  fClientStreamsEx := TList<ISendClientStreamEx>.Create;
  fDuplexStreams := TList<ISendDuplexStream>.Create;
end;

destructor TTestService.Destroy;
begin
  FreeAndNil(fBeginStreams);
  FreeAndNil(fBeginStreamsEx);
  FreeAndNil(fClientStreams);
  FreeAndNil(fClientStreamsEx);
  FreeAndNil(fDuplexStreams);
  inherited;
end;

procedure TTestService.CheckAllTypesAsync(
  pCallback: TAsyncAllTypesRequestCallback; pOnTimeout: TProc<Integer>);
var
  vCallback: TGrpcCallbackExA;
begin
  vCallback :=
    procedure(const pPacket: TGrpcPacket; aIsStreamClosed: Boolean; pStreamID: Integer)
    var
      vAllTypes: AllTypes;
    begin
      if pPacket.Data <> nil then
        if Length(pPacket.Data) <> 0 then
        begin
          TgoProtocolBuffer.Deserialize(vAllTypes, pPacket.Data);
          pCallback(vAllTypes);
        end;
    end;
  Client.DoUnaryRequestAsyncEx(nil,
    '/testservice.TestService/CheckAllTypes', vCallback, nil, nil, 3);
end;

procedure TTestService.OneSimpleAsync(pCallback: TAsyncOneSimpleRequestCallback;
  pOnTimeout: TProc<Integer>);
var
  vCallback: TGrpcCallbackExA;
begin
  vCallback :=
    procedure(const pPacket: TGrpcPacket; aIsStreamClosed: Boolean; pStreamID: Integer)
    var
      vSimple: Simple;
    begin
      if pPacket.Data <> nil then
        if Length(pPacket.Data) <> 0 then
        begin
          TgoProtocolBuffer.Deserialize(vSimple, pPacket.Data);
          pCallback(vSimple);
        end;
    end;
  Client.DoUnaryRequestAsyncEx(nil,
    '/testservice.TestService/OneSimple', vCallback, nil, nil, 3);
end;

procedure TTestService.DoubleSimpleAsync(pSimpleData: Simple;
  pCallback: TAsyncOneSimpleRequestCallback;
  pOnTimeout: TProc<Integer>);
var
  vCallback: TGrpcCallbackExA;
begin
  vCallback :=
    procedure(const pPacket: TGrpcPacket; aIsStreamClosed: Boolean; pStreamID: Integer)
    var
      vSimple: Simple;
    begin
      if pPacket.Data <> nil then
        if Length(pPacket.Data) <> 0 then
        begin
          TgoProtocolBuffer.Deserialize(vSimple, pPacket.Data);
          pCallback(vSimple);
        end;
    end;
  Client.DoUnaryRequestAsyncEx(TgoProtocolBuffer.Serialize(pSimpleData),
    '/testservice.TestService/DoubleSimple', vCallback, pOnTimeout, nil, 3);
end;

procedure TTestService.SaveSimpleAsync(pSimpleData: Simple;
  pOnStreamClose: TProc<TPair<string, string>, TPair<string, string>>;
  pOnTimeout: TProc<Integer>);
var
  vCallback: TGrpcCallbackExA;
begin
  vCallback :=
    procedure(const pPacket: TGrpcPacket; aIsStreamClosed: Boolean; pStreamID: Integer)
    begin
    end;
  Client.DoUnaryRequestAsyncEx(TgoProtocolBuffer.Serialize(pSimpleData),
    '/testservice.TestService/SaveSimple', vCallback, nil, pOnStreamClose, 3);
end;

procedure TTestService.RepSimpleAsync(pRepAllTypes: RepAllTypes;
  pCallback: TAsyncRepAllTypesRequestCallback; pOnTimeout: TProc<Integer>);
var
  vCallback: TGrpcCallbackExA;
begin
  vCallback :=
    procedure(const pPacket: TGrpcPacket; aIsStreamClosed: Boolean; pStreamID: Integer)
    var
      vRepAllTypes: RepAllTypes;
    begin
      if pPacket.Data <> nil then
        if Length(pPacket.Data) <> 0 then
        begin
          TgoProtocolBuffer.Deserialize(vRepAllTypes, pPacket.Data);
          pCallback(vRepAllTypes);
        end;
    end;
  Client.DoUnaryRequestAsyncEx(TgoProtocolBuffer.Serialize(pRepAllTypes),
    '/testservice.TestService/RepSimple', vCallback, nil, nil, 3);
end;

procedure TTestService.ReturnAnyType(pInfoString: InfoString; pCallback: TAsyncReturnAnyTypeCallback; pOnTimeout: TProc<Integer>);
var
  vCallback: TGrpcCallbackExA;
begin
  vCallback :=
    procedure(const pPacket: TGrpcPacket; aIsStreamClosed: Boolean; pStreamID: Integer)
    var
      vAnyBytes: TBytes;
    begin
      if pPacket.Data <> nil then
        if Length(pPacket.Data) <> 0 then
        begin
          vAnyBytes := Copy(pPacket.Data, 0, Length(pPacket.Data));
          pCallback(vAnyBytes);
        end;
    end;
  Client.DoUnaryRequestAsyncEx(TgoProtocolBuffer.Serialize(pInfoString),
    '/testservice.TestService/ReturnAnyType', vCallback, nil, nil, 3);
end;

procedure TTestService.EmbeddedMessageSimple(pEmbSimple: EmbeddedSimple;
  pCallback: TAsyncEmbeddedMessageSimpleCallback; pOnTimeout: TProc<Integer>);
var
  vCallback: TGrpcCallbackExA;
begin
  vCallback :=
    procedure(const pPacket: TGrpcPacket; aIsStreamClosed: Boolean; pStreamID: Integer)
    var
      vEmbeddedSimple: EmbeddedSimple;
    begin
      if pPacket.Data <> nil then
        if Length(pPacket.Data) <> 0 then
        begin
          TgoProtocolBuffer.Deserialize(vEmbeddedSimple, pPacket.Data);
          pCallback(vEmbeddedSimple);
        end;
    end;
  Client.DoUnaryRequestAsyncEx(TgoProtocolBuffer.Serialize(pEmbSimple),
    '/testservice.TestService/EmbeddedMessageSimple', vCallback, nil, nil, 3);
end;

procedure TTestService.EmbeddedMessageComplex(pEmbComplex: EmbeddedComplex;
  pCallback: TAsyncEmbeddedMessageComplexCallback; pOnTimeout: TProc<Integer>);
var
  vCallback: TGrpcCallbackExA;
begin
  vCallback :=
    procedure(const pPacket: TGrpcPacket; aIsStreamClosed: Boolean; pStreamID: Integer)
    var
      vEmbeddedComplex: EmbeddedComplex;
    begin
      if pPacket.Data <> nil then
        if Length(pPacket.Data) <> 0 then
        begin
          TgoProtocolBuffer.Deserialize(vEmbeddedComplex, pPacket.Data);
          pCallback(vEmbeddedComplex);
        end;
    end;
  Client.DoUnaryRequestAsyncEx(TgoProtocolBuffer.Serialize(pEmbComplex),
    '/testservice.TestService/EmbeddedMessageComplex', vCallback, nil, nil, 3);
end;

procedure TTestService.BeginStream(
  pCallback: TAsyncBeginStreamStreamDataCallbackEx);
var
  callback: TGrpcCallbackExA;
  vGrpcStream: IGrpcStream;
begin
  if Assigned(pCallback) then
    callback :=
      procedure(const pPacket: TGrpcPacket; aIsStreamClosed: Boolean; pStreamID: Integer)
      var
        vStreamData: StreamData;
      begin
        if pPacket.Data <> nil then
          TgoProtocolBuffer.Deserialize(vStreamData, pPacket.Data);
        pCallback(vStreamData, pStreamID);
//        if aIsStreamClosed then
//          fBeginStream := nil;
      end
  else
    callback := nil;

  vGrpcStream := Client.DoRequest(nil, '/testservice.TestService/BeginStream', callback, True);
  if vGrpcStream <> nil then
    fBeginStreams.Add(vGrpcStream);
end;

procedure TTestService.BeginStreamEx(pStreamInfo: StreamInfo;
  pCallback: TAsyncBeginStreamStreamDataCallbackEx);
var
  vCallback: TGrpcCallbackExA;
  vGrpcStream: IGrpcStream;
begin
  if Assigned(pCallback) then
    vCallback :=
      procedure(const pPacket: TGrpcPacket; aIsStreamClosed: Boolean; pStreamID: Integer)
      var
        vStreamData: StreamData;
      begin
        if pPacket.Data <> nil then
          TgoProtocolBuffer.Deserialize(vStreamData, pPacket.Data);
        pCallback(vStreamData, pStreamID);
      end
  else
    vCallback := nil;
  vGrpcStream := Client.DoRequest(TgoProtocolBuffer.Serialize(pStreamInfo), '/testservice.TestService/BeginStreamEx', vCallback, True);
  if vGrpcStream <> nil then
    fBeginStreamsEx.Add(vGrpcStream);
end;

procedure TTestService.ClientStream(pOnStreamClose:
  TProc<TPair<string, string>, TPair<string, string>>);
var
  vRequest: IGrpcStream;
begin
  vRequest := Client.DoRequest(nil, '/testservice.TestService/ClientStream', nil, False);
  if vRequest = nil then
    Exit;
  vRequest.SetOnCloseCallback(pOnStreamClose);
  fClientStreams.Add(TSendClientStream.Create(vRequest));
end;

procedure TTestService.ClientStreamEx(pCallback: TAsyncClientStreamExDataCallback;
  pOnStreamClose: TProc<TPair<string, string>, TPair<string, string>>);
var
  vRequest: IGrpcStream;
  vCallback: TGrpcCallbackExA;

begin
  if Assigned(pCallback) then
  begin
    vCallback :=
      procedure(const pPacket: TGrpcPacket; aIsStreamClosed: Boolean; pStreamID: Integer)
      var
        vStreamInfo: StreamInfo;
        vCount: Integer;
        vGrpcStream: ISendClientStreamEx;
      begin
        if (pPacket.Header.Compression = 0) and (pPacket.Data <> nil) then
        begin
          TgoProtocolBuffer.Deserialize(vStreamInfo, pPacket.Data);
          pCallback(vStreamInfo, pStreamID);
          if aIsStreamClosed then
          begin
            for vCount := 0 to fClientStreamsEx.Count - 1 do
              if fClientStreamsEx[vCount].GetStreamID = pStreamID then
              begin
                vGrpcStream := fClientStreamsEx[vCount];
                Break;
              end;
            fClientStreamsEx.Remove(vGrpcStream);
          end;
        end;
      end;
  end;
  vRequest := Client.DoRequest(nil, '/testservice.TestService/ClientStreamEx', vCallback, False);
  if vRequest = nil then
    Exit;
  vRequest.SetOnCloseCallback(pOnStreamClose);
  fClientStreamsEx.Add(TSendClientStreamEx.Create(vRequest));
end;

procedure TTestService.DuplexStream(pCallback: TDuplexStreamDataCallback);
var
  vRequest: IGrpcStream;
  vCallback: TGrpcCallbackExA;
begin
  if Assigned(pCallback) then
    vCallback :=
      procedure(const pPacket: TGrpcPacket; aIsStreamClosed: Boolean; pStreamID: Integer)
      var
        vStreamData: StreamData;
      begin
        if pPacket.Data <> nil then
          TgoProtocolBuffer.Deserialize<StreamData>(vStreamData, pPacket.Data);
        pCallback(vStreamData, pStreamID);
      end
  else
    vCallback := nil;
  vRequest := Client.DoRequest(nil, '/testservice.TestService/DuplexStream', vCallback, False);
  if vRequest = nil then
    Exit;
  fDuplexStreams.Add(TSendDuplexStream.Create(vRequest));
end;

function TTestService.BeginStreamsList: TList<IGrpcStream>;
begin
  Result := fBeginStreams;
end;

function TTestService.BeginStreamsExList: TList<IGrpcStream>;
begin
  Result := fBeginStreamsEx;
end;

function TTestService.ClientStreamsList: TList<ISendClientStream>;
begin
  Result := fClientStreams;
end;

function TTestService.ClientStreamsExList: TList<ISendClientStreamEx>;
begin
  Result := fClientStreamsEx;
end;

function TTestService.DuplexStreamsList: TList<ISendDuplexStream>;
begin
  Result := fDuplexStreams;
end;

{ TSendClientStream }

procedure TSendClientStream.Send(const pStreamData: StreamData);
begin
  Stream.SendData(TgoProtocolBuffer.Serialize(pStreamData));
end;

procedure TSendClientStream.Close;
begin
  Stream.DoCloseSend;
end;

function TSendClientStream.GetStreamID: Integer;
begin
  Result := Stream.GetStreamID;
end;

{ TSendClientStreamEx }

procedure TSendClientStreamEx.Send(const pStreamData: StreamData);
begin
  Stream.SendData(TgoProtocolBuffer.Serialize(pStreamData));
end;

procedure TSendClientStreamEx.Close;
begin
  Stream.DoCloseSend;
end;

function TSendClientStreamEx.GetStreamID: Integer;
begin
  Result := Stream.GetStreamID;
end;

{ TSendDuplexStream }

function TSendDuplexStream.GetStreamID: Integer;
begin
  Result := Stream.GetStreamID;
end;

procedure TSendDuplexStream.Send(const pStreamInfo: StreamInfo);
begin
  Stream.SendData(TgoProtocolBuffer.Serialize(pStreamInfo));
end;

procedure TSendDuplexStream.SendClose;
begin
  Stream.SendCloseStream;
end;

end.
