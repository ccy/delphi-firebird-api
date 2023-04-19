unit firebird.client;

interface

uses
  Winapi.Windows, System.Classes, System.Generics.Collections, System.SysUtils,
  firebird.delphi, firebird.ibase.h, firebird.sqlda_pub.h, firebird.types_pub.h,
  firebird.jrd.h;

const
  FirebirdTransaction_WaitOnLocks = $0100;
  FirebirdTransaction_ReadOnly = $0200;

type
  TFBIntType = {$if CompilerVersion<=18.5}Integer{$else}NativeInt{$ifend};

  TFirebird = record
    const service_mgr = 'service_mgr';
    const DefaultDBAPassword = 'masterkey';
    const FB_Config_Providers = 'Providers';
  end;

  TFirebird_ODS_Major = (ODS_10_And_Below, ODS_11_And_Above);

  TFirebirdConf = record
  type
    TConfigType = (TYPE_BOOLEAN, TYPE_INTEGER, TYPE_STRING);
    TConfigEntry = record
      data_type: TConfigType;
      key: string;
      is_global: Boolean;
      default_value: string;  // For reference only, don't use this value
    end;
  const
    entries: array[0..72] of TConfigEntry = (
      (data_type: TYPE_INTEGER; key: 'TempBlockSize';                  is_global: true;  default_value: '1048576') // bytes
    , (data_type: TYPE_INTEGER; key: 'TempCacheLimit';                 is_global: false; default_value: '-1') // bytes
    , (data_type: TYPE_BOOLEAN; key: 'RemoteFileOpenAbility';          is_global: true;  default_value: 'false')
    , (data_type: TYPE_INTEGER; key: 'GuardianOption';                 is_global: true;  default_value: 'true')
    , (data_type: TYPE_INTEGER; key: 'CpuAffinityMask';                is_global: true;  default_value: '0')
    , (data_type: TYPE_INTEGER; key: 'TcpRemoteBufferSize';            is_global: true;  default_value: '8192')  // bytes
    , (data_type: TYPE_BOOLEAN; key: 'TcpNoNagle';                     is_global: false; default_value: 'true')
    , (data_type: TYPE_BOOLEAN; key: 'TcpLoopbackFastPath';            is_global: false; default_value: 'false')
    , (data_type: TYPE_INTEGER; key: 'DefaultDbCachePages';            is_global: false; default_value: '-1')  // pages
    , (data_type: TYPE_INTEGER; key: 'ConnectionTimeout';              is_global: false; default_value: '180')  // seconds
    , (data_type: TYPE_INTEGER; key: 'DummyPacketInterval';            is_global: false; default_value: '0')   // seconds
    , (data_type: TYPE_STRING;  key: 'DefaultTimeZone';                is_global: true;  default_value: 'nullptr')
    , (data_type: TYPE_INTEGER; key: 'LockMemSize';                    is_global: false; default_value: '1048576') // bytes
    , (data_type: TYPE_INTEGER; key: 'LockHashSlots';                  is_global: false; default_value: '8191')  // slots
    , (data_type: TYPE_INTEGER; key: 'LockAcquireSpins';               is_global: false; default_value: '0')
    , (data_type: TYPE_INTEGER; key: 'EventMemSize';                   is_global: false; default_value: '65536')  // bytes
    , (data_type: TYPE_INTEGER; key: 'DeadlockTimeout';                is_global: false; default_value: '10')  // seconds
    , (data_type: TYPE_STRING;  key: 'RemoteServiceName';              is_global: false; default_value: 'FB_SERVICE_NAME')
    , (data_type: TYPE_INTEGER; key: 'RemoteServicePort';              is_global: false; default_value: '0')
    , (data_type: TYPE_STRING;  key: 'RemotePipeName';                 is_global: false; default_value: 'FB_PIPE_NAME')
    , (data_type: TYPE_STRING;  key: 'IpcName';                        is_global: false; default_value: 'FB_IPC_NAME')
    , (data_type: TYPE_INTEGER; key: 'MaxUnflushedWrites';             is_global: false; default_value: '100')
    , (data_type: TYPE_INTEGER; key: 'MaxUnflushedWriteTime';          is_global: false; default_value: '5')
    , (data_type: TYPE_INTEGER; key: 'ProcessPriorityLevel';           is_global: true;  default_value: '0')
    , (data_type: TYPE_INTEGER; key: 'RemoteAuxPort';                  is_global: false; default_value: ' 0')
    , (data_type: TYPE_STRING;  key: 'RemoteBindAddress';              is_global: true;  default_value: '0')
    , (data_type: TYPE_STRING;  key: 'ExternalFileAccess';             is_global: false; default_value: 'None') // locations of external files for tables
    , (data_type: TYPE_STRING;  key: 'DatabaseAccess';                 is_global: true;  default_value: 'Full') // locations of databases
    , (data_type: TYPE_STRING;  key: 'UdfAccess';                      is_global: true;  default_value: 'None') // locations of UDFs
    , (data_type: TYPE_STRING;  key: 'TempDirectories';                is_global: true;  default_value: '0')
    , (data_type: TYPE_BOOLEAN; key: 'BugcheckAbort';                  is_global: true;  default_value: 'true') // whether to abort engine when internal error is found
    , (data_type: TYPE_INTEGER; key: 'TraceDSQL';                      is_global: true;  default_value: '0')   // bitmask
    , (data_type: TYPE_BOOLEAN; key: 'LegacyHash';                     is_global: true;  default_value: 'true')  // let use old passwd hash verification
    , (data_type: TYPE_STRING;  key: 'GCPolicy';                       is_global: false; default_value: 'nullptr') // garbage collection policy
    , (data_type: TYPE_BOOLEAN; key: 'Redirection';                    is_global: true;  default_value: 'false')
    , (data_type: TYPE_INTEGER; key: 'DatabaseGrowthIncrement';        is_global: false; default_value: '128 * 1048576') // bytes
    , (data_type: TYPE_INTEGER; key: 'FileSystemCacheThreshold';       is_global: false; default_value: '65536')  // page buffers
    , (data_type: TYPE_BOOLEAN; key: 'RelaxedAliasChecking';           is_global: true;  default_value: 'false')  // if true relax strict alias checking rules in DSQL a bit
    , (data_type: TYPE_STRING;  key: 'AuditTraceConfigFile';           is_global: true;  default_value: '')  // location of audit trace configuration file
    , (data_type: TYPE_INTEGER; key: 'MaxUserTraceLogSize';            is_global: true;  default_value: '10')  // maximum size of user session trace log
    , (data_type: TYPE_INTEGER; key: 'FileSystemCacheSize';            is_global: true;  default_value: '0')   // percent
    , (data_type: TYPE_STRING;  key: 'Providers';                      is_global: false; default_value: '"Remote, " CURRENT_ENGINE ", Loopback"')
    , (data_type: TYPE_STRING;  key: 'AuthServer';                     is_global: false; default_value: 'Srp256"')
    , (data_type: TYPE_STRING;  key: 'AuthClient';                     is_global: false; default_value: 'Srp256, Srp, Win_Sspi, Legacy_Auth"')
    , (data_type: TYPE_STRING;  key: 'UserManager';                    is_global: false; default_value: 'Srp"')
    , (data_type: TYPE_STRING;  key: 'TracePlugin';                    is_global: false; default_value: 'fbtrace"')
    , (data_type: TYPE_STRING;  key: 'SecurityDatabase';               is_global: false; default_value: 'nullptr') // sec/db alias - rely on ConfigManager::getDefaultSecurityDb(
    , (data_type: TYPE_STRING;  key: 'ServerMode';                     is_global: true;  default_value: 'nullptr') // actual value differs in boot/regular cases and set at setupDefaultConfig(
    , (data_type: TYPE_STRING;  key: 'WireCrypt';                      is_global: false; default_value: 'nullptr')
    , (data_type: TYPE_STRING;  key: 'WireCryptPlugin';                is_global: false; default_value: 'ChaCha64, ChaCha, Arc4"')
    , (data_type: TYPE_STRING;  key: 'KeyHolderPlugin';                is_global: false; default_value: '')
    , (data_type: TYPE_BOOLEAN; key: 'RemoteAccess';                   is_global: false; default_value: 'true')
    , (data_type: TYPE_BOOLEAN; key: 'IPv6V6Only';                     is_global: false; default_value: 'false')
    , (data_type: TYPE_BOOLEAN; key: 'WireCompression';                is_global: false; default_value: 'false')
    , (data_type: TYPE_INTEGER; key: 'MaxIdentifierByteLength';        is_global: false; default_value: '(int)MAX_SQL_IDENTIFIER_LEN')
    , (data_type: TYPE_INTEGER; key: 'MaxIdentifierCharLength';        is_global: false; default_value: '(int)METADATA_IDENTIFIER_CHAR_LEN')
    , (data_type: TYPE_BOOLEAN; key: 'AllowEncryptedSecurityDatabase'; is_global: false; default_value: 'false')
    , (data_type: TYPE_INTEGER; key: 'StatementTimeout';               is_global: false; default_value: '0')
    , (data_type: TYPE_INTEGER; key: 'ConnectionIdleTimeout';          is_global: false; default_value: '0')
    , (data_type: TYPE_INTEGER; key: 'OnDisconnectTriggerTimeout';     is_global: false; default_value: '180')
    , (data_type: TYPE_INTEGER; key: 'ClientBatchBuffer';              is_global: false; default_value: '128 * 1024')
    , (data_type: TYPE_STRING;  key: 'OutputRedirectionFile';          is_global: true;  default_value: '-"')
    , (data_type: TYPE_INTEGER; key: 'ExtConnPoolSize';                is_global: true;  default_value: '0')
    , (data_type: TYPE_INTEGER; key: 'ExtConnPoolLifeTime';            is_global: true;  default_value: '7200')
    , (data_type: TYPE_INTEGER; key: 'SnapshotsMemSize';               is_global: false; default_value: '65536')  // bytes
    , (data_type: TYPE_INTEGER; key: 'TipCacheBlockSize';              is_global: false; default_value: '4194304') // bytes
    , (data_type: TYPE_BOOLEAN; key: 'ReadConsistency';                is_global: false; default_value: 'true')
    , (data_type: TYPE_BOOLEAN; key: 'ClearGTTAtRetaining';            is_global: false; default_value: 'false')
    , (data_type: TYPE_STRING;  key: 'DataTypeCompatibility';          is_global: false; default_value: 'nullptr')
    , (data_type: TYPE_BOOLEAN; key: 'UseFileSystemCache';             is_global: false; default_value: 'true')
    , (data_type: TYPE_INTEGER; key: 'InlineSortThreshold';            is_global: false; default_value: '1000')  // bytes
    , (data_type: TYPE_STRING;  key: 'TempTableDirectory';             is_global: false; default_value: '')
    , (data_type: TYPE_BOOLEAN; key: 'UseLegacyKernelObjectsNames';    is_global: true;  default_value: 'false')
    );
  end;

type
  TFirebirdPB = record
  strict private
    FParams: TBytes;
    function IncSize(const aIncSize: Integer): TFirebirdPB;
  public
    function AddByte(const B: Byte): TFirebirdPB;
    function AddLongint(const B: LongInt): TFirebirdPB;
    function AddShortString(const aValue: string): TFirebirdPB;
    function AddSmallInt(const B: SmallInt): TFirebirdPB;
    function AddString(const aValue: string): TFirebirdPB;
    class function GetDPB(const aUser, aPassword: string): TFirebirdPB;
        static;
    function GetLength: Integer;
    function Init(const aParams: array of byte): TFirebirdPB;
    class operator Implicit(const A: TFirebirdPB): Pointer;
  end;

  {$region 'Firebird Library: Debugger'}
  IFirebirdLibraryDebuggerListener = interface(IInterface)
  ['{5E724646-C4F6-499E-9C04-38AA81425B47}']
    procedure Update(const aDebugStr: string);
  end;

  IFirebirdLibraryDebugger = interface(IInterface)
  ['{F9E55F0A-3843-44B3-AA64-5D2EC8211B94}']
    function HasListener: Boolean;
    procedure Notify(const aDebugStr: string);
    procedure SetListener(const aListener: IFirebirdLibraryDebuggerListener);
  end;

  IFirebirdLibraryDebugFactory = interface(IInterface)
  ['{2FDB8E26-BA3D-4091-A1B1-176DBA686A7B}']
    function Get(const aProcName: string; const aProc: pointer; const aParams:
        array of const; const aResult: longInt): string;
  end;

  TFirebirdLibraryDebugger = class(TInterfacedObject, IFirebirdLibraryDebugger)
  private
    FListener: IFirebirdLibraryDebuggerListener;
  protected
    function HasListener: Boolean;
    procedure Notify(const aDebugStr: string);
    procedure SetListener(const aListener: IFirebirdLibraryDebuggerListener);
  end;
  {$endregion}

  IFirebirdLibrary_DLL = interface(IInterface)
    function fb_shutdown(timeout: Cardinal = 20000; const reason: Integer = 0):
        Integer; stdcall;
    function isc_attach_database(status_vector: PISC_STATUS_ARRAY; file_length: SmallInt;
        file_name: PISC_SCHAR; public_handle: pisc_db_handle; dpb_length: SmallInt;
        dpb: PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_blob_info(status_vector: PISC_STATUS_ARRAY; isc_blob_handle:
        pisc_blob_handle; item_length: SmallInt; items: PISC_SCHAR; buffer_length:
        SmallInt; buffer: PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_create_database(status_vector: PISC_STATUS_ARRAY; fileLength:
        Word; filename: PISC_SCHAR; publicHandle: pisc_db_handle; dpbLength: Word;
        dpb: PISC_SCHAR; db_type: Word): Integer; stdcall;
    function isc_close_blob(status_vector: PISC_STATUS_ARRAY; blob_handle:
        pisc_blob_handle): ISC_STATUS; stdcall;
    function isc_commit_transaction(status_vector: PISC_STATUS_ARRAY; tra_handle:
        pisc_tr_handle): ISC_STATUS; stdcall;
    function isc_create_blob(status_vector: PISC_STATUS_ARRAY; db_handle: pisc_db_handle;
        tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle; blob_id:
        PISC_QUAD): ISC_STATUS; stdcall;
    function isc_create_blob2(status_vector: PISC_STATUS_ARRAY; db_handle: pisc_db_handle;
        tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle; blob_id:
        PISC_QUAD; bpb_length: SmallInt; bpb: PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_database_info(status_vector: PISC_STATUS_ARRAY; db_handle: pisc_db_handle;
        info_len: SmallInt; info: PISC_SCHAR; res_len: SmallInt; res: PISC_SCHAR):
        ISC_STATUS; stdcall;
    procedure isc_decode_sql_date(date: PISC_DATE; times_arg: pointer); stdcall;
    procedure isc_decode_sql_time(sql_time: PISC_TIME; times_args: pointer); stdcall;
    procedure isc_decode_timestamp(date: PISC_TIMESTAMP; times_arg: pointer); stdcall;
    function isc_detach_database(status_vector: PISC_STATUS_ARRAY; public_handle:
        pisc_db_handle): ISC_STATUS; stdcall;
    function isc_drop_database(status_vector: PISC_STATUS_ARRAY; db_handle:
        pisc_db_handle): ISC_STATUS; stdcall;
    function isc_dsql_allocate_statement(status_vector: PISC_STATUS_ARRAY; db_handle:
        pisc_db_handle; stmt_handle: pisc_stmt_handle): ISC_STATUS; stdcall;
    function isc_dsql_alloc_statement2(status_vector: PISC_STATUS_ARRAY; db_handle:
        pisc_db_handle; stmt_handle: pisc_stmt_handle): ISC_STATUS; stdcall;
    function isc_dsql_describe(status_vector: PISC_STATUS_ARRAY; stmt_handle:
        pisc_stmt_handle; dialect: Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_describe_bind(status_vector: PISC_STATUS_ARRAY; stmt_handle:
        pisc_stmt_handle; dialect: Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_execute(status_vector: PISC_STATUS_ARRAY; tra_handle: pisc_tr_handle;
        stmt_handle: pisc_stmt_handle; dialect: Word; sqlda: PXSQLDA): ISC_STATUS;
        stdcall;
    function isc_dsql_execute2(status_vector: PISC_STATUS_ARRAY; tra_handle:
        pisc_tr_handle; stmt_handle: pisc_stmt_handle; dialect: Word; in_sqlda:
        PXSQLDA; out_sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_execute_immediate(status_vector: PISC_STATUS_ARRAY; db_handle:
        pisc_db_handle; tra_handle: pisc_tr_handle; length: Word; statement:
        PISC_SCHAR; dialect: Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_fetch(status_vector: PISC_STATUS_ARRAY; stmt_handle:
        pisc_stmt_handle; da_version: Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_free_statement(status_vector: PISC_STATUS_ARRAY; stmt_handle:
        pisc_stmt_handle; option: Word): ISC_STATUS; stdcall;
    function isc_dsql_prepare(status_vector: PISC_STATUS_ARRAY; tra_handle: pisc_tr_handle;
        stmt_handle: pisc_stmt_handle; length: Word; str: PISC_SCHAR; dialect:
        Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_set_cursor_name(status_vector: PISC_STATUS_ARRAY; stmt_handle:
        pisc_stmt_handle; cursor_name: PISC_SCHAR; reserve: Word): ISC_STATUS;
        stdcall;
    function isc_dsql_sql_info(status_vector: PISC_STATUS_ARRAY; stmt_handle:
        pisc_stmt_handle; items_len: SmallInt; items: PISC_SCHAR; buffer_len:
        SmallInt; buffer: PISC_SCHAR): ISC_STATUS; stdcall;
    procedure isc_encode_sql_date(times_arg: pointer; date: PISC_DATE); stdcall;
    procedure isc_encode_sql_time(times_arg: pointer; isc_time: PISC_TIME); stdcall;
    procedure isc_encode_timestamp(times_arg: pointer; isc_time: PISC_TIMESTAMP); stdcall;
    function isc_get_segment(status_vector: PISC_STATUS_ARRAY; blob_handle:
        pisc_blob_handle; length: System.pWord; buffer_length: Word; buffer: PISC_SCHAR):
        ISC_STATUS; stdcall;
    function isc_interprete(buffer: PISC_SCHAR; status_vector: PPISC_STATUS_ARRAY):
        ISC_STATUS; stdcall;
    function isc_open_blob(status_vector: PISC_STATUS_ARRAY; db_handle: pisc_db_handle;
        tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle; blob_id:
        PISC_QUAD): ISC_STATUS; stdcall;
    function isc_open_blob2(status_vector: PISC_STATUS_ARRAY; db_handle: pisc_db_handle;
        tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle; blob_id:
        PISC_QUAD; bpb_length: ISC_USHORT; bpb: PISC_UCHAR): ISC_STATUS; stdcall;
    function isc_put_segment(status_vector: PISC_STATUS_ARRAY; blob_handle:
        pisc_blob_handle; buffer_length: Word; buffer: PISC_SCHAR): ISC_STATUS;
        stdcall;
    function isc_rollback_transaction(status_vector: PISC_STATUS_ARRAY; tra_handle:
        pisc_tr_handle): ISC_STATUS; stdcall;
    function isc_service_attach(status_vector: PISC_STATUS_ARRAY; service_length: Word;
        service: PISC_SCHAR; svc_handle: pisc_svc_handle; spb_length: Word; spb:
        PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_service_detach(status_vector: PISC_STATUS_ARRAY; svc_handle:
        pisc_svc_handle): ISC_STATUS; stdcall;
    function isc_service_query(status_vector: PISC_STATUS_ARRAY; svc_handle:
        pisc_svc_handle; reserved: pisc_resv_handle; send_spb_length: Word;
        send_spb: PISC_SCHAR; request_spb_length:Word; request_spb: PISC_SCHAR;
        buffer_length: Word; buffer: PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_service_start(status_vector: PISC_STATUS_ARRAY; svc_handle:
        pisc_svc_handle; reserved: pisc_resv_handle; spb_length: Word; spb:
        PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_sqlcode(status_vector: PISC_STATUS_ARRAY): ISC_LONG; stdcall;
    function isc_start_multiple(status_vector: PISC_STATUS_ARRAY; tra_handle:
        pisc_tr_handle; count: SmallInt; vec: pointer): ISC_STATUS; stdcall;
    function isc_vax_integer(buffer: PISC_SCHAR; len: SmallInt): ISC_LONG; stdcall;
  end;

  IFirebirdLibrary = interface(IFirebirdLibrary_DLL)
    ['{90A53F8C-2F1A-437C-A3CF-97D15D35E1C5}']
    function GetODS: Cardinal;
    function GetODS_Major: TFirebird_ODS_Major;
    function GetTimeZoneOffset: TGetTimeZoneOffSet;
    function Loaded: Boolean;
    procedure SetupTimeZoneHandler(aHandler: TSetupTimeZoneHandler);
  end;

  TFirebirdLibrary = class(TInterfacedObject, IFirebirdLibrary)
  strict private
    FDebugFactory: IFirebirdLibraryDebugFactory;
    FDebugger: IFirebirdLibraryDebugger;
    FProcs: TDictionary<Pointer,string>;
    FServerCharSet: string;
    FEncoding: TEncoding;
    FOldVars: IInterface;
    function GetDebugFactory: IFirebirdLibraryDebugFactory;
    function GetProc(const aHandle: THandle; const aProcName: PChar; const
        aRequired: Boolean = True): pointer;
    procedure DebugMsg(const aProc: pointer; const aParams: array of const;
        aResult: ISC_STATUS);
  private
    Ffb_shutdown: Tfb_shutdown;
    Fisc_attach_database: Tisc_attach_database;
    Fisc_blob_info: Tisc_blob_info;
    Fisc_close_blob: Tisc_close_blob;
    Fisc_commit_transaction: Tisc_commit_transaction;
    Fisc_create_blob: Tisc_create_blob;
    Fisc_create_blob2: Tisc_create_blob2;
    Fisc_create_database: Tisc_create_database;
    Fisc_database_info: Tisc_database_info;
    Fisc_decode_sql_date: Tisc_decode_sql_date;
    Fisc_decode_sql_time: Tisc_decode_sql_time;
    Fisc_decode_timestamp: Tisc_decode_timestamp;
    Fisc_detach_database: Tisc_detach_database;
    Fisc_drop_database: Tisc_drop_database;
    Fisc_dsql_allocate_statement: Tisc_dsql_allocate_statement;
    Fisc_dsql_alloc_statement2: Tisc_dsql_alloc_statement2;
    Fisc_dsql_describe: Tisc_dsql_describe;
    Fisc_dsql_describe_bind: Tisc_dsql_describe_bind;
    Fisc_dsql_execute: Tisc_dsql_execute;
    Fisc_dsql_execute2: Tisc_dsql_execute2;
    Fisc_dsql_execute_immediate: Tisc_dsql_execute_immediate;
    Fisc_dsql_fetch: Tisc_dsql_fetch;
    Fisc_dsql_free_statement: Tisc_dsql_free_statement;
    Fisc_dsql_prepare: Tisc_dsql_prepare;
    Fisc_dsql_set_cursor_name: Tisc_dsql_set_cursor_name;
    Fisc_dsql_sql_info: Tisc_dsql_sql_info;
    Fisc_encode_sql_date: Tisc_encode_sql_date;
    Fisc_encode_sql_time: Tisc_encode_sql_time;
    Fisc_encode_timestamp: Tisc_encode_timestamp;
    Fisc_get_segment: Tisc_get_segment;
    Fisc_interprete: Tisc_interprete;
    Fisc_open_blob: Tisc_open_blob;
    Fisc_open_blob2: Tisc_open_blob2;
    Fisc_put_segment: Tisc_put_segment;
    Fisc_rollback_transaction: Tisc_rollback_transaction;
    Fisc_service_attach: Tisc_service_attach;
    Fisc_service_detach: Tisc_service_detach;
    Fisc_service_query: Tisc_service_query;
    Fisc_service_start: Tisc_service_start;
    Fisc_sqlcode: Tisc_sqlcode;
    Fisc_start_multiple: Tisc_start_multiple;
    Fisc_vax_integer: Tisc_vax_integer;
  protected  // IFirebirdLibrary_DLL
    function fb_shutdown(timeout: Cardinal = 20000; const reason: Integer = 0):
        Integer; stdcall;
    function isc_attach_database(status_vector: PISC_STATUS_ARRAY; file_length: SmallInt;
        file_name: PISC_SCHAR; public_handle: pisc_db_handle; dpb_length: SmallInt;
        dpb: PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_blob_info(status_vector: PISC_STATUS_ARRAY; isc_blob_handle:
        pisc_blob_handle; item_length: SmallInt; items: PISC_SCHAR; buffer_length:
        SmallInt; buffer: PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_close_blob(status_vector: PISC_STATUS_ARRAY; blob_handle:
        pisc_blob_handle): ISC_STATUS; stdcall;
    function isc_commit_transaction(status_vector: PISC_STATUS_ARRAY; tra_handle:
        pisc_tr_handle): ISC_STATUS; stdcall;
    function isc_create_blob(status_vector: PISC_STATUS_ARRAY; db_handle: pisc_db_handle;
        tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle; blob_id:
        PISC_QUAD): ISC_STATUS; stdcall;
    function isc_create_blob2(status_vector: PISC_STATUS_ARRAY; db_handle:
        pisc_db_handle; tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle;
        blob_id: PISC_QUAD; bpb_length: SmallInt; bpb: PISC_SCHAR): ISC_STATUS;
        stdcall;
    function isc_create_database(status_vector: PISC_STATUS_ARRAY; fileLength:
        Word; filename: PISC_SCHAR; publicHandle: pisc_db_handle; dpbLength: Word;
        dpb: PISC_SCHAR; db_type: Word): Integer; stdcall;
    function isc_database_info(status_vector: PISC_STATUS_ARRAY; db_handle:
        pisc_db_handle; info_len: SmallInt; info: PISC_SCHAR; res_len: SmallInt;
        res: PISC_SCHAR): ISC_STATUS; stdcall;
    procedure isc_decode_sql_date(date: PISC_DATE; times_arg: pointer); stdcall;
    procedure isc_decode_sql_time(sql_time: PISC_TIME; times_args: pointer); stdcall;
    procedure isc_decode_timestamp(date: PISC_TIMESTAMP; times_arg: pointer); stdcall;
    function isc_detach_database(status_vector: PISC_STATUS_ARRAY; public_handle:
        pisc_db_handle): ISC_STATUS; stdcall;
    function isc_drop_database(status_vector: PISC_STATUS_ARRAY; db_handle:
        pisc_db_handle): ISC_STATUS; stdcall;
    function isc_dsql_allocate_statement(status_vector: PISC_STATUS_ARRAY; db_handle:
        pisc_db_handle; stmt_handle: pisc_stmt_handle): ISC_STATUS; stdcall;
    function isc_dsql_alloc_statement2(status_vector: PISC_STATUS_ARRAY; db_handle:
        pisc_db_handle; stmt_handle: pisc_stmt_handle): ISC_STATUS; stdcall;
    function isc_dsql_describe(status_vector: PISC_STATUS_ARRAY; stmt_handle:
        pisc_stmt_handle; dialect: Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_describe_bind(status_vector: PISC_STATUS_ARRAY; stmt_handle:
        pisc_stmt_handle; dialect: Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_execute(status_vector: PISC_STATUS_ARRAY; tra_handle:
        pisc_tr_handle; stmt_handle: pisc_stmt_handle; dialect: Word; sqlda:
        PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_execute2(status_vector: PISC_STATUS_ARRAY; tra_handle:
        pisc_tr_handle; stmt_handle: pisc_stmt_handle; dialect: Word; in_sqlda:
        PXSQLDA; out_sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_execute_immediate(status_vector: PISC_STATUS_ARRAY; db_handle:
        pisc_db_handle; tra_handle: pisc_tr_handle; length: Word; statement:
        PISC_SCHAR; dialect: Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_fetch(status_vector: PISC_STATUS_ARRAY; stmt_handle:
        pisc_stmt_handle; da_version: Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_free_statement(status_vector: PISC_STATUS_ARRAY; stmt_handle:
        pisc_stmt_handle; option: Word): ISC_STATUS; stdcall;
    function isc_dsql_prepare(status_vector: PISC_STATUS_ARRAY; tra_handle:
        pisc_tr_handle; stmt_handle: pisc_stmt_handle; length: Word; str:
        PISC_SCHAR; dialect: Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_set_cursor_name(status_vector: PISC_STATUS_ARRAY; stmt_handle:
        pisc_stmt_handle; cursor_name: PISC_SCHAR; reserve: Word): ISC_STATUS;
        stdcall;
    function isc_dsql_sql_info(status_vector: PISC_STATUS_ARRAY; stmt_handle:
        pisc_stmt_handle; items_len: SmallInt; items: PISC_SCHAR; buffer_len:
        SmallInt; buffer: PISC_SCHAR): ISC_STATUS; stdcall;
    procedure isc_encode_sql_date(times_arg: pointer; date: PISC_DATE); stdcall;
    procedure isc_encode_sql_time(times_arg: pointer; isc_time: PISC_TIME); stdcall;
    procedure isc_encode_timestamp(times_arg: pointer; isc_time: PISC_TIMESTAMP); stdcall;
    function isc_get_segment(status_vector: PISC_STATUS_ARRAY; blob_handle:
        pisc_blob_handle; length: System.pWord; buffer_length: Word; buffer: PISC_SCHAR):
        ISC_STATUS; stdcall;
    function isc_interprete(buffer: PISC_SCHAR; status_vector: PPISC_STATUS_ARRAY):
        ISC_STATUS; stdcall;
    function isc_open_blob(status_vector: PISC_STATUS_ARRAY; db_handle: pisc_db_handle;
        tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle; blob_id:
        PISC_QUAD): ISC_STATUS; stdcall;
    function isc_open_blob2(status_vector: PISC_STATUS_ARRAY; db_handle: pisc_db_handle;
        tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle; blob_id:
        PISC_QUAD; bpb_length: ISC_USHORT; bpb: PISC_UCHAR): ISC_STATUS; stdcall;
    function isc_put_segment(status_vector: PISC_STATUS_ARRAY; blob_handle:
        pisc_blob_handle; buffer_length: Word; buffer: PISC_SCHAR): ISC_STATUS;
        stdcall;
    function isc_rollback_transaction(status_vector: PISC_STATUS_ARRAY; tra_handle:
        pisc_tr_handle): ISC_STATUS; stdcall;
    function isc_service_attach(status_vector: PISC_STATUS_ARRAY; service_length: Word;
        service: PISC_SCHAR; svc_handle: pisc_svc_handle; spb_length: Word; spb:
        PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_service_detach(status_vector: PISC_STATUS_ARRAY; svc_handle:
        pisc_svc_handle): ISC_STATUS; stdcall;
    function isc_service_query(status_vector: PISC_STATUS_ARRAY; svc_handle:
        pisc_svc_handle; reserved: pisc_resv_handle; send_spb_length: Word;
        send_spb: PISC_SCHAR; request_spb_length:Word; request_spb: PISC_SCHAR;
        buffer_length: Word; buffer: PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_service_start(status_vector: PISC_STATUS_ARRAY; svc_handle:
        pisc_svc_handle; reserved: pisc_resv_handle; spb_length: Word; spb:
        PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_sqlcode(status_vector: PISC_STATUS_ARRAY): ISC_LONG; stdcall;
    function isc_start_multiple(status_vector: PISC_STATUS_ARRAY; tra_handle:
        pisc_tr_handle; count: SmallInt; vec: pointer): ISC_STATUS; stdcall;
    function isc_vax_integer(buffer: PISC_SCHAR; len: SmallInt): ISC_LONG; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
  protected // IFirebirdLibrary
    FHandle: THandle;
    FODS: Cardinal;
    function GetODS: Cardinal;
    function GetODS_Major: TFirebird_ODS_Major;
    function GetTimeZoneOffset: TGetTimeZoneOffSet;
    function Loaded: Boolean;
    procedure SetupTimeZoneHandler(aHandler: TSetupTimeZoneHandler);
    procedure SetupProcs;
  strict private
    FTimeZones: TDictionary<Word, TTimeZoneOffset>;
    FSetupTimeZoneHandler: TSetupTimeZoneHandler;
    constructor Create(aLibrary, aServerCharSet: string);
    function DoGetTimeZoneOffset(aFBTimeZoneID: Word): TTimeZoneOffset;
  public
    class function New(aLibrary: string; aServerCharSet: string = 'NONE'):
        IFirebirdLibrary;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

  IFirebirdError = interface(IInterface)
  ['{5D89C7AC-544B-4170-AF0F-79AD05265BC5}']
    procedure GetMessage(const aMsg: PWideChar); overload;
    function GetMessage: string; overload;
    function GetLength: Smallint;
  end;

  TFirebirdError = class(TInterfacedObject, IFirebirdError)
  private
    FMessage: string;
  protected
    procedure GetMessage(const aMsg: PWideChar); overload;
    function GetMessage: string; overload;
    function GetLength: Smallint;
  public
    constructor Create(const aErrorMessage: string);
  end;

  IStatusVector = interface(IInterface)
  ['{A51BBF0A-0565-4397-AFBE-ED0DD7BAF3BC}']
    procedure CheckAndRaiseError(const aFirebirdClient: IFirebirdLibrary);
    function CheckError(const aFirebirdClient: IFirebirdLibrary; out aErrorCode:
        TFBIntType): boolean;
    function CheckFirebirdError(out aErrorCode: TFBIntType): boolean;
    function CheckResult(out aResult: word; const aFailed_Result: word): Boolean; overload;
    function CheckResult(out aResult: longint; const aFailed_Result: longint):
        Boolean; overload;
    function GetError(const aFirebirdClient: IFirebirdLibrary): IFirebirdError;
    function GetLastError: IFirebirdError;
    function GetpValue: PISC_STATUS_ARRAY;
    function HasError: boolean;
    function Success: boolean;
    property pValue: PISC_STATUS_ARRAY read GetpValue;
  end;

  TStatusVector = class(TInterfacedObject, IStatusVector)
  private
    FError: IFirebirdError;
    FStatusVector: ISC_STATUS_ARRAY;
  protected
    procedure CheckAndRaiseError(const aFirebirdClient: IFirebirdLibrary);
    function CheckError(const aFirebirdClient: IFirebirdLibrary; out aErrorCode:
        TFBIntType): boolean;
    function CheckFirebirdError(out aErrorCode: TFBIntType): boolean;
    function CheckResult(out aResult: word; const aFailed_Result: word): Boolean; overload;
    function CheckResult(out aResult: longint; const aFailed_Result: longint):
        Boolean; overload;
    function GetError(const aFirebirdClient: IFirebirdLibrary): IFirebirdError;
    function GetLastError: IFirebirdError;
    function GetpValue: PISC_STATUS_ARRAY;
    function HasError: boolean;
    function Success: boolean;
  end;

  ETransactionExist = Exception;

  TTransactionIsolation = (isoReadCommitted, isoRepeatableRead);

  TTransactionInfo = record
    ID: LongWord;
    Isolation: TTransactionIsolation;
    WaitOnLocks: Boolean;
    WaitOnLocksTimeOut: Integer;
    ReadOnly: Boolean;
    procedure Init(aIsolation: TTransactionIsolation = isoReadCommitted;
        aWaitOnLocks: Boolean = False; aWaitOnLocksTimeOut: Integer = -1;
        aReadOnly: Boolean = False);
  end;

  TFirebirdTransaction = class(TObject)
  private
    FClient: IFirebirdLibrary;
    FTransactionHandle: isc_tr_handle;
    FTransParam: isc_teb;
    FTransInfo: TTransactionInfo;
    Fisc_tec: TArray<ISC_UCHAR>;
  protected
    function Active: boolean;
    function GetID: LongWord;
  public
    constructor Create(const aFirebirdClient: IFirebirdLibrary; const aDBHandle:
        pisc_db_handle; const aTransInfo: TTransactionInfo);
    function Commit(const aStatusVector: IStatusVector): ISC_STATUS;
    function Rollback(const aStatusVector: IStatusVector): ISC_STATUS;
    function Start(aStatusVector: IStatusVector): ISC_STATUS;
    function TransactionHandle: pisc_tr_handle;
  end;

  TFirebirdTransactionPool = class(TObject)
  private
    FDBHandle: pisc_db_handle;
    FFirebirdClient: IFirebirdLibrary;
    FItems: TObjectList<TFirebirdTransaction>;
    FDefaultTransactionInfo: TTransactionInfo;
  public
    constructor Create(const aFirebirdClient: IFirebirdLibrary; const aDBHandle:
        pisc_db_handle; const aDefaultTransactionInfo: TTransactionInfo);
    function Add: TFirebirdTransaction; overload;
    function Add(const aTransInfo: TTransactionInfo): TFirebirdTransaction;
        overload;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    function Commit(const aStatusVector: IStatusVector; const aTransaction:
        TFirebirdTransaction): ISC_STATUS;
    function CurrentTransaction: TFirebirdTransaction;
    function RollBack(const aStatusVector: IStatusVector; const aTransaction:
        TFirebirdTransaction): ISC_STATUS;
  end;

  TFirebirdLibraryRootPath = class(TInterfacedObject)
  strict private
    FOldVars: TStringList;
  private
    procedure AddVar(const aVarName: string);
    procedure SetVars(const aVars: TStringList);
  public
    constructor Create(const aRootPath: string);
    constructor CreateFromLibrary(const aLibrary: string; const Dummy: Integer = 0);
    procedure BeforeDestruction; override;
  end;

  TFirebirdSQLParser = class
  private
    FScript: string;
    ci: integer; // CharacterIndex
    FTerm: char;
    FCommands: TStrings;
    procedure SetScript(const Value: string);
    function StripLines(s: string): string;
    function CheckTERM(cmd: string): boolean;
    function IsConsoleCommand(cmd: string): boolean;
    function NextCommand:string;
    function EOS: boolean; // EndOfScript;
    procedure Parse;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(AFileName: string);
    property Script: string read FScript write SetScript;
    property Commands: TStrings read FCommands;
    property Term: char read FTerm write FTerm default ';';
  end;

  TFirebirdEngine = record
  strict private
    FFileName: string;
    FMajor: Cardinal;
    FMinor: Cardinal;
    FBuild: Cardinal;
  private
    function GetEncodedODS: UInt16;
    function GetVersion: string;
  public
    class function Loopback: TFirebirdEngine; static;
    class function Remote: TFirebirdEngine; static;
    class operator Implicit(Value: string): TFirebirdEngine;
    class operator Implicit(Value: TFirebirdEngine): string;
    function SupportedPageSizes: TArray<Integer>;
    property FileName: string read FFileName;
    property Major: Cardinal read FMajor;
    property Minor: Cardinal read FMinor;
    property Build: Cardinal read FBuild;
    property EncodedODS: UInt16 read GetEncodedODS;
    property Version: string read GetVersion;
  end;

  TFirebirdEngines = record
  type
    TEngines = TArray<TFirebirdEngine>;

    TEnumerator = record
    type
      TGetCurrent = TFunc<Integer, TFirebirdEngine>;
    strict private
      FCount: Integer;
      FCurrent: Integer;
      FGetCurrent: TGetCurrent;
    public
      constructor Create(const Engines: TFirebirdEngines);
      function GetCurrent: TFirebirdEngine;
      function MoveNext: Boolean;
      property Current: TFirebirdEngine read GetCurrent;
    end;

  strict private
    FEngines: TEngines;
    function Get(aIndex: Integer): TFirebirdEngine;
  public
    constructor Create(aRoot_Or_fbclient: string);
    function Count: Integer;
    function GetEnumerator: TEnumerator;
    function GetProviders: string; overload; inline;
    class function GetProviders(aRoot_Or_fbclient: string): string; overload;
        static; inline;
    function GetProviders(aEngines: array of TFirebirdEngine): string; overload;
    property Items[Index: Integer]: TFirebirdEngine read Get; default;
  end;

function ExpandFileNameString(const aFileName: string): string;

implementation

uses
  System.AnsiStrings, System.Generics.Defaults, System.IOUtils, System.Math,
  firebird.client.debug, firebird.consts_pub.h, firebird.inf_pub.h,
  firebird.ods.h;

function ExpandFileNameString(const aFileName: string): string;
var P: PChar;
    i: integer;
begin
  i := ExpandEnvironmentStrings(PChar(aFileName), nil, 0);
  P := StrAlloc(i);
  try
    ExpandEnvironmentStrings(PChar(aFileName), P, i);
    Result := StrPas(P);
  finally
    StrDispose(P);
  end;
end;

procedure TFirebirdLibrary.AfterConstruction;
begin
  inherited;
  FODS := ODS_CURRENT_VERSION;
end;

procedure TFirebirdLibrary.BeforeDestruction;
begin
  inherited;
  FProcs.Free;
  FreeAndNil(FTimeZones);
end;

constructor TFirebirdLibrary.Create(aLibrary, aServerCharSet: string);
begin
  inherited Create;

  FProcs := TDictionary<Pointer,string>.Create;
  FDebugger := TFirebirdLibraryDebugger.Create;
  FTimeZones := nil;

  FServerCharSet := aServerCharSet;
  if SameText(FServerCharSet, 'UTF8') then
    FEncoding := TEncoding.UTF8
  else
    FEncoding := TEncoding.Default;

  var sPath := TPath.GetDirectoryName(aLibrary);
  FOldVars := TFirebirdLibraryRootPath.Create(sPath);

  SetDllDirectory(PChar(sPath));
  FHandle := LoadLibrary(PChar(aLibrary));

  if FHandle <> 0 then SetupProcs;
end;

function TFirebirdLibrary.GetDebugFactory: IFirebirdLibraryDebugFactory;
begin
  if FDebugFactory = nil then
    FDebugFactory := TFirebirdClientDebugFactory.Create(Self as IFirebirdLibrary, FEncoding);
  Result := FDebugFactory;
end;

function TFirebirdLibrary.GetProc(const aHandle: THandle; const aProcName:
    PChar; const aRequired: Boolean = True): pointer;
begin
  Result := GetProcAddress(aHandle, aProcName);
  if Result <> nil then
    FProcs.Add(Result, aProcName)
  else if aRequired then
    RaiseLastOSError;
end;

function TFirebirdLibrary.GetTimeZoneOffset: TGetTimeZoneOffSet;
begin
  Result := DoGetTimeZoneOffset;
end;

function TFirebirdLibrary.GetODS: Cardinal;
begin
  Result := FODS;
end;

function TFirebirdLibrary.GetODS_Major: TFirebird_ODS_Major;
begin
  if DECODE_ODS_MAJOR(FODS) <= ODS_VERSION10 then
    Result := ODS_10_And_Below
  else
    Result := ODS_11_And_Above;
end;

function TFirebirdLibrary.isc_attach_database(status_vector: PISC_STATUS_ARRAY;
    file_length: SmallInt; file_name: PISC_SCHAR; public_handle:
    pisc_db_handle; dpb_length: SmallInt; dpb: PISC_SCHAR): ISC_STATUS;
begin
  Result := Fisc_attach_database(status_vector, file_length, file_name, public_handle, dpb_length, dpb);

  var Info := TBytes.Create(isc_info_ods_version, isc_info_ods_minor_version);
  var buf: TBytes;
  var V := TStatusVector.Create as IStatusVector;
  SetLength(buf, High(Byte));

  isc_database_info(V.pValue, public_handle, Length(Info), @Info[0], Length(buf), @buf[0]);
  if V.Success then begin
    var i := 1;
    var L := isc_vax_integer(@buf[i], SizeOf(SmallInt));
    Assert(L = SizeOf(LongInt));
    Inc(i, SizeOf(SmallInt));
    var iMajor := isc_vax_integer(@buf[i], SizeOf(Longint));
    Inc(i, SizeOf(Longint));

    Inc(i);
    L := isc_vax_integer(@buf[i], SizeOf(SmallInt));
    Assert(L = SizeOf(LongInt));
    Inc(i, SizeOf(SmallInt));
    var iMinor := isc_vax_integer(@buf[i], SizeOf(Longint));

    FODS := Encode_ODS(iMajor, iMinor);
  end;

  DebugMsg(@Fisc_attach_database, [status_vector, file_length, file_name, public_handle, dpb_length, dpb], Result);
end;

function TFirebirdLibrary.isc_blob_info(status_vector: PISC_STATUS_ARRAY;
    isc_blob_handle: pisc_blob_handle; item_length: SmallInt; items:
    PISC_SCHAR; buffer_length: SmallInt; buffer: PISC_SCHAR): ISC_STATUS;
begin
  Result := FIsc_blob_info(status_vector, isc_blob_handle, item_length, items, buffer_length, buffer);
  DebugMsg(@FIsc_blob_info, [status_vector, isc_blob_handle, item_length, items, buffer_length, buffer], Result);
end;

function TFirebirdLibrary.isc_close_blob(status_vector: PISC_STATUS_ARRAY;
    blob_handle: pisc_blob_handle): ISC_STATUS;
begin
  Result := Fisc_close_blob(status_vector, blob_handle);
  DebugMsg(@Fisc_close_blob, [status_vector, blob_handle], Result);
end;

function TFirebirdLibrary.isc_commit_transaction(status_vector: PISC_STATUS_ARRAY;
    tra_handle: pisc_tr_handle): ISC_STATUS;
var H: Integer;
begin
  H := PInteger(tra_handle)^;
  Result := Fisc_commit_transaction(status_vector, tra_handle);
  DebugMsg(@Fisc_commit_transaction, [status_vector, H], Result);
end;

function TFirebirdLibrary.isc_create_blob(status_vector: PISC_STATUS_ARRAY;
    db_handle: pisc_db_handle; tr_handle: pisc_tr_handle; blob_handle:
    pisc_blob_handle; blob_id: PISC_QUAD): ISC_STATUS;
begin
  Result := Fisc_create_blob(status_vector, db_handle, tr_handle, blob_handle, blob_id);
  DebugMsg(@Fisc_create_blob, [status_vector, db_handle, tr_handle, blob_handle, blob_id], Result);
end;

function TFirebirdLibrary.isc_create_blob2(status_vector: PISC_STATUS_ARRAY;
    db_handle: pisc_db_handle; tr_handle: pisc_tr_handle; blob_handle:
    pisc_blob_handle; blob_id: PISC_QUAD; bpb_length: SmallInt; bpb:
    PISC_SCHAR): ISC_STATUS;
begin
  Result := Fisc_create_blob2(status_vector, db_handle, tr_handle, blob_handle, blob_id, bpb_length, bpb);
  DebugMsg(@Fisc_create_blob2, [status_vector, db_handle, tr_handle, blob_handle, blob_id, bpb_length, bpb], Result);
end;

function TFirebirdLibrary.isc_create_database(
  status_vector: PISC_STATUS_ARRAY; fileLength: Word; filename: PISC_SCHAR;
  publicHandle: pisc_db_handle; dpbLength: Word; dpb: PISC_SCHAR;
  db_type: Word): Integer;
begin
  Result := Fisc_create_database(status_vector, fileLength, filename, publicHandle, dpbLength, dpb, db_type);
  DebugMsg(@Fisc_create_database, [status_vector, fileLength, filename, publicHandle, dpbLength, dpb, db_type], Result);
end;

function TFirebirdLibrary.isc_database_info(status_vector: PISC_STATUS_ARRAY;
    db_handle: pisc_db_handle; info_len: SmallInt; info: PISC_SCHAR; res_len:
    SmallInt; res: PISC_SCHAR): ISC_STATUS;
begin
  Result := Fisc_database_info(status_vector, db_handle, info_len, info, res_len, res);
  DebugMsg(@Fisc_database_info, [status_vector, db_handle, info_len, info, res_len, res], Result);
end;

procedure TFirebirdLibrary.isc_decode_sql_date(date: PISC_DATE; times_arg:
    pointer);
begin
  Fisc_decode_sql_date(date, times_arg);
  DebugMsg(@Fisc_decode_sql_date, [date, times_arg], 0);
end;

procedure TFirebirdLibrary.isc_decode_sql_time(sql_time: PISC_TIME; times_args:
    pointer);
begin
  Fisc_decode_sql_time(sql_time, times_args);
  DebugMsg(@Fisc_decode_sql_time, [sql_time, times_args], 0);
end;

procedure TFirebirdLibrary.isc_decode_timestamp(date: PISC_TIMESTAMP;
    times_arg: pointer);
begin
  Fisc_decode_timestamp(date, times_arg);
  DebugMsg(@Fisc_decode_timestamp, [date, times_arg], 0);
end;

function TFirebirdLibrary.isc_detach_database(status_vector: PISC_STATUS_ARRAY;
    public_handle: pisc_db_handle): ISC_STATUS;
begin
  Result := Fisc_detach_database(status_vector, public_handle);
  FODS := ODS_CURRENT_VERSION;
  DebugMsg(@Fisc_detach_database, [status_vector, public_handle], Result);
end;

function TFirebirdLibrary.isc_drop_database(status_vector: PISC_STATUS_ARRAY;
    db_handle: pisc_db_handle): ISC_STATUS;
begin
  Result := Fisc_drop_database(status_vector, db_handle);
  DebugMsg(@Fisc_drop_database, [status_vector, db_handle], Result);
end;

function TFirebirdLibrary.isc_dsql_allocate_statement(status_vector:
    PISC_STATUS_ARRAY; db_handle: pisc_db_handle; stmt_handle: pisc_stmt_handle):
    ISC_STATUS;
begin
  Result := Fisc_dsql_allocate_statement(status_vector, db_handle, stmt_handle);
  DebugMsg(@Fisc_dsql_allocate_statement, [status_vector, db_handle, stmt_handle], Result);
end;

function TFirebirdLibrary.isc_dsql_alloc_statement2(status_vector: PISC_STATUS_ARRAY;
    db_handle: pisc_db_handle; stmt_handle: pisc_stmt_handle): ISC_STATUS;
begin
  Result := Fisc_dsql_alloc_statement2(status_vector, db_handle, stmt_handle);
  DebugMsg(@Fisc_dsql_alloc_statement2, [status_vector, db_handle, stmt_handle], Result);
end;

function TFirebirdLibrary.isc_dsql_describe(status_vector: PISC_STATUS_ARRAY;
    stmt_handle: pisc_stmt_handle; dialect: Word; sqlda: PXSQLDA): ISC_STATUS;
begin
  Result := Fisc_dsql_describe(status_vector, stmt_handle, dialect, sqlda);
  DebugMsg(@Fisc_dsql_describe, [status_vector, stmt_handle, dialect, sqlda], Result);
end;

function TFirebirdLibrary.isc_dsql_describe_bind(status_vector: PISC_STATUS_ARRAY;
    stmt_handle: pisc_stmt_handle; dialect: Word; sqlda: PXSQLDA): ISC_STATUS;
begin
  Result := Fisc_dsql_describe_bind(status_vector, stmt_handle, dialect, sqlda);
  DebugMsg(@Fisc_dsql_describe_bind, [status_vector, stmt_handle, dialect, sqlda], Result);
end;

function TFirebirdLibrary.isc_dsql_execute(status_vector: PISC_STATUS_ARRAY;
    tra_handle: pisc_tr_handle; stmt_handle: pisc_stmt_handle; dialect: Word;
    sqlda: PXSQLDA): ISC_STATUS;
begin
  Result := Fisc_dsql_execute(status_vector, tra_handle, stmt_handle, dialect, sqlda);
  DebugMsg(@Fisc_dsql_execute, [status_vector, tra_handle, stmt_handle, dialect, sqlda], Result);
end;

function TFirebirdLibrary.isc_dsql_execute2(status_vector: PISC_STATUS_ARRAY;
    tra_handle: pisc_tr_handle; stmt_handle: pisc_stmt_handle; dialect: Word;
    in_sqlda: PXSQLDA; out_sqlda: PXSQLDA): ISC_STATUS;
begin
  Result := Fisc_dsql_execute2(status_vector, tra_handle, stmt_handle, dialect, in_sqlda, out_sqlda);
  DebugMsg(@Fisc_dsql_execute2, [status_vector, tra_handle, stmt_handle, dialect, in_sqlda, out_sqlda], Result);
end;

function TFirebirdLibrary.isc_dsql_execute_immediate(status_vector:
    PISC_STATUS_ARRAY; db_handle: pisc_db_handle; tra_handle: pisc_tr_handle; length:
    Word; statement: PISC_SCHAR; dialect: Word; sqlda: PXSQLDA): ISC_STATUS;
begin
  Result := Fisc_dsql_execute_immediate(status_vector, db_handle, tra_handle, length, statement, dialect, sqlda);
  DebugMsg(@Fisc_dsql_execute_immediate, [status_vector, db_handle, tra_handle, length, statement, dialect, sqlda], Result);
end;

function TFirebirdLibrary.isc_dsql_fetch(status_vector: PISC_STATUS_ARRAY;
    stmt_handle: pisc_stmt_handle; da_version: Word; sqlda: PXSQLDA):
    ISC_STATUS;
begin
  Result := Fisc_dsql_fetch(status_vector, stmt_handle, da_version, sqlda);
  DebugMsg(@Fisc_dsql_fetch, [status_vector, stmt_handle, da_version, sqlda], Result);
end;

function TFirebirdLibrary.isc_dsql_free_statement(status_vector: PISC_STATUS_ARRAY;
    stmt_handle: pisc_stmt_handle; option: Word): ISC_STATUS;
begin
  Result := Fisc_dsql_free_statement(status_vector, stmt_handle, option);
  DebugMsg(@Fisc_dsql_free_statement, [status_vector, stmt_handle, option], Result);
end;

function TFirebirdLibrary.isc_dsql_prepare(status_vector: PISC_STATUS_ARRAY;
    tra_handle: pisc_tr_handle; stmt_handle: pisc_stmt_handle; length: Word;
    str: PISC_SCHAR; dialect: Word; sqlda: PXSQLDA): ISC_STATUS;
begin
  Result := Fisc_dsql_prepare(status_vector, tra_handle, stmt_handle, length, str, dialect, sqlda);
  DebugMsg(@Fisc_dsql_prepare, [status_vector, tra_handle, stmt_handle, length, str, dialect, sqlda], Result);
end;

function TFirebirdLibrary.isc_dsql_set_cursor_name(status_vector: PISC_STATUS_ARRAY;
    stmt_handle: pisc_stmt_handle; cursor_name: PISC_SCHAR; reserve: Word):
    ISC_STATUS;
begin
  Result := Fisc_dsql_set_cursor_name(status_vector, stmt_handle, cursor_name, reserve);
  DebugMsg(@Fisc_dsql_set_cursor_name, [status_vector, stmt_handle, cursor_name, reserve], Result);
end;

function TFirebirdLibrary.isc_dsql_sql_info(status_vector: PISC_STATUS_ARRAY;
    stmt_handle: pisc_stmt_handle; items_len: SmallInt; items: PISC_SCHAR;
    buffer_len: SmallInt; buffer: PISC_SCHAR): ISC_STATUS;
begin
  Result := Fisc_dsql_sql_info(status_vector, stmt_handle, items_len, items, buffer_len, buffer);
  DebugMsg(@Fisc_dsql_sql_info, [status_vector, stmt_handle, items_len, items, buffer_len, buffer], Result);
end;

procedure TFirebirdLibrary.isc_encode_sql_date(times_arg: pointer; date:
    PISC_DATE);
begin
  Fisc_encode_sql_date(times_arg, date);
  DebugMsg(@Fisc_encode_sql_date, [times_arg, date], 0);
end;

procedure TFirebirdLibrary.isc_encode_sql_time(times_arg: pointer; isc_time:
    PISC_TIME);
begin
  Fisc_encode_sql_time(times_arg, isc_time);
  DebugMsg(@Fisc_encode_sql_time, [times_arg, isc_time], 0);
end;

procedure TFirebirdLibrary.isc_encode_timestamp(times_arg: pointer; isc_time:
    PISC_TIMESTAMP);
begin
  Fisc_encode_timestamp(times_arg, isc_time);
  DebugMsg(@Fisc_encode_timestamp, [times_arg, isc_time], 0);
end;

function TFirebirdLibrary.isc_get_segment(status_vector: PISC_STATUS_ARRAY;
    blob_handle: pisc_blob_handle; length: System.pWord; buffer_length: Word; buffer:
    PISC_SCHAR): ISC_STATUS;
begin
  Result := Fisc_get_segment(status_vector, blob_handle, length, buffer_length, buffer);
  DebugMsg(@Fisc_get_segment, [status_vector, blob_handle, length, buffer_length, buffer], Result);
end;

function TFirebirdLibrary.isc_interprete(buffer: PISC_SCHAR; status_vector:
    PPISC_STATUS_ARRAY): ISC_STATUS;
begin
  Result := Fisc_interprete(buffer, status_vector);
  DebugMsg(@Fisc_interprete, [buffer, status_vector], Result);
end;

function TFirebirdLibrary.isc_open_blob(status_vector: PISC_STATUS_ARRAY; db_handle:
    pisc_db_handle; tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle;
    blob_id: PISC_QUAD): ISC_STATUS;
begin
  Result := Fisc_open_blob(status_vector, db_handle, tr_handle, blob_handle, blob_id);
  DebugMsg(@Fisc_open_blob, [status_vector, db_handle, tr_handle, blob_handle, blob_id], Result);
end;

function TFirebirdLibrary.isc_open_blob2(status_vector: PISC_STATUS_ARRAY; db_handle:
    pisc_db_handle; tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle;
    blob_id: PISC_QUAD; bpb_length: ISC_USHORT; bpb: PISC_UCHAR): ISC_STATUS;
begin
  Result := Fisc_open_blob2(status_vector, db_handle, tr_handle, blob_handle, blob_id, bpb_length, bpb);
  DebugMsg(@Fisc_open_blob2, [status_vector, db_handle, tr_handle, blob_handle, blob_id, bpb_length, bpb], Result);
end;

function TFirebirdLibrary.isc_put_segment(status_vector: PISC_STATUS_ARRAY;
    blob_handle: pisc_blob_handle; buffer_length: Word; buffer: PISC_SCHAR):
    ISC_STATUS;
begin
  Result := Fisc_put_segment(status_vector, blob_handle, buffer_length, buffer);
  DebugMsg(@Fisc_put_segment, [status_vector, blob_handle, buffer_length, buffer], Result);
end;

function TFirebirdLibrary.isc_rollback_transaction(status_vector: PISC_STATUS_ARRAY;
    tra_handle: pisc_tr_handle): ISC_STATUS;
begin
  Result := Fisc_rollback_transaction(status_vector, tra_handle);
  DebugMsg(@Fisc_rollback_transaction, [status_vector, tra_handle], Result);
end;

function TFirebirdLibrary.isc_service_attach(status_vector: PISC_STATUS_ARRAY;
    service_length: Word; service: PISC_SCHAR; svc_handle: pisc_svc_handle;
    spb_length: Word; spb: PISC_SCHAR): ISC_STATUS;
begin
  Result := Fisc_service_attach(status_vector, service_length, service, svc_handle, spb_length, spb);
  DebugMsg(@Fisc_service_attach, [status_vector, service_length, service, svc_handle, spb_length, spb], Result);
end;

function TFirebirdLibrary.isc_service_detach(status_vector: PISC_STATUS_ARRAY;
    svc_handle: pisc_svc_handle): ISC_STATUS;
begin
  Result := Fisc_service_detach(status_vector, svc_handle);
  DebugMsg(@Fisc_service_detach, [status_vector, svc_handle], Result);
end;

function TFirebirdLibrary.isc_service_query(status_vector: PISC_STATUS_ARRAY;
    svc_handle: pisc_svc_handle; reserved: pisc_resv_handle; send_spb_length:
    Word; send_spb: PISC_SCHAR; request_spb_length:Word; request_spb:
    PISC_SCHAR; buffer_length: Word; buffer: PISC_SCHAR): ISC_STATUS;
begin
  Result := Fisc_service_query(status_vector, svc_handle, reserved, send_spb_length, send_spb, request_spb_length, request_spb, buffer_length, buffer);
  DebugMsg(@Fisc_service_query, [status_vector, svc_handle, reserved, send_spb_length, send_spb, request_spb_length, request_spb, buffer_length, buffer], Result);
end;

function TFirebirdLibrary.isc_service_start(status_vector: PISC_STATUS_ARRAY;
    svc_handle: pisc_svc_handle; reserved: pisc_resv_handle; spb_length: Word;
    spb: PISC_SCHAR): ISC_STATUS;
begin
  Result := Fisc_service_start(status_vector, svc_handle, reserved, spb_length, spb);
  DebugMsg(@Fisc_service_start, [status_vector, svc_handle, reserved, spb_length, spb], Result);
end;

function TFirebirdLibrary.isc_sqlcode(status_vector: PISC_STATUS_ARRAY): ISC_LONG;
begin
  Result := Fisc_sqlcode(status_vector);
  DebugMsg(@Fisc_sqlcode, [status_vector], Result);
end;

function TFirebirdLibrary.isc_start_multiple(status_vector: PISC_STATUS_ARRAY;
    tra_handle: pisc_tr_handle; count: SmallInt; vec: pointer): ISC_STATUS;
begin
  Result := Fisc_start_multiple(status_vector, tra_handle, count, vec);
  DebugMsg(@Fisc_start_multiple, [status_vector, tra_handle, count, vec], Result);
end;

function TFirebirdLibrary.isc_vax_integer(buffer: PISC_SCHAR; len: SmallInt):
    ISC_LONG;
begin
  Result := Fisc_vax_integer(buffer, len);
  DebugMsg(@Fisc_vax_integer, [buffer, len], Result);
end;

function TFirebirdLibrary.Loaded: Boolean;
begin
  Result := FHandle <> 0;
end;

class function TFirebirdLibrary.New(aLibrary: string; aServerCharSet: string =
    'NONE'): IFirebirdLibrary;
begin
  Result := Create(aLibrary, aServerCharSet) as IFirebirdLibrary;
end;

function TFirebirdLibrary.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if IsEqualGUID(IID, IFirebirdLibraryDebugger) then begin
    IFirebirdLibraryDebugger(Obj) := FDebugger;
    Result := S_OK;
  end else
    Result := inherited QueryInterface(IID, Obj);
end;

procedure TFirebirdLibrary.SetupProcs;
begin
  Ffb_shutdown                 := GetProc(FHandle, 'fb_shutdown', False);
  Fisc_attach_database         := GetProc(FHandle, 'isc_attach_database');
  Fisc_blob_info               := GetProc(FHandle, 'isc_blob_info');
  Fisc_close_blob              := GetProc(FHandle, 'isc_close_blob');
  Fisc_commit_transaction      := GetProc(FHandle, 'isc_commit_transaction');
  Fisc_create_blob             := GetProc(FHandle, 'isc_create_blob');
  Fisc_create_blob2            := GetProc(FHandle, 'isc_create_blob2');
  Fisc_create_database         := GetProc(FHandle, 'isc_create_database');
  Fisc_database_info           := GetProc(FHandle, 'isc_database_info');
  Fisc_decode_sql_date         := GetProc(FHandle, 'isc_decode_sql_date');
  Fisc_decode_sql_time         := GetProc(FHandle, 'isc_decode_sql_time');
  Fisc_decode_timestamp        := GetProc(FHandle, 'isc_decode_timestamp');
  Fisc_detach_database         := GetProc(FHandle, 'isc_detach_database');
  Fisc_drop_database           := GetProc(FHandle, 'isc_drop_database');
  Fisc_dsql_allocate_statement := GetProc(FHandle, 'isc_dsql_allocate_statement');
  Fisc_dsql_alloc_statement2   := GetProc(FHandle, 'isc_dsql_alloc_statement2');
  Fisc_dsql_describe           := GetProc(FHandle, 'isc_dsql_describe');
  Fisc_dsql_describe_bind      := GetProc(FHandle, 'isc_dsql_describe_bind');
  Fisc_dsql_execute            := GetProc(FHandle, 'isc_dsql_execute');
  Fisc_dsql_execute2           := GetProc(FHandle, 'isc_dsql_execute2');
  Fisc_dsql_execute_immediate  := GetProc(FHandle, 'isc_dsql_execute_immediate');
  Fisc_dsql_fetch              := GetProc(FHandle, 'isc_dsql_fetch');
  Fisc_dsql_free_statement     := GetProc(FHandle, 'isc_dsql_free_statement');
  Fisc_dsql_prepare            := GetProc(FHandle, 'isc_dsql_prepare');
  Fisc_dsql_set_cursor_name    := GetProc(FHandle, 'isc_dsql_set_cursor_name');
  Fisc_dsql_sql_info           := GetProc(FHandle, 'isc_dsql_sql_info');
  Fisc_encode_sql_date         := GetProc(FHandle, 'isc_encode_sql_date');
  Fisc_encode_sql_time         := GetProc(FHandle, 'isc_encode_sql_time');
  Fisc_encode_timestamp        := GetProc(FHandle, 'isc_encode_timestamp');
  Fisc_get_segment             := GetProc(FHandle, 'isc_get_segment');
  Fisc_interprete              := GetProc(FHandle, 'isc_interprete');
  Fisc_open_blob               := GetProc(FHandle, 'isc_open_blob');
  Fisc_open_blob2              := GetProc(FHandle, 'isc_open_blob2');
  Fisc_put_segment             := GetProc(FHandle, 'isc_put_segment');
  Fisc_rollback_transaction    := GetProc(FHandle, 'isc_rollback_transaction');
  Fisc_sqlcode                 := GetProc(FHandle, 'isc_sqlcode');
  Fisc_service_attach          := GetProc(FHandle, 'isc_service_attach');
  Fisc_service_detach          := GetProc(FHandle, 'isc_service_detach');
  Fisc_service_query           := GetProc(FHandle, 'isc_service_query');
  Fisc_service_start           := GetProc(FHandle, 'isc_service_start');
  Fisc_start_multiple          := GetProc(FHandle, 'isc_start_multiple');
  Fisc_vax_integer             := GetProc(FHandle, 'isc_vax_integer');
end;

procedure TFirebirdLibrary.SetupTimeZoneHandler(
  aHandler: TSetupTimeZoneHandler);
begin
  if Assigned(aHandler) then
    FSetupTimeZoneHandler := aHandler
  else begin
    FreeAndNil(FTimeZones);
    FSetupTimeZoneHandler := nil;
  end;
end;

procedure TFirebirdLibrary.DebugMsg(const aProc: pointer; const aParams: array
    of const; aResult: ISC_STATUS);
begin
  if FDebugger.HasListener then
    FDebugger.Notify(GetDebugFactory.Get(FProcs[aProc], aProc, aParams, aResult));
end;

function TFirebirdLibrary.DoGetTimeZoneOffset(
  aFBTimeZoneID: Word): TTimeZoneOffset;
begin
  if (FTimeZones = nil) and Assigned(FSetupTimeZoneHandler) then begin
    FTimeZones := TDictionary<Word, TTimeZoneOffset>.Create;
    FSetupTimeZoneHandler(FTimeZones.Add);
  end;

  if not FTimeZones.TryGetValue(aFBTimeZoneID, Result) then
    Result := TTimeZoneOffset.Default;
end;

function TFirebirdLibrary.fb_shutdown(timeout: Cardinal = 20000; const reason:
    Integer = 0): Integer;
begin
  Result := 0;
  if Assigned(Ffb_shutdown) then begin
    Result := Ffb_shutdown(timeout, reason);
    DebugMsg(@Ffb_shutdown, [timeout, reason], Result);
  end;
end;

procedure TStatusVector.CheckAndRaiseError(
  const aFirebirdClient: IFirebirdLibrary);
begin
  if HasError then
    raise Exception.Create(GetError(aFirebirdClient).GetMessage);
end;

function TStatusVector.CheckError(const aFirebirdClient: IFirebirdLibrary; out
    aErrorCode: TFBIntType): boolean;
begin
  aErrorCode := 0;
  if HasError then
    aErrorCode := aFirebirdClient.isc_sqlcode(GetpValue);
  Result := aErrorCode <> 0;
end;

function TStatusVector.CheckFirebirdError(out aErrorCode: TFBIntType): boolean;
begin
  aErrorCode := 0;
  if HasError then
    aErrorCode := GetpValue[1];
  Result := aErrorCode <> 0;
end;

function TStatusVector.CheckResult(out aResult: word; const aFailed_Result:
    word): Boolean;
begin
  aResult := 0;
  if HasError then
    aResult := aFailed_Result;
  Result := aResult = 0;
end;

function TStatusVector.CheckResult(out aResult: longint; const aFailed_Result:
    longint): Boolean;
begin
  aResult := 0;
  if HasError then
    aResult := aFailed_Result;
  Result := aResult = 0;
end;

function TStatusVector.GetError(const aFirebirdClient: IFirebirdLibrary):
    IFirebirdError;
var P: array [0..1023] of AnsiChar;
    ptr: PISC_STATUS_ARRAY;
    sLastMsg, sError: string;
begin
  sError := '';
  ptr := GetpValue;
  while aFirebirdClient.isc_interprete(@P, @ptr) > 0 do begin
    sLastMsg := string({$if RtlVersion >= 20}System.AnsiStrings.{$ifend}StrPas(P));
    if sError <> '' then
      sError := sError + #13#10;
    sError := sError + sLastMsg;
  end;

  FError := nil;
  FError := TFirebirdError.Create(sError);
  Result := FError;
end;

function TStatusVector.GetpValue: PISC_STATUS_ARRAY;
begin
  Result := @FStatusVector;
end;

function TStatusVector.HasError: boolean;
begin
  Result := (FStatusVector[0] = 1) and (FStatusVector[1] > 0);
end;

function TStatusVector.Success: boolean;
begin
  Result := not HasError;
end;

function TStatusVector.GetLastError: IFirebirdError;
begin
  Result := FError;
end;

function TFirebirdLibraryDebugger.HasListener: Boolean;
begin
  Result := Assigned(FListener);
end;

procedure TFirebirdLibraryDebugger.Notify(const aDebugStr: string);
begin
  if HasListener then
    FListener.Update(aDebugStr);
end;

procedure TFirebirdLibraryDebugger.SetListener(
  const aListener: IFirebirdLibraryDebuggerListener);
begin
  FListener := aListener;
end;

{ TFirebirdError }

constructor TFirebirdError.Create(const aErrorMessage: string);
begin
  inherited Create;
  FMessage := aErrorMessage;
end;

function TFirebirdError.GetLength: Smallint;
begin
  Result := Length(FMessage);
end;

function TFirebirdError.GetMessage: string;
begin
  Result := FMessage;
end;

procedure TFirebirdError.GetMessage(const aMsg: PWideChar);
var W: WideString;
begin
  W := FMessage;
  lstrcpyW(aMsg, PWideChar(W));
end;

constructor TFirebirdTransaction.Create(const aFirebirdClient:
    IFirebirdLibrary; const aDBHandle: pisc_db_handle; const aTransInfo:
    TTransactionInfo);
var b: byte;
    iTimeOut: ISC_LONG;
    TimeOut: array[0..3] of Byte absolute iTimeOut;
begin
  inherited Create;
  FClient := aFirebirdClient;

  FTransInfo := aTransInfo;

  Fisc_tec := [isc_tpb_version3];

  if aTransInfo.ReadOnly then
    Fisc_tec := Fisc_tec + [isc_tpb_read]
  else
    Fisc_tec := Fisc_tec + [isc_tpb_write];

  b := 0;
  case aTransInfo.Isolation of
    isoReadCommitted:  b := isc_tpb_read_committed;
    isoRepeatableRead: b := isc_tpb_concurrency;
  end;
  if b <> 0 then
    Fisc_tec := Fisc_tec + [b];

  if aTransInfo.Isolation = isoReadCommitted then begin
    Fisc_tec := Fisc_tec + [isc_tpb_rec_version];

    if aTransInfo.WaitOnLocks then begin
      Fisc_tec := Fisc_tec + [isc_tpb_wait];

      if (aTransInfo.WaitOnLocksTimeOut <> -1) and (aFirebirdClient.GetODS >= ODS_11_1)then begin
        iTimeOut := aTransInfo.WaitOnLocksTimeOut;
        Fisc_tec := Fisc_tec + [isc_tpb_lock_timeout];
        Fisc_tec := Fisc_tec + [SizeOf(ISC_LONG)];
        Fisc_tec := Fisc_tec + [TimeOut[0], TimeOut[1], TimeOut[2], TimeOut[3]];
      end;
    end else
      Fisc_tec := Fisc_tec + [isc_tpb_nowait];
  end;

  FTransactionHandle := nil;
  FTransParam.database := aDBHandle;
  FTransParam.tpb_len := Length(Fisc_tec);
  FTransParam.tpb := @Fisc_tec[0];
end;

function TFirebirdTransaction.GetID: LongWord;
begin
  Result := FTransInfo.ID;
end;

function TFirebirdTransaction.Active: boolean;
begin
  Result := FTransactionHandle <> nil;
end;

function TFirebirdTransaction.Commit(const aStatusVector: IStatusVector):
    ISC_STATUS;
begin
  if Active then
    Result := FClient.isc_commit_transaction(aStatusVector.pValue, TransactionHandle)
  else
    Result := 0;
end;

function TFirebirdTransaction.Rollback(const aStatusVector: IStatusVector):
    ISC_STATUS;
begin
  Assert(Active);
  Result := FClient.isc_rollback_transaction(aStatusVector.pValue, TransactionHandle);
  Assert(not Active);
end;

function TFirebirdTransaction.Start(aStatusVector: IStatusVector): ISC_STATUS;
begin
  Assert(not Active);
  Result := FClient.isc_start_multiple(aStatusVector.pValue, TransactionHandle, 1, @FTransParam);
end;

function TFirebirdTransaction.TransactionHandle: pisc_tr_handle;
begin
  Result := @FTransactionHandle;
end;

constructor TFirebirdTransactionPool.Create(const aFirebirdClient:
    IFirebirdLibrary; const aDBHandle: pisc_db_handle; const
    aDefaultTransactionInfo: TTransactionInfo);
begin
  inherited Create;
  FFirebirdClient := aFirebirdClient;
  FDBHandle := aDBHandle;
  FDefaultTransactionInfo := aDefaultTransactionInfo;
end;

function TFirebirdTransactionPool.CurrentTransaction: TFirebirdTransaction;
begin
  if FItems.Count > 0 then
    Result := FItems.Last
  else
    Result := nil;
end;

function TFirebirdTransactionPool.Add(const aTransInfo: TTransactionInfo):
    TFirebirdTransaction;
begin
  {$if CompilerVersion = 18}
  if Assigned(Get(aTransInfo.ID)) then
    raise ETransactionExist.CreateFmt('Transaction ID %d already exist', [aTransInfo.ID]);
  {$ifend}

  Result := TFirebirdTransaction.Create(FFirebirdClient, FDBHandle, aTransInfo);
  FItems.Add(Result);
end;

function TFirebirdTransactionPool.Add: TFirebirdTransaction;
begin
  Result := Add(FDefaultTransactionInfo);
end;

procedure TFirebirdTransactionPool.AfterConstruction;
begin
  inherited;
  FItems := TObjectList<TFirebirdTransaction>.Create();
end;

procedure TFirebirdTransactionPool.BeforeDestruction;
var S: IStatusVector;
    N: TFirebirdTransaction;
begin
  inherited;
  if FItems.Count > 0 then begin
    S := TStatusVector.Create;
    for N in FItems do begin
      if N.Active then N.Rollback(S);
      FItems.Remove(N);
    end;
  end;
  FItems.Free;
end;

function TFirebirdTransactionPool.Commit(const aStatusVector: IStatusVector;
    const aTransaction: TFirebirdTransaction): ISC_STATUS;
begin
  Result := aTransaction.Commit(aStatusVector);
  if aStatusVector.Success then
    Assert(FItems.Remove(aTransaction) >= 0);
end;

function TFirebirdTransactionPool.RollBack(const aStatusVector: IStatusVector;
    const aTransaction: TFirebirdTransaction): ISC_STATUS;
begin
  Result := aTransaction.Rollback(aStatusVector);
  if aStatusVector.Success then
    Assert(FItems.Remove(aTransaction) >= 0);
end;

procedure TFirebirdLibraryRootPath.AddVar(const aVarName: string);
var S: string;
begin
  S := GetEnvironmentVariable(aVarName);
  if S = '' then
    FOldVars.Add(aVarName + '=')
  else
    FOldVars.Values[aVarName] := S;
end;

procedure TFirebirdLibraryRootPath.BeforeDestruction;
begin
  inherited;
  SetVars(FOldVars);
  FOldVars.Free;
end;

constructor TFirebirdLibraryRootPath.Create(const aRootPath: string);
var sPath: array[0..MAX_PATH] of char;
    S: TStringList;
begin
  inherited Create;
  FOldVars := TStringList.Create;

  AddVar('FIREBIRD');
  AddVar('FIREBIRD_MSG');
  AddVar('FIREBIRD_TMP');

  S := TStringList.Create;
  try
    S.Values['FIREBIRD'] := aRootPath;
    S.Values['FIREBIRD_MSG'] := aRootPath;

    GetTempPath(MAX_PATH, sPath);
    S.Values['FIREBIRD_TMP'] := sPath;

    SetVars(S);
  finally
    S.Free;
  end;
end;

constructor TFirebirdLibraryRootPath.CreateFromLibrary(const aLibrary: string;
    const Dummy: Integer = 0);
begin
  Create(ExtractFilePath(aLibrary));
end;

procedure TFirebirdLibraryRootPath.SetVars(const aVars: TStringList);
var H: THandle;
    putenv: function(estr: PAnsiChar): integer; cdecl;
    S: string;
begin
  H := LoadLibrary('msvcrt.dll');
  if (H >= 32) then begin
    try
      putenv := GetProcAddress( H, '_putenv');
      if Assigned(putenv) then begin
        for S in aVars do
          putenv(PAnsiChar(AnsiString(S)));
      end;
    finally
      FreeLibrary(H);
    end;
  end;
end;

constructor TFirebirdSQLParser.Create;
begin
 FTerm := ';';
 FCommands := TStringlist.Create;
end;

destructor TFirebirdSQLParser.Destroy;
begin
 FreeAndNil(FCommands);
 inherited;
end;

function TFirebirdSQLParser.CheckTERM(cmd:string):boolean;
var s:string;
begin
 result:=false;
 s := uppercase(trim(cmd));
 if pos('SET TERM ',s) = 1 then begin
  if length(s) >= 10 then begin
   FTerm := s[10];
   result:=true;
  end;
 end;
end;

function TFirebirdSQLParser.EOS: boolean;
begin
 result:=ci>length(Script);
end;

function TFirebirdSQLParser.IsConsoleCommand(cmd:string):boolean;
begin
 cmd := uppercase(trim(cmd));
 result:=(pos('SET ',cmd) = 1)
       or(cmd='COMMIT WORK');
end;

procedure TFirebirdSQLParser.LoadFromFile(AFileName: string);
var lScripts: TStringList;
begin
  lScripts := TStringList.Create;
  try
    lScripts.LoadFromFile(AFileName);
    SetScript(lScripts.Text);
  finally
    lScripts.Free;
  end;
end;

function TFirebirdSQLParser.NextCommand:string;
var escapechar,escaped,onlyspace:boolean;
    c,lastchar:char;incomment:boolean;
begin
 result:='';escaped := false;incomment:=false;lastchar:=#0;
 onlyspace:=true;
 while ci <= length(Script) do begin
  c:=Script[ci];
  if incomment then begin
   escaped := false;
   incomment := not ((c='/') and (lastchar='*'));
   if not incomment then begin
    if Length(result) > 0 then SetLength(result,Length(result)-1);
    lastchar:=c;
    inc(ci);
    continue;
   end;
  end
  else begin
   incomment := ((c='*') and (lastchar='/'));
   if incomment
   then SetLength(result,Length(result)-1);
  end;
  if not incomment then begin
   escapechar := {$if CompilerVersion <= 18.5}c in ['''','"']{$else}CharInSet(c, ['''','"']){$ifend};
   if escapechar then escaped := not escaped;
   if not escaped then begin
    if c = FTerm then begin
     inc(ci);
     break;
    end
    else begin
     if onlyspace then begin
      if not {$if CompilerVersion <= 18.5}(c in [#13,#10,' ',#09]){$else}CharInSet(c, [#13,#10,' ',#09]){$ifend} then begin
       onlyspace:=false;
       result:='';
      end;
     end;
    end;
   end;
   result:=result + c;
  end;
  lastchar:=c;
  inc(ci);
 end;
end;

procedure TFirebirdSQLParser.Parse;
var cmd:string;
begin
 cmd := inttostr(length(script));
 FCommands.Clear;
 while not eos do begin
  cmd := NextCommand;
  cmd := trim(StripLines(cmd));
  if length(cmd) > 0 then begin
   if isConsoleCommand(cmd) then CheckTERM(cmd)
   else FCommands.Add(cmd);
  end;
 end;
end;

procedure TFirebirdSQLParser.SetScript(const Value: string);
begin
 FScript := Value;
 ci:=1;
 Parse;
end;

function TFirebirdSQLParser.StripLines(s:string):string;
var i:integer; l:TStringlist;
begin
 l := TStringlist.Create;
 try
  l.Text := s;
  for i := l.Count-1 downto 0 do
   if length(trim(l[i])) = 0 then l.delete(i);
  i := length(l.Text)-2;
  result:=copy(l.Text,1,i);
 finally
  l.free;
 end;
end;

function TFirebirdPB.AddByte(const B: Byte): TFirebirdPB;
var i: integer;
begin
  i := GetLength;
  IncSize(SizeOf(B));
  FParams[i] := B;
  Result := Self;
end;

function TFirebirdPB.AddLongint(const B: LongInt): TFirebirdPB;
var i: integer;
    P: PLongint;
begin
  i := GetLength;
  IncSize(SizeOf(B));
  P := @FParams[i];
  P^ := B;
  Result := Self;
end;

function TFirebirdPB.AddShortString(const aValue: string): TFirebirdPB;
var i: Integer;
    S: string;
    B: TBytes;
begin
  i := GetLength;
  S := Copy(aValue, 0, Min(High(Byte), Length(aValue)));
  B := TEncoding.Default.GetBytes(S);
  AddByte(Length(B));
  IncSize(Length(B));
  Inc(i, SizeOf(Byte));
  Move(B[0], FParams[i], Length(B));
  Result := Self;
end;

function TFirebirdPB.AddSmallInt(const B: SmallInt): TFirebirdPB;
var i: integer;
    P: PSmallInt;
begin
  i := GetLength;
  IncSize(SizeOf(B));
  P := @FParams[i];
  P^ := B;
  Result := Self;
end;

function TFirebirdPB.AddString(const aValue: string): TFirebirdPB;
var i: SmallInt;
    S: string;
    B: TBytes;
begin
  i := GetLength;
  S := Copy(aValue, 0, Min(High(SmallInt), Length(aValue)));
  B := TEncoding.Default.GetBytes(S);
  AddSmallInt(Length(B));
  IncSize(Length(B));
  Inc(i, SizeOf(SmallInt));
  Move(B[0], FParams[i], Length(B));
  Result := Self;
end;

class function TFirebirdPB.GetDPB(const aUser, aPassword: string): TFirebirdPB;
begin
  Result := Result.Init([])
           .AddByte(isc_dpb_version1)
           .AddByte(isc_dpb_user_name)
           .AddShortString(aUser)
           .AddByte(isc_dpb_password)
           .AddShortString(aPassword);
end;

function TFirebirdPB.GetLength: Integer;
begin
  Result := System.Length(FParams);
end;

function TFirebirdPB.IncSize(const aIncSize: Integer): TFirebirdPB;
begin
  SetLength(FParams, GetLength + aIncSize);
  Result := Self;
end;

function TFirebirdPB.Init(const aParams: array of byte): TFirebirdPB;
begin
  SetLength(FParams, 0);
  Result := Self;
end;

class operator TFirebirdPB.Implicit(const A: TFirebirdPB): Pointer;
begin
  Result := @A.FParams[0];
end;

procedure TTransactionInfo.Init(aIsolation: TTransactionIsolation =
    isoReadCommitted; aWaitOnLocks: Boolean = False; aWaitOnLocksTimeOut:
    Integer = -1; aReadOnly: Boolean = False);
begin
  ID := 0;
  Isolation := aIsolation;
  WaitOnLocks := aWaitOnLocks;
  WaitOnLocksTimeOut := aWaitOnLocksTimeOut;
  ReadOnly := aReadOnly;
end;

function TFirebirdEngine.GetEncodedODS: UInt16;
begin
  case FMajor of
    3: Result := ODS_12_0;
    4: Result := ODS_13_0;
  else
    raise Exception.CreateFmt('Unsupported version %s', [GetVersion]);
  end;
end;

class operator TFirebirdEngine.Implicit(Value: string): TFirebirdEngine;
begin
  Result.FFileName := Value;
  if not GetProductVersion(Value, Result.FMajor, Result.FMinor, Result.FBuild) then begin
    Result.FMajor := 0;
    Result.FMinor := 0;
    Result.FBuild := 0;
  end;
end;

function TFirebirdEngine.GetVersion: string;
begin
  Result := Format('%d.%d.%d', [FMajor, FMinor, FBuild]);
end;

class operator TFirebirdEngine.Implicit(Value: TFirebirdEngine): string;
begin
  if TFile.Exists(Value.FFileName) then
    Result := TPath.GetFileNameWithoutExtension(Value.FFileName)
  else
    Result := Value.FFileName;
end;

class function TFirebirdEngine.Loopback: TFirebirdEngine;
begin
  Result := 'Loopback';
end;

class function TFirebirdEngine.Remote: TFirebirdEngine;
begin
  Result := 'Remote';
end;

function TFirebirdEngine.SupportedPageSizes: TArray<Integer>;
begin
  var i := MIN_PAGE_SIZE;
  var m := MAX_PAGE_SIZE;
  if FMajor < 4 then m := m shr 1;

  while i <= m do begin
    Result := Result + [i];
    i := i shl 1;
  end;
end;

constructor TFirebirdEngines.TEnumerator.Create(const Engines:
    TFirebirdEngines);
begin
  FCurrent := -1;
  FGetCurrent := Engines.Get;
  FCount := Engines.Count;
end;

function TFirebirdEngines.TEnumerator.GetCurrent: TFirebirdEngine;
begin
  Result := FGetCurrent(FCurrent);
end;

function TFirebirdEngines.TEnumerator.MoveNext: Boolean;
begin
  Inc(FCurrent);
  Result := FCurrent < FCount;
end;

function TFirebirdEngines.Count: Integer;
begin
  Result := Length(FEngines);
end;

constructor TFirebirdEngines.Create(aRoot_Or_fbclient: string);
begin
  aRoot_Or_fbclient := ExpandFileNameString(aRoot_Or_fbclient);
  if not (System.IOUtils.TFileAttribute.faDirectory in TPath.GetAttributes(aRoot_Or_fbclient)) then
    aRoot_Or_fbclient := TPath.GetDirectoryName(aRoot_Or_fbclient);

  SetLength(FEngines, 0);

  var plugins := IncludeTrailingPathDelimiter(aRoot_Or_fbclient) + 'plugins';
  if TDirectory.Exists(plugins) then begin
    var A := TDirectory.GetFiles(plugins, 'engine*.dll');

    TArray.Sort<string>(A, TDelegatedComparer<string>.Construct(
      function(const Left, Right: string): Integer
      begin
        Result := TComparer<string>.Default.Compare(Right, Left);
      end
    ));

    for var s in A do
      FEngines := FEngines + [s];
  end;
end;

function TFirebirdEngines.Get(aIndex: Integer): TFirebirdEngine;
begin
  Result := FEngines[aIndex];
end;

function TFirebirdEngines.GetEnumerator: TEnumerator;
begin
  Result := TEnumerator.Create(Self);
end;

class function TFirebirdEngines.GetProviders(aRoot_Or_fbclient: string): string;
begin
  Result := TFirebirdEngines.Create(aRoot_Or_fbclient).GetProviders;
end;

function TFirebirdEngines.GetProviders(aEngines: array of TFirebirdEngine):
    string;
var A: array of TFirebirdEngine;
begin
  if Length(aEngines) > 0 then begin
    SetLength(A, Length(aEngines));
    TArray.Copy<TFirebirdEngine>(aEngines, A, Length(A));
  end else if Length(FEngines) > 0 then begin
    SetLength(A, Length(FEngines));
    TArray.Copy<TFirebirdEngine>(FEngines, A, Length(A));
  end else
    Exit('');

  A := [TFirebirdEngine.Remote] + A + [TFirebirdEngine.Loopback];

  var s: TArray<string>;
  for var e in A do
    s := s + [e];

  Result := TFirebird.FB_Config_Providers + '=' + string.Join(',', s);
end;

function TFirebirdEngines.GetProviders: string;
begin
  Result := GetProviders([]);
end;

end.
