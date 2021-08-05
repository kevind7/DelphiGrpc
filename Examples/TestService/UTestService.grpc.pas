unit UTestService.grpc;

interface

uses
  System.SysUtils, System.Generics.Collections, Ultraware.Grpc, UTestService.proto, Grijjy.ProtocolBuffers;

type
  TAsyncAllTypesRequestCallback = procedure(pAllTypes: AllTypes) of object;
  TAsyncOneSimpleRequestCallback = procedure(pSimple: Simple) of object;
  TAsyncRepAllTypesRequestCallback = procedure(pRepAllTypes: RepAllTypes) of object;
  TAsyncEmbeddedMessageSimpleCallback = procedure(pEmbSimple: EmbeddedSimple) of object;
  TAsyncEmbeddedMessageComplexCallback = procedure(pEmbComplex: EmbeddedComplex) of object;
  TAsyncBeginStreamStreamDataCallback = procedure(pStreamData: StreamData) of object;
  TAsyncBeginStreamStreamDataCallbackEx = procedure(pStreamData: StreamData; pStreamID: Integer) of object;
  TAsyncReturnAnyTypeCallback = procedure(pAny: TBytes) of object;
  TAsyncClientStreamExDataCallback = procedure(pStreamInfo: StreamInfo; pStreamID: Integer) of object;
  TDuplexStreamDataCallback = procedure(pStreamData: StreamData; pStreamID: Integer) of object;

  {
    rpc CheckAllTypes (google.protobuf.Empty) returns (AllTypes);
    rpc OneSimple (google.protobuf.Empty) returns (Simple);
    rpc DoubleSimple (Simple) returns (Simple);
    rpc SaveSimple (Simple) returns (google.protobuf.Empty);
    rpc RepSimple (RepAllTypes) returns (RepAllTypes);
    rpc EmbeddedMessageSimple (EmbeddedSimple) returns (EmbeddedSimple);
    rpc EmbeddedMessageComplex (EmbeddedComplex) returns (EmbeddedComplex);
    rpc ReturnAnyType (google.protobuf.Empty) returns (google.protobuf.Any);
    rpc BeginStream (google.protobuf.Empty) returns (stream StreamData);
    rpc BeginStreamEx (StreamInfo) returns (stream StreamData);
    rpc ClientStream (stream StreamData) returns (google.protobuf.Empty);
    rpc ClientStreamEx (stream StreamData) returns (StreamInfo);
    rpc DuplexStream (stream StreamInfo) returns (stream StreamData);
  }

  ISendClientStream = interface
    ['{92BF58F0-6E6F-439D-8BF5-EF1AE5E25DBA}']
    procedure Send(const pStreamData: StreamData);
    procedure Close;
    function GetStreamID: Integer;
  end;

  ISendClientStreamEx = interface
    ['{DD421AB5-1260-44C6-B947-A886F3F4CF2F}']
    procedure Send(const pStreamData: StreamData);
    procedure Close;
    function GetStreamID: Integer;
  end;

  ISendDuplexStream = interface
    ['{DF3E9CF2-F139-4CFA-857C-3F5B91AF5570}']
    procedure Send(const pStreamInfo: StreamInfo);
    procedure SendClose;
    function GetStreamID: Integer;
  end;

  ITestService = interface
    ['{54E49221-824E-4F01-AC92-5378C6A187D2}']
    procedure CheckAllTypesAsync(pCallback: TAsyncAllTypesRequestCallback; pOnTimeout: TProc<Integer> = nil);
    procedure OneSimpleAsync(pCallback: TAsyncOneSimpleRequestCallback; pOnTimeout: TProc<Integer> = nil);
    procedure DoubleSimpleAsync(pSimpleData: Simple; pCallback: TAsyncOneSimpleRequestCallback; pOnTimeout: TProc<Integer> = nil);
    procedure SaveSimpleAsync(pSimpleData: Simple; pOnStreamClose: TProc<TPair<string, string>, TPair<string, string>> = nil; pOnTimeout: TProc<Integer> = nil);
    procedure RepSimpleAsync(pRepAllTypes: RepAllTypes; pCallback: TAsyncRepAllTypesRequestCallback; pOnTimeout: TProc<Integer> = nil);
    procedure EmbeddedMessageSimple(pEmbSimple: EmbeddedSimple; pCallback: TAsyncEmbeddedMessageSimpleCallback; pOnTimeout: TProc<Integer> = nil);
    procedure EmbeddedMessageComplex(pEmbComplex: EmbeddedComplex; pCallback: TAsyncEmbeddedMessageComplexCallback; pOnTimeout: TProc<Integer> = nil);
    procedure ReturnAnyType(pInfoString: InfoString; pCallback: TAsyncReturnAnyTypeCallback; pOnTimeout: TProc<Integer> = nil);
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

implementation

end.
