unit firebird.client;

interface

uses Windows, SysUtils, Classes,
     firebird.types_pub.h, firebird.sqlda_pub.h, firebird.ibase.h;

{$Message 'http://tracker.firebirdsql.org/browse/CORE-1745: Firebird Embedded DLL create fb_xxxx.LCK cause problem on multi connection in same project'}

type
  TFBIntType = {$if CompilerVersion<=18.5}Integer{$else}NativeInt{$ifend};

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
    procedure Add(const aListener: IFirebirdLibraryDebuggerListener);
    function HasListener: boolean;
    procedure Remove(const aListener: IFirebirdLibraryDebuggerListener);
    procedure Notify(const aDebugStr: string);
  end;

  IFirebirdLibraryDebugFactory = interface(IInterface)
  ['{2FDB8E26-BA3D-4091-A1B1-176DBA686A7B}']
    function Get(const aProcName: string; const aProc: pointer; const aParams:
        array of const; const aResult: longInt): string;
  end;

  TFirebirdLibraryDebugger = class(TInterfacedObject, IFirebirdLibraryDebugger)
  private
    FDebuggerListener: IInterfaceList;
    function GetDebuggerListener: IInterfaceList;
  protected
    procedure Add(const aListener: IFirebirdLibraryDebuggerListener);
    function HasListener: boolean;
    procedure Remove(const aListener: IFirebirdLibraryDebuggerListener);
    procedure Notify(const aDebugStr: string);
  end;
  {$endregion}

  IFirebirdLibrary_DLL = interface(IInterface)
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
    procedure Setup(const aHandle: THandle);
    function TryGetODSMajor(out aODS: integer): boolean;
  end;

  TFirebirdLibrary = class(TInterfacedObject, IFirebirdLibrary)
  strict private
    FDebugFactory: IFirebirdLibraryDebugFactory;
    FDebugger: IFirebirdLibraryDebugger;
    FProcs: TStringList;
    function GetDebugFactory: IFirebirdLibraryDebugFactory;
    function GetProc(const aHandle: THandle; const aProcName: PChar): pointer;
    procedure DebugMsg(const aProc: pointer; const aParams: array of const;
        aResult: ISC_STATUS);
  private
    Fisc_attach_database: Tisc_attach_database;
    Fisc_blob_info: Tisc_blob_info;
    Fisc_close_blob: Tisc_close_blob;
    Fisc_commit_transaction: Tisc_commit_transaction;
    Fisc_create_blob: Tisc_create_blob;
    Fisc_create_blob2: Tisc_create_blob2;
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
    FAttached_DB: pisc_db_handle;
    FODSMajor: integer;
    procedure Setup(const aHandle: THandle);
    function TryGetODSMajor(out aODS: integer): boolean;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

  isc_teb = record
    database: pisc_db_handle;
    tpb_len:  longint;
    tpb:      PISC_UCHAR;
  end;
  pisc_teb = ^isc_teb;

  TFirebirdLibrary2 = class(TFirebirdLibrary)
  private
    FHandle: THandle;
    FLibrary: string;
    FOldVars: IInterface;
  public
    constructor Create(const aLibrary: string);
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
  end;

  IFirebirdTransaction = interface(IInterface)
  ['{9BC18924-3D12-42F2-9A0A-9FE05FE6FB73}']
    function Active: boolean;
    function GetID: LongWord;
    function Start(aStatusVector: IStatusVector): ISC_STATUS;
    function Commit(const aStatusVector: IStatusVector): ISC_STATUS;
    function Rollback(const aStatusVector: IStatusVector): ISC_STATUS;
    function TransactionHandle: pisc_tr_handle;
    property ID: LongWord read GetID;
  end;

  TFirebirdTransaction = class(TInterfacedObject, IFirebirdTransaction)
  private
    FClient: IFirebirdLibrary;
    FTransactionHandle: isc_tr_handle;
    FTransParam: isc_teb;
    FTransInfo: TTransactionInfo;
    Fisc_tec: array[0..9] of ISC_UCHAR;
  protected
    function Active: boolean;
    function Start(aStatusVector: IStatusVector): ISC_STATUS;
    function Commit(const aStatusVector: IStatusVector): ISC_STATUS;
    function GetID: LongWord;
    function Rollback(const aStatusVector: IStatusVector): ISC_STATUS;
    function TransactionHandle: pisc_tr_handle;
  public
    constructor Create(const aFirebirdClient: IFirebirdLibrary; const aDBHandle:
        pisc_db_handle; const aTransInfo: TTransactionInfo);
  end;

  TFirebirdTransactionPool = class(TObject)
  private
    FDBHandle: pisc_db_handle;
    FFirebirdClient: IFirebirdLibrary;
    FItems: IInterfaceList;
  public
    constructor Create(const aFirebirdClient: IFirebirdLibrary; const aDBHandle:
        pisc_db_handle);
    function Add: IFirebirdTransaction; overload;
    function Add(const aTransInfo: TTransactionInfo): IFirebirdTransaction;
        overload;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    function Commit(const aStatusVector: IStatusVector; const aTransaction:
        IFirebirdTransaction): ISC_STATUS;
    function Count: integer;
    function CurrentTransaction: IFirebirdTransaction;
    function Get(const aTransID: LongWord): IFirebirdTransaction;
    function RollBack(const aStatusVector: IStatusVector; const aTransaction:
        IFirebirdTransaction): ISC_STATUS;
  end;

  TFirebirdLibraryFactory = class abstract
  public
    class function New(const aLibrary: string): IFirebirdLibrary; overload;
    class function New(const aHandle: THandle): IFirebirdLibrary; overload;
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

implementation

uses Math{$if RTLVersion >= 20}, AnsiStrings{$ifend}
     , firebird.inf_pub.h, firebird.consts_pub.h, firebird.client.debug;

procedure TFirebirdLibrary.AfterConstruction;
begin
  inherited;
  FProcs := TStringList.Create;
  FDebugger := TFirebirdLibraryDebugger.Create;
  FAttached_DB := nil;
  FODSMajor := -1;
end;

procedure TFirebirdLibrary.BeforeDestruction;
begin
  inherited;
  FProcs.Free;
end;

function TFirebirdLibrary.GetDebugFactory: IFirebirdLibraryDebugFactory;
begin
  if FDebugFactory = nil then
    FDebugFactory := TFirebirdClientDebugFactory.Create(IFirebirdLibrary(Self));
  Result := FDebugFactory;
end;

function TFirebirdLibrary.GetProc(const aHandle: THandle; const aProcName:
    PChar): pointer;
begin
  Result := GetProcAddress(aHandle, aProcName);
  FProcs.AddObject(aProcName, Result);
  if Result = nil then
    RaiseLastOSError;
end;

function TFirebirdLibrary.isc_attach_database(status_vector: PISC_STATUS_ARRAY;
    file_length: SmallInt; file_name: PISC_SCHAR; public_handle:
    pisc_db_handle; dpb_length: SmallInt; dpb: PISC_SCHAR): ISC_STATUS;
begin
  Result := Fisc_attach_database(status_vector, file_length, file_name, public_handle, dpb_length, dpb);
  FAttached_DB := public_handle;
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
begin
  Result := Fisc_commit_transaction(status_vector, tra_handle);
  DebugMsg(@Fisc_commit_transaction, [status_vector, tra_handle], Result);
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
  FAttached_DB := nil;
  FODSMajor := -1;
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

function TFirebirdLibrary.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if IsEqualGUID(IID, IFirebirdLibraryDebugger) then begin
    IFirebirdLibraryDebugger(Obj) := FDebugger;
    Result := S_OK;
  end else
    Result := inherited QueryInterface(IID, Obj);
end;

procedure TFirebirdLibrary.Setup(const aHandle: THandle);
begin
  Fisc_attach_database         := GetProc(aHandle, 'isc_attach_database');
  Fisc_blob_info               := GetProc(aHandle, 'isc_blob_info');
  Fisc_close_blob              := GetProc(aHandle, 'isc_close_blob');
  Fisc_commit_transaction      := GetProc(aHandle, 'isc_commit_transaction');
  Fisc_create_blob             := GetProc(aHandle, 'isc_create_blob');
  Fisc_create_blob2            := GetProc(aHandle, 'isc_create_blob2');
  Fisc_database_info           := GetProc(aHandle, 'isc_database_info');
  Fisc_decode_sql_date         := GetProc(aHandle, 'isc_decode_sql_date');
  Fisc_decode_sql_time         := GetProc(aHandle, 'isc_decode_sql_time');
  Fisc_decode_timestamp        := GetProc(aHandle, 'isc_decode_timestamp');
  Fisc_detach_database         := GetProc(aHandle, 'isc_detach_database');
  Fisc_drop_database           := GetProc(aHandle, 'isc_drop_database');
  Fisc_dsql_allocate_statement := GetProc(aHandle, 'isc_dsql_allocate_statement');
  Fisc_dsql_alloc_statement2   := GetProc(aHandle, 'isc_dsql_alloc_statement2');
  Fisc_dsql_describe           := GetProc(aHandle, 'isc_dsql_describe');
  Fisc_dsql_describe_bind      := GetProc(aHandle, 'isc_dsql_describe_bind');
  Fisc_dsql_execute            := GetProc(aHandle, 'isc_dsql_execute');
  Fisc_dsql_execute2           := GetProc(aHandle, 'isc_dsql_execute2');
  Fisc_dsql_execute_immediate  := GetProc(aHandle, 'isc_dsql_execute_immediate');
  Fisc_dsql_fetch              := GetProc(aHandle, 'isc_dsql_fetch');
  Fisc_dsql_free_statement     := GetProc(aHandle, 'isc_dsql_free_statement');
  Fisc_dsql_prepare            := GetProc(aHandle, 'isc_dsql_prepare');
  Fisc_dsql_set_cursor_name    := GetProc(aHandle, 'isc_dsql_set_cursor_name');
  Fisc_dsql_sql_info           := GetProc(aHandle, 'isc_dsql_sql_info');
  Fisc_encode_sql_date         := GetProc(aHandle, 'isc_encode_sql_date');
  Fisc_encode_sql_time         := GetProc(aHandle, 'isc_encode_sql_time');
  Fisc_encode_timestamp        := GetProc(aHandle, 'isc_encode_timestamp');
  Fisc_get_segment             := GetProc(aHandle, 'isc_get_segment');
  Fisc_interprete              := GetProc(aHandle, 'isc_interprete');
  Fisc_open_blob               := GetProc(aHandle, 'isc_open_blob');
  Fisc_open_blob2              := GetProc(aHandle, 'isc_open_blob2');
  Fisc_put_segment             := GetProc(aHandle, 'isc_put_segment');
  Fisc_rollback_transaction    := GetProc(aHandle, 'isc_rollback_transaction');
  Fisc_sqlcode                 := GetProc(aHandle, 'isc_sqlcode');
  Fisc_service_attach          := GetProc(aHandle, 'isc_service_attach');
  Fisc_service_detach          := GetProc(aHandle, 'isc_service_detach');
  Fisc_service_query           := GetProc(aHandle, 'isc_service_query');
  Fisc_service_start           := GetProc(aHandle, 'isc_service_start');
  Fisc_start_multiple          := GetProc(aHandle, 'isc_start_multiple');
  Fisc_vax_integer             := GetProc(aHandle, 'isc_vax_integer');
end;

function TFirebirdLibrary.TryGetODSMajor(out aODS: integer): boolean;
var _DatabaseInfoCommand: AnsiChar;
    local_buffer: array[0..511] of Byte;
    L: integer;
    V: IStatusVector;
begin
  if FODSMajor <> -1 then begin
    Result := True;
    aODS := FODSMajor;
    Exit;
  end;
  Result := False;
  if FAttached_DB = nil then Exit;

  V := TStatusVector.Create;
  _DatabaseInfoCommand := AnsiChar(isc_info_ods_version);
  isc_database_info(V.pValue, FAttached_DB, 1, @_DatabaseInfoCommand, SizeOf(local_buffer), @local_buffer);
  if V.Success then begin
    L := isc_vax_integer(@local_buffer[1], 2);
    FODSMajor := isc_vax_integer(@local_buffer[3], L);
    aODS := FODSMajor;
    Result := True;
  end;
end;

procedure TFirebirdLibrary.DebugMsg(const aProc: pointer; const aParams: array
    of const; aResult: ISC_STATUS);
begin
  if FDebugger.HasListener then
    FDebugger.Notify(GetDebugFactory.Get(FProcs[FProcs.IndexOfObject(aProc)], aProc, aParams, aResult));
end;

class function TFirebirdLibraryFactory.New(
  const aLibrary: string): IFirebirdLibrary;
begin
  Result := TFirebirdLibrary2.Create(aLibrary);
end;

class function TFirebirdLibraryFactory.New(
  const aHandle: THandle): IFirebirdLibrary;
var L: IFirebirdLibrary;
begin
  L := TFirebirdLibrary.Create;
  try
    L.Setup(aHandle);
  except
    L := nil;
  end;
  Result := L;
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
    sLastMsg := string({$if RtlVersion >= 20}AnsiStrings.{$ifend}StrPas(P));
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

{ TFirebirdClientDebugger }

procedure TFirebirdLibraryDebugger.Add(
  const aListener: IFirebirdLibraryDebuggerListener);
begin
  GetDebuggerListener.Add(aListener);
end;

function TFirebirdLibraryDebugger.GetDebuggerListener: IInterfaceList;
begin
  if FDebuggerListener = nil then
    FDebuggerListener := TInterfaceList.Create;
  Result := FDebuggerListener;
end;

function TFirebirdLibraryDebugger.HasListener: boolean;
begin
  Result := GetDebuggerListener.Count > 0;
end;

procedure TFirebirdLibraryDebugger.Notify(const aDebugStr: string);
var i: integer;
begin
  for i := 0 to GetDebuggerListener.Count - 1 do
    (GetDebuggerListener[i] as IFirebirdLibraryDebuggerListener).Update(aDebugStr);
end;

procedure TFirebirdLibraryDebugger.Remove(
  const aListener: IFirebirdLibraryDebuggerListener);
var i: integer;
begin
  i := GetDebuggerListener.IndexOf(aListener);
  GetDebuggerListener.Delete(i);
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
var i: integer;
    b: byte;
begin
  inherited Create;
  FClient := aFirebirdClient;

  FTransInfo := aTransInfo;

  i := 0;
  Fisc_tec[i] := isc_tpb_version3;
  Inc(i);

  Fisc_tec[i] := isc_tpb_write;
  Inc(i);

  b := 0;
  case aTransInfo.Isolation of
    isoReadCommitted:  b := isc_tpb_read_committed;
    isoRepeatableRead: b := isc_tpb_concurrency;
  end;
  if b <> 0 then begin
    Fisc_tec[i] := b;
    Inc(i);
  end;

  if aTransInfo.Isolation = isoReadCommitted then begin
    Fisc_tec[i] := isc_tpb_rec_version;
    Inc(i);

    Fisc_tec[i] := isc_tpb_nowait;
    Inc(i);
  end;

  FTransactionHandle := nil;
  FTransParam.database := aDBHandle;
  FTransParam.tpb_len := i;
  FTransParam.tpb := @Fisc_tec;
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

constructor TFirebirdTransactionPool.Create(
  const aFirebirdClient: IFirebirdLibrary; const aDBHandle: pisc_db_handle);
begin
  inherited Create;
  FFirebirdClient := aFirebirdClient;
  FDBHandle := aDBHandle;
end;

function TFirebirdTransactionPool.CurrentTransaction: IFirebirdTransaction;
begin
  if Count > 0 then
    Result := FItems[Count - 1] as IFirebirdTransaction
  else
    Result := nil;
end;

function TFirebirdTransactionPool.Add(const aTransInfo: TTransactionInfo):
    IFirebirdTransaction;
begin
  {$if CompilerVersion = 18}
  if Assigned(Get(aTransInfo.ID)) then
    raise ETransactionExist.CreateFmt('Transaction ID %d already exist', [aTransInfo.ID]);
  {$ifend}
  
  Result := TFirebirdTransaction.Create(FFirebirdClient, FDBHandle, aTransInfo);
  FItems.Add(Result);
end;

function TFirebirdTransactionPool.Add: IFirebirdTransaction;
var T: TTransactionInfo;
begin
  T.ID := 0;
  T.Isolation := isoReadCommitted;
  Result := Add(T);
end;

procedure TFirebirdTransactionPool.AfterConstruction;
begin
  inherited;
  FItems := TInterfaceList.Create;
end;

procedure TFirebirdTransactionPool.BeforeDestruction;
var i: integer;
    S: IStatusVector;
    N: IFirebirdTransaction;
begin
  inherited;
  if Count > 0 then begin
    S := TStatusVector.Create;
    for i := Count - 1 downto 0 do begin
      N := FItems[i] as IFirebirdTransaction;
      if N.Active then
        N.Rollback(S);
      FItems.Delete(i);
      N := nil;
    end;
  end;
end;

function TFirebirdTransactionPool.Commit(const aStatusVector: IStatusVector;
    const aTransaction: IFirebirdTransaction): ISC_STATUS;
var i: integer;
begin
  Result := aTransaction.Commit(aStatusVector);
  i := FItems.IndexOf(aTransaction);
  Assert(i >= 0);
  FItems.Delete(i);
end;

function TFirebirdTransactionPool.Count: integer;
begin
  Result := FItems.Count;
end;

function TFirebirdTransactionPool.Get(const aTransID: LongWord):
    IFirebirdTransaction;
var i: integer;
    N: IFirebirdTransaction;
begin
  {$if CompilerVersion > 18} Assert(False, 'For DBX3 Only'); {$ifend}
  Result := nil;
  for i := 0 to Count - 1 do begin
    N := FItems[i] as IFirebirdTransaction;
    if N.ID = aTransID then begin
      Result := N;
      Break;
    end;
  end;
end;

function TFirebirdTransactionPool.RollBack(const aStatusVector: IStatusVector;
    const aTransaction: IFirebirdTransaction): ISC_STATUS;
var i: integer;
begin
  Result := aTransaction.Rollback(aStatusVector);
  i := FItems.IndexOf(aTransaction);
  Assert(i >= 0);
  FItems.Delete(i);
end;

procedure TFirebirdLibrary2.AfterConstruction;
var sPath, sDir: string;
begin
  inherited;
  sPath := ExtractFilePath(FLibrary);
  FOldVars := TFirebirdLibraryRootPath.Create(sPath);

  sDir := GetCurrentDir;
  try
    SetCurrentDir(sPath);
    FHandle := LoadLibrary(PChar(FLibrary));
    if FHandle = 0 then
      raise Exception.CreateFmt('Unable to load %s', [FLibrary]);
    Setup(FHandle);
  finally
    SetCurrentDir(sDir);
  end;
end;

procedure TFirebirdLibrary2.BeforeDestruction;
var s: string;
    h: THandle;
begin
  inherited;
  if not FreeLibrary(FHandle) then
    RaiseLastOSError;

  // Check if the FLibrary still in used, otherwise attempt to free library fbintl.dll
  h := GetModuleHandle(PChar(FLibrary));
  if h = 0 then begin
    {$Message 'Firebird bug: http://tracker.firebirdsql.org/browse/CORE-2186'}
    // In Firebird version 2.X, when execute function isc_dsql_execute_immediate for CREATE DATABASE
    // intl/fbintl.dll will be loaded and never free.  The following code attempt to free the fbintl.dll library
    s := ExtractFilePath(FLibrary) + 'intl\fbintl.dll';
    h := GetModuleHandle(PChar(s));
    if h <> 0 then
      FreeLibrary(h);
  end;
end;

constructor TFirebirdLibrary2.Create(const aLibrary: string);
begin
  inherited Create;
  FLibrary := aLibrary;
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
begin
  i := GetLength;
  S := Copy(aValue, 0, Min(High(Byte), Length(aValue)));
  AddByte(Length(S));
  IncSize(Length(S));
  Inc(i, SizeOf(Byte));
  Move(PAnsiChar(AnsiString(S))^, FParams[i], Length(S));
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
begin
  i := GetLength;
  S := Copy(aValue, 0, Min(High(SmallInt), Length(aValue)));
  AddSmallInt(Length(S));
  IncSize(Length(S));
  Inc(i, SizeOf(SmallInt));
  Move(PAnsiChar(AnsiString(S))^, FParams[i], Length(S));
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

end.
