unit TestUTestService.client;

interface

uses
  TestFrameWork,
  UTestService.proto, UTestService.client, UTestService.grpc,
  Winapi.Windows,
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults,
  Ultraware.grpc, Ultraware.grpc.Proto.Utils, Ultraware.grpc.Any;

type
  TestUnitTestServiceClient = class(TTestCase)
  strict private
    FAllTypes: AllTypes;
    FSimple: Simple;
    FRepAllTypes: RepAllTypes;
    FEmbSimple: EmbeddedSimple;
    FEmbComplex: EmbeddedComplex;
    FStreamInfo: StreamInfo;
    FStreamDataList: TList<StreamData>;

    FC1: ITestService;

    FSaveSimpleStatus: Integer;
    FSaveSimpleGrpcMessage: string;
    FClientStreamClosed: Boolean;
    FClientStreamExClosed: Boolean;

    procedure CheckAllTypes;
    procedure CheckAllTypesEx;
    procedure CheckOneSimple;
    procedure CheckOneSimpleEx;
    procedure CheckRepSimple;
    procedure CheckRepSimpleEx;

    function CompareArray<T>(A1, A2: TArray<T>): Boolean;

    procedure OnCheckAllTypesResponse(pAllTypes: AllTypes);
    procedure OnOneSimpleResponse(pSimple: Simple);
    procedure OnDoubleSimpleResponse(pSimple: Simple);
    procedure OnRepAllTypesResponse(pRepAllTypes: RepAllTypes);
    procedure OnEmbeddedMessageSimpleResponse(pEmbSimple: EmbeddedSimple);
    procedure OnEmbeddedMessageComplexResponse(pEmbComplex: EmbeddedComplex);
    procedure OnReturnAny(pAnyBytes: TBytes);
    procedure OnBeginStreamData(pStreamData: StreamData; pStreamID: Integer);
    procedure OnBeginStreamDataEx(pStreamData: StreamData; pStreamID: Integer);
    procedure OnClientStreamEx(pStreamInfo: StreamInfo; pStreamID: Integer);
    procedure OnDuplexStreamData(pStreamData: StreamData; pStreamID: Integer);
  public
    procedure SetUp; override;
    procedure Teardown; override;
  published
    procedure TestOpenDuplexStreamReceiveSix;
    procedure TestRequestCheckAllTypes;
    procedure TestRequestOneSimple;
    procedure TestRequestDoubleSimple;
    procedure TestRequestSaveSimple;
    procedure TestRequestSaveSimpleError;
    procedure TestRequestRepSimple;
    procedure TestRequestEmbeddedMessageSimple;
    procedure TestRequestEmbeddedMessageComplex;
    procedure TestRequestReturnAny;
    procedure TestOpenBeginStreamReceiveThree;
    procedure TestOpenBeginStreamExReceiveFive;
    procedure TestClientSendStream;
    procedure TestClientSendStreamEx;
    procedure TestMakeTwoRequestsWhilstBeginStreamRunning;
    procedure TestMakeThreeRequestsWhilstClientStreamExOpen;
  end;

const
  c_Chars: TArray<Char> = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b',
            'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'o', 'p', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
            'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];

  c_ByteArrayTest01: TBytes = [9, 18, 27, 36, 45, 54, 63, 72, 81, 90];

  c_ByteArrayTest02: TBytes = [14, 98, 123, 11, 4];

  c_ByteArrayTest03: TBytes = [77, 89, 5, 19, 33];

  c_DoubleArrayTest04: TArray<Double> = [ 0.12131415, 0.222324, 0.323334, 0.424344, 0.525354 ];
  c_FloatArrayTest04: TArray<Single> = [ 0.121314, 0.222324, 0.323334, 0.424344, 0.525354];
  c_UInt32ArrayTest04: TArray<UInt32> = [ 4500, 6000, 156712, 7891234, 140456781 , 1 , 88, 97, 145, 2002 ];
  c_UInt64ArrayTest04: TArray<UInt64> = [ 9922, 18455, 9812, 147987, 28043286701 , 4, 99, 3920, 32567, 77 ];
  c_Int32ArrayTest04: TArray<Int32> = [-1, -5000, -2147, -4294, 9000, 18000, 54000, 885, 607, 761111 ];
  c_Int64ArrayTest04: TArray<Int64> = [-3283823891, -4, -1992, -8956895, 88884, 99901, 4, 99, 7];
  c_BoolArrayTest04: TArray<Boolean> = [true, true, true, false, false, true, false, false, false, true];
  c_StringArrayTest04: TArray<string> = [ 'Well, shes walking through the clouds',
                'With a circus mind' , 'Thats running wild' ,
                'Butterflies and zebras and moonbeams', 'And fairly tales',
                'Thats all she ever thinks about', 'Riding the wind'];
  c_EnumTypeArrayTest04: TArray<TEnumType> = [ One, Three, Two, Two, One ];

  c_ByteArrayTest05: TBytes = [55, 123, 59, 11, 49];
  c_StringArrayTest05: TArray<string> = ['StreamOne', 'StreamTwo', 'StreamThree', 'StreamFour', 'StreamFive'];

  c_ByteArrayTest06: TBytes = [122, 199, 71, 18, 88, 91, 7, 156];
  c_ByteArrayTest06E2: TBytes = [11, 20, 29, 44, 85, 68, 54, 15, 66, 120];

  c_ByteArrayTest07: TBytes = [ 33, 48, 99, 222];
  c_DoubleArrayTest07: TArray<Double> = [ 0.413231, 0.183473, 0.318392, 0.323232, 0.11147];
  c_FloatArrayTest07: TArray<Single> = [ 0.414342, 0.444561, 0.1028367, 0.51782, 0.88723];
  c_UInt32ArrayTest07: TArray<UInt32> = [ 45689, 2, 5555, 7534, 1564, 78524, 24351, 764898, 156456, 96965 ];
  c_UInt64ArrayTest07: TArray<UInt64> = [ 46468, 41325151, 8885624343, 123232424241, 3424245252, 7, 77, 777, 7777, 77777 ];
  c_Int32ArrayTest07: TArray<Int32> = [ -1, -9999, -4467, -14891, 4744, 14700, 29400, -885, 11607, 99761111 ];
  c_Int64ArrayTest07: TArray<Int64> = [ -32891, -41, -12, -8895, 84, 901, 4, 9, 1];
  c_BoolArrayTest07: TArray<Boolean> = [ false, true, false, false, false, true, false, false, false, true ];
  c_StringArrayTest07: TArray<string> = [ 'Confutatis maledictis',
                        'flammis acribus addictis' , 'voca me cum benedictis' ,
                        'Oro supplex et acclinis', 'cor contritum quasi cinis',
                        'gere curam', 'mei finis'];
  c_EnumTypeArrayTest07: TArray<TEnumType> = [ One, Two, Two, Two, Three ];

implementation

uses
  System.Rtti, Math;

const
  c_Localhost: string = '127.0.0.1';
  c_Port: Integer = 5000;

function GenerateRandomStreamData: StreamData;
var
  vCount: Integer;
begin
  SetLength(Result.Data, Random(31) + 20);
  for vCount := 0 to Length(Result.Data) - 1 do
    Result.Data[vCount] := Random(255);
  Result.DataType := Random(5);
  SetLength(Result.ExtraInfo, 32);
  for vCount := 0 to Result.ExtraInfo.Length do
    Result.ExtraInfo[vCount + 1] := c_Chars[Random(61)];
end;

function GenerateRandomStreamInfo: StreamInfo;
var
  vCount: Integer;
begin
  SetLength(Result.Info, 50);
  for vCount := 0 to Result.Info.Length do
    Result.Info[vCount + 1] := c_Chars[Random(61)];
end;

procedure TestUnitTestServiceClient.CheckAllTypes;
begin
  Check(SameValue(FAllTypes.DoubleData, 0.32141516, 1E-6),
    Format('DoubleData %.12f is different from %.12f', [FAllTypes.DoubleData, 0.32141516]));
  Check(SameValue(FAllTypes.FloatData, 0.451419, 1E-6),
    Format('FloatData %.12f is different from %.12f', [FAllTypes.FloatData, 0.451419]));
  Check(FAllTypes.UInt32Data = 343311,
    Format('UInt32Data %u is different from %u', [FAllTypes.UInt32Data, 343311]));
  Check(FAllTypes.UInt64Data = 9147568,
    Format('UInt64Data %u is different from %u', [FAllTypes.UInt64Data, 9147568]));
  Check(FAllTypes.Int32Data = -4512,
    Format('Int32Data %d is different from %d', [FAllTypes.Int32Data, -4512]));
  Check(FAllTypes.Int64Data = -914175866,
    Format('Int32Data %d is different from %d', [FAllTypes.Int64Data, -914175866]));
  Check(not FAllTypes.BoolData, 'BoolData suppose to be False');
  Check(FAllTypes.UTF8StringData = 'TryingThisNewCoolFramework',
    Format('UTF8StringData should be "%s"', ['TryingThisNewCoolFrameWork']));
  Check(CompareArray<Byte>(FAllTypes.ArrayOfByteData, c_ByteArrayTest01),
    Format('ArrayOfByteData is not equal L1-%d L2-%d',
    [Length(FAllTypes.ArrayOfByteData) , Length(c_ByteArrayTest01)]));
  Check(FAllTypes.EnumData = TEnumType.One, 'EnumData should be One');
end;

procedure TestUnitTestServiceClient.CheckAllTypesEx;
begin
  Check(SameValue(FAllTypes.DoubleData, 0.32141516, 1E-6),
    Format('DoubleData %.12f is different from %.12f', [FAllTypes.DoubleData, 0.32141516]));
  Check(SameValue(FAllTypes.FloatData, 0.451419, 1E-6),
    Format('FloatData %.12f is different from %.12f', [FAllTypes.FloatData, 0.451419]));
  Check(FAllTypes.UInt32Data = 343311,
    Format('UInt32Data %u is different from %u', [FAllTypes.UInt32Data, 343311]));
  Check(FAllTypes.UInt64Data = 9147568,
    Format('UInt64Data %u is different from %u', [FAllTypes.UInt64Data, 9147568]));
  Check(FAllTypes.Int32Data = -4512,
    Format('Int32Data %d is different from %d', [FAllTypes.Int32Data, -4512]));
  Check(FAllTypes.Int64Data = -914175866,
    Format('Int32Data %d is different from %d', [FAllTypes.Int64Data, -914175866]));
  Check(not FAllTypes.BoolData, 'BoolData suppose to be False');
  Check(FAllTypes.UTF8StringData = 'TryingThisNewCoolFramework',
    Format('UTF8StringData should be "%s"', ['TryingThisNewCoolFrameWork']));
  Check(CompareArray<Byte>(FAllTypes.ArrayOfByteData, c_ByteArrayTest01),
    Format('ArrayOfByteData is not equal L1-%d L2-%d',
    [Length(FAllTypes.ArrayOfByteData) , Length(c_ByteArrayTest01)]));
  Check(FAllTypes.EnumData = TEnumType.Two, 'EnumData should be Two');
end;

procedure TestUnitTestServiceClient.CheckOneSimple;
begin
  Check(FSimple.Name = 'Steven Benz', Format('%s should be Steven Benz', [FSimple.Name]));
  Check(FSimple.ID = 14, Format('%d should be 14', [FSimple.ID]));
  Check(CompareArray<Byte>(FSimple.Info, c_ByteArrayTest02),
    Format('ArrayOfByteData is not equal L1-%d L2-%d',
    [Length(FSimple.Info) , Length(c_ByteArrayTest02)]));
end;

procedure TestUnitTestServiceClient.CheckOneSimpleEx;
begin
  Check(FSimple.Name = 'Stan Getz', Format('%s should be Stan Getz', [FSimple.Name]));
  Check(FSimple.ID = 46578, Format('%d should be 46578', [FSimple.ID]));
  Check(CompareArray<Byte>(FSimple.Info, c_ByteArrayTest07),
    Format('ArrayOfByteData is not equal L1-%d L2-%d',
    [Length(FSimple.Info) , Length(c_ByteArrayTest07)]));
end;

procedure TestUnitTestServiceClient.CheckRepSimple;
begin
    Check(CompareArray<Double>(FRepAllTypes.DoubleData, c_DoubleArrayTest04),
    Format('DoubleData is not equal L1-%d L2-%d',
    [Length(FRepAllTypes.DoubleData), Length(c_DoubleArrayTest04)]));
  Check(CompareArray<Single>(FRepAllTypes.FloatData, c_FloatArrayTest04),
    Format('FloatData is not equal L1-%d L2-%d',
    [Length(FRepAllTypes.FloatData), Length(c_FloatArrayTest04)]));
  Check(CompareArray<UInt32>(TArray<UInt32>(FRepAllTypes.UInt32Data), c_UInt32ArrayTest04),
    Format('UInt32Data is not equal L1-%d L2-%d',
    [Length(FRepAllTypes.UInt32Data), Length(c_UInt32ArrayTest04)]));
  Check(CompareArray<UInt64>(TArray<UInt64>(FRepAllTypes.UInt64Data), c_UInt64ArrayTest04),
    Format('UInt64Data is not equal L1-%d L2-%d',
    [Length(FRepAllTypes.UInt64Data), Length(c_UInt64ArrayTest04)]));
  Check(CompareArray<Int32>(TArray<Int32>(FRepAllTypes.Int32Data), c_Int32ArrayTest04),
    Format('Int32Data is not equal L1-%d L2-%d',
    [Length(FRepAllTypes.Int32Data), Length(c_Int32ArrayTest04)]));
  Check(CompareArray<Int64>(TArray<Int64>(FRepAllTypes.Int64Data), c_Int64ArrayTest04),
    Format('Int64Data is not equal L1-%d L2-%d',
    [Length(FRepAllTypes.Int64Data), Length(c_Int64ArrayTest04)]));
  Check(CompareArray<Boolean>(FRepAllTypes.BoolData, c_BoolArrayTest04),
    Format('BoolData is not equal L1-%d L2-%d',
    [Length(FRepAllTypes.BoolData), Length(c_BoolArrayTest04)]));
  Check(CompareArray<string>(FRepAllTypes.UTF8StringData, c_StringArrayTest04),
    Format('UTF8StringData is not equal L1-%d L2-%d',
    [Length(FRepAllTypes.UTF8StringData), Length(c_StringArrayTest04)]));
  Check(CompareArray<TEnumType>(FRepAllTypes.EnumData, c_EnumTypeArrayTest04),
    Format('EnumData is not equal L1-%d L2-%d',
    [Length(FRepAllTypes.EnumData), Length(c_EnumTypeArrayTest04)]));
end;

procedure TestUnitTestServiceClient.CheckRepSimpleEx;
begin
  Check(CompareArray<Double>(FRepAllTypes.DoubleData, c_DoubleArrayTest07),
    Format('DoubleData is not equal L1-%d L2-%d',
    [Length(FRepAllTypes.DoubleData), Length(c_DoubleArrayTest07)]));
  Check(CompareArray<Single>(FRepAllTypes.FloatData, c_FloatArrayTest07),
    Format('FloatData is not equal L1-%d L2-%d',
    [Length(FRepAllTypes.FloatData), Length(c_FloatArrayTest07)]));
  Check(CompareArray<UInt32>(TArray<UInt32>(FRepAllTypes.UInt32Data), c_UInt32ArrayTest07),
    Format('UInt32Data is not equal L1-%d L2-%d',
    [Length(FRepAllTypes.UInt32Data), Length(c_UInt32ArrayTest07)]));
  Check(CompareArray<UInt64>(TArray<UInt64>(FRepAllTypes.UInt64Data), c_UInt64ArrayTest07),
    Format('UInt64Data is not equal L1-%d L2-%d',
    [Length(FRepAllTypes.UInt64Data), Length(c_UInt64ArrayTest07)]));
  Check(CompareArray<Int32>(TArray<Int32>(FRepAllTypes.Int32Data), c_Int32ArrayTest07),
    Format('Int32Data is not equal L1-%d L2-%d',
    [Length(FRepAllTypes.Int32Data), Length(c_Int32ArrayTest07)]));
  Check(CompareArray<Int64>(TArray<Int64>(FRepAllTypes.Int64Data), c_Int64ArrayTest07),
    Format('Int64Data is not equal L1-%d L2-%d',
    [Length(FRepAllTypes.Int64Data), Length(c_Int64ArrayTest07)]));
  Check(CompareArray<Boolean>(FRepAllTypes.BoolData, c_BoolArrayTest07),
    Format('BoolData is not equal L1-%d L2-%d',
    [Length(FRepAllTypes.BoolData), Length(c_BoolArrayTest07)]));
  Check(CompareArray<string>(FRepAllTypes.UTF8StringData, c_StringArrayTest07),
    Format('UTF8StringData is not equal L1-%d L2-%d',
    [Length(FRepAllTypes.UTF8StringData), Length(c_StringArrayTest07)]));
  Check(CompareArray<TEnumType>(FRepAllTypes.EnumData, c_EnumTypeArrayTest07),
    Format('EnumData is not equal L1-%d L2-%d',
    [Length(FRepAllTypes.EnumData), Length(c_EnumTypeArrayTest07)]));
end;

function TestUnitTestServiceClient.CompareArray<T>(A1, A2: TArray<T>): Boolean;
var
  vComp: IComparer<T>;
  vCount: Integer;
begin
  if Length(A1) <> Length(A2) then
    Exit(False);
  if (A1 = nil) or (A2 = nil) then
    Exit(False);
  vComp := TComparer<T>.Default;
  for vCount := 0 to Length(A1) - 1 do
    if TypeInfo(Double) = TypeInfo(T) then
    begin
      if not SameValue(TValue.From(A1[vCount]).AsExtended, TValue.From(A2[vCount]).AsExtended, 1E-6) then
        Exit(False);
    end
    else if (vComp.Compare(A1[vCount], A2[vCount]).ToBoolean) then
        Exit(False);
  Exit(True);
end;

{ TestUnitTestServiceClient }

procedure TestUnitTestServiceClient.SetUp;
var
  Dummy, MilliSecs: Word;
begin
  DecodeTime(Dummy, Dummy, Dummy, Dummy, MilliSecs);
  RandSeed := MilliSecs;
  FC1 := TTestService.Create(TGrpcHttp2Client.Create(c_Localhost, c_Port, False));
  FStreamDataList := TList<StreamData>.Create;
  FClientStreamClosed := False;
  FClientStreamExClosed := False;
  FSaveSimpleStatus := -1;
end;

procedure TestUnitTestServiceClient.Teardown;
begin
  FC1 := nil;
end;

procedure TestUnitTestServiceClient.TestRequestCheckAllTypes;
begin
  FC1.CheckAllTypesAsync(OnCheckAllTypesResponse);

  Sleep(500);

  CheckAllTypes;
  FillChar(FAllTypes, Sizeof(AllTypes), 0);
end;

procedure TestUnitTestServiceClient.TestRequestOneSimple;
begin
  FC1.OneSimpleAsync(OnOneSimpleResponse);
  Sleep(500);

  CheckOneSimple;
  FillChar(FSimple, SizeOf(FSimple), 0);
end;

procedure TestUnitTestServiceClient.TestRequestDoubleSimple;
var
  vSimple: Simple;
  vBytes: TBytes;
begin
  vSimple.Name := 'Thelonious Monk';
  vSimple.ID := 37;
  SetLength(vBytes, 5);
  vBytes[0] := 99;
  vBytes[1] := 45;
  vBytes[2] := 17;
  vBytes[3] := 22;
  vBytes[4] := 55;
  vSimple.Info := vBytes;

  FC1.DoubleSimpleAsync(vSimple, OnDoubleSimpleResponse);
  Sleep(500);

  Check(FSimple.Name = 'Wes Montgomery', Format('%s should be Wes Montgomery', [FSimple.Name]));
  Check(FSimple.ID = 41, Format('%d should be 41', [FSimple.ID]));
  Check(CompareArray<Byte>(FSimple.Info, c_ByteArrayTest03),
    Format('ArrayOfByteData is not equal L1-%d L2-%d',
    [Length(FSimple.Info), Length(c_ByteArrayTest03)]));
  FillChar(FSimple, Sizeof(FSimple), 0);
end;

procedure TestUnitTestServiceClient.TestRequestSaveSimple;
var
  vBytes: TBytes;
  vSimple: Simple;
  vOnClose: TProc<TPair<string, string>, TPair<string, string>>;
begin
  vSimple.Name := 'Joe Pass';
  vSimple.ID := 97;
  SetLength(vBytes, 5);
  vBytes[0] := 17;
  vBytes[1] := 25;
  vBytes[2] := 48;
  vBytes[3] := 8;
  vBytes[4] := 178;
  vSimple.Info := vBytes;
  vOnClose :=
    procedure(pGrpcStatus, pGrpcMessage: TPair<string, string>)
    begin
      FSaveSimpleStatus := pGrpcStatus.Value.ToInteger;
    end;
  FC1.SaveSimpleAsync(vSimple, vOnClose);
  Sleep(500);
  Check(FSaveSimpleStatus = 0, Format('Error ocurred with status == %d', [FSaveSimpleStatus]));
  FSaveSimpleStatus := -1;
end;

procedure TestUnitTestServiceClient.TestRequestSaveSimpleError;
var
  vBytes: TBytes;
  vSimple: Simple;
  vOnClose: TProc<TPair<string, string>, TPair<string, string>>;
begin
  vSimple.Name := 'Joe Passo';
  vSimple.ID := 97;
  SetLength(vBytes, 5);
  vBytes[0] := 17;
  vBytes[1] := 25;
  vBytes[2] := 48;
  vBytes[3] := 8;
  vBytes[4] := 178;
  vSimple.Info := vBytes;
  vOnClose :=
    procedure(pGrpcStatus, pGrpcMessage: TPair<string, string>)
    begin
      FSaveSimpleStatus := pGrpcStatus.Value.ToInteger;
      FSaveSimpleGrpcMessage := pGrpcMessage.Value;
    end;
  FC1.SaveSimpleAsync(vSimple, vOnClose);
  Sleep(500);
  Check(FSaveSimpleStatus = 3, Format('Error %d should have ocurred with status == %d', [FSaveSimpleStatus, 3]));
  Check(FSaveSimpleGrpcMessage = 'Invalid argument', Format('Error message %s should have been == %s', [FSaveSimpleGrpcMessage, 'Invalid argument']));
  FSaveSimpleStatus := -1;
  FSaveSimpleGrpcMessage := EmptyStr;
end;

procedure TestUnitTestServiceClient.TestRequestRepSimple;
var
  vRepAllTypes: RepAllTypes;
begin
  vRepAllTypes.DoubleData := [0.44455, 0.13451, 0.190321, 0.99145, 0.145332, 0.77811, 0.99832];
  vRepAllTypes.FloatData := [0.432, 0.912, 0.8442, 0.8293, 0.551, 0.990, 3200.12321, 5000.885];
  vRepAllTypes.UInt32Data := [4120, 8000, 12000, 1, 99, 7, 8, 4, 67, 154];
  vRepAllTypes.UInt64Data := [4645, 1789, 14891, 89, 191, 891, 78, 1294, 91, 6819, 64, 7849];
  vRepAllTypes.Int32Data := [-4120, -8000, 12000, -1, 99, -7, 8, 4, -67, -154];
  vRepAllTypes.Int64Data := [4645, 1789, -14891, -8900, 191, -4891, -7778, -41294, -91, 6819, -64, 7849];
  vRepAllTypes.BoolData := [True, False, True, False, False, False, False, False, True, False, False];
  vRepAllTypes.UTF8StringData := ['Baby, do you understand me now', 'Sometimes I feel a little mad',
    'Well, dont you know that no-one alive', 'Can always be an angel', 'When things go wrong I seem to be bad',
    'Im just a soul whos intentions are good', 'Oh Lord, please dont let me be misunderstood'];
  vRepAllTypes.EnumData := [TEnumType.One, TEnumType.Two, TEnumType.Three, TEnumType.One, TEnumType.One, TEnumType.Three, TEnumType.Two, TEnumType.Two];

  FC1.RepSimpleAsync(vRepAllTypes, OnRepAllTypesResponse);
  Sleep(500);
end;

procedure TestUnitTestServiceClient.TestRequestEmbeddedMessageSimple;
var
  vEmbSimple: EmbeddedSimple;
  vCount: Integer;
  vStreamInfos: TArray<string>;
begin
  vEmbSimple.TypeName := 'EmbeddedSimple';
  vEmbSimple.SimpleData.Name := 'Chick Corea';
  vEmbSimple.SimpleData.ID := 177;
  SetLength(vEmbSimple.SimpleData.Info, 5);
  vEmbSimple.SimpleData.Info[0] := 0;
  vEmbSimple.SimpleData.Info[1] := 100;
  vEmbSimple.SimpleData.Info[2] := 90;
  vEmbSimple.SimpleData.Info[3] := 190;
  vEmbSimple.SimpleData.Info[4] := 150;
  SetLength(vEmbSimple.StreamInfoArray, 8);
  vEmbSimple.StreamInfoArray[0].Info := 'You got a fast car';
  vEmbSimple.StreamInfoArray[1].Info := 'I want a ticket to anywhere';
  vEmbSimple.StreamInfoArray[2].Info := 'Maybe we make a deal';
  vEmbSimple.StreamInfoArray[3].Info := 'Maybe together we can get somewhere';
  vEmbSimple.StreamInfoArray[4].Info := 'Any place is better';
  vEmbSimple.StreamInfoArray[5].Info := 'Starting from zero got nothing to lose';
  vEmbSimple.StreamInfoArray[6].Info := 'Maybe well make something';
  vEmbSimple.StreamInfoArray[7].Info := 'Me, myself, I got nothing to prove';

  FC1.EmbeddedMessageSimple(vEmbSimple, OnEmbeddedMessageSimpleResponse);
  Sleep(500);

  Check(FEmbSimple.TypeName = 'EmbeddedSimple', Format('%s should be EmbeddedSimple', [FEmbSimple.TypeName]));
  Check(FEmbSimple.SimpleData.Name = 'Al Di Meola', Format('%s should be Al Di Meola', [FEmbSimple.SimpleData.Name]));
  Check(FEmbSimple.SimpleData.ID = 19, Format('%d should be 19', [FEmbSimple.SimpleData.ID]));
  Check(CompareArray<Byte>(FEmbSimple.SimpleData.Info, c_ByteArrayTest05),
    Format('SimpleData.Info is not equal L1-%d L2-%d',
    [Length(FEmbSimple.SimpleData.Info), Length(c_ByteArrayTest05)]));

  SetLength(vStreamInfos, Length(FEmbSimple.StreamInfoArray));
  for vCount := 0 to Length(vStreamInfos) - 1 do
    vStreamInfos[vCount] := FEmbSimple.StreamInfoArray[vCount].Info;

  Check(CompareArray<string>(vStreamInfos, c_StringArrayTest05),
    Format('vStreamInfos is not equal L1-%d L2-%d',
    [Length(vStreamInfos), Length(c_StringArrayTest05)]));
end;

procedure TestUnitTestServiceClient.TestRequestEmbeddedMessageComplex;
var
  vEmbComplex: EmbeddedComplex;
begin
  vEmbComplex.ComplexInfo := 'Eric Johnson';
  vEmbComplex.ComplexData.RawData := [33, 32, 13, 21, 45, 1, 52, 51, 6, 1];
  vEmbComplex.ComplexData.DataInfo := 'Cliffs of Dover';
  vEmbComplex.ComplexData.DataID := 10;
  vEmbComplex.ComplexData.SimpleData.Name := 'Steve Vai';
  vEmbComplex.ComplexData.SimpleData.ID := 44;
  vEmbComplex.ComplexData.SimpleData.Info := [55,44,66,77,88,99];

  FC1.EmbeddedMessageComplex(vEmbComplex, OnEmbeddedMessageComplexResponse);
  Sleep(500);

  Check(FEmbComplex.ComplexInfo = 'Caspar Wessel', Format('%s should be Caspar Wessel', [FEmbComplex.ComplexInfo]));
  Check(CompareArray<Byte>(FEmbComplex.ComplexData.RawData, c_ByteArrayTest06),
    Format('ComplexData.RawData is not equal L1-%d L2-%d',
    [Length(FEmbComplex.ComplexData.RawData), Length(c_ByteArrayTest06)]));
  Check(FEmbComplex.ComplexData.DataInfo = 'jtv84hny9ptgy9gmvya987ntypav4fgya8n',
    Format('%s should be jtv84hny9ptgy9gmvya987ntypav4fgya8n', [FEmbComplex.ComplexData.DataInfo]));
  Check(FEmbComplex.ComplexData.DataID = 1855,
    Format('%d should be 1855', [FEmbComplex.ComplexData.DataID]));
  Check(FEmbComplex.ComplexData.SimpleData.Name = 'Jean-Baptiste Joseph Fourier',
    Format('%s should be Jean-Baptiste Joseph Fourier', [FEmbComplex.ComplexData.SimpleData.Name]));
  Check(FEmbComplex.ComplexData.SimpleData.ID = 81,
    Format('%d should be 81', [FEmbComplex.ComplexData.SimpleData.ID]));
  Check(CompareArray<Byte>(FEmbComplex.ComplexData.SimpleData.Info, c_ByteArrayTest06E2),
    Format('ComplexData.SimpleData.Info is not equal L1-%d L2-%d',
    [Length(FEmbComplex.ComplexData.SimpleData.Info), Length(c_ByteArrayTest06E2)]));
end;

procedure TestUnitTestServiceClient.TestRequestReturnAny;
const
  c_TypeNames: array of string = ['type.googleapis.com/TestService.AllTypes',
                'type.googleapis.com/TestService.Simple',
                'type.googleapis.com/TestService.RepAllTypes'];
var
  vInfoString: InfoString;
begin
  vInfoString.Info := c_TypeNames[0];
  FC1.ReturnAnyType(vInfoString, OnReturnAny);
  Sleep(500);
  CheckAllTypesEx;
  FillChar(FAllTypes, Sizeof(FAllTypes), 0);
  vInfoString.Info := c_TypeNames[1];
  FC1.ReturnAnyType(vInfoString, OnReturnAny);
  Sleep(500);
  CheckOneSimpleEx;
  FillChar(FSimple, Sizeof(FSimple), 0);
  vInfoString.Info := c_TypeNames[2];
  FC1.ReturnAnyType(vInfoString, OnReturnAny);
  Sleep(500);
  CheckRepSimpleEx;
  FillChar(FRepAllTypes, Sizeof(FRepAllTypes), 0);
end;

procedure TestUnitTestServiceClient.TestOpenBeginStreamReceiveThree;
begin
  FC1.BeginStream(OnBeginStreamData);
  Sleep(1500);

  Check(FStreamDataList.Count = 3, Format('Did not receive 3 messages. Received [%d]', [FStreamDataList.Count]));
  FStreamDataList.Clear;
end;

procedure TestUnitTestServiceClient.TestOpenBeginStreamExReceiveFive;
var
  vStreamInfo: StreamInfo;
begin
  vStreamInfo.Info := 'uyb897yg9a8gy87khcv487hfgm86fghy8g4hsghy4m';
  FC1.BeginStreamEx(vStreamInfo, OnBeginStreamDataEx);
  Sleep(3000);

  Check(FStreamDataList.Count >= 4, Format('Did not receive >= 4 messages. Received [%d]', [FStreamDataList.Count]));
  FStreamDataList.Clear;
end;

procedure TestUnitTestServiceClient.TestClientSendStream;
var
  vOnClose: TProc<TPair<string, string>, TPair<string, string>>;
  vCount: Integer;
begin
  vOnClose :=
    procedure(pGrpcStatus, pGrpcMessage: TPair<string, string>)
    begin
      FClientStreamClosed := True;
    end;

  FC1.ClientStream(vOnClose);

  for vCount := 0 to 2 do
  begin
    FC1.ClientStreamsList[FC1.ClientStreamsList.Count-1].Send(GenerateRandomStreamData);
    Sleep(50);
  end;
  FC1.ClientStreamsList[FC1.ClientStreamsList.Count-1].Close;

  Sleep(500);

  Check(FClientStreamClosed, 'ClientStream did not close gracefully');
  FClientStreamClosed := False;
end;

procedure TestUnitTestServiceClient.TestClientSendStreamEx;
var
  vOnClose: TProc<TPair<string, string>, TPair<string, string>>;
  vCount, vMessageCount: Integer;
  vFutureInfo: string;
begin
  vOnClose :=
    procedure(pGrpcStatus, pGrpcMessage: TPair<string, string>)
    begin
      FClientStreamExClosed := True;
    end;

  FC1.ClientStreamEx(OnClientStreamEx, vOnClose);

  vMessageCount := 0;
  for vCount := 0 to 2 do
  begin
    FC1.ClientStreamsExList[FC1.ClientStreamsExList.Count-1].Send(GenerateRandomStreamData);
    Inc(vMessageCount);
    Sleep(50);
  end;
  FC1.ClientStreamsExList[FC1.ClientStreamsExList.Count-1].Close;

  Sleep(500);

  vFutureInfo := Format('You have sent %d through this stream', [vMessageCount]);
  Check(FClientStreamExClosed, 'ClientStreamEx did not close gracefully');
  Check(FStreamInfo.Info = vFutureInfo, Format('ClientStreamEx closing response [%s] should be %s', [FStreamInfo.Info, vFutureInfo]));

  FClientStreamExClosed := False;
  FillChar(FStreamInfo, Sizeof(FStreamInfo), 0);
end;

procedure TestUnitTestServiceClient.TestOpenDuplexStreamReceiveSix;
var
  vCount: Integer;
begin
  FC1.DuplexStream(OnDuplexStreamData);

  Sleep(2600);

  for vCount := 0 to 2 do
  begin
    FC1.DuplexStreamsList[FC1.DuplexStreamsList.Count - 1].Send(GenerateRandomStreamInfo);
    Sleep(50);
  end;
  FC1.DuplexStreamsList[FC1.DuplexStreamsList.Count - 1].SendClose;

  Check(FStreamDataList.Count >= 6, Format('Did not receive >= 6 messages. Received [%d]', [FStreamDataList.Count]));
  FStreamDataList.Clear;
end;

procedure TestUnitTestServiceClient.TestMakeTwoRequestsWhilstBeginStreamRunning;
begin
  FC1.BeginStream(OnBeginStreamData);
  FC1.CheckAllTypesAsync(OnCheckAllTypesResponse);
  Sleep(500);
  FC1.OneSimpleAsync(OnOneSimpleResponse);
  Sleep(500);
  CheckAllTypes;
  CheckOneSimple;
  FillChar(FAllTypes, Sizeof(AllTypes), 0);
  FillChar(FSimple, SizeOf(FSimple), 0);
  Check(FStreamDataList.Count >= 2, Format('Did not receive >= 2 messages. Received [%d]', [FStreamDataList.Count]));
end;

procedure TestUnitTestServiceClient.TestMakeThreeRequestsWhilstClientStreamExOpen;
var
  vOnClose: TProc<TPair<string, string>, TPair<string, string>>;
  vCount, vMessageCount: Integer;
  vFutureInfo: string;
  vRepAllTypes: RepAllTypes;
begin
  vOnClose :=
    procedure(pGrpcStatus, pGrpcMessage: TPair<string, string>)
    begin
      FClientStreamExClosed := True;
    end;

  FC1.ClientStreamEx(OnClientStreamEx, vOnClose);

  vRepAllTypes.DoubleData := [0.44455, 0.13451, 0.190321, 0.99145, 0.145332, 0.77811, 0.99832];
  vRepAllTypes.FloatData := [0.432, 0.912, 0.8442, 0.8293, 0.551, 0.990, 3200.12321, 5000.885];
  vRepAllTypes.UInt32Data := [4120, 8000, 12000, 1, 99, 7, 8, 4, 67, 154];
  vRepAllTypes.UInt64Data := [4645, 1789, 14891, 89, 191, 891, 78, 1294, 91, 6819, 64, 7849];
  vRepAllTypes.Int32Data := [-4120, -8000, 12000, -1, 99, -7, 8, 4, -67, -154];
  vRepAllTypes.Int64Data := [4645, 1789, -14891, -8900, 191, -4891, -7778, -41294, -91, 6819, -64, 7849];
  vRepAllTypes.BoolData := [True, False, True, False, False, False, False, False, True, False, False];
  vRepAllTypes.UTF8StringData := ['Baby, do you understand me now', 'Sometimes I feel a little mad',
    'Well, dont you know that no-one alive', 'Can always be an angel', 'When things go wrong I seem to be bad',
    'Im just a soul whos intentions are good', 'Oh Lord, please dont let me be misunderstood'];
  vRepAllTypes.EnumData := [TEnumType.One, TEnumType.Two, TEnumType.Three, TEnumType.One, TEnumType.One, TEnumType.Three, TEnumType.Two, TEnumType.Two];

  FC1.CheckAllTypesAsync(OnCheckAllTypesResponse);
  Sleep(500);
  FC1.OneSimpleAsync(OnOneSimpleResponse);
  Sleep(500);
  FC1.RepSimpleAsync(vRepAllTypes, OnRepAllTypesResponse);
  Sleep(500);
  CheckAllTypes;
  CheckOneSimple;
  CheckRepSimple;
  FillChar(FAllTypes, Sizeof(AllTypes), 0);
  FillChar(FSimple, SizeOf(FSimple), 0);
  FillChar(FRepAllTypes, SizeOf(FRepAllTypes), 0);

  vMessageCount := 0;
  for vCount := 0 to 5 do
  begin
    FC1.ClientStreamsExList[FC1.ClientStreamsExList.Count-1].Send(GenerateRandomStreamData);
    Inc(vMessageCount);
    Sleep(50);
  end;
  FC1.ClientStreamsExList[FC1.ClientStreamsExList.Count-1].Close;

  Sleep(500);

  vFutureInfo := Format('You have sent %d through this stream', [vMessageCount]);
  Check(FClientStreamExClosed, 'ClientStreamEx did not close gracefully');
  Check(FStreamInfo.Info = vFutureInfo, Format('ClientStreamEx closing response [%s] should be %s', [FStreamInfo.Info, vFutureInfo]));

  FClientStreamExClosed := False;
  FillChar(FStreamInfo, Sizeof(FStreamInfo), 0);
end;

{Callbacks}

procedure TestUnitTestServiceClient.OnCheckAllTypesResponse(pAllTypes: AllTypes);
begin
  FAllTypes := pAllTypes;
end;

procedure TestUnitTestServiceClient.OnOneSimpleResponse(pSimple: Simple);
begin
  FSimple := pSimple;
end;

procedure TestUnitTestServiceClient.OnDoubleSimpleResponse(pSimple: Simple);
begin
  FSimple := pSimple;
end;

procedure TestUnitTestServiceClient.OnRepAllTypesResponse(pRepAllTypes: RepAllTypes);
begin
  FRepAllTypes := pRepAllTypes;
end;

procedure TestUnitTestServiceClient.OnEmbeddedMessageSimpleResponse(
  pEmbSimple: EmbeddedSimple);
begin
  FEmbSimple := pEmbSimple;
end;

procedure TestUnitTestServiceClient.OnEmbeddedMessageComplexResponse(
  pEmbComplex: EmbeddedComplex);
begin
  FEmbComplex := pEmbComplex;
end;

procedure TestUnitTestServiceClient.OnReturnAny(pAnyBytes: TBytes);
var
  vAnyAllTypes: TAny<AllTypes>;
  vAnySimple: TAny<Simple>;
  vAnyRepAllTypes: TAny<RepAllTypes>;
begin
  if GetAnyMessageTypeName(pAnyBytes) = TProtoUtils.GetTypeProtoMessageName<AllTypes>() then
  begin
    if not vAnyAllTypes.Unpack(pAnyBytes) then
      Exit;
    FAllTypes := vAnyAllTypes.AType;
  end
  else if GetAnyMessageTypeName(pAnyBytes) = TProtoUtils.GetTypeProtoMessageName<Simple>() then
  begin
    if not vAnySimple.Unpack(pAnyBytes) then
      Exit;
    FSimple := vAnySimple.AType;
  end
  else if GetAnyMessageTypeName(pAnyBytes) = TProtoUtils.GetTypeProtoMessageName<RepAllTypes>() then
  begin
    if not vAnyRepAllTypes.Unpack(pAnyBytes) then
      Exit;
    FRepAllTypes := vAnyRepAllTypes.AType;
  end;
end;

procedure TestUnitTestServiceClient.OnBeginStreamData(pStreamData: StreamData; pStreamID: Integer);
begin
  FStreamDataList.Add(pStreamData);
end;

procedure TestUnitTestServiceClient.OnBeginStreamDataEx(pStreamData: StreamData; pStreamID: Integer);
begin
  FStreamDataList.Add(pStreamData);
end;

procedure TestUnitTestServiceClient.OnClientStreamEx(pStreamInfo: StreamInfo;
  pStreamID: Integer);
begin
  FStreamInfo := pStreamInfo;
end;

procedure TestUnitTestServiceClient.OnDuplexStreamData(pStreamData: StreamData; pStreamID: Integer);
begin
  FStreamDataList.Add(pStreamData);
end;

initialization
  RegisterTest(TestUnitTestServiceClient.Suite);

end.