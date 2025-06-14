unit firebird.client;

interface

uses
  Winapi.Windows, System.Classes, System.Generics.Collections, System.SysUtils,
  Firebird,
  firebird.ibase.h, firebird.inf_pub.h, firebird.jrd.h, firebird.sqlda_pub.h,
  firebird.types_pub.h;

const
  FirebirdTransaction_WaitOnLocks = $0100;
  FirebirdTransaction_ReadOnly = $0200;

type
  TFirebird = record
    const service_mgr = 'service_mgr';
    const DefaultDBAPassword = 'masterkey';
    const FB_Config_Providers = 'Providers';
    const MIN_PAGE_BUFFERS = 50;
    const MAX_PAGE_BUFFERS = 131072;
    const isc_spb_res_parallel_workers = isc_spb_bkp_parallel_workers;
  end;

  TFirebird_ODS_Major = (ODS_10_And_Below, ODS_11_And_Above);

  TODS = record
  strict private
    FValue: Word;
  public
    constructor Create(aMajor, aMinor: Word);
    class function GetODS(aDatabaseFile: string): TODS; static;
    function Major: Word;
    function Minor: Word;
    function ToString: string;
    class operator Equal(a: TODS; b: TODS): Boolean;
    class operator GreaterThanOrEqual(a: TODS; b: TODS): Boolean;
    class operator GreaterThan(a: TODS; b: TODS): Boolean;
    class operator LessThan(a: TODS; b: TODS): Boolean;
    class operator LessThanOrEqual(a: TODS; b: TODS): Boolean;
    class operator NotEqual(a: TODS; b: TODS): Boolean;
    class operator Implicit(v: Integer): TODS;
    class operator Implicit(o: string): TODS;
    class operator Implicit(o: TODS): Integer;
    class operator Implicit(o: TODS): string;
  end;

  TFirebirdEngine = record
  strict private
    FFileName: string;
    FPlatform: TOSVersion.TPlatform;
    FMajor: Integer;
    FMinor: Integer;
    FRelease: Integer;
    FBuild: Integer;
    FIsCurrent: Boolean;
    class function GetProductVersion(const AValue: string; var APlatform:
        TOSVersion.TPlatform; var AMajor, AMinor, ARelease, ABuild: Integer):
        Boolean; static;
  private
    function GetODS: TODS;
    function GetPlatform: TOSVersion.TPlatform;
    function GetVersion: string;
  public
    class operator Implicit(Value: string): TFirebirdEngine;
    class operator Implicit(Value: TFirebirdEngine): string;
    class function Loopback: TFirebirdEngine; static;
    class function Remote: TFirebirdEngine; static;
    function SupportedPageSizes: TArray<Integer>;
    property IsCurrent: Boolean read FIsCurrent write FIsCurrent;
    property FileName: string read FFileName;
    property Major: Integer read FMajor;
    property Minor: Integer read FMinor;
    property Release: Integer read FRelease;
    property Build: Integer read FBuild;
    property ODS: TODS read GetODS;
    property Platform: TOSVersion.TPlatform read GetPlatform;
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
    function GetEngineByProviders(aProviders: string; out aEngine:
        TFirebirdEngine): Boolean;
    function GetEngineByODS(aODS: TODS; out aEngine: TFirebirdEngine): Boolean;
    function GetEnumerator: TEnumerator;
    function GetProviders: string; overload;
    class function GetProviders(aRoot_Or_fbclient: string): string; overload;
        static;
    function GetProviders(aEngines: array of TFirebirdEngine): string; overload;
    property Items[Index: Integer]: TFirebirdEngine read Get; default;
  end;

  TFirebirdConfig = record
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

  TInfoValue<T> = record
  strict private
    FAvailable: Boolean;
    FValue: T;
    class function New(a: T): TInfoValue<T>; static;
  public
    function Available: Boolean;
    procedure Clear;
    class operator Implicit(a: TInfoValue<T>): T;
    class operator Implicit(a: T): TInfoValue<T>;
    class operator Initialize(out Dest: TInfoValue<T>);
    property Value: T read FValue;
  end;

  TQueryBufferReader = reference to function(var Buffer; Count: Word): Word;

  TQueryBuffer = record
  strict private
    FValues: TBytes;
    const DefaultSize = High(Word);
  public
    class operator Assign(var Dest: TQueryBuffer; const [ref] Src: TQueryBuffer);
    class operator Initialize(out Dest: TQueryBuffer);
    function AsPtr(i: UInt64 = 0): BytePtr; inline;
    function Fetch(Reader: TQueryBufferReader; aSize: Word): Word;
    function Size: Integer; inline;
    procedure SetSize(aSize: Word);
  end;

  TDatabaseInfo = record
  const
    Items: array[0..13] of Byte = (
      isc_info_page_size
    , isc_info_num_buffers
    , isc_info_ods_version
    , isc_info_ods_minor_version
    , isc_info_db_sql_dialect
    , isc_info_sweep_interval
    , isc_info_db_read_only
    , isc_info_forced_writes
    , isc_info_creation_date
    , isc_info_db_size_in_pages
    , isc_info_current_memory
    , isc_info_max_memory
    , isc_info_firebird_version
    , isc_info_isc_version
    );
  public
    page_size: Int32;
    num_buffers: Int32;
    ods_version: Int32;
    ods_minor_version: Int32;
    db_sql_dialect: Int32;
    sweep_interval: Int32;
    db_read_only: Boolean;
    forced_writes: Boolean;
    creation_date: TDateTime;
    db_size_in_pages: Int32;
    current_memory: Int32;
    max_memory: Int32;
    firebird_version: string;
    isc_version: string;
    function ODS: TODS;
    function FileSize: UInt64;
    class function AsPtr: Pointer; static; inline;
    class function Size: Integer; static; inline;
  end;

  TServiceManagerInfo = record
  public
    svc_version: Int32;
    svc_server_version: string;
    svc_implementation: string;
    num_att: Integer;
    num_db: Integer;
    db_name: TArray<string>;
    get_env: string;
    class function Items(aDBInfos: Boolean = False): TBytes; static; inline;
    function IsWindows: Boolean;
  end;

  TServiceQueryInfo = record
  strict private
    FTags: TBytes;
    class constructor Create;
    class function New(aTags: array of Byte): TServiceQueryInfo; static;
  public
    class var eof: TServiceQueryInfo;
    class var line: TServiceQueryInfo;
    class var restore: TServiceQueryInfo;
    function Size: Integer; inline;
    function AsPtr: Pointer; inline;
  end;

  TPageSize = (ps4096, ps8192, ps16384, ps32768);

  TPageSizeHelper = record helper for TPageSize
    class function Create(const Value: Integer): TPageSize; static;
    class function Default: TPageSize; static;
    function ToInteger: Integer;
  end;

  TFirebirdConnectionStringProtocol = (
    local     // Local connection
  , wnet_tra  // Traditional WNET
  , tcp_tra   // Traditional TCP
  , xnet      // URL XNET
  , wnet      // URL WNET
  , inet      // URL TCP
  , inet4     // URL TCP
  , inet6     // URL TCP
  );

  TFirebirdConnectionStringProtocolHelper = record helper for TFirebirdConnectionStringProtocol
    const URL_Delimiter = '://';
    class function Get(V: string): TFirebirdConnectionStringProtocol; static;
    class function IsValidWindowsFileName(aStr: string): Boolean; static;
    function ToString(AppendDelimiter: Boolean = False): string;
  end;

  TFirebirdConnectionString = record
  strict private
    FProtocol: TFirebirdConnectionStringProtocol;
    FPort: string;
    FHost: string;
    FDatabase: string;
    function GetValue: string;
    procedure SetValue(v: string);
  public
    class operator Initialize(out Dest: TFirebirdConnectionString);
    class operator Implicit(a: string): TFirebirdConnectionString;
    class operator Implicit(a: TFirebirdConnectionString): string;
    function AsServiceManager: string;
    property Host: string read FHost write FHost;
    property Database: string read FDatabase write FDatabase;
    property Port: string read FPort write FPort;
    property Protocol: TFirebirdConnectionStringProtocol read FProtocol write
        FProtocol;
    property Value: string read GetValue;
  end;

  TBurpData = record
    // Backup program attributes
    att_backup_date: string;             // date of backup
    att_type_att_backup_format: UInt32;  // backup format version
    att_backup_os: UInt32;               // backup operating system
    att_backup_compress: Boolean;
    att_backup_transportable: Boolean;   // XDR datatypes for user data
    att_backup_blksize: UInt32;          // backup block size
    att_backup_file: string;             // database file name
    att_backup_volume: UInt32;           // backup volume number
    att_backup_keyname: string;          // name of crypt key
    att_backup_zip: string;              // zipped backup file
    att_backup_hash: string;             // hash of crypt key
    att_backup_crypt: string;            // name of crypt plugin

    // Database attributes
    att_file_name: string;               // database file name (physical)
    att_file_size: UInt32;               // size of original database (physical)
    att_jrd_version: UInt32;             // jrd version (physical)
    att_creation_date: string;           // database creation date (physical)
    att_page_size: UInt32;               // page size of original database (physical)
    att_database_description: string;    // description from RDB$DATABASE (logical)
    att_database_security_class: string; // database level security (logical)
    att_sweep_interval: UInt32;          // sweep interval
    att_no_reserve: Boolean;             // don't reserve space for versions
    att_database_description2: string;
    att_database_dfl_charset: string;    // default character set from RDB$DATABASE
    att_forced_writes: Boolean;          // syncronous writes flag
    att_page_buffers: UInt32;            // page buffers for buffer cache
    att_SQL_dialect: UInt32;             // SQL dialect that it speaks
    att_db_read_only: Boolean;           // Is the database ReadOnly?
    att_database_linger: UInt32;         // Disconnection timeout
    att_database_sql_security_deprecated: Boolean; // can be removed later
    att_replica_mode: UInt32;            // replica mode
    att_database_sql_security: Boolean;  // default sql security value
  private
  type
    TBurpDataItem = TBytes;
    TBurpDataItemHelper = record helper for TBurpDataItem
      function AsBoolean: Boolean;
      function AsString: string;
      function AsUINT32: UINT32;
    end;
    procedure LoadFromStream(S: TStream);
  public
    class operator Implicit(A: TStream): TBurpData;
  end;

  PFirebirdAPI = ^TFirebirdAPI;
  TFirebirdAPI = record
    class operator Assign(var Dest: TFirebirdAPI; const [ref] Src: TFirebirdAPI);
    class operator Initialize(out Dest: TFirebirdAPI);
  strict private
    Fmaster: IMaster;
    Fstatus: IStatus;
    util: IUtil;
    prov: IProvider;
    const stdin = 'stdin';
    const stdout = 'stdout';
    type TBackupInfoProcessor = reference to procedure(const Buf; Count: NativeInt);
    type TBackupDataReader = TQueryBufferReader;
  strict private
    FHandle: THandle;
    FFBClient: string;
    FUserName: TInfoValue<string>;
    FPassword: TInfoValue<string>;
    FProviders: TInfoValue<string>;
    FConnectionString: TFirebirdConnectionString;
    FPageSize: TInfoValue<TPageSize>;
    FForcedWrite: TInfoValue<Boolean>;
    FPageBuffers: TInfoValue<Cardinal>;
    FParallelWorkers: TInfoValue<Integer>;
    function FirebirdException: Exception;
  public
    function AttachDatabase(aExpectedDB: string = ''): IAttachment;
    function AttachServiceManager(aExpectedDB: string = ''): IService;
    procedure Backup(Process: TBackupInfoProcessor = nil; aBackupFile: string = stdout);
        overload;
    function CreateDatabase(aDummy: Integer): IAttachment; overload;
    procedure CreateDatabase; overload;
    procedure DropDatabase;
    function GetDatabaseInfo: TDatabaseInfo;
    function GetServiceInfo(aDBInfos: Boolean): TServiceManagerInfo;
    function GetPlans(aSQLs: array of string): TArray<string>;
    procedure nBackup(aBackupFile: string; Process: TBackupInfoProcessor = nil;
        aBackupLevel: Integer = 0);
    procedure nFix(aBackupFile: string; Process: TBackupInfoProcessor = nil);
    procedure nRestore(aBackupFiles: array of string; Process: TBackupInfoProcessor
        = nil);
    procedure Restore(aBackupFile: string; Process: TBackupInfoProcessor = nil;
        Read: TBackupDataReader = nil); overload;
    procedure Restore(Read: TBackupDataReader = nil; Process: TBackupInfoProcessor
        = nil); overload;
    procedure SetProperties;
  public
    class function New(aFBClient: string): TFirebirdAPI;
        overload; static;
    function New(aFBClient: string; Dummy: Integer): PFirebirdAPI; overload;
    function New(aFBClient: string; out aStatus: IStatus): PFirebirdAPI; overload;
    function Reset: PFirebirdAPI;
    function SetCredential(aUserName, aPassword: string): PFirebirdAPI;
    function SetConnectionString(aConnStr: string): PFirebirdAPI; overload;
    function SetConnectionString(aDatabase, ProvidersOrHost: string): PFirebirdAPI;
        overload;
    function SetConnectionString(aDatabase, aHost: string; aProtocol: TFirebirdConnectionStringProtocol): PFirebirdAPI; overload;
    function SetPageBuffers(aValue: Cardinal): PFirebirdAPI;
    function SetPageSize(aValue: TPageSize): PFirebirdAPI;
    function SetParallelWorkers(aValue: Integer): PFirebirdAPI;
    function SetProviders(aProviders: string): PFirebirdAPI;
    function SetForcedWrite(aValue: Boolean = True): PFirebirdAPI;
    property master: IMaster read Fmaster;
    property FBClient: string read FFBClient;
  end;

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
    function isc_attach_database(status_vector: PISC_STATUS; file_length: SmallInt;
        file_name: PISC_SCHAR; public_handle: pisc_db_handle; dpb_length: SmallInt;
        dpb: PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_blob_info(status_vector: PISC_STATUS; isc_blob_handle:
        pisc_blob_handle; item_length: SmallInt; items: PISC_SCHAR; buffer_length:
        SmallInt; buffer: PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_create_database(status_vector: PISC_STATUS; fileLength:
        Word; filename: PISC_SCHAR; publicHandle: pisc_db_handle; dpbLength: Word;
        dpb: PISC_SCHAR; db_type: Word): Integer; stdcall;
    function isc_close_blob(status_vector: PISC_STATUS; blob_handle:
        pisc_blob_handle): ISC_STATUS; stdcall;
    function isc_commit_transaction(status_vector: PISC_STATUS; tra_handle:
        pisc_tr_handle): ISC_STATUS; stdcall;
    function isc_create_blob(status_vector: PISC_STATUS; db_handle: pisc_db_handle;
        tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle; blob_id:
        PISC_QUAD): ISC_STATUS; stdcall;
    function isc_create_blob2(status_vector: PISC_STATUS; db_handle: pisc_db_handle;
        tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle; blob_id:
        PISC_QUAD; bpb_length: SmallInt; bpb: PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_database_info(status_vector: PISC_STATUS; db_handle: pisc_db_handle;
        info_len: SmallInt; info: PISC_SCHAR; res_len: SmallInt; res: PISC_SCHAR):
        ISC_STATUS; stdcall;
    procedure isc_decode_sql_date(date: PISC_DATE; times_arg: pointer); stdcall;
    procedure isc_decode_sql_time(sql_time: PISC_TIME; times_args: pointer); stdcall;
    procedure isc_decode_timestamp(date: PISC_TIMESTAMP; times_arg: pointer); stdcall;
    function isc_detach_database(status_vector: PISC_STATUS; public_handle:
        pisc_db_handle): ISC_STATUS; stdcall;
    function isc_drop_database(status_vector: PISC_STATUS; db_handle:
        pisc_db_handle): ISC_STATUS; stdcall;
    function isc_dsql_allocate_statement(status_vector: PISC_STATUS; db_handle:
        pisc_db_handle; stmt_handle: pisc_stmt_handle): ISC_STATUS; stdcall;
    function isc_dsql_alloc_statement2(status_vector: PISC_STATUS; db_handle:
        pisc_db_handle; stmt_handle: pisc_stmt_handle): ISC_STATUS; stdcall;
    function isc_dsql_describe(status_vector: PISC_STATUS; stmt_handle:
        pisc_stmt_handle; dialect: Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_describe_bind(status_vector: PISC_STATUS; stmt_handle:
        pisc_stmt_handle; dialect: Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_execute(status_vector: PISC_STATUS; tra_handle: pisc_tr_handle;
        stmt_handle: pisc_stmt_handle; dialect: Word; sqlda: PXSQLDA): ISC_STATUS;
        stdcall;
    function isc_dsql_execute2(status_vector: PISC_STATUS; tra_handle:
        pisc_tr_handle; stmt_handle: pisc_stmt_handle; dialect: Word; in_sqlda:
        PXSQLDA; out_sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_execute_immediate(status_vector: PISC_STATUS; db_handle:
        pisc_db_handle; tra_handle: pisc_tr_handle; length: Word; statement:
        PISC_SCHAR; dialect: Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_fetch(status_vector: PISC_STATUS; stmt_handle:
        pisc_stmt_handle; da_version: Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_free_statement(status_vector: PISC_STATUS; stmt_handle:
        pisc_stmt_handle; option: Word): ISC_STATUS; stdcall;
    function isc_dsql_prepare(status_vector: PISC_STATUS; tra_handle: pisc_tr_handle;
        stmt_handle: pisc_stmt_handle; length: Word; str: PISC_SCHAR; dialect:
        Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_set_cursor_name(status_vector: PISC_STATUS; stmt_handle:
        pisc_stmt_handle; cursor_name: PISC_SCHAR; reserve: Word): ISC_STATUS;
        stdcall;
    function isc_dsql_sql_info(status_vector: PISC_STATUS; stmt_handle:
        pisc_stmt_handle; items_len: SmallInt; items: PISC_SCHAR; buffer_len:
        SmallInt; buffer: PISC_SCHAR): ISC_STATUS; stdcall;
    procedure isc_encode_sql_date(times_arg: pointer; date: PISC_DATE); stdcall;
    procedure isc_encode_sql_time(times_arg: pointer; isc_time: PISC_TIME); stdcall;
    procedure isc_encode_timestamp(times_arg: pointer; isc_time: PISC_TIMESTAMP); stdcall;
    function isc_get_segment(status_vector: PISC_STATUS; blob_handle:
        pisc_blob_handle; length: System.pWord; buffer_length: Word; buffer: PISC_SCHAR):
        ISC_STATUS; stdcall;
    function isc_interprete(buffer: PISC_SCHAR; status_vector: PPISC_STATUS):
        ISC_STATUS; stdcall;
    function isc_open_blob(status_vector: PISC_STATUS; db_handle: pisc_db_handle;
        tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle; blob_id:
        PISC_QUAD): ISC_STATUS; stdcall;
    function isc_open_blob2(status_vector: PISC_STATUS; db_handle: pisc_db_handle;
        tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle; blob_id:
        PISC_QUAD; bpb_length: ISC_USHORT; bpb: PISC_UCHAR): ISC_STATUS; stdcall;
    function isc_put_segment(status_vector: PISC_STATUS; blob_handle:
        pisc_blob_handle; buffer_length: Word; buffer: PISC_SCHAR): ISC_STATUS;
        stdcall;
    function isc_rollback_transaction(status_vector: PISC_STATUS; tra_handle:
        pisc_tr_handle): ISC_STATUS; stdcall;
    function isc_service_attach(status_vector: PISC_STATUS; service_length: Word;
        service: PISC_SCHAR; svc_handle: pisc_svc_handle; spb_length: Word; spb:
        PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_service_detach(status_vector: PISC_STATUS; svc_handle:
        pisc_svc_handle): ISC_STATUS; stdcall;
    function isc_service_query(status_vector: PISC_STATUS; svc_handle:
        pisc_svc_handle; reserved: pisc_resv_handle; send_spb_length: Word;
        send_spb: PISC_SCHAR; request_spb_length:Word; request_spb: PISC_SCHAR;
        buffer_length: Word; buffer: PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_service_start(status_vector: PISC_STATUS; svc_handle:
        pisc_svc_handle; reserved: pisc_resv_handle; spb_length: Word; spb:
        PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_sqlcode(status_vector: PISC_STATUS): ISC_LONG; stdcall;
    function isc_start_multiple(status_vector: PISC_STATUS; tra_handle:
        pisc_tr_handle; count: SmallInt; vec: pointer): ISC_STATUS; stdcall;
    function isc_vax_integer(buffer: PISC_SCHAR; len: SmallInt): ISC_LONG; stdcall;
  end;

  IFirebirdLibrary = interface(IFirebirdLibrary_DLL)
    ['{90A53F8C-2F1A-437C-A3CF-97D15D35E1C5}']
    function GetODS: Cardinal;
    function GetODS_Major: TFirebird_ODS_Major;
    function Loaded: Boolean;
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
    function isc_attach_database(status_vector: PISC_STATUS; file_length: SmallInt;
        file_name: PISC_SCHAR; public_handle: pisc_db_handle; dpb_length: SmallInt;
        dpb: PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_blob_info(status_vector: PISC_STATUS; isc_blob_handle:
        pisc_blob_handle; item_length: SmallInt; items: PISC_SCHAR; buffer_length:
        SmallInt; buffer: PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_close_blob(status_vector: PISC_STATUS; blob_handle:
        pisc_blob_handle): ISC_STATUS; stdcall;
    function isc_commit_transaction(status_vector: PISC_STATUS; tra_handle:
        pisc_tr_handle): ISC_STATUS; stdcall;
    function isc_create_blob(status_vector: PISC_STATUS; db_handle: pisc_db_handle;
        tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle; blob_id:
        PISC_QUAD): ISC_STATUS; stdcall;
    function isc_create_blob2(status_vector: PISC_STATUS; db_handle:
        pisc_db_handle; tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle;
        blob_id: PISC_QUAD; bpb_length: SmallInt; bpb: PISC_SCHAR): ISC_STATUS;
        stdcall;
    function isc_create_database(status_vector: PISC_STATUS; fileLength:
        Word; filename: PISC_SCHAR; publicHandle: pisc_db_handle; dpbLength: Word;
        dpb: PISC_SCHAR; db_type: Word): Integer; stdcall;
    function isc_database_info(status_vector: PISC_STATUS; db_handle:
        pisc_db_handle; info_len: SmallInt; info: PISC_SCHAR; res_len: SmallInt;
        res: PISC_SCHAR): ISC_STATUS; stdcall;
    procedure isc_decode_sql_date(date: PISC_DATE; times_arg: pointer); stdcall;
    procedure isc_decode_sql_time(sql_time: PISC_TIME; times_args: pointer); stdcall;
    procedure isc_decode_timestamp(date: PISC_TIMESTAMP; times_arg: pointer); stdcall;
    function isc_detach_database(status_vector: PISC_STATUS; public_handle:
        pisc_db_handle): ISC_STATUS; stdcall;
    function isc_drop_database(status_vector: PISC_STATUS; db_handle:
        pisc_db_handle): ISC_STATUS; stdcall;
    function isc_dsql_allocate_statement(status_vector: PISC_STATUS; db_handle:
        pisc_db_handle; stmt_handle: pisc_stmt_handle): ISC_STATUS; stdcall;
    function isc_dsql_alloc_statement2(status_vector: PISC_STATUS; db_handle:
        pisc_db_handle; stmt_handle: pisc_stmt_handle): ISC_STATUS; stdcall;
    function isc_dsql_describe(status_vector: PISC_STATUS; stmt_handle:
        pisc_stmt_handle; dialect: Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_describe_bind(status_vector: PISC_STATUS; stmt_handle:
        pisc_stmt_handle; dialect: Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_execute(status_vector: PISC_STATUS; tra_handle:
        pisc_tr_handle; stmt_handle: pisc_stmt_handle; dialect: Word; sqlda:
        PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_execute2(status_vector: PISC_STATUS; tra_handle:
        pisc_tr_handle; stmt_handle: pisc_stmt_handle; dialect: Word; in_sqlda:
        PXSQLDA; out_sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_execute_immediate(status_vector: PISC_STATUS; db_handle:
        pisc_db_handle; tra_handle: pisc_tr_handle; length: Word; statement:
        PISC_SCHAR; dialect: Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_fetch(status_vector: PISC_STATUS; stmt_handle:
        pisc_stmt_handle; da_version: Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_free_statement(status_vector: PISC_STATUS; stmt_handle:
        pisc_stmt_handle; option: Word): ISC_STATUS; stdcall;
    function isc_dsql_prepare(status_vector: PISC_STATUS; tra_handle:
        pisc_tr_handle; stmt_handle: pisc_stmt_handle; length: Word; str:
        PISC_SCHAR; dialect: Word; sqlda: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_set_cursor_name(status_vector: PISC_STATUS; stmt_handle:
        pisc_stmt_handle; cursor_name: PISC_SCHAR; reserve: Word): ISC_STATUS;
        stdcall;
    function isc_dsql_sql_info(status_vector: PISC_STATUS; stmt_handle:
        pisc_stmt_handle; items_len: SmallInt; items: PISC_SCHAR; buffer_len:
        SmallInt; buffer: PISC_SCHAR): ISC_STATUS; stdcall;
    procedure isc_encode_sql_date(times_arg: pointer; date: PISC_DATE); stdcall;
    procedure isc_encode_sql_time(times_arg: pointer; isc_time: PISC_TIME); stdcall;
    procedure isc_encode_timestamp(times_arg: pointer; isc_time: PISC_TIMESTAMP); stdcall;
    function isc_get_segment(status_vector: PISC_STATUS; blob_handle:
        pisc_blob_handle; length: System.pWord; buffer_length: Word; buffer: PISC_SCHAR):
        ISC_STATUS; stdcall;
    function isc_interprete(buffer: PISC_SCHAR; status_vector: PPISC_STATUS):
        ISC_STATUS; stdcall;
    function isc_open_blob(status_vector: PISC_STATUS; db_handle: pisc_db_handle;
        tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle; blob_id:
        PISC_QUAD): ISC_STATUS; stdcall;
    function isc_open_blob2(status_vector: PISC_STATUS; db_handle: pisc_db_handle;
        tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle; blob_id:
        PISC_QUAD; bpb_length: ISC_USHORT; bpb: PISC_UCHAR): ISC_STATUS; stdcall;
    function isc_put_segment(status_vector: PISC_STATUS; blob_handle:
        pisc_blob_handle; buffer_length: Word; buffer: PISC_SCHAR): ISC_STATUS;
        stdcall;
    function isc_rollback_transaction(status_vector: PISC_STATUS; tra_handle:
        pisc_tr_handle): ISC_STATUS; stdcall;
    function isc_service_attach(status_vector: PISC_STATUS; service_length: Word;
        service: PISC_SCHAR; svc_handle: pisc_svc_handle; spb_length: Word; spb:
        PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_service_detach(status_vector: PISC_STATUS; svc_handle:
        pisc_svc_handle): ISC_STATUS; stdcall;
    function isc_service_query(status_vector: PISC_STATUS; svc_handle:
        pisc_svc_handle; reserved: pisc_resv_handle; send_spb_length: Word;
        send_spb: PISC_SCHAR; request_spb_length:Word; request_spb: PISC_SCHAR;
        buffer_length: Word; buffer: PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_service_start(status_vector: PISC_STATUS; svc_handle:
        pisc_svc_handle; reserved: pisc_resv_handle; spb_length: Word; spb:
        PISC_SCHAR): ISC_STATUS; stdcall;
    function isc_sqlcode(status_vector: PISC_STATUS): ISC_LONG; stdcall;
    function isc_start_multiple(status_vector: PISC_STATUS; tra_handle:
        pisc_tr_handle; count: SmallInt; vec: pointer): ISC_STATUS; stdcall;
    function isc_vax_integer(buffer: PISC_SCHAR; len: SmallInt): ISC_LONG; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
  protected // IFirebirdLibrary
    FHandle: THandle;
    FODS: Cardinal;
    function GetODS: Cardinal;
    function GetODS_Major: TFirebird_ODS_Major;
    function Loaded: Boolean;
    procedure SetupProcs;
  strict private
    constructor Create(aLibrary, aServerCharSet: string);
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
        ISC_STATUS): boolean;
    function CheckFirebirdError(out aErrorCode: ISC_STATUS): boolean;
    function GetError(const aFirebirdClient: IFirebirdLibrary): IFirebirdError;
    function GetLastError: IFirebirdError;
    function GetpValue: PISC_STATUS;
    function HasError: boolean;
    procedure SetError(Errors: TArray<ISC_STATUS> = nil);
    function Success: boolean;
    property pValue: PISC_STATUS read GetpValue;
  end;

  TStatusVector = class(TInterfacedObject, IStatusVector)
  private
    FError: IFirebirdError;
    FStatusVector: ISC_STATUS_ARRAY;
  protected
    procedure CheckAndRaiseError(const aFirebirdClient: IFirebirdLibrary);
    function CheckError(const aFirebirdClient: IFirebirdLibrary; out aErrorCode:
        ISC_STATUS): boolean;
    function CheckFirebirdError(out aErrorCode: ISC_STATUS): boolean;
    function GetError(const aFirebirdClient: IFirebirdLibrary): IFirebirdError;
    function GetLastError: IFirebirdError;
    function GetpValue: PISC_STATUS;
    function HasError: boolean;
    procedure SetError(Errors: TArray<ISC_STATUS> = nil);
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

function ExpandFileNameString(const aFileName: string): string;

implementation

uses
  Winapi.Winsock2, System.AnsiStrings, System.Generics.Defaults, System.IOUtils,
  System.Math, System.Net.URLClient, System.NetEncoding,
  Firebird.helper, firebird.burp.h, firebird.client.debug, firebird.constants.h,
  firebird.delphi, firebird.iberror.h, firebird.ods.h;

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

constructor TODS.Create(aMajor, aMinor: Word);
begin
  FValue := ENCODE_ODS(aMajor, aMinor);
end;

class function TODS.GetODS(aDatabaseFile: string): TODS;
var F: TStream;
    H: Ods_header_page;
begin
  F := TFileStream.Create(ExpandFileNameString(aDatabaseFile), fmOpenRead + fmShareDenyNone);
  try
    F.Read(H, SizeOf(H));
    Result := TODS.Create(H.hdr_ods_version xor $8000, H.hdr_ods_minor);
  finally
    F.Free;
  end;
end;

function TODS.Major: Word;
begin
  Result := FValue shr 4;
end;

function TODS.Minor: Word;
begin
  Result := FValue and $0F;
end;

function TODS.ToString: string;
begin
  Result := Self;
end;

class operator TODS.Equal(a: TODS; b: TODS): Boolean;
begin
  Result := a.FValue = b.FValue;
end;

class operator TODS.GreaterThan(a, b: TODS): Boolean;
begin
  Result := a.FValue > b.FValue;
end;

class operator TODS.GreaterThanOrEqual(a, b: TODS): Boolean;
begin
  Result := a.FValue >= b.FValue;
end;

class operator TODS.Implicit(v: Integer): TODS;
begin
  Result.FValue := v;
end;

class operator TODS.Implicit(o: string): TODS;
var A: TArray<string>;
    iMajor, iMinor: Word;
begin
  A := o.Split(['.']);
  iMajor := 0;
  iMinor := 0;
  if Length(A) > 0 then iMajor := A[0].ToInteger;
  if Length(A) > 1 then iMinor := A[1].ToInteger;
  Result := TODS.Create(iMajor, iMinor);
end;

class operator TODS.Implicit(o: TODS): string;
begin
  Result := string.Format('%d.%d', [o.Major, o.Minor]);
end;

class operator TODS.LessThan(a, b: TODS): Boolean;
begin
  Result := a.FValue < b.FValue;
end;

class operator TODS.LessThanOrEqual(a, b: TODS): Boolean;
begin
  Result := a.FValue <= b.FValue;
end;

class operator TODS.Implicit(o: TODS): Integer;
begin
  Result := o.FValue;
end;

class operator TODS.NotEqual(a: TODS; b: TODS): Boolean;
begin
  Result := a.FValue <> b.FValue;
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
end;

constructor TFirebirdLibrary.Create(aLibrary, aServerCharSet: string);
begin
  inherited Create;

  FProcs := TDictionary<Pointer,string>.Create;
  FDebugger := TFirebirdLibraryDebugger.Create;

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

function TFirebirdLibrary.isc_attach_database(status_vector: PISC_STATUS;
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

function TFirebirdLibrary.isc_blob_info(status_vector: PISC_STATUS;
    isc_blob_handle: pisc_blob_handle; item_length: SmallInt; items:
    PISC_SCHAR; buffer_length: SmallInt; buffer: PISC_SCHAR): ISC_STATUS;
begin
  Result := FIsc_blob_info(status_vector, isc_blob_handle, item_length, items, buffer_length, buffer);
  DebugMsg(@FIsc_blob_info, [status_vector, isc_blob_handle, item_length, items, buffer_length, buffer], Result);
end;

function TFirebirdLibrary.isc_close_blob(status_vector: PISC_STATUS;
    blob_handle: pisc_blob_handle): ISC_STATUS;
begin
  Result := Fisc_close_blob(status_vector, blob_handle);
  DebugMsg(@Fisc_close_blob, [status_vector, blob_handle], Result);
end;

function TFirebirdLibrary.isc_commit_transaction(status_vector: PISC_STATUS;
    tra_handle: pisc_tr_handle): ISC_STATUS;
var H: Integer;
begin
  H := PInteger(tra_handle)^;
  Result := Fisc_commit_transaction(status_vector, tra_handle);
  DebugMsg(@Fisc_commit_transaction, [status_vector, H], Result);
end;

function TFirebirdLibrary.isc_create_blob(status_vector: PISC_STATUS;
    db_handle: pisc_db_handle; tr_handle: pisc_tr_handle; blob_handle:
    pisc_blob_handle; blob_id: PISC_QUAD): ISC_STATUS;
begin
  Result := Fisc_create_blob(status_vector, db_handle, tr_handle, blob_handle, blob_id);
  DebugMsg(@Fisc_create_blob, [status_vector, db_handle, tr_handle, blob_handle, blob_id], Result);
end;

function TFirebirdLibrary.isc_create_blob2(status_vector: PISC_STATUS;
    db_handle: pisc_db_handle; tr_handle: pisc_tr_handle; blob_handle:
    pisc_blob_handle; blob_id: PISC_QUAD; bpb_length: SmallInt; bpb:
    PISC_SCHAR): ISC_STATUS;
begin
  Result := Fisc_create_blob2(status_vector, db_handle, tr_handle, blob_handle, blob_id, bpb_length, bpb);
  DebugMsg(@Fisc_create_blob2, [status_vector, db_handle, tr_handle, blob_handle, blob_id, bpb_length, bpb], Result);
end;

function TFirebirdLibrary.isc_create_database(
  status_vector: PISC_STATUS; fileLength: Word; filename: PISC_SCHAR;
  publicHandle: pisc_db_handle; dpbLength: Word; dpb: PISC_SCHAR;
  db_type: Word): Integer;
begin
  Result := Fisc_create_database(status_vector, fileLength, filename, publicHandle, dpbLength, dpb, db_type);
  DebugMsg(@Fisc_create_database, [status_vector, fileLength, filename, publicHandle, dpbLength, dpb, db_type], Result);
end;

function TFirebirdLibrary.isc_database_info(status_vector: PISC_STATUS;
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

function TFirebirdLibrary.isc_detach_database(status_vector: PISC_STATUS;
    public_handle: pisc_db_handle): ISC_STATUS;
begin
  Result := Fisc_detach_database(status_vector, public_handle);
  FODS := ODS_CURRENT_VERSION;
  DebugMsg(@Fisc_detach_database, [status_vector, public_handle], Result);
end;

function TFirebirdLibrary.isc_drop_database(status_vector: PISC_STATUS;
    db_handle: pisc_db_handle): ISC_STATUS;
begin
  Result := Fisc_drop_database(status_vector, db_handle);
  DebugMsg(@Fisc_drop_database, [status_vector, db_handle], Result);
end;

function TFirebirdLibrary.isc_dsql_allocate_statement(status_vector:
    PISC_STATUS; db_handle: pisc_db_handle; stmt_handle: pisc_stmt_handle):
    ISC_STATUS;
begin
  Result := Fisc_dsql_allocate_statement(status_vector, db_handle, stmt_handle);
  DebugMsg(@Fisc_dsql_allocate_statement, [status_vector, db_handle, stmt_handle], Result);
end;

function TFirebirdLibrary.isc_dsql_alloc_statement2(status_vector: PISC_STATUS;
    db_handle: pisc_db_handle; stmt_handle: pisc_stmt_handle): ISC_STATUS;
begin
  Result := Fisc_dsql_alloc_statement2(status_vector, db_handle, stmt_handle);
  DebugMsg(@Fisc_dsql_alloc_statement2, [status_vector, db_handle, stmt_handle], Result);
end;

function TFirebirdLibrary.isc_dsql_describe(status_vector: PISC_STATUS;
    stmt_handle: pisc_stmt_handle; dialect: Word; sqlda: PXSQLDA): ISC_STATUS;
begin
  Result := Fisc_dsql_describe(status_vector, stmt_handle, dialect, sqlda);
  DebugMsg(@Fisc_dsql_describe, [status_vector, stmt_handle, dialect, sqlda], Result);
end;

function TFirebirdLibrary.isc_dsql_describe_bind(status_vector: PISC_STATUS;
    stmt_handle: pisc_stmt_handle; dialect: Word; sqlda: PXSQLDA): ISC_STATUS;
begin
  Result := Fisc_dsql_describe_bind(status_vector, stmt_handle, dialect, sqlda);
  DebugMsg(@Fisc_dsql_describe_bind, [status_vector, stmt_handle, dialect, sqlda], Result);
end;

function TFirebirdLibrary.isc_dsql_execute(status_vector: PISC_STATUS;
    tra_handle: pisc_tr_handle; stmt_handle: pisc_stmt_handle; dialect: Word;
    sqlda: PXSQLDA): ISC_STATUS;
begin
  Result := Fisc_dsql_execute(status_vector, tra_handle, stmt_handle, dialect, sqlda);
  DebugMsg(@Fisc_dsql_execute, [status_vector, tra_handle, stmt_handle, dialect, sqlda], Result);
end;

function TFirebirdLibrary.isc_dsql_execute2(status_vector: PISC_STATUS;
    tra_handle: pisc_tr_handle; stmt_handle: pisc_stmt_handle; dialect: Word;
    in_sqlda: PXSQLDA; out_sqlda: PXSQLDA): ISC_STATUS;
begin
  Result := Fisc_dsql_execute2(status_vector, tra_handle, stmt_handle, dialect, in_sqlda, out_sqlda);
  DebugMsg(@Fisc_dsql_execute2, [status_vector, tra_handle, stmt_handle, dialect, in_sqlda, out_sqlda], Result);
end;

function TFirebirdLibrary.isc_dsql_execute_immediate(status_vector:
    PISC_STATUS; db_handle: pisc_db_handle; tra_handle: pisc_tr_handle; length:
    Word; statement: PISC_SCHAR; dialect: Word; sqlda: PXSQLDA): ISC_STATUS;
begin
  Result := Fisc_dsql_execute_immediate(status_vector, db_handle, tra_handle, length, statement, dialect, sqlda);
  DebugMsg(@Fisc_dsql_execute_immediate, [status_vector, db_handle, tra_handle, length, statement, dialect, sqlda], Result);
end;

function TFirebirdLibrary.isc_dsql_fetch(status_vector: PISC_STATUS;
    stmt_handle: pisc_stmt_handle; da_version: Word; sqlda: PXSQLDA):
    ISC_STATUS;
begin
  Result := Fisc_dsql_fetch(status_vector, stmt_handle, da_version, sqlda);
  DebugMsg(@Fisc_dsql_fetch, [status_vector, stmt_handle, da_version, sqlda], Result);
end;

function TFirebirdLibrary.isc_dsql_free_statement(status_vector: PISC_STATUS;
    stmt_handle: pisc_stmt_handle; option: Word): ISC_STATUS;
begin
  Result := Fisc_dsql_free_statement(status_vector, stmt_handle, option);
  DebugMsg(@Fisc_dsql_free_statement, [status_vector, stmt_handle, option], Result);
end;

function TFirebirdLibrary.isc_dsql_prepare(status_vector: PISC_STATUS;
    tra_handle: pisc_tr_handle; stmt_handle: pisc_stmt_handle; length: Word;
    str: PISC_SCHAR; dialect: Word; sqlda: PXSQLDA): ISC_STATUS;
begin
  Result := Fisc_dsql_prepare(status_vector, tra_handle, stmt_handle, length, str, dialect, sqlda);
  DebugMsg(@Fisc_dsql_prepare, [status_vector, tra_handle, stmt_handle, length, str, dialect, sqlda], Result);
end;

function TFirebirdLibrary.isc_dsql_set_cursor_name(status_vector: PISC_STATUS;
    stmt_handle: pisc_stmt_handle; cursor_name: PISC_SCHAR; reserve: Word):
    ISC_STATUS;
begin
  Result := Fisc_dsql_set_cursor_name(status_vector, stmt_handle, cursor_name, reserve);
  DebugMsg(@Fisc_dsql_set_cursor_name, [status_vector, stmt_handle, cursor_name, reserve], Result);
end;

function TFirebirdLibrary.isc_dsql_sql_info(status_vector: PISC_STATUS;
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

function TFirebirdLibrary.isc_get_segment(status_vector: PISC_STATUS;
    blob_handle: pisc_blob_handle; length: System.pWord; buffer_length: Word; buffer:
    PISC_SCHAR): ISC_STATUS;
begin
  Result := Fisc_get_segment(status_vector, blob_handle, length, buffer_length, buffer);
  DebugMsg(@Fisc_get_segment, [status_vector, blob_handle, length, buffer_length, buffer], Result);
end;

function TFirebirdLibrary.isc_interprete(buffer: PISC_SCHAR; status_vector:
    PPISC_STATUS): ISC_STATUS;
begin
  Result := Fisc_interprete(buffer, status_vector);
  DebugMsg(@Fisc_interprete, [buffer, status_vector], Result);
end;

function TFirebirdLibrary.isc_open_blob(status_vector: PISC_STATUS; db_handle:
    pisc_db_handle; tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle;
    blob_id: PISC_QUAD): ISC_STATUS;
begin
  Result := Fisc_open_blob(status_vector, db_handle, tr_handle, blob_handle, blob_id);
  DebugMsg(@Fisc_open_blob, [status_vector, db_handle, tr_handle, blob_handle, blob_id], Result);
end;

function TFirebirdLibrary.isc_open_blob2(status_vector: PISC_STATUS; db_handle:
    pisc_db_handle; tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle;
    blob_id: PISC_QUAD; bpb_length: ISC_USHORT; bpb: PISC_UCHAR): ISC_STATUS;
begin
  Result := Fisc_open_blob2(status_vector, db_handle, tr_handle, blob_handle, blob_id, bpb_length, bpb);
  DebugMsg(@Fisc_open_blob2, [status_vector, db_handle, tr_handle, blob_handle, blob_id, bpb_length, bpb], Result);
end;

function TFirebirdLibrary.isc_put_segment(status_vector: PISC_STATUS;
    blob_handle: pisc_blob_handle; buffer_length: Word; buffer: PISC_SCHAR):
    ISC_STATUS;
begin
  Result := Fisc_put_segment(status_vector, blob_handle, buffer_length, buffer);
  DebugMsg(@Fisc_put_segment, [status_vector, blob_handle, buffer_length, buffer], Result);
end;

function TFirebirdLibrary.isc_rollback_transaction(status_vector: PISC_STATUS;
    tra_handle: pisc_tr_handle): ISC_STATUS;
begin
  Result := Fisc_rollback_transaction(status_vector, tra_handle);
  DebugMsg(@Fisc_rollback_transaction, [status_vector, tra_handle], Result);
end;

function TFirebirdLibrary.isc_service_attach(status_vector: PISC_STATUS;
    service_length: Word; service: PISC_SCHAR; svc_handle: pisc_svc_handle;
    spb_length: Word; spb: PISC_SCHAR): ISC_STATUS;
begin
  Result := Fisc_service_attach(status_vector, service_length, service, svc_handle, spb_length, spb);
  DebugMsg(@Fisc_service_attach, [status_vector, service_length, service, svc_handle, spb_length, spb], Result);
end;

function TFirebirdLibrary.isc_service_detach(status_vector: PISC_STATUS;
    svc_handle: pisc_svc_handle): ISC_STATUS;
begin
  Result := Fisc_service_detach(status_vector, svc_handle);
  DebugMsg(@Fisc_service_detach, [status_vector, svc_handle], Result);
end;

function TFirebirdLibrary.isc_service_query(status_vector: PISC_STATUS;
    svc_handle: pisc_svc_handle; reserved: pisc_resv_handle; send_spb_length:
    Word; send_spb: PISC_SCHAR; request_spb_length:Word; request_spb:
    PISC_SCHAR; buffer_length: Word; buffer: PISC_SCHAR): ISC_STATUS;
begin
  Result := Fisc_service_query(status_vector, svc_handle, reserved, send_spb_length, send_spb, request_spb_length, request_spb, buffer_length, buffer);
  DebugMsg(@Fisc_service_query, [status_vector, svc_handle, reserved, send_spb_length, send_spb, request_spb_length, request_spb, buffer_length, buffer], Result);
end;

function TFirebirdLibrary.isc_service_start(status_vector: PISC_STATUS;
    svc_handle: pisc_svc_handle; reserved: pisc_resv_handle; spb_length: Word;
    spb: PISC_SCHAR): ISC_STATUS;
begin
  Result := Fisc_service_start(status_vector, svc_handle, reserved, spb_length, spb);
  DebugMsg(@Fisc_service_start, [status_vector, svc_handle, reserved, spb_length, spb], Result);
end;

function TFirebirdLibrary.isc_sqlcode(status_vector: PISC_STATUS): ISC_LONG;
begin
  Result := Fisc_sqlcode(status_vector);
  DebugMsg(@Fisc_sqlcode, [status_vector], Result);
end;

function TFirebirdLibrary.isc_start_multiple(status_vector: PISC_STATUS;
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

procedure TFirebirdLibrary.DebugMsg(const aProc: pointer; const aParams: array
    of const; aResult: ISC_STATUS);
begin
  if FDebugger.HasListener then
    FDebugger.Notify(GetDebugFactory.Get(FProcs[aProc], aProc, aParams, aResult));
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
    aErrorCode: ISC_STATUS): boolean;
begin
  aErrorCode := isc_arg_end;
  if HasError then
    aErrorCode := aFirebirdClient.isc_sqlcode(GetpValue);
  Result := aErrorCode <> isc_arg_end;
end;

function TStatusVector.CheckFirebirdError(out aErrorCode: ISC_STATUS): boolean;
begin
  aErrorCode := isc_arg_end;
  if HasError then
    aErrorCode := FStatusVector[1];
  Result := aErrorCode <> isc_arg_end;
end;

function TStatusVector.GetError(const aFirebirdClient: IFirebirdLibrary):
    IFirebirdError;
var P: array [0..1023] of AnsiChar;
    ptr: PISC_STATUS;
    sLastMsg, sError: string;
begin
  sError := '';
  ptr := GetpValue;
  while aFirebirdClient.isc_interprete(@P, @ptr) > 0 do begin
    sLastMsg := string({$if RtlVersion >= 20}System.AnsiStrings.{$ifend}StrPas(P));
    if not sError.IsEmpty then
      sError := sError + sLineBreak;
    sError := sError + sLastMsg;
  end;

  FError := nil;
  FError := TFirebirdError.Create(sError);
  Result := FError;
end;

function TStatusVector.GetpValue: PISC_STATUS;
begin
  Result := @FStatusVector;
end;

function TStatusVector.HasError: boolean;
begin
  Result := (FStatusVector[0] = isc_arg_gds) and (FStatusVector[1] > isc_arg_end);
end;

procedure TStatusVector.SetError(Errors: TArray<ISC_STATUS> = nil);
begin
  var i := 0;
  FStatusVector[i] := isc_arg_gds;
  Inc(i);
  for var E in Errors do begin
    FStatusVector[i] := E;
    Inc(i);
    if i = Length(FStatusVector) - 1 then
      Break;
  end;
  while i < Length(FStatusVector) do begin
    FStatusVector[i] := isc_arg_end;
    Inc(i);
  end;
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

function TFirebirdEngine.GetODS: TODS;
begin
  case FMajor of
    3: Result := ODS_12_0;
    4: Result := ODS_13_0;
    5: Result := ODS_13_1;
  else
    raise Exception.CreateFmt('Unsupported version %s', [GetVersion]);
  end;
end;

function TFirebirdEngine.GetPlatform: TOSVersion.TPlatform;
begin
  Result := FPlatform;
end;

class function TFirebirdEngine.GetProductVersion(const AValue: string; var
    APlatform: TOSVersion.TPlatform; var AMajor, AMinor, ARelease, ABuild:
    Integer): Boolean;
var
  FileName: string;
  InfoSize, Wnd: DWORD;
  VerBuf: Pointer;
  FI: PVSFixedFileInfo;
  VerSize: DWORD;
begin
  Result := False;
  // GetFileVersionInfo modifies the filename parameter data while parsing.
  // Copy the string const into a local variable to create a writeable copy.
  FileName := AValue;
  UniqueString(FileName);
  InfoSize := GetFileVersionInfoSize(PChar(FileName), Wnd);
  if InfoSize <> 0 then begin
    GetMem(VerBuf, InfoSize);
    try
      if GetFileVersionInfo(PChar(FileName), Wnd, InfoSize, VerBuf) then
        if VerQueryValue(VerBuf, '\', Pointer(FI), VerSize) then
        begin
          AMajor    := HiWord(FI.dwProductVersionMS);
          AMinor    := LoWord(FI.dwProductVersionMS);
          ARelease  := HiWord(FI.dwProductVersionLS);
          ABuild    := LoWord(FI.dwProductVersionLS);

          Result:= True;
        end;
    finally
      FreeMem(VerBuf);
    end;
  end else begin
    var p := AValue.Substring(0, 4).ToUpper;
    if p = 'WI-V' then
      APlatform := pfWindows
    else if p = 'LI-V' then
      APlatform := pfLinux;
    var i := p.Length;

    var j := AValue.IndexOf(' ', i);
    if j <> -1 then begin
      var v := AValue.Substring(i, j - i);

      var a := v.Split(['.']);
      if Length(a) = 4 then begin
        TryStrToInt(a[0], AMajor);
        TryStrToInt(a[1], AMinor);
        TryStrToInt(a[2], ARelease);
        TryStrToInt(a[3], ABuild);

        Result:= True;
      end;
    end;
  end;
end;

class operator TFirebirdEngine.Implicit(Value: string): TFirebirdEngine;
begin
  Result.FFileName := Value;
  if not GetProductVersion(Value, Result.FPlatform, Result.FMajor, Result.FMinor, Result.FRelease, Result.FBuild) then begin
    Result.FPlatform := pfWindows;
    Result.FMajor := 0;
    Result.FMinor := 0;
    Result.FRelease := 0;
    Result.FBuild := 0;
  end;
end;

function TFirebirdEngine.GetVersion: string;
begin
  Result := Format('%d.%d.%d.%d', [FMajor, FMinor, FRelease, FBuild]);
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

  Result := [];
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

    var b := True;
    for var s in A do begin
      var E: TFirebirdEngine := s;
      E.IsCurrent := b;
      if b then b := not b;
      FEngines := FEngines + [E];
    end;
  end;
end;

function TFirebirdEngines.GetEngineByProviders(aProviders: string; out aEngine:
    TFirebirdEngine): Boolean;
begin
  for var E in FEngines do begin
    if GetProviders(E) = aProviders then begin
      aEngine := E;
      Exit(True);
    end;
  end;
  Exit(False);
end;

function TFirebirdEngines.Get(aIndex: Integer): TFirebirdEngine;
begin
  Result := FEngines[aIndex];
end;

function TFirebirdEngines.GetEngineByODS(aODS: TODS;
  out aEngine: TFirebirdEngine): Boolean;
begin
  for var E in FEngines do begin
    if e.ODS = aODS then begin
      aEngine := E;
      Exit(True);
    end;
  end;
  Exit(False);
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

function TInfoValue<T>.Available: Boolean;
begin
  Result := FAvailable;
end;

class operator TInfoValue<T>.Implicit(a: TInfoValue<T>): T;
begin
  Result := a.FValue;
end;

procedure TInfoValue<T>.Clear;
begin
  FAvailable := False;
  FValue := Default(T);
end;

class operator TInfoValue<T>.Implicit(a: T): TInfoValue<T>;
begin
  Result := TInfoValue<T>.New(a);
end;

class operator TInfoValue<T>.Initialize(out Dest: TInfoValue<T>);
begin
  Dest.FAvailable := False;
end;

class function TInfoValue<T>.New(a: T): TInfoValue<T>;
begin
  Result.FAvailable := True;
  Result.FValue := a;
end;

function TQueryBuffer.AsPtr(i: UInt64 = 0): BytePtr;
begin
  Result := @FValues[i];
end;

procedure TQueryBuffer.SetSize(aSize: Word);
begin
  SetLength(FValues, aSize);
end;

function TQueryBuffer.Size: Integer;
begin
  Result := Length(FValues);
end;

class operator TQueryBuffer.Assign(var Dest: TQueryBuffer; const [ref] Src:
    TQueryBuffer);
begin
  raise Exception.Create('TQueryBuffer.Assign is not supported');
end;

function TQueryBuffer.Fetch(Reader: TQueryBufferReader; aSize: Word): Word;
begin
  Result := Reader(FValues[0], aSize);
end;

class operator TQueryBuffer.Initialize(out Dest: TQueryBuffer);
begin
  SetLength(Dest.FValues, DefaultSize);
end;

class function TDatabaseInfo.AsPtr: Pointer;
begin
  Result := @Items[0];
end;

function TDatabaseInfo.FileSize: UInt64;
begin
  Result := page_size * db_size_in_pages;
end;

function TDatabaseInfo.ODS: TODS;
begin
  Result := TODS.Create(ods_version, ods_minor_version);
end;

class function TDatabaseInfo.Size: Integer;
begin
  Result := Length(Items);
end;

class function TServiceManagerInfo.Items(aDBInfos: Boolean = False): TBytes;
begin
  Result := TBytes.Create(
      isc_info_svc_version
    , isc_info_svc_server_version
    , isc_info_svc_implementation
    , isc_info_svc_get_env
    );
  if aDBInfos then
    Result := Result + [isc_info_svc_svr_db_info];
end;

function TServiceManagerInfo.IsWindows: Boolean;
begin
  Result := svc_implementation.Contains('/Windows/');
end;

class constructor TServiceQueryInfo.Create;
begin
  eof := TServiceQueryInfo.New([isc_info_svc_to_eof]);
  line := TServiceQueryInfo.New([isc_info_svc_line]);
  restore := TServiceQueryInfo.New([isc_info_svc_stdin, isc_info_svc_to_eof]);
end;

class function TServiceQueryInfo.New(aTags: array of Byte): TServiceQueryInfo;
begin
  SetLength(Result.FTags, Length(aTags));
  Move(aTags[0], Result.FTags[0], Length(aTags));
end;

function TServiceQueryInfo.AsPtr: Pointer;
begin
  Result := @FTags[0];
end;

function TServiceQueryInfo.Size: Integer;
begin
  Result := Length(FTags);
end;

class function TPageSizeHelper.Create(const Value: Integer): TPageSize;
begin
  var i := Low(TPageSize);

  if Value <= i.ToInteger then Exit(i);
  Inc(i);

  while i <= High(TPageSize) do begin
    if Value = i.ToInteger then
      Break
    else if Value < i.ToInteger then begin
      Dec(i);
      Break;
    end;
    Inc(i);
  end;

  Result := i;
end;

class function TPageSizeHelper.Default: TPageSize;
begin
  Result := Create(DEFAULT_PAGE_SIZE);
end;

function TPageSizeHelper.ToInteger: Integer;
begin
  Result := DEFAULT_PAGE_SIZE;
  case Self of
    ps4096:    Result := 4096;
    ps8192:    Result := 8192;
    ps16384:   Result := 16384;
    ps32768:   Result := 32768;
  end;
end;

class function TFirebirdConnectionStringProtocolHelper.Get(V: string):
    TFirebirdConnectionStringProtocol;
begin
  for var p := Low(TFirebirdConnectionStringProtocol) to High(TFirebirdConnectionStringProtocol) do begin
    if p.ToString.IsEmpty then Continue;

    if V.StartsWith(p.ToString(True), True) then
      Exit(p)
  end;

  if V.IsEmpty then Exit(local);

  if TFile.Exists(V) then Exit(local);

  // Windows file name
  if IsValidWindowsFileName(v) then Exit(local);

  // Linux file name
  if V[1] = '/' then Exit(local);

  if V.IndexOf(':') = -1 then begin
    // detect Port delimiter
    if V.IndexOf('/') <> -1 then Exit(tcp_tra);

    var Hint: addrinfoW;
    FillChar(Hint, SizeOf(Hint), 0);
    var HostInfo: PaddrinfoW := nil;
    if GetAddrInfoW(PChar(v), nil, Hint, HostInfo) <> 0 then
      Exit(local);
  end;

  Exit(tcp_tra);
end;

class function TFirebirdConnectionStringProtocolHelper.IsValidWindowsFileName(
  aStr: string): Boolean;
begin
  Result := (aStr.Length >= 3)
        and CharInSet(aStr.Chars[0], ['A'..'Z', 'a'..'z']) // valid drive letter
        and (aStr.Chars[1] = ':')                          // drive letter URL_Delimiter
        and CharInSet(aStr.Chars[2], ['/', '\']);          // path URL_Delimiter
end;

function TFirebirdConnectionStringProtocolHelper.ToString(AppendDelimiter:
    Boolean = False): string;
begin
  Result := '';
  case Self of
    local:    Result := '';
    wnet_tra: Result := '\\';
    tcp_tra:  Result := '';
    xnet:     Result := 'xnet';
    wnet:     Result := 'wnet';
    inet:     Result := 'inet';
    inet4:    Result := 'inet4';
    inet6:    Result := 'inet6';
  end;
  if AppendDelimiter and (Self in [xnet..inet6]) then
    Result := Result + URL_Delimiter;
end;

class operator TFirebirdConnectionString.Implicit(
  a: string): TFirebirdConnectionString;
begin
  Result.SetValue(a);
end;

function TFirebirdConnectionString.AsServiceManager: string;
begin
  var o := Self;
  o.Database := TFirebird.service_mgr;
  Result := o;
end;

function TFirebirdConnectionString.GetValue: string;
begin
  if FProtocol = local then
    Exit(FDatabase);

  if FProtocol = wnet_tra then begin
    var s := FProtocol.ToString(True) + FHost;
    if not FDatabase.IsEmpty then
      s := s + '\' + FDatabase;
    Exit(s);
  end;

  if FProtocol = tcp_tra then begin
    var s := FHost;
    if not FPort.IsEmpty then
      s := s + '/' + FPort;
    if not FDatabase.IsEmpty then
      s := s + ':' + FDatabase;
    Exit(s);
  end;

  if FProtocol in [xnet, wnet, inet, inet4, inet6] then begin
    var s: TURI;
    s.Scheme := FProtocol.ToString;
    s.Host := FHost;
    if not FPort.IsEmpty then s.Port := 999999;  // Temporary place holder
    if not FDatabase.IsEmpty then begin
      s.Path := FDatabase;
      if FDatabase.StartsWith('/') then
        s.Path := '/' + s.Path;
    end;

    var r := TNetEncoding.URL.Decode(s.ToString).Replace(':999999', ':' + FPort);

    if r.StartsWith(xnet.ToString(True) + '/') then
      r := r.Replace(xnet.ToString(True) + '/', xnet.ToString(True));

    Exit(r);
  end;
end;

class operator TFirebirdConnectionString.Implicit(
  a: TFirebirdConnectionString): string;
begin
  Result := a.GetValue;
end;

procedure TFirebirdConnectionString.SetValue(v: string);
begin
  FProtocol := TFirebirdConnectionStringProtocol.Get(v);
  FPort := '';
  FHost := '';
  FDatabase := '';

  case FProtocol of
    local: FDatabase := v;

    wnet_tra: begin
      var L := wnet_tra.ToString.Length;
      var i := v.IndexOf('\', L);
      FHost := v.Substring(L, i - L);
      FDatabase := v.Substring(i + 1);
    end;

    tcp_tra: begin
      var iBracket := v.IndexOf(']');  // For IPv6 CIDR notation
      if iBracket < 0 then iBracket := 0;

      var iPortDelim := v.IndexOf('/', iBracket);
      var iPathDelim := v.IndexOf(':', iBracket);
      if (iPathDelim <> -1) and (iPathDelim < iPortDelim) then
        iPortDelim := -1;

      iPathDelim := v.IndexOf(':', Max(0, Max(iBracket, iPortDelim)));

      if (iPortDelim < 0) and (iPathDelim < 0) then
        FHost := v
      else if iPathDelim < 0 then begin
        FHost := v.Substring(0, iPortDelim);
        FPort := v.SubString(iPortDelim + 1);
      end else if iPortDelim < 0 then begin
        FHost := v.Substring(0, iPathDelim);
        FDatabase := v.SubString(iPathDelim + 1);
      end else begin
        FHost := v.Substring(0, iPortDelim);
        FPort := v.Substring(iPortDelim + 1, iPathDelim - iPortDelim - 1);
        FDatabase := v.SubString(iPathDelim + 1);
      end;
    end;

    xnet: FDatabase := v.Substring(xnet.ToString(True).Length);

    inet, inet4, inet6, wnet: begin
      var B := TURI.Create(v);
      Host := B.Host;
      if B.Port <> -1 then
        Port := B.Port.ToString;
      FDatabase := TNetEncoding.URL.Decode(B.Path);
      if FDatabase.StartsWith('/') then
        FDatabase := FDatabase.Remove(0, 1);
    end;
  end;
end;

class operator TFirebirdConnectionString.Initialize(out Dest:
    TFirebirdConnectionString);
begin
  Dest.FProtocol := local;
  Dest.FHost := '';
  Dest.FDatabase := '';
  Dest.FPort := '';
end;

function TBurpData.TBurpDataItemHelper.AsBoolean: Boolean;
begin
  Result := Boolean(AsUINT32);
end;

function TBurpData.TBurpDataItemHelper.AsString: string;
begin
  Result := TEncoding.ANSI.GetString(Self);
end;

function TBurpData.TBurpDataItemHelper.AsUINT32: UINT32;
begin
  Result := PUINT(Self)^;
end;

class operator TBurpData.Implicit(A: TStream): TBurpData;
begin
  Result.LoadFromStream(A);
end;

procedure TBurpData.LoadFromStream(S: TStream);
begin
  ZeroMemory(@Self, SizeOf(Self));

  var recTag, attTag, Len: Byte;
  while S.Read(recTag, SizeOf(recTag)) = SizeOf(recTag) do begin
    if not (recTag in [rec_burp, rec_physical_db]) then Exit;
    while (S.Read(attTag, SizeOf(attTag)) = SizeOf(attTag)) and (attTag <> att_end) do begin
      var D: TBurpDataItem;
      Assert(S.Read(Len, SizeOf(Len)) = SizeOf(Len));
      SetLength(D, Len);
      Assert(S.Read(D, Len) = Len);

      case recTag of
        rec_burp:
          case attTag of
            firebird.burp.h.att_type_att_backup_format: att_type_att_backup_format := D.AsUINT32;
            firebird.burp.h.att_backup_compress:        att_backup_compress        := D.AsBoolean;
            firebird.burp.h.att_backup_transportable:   att_backup_transportable   := D.AsBoolean;
            firebird.burp.h.att_backup_blksize:         att_backup_blksize         := D.AsUINT32;
            firebird.burp.h.att_backup_volume:          att_backup_volume          := D.AsUINT32;
            firebird.burp.h.att_backup_file:            att_backup_file            := D.AsString;
            firebird.burp.h.att_backup_date:            att_backup_date            := D.AsString;
            firebird.burp.h.att_backup_keyname:         att_backup_keyname         := D.AsString;
            firebird.burp.h.att_backup_zip:             att_backup_zip             := D.AsString;
            firebird.burp.h.att_backup_hash:            att_backup_hash            := D.AsString;
            firebird.burp.h.att_backup_crypt:           att_backup_crypt           := D.AsString;
          end;

        rec_physical_db:
          case attTag of
            firebird.burp.h.att_file_name:               att_file_name               := D.AsString;
            firebird.burp.h.att_file_size:               att_file_size               := D.AsUINT32;
            firebird.burp.h.att_jrd_version:             att_jrd_version             := D.AsUINT32;
            firebird.burp.h.att_creation_date:           att_creation_date           := D.AsString;
            firebird.burp.h.att_page_size:               att_page_size               := D.AsUINT32;
            firebird.burp.h.att_database_description:    att_database_description    := D.AsString;
            firebird.burp.h.att_database_security_class: att_database_security_class := D.AsString;
            firebird.burp.h.att_sweep_interval:          att_sweep_interval          := D.AsUINT32;
            firebird.burp.h.att_no_reserve:              att_no_reserve              := D.AsBoolean;
            firebird.burp.h.att_database_description2:   att_database_description2   := D.AsString;
            firebird.burp.h.att_database_dfl_charset:    att_database_dfl_charset    := D.AsString;
            firebird.burp.h.att_forced_writes:           att_forced_writes           := D.AsBoolean;
            firebird.burp.h.att_page_buffers:            att_page_buffers            := D.AsUINT32;
            firebird.burp.h.att_SQL_dialect:             att_SQL_dialect             := D.AsUINT32;
            firebird.burp.h.att_db_read_only:            att_db_read_only            := D.AsBoolean;
            firebird.burp.h.att_database_linger:         att_database_linger         := D.AsUINT32;
            firebird.burp.h.att_database_sql_security_deprecated: att_database_sql_security_deprecated := D.AsBoolean;
            firebird.burp.h.att_replica_mode:            att_replica_mode            := D.AsUINT32;
            firebird.burp.h.att_database_sql_security:   att_database_sql_security   := D.AsBoolean;
          end;
      end;
    end;
  end;
end;

class operator TFirebirdAPI.Assign(var Dest: TFirebirdAPI;
  const [ref] Src: TFirebirdAPI);
begin
  raise Exception.Create('TFirebirdAPI.Assign is not supported');
end;

function TFirebirdAPI.AttachDatabase(aExpectedDB: string = ''): IAttachment;
begin
  Fstatus.init;
  var x := util.getXpbBuilder(Fstatus, IXpbBuilder.DPB, nil, 0);
  try
    try
      if FUserName.Available then x.insertString(Fstatus, isc_dpb_user_name, FUserName);
      if FPassword.Available then x.insertString(Fstatus, isc_dpb_password, FPassword);
      if FProviders.Available then x.insertString(Fstatus, isc_dpb_config, FProviders);
      if FPageBuffers.Available then x.insertInt(Fstatus, isc_dpb_set_page_buffers, FPageBuffers);
      if FForcedWrite.Available then x.insertBytes(Fstatus, isc_dpb_force_write, @FForcedWrite.Value, SizeOf(FForcedWrite.Value));
      if not aExpectedDB.IsEmpty then x.insertString(Fstatus, isc_spb_expected_db, aExpectedDB);

      Result := prov.attachDatabase(Fstatus, FConnectionString, x.getBufferLength(Fstatus), x.getBuffer(Fstatus));
    finally
      x.dispose;
    end;
  except
    raise FirebirdException;
  end;
end;

function TFirebirdAPI.AttachServiceManager(aExpectedDB: string = ''): IService;
begin
  Fstatus.init;
  var x := util.getXpbBuilder(Fstatus, IXpbBuilder.SPB_ATTACH, nil, 0);
  try
    try
      if FUserName.Available then x.insertString(Fstatus, isc_dpb_user_name, FUserName);
      if FPassword.Available then x.insertString(Fstatus, isc_dpb_password, FPassword);
      if FProviders.Available then x.insertString(Fstatus, isc_spb_config, FProviders);
      if not aExpectedDB.IsEmpty then x.insertString(Fstatus, isc_spb_expected_db, aExpectedDB);

      Result := prov.attachServiceManager(Fstatus, FConnectionString.AsServiceManager, x.getBufferLength(Fstatus), x.getBuffer(Fstatus));
    finally
      x.dispose;
    end;
  except
    raise FirebirdException;
  end;
end;

procedure TFirebirdAPI.Backup(Process: TBackupInfoProcessor = nil; aBackupFile: string
    = stdout);
begin
  var a := AttachServiceManager(FConnectionString.Database);
  try
    try
      var x := util.getXpbBuilder(Fstatus, IXpbBuilder.SPB_START, nil, 0);
      try
        x.insertTag(Fstatus, isc_action_svc_backup);
        x.insertString(Fstatus, isc_spb_dbname, FConnectionString.Database);
        var sBackupFile := aBackupFile;
        if not SameText(aBackupFile, stdout) then
          x.insertTag(Fstatus, isc_spb_verbose);
        x.insertString(Fstatus, isc_spb_bkp_file, sBackupFile);
        if FParallelWorkers.Available then
          x.insertInt(FStatus, isc_spb_bkp_parallel_workers, FParallelWorkers);

        a.start(Fstatus, x.getBufferLength(Fstatus), x.getBuffer(Fstatus));
      finally
        x.dispose;
      end;

      var r: TQueryBuffer;
      var iDataSize: UInt64;
      var Info: TServiceQueryInfo;
      if aBackupFile <> stdout then r.SetSize(2000);  // Default 64K buffer size requires longer time to fill up and lead to unresponsive state
      repeat
        a.query(Fstatus, 0, nil, TServiceQueryInfo.eof.Size, TServiceQueryInfo.eof.AsPtr, r.Size, r.AsPtr);
        try
          x := util.getXpbBuilder(Fstatus, IXpbBuilder.SPB_RESPONSE, r.AsPtr, r.Size);
          iDataSize := x.Parse(Fstatus, function(Tag: Byte; Buf: IXpbBuilderBuffer; Len: UInt32): Uint32
          begin
            if (Len > 0) and Assigned(Process) then
              Process(Buf^, Len);
            Result := Len;
          end
          );
        finally
          x.dispose;
        end;
      until iDataSize = 0;
    finally
      a.detach(Fstatus);
      a.release;
    end;
  except
    raise FirebirdException;
  end;
end;

function TFirebirdAPI.CreateDatabase(aDummy: Integer): IAttachment;
begin
  Fstatus.init;
  var x := util.getXpbBuilder(Fstatus, IXpbBuilder.DPB, nil, 0);
  try
    try
      if FUserName.Available    then x.insertString(Fstatus, isc_dpb_user_name, FUserName);
      if FPassword.Available    then x.insertString(Fstatus, isc_dpb_password, FPassword);
      if FProviders.Available   then x.insertString(Fstatus, isc_dpb_config, FProviders);
      if FForcedWrite.Available then x.insertBytes(Fstatus, isc_dpb_force_write, @FForcedWrite.Value, SizeOf(FForcedWrite.Value));
      if FPageSize.Available    then x.insertInt(Fstatus, isc_dpb_page_size, FPageSize.Value.ToInteger);
      if FPageBuffers.Available then x.insertInt(Fstatus, isc_dpb_set_page_buffers, FPageBuffers);
      Result := prov.createDatabase(Fstatus, FConnectionString, x.getBufferLength(Fstatus), x.getBuffer(Fstatus));
    finally
      x.dispose;
    end;
  except
    raise FirebirdException;
  end;
end;

procedure TFirebirdAPI.CreateDatabase;
begin
  try
    CreateDatabase(0).detach(Fstatus);
  except
    raise FirebirdException;
  end;
end;

function TFirebirdAPI.FirebirdException: Exception;
begin
  var E := AcquireExceptionObject as Exception;
  if E is FbException then begin
    var M: TBytes;
    repeat
      SetLength(M, Length(M) + 256);
    until (util.formatStatus(@M[0], Length(M), (E as FbException).getStatus) < Cardinal(Length(M))) or (Length(M) >= 1024);
    E.Free;
    Result := Exception.Create(TEncoding.ANSI.GetString(M));
  end else
    Result := E;
end;

procedure TFirebirdAPI.DropDatabase;
begin
  try
    AttachDatabase.dropDatabase(Fstatus);
  except
    raise FirebirdException;
  end;
end;

function TFirebirdAPI.GetDatabaseInfo: TDatabaseInfo;
begin
  try
    var a := AttachDatabase;
    try
      var r: TQueryBuffer;
      a.getInfo(Fstatus, TDatabaseInfo.Size, TDatabaseInfo.AsPtr, r.Size, r.AsPtr);

      var x := util.getXpbBuilder(Fstatus, IXpbBuilder.INFO_RESPONSE, r.AsPtr, r.Size);
      try
        var Info: TDatabaseInfo;
        x.Parse(Fstatus, function(Tag: Byte; Buf: IXpbBuilderBuffer; Len: UInt32): UInt32
        begin
          case Tag of
            isc_info_page_size:         Info.page_size         := Buf.AsInt(Len);
            isc_info_num_buffers:       Info.num_buffers       := Buf.AsInt(Len);
            isc_info_ods_version:       Info.ods_version       := Buf.AsInt(Len);
            isc_info_ods_minor_version: Info.ods_minor_version := Buf.AsInt(Len);
            isc_info_db_sql_dialect:    Info.db_sql_dialect    := Buf.AsInt(Len);
            isc_info_sweep_interval:    Info.sweep_interval    := Buf.AsInt(Len);
            isc_info_db_read_only:      Info.db_read_only      := Boolean(Buf.AsInt(Len));
            isc_info_forced_writes:     Info.forced_writes     := Boolean(Buf.AsInt(Len));
            isc_info_creation_date:     Info.creation_date     := TimeStampToDateTime(ISC_TIMESTAMP(Buf.AsBigInt()));
            isc_info_db_size_in_pages:  Info.db_size_in_pages  := Buf.AsInt(Len);
            isc_info_current_memory:    Info.current_memory    := Buf.AsInt(Len);
            isc_info_max_memory:        Info.max_memory        := Buf.AsInt(Len);
            isc_info_firebird_version:  Info.firebird_version  := Buf.AsStringFromBytes;
            isc_info_isc_version:       Info.isc_version       := Buf.AsStringFromBytes;
          end;
          Result := Len;
        end
        );
        Result := Info;
      finally
        x.dispose;
      end;
    finally
      a.detach(Fstatus);
      a.release;
    end;
  except
    raise FirebirdException;
  end;
end;

function TFirebirdAPI.GetPlans(aSQLs: array of string): TArray<string>;
begin
  try
    var a := AttachDatabase;
    try
      var tpb := util.getXpbBuilder(Fstatus, IXpbBuilder.TPB, nil, 0);
      tpb.insertTag(Fstatus, isc_tpb_read);
      var t := a.startTransaction(Fstatus, tpb.getBufferLength(Fstatus), tpb.getBuffer(Fstatus));
      try
        for var s in aSQLs do begin
          var r := '';
          try
            var stmt := a.prepare(Fstatus.clone, t, s.Length, s, SQL_DIALECT_CURRENT, IStatement.PREPARE_PREFETCH_DETAILED_PLAN);
            try
              r := stmt.getPlan(Fstatus, true, 0);
            finally
              stmt.free(Fstatus);
            end;
          except
            on E: Exception do r := E.Message;
          end;
          Result := Result + [r.Trim];
        end;
      finally
        t.commit(Fstatus);
        tpb.dispose;
      end;
    finally
      a.detach(Fstatus);
      a.release;
    end;
  except
    raise FirebirdException;
  end;
end;

function TFirebirdAPI.GetServiceInfo(aDBInfos: Boolean): TServiceManagerInfo;
begin
  try
    var a := AttachServiceManager(FConnectionString.Database);
    try
      var r: TQueryBuffer;
      var N := TServiceManagerInfo.Items(aDBInfos);
      a.query(Fstatus, 0, nil, Length(N), @N[0], r.Size, r.AsPtr);

      var x := util.getXpbBuilder(Fstatus, IXpbBuilder.SPB_RESPONSE, r.AsPtr, r.Size);
      var _util := util;
      var _Fstatus := Fstatus;
      try
        var Info: TServiceManagerInfo;
        x.Parse(Fstatus, function(Tag: Byte; Buf: IXpbBuilderBuffer; Len: UInt32): UInt32
          begin
            case Tag of
              isc_info_svc_version:        Info.svc_version        := Buf.AsInt(Len);
              isc_info_svc_server_version: Info.svc_server_version := Buf.AsString(Len);
              isc_info_svc_implementation: Info.svc_implementation := Buf.AsString(Len);
              isc_info_svc_get_env:        Info.get_env            := Buf.AsString(Len);
              isc_info_svc_svr_db_info: begin
                var y := _util.getXpbBuilder(_Fstatus, IXpbBuilder.SPB_RESPONSE, Buf, r.Size);
                y.Parse(_Fstatus, function(yTag: Byte; yBuf: IXpbBuilderBuffer; yLen: UInt32): UInt32
                  begin
                    case yTag of
                      isc_spb_num_att: Info.num_att := yBuf.AsInt(yLen);
                      isc_spb_num_db:  Info.num_db  := yBuf.AsInt(yLen);
                      isc_spb_dbname:  Info.db_name := Info.db_name + [yBuf.AsString(yLen)];
                    end;
                    Result := yLen;
                  end
                , isc_info_flag_end
                );
              end;
            end;
            Result := Len;
          end
        );
        Result := Info;
      finally
        x.dispose;
      end;
    finally
      a.detach(Fstatus);
      a.release;
    end;
  except
    raise FirebirdException;
  end;
end;

class operator TFirebirdAPI.Initialize(out Dest: TFirebirdAPI);
begin
  Dest.FFBClient := 'fbclient.dll';
  Dest.FUserName := DBA_USER_NAME;
  Dest.FPassword := TFirebird.DefaultDBAPassword;
  Dest.FProviders.Clear;
  Dest.FParallelWorkers.Clear;
  Dest.FConnectionString := '';
  Dest.FPageSize.Clear;
  Dest.FForcedWrite.Clear;
  Dest.FPageBuffers.Clear;

  Dest.FHandle := 0;
end;

class function TFirebirdAPI.New(aFBClient: string): TFirebirdAPI;
begin
  Result.New(aFBClient, 0);
end;

function TFirebirdAPI.New(aFBClient: string; Dummy: Integer): PFirebirdAPI;
begin
  FFBClient := aFBClient;
  Fmaster := fb_get_master_interface(aFBClient, FHandle);
  Fstatus := Fmaster.getStatus;
  util := Fmaster.getUtilInterface;
  prov := Fmaster.getDispatcher;

  Result := @Self;
end;

procedure TFirebirdAPI.nBackup(aBackupFile: string; Process:
    TBackupInfoProcessor = nil; aBackupLevel: Integer = 0);
begin
  try
    var a := AttachServiceManager(FConnectionString.Database);
    try
      var x := util.getXpbBuilder(Fstatus, IXpbBuilder.SPB_START, nil, 0);
      try
        x.insertTag(Fstatus, isc_action_svc_nbak);
        x.insertString(Fstatus, isc_spb_dbname, FConnectionString.Database);
        x.insertString(Fstatus, isc_spb_nbk_file, aBackupFile);
        x.insertInt(Fstatus, isc_spb_nbk_level, aBackupLevel);

        a.start(Fstatus, x.getBufferLength(Fstatus), x.getBuffer(Fstatus));
      finally
        x.dispose;
      end;

      var iDataSize: UInt64;
      var r: TQueryBuffer;
      repeat
        a.query(Fstatus, 0, nil, TServiceQueryInfo.eof.Size, TServiceQueryInfo.eof.AsPtr, r.Size, r.AsPtr);
        x := util.getXpbBuilder(Fstatus, IXpbBuilder.SPB_RESPONSE, r.AsPtr, r.Size);
        try
          iDataSize := x.Parse(Fstatus, function(Tag: Byte; Buf: IXpbBuilderBuffer; Len: UInt32): UInt32
          begin
            if (Len > 0) and Assigned(Process) then
              Process(Buf^, Len);
            Result := Len;
          end
          );
        finally
          x.dispose;
        end;
      until iDataSize = 0;
    finally
      a.detach(Fstatus);
      a.release;
    end;
  except
    raise FirebirdException;
  end;
end;

function TFirebirdAPI.New(aFBClient: string; out aStatus: IStatus):
    PFirebirdAPI;
begin
  New(aFBClient, 0);
  aStatus := Fstatus;
  Result := @Self;
end;

procedure TFirebirdAPI.nFix(aBackupFile: string; Process: TBackupInfoProcessor
    = nil);
begin
  try
    var a := AttachServiceManager(FConnectionString.Database);
    try
      var x := util.getXpbBuilder(Fstatus, IXpbBuilder.SPB_START, nil, 0);
      try
        x.insertTag(Fstatus, isc_action_svc_nfix);
        x.insertString(Fstatus, isc_spb_dbname, aBackupFile);

        a.start(Fstatus, x.getBufferLength(Fstatus), x.getBuffer(Fstatus));
      finally
        x.dispose;
      end;
    finally
      a.detach(Fstatus);
      a.release;
    end;
  except
    raise FirebirdException;
  end;
end;

procedure TFirebirdAPI.nRestore(aBackupFiles: array of string; Process:
    TBackupInfoProcessor = nil);
begin
  try
    var a := AttachServiceManager(FConnectionString.Database);
    try
      var x := util.getXpbBuilder(Fstatus, IXpbBuilder.SPB_START, nil, 0);
      try
        x.insertTag(Fstatus, isc_action_svc_nrest);
        x.insertString(Fstatus, isc_spb_dbname, FConnectionString.Database);
        for var s in aBackupFiles do
          x.insertString(Fstatus, isc_spb_nbk_file, s);

        a.start(Fstatus, x.getBufferLength(Fstatus), x.getBuffer(Fstatus));
      finally
        x.dispose;
      end;

      var iDataSize: Int64;
      var r: TQueryBuffer;
      repeat
        a.query(Fstatus, 0, nil, TServiceQueryInfo.eof.Size, TServiceQueryInfo.eof.AsPtr, r.Size, r.AsPtr);
        x := util.getXpbBuilder(Fstatus, IXpbBuilder.SPB_RESPONSE, r.AsPtr, r.Size);
        try
          iDataSize := x.Parse(Fstatus, function(Tag: Byte; Buf: IXpbBuilderBuffer; Len: UInt32): UInt32
          begin
            if (Len > 0) and Assigned(Process) then
              Process(Buf^, Len);
            Result := Len;
          end
          );
        finally
          x.dispose;
        end;
      until iDataSize = 0;
    finally
      a.detach(Fstatus);
      a.release;
    end;
  except
    raise FirebirdException;
  end;
end;

function TFirebirdAPI.Reset: PFirebirdAPI;
begin
  FUserName := DBA_USER_NAME;
  FPassword := TFirebird.DefaultDBAPassword;

  FProviders.Clear;
  FConnectionString := '';

  FPageSize.Clear;
  FForcedWrite.Clear;
  FPageBuffers.Clear;
  FParallelWorkers.Clear;

  Result := @Self;
end;

procedure TFirebirdAPI.Restore(aBackupFile: string; Process:
    TBackupInfoProcessor = nil; Read: TBackupDataReader = nil);
begin
  try
    var a := AttachServiceManager;
    try
      var x := util.getXpbBuilder(Fstatus, IXpbBuilder.SPB_START, nil, 0);
      try
        x.insertTag(Fstatus, isc_action_svc_restore);
        x.insertTag(Fstatus, isc_spb_verbose);
        x.insertInt(Fstatus, isc_spb_options, isc_spb_res_create);
        x.insertString(Fstatus, isc_spb_dbname, FConnectionString.Database);
        x.insertString(Fstatus, isc_spb_bkp_file, aBackupFile);
        if FPageSize.Available    then x.insertInt(Fstatus, isc_spb_res_page_size, FPageSize.Value.ToInteger);
        if FPageBuffers.Available then x.insertInt(Fstatus, isc_spb_res_buffers, FPageBuffers);
        if FParallelWorkers.Available then
          x.insertInt(FStatus, TFirebird.isc_spb_res_parallel_workers, FParallelWorkers);
        a.start(Fstatus, x.getBufferLength(Fstatus), x.getBuffer(Fstatus));
      finally
        x.dispose;
      end;

      var r, sendBuf: TQueryBuffer;
      var send := util.getXpbBuilder(Fstatus, IXpbBuilder.SPB_SEND, nil, 0);
      try
        var iDataSize: UInt64;
        var iSendBufSize: Word := 0;
        repeat
          send.clear(Fstatus);
          if iSendBufSize > 0 then begin
            iSendBufSize := sendBuf.Fetch(Read, iSendBufSize);
            if iSendBufSize > 0 then
              send.insertBytes(Fstatus, isc_info_svc_line, sendBuf.AsPtr, iSendBufSize);
            iSendBufSize := 0;
          end;
          a.query(Fstatus, send.getBufferLength(Fstatus), send.getBuffer(Fstatus), TServiceQueryInfo.restore.Size, TServiceQueryInfo.restore.AsPtr, r.Size, r.AsPtr);
          x := util.getXpbBuilder(Fstatus, IXpbBuilder.SPB_RESPONSE, r.AsPtr, r.Size);
          try
            iDataSize := x.Parse(Fstatus, function(Tag: Byte; Buf: IXpbBuilderBuffer; Len: UInt32): UInt32
            begin
              case Tag of
                isc_info_svc_stdin: begin
                  iSendBufSize := Min(sendBuf.Size - SizeOf(Byte){isc_info_svc_line} - SizeOf(iSendBufSize){2 bytes}, Buf.AsInt(Len));
                  Result := iSendBufSize;
                end;
                isc_info_svc_to_eof: begin
                  if (Len > 0) and Assigned(Process) then
                    Process(Buf^, Len);
                  Result := Len;
                end;
                isc_info_truncated, isc_info_data_not_ready:
                  Result := 1; // Force return 1 to indicate more data on the way
                else
                  Result := Len;
              end;
            end
            );
          finally
            x.dispose;
          end;
        until iDataSize = 0;
      finally
        send.dispose;
      end;
    finally
      a.detach(Fstatus);
      a.release;
    end;
  except
    raise FirebirdException;
  end;
end;

procedure TFirebirdAPI.Restore(Read: TBackupDataReader = nil; Process:
    TBackupInfoProcessor = nil);
begin
  Restore(stdin, Process, Read);
end;

function TFirebirdAPI.SetConnectionString(aConnStr: string): PFirebirdAPI;
begin
  FConnectionString := AConnStr;
  Result := @Self;
end;

function TFirebirdAPI.SetConnectionString(aDatabase, aHost: string;
  aProtocol: TFirebirdConnectionStringProtocol): PFirebirdAPI;
begin
  FConnectionString := aDatabase;
  FConnectionString.Host := aHost;
  FConnectionString.Protocol := aProtocol;

  Result := @Self;
end;

function TFirebirdAPI.SetConnectionString(aDatabase, ProvidersOrHost: string):
    PFirebirdAPI;
begin
  if ProvidersOrHost.StartsWith(TFirebird.FB_Config_Providers, True) then begin
    FConnectionString.Database := aDatabase;
    SetProviders(ProvidersOrHost)
  end else if not ProvidersOrHost.IsEmpty then begin
    FConnectionString := ProvidersOrHost;
    if FConnectionString.Host = '' then begin
      FConnectionString.Host := ProvidersOrHost;
      FConnectionString.Protocol := tcp_tra;
    end;
    FConnectionString.Database := aDatabase;
  end;

  Result := @Self;
end;

function TFirebirdAPI.SetCredential(aUserName,
  aPassword: string): PFirebirdAPI;
begin
  if not aUserName.IsEmpty then FUserName := aUserName;
  if not aPassword.IsEmpty then FPassword := aPassword;

  Result := @Self;
end;

function TFirebirdAPI.SetForcedWrite(aValue: Boolean = True): PFirebirdAPI;
begin
  FForcedWrite := aValue;
  Result := @Self;
end;

function TFirebirdAPI.SetPageBuffers(aValue: Cardinal): PFirebirdAPI;
begin
  FPageBuffers := aValue;
  Result := @Self;
end;

function TFirebirdAPI.SetPageSize(aValue: TPageSize): PFirebirdAPI;
begin
  FPageSize := aValue;
  Result := @Self;
end;

function TFirebirdAPI.SetParallelWorkers(aValue: Integer): PFirebirdAPI;
begin
  FParallelWorkers := aValue;
  Result := @Self;
end;

procedure TFirebirdAPI.SetProperties;
begin
  try
    AttachDatabase.detach(Fstatus);
  except
    raise FirebirdException;
  end;
end;

function TFirebirdAPI.SetProviders(aProviders: string): PFirebirdAPI;
begin
  FProviders := aProviders;
  Result := @Self;
end;

var Data: WSAData;

initialization
  WSAStartup(WINSOCK_VERSION, Data);
finalization
  WSACleanup;
end.
