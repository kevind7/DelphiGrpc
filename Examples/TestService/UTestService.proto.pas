unit UTestService.proto;

interface

uses
  System.Types, System.SysUtils, Ultraware.Grpc.Proto.Utils,
  Grijjy.ProtocolBuffers;

type
  TEnumType = (One, Two, Three);
  
  //message AllTypes
  {
    double DoubleData = 1;
    float FloatData = 2;
    fixed32 UInt32Data = 3;
    fixed64 UInt64Data = 4;
    sfixed32 Int32Data = 5;
    sfixed64 Int64Data = 6;
    bool BoolData = 7;
    string UTF8StringData = 8;
    bytes ArrayOfByteData = 9;
    EnumType EnumData = 10;
  }
  
  [TProtoMessageName('type.googleapis.com/TestService.AllTypes')]
  AllTypes = record
  public
    [Serialize(1)] DoubleData: Double;
    [Serialize(2)] FloatData: Single;
    [Serialize(3)] UInt32Data: UInt32;
    [Serialize(4)] UInt64Data: UInt64;
    [Serialize(5)] Int32Data: Int32;
    [Serialize(6)] Int64Data: Int64;
    [Serialize(7)] BoolData: Boolean;
    [Serialize(8)] UTF8StringData: string;
    [Serialize(9)] ArrayOfByteData: TBytes;
    [Serialize(10)] EnumData: TEnumType;
  end;

  //message Simple
  {
    string Name = 1;
    fixed32 ID = 2;
    bytes Info = 3;
  }
  
  [TProtoMessageName('type.googleapis.com/TestService.Simple')]
  Simple = record
  public
    [Serialize(1)] Name: string;
    [Serialize(2)] ID: UInt32;
    [Serialize(3)] Info: TBytes;
  end;

 //message RepAllTypes
 {
	  repeated double DoubleData = 1;
  	repeated float FloatData = 2;
  	repeated fixed32 UInt32Data = 3;
  	repeated fixed64 UInt64Data = 4;
	  repeated sfixed32 Int32Data = 5;
  	repeated sfixed64 Int64Data = 6;
  	repeated bool BoolData = 7;
	  repeated string UTF8StringData = 8;
  	repeated EnumType EnumData = 9;
  }
  
  [TProtoMessageName('type.googleapis.com/TestService.RepAllTypes')]
  RepAllTypes = record
  public
    [Serialize(1)] DoubleData: TArray<Double>;
    [Serialize(2)] FloatData: TArray<Single>;
    [Serialize(3)] UInt32Data: TArray<FixedUInt32>;
    [Serialize(4)] UInt64Data: TArray<FixedUInt64>;
    [Serialize(5)] Int32Data: TArray<FixedInt32>;
    [Serialize(6)] Int64Data: TArray<FixedInt64>;
    [Serialize(7)] BoolData: TArray<Boolean>;
    [Serialize(8)] UTF8StringData: TArray<string>;
    [Serialize(9)] EnumData: TArray<TEnumType>;
  end;

  //message StreamInfo
  {
	  string Info = 1;
  }
    
  [TProtoMessageName('type.googleapis.com/TestService.StreamInfo')]
  StreamInfo = record
  public
    [Serialize(1)] Info: string;
  end;

  //message InfoString 
  {
	  string Info = 1;
  }
  
  [TProtoMessageName('type.googleapis.com/TestService.InfoString')]
  InfoString = record
  public
    [Serialize(1)] Info: string;
  end;
  
  //message EmbeddedSimple
  {
    string TypeName = 1;
    Simple SimpleData = 2;
    repeated StreamInfo StreamInfoArray = 3;
  }
  
  [TProtoMessageName('type.googleapis.com/TestService.EmbeddedSimple')]
  EmbeddedSimple = record
  public
    [Serialize(1)] TypeName: string;
    [Serialize(2)] SimpleData: Simple;
    [Serialize(3)] StreamInfoArray: TArray<StreamInfo>;
  end;

  //message ComplexStruct
  {
	  bytes RawData = 1;
    string DataInfo = 2;
    fixed32 DataID = 3;
    Simple SimpleData = 4;
  }

  [TProtoMessageName('type.googleapis.com/TestService.ComplexStruct')]
  ComplexStruct = record
  public
    [Serialize(1)] RawData: TBytes;
    [Serialize(2)] DataInfo: string;
    [Serialize(3)] DataID: FixedUInt32;
    [Serialize(4)] SimpleData: Simple;
  end;

  //message EmbeddedComplex
  {
	  string ComplexInfo = 1;
   	ComplexStruct ComplexData = 2;
  }

  [TProtoMessageName('type.googleapis.com/TestService.EmbeddedComplex')]
  EmbeddedComplex = record
  public
    [Serialize(1)] ComplexInfo: string;
    [Serialize(2)] ComplexData: ComplexStruct;
  end;

  //message StreamData
  {
  	bytes Data = 1;
  	sfixed32 DataType = 2;
	  string ExtraInfo = 3;
  }
  
  [TProtoMessageName('type.googleapis.com/TestService.StreamData')]
  StreamData = record
  public
    [Serialize(1)] Data: TBytes;
    [Serialize(2)] DataType: FixedInt32;
    [Serialize(3)] ExtraInfo: string;
  end;

implementation

end.
