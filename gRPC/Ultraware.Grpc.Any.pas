unit Ultraware.Grpc.Any;

interface

uses
  System.Types, System.SysUtils, Grijjy.ProtocolBuffers;

function GetAnyMessageTypeName(pBytes: TBytes): string;

type
  // Pack and unpack have different meanings from other gRPC implementations
  // Pack means shallow record copy + serialization
  // Unpack means deserialize TBytes into TAny<T>
  TAny<T: record> = record
    public
    [Serialize(1)] TypeName: string;
    [Serialize(2)] AType: T;
    function Pack: TBytes;
    function Unpack(pBytes: TBytes): Boolean;
  end;

implementation

uses
  Ultraware.Grpc.Proto.Utils;

function FromVarInt(pBytes: PByte): UInt64;
var
  Shift: Integer;
begin
  Result := 0;
  Shift := 0;

  if pBytes = nil then
    Exit;

  while((pBytes^ and $80) >= 1) do
  begin
    if Shift > 64 then
      Break;
    Result := Result or (UInt64(pBytes^ and $7F) shl Shift);
    Inc(pBytes);
    Shift := Shift + 7;
  end;
  Result := pBytes^ shl Shift;
end;

function GetAnyMessageTypeName(pBytes: TBytes): string;
var
  vSize: UInt64;
  vAnsiString: AnsiString;
  vCount: Integer;
begin
  Result := EmptyStr;
  if pBytes = nil then
    Exit;

  if Length(pBytes) < 4 then
    Exit;

  //I know that the first byte will be 0b1010 (means field noº1 with wiretype 2)
  vSize := FromVarInt(@pBytes[1]);
  SetLength(vAnsiString, vSize);
  for vCount := 1 to vSize do
    vAnsiString[vCount] := AnsiChar(pBytes[vCount+1]);
  Result := string(vAnsiString);
end;

{ TAny<T> }

function TAny<T>.Pack: TBytes;
begin
  TypeName := TProtoUtils.GetTypeProtoMessageName<T>();

  if TypeName = EmptyStr then
    Exit(nil);

  try
    Result := TgoProtocolBuffer.Serialize(Self);
  except
    Result := nil;
  end;
end;

function TAny<T>.Unpack(pBytes: TBytes): Boolean;
begin
  Result := True;
  try
    TgoProtocolBuffer.Deserialize(Self, pBytes);
  except
    Result := False;
  end;
end;

end.
