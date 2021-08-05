unit Nghttp2;

{ Header translation of ngHttp library for HTTP/2 protocol support, see https://nghttp2.org }

{$I Grijjy.inc}

{ To build the library:
  Download the latest release from https://github.com/nghttp2/releases

For Windows...
  1.  Install CMAKE and the Build Tools for Visual Studio.
  2.  Run CMAKE followed by a period, (ex: cmake .)
  3.  Run CMAKE to build the release version (ex: cmake --build . --config RELEASE)

For Linux...
  1.  ./configure
  2.  sudo make
  3.  sudo make install
}

interface

const
  {$IF Defined(MSWINDOWS)}
  NGHTTP2_LIB = 'nghttp2.dll';
  {$ELSEIF Defined(LINUX)}
  NGHTTP2_LIB = 'libnghttp2.so';
  {$ELSE}
  NGHTTP2_LIB = '';  //android etc not supported
  {$ENDIF}

const
  //NGHTTP2 ERROR CODE
  NGHTTP2_NO_ERROR = 0;
  NGHTTP2_PROTOCOL_ERROR = 1;
  NGHTTP2_INTERNAL_ERROR = 2;
  NGHTTP2_FLOW_CONTROL_ERROR = 3;
  NGHTTP2_SETTINGS_TIMEOUT = 4;
  NGHTTP2_STREAM_CLOSED = 5;
  NGHTTP2_FRAME_SIZE_ERROR = 6;
  NGHTTP2_REFUSED_STREAM = 7;
  NGHTTP2_CANCEL = 8;
  NGHTTP2_COMPRESSION_ERROR = 9;
  NGHTTP2_CONNECT_ERROR = 10;
  NGHTTP2_ENHANCE_YOUR_CALM = 11;
  NGHTTP2_INADEQUATE_SECURITY = 12;
  NGHTTP2_HTTP_1_1_REQUIRED = 13;

  NGHTTP2_ERR_CALLBACK_FAILURE = -902;

  NGHTTP2_DATA = 0;
  _NGHTTP2_HEADERS = 1;
  NGHTTP2_HCAT_REQUEST = 0;
  NGHTTP2_HCAT_RESPONSE = 1;
  NGHTTP2_HCAT_PUSH_RESPONSE = 2;
  NGHTTP2_HCAT_HEADERS = 3;
  NGHTTP2_NV_FLAG_NONE = 0;
  NGHTTP2_NV_FLAG_NO_INDEX = 1;
  NGHTTP2_NV_FLAG_NO_COPY_NAME = 2;
  NGHTTP2_NV_FLAG_NO_COPY_VALUE = 4;
  NGHTTP2_SETTINGS_ENABLE_PUSH = 2;
  NGHTTP2_SETTINGS_MAX_CONCURRENT_STREAMS = 3;
  NGHTTP2_SETTINGS_INITIAL_WINDOW_SIZE = 4;
  NGHTTP2_SETTINGS_MAX_FRAME_SIZE = 5;
  NGHTTP2_SETTINGS_MAX_HEADER_LIST_SIZE = 6;

  NGHTTP2_FLAG_NONE = 0;
  NGHTTP2_FLAG_END_STREAM = 1;
  NGHTTP2_FLAG_END_HEADERS = 4;

  NGHTTP2_DATA_FLAG_NONE = 0;
  NGHTTP2_DATA_FLAG_EOF = 1;
  NGHTTP2_DATA_FLAG_NO_END_STREAM = 2;

type
  size_t = NativeUInt;
  ssize_t = NativeInt;
  puint8 = ^uint8;
  puint32 = ^uint32;

  pnghttp2_option = Pointer;
  ppnghttp2_option = ^pnghttp2_option;

  pnghttp2_session = Pointer;
  ppnghttp2_session = ^pnghttp2_session;

  pnghttp2_session_callbacks = Pointer;
  nghttp2_nv = record
    name : MarshaledAString;
    value: MarshaledAString;
    namelen: size_t;
    valuelen: size_t;
    flags: uint8;
  end;
  pnghttp2_nv = ^nghttp2_nv;

  nghttp2_priority_spec = record
    stream_id: int32;
    weight: int32;
    exclusive: uint8;
  end;
  pnghttp2_priority_spec = ^nghttp2_priority_spec;

  nghttp2_settings_entry = record
    settings_id: int32;
    value: uint32;
  end;
  pnghttp2_settings_entry = ^nghttp2_settings_entry;

  nghttp2_frame_hd = record
    length: size_t;
    stream_id: int32;
    &type: uint8;
    flags: uint8;
    reserved: uint8;
  end;

  nghttp2_headers = record
    hd: nghttp2_frame_hd;
    padlen: size_t;
    pri_spec: nghttp2_priority_spec;
    nva: pnghttp2_nv;
    nvlen: size_t;
    cat: Integer; { enum }
  end;

  nghttp2_frame = record
    case Integer of
    0:(hd: nghttp2_frame_hd);
    1:(headers: nghttp2_headers);
//    nghttp2_frame_hd hd;
//    nghttp2_data data;
//    nghttp2_headers headers;
//    nghttp2_priority priority;
//    nghttp2_rst_stream rst_stream;
//    nghttp2_settings settings;
//    nghttp2_push_promise push_promise;
//    nghttp2_ping ping;
//    nghttp2_goaway goaway;
//    nghttp2_window_update window_update;
//    nghttp2_extension ext;
  end;
  pnghttp2_frame = ^nghttp2_frame;

  nghttp2_data_source = record
  case Integer of
    0:(fd: Integer);
    1:(ptr: Pointer);
  end;
  pnghttp2_data_source = ^nghttp2_data_source;

  nghttp2_data_source_read_callback = function(session: pnghttp2_session; stream_id: int32; buf: puint8; length:
    size_t; data_flags: puint32; source: pnghttp2_data_source; user_data: Pointer): ssize_t; cdecl;

  nghttp2_data_provider = record
    source: nghttp2_data_source;
    read_callback: nghttp2_data_source_read_callback;
  end;
  pnghttp2_data_provider = ^nghttp2_data_provider;

  nghttp2_on_header_callback = function(session: pnghttp2_session; const frame: pnghttp2_frame;
    const name: puint8; namelen: size_t; const value: puint8; valuelen: size_t;
      flags: uint8; user_data: Pointer): Integer; cdecl;

  nghttp2_on_begin_headers_callback = function(session: pnghttp2_session;
    const frame: pnghttp2_frame; user_data: Pointer): Integer; cdecl;

  nghttp2_on_before_frame_send_callback = function(session: pnghttp2_session;
    const frame: pnghttp2_frame; user_data: Pointer): Integer; cdecl;

  nghttp2_on_frame_recv_callback = function(session: pnghttp2_session;
    const frame: pnghttp2_frame; user_data: Pointer): Integer; cdecl;

  nghttp2_on_frame_send_callback = function(session: pnghttp2_session;
    const frame: pnghttp2_frame; user_data: Pointer): Integer; cdecl;

  nghttp2_on_data_chunk_recv_callback = function(session: pnghttp2_session;
    flags: uint8; stream_id: int32; const data: puint8; len: size_t;
    user_data: Pointer): Integer; cdecl;

  nghttp2_on_stream_close_callback = function(session: pnghttp2_session;
    stream_id: int32; error_code: uint32; user_data: Pointer): Integer; cdecl;

  TNGHTTP2 = class
  private
    class var fInstance: TNGHTTP2;
    fLibHandle: THandle;
  public
    nghttp2_submit_settings: function(session: pnghttp2_session; flags: uint8; const iv: pnghttp2_settings_entry; niv: size_t): Integer; cdecl;

    nghttp2_session_client_new: function(var session_ptr: pnghttp2_session;
      const callbacks: pnghttp2_session_callbacks; user_data: Pointer): Integer; cdecl;

    nghttp2_session_server_new: function(var session_ptr: pnghttp2_session;
      const callbacks: pnghttp2_session_callbacks; user_data: Pointer): Integer; cdecl;

    nghttp2_session_del: procedure(session_ptr: pnghttp2_session); cdecl;

    nghttp2_session_callbacks_new: function(out callbacks_ptr: pnghttp2_session_callbacks): Integer; cdecl;

    nghttp2_session_callbacks_del: procedure(callbacks: pnghttp2_session_callbacks); cdecl;

    nghttp2_session_callbacks_set_on_begin_headers_callback: procedure(callbacks: pnghttp2_session_callbacks;
      on_header_callback: nghttp2_on_begin_headers_callback); cdecl;

    nghttp2_session_callbacks_set_before_frame_send_callback: procedure(callbacks: pnghttp2_session_callbacks;
      on_before_frame_send_callback: nghttp2_on_before_frame_send_callback); cdecl;

    nghttp2_session_callbacks_set_on_header_callback: procedure(callbacks: pnghttp2_session_callbacks;
      on_header_callback: nghttp2_on_header_callback); cdecl;

    nghttp2_session_callbacks_set_on_frame_send_callback: procedure(callbacks: pnghttp2_session_callbacks;
      on_frame_send_callback: nghttp2_on_frame_send_callback); cdecl;

    nghttp2_session_callbacks_set_on_frame_recv_callback: procedure(callbacks: pnghttp2_session_callbacks;
      on_frame_recv_callback: nghttp2_on_frame_recv_callback); cdecl;

    nghttp2_session_callbacks_set_on_data_chunk_recv_callback: procedure(callbacks: pnghttp2_session_callbacks;
      on_data_chunk_recv_callback: nghttp2_on_data_chunk_recv_callback); cdecl;

    nghttp2_session_callbacks_set_on_stream_close_callback: procedure(callbacks: pnghttp2_session_callbacks;
      on_stream_close_callback: nghttp2_on_stream_close_callback); cdecl;

    nghttp2_session_terminate_session: function(session: pnghttp2_session; error_code: uint32): Integer; cdecl;

    nghttp2_submit_request: function(session: pnghttp2_session; const pri_spec: pnghttp2_priority_spec;
      const nva: pnghttp2_nv; nvlen: size_t; const data_prd: pnghttp2_data_provider; stream_user_data: Pointer): int32; cdecl;

    nghttp2_submit_response: function(session: pnghttp2_session; stream_id: int32;
      const nva: pnghttp2_nv; nvlen: size_t; const data_prd: pnghttp2_data_provider): int32; cdecl;

    nghttp2_session_get_stream_user_data: function(session: pnghttp2_session;
      stream_id: int32): Pointer; cdecl;

    nghttp2_session_set_stream_user_data: function(session: pnghttp2_session;
      stream_id: int32; stream_user_data: Pointer): Int32; cdecl;

    nghttp2_priority_spec_init: procedure(pri_spec: pnghttp2_priority_spec; stream_id: int32; weight: int32; exclusive: integer); cdecl;

    nghttp2_session_get_next_stream_id: function (session: pnghttp2_session): uint32; cdecl;

    nghttp2_session_mem_recv: function(session: pnghttp2_session; const &in: Pointer; const inlen: size_t): Integer; cdecl;

    nghttp2_session_mem_send: function(session: pnghttp2_session; out data_ptr: Pointer): Integer; cdecl;

    nghttp2_session_want_read: function(session: pnghttp2_session): Integer; cdecl;

    nghttp2_session_change_stream_priority: function(session: pnghttp2_session; stream_id: int32; pri_spec: pnghttp2_priority_spec): Integer; cdecl;

    nghttp2_session_want_write: function(session: pnghttp2_session): Integer; cdecl;

    nghttp2_submit_rst_stream: function(session: pnghttp2_session; flags: uint8; stream_id: int32; error_code: uint32): Integer; cdecl;

    nghttp2_submit_data: function(session: pnghttp2_session; flags: uint8; stream_id: int32; data_provider: pnghttp2_data_provider): Integer; cdecl;

    nghttp2_option_new: function(var option: pnghttp2_option): Integer; cdecl;

    nghttp2_option_del: procedure(option: ppnghttp2_option); cdecl;

    nghttp2_option_set_no_closed_streams: procedure(session: pnghttp2_session; val: int32); cdecl;

    function StartUp: Integer;
    destructor Destroy; override;
    class function GetInstance: TNGHTTP2;
  end;

//function MAKE_NV2(name, value: MarshaledAString): nghttp2_nv;//function MAKE_NV(name, value: MarshaledAString; valuelen: uint8): nghttp2_nv;

implementation

uses
  System.Classes,
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF}
  System.SyncObjs,
  System.SysUtils;

//function MAKE_NV2(name, value: MarshaledAString): nghttp2_nv;
//begin
//  Result.name := name;
//  Result.value := value;
//  Result.namelen := StrLen(name);
//  Result.valuelen := StrLen(value);
//  Result.flags := NGHTTP2_NV_FLAG_NONE;
//end;
//
//function MAKE_NV(name, value: MarshaledAString; valuelen: uint8): nghttp2_nv;
//begin
//  Result.name := name;
//  Result.value := value;
//  Result.namelen := StrLen(name);
//  Result.valuelen := valuelen;
//  Result.flags := NGHTTP2_NV_FLAG_NONE;
//end;

{ TNGHTTP2 }

destructor TNGHTTP2.Destroy;
begin
  if (fLibHandle = 0) then
    Exit;
  FreeLibrary(fLibHandle);
  inherited Destroy;
end;

class function TNGHTTP2.GetInstance: TNGHTTP2;
var
  vErrorCode: Integer;
begin
  if (fInstance = nil) then
  begin
    fInstance := TNGHTTP2.Create;
    vErrorCode := fInstance.StartUp;
    if vErrorCode < 0 then
      FreeAndNil(fInstance);
  end;
  Result := fInstance;
end;

function TNGHTTP2.StartUp: Integer;
begin
  fLibHandle := LoadLibrary(PWideChar(NGHTTP2_LIB));
  if fLibHandle <> 0 then
  begin
    nghttp2_submit_settings := GetProcAddress(fLibHandle, 'nghttp2_submit_settings');
    nghttp2_session_client_new := GetProcAddress(fLibHandle, 'nghttp2_session_client_new');
    nghttp2_session_server_new := GetProcAddress(fLibHandle, 'nghttp2_session_server_new');
    nghttp2_session_del := GetProcAddress(fLibHandle, 'nghttp2_session_del');
    nghttp2_session_callbacks_new := GetProcAddress(fLibHandle, 'nghttp2_session_callbacks_new');
    nghttp2_session_callbacks_del := GetProcAddress(fLibHandle, 'nghttp2_session_callbacks_del');
    nghttp2_session_callbacks_set_on_header_callback := GetProcAddress(fLibHandle, 'nghttp2_session_callbacks_set_on_header_callback');
    nghttp2_session_callbacks_set_before_frame_send_callback := GetProcAddress(fLibHandle, 'nghttp2_session_callbacks_set_before_frame_send_callback');
    nghttp2_session_callbacks_set_on_begin_headers_callback := GetProcAddress(fLibHandle, 'nghttp2_session_callbacks_set_on_begin_headers_callback');
    nghttp2_session_callbacks_set_on_frame_send_callback := GetProcAddress(fLibHandle, 'nghttp2_session_callbacks_set_on_frame_send_callback');
    nghttp2_session_callbacks_set_on_frame_recv_callback := GetProcAddress(fLibHandle, 'nghttp2_session_callbacks_set_on_frame_recv_callback');
    nghttp2_session_callbacks_set_on_data_chunk_recv_callback := GetProcAddress(fLibHandle, 'nghttp2_session_callbacks_set_on_data_chunk_recv_callback');
    nghttp2_session_callbacks_set_on_stream_close_callback := GetProcAddress(fLibHandle, 'nghttp2_session_callbacks_set_on_stream_close_callback');
    nghttp2_session_terminate_session := GetProcAddress(fLibHandle, 'nghttp2_session_terminate_session');
    nghttp2_submit_request := GetProcAddress(fLibHandle, 'nghttp2_submit_request');
    nghttp2_session_get_stream_user_data := GetProcAddress(fLibHandle, 'nghttp2_session_get_stream_user_data');
    nghttp2_session_set_stream_user_data := GetProcAddress(fLibHandle, 'nghttp2_session_set_stream_user_data');
    nghttp2_priority_spec_init := GetProcAddress(fLibHandle, 'nghttp2_priority_spec_init');
    nghttp2_session_get_next_stream_id := GetProcAddress(fLibHandle, 'nghttp2_session_get_next_stream_id');
    nghttp2_submit_response := GetProcAddress(fLibHandle, 'nghttp2_submit_response');
    nghttp2_session_change_stream_priority := GetProcAddress(fLibHandle, 'nghttp2_session_change_stream_priority');
    nghttp2_session_mem_recv := GetProcAddress(fLibHandle, 'nghttp2_session_mem_recv');
    nghttp2_session_mem_send := GetProcAddress(fLibHandle, 'nghttp2_session_mem_send');
    nghttp2_session_want_read := GetProcAddress(fLibHandle, 'nghttp2_session_want_read');
    nghttp2_session_want_write := GetProcAddress(fLibHandle, 'nghttp2_session_want_write');
    nghttp2_submit_rst_stream := GetProcAddress(fLibHandle, 'nghttp2_submit_rst_stream');
    nghttp2_submit_data := GetProcAddress(fLibHandle, 'nghttp2_submit_data');
    {$IFNDEF WIN32}
    nghttp2_option_new := GetProcAddress(fLibHandle, 'nghttp2_option_new');
    nghttp2_option_del := GetProcAddress(fLibHandle, 'nghttp2_option_del');
    nghttp2_option_set_no_closed_streams := GetProcAddress(fLibHandle, 'nghttp2_option_set_no_closed_streams');
    {$ENDIF}
  end;

  if (@nghttp2_submit_settings = nil) or
    (@nghttp2_session_client_new = nil) or
    (@nghttp2_session_server_new = nil) or
    (@nghttp2_session_del = nil) or
    (@nghttp2_session_callbacks_new = nil) or
    (@nghttp2_session_callbacks_del = nil) or
    (@nghttp2_session_callbacks_set_before_frame_send_callback = nil) or
    (@nghttp2_session_callbacks_set_on_header_callback = nil) or
    (@nghttp2_session_callbacks_set_on_begin_headers_callback = nil) or
    (@nghttp2_session_callbacks_set_on_frame_send_callback = nil) or
    (@nghttp2_session_callbacks_set_on_frame_recv_callback = nil) or
    (@nghttp2_session_callbacks_set_on_data_chunk_recv_callback = nil) or
    (@nghttp2_session_callbacks_set_on_stream_close_callback = nil) or
    (@nghttp2_session_terminate_session = nil) or
    (@nghttp2_submit_request = nil) or
    (@nghttp2_session_get_stream_user_data = nil) or
    (@nghttp2_session_set_stream_user_data = nil) or
    (@nghttp2_priority_spec_init = nil) or
    (@nghttp2_session_get_next_stream_id = nil) or
    (@nghttp2_submit_response = nil) or
    (@nghttp2_session_change_stream_priority = nil) or
    (@nghttp2_session_mem_recv = nil) or
    (@nghttp2_session_mem_send = nil) or
    (@nghttp2_session_want_read = nil) or
    {$IFNDEF WIN32}
    (@nghttp2_option_new = nil) or
    (@nghttp2_option_del = nil) or
    (@nghttp2_option_set_no_closed_streams = nil) or
    {$ENDIF}
    (@nghttp2_session_want_write = nil) or
    (@nghttp2_submit_rst_stream = nil) or
    (@nghttp2_submit_data = nil) then
      Result := -1
    else
      Result := 0;
end;

initialization

finalization
  FreeAndNil(TNGHTTP2.fInstance);

end.
