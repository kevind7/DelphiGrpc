unit Ultraware.Grpc.Proto.Utils;

interface

type
  TProtoMessageNameAttribute = class(TCustomAttribute)
  public
    FName: string;
    constructor Create(const pName: string);
  end;

  TProtoUtils = class(TObject)
    class function GetTypeProtoMessageName<T: record>: string;
  end;

implementation

uses
  System.SysUtils, System.Rtti;

{ TProtoMessageNameAttribute }

constructor TProtoMessageNameAttribute.Create(const pName: string);
begin
  FName := pName;
end;

{ TProtoUtils }

class function TProtoUtils.GetTypeProtoMessageName<T>: string;
var
  vContext: TRttiContext;
  vType: TRttiType;
  vAttr: TCustomAttribute;
begin
  Result := EmptyStr;

  vContext := TRttiContext.Create;
  vType := vContext.GetType(TypeInfo(T));
  for vAttr in vType.GetAttributes() do
    if vAttr is TProtoMessageNameAttribute then
      Result := TProtoMessageNameAttribute(vAttr).FName;
  vContext.Free;
end;

end.
