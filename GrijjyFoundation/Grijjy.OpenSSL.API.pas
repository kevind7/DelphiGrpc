unit Grijjy.OpenSSL.API;

{ Provides an interface to OpenSSL }

{$I Grijjy.inc}

interface

uses
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF}
  System.Classes,
  System.SyncObjs,
  System.SysUtils;

const
  {$IFDEF LINUX}
  SSLEAY_DLL = 'libssl.so.1.0.0';
  LIBEAY_DLL = 'libcrypto.so.1.0.0';
  {$ELSE}
  SSLEAY_DLL = 'ssleay32.dll';
  LIBEAY_DLL = 'libeay32.dll';
  {$ENDIF}

const
  SSL_ERROR_NONE = 0;
  SSL_ERROR_SSL = 1;
  SSL_ERROR_WANT_READ = 2;
  SSL_ERROR_WANT_WRITE = 3;
  SSL_ERROR_WANT_X509_LOOKUP = 4;
  SSL_ERROR_SYSCALL = 5;
  SSL_ERROR_ZERO_RETURN = 6;
  SSL_ERROR_WANT_CONNECT = 7;
  SSL_ERROR_WANT_ACCEPT = 8;

  SSL_ST_OK = 3;
  SSL_VERIFY_NONE = 0;

  SSL_OP_ALL = $000FFFFF;
  SSL_OP_NO_SSLv2 = $01000000;
  SSL_OP_NO_SSLv3 = $02000000;
  SSL_OP_NO_COMPRESSION = $00020000;

  BIO_CTRL_INFO = 3;
  BIO_CTRL_PENDING = 10;

  CRYPTO_LOCK = 1;
  CRYPTO_UNLOCK = 2;
  CRYPTO_READ = 4;
  CRYPTO_WRITE = 8;

  BIO_FLAGS_READ = 1;
  BIO_FLAGS_WRITE = 2;
  BIO_FLAGS_IO_SPECIAL = 4;
  BIO_FLAGS_RWS = (BIO_FLAGS_READ or BIO_FLAGS_WRITE or BIO_FLAGS_IO_SPECIAL);
  BIO_FLAGS_SHOULD_RETRY = 8;
  BIO_NOCLOSE = 0;
  BIO_CLOSE = 1;

type
  PSSL_METHOD = Pointer;
  PSSL_CTX = Pointer;
  PBIO = Pointer;
  PSSL = Pointer;
  PX509_STORE = Pointer;
  PEVP_PKEY = Pointer;
  PPEVP_PKEY = ^PEVP_PKEY;
  PEVP_PKEY_CTX = Pointer;
  PEVP_MD_CTX = Pointer;
  PEVP_MD = Pointer;
  PENGINE = Pointer;
  PX509 = Pointer;
  PPX509 = ^PX509;

  TASN1_STRING = record
    length: Integer;
    type_: Integer;
    data: MarshaledAString;
    flags: Longword;
  end;
  PASN1_STRING = ^TASN1_STRING;
  TASN1_BIT_STRING = TASN1_STRING;
  PASN1_BIT_STRING = ^TASN1_BIT_STRING;

  TSetVerify_cb = function(Ok: Integer; StoreCtx: PX509_STORE): Integer; cdecl;

  TCRYPTO_dynlock_value = record
    Mutex: TCriticalSection;
  end;
  PCRYPTO_dynlock_value = ^TCRYPTO_dynlock_value;

  PBIO_METHOD = Pointer;
  PX509_NAME = Pointer;
  PSTACK = Pointer;
  PASN1_OBJECT = Pointer;

  TStatLockLockCallback = procedure(Mode: Integer; N: Integer; const _File: MarshaledAString; Line: Integer); cdecl;
  TDynLockCreateCallback = function(const _file: MarshaledAString; Line: Integer): PCRYPTO_dynlock_value; cdecl;
  TDynLockLockCallback = procedure(Mode: Integer; L: PCRYPTO_dynlock_value; _File: MarshaledAString; Line: Integer); cdecl;
  TDynLockDestroyCallback = procedure(L: PCRYPTO_dynlock_value; _File: MarshaledAString; Line: Integer); cdecl;
  TPemPasswordCallback = function(buf: Pointer; size: Integer; rwflag: Integer; userdata: Pointer): Integer; cdecl;

  TOpenSSL = class
    private
      class var FTarget: Integer;
      fLibeayHandle: THandle;
      fSSLeayHandle: THandle;
    public
      SSL_library_init: function: Integer; cdecl;
      SSL_load_error_strings: procedure; cdecl;
      SSLv3_method: function: PSSL_METHOD; cdecl;
      SSLv23_method: function: PSSL_METHOD; cdecl;
      TLSv1_method: function: PSSL_METHOD; cdecl;
      TLSv1_1_method: function: PSSL_METHOD; cdecl;
      SSL_CTX_new: function(meth: PSSL_METHOD): PSSL_CTX; cdecl;
      SSL_CTX_free: procedure(ctx: PSSL_CTX); cdecl;
      SSL_CTX_set_verify: procedure(ctx: PSSL_CTX; mode: Integer; callback: TSetVerify_cb); cdecl;
      SSL_CTX_use_PrivateKey: function(ctx: PSSL_CTX; pkey: PEVP_PKEY): Integer; cdecl;
      SSL_CTX_use_RSAPrivateKey: function(ctx: PSSL_CTX; pkey: PEVP_PKEY): Integer; cdecl;
      SSL_CTX_use_certificate: function(ctx: PSSL_CTX; x: PX509): Integer; cdecl;
      SSL_CTX_check_private_key: function(ctx: PSSL_CTX): Integer; cdecl;
      SSL_CTX_use_certificate_file: function(ctx: PSSL_CTX; f: MarshaledAString; t: Integer): Integer; cdecl;
      SSL_CTX_use_RSAPrivateKey_file: function(ctx: PSSL_CTX; f: MarshaledAString; t: Integer): Integer; cdecl;
      SSL_CTX_get_cert_store: function(ctx: PSSL_CTX): PX509_STORE; cdecl;
      SSL_CTX_ctrl: function(ctx: PSSL_CTX; cmd, i: integer; p: pointer): Integer; cdecl;
      SSL_CTX_load_verify_locations: function(ctx: PSSL_CTX; CAFile: MarshaledAString; CAPath: MarshaledAString): Integer; cdecl;
      SSL_CTX_use_certificate_chain_file: function(ctx: PSSL_CTX; CAFile: MarshaledAString): Integer; cdecl;
      SSL_CTX_set_alpn_protos: function(ctx: PSSL_CTX; protos: MarshaledAString; protos_len: Integer): Integer; cdecl;
      SSL_new: function(ctx: PSSL_CTX): PSSL; cdecl;
      SSL_set_bio: procedure(s: PSSL; rbio, wbio: PBIO); cdecl;
      SSL_get_peer_certificate: function(s: PSSL): PX509; cdecl;
      SSL_get_error: function(s: PSSL; ret_code: Integer): Integer; cdecl;
      SSL_shutdown: function(s: PSSL): Integer; cdecl;
      SSL_free: procedure(s: PSSL); cdecl;
      SSL_connect: function(s: PSSL): Integer; cdecl;
      SSL_set_connect_state: procedure(s: PSSL); cdecl;
      SSL_set_accept_state: procedure(s: PSSL); cdecl;
      SSL_read: function(s: PSSL; buf: Pointer; num: Integer): Integer; cdecl;
      SSL_write: function(s: PSSL; const buf: Pointer; num: Integer): Integer; cdecl;
      SSL_state: function(s: PSSL): Integer; cdecl;
      SSL_pending: function(s: PSSL): Integer; cdecl;
      SSL_set_cipher_list: function(s: PSSL; ciphers: MarshaledAString): Integer; cdecl;
      SSL_get0_alpn_selected: procedure (s: PSSL; out data: MarshaledAString; out len: Integer); cdecl;
      SSL_clear: function(s: PSSL): Integer; cdecl;
      CRYPTO_num_locks: function: Integer; cdecl;
      CRYPTO_set_locking_callback: procedure(callback: TStatLockLockCallback); cdecl;
      CRYPTO_set_dynlock_create_callback: procedure(callback: TDynLockCreateCallBack); cdecl;
      CRYPTO_set_dynlock_lock_callback: procedure(callback: TDynLockLockCallBack); cdecl;
      CRYPTO_set_dynlock_destroy_callback: procedure(callback: TDynLockDestroyCallBack); cdecl;
      CRYPTO_cleanup_all_ex_data: procedure; cdecl;
      ERR_remove_state: procedure(tid: Cardinal); cdecl;
      ERR_free_strings: procedure; cdecl; // thread-unsafe, Application-global cleanup functions
      ERR_error_string_n: procedure(err: Cardinal; buf: MarshaledAString; len: NativeUInt); cdecl;
      ERR_get_error: function: Cardinal; cdecl;
      ERR_remove_thread_state: procedure(pid: Cardinal); cdecl;
      ERR_load_BIO_strings: function: Cardinal; cdecl;
      EVP_cleanup: procedure; cdecl;
      EVP_PKEY_free: procedure(pkey: PEVP_PKEY); cdecl;
      BIO_new: function(BioMethods: PBIO_METHOD): PBIO; cdecl;
      BIO_ctrl: function(bp: PBIO; cmd: Integer; larg: Longint; parg: Pointer): Longint; cdecl;
      BIO_new_mem_buf: function(buf: Pointer; len: Integer): PBIO; cdecl;
      BIO_free: function(b: PBIO): Integer; cdecl;
      BIO_s_mem: function: PBIO_METHOD; cdecl;
      BIO_read: function(b: PBIO; Buf: Pointer; Len: Integer): Integer; cdecl;
      BIO_write: function(b: PBIO; Buf: Pointer; Len: Integer): Integer; cdecl;
      BIO_new_socket: function(sock: Integer; close_flag: Integer): PBIO; cdecl;
      X509_get_issuer_name: function(cert: PX509): PX509_NAME; cdecl;
      X509_get_subject_name: function(cert: PX509): PX509_NAME; cdecl;
      X509_free: procedure(cert: PX509); cdecl;
      X509_NAME_print_ex: function(bout: PBIO; nm: PX509_NAME; indent: Integer; flags: Cardinal): Integer; cdecl;
      sk_num: function(stack: PSTACK): Integer; cdecl;
      sk_pop: function(stack: PSTACK): Pointer; cdecl;
      ASN1_BIT_STRING_get_bit: function(a: PASN1_BIT_STRING; n: Integer): Integer; cdecl;
      OBJ_obj2nid: function(o: PASN1_OBJECT): Integer; cdecl;
      OBJ_nid2sn: function(n: Integer): MarshaledAString; cdecl;
      ASN1_STRING_data: function(x: PASN1_STRING): Pointer; cdecl;
      PEM_read_bio_X509: function(bp: PBIO; x: PX509; cb: TPemPasswordCallback; u: Pointer): PX509; cdecl;
      PEM_read_bio_PrivateKey: function(bp: PBIO; x: PPEVP_PKEY; cb: TPemPasswordCallback; u: Pointer): PEVP_PKEY; cdecl;
      PEM_read_bio_RSAPrivateKey: function(bp: PBIO; x: PPEVP_PKEY; cb: TPemPasswordCallback; u: Pointer): PEVP_PKEY; cdecl;
      EVP_MD_CTX_create: function: PEVP_MD_CTX; cdecl;
      EVP_MD_CTX_destroy: procedure(ctx: PEVP_MD_CTX); cdecl;
      EVP_sha256: function: PEVP_MD; cdecl;
      EVP_sha1: function: PEVP_MD; cdecl;
      EVP_PKEY_size: function(key: PEVP_PKEY): Integer; cdecl;
      EVP_DigestSignInit: function(aCtx: PEVP_MD_CTX; aPCtx: PEVP_PKEY_CTX; aType: PEVP_MD; aEngine: PENGINE; aKey: PEVP_PKEY): Integer; cdecl;
      EVP_DigestUpdate: function(ctx: PEVP_MD_CTX; const d: Pointer; cnt: Cardinal): Integer; cdecl;
      EVP_DigestSignFinal: function(ctx : PEVP_MD_CTX; const d: PByte; var cnt: Cardinal): Integer; cdecl;
      EVP_DigestVerifyInit: function(aCtx: PEVP_MD_CTX; aPCtx: PEVP_PKEY_CTX; aType: PEVP_MD; aEngine: PENGINE; aKey: pEVP_PKEY): Integer; cdecl;
      EVP_DigestVerifyFinal: function(ctx : pEVP_MD_CTX; const d: PByte; cnt: Cardinal) : Integer; cdecl;
      CRYPTO_malloc: function(aLength : LongInt; const f : MarshaledAString; aLine : Integer): Pointer; cdecl;
      CRYPTO_free: procedure(str: Pointer); cdecl;
      HMAC: function(evp: PEVP_MD; key: PByte; key_len: Integer; data: PByte; data_len: Integer; md: PByte; var md_len: integer): PByte; cdecl;

      FSSLLocks: TArray<TCriticalSection>;

      class var fInstance: TOpenSSL;
      class var OnDestroy: procedure of object;
      class var OnCreate: procedure of object;

      destructor Destroy; override;
      class function GetInstance: TOpenSSL;

      function BIOGetFlags(const ABIO: PBIO): Integer; inline;
      function BIORetry(const ABIO: PBIO): Boolean; inline;
      function SetSSLCTXOptions(const ACTX: Pointer; const AOP: Integer): Integer;
      function SSLErrorFatal(const AError: Integer): Boolean;
      function SSLError(const ASSL: PSSL; const AReturnCode: Integer; out AErrorMsg: String): Integer;
      procedure SSLFinalize;
      procedure SSLInitialize;

      function StartUp: Integer;
  end;

implementation

function TOpenSSL.BIOGetFlags(const ABIO: PBIO): Integer;
begin
  Result := PInteger(MarshaledAString(ABIO) + 3 * SizeOf(Pointer) + 2 * SizeOf(Integer))^;
end;

function TOpenSSL.BIORetry(const ABIO: PBIO): Boolean;
begin
  Result := ((BIOGetFlags(ABIO) and BIO_FLAGS_SHOULD_RETRY) <> 0);
end;

function TOpenSSL.SetSSLCTXOptions(const ACTX: pointer; const AOP: integer): Integer;
const
  SSL_CTRL_OPTIONS = 32;
begin
  result := SSL_CTX_ctrl(ACTX, SSL_CTRL_OPTIONS, AOP, nil);
end;

function TOpenSSL.SSLErrorFatal(const AError: Integer): Boolean;
begin
	case AError of
		SSL_ERROR_NONE,
		SSL_ERROR_WANT_READ,
		SSL_ERROR_WANT_WRITE,
		SSL_ERROR_WANT_CONNECT,
		SSL_ERROR_WANT_ACCEPT: Result := False;
  else
    Result := True;
	end;
end;

function TOpenSSL.SSLError(const ASSL: PSSL; const AReturnCode: Integer; out AErrorMsg: String): Integer;
var
  error, error_log: Integer;
  ErrorBuf: TBytes;
begin
	error := SSL_get_error(ASSL, AReturnCode);
	if(error <> SSL_ERROR_NONE) then
	begin
		error_log := error;
		while (error_log <> SSL_ERROR_NONE) do
    begin
      SetLength(ErrorBuf, 512);
			ERR_error_string_n(error_log, @ErrorBuf[0], Length(ErrorBuf));
			if (SSLErrorFatal(error_log)) then
        AErrorMsg := StringOf(ErrorBuf);
			error_log := ERR_get_error();
		end;
	end;
	Result := error;
end;

procedure CRYPTO_locking_callback(Mode, N: Integer; const _File: MarshaledAString; Line: Integer); cdecl;
begin
	if(mode and CRYPTO_LOCK <> 0) then
    TOpenSSL.GetInstance.FSSLLocks[N].Enter
	else
    TOpenSSL.GetInstance.FSSLLocks[N].Leave;
end;

procedure CRYPTO_dynlock_callback_lock(Mode: Integer; L: PCRYPTO_dynlock_value; _File: MarshaledAString; Line: Integer); cdecl;
begin
  if (Mode and CRYPTO_LOCK <> 0) then
    L.Mutex.Enter
  else
    L.Mutex.Leave;
end;

function CRYPTO_dynlock_callback_create(const _file: MarshaledAString; Line: Integer): PCRYPTO_dynlock_value; cdecl;
begin
  New(Result);
  Result.Mutex := TCriticalSection.Create;
end;

procedure CRYPTO_dynlock_callback_destroy(L: PCRYPTO_dynlock_value; _File: MarshaledAString; Line: Integer); cdecl;
begin
  L.Mutex.Free;
  Dispose(L);
end;

procedure TOpenSSL.SSLInitialize;
var
  Locks, I: Integer;
begin
  if (fSSLeayHandle = 0) or (Self.fLibeayHandle = 0) then
    Exit;

  Locks := CRYPTO_num_locks();
	if(Locks > 0) then
  begin
    SetLength(FSSLLocks, Locks);
    for I := Low(FSSLLocks) to High(FSSLLocks) do
      FSSLLocks[I] := TCriticalSection.Create;
	end;

	CRYPTO_set_locking_callback(CRYPTO_locking_callback);
  CRYPTO_set_dynlock_create_callback(CRYPTO_dynlock_callback_create);
	CRYPTO_set_dynlock_lock_callback(CRYPTO_dynlock_callback_lock);
  CRYPTO_set_dynlock_destroy_callback(CRYPTO_dynlock_callback_destroy);

  SSL_load_error_strings();
  SSL_library_init();
end;

procedure TOpenSSL.SSLFinalize;
var
  I: Integer;
begin
  if (fSSLeayHandle = 0) or (Self.fLibeayHandle = 0) then
    Exit;

	CRYPTO_set_locking_callback(nil);
	CRYPTO_set_dynlock_create_callback(nil);
	CRYPTO_set_dynlock_lock_callback(nil);
	CRYPTO_set_dynlock_destroy_callback(nil);

  EVP_cleanup();
  CRYPTO_cleanup_all_ex_data();
  ERR_remove_state(0);
  ERR_free_strings();

  for I := Low(FSSLLocks) to High(FSSLLocks) do
    FSSLLocks[I].Free;
  FSSLLocks := nil;
end;

{ TOpenSSL }

destructor TOpenSSL.Destroy;
begin
  if (TInterlocked.Decrement(FTarget) = 0) then
  begin
    SSLFinalize;
    if (fSSLeayHandle <> 0) then
    begin
      FreeLibrary(fSSLeayHandle);
      fSSLeayHandle := 0;
    end;
    if (fLibeayHandle <> 0) then
    begin
      FreeLibrary(fLibeayHandle);
      fLibeayHandle := 0;
    end;
  end;
  //TODO-1 -> OnBeforeDestroy -> _MemBufferPool.Free;
  inherited Destroy;
end;

class function TOpenSSL.GetInstance: TOpenSSL;
var
  vErrorCode: Integer;
begin
  if (fInstance = nil) then
  begin
    fInstance := TOpenSSL.Create;
    vErrorCode := fInstance.StartUp;
    if vErrorCode < 0 then
      FreeAndNil(fInstance);
  end;
  Result := fInstance;
end;

function TOpenSSL.StartUp: Integer;
begin
  Result := -1;

  if (fLibeayHandle = 0) then
  begin
    fLibeayHandle := LoadLibrary(PWideChar(LIBEAY_DLL));

    if fLibeayHandle <> 0 then
    begin
      CRYPTO_malloc := GetProcAddress(fLibeayHandle, 'CRYPTO_malloc');
      CRYPTO_free := GetProcAddress(fLibeayHandle, 'CRYPTO_free');
      CRYPTO_num_locks := GetProcAddress(fLibeayHandle, 'CRYPTO_num_locks');
      CRYPTO_set_locking_callback := GetProcAddress(fLibeayHandle, 'CRYPTO_set_locking_callback');
      CRYPTO_set_dynlock_create_callback := GetProcAddress(fLibeayHandle, 'CRYPTO_set_dynlock_create_callback');
      CRYPTO_set_dynlock_lock_callback := GetProcAddress(fLibeayHandle, 'CRYPTO_set_dynlock_lock_callback');
      CRYPTO_set_dynlock_destroy_callback := GetProcAddress(fLibeayHandle, 'CRYPTO_set_dynlock_destroy_callback');
      CRYPTO_cleanup_all_ex_data := GetProcAddress(fLibeayHandle, 'CRYPTO_cleanup_all_ex_data');
      ERR_remove_state := GetProcAddress(fLibeayHandle, 'ERR_remove_state');
      ERR_free_strings := GetProcAddress(fLibeayHandle, 'ERR_free_strings');
      ERR_error_string_n := GetProcAddress(fLibeayHandle, 'ERR_error_string_n');
      ERR_get_error := GetProcAddress(fLibeayHandle, 'ERR_get_error');
      ERR_remove_thread_state := GetProcAddress(fLibeayHandle, 'ERR_remove_thread_state');
      ERR_load_BIO_strings := GetProcAddress(fLibeayHandle, 'ERR_load_BIO_strings');
      EVP_cleanup := GetProcAddress(fLibeayHandle, 'EVP_cleanup');
      EVP_MD_CTX_create := GetProcAddress(fLibeayHandle, 'EVP_MD_CTX_create');
      EVP_MD_CTX_destroy := GetProcAddress(fLibeayHandle, 'EVP_MD_CTX_destroy');
      EVP_sha256 := GetProcAddress(fLibeayHandle, 'EVP_sha256');
      EVP_sha1 := GetProcAddress(fLibeayHandle, 'EVP_sha1');
      EVP_PKEY_size := GetProcAddress(fLibeayHandle, 'EVP_PKEY_size');
      EVP_DigestSignInit := GetProcAddress(fLibeayHandle, 'EVP_DigestSignInit');
      EVP_DigestUpdate := GetProcAddress(fLibeayHandle, 'EVP_DigestUpdate');
      EVP_DigestSignFinal := GetProcAddress(fLibeayHandle, 'EVP_DigestSignFinal');
      EVP_DigestVerifyInit := GetProcAddress(fLibeayHandle, 'EVP_DigestVerifyInit');
      EVP_DigestVerifyFinal := GetProcAddress(fLibeayHandle, 'EVP_DigestVerifyFinal');
      EVP_PKEY_free := GetProcAddress(fLibeayHandle, 'EVP_PKEY_free');
      BIO_new := GetProcAddress(fLibeayHandle, 'BIO_new');
      BIO_ctrl := GetProcAddress(fLibeayHandle, 'BIO_ctrl');
      BIO_new_mem_buf := GetProcAddress(fLibeayHandle, 'BIO_new_mem_buf');
      BIO_free := GetProcAddress(fLibeayHandle, 'BIO_free');
      BIO_s_mem := GetProcAddress(fLibeayHandle, 'BIO_s_mem');
      BIO_read := GetProcAddress(fLibeayHandle, 'BIO_read');
      BIO_write := GetProcAddress(fLibeayHandle, 'BIO_write');
      BIO_new_socket := GetProcAddress(fLibeayHandle, 'BIO_new_socket');
      X509_get_issuer_name := GetProcAddress(fLibeayHandle, 'X509_get_issuer_name');
      X509_get_subject_name := GetProcAddress(fLibeayHandle, 'X509_get_subject_name');
      X509_free := GetProcAddress(fLibeayHandle, 'X509_free');
      X509_NAME_print_ex := GetProcAddress(fLibeayHandle, 'X509_NAME_print_ex');
      sk_num := GetProcAddress(fLibeayHandle, 'sk_num');
      sk_pop := GetProcAddress(fLibeayHandle, 'sk_pop');
      ASN1_BIT_STRING_get_bit := GetProcAddress(fLibeayHandle, 'ASN1_BIT_STRING_get_bit');
      OBJ_obj2nid := GetProcAddress(fLibeayHandle, 'OBJ_obj2nid');
      OBJ_nid2sn := GetProcAddress(fLibeayHandle, 'OBJ_nid2sn');
      ASN1_STRING_data := GetProcAddress(fLibeayHandle, 'ASN1_STRING_data');
      PEM_read_bio_X509 := GetProcAddress(fLibeayHandle, 'PEM_read_bio_X509');
      PEM_read_bio_PrivateKey := GetProcAddress(fLibeayHandle, 'PEM_read_bio_PrivateKey');
      PEM_read_bio_RSAPrivateKey := GetProcAddress(fLibeayHandle, 'PEM_read_bio_RSAPrivateKey');
      HMAC := GetProcAddress(fLibeayHandle, 'HMAC');
    end;

    if (@CRYPTO_malloc = nil) or
    (@CRYPTO_free = nil) or
    (@CRYPTO_num_locks = nil) or
    (@CRYPTO_set_locking_callback = nil) or
    (@CRYPTO_set_dynlock_lock_callback = nil) or
    (@CRYPTO_set_dynlock_destroy_callback = nil) or
    (@CRYPTO_cleanup_all_ex_data = nil) or
    (@ERR_remove_state = nil) or
    (@ERR_free_strings = nil) or
    (@ERR_error_string_n = nil) or
    (@ERR_get_error = nil) or
    (@ERR_remove_thread_state = nil) or
    (@ERR_load_BIO_strings = nil) or
    (@EVP_cleanup = nil) or
    (@EVP_MD_CTX_create = nil) or
    (@EVP_MD_CTX_destroy = nil) or
    (@EVP_sha256 = nil) or
    (@EVP_sha1 = nil) or
    (@EVP_PKEY_size = nil) or
    (@EVP_DigestSignInit = nil) or
    (@EVP_DigestUpdate = nil) or
    (@EVP_DigestSignFinal = nil) or
    (@EVP_DigestVerifyInit = nil) or
    (@EVP_DigestVerifyFinal = nil) or
    (@EVP_PKEY_free = nil) or
    (@BIO_new = nil) or
    (@BIO_ctrl = nil) or
    (@BIO_new_mem_buf = nil) or
    (@BIO_free = nil) or
    (@BIO_s_mem = nil) or
    (@BIO_read = nil) or
    (@BIO_write = nil) or
    (@BIO_new_socket = nil) or
    (@X509_get_issuer_name = nil) or
    (@EVP_cleanup = nil) or
    (@X509_get_subject_name = nil) or
    (@X509_free = nil) or
    (@X509_NAME_print_ex = nil) or
    (@sk_num = nil) or
    (@sk_pop = nil) or
    (@ASN1_BIT_STRING_get_bit = nil) or
    (@OBJ_obj2nid = nil) or
    (@OBJ_nid2sn = nil) or
    (@ASN1_STRING_data = nil) or
    (@PEM_read_bio_X509 = nil) or
    (@PEM_read_bio_PrivateKey = nil) or
    (@PEM_read_bio_RSAPrivateKey = nil) or
    (@HMAC = nil) then
      Exit;
  end;

  if fSSLeayHandle = 0 then
  begin
    fSSLeayHandle := LoadLibrary(PWideChar(SSLEAY_DLL));

    if fSSLeayHandle <> 0 then
    begin
      SSL_library_init := GetProcaddress(fSSLeayHandle, 'SSL_library_init');
      SSL_load_error_strings := GetProcaddress(fSSLeayHandle, 'SSL_load_error_strings');
      SSLv3_method := GetProcaddress(fSSLeayHandle, 'SSLv3_method');
      SSLv23_method := GetProcaddress(fSSLeayHandle, 'SSLv23_method');
      TLSv1_method := GetProcaddress(fSSLeayHandle, 'TLSv1_method');
      TLSv1_1_method := GetProcaddress(fSSLeayHandle, 'TLSv1_1_method');
      SSL_CTX_new := GetProcaddress(fSSLeayHandle, 'SSL_CTX_new');
      SSL_CTX_free := GetProcaddress(fSSLeayHandle, 'SSL_CTX_free');
      SSL_CTX_set_verify := GetProcaddress(fSSLeayHandle, 'SSL_CTX_set_verify');
      SSL_CTX_use_PrivateKey := GetProcaddress(fSSLeayHandle, 'SSL_CTX_use_PrivateKey');
      SSL_CTX_use_RSAPrivateKey := GetProcaddress(fSSLeayHandle, 'SSL_CTX_use_RSAPrivateKey');
      SSL_CTX_use_certificate := GetProcaddress(fSSLeayHandle, 'SSL_CTX_use_certificate');
      SSL_CTX_check_private_key := GetProcaddress(fSSLeayHandle, 'SSL_CTX_check_private_key');
      SSL_CTX_use_certificate_file := GetProcaddress(fSSLeayHandle, 'SSL_CTX_use_certificate_file');
      SSL_CTX_use_RSAPrivateKey_file := GetProcaddress(fSSLeayHandle, 'SSL_CTX_use_RSAPrivateKey_file');
      SSL_CTX_get_cert_store := GetProcaddress(fSSLeayHandle, 'SSL_CTX_get_cert_store');
      SSL_CTX_ctrl := GetProcaddress(fSSLeayHandle, 'SSL_CTX_ctrl');
      SSL_CTX_load_verify_locations := GetProcaddress(fSSLeayHandle, 'SSL_CTX_load_verify_locations');
      SSL_CTX_use_certificate_chain_file := GetProcaddress(fSSLeayHandle, 'SSL_CTX_use_certificate_chain_file');
      SSL_CTX_set_alpn_protos := GetProcaddress(fSSLeayHandle, 'SSL_CTX_set_alpn_protos');
      SSL_new := GetProcaddress(fSSLeayHandle, 'SSL_new');
      SSL_set_bio := GetProcaddress(fSSLeayHandle, 'SSL_set_bio');
      SSL_get_peer_certificate := GetProcaddress(fSSLeayHandle, 'SSL_get_peer_certificate');
      SSL_get_error := GetProcaddress(fSSLeayHandle, 'SSL_get_error');
      SSL_shutdown := GetProcaddress(fSSLeayHandle, 'SSL_shutdown');
      SSL_free := GetProcaddress(fSSLeayHandle, 'SSL_free');
      SSL_connect := GetProcaddress(fSSLeayHandle, 'SSL_connect');
      SSL_set_connect_state := GetProcaddress(fSSLeayHandle, 'SSL_set_connect_state');
      SSL_set_accept_state := GetProcaddress(fSSLeayHandle, 'SSL_set_accept_state');
      SSL_read := GetProcaddress(fSSLeayHandle, 'SSL_read');
      SSL_write := GetProcaddress(fSSLeayHandle, 'SSL_write');
      SSL_state := GetProcaddress(fSSLeayHandle, 'SSL_state');
      SSL_pending := GetProcaddress(fSSLeayHandle, 'SSL_pending');
      SSL_set_cipher_list := GetProcaddress(fSSLeayHandle, 'SSL_set_cipher_list');
      SSL_get0_alpn_selected := GetProcaddress(fSSLeayHandle, 'SSL_get0_alpn_selected');
      SSL_clear := GetProcaddress(fSSLeayHandle, 'SSL_clear');
    end;

    if (@SSL_library_init = nil) or
    (@SSL_load_error_strings = nil) or
    (@SSLv3_method = nil) or
    (@SSLv23_method = nil) or
    (@TLSv1_method = nil) or
    (@TLSv1_1_method = nil) or
    (@SSL_CTX_new = nil) or
    (@SSL_CTX_free = nil) or
    (@SSL_CTX_set_verify = nil) or
    (@SSL_CTX_use_PrivateKey = nil) or
    (@SSL_CTX_use_RSAPrivateKey = nil) or
    (@SSL_CTX_use_certificate = nil) or
    (@SSL_CTX_check_private_key = nil) or
    (@SSL_CTX_use_certificate_file = nil) or
    (@SSL_CTX_use_RSAPrivateKey_file = nil) or
    (@SSL_CTX_get_cert_store = nil) or
    (@SSL_CTX_ctrl = nil) or
    (@SSL_CTX_load_verify_locations = nil) or
    (@SSL_CTX_use_certificate_chain_file = nil) or
    (@SSL_CTX_set_alpn_protos = nil) or
    (@SSL_new = nil) or
    (@SSL_set_bio = nil) or
    (@SSL_get_peer_certificate = nil) or
    (@SSL_get_error = nil) or
    (@SSL_shutdown = nil) or
    (@SSL_free = nil) or
    (@SSL_connect = nil) or
    (@SSL_set_connect_state = nil) or
    (@SSL_set_accept_state = nil) or
    (@SSL_read = nil) or
    (@SSL_write = nil) or
    (@SSL_state = nil) or
    (@SSL_pending = nil) or
    (@SSL_set_cipher_list = nil) or
    (@SSL_get0_alpn_selected = nil) or
    (@SSL_clear = nil) then
      Result := -1
    else
      Result := 0;
    SSLInitialize;
    //TODO - 1 -> OnBeforeCreate -> _MemBufferPool := TgoMemoryPool.Create(DEFAULT_BLOCK_SIZE);
  end;
end;

end.