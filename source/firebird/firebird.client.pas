unit firebird.client;

interface

uses Windows, IB_Header, SysUtils, Classes;

type
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

  IFirebirdLibrary = interface(IInterface)
  ['{90A53F8C-2F1A-437C-A3CF-97D15D35E1C5}']
    function isc_attach_database(status: pstatus_vector; db_name_len: short;
        db_name: pchar; db_handle: pisc_db_handle; parm_buffer_len: short;
        parm_buffer: pchar): ISC_STATUS; stdcall;
    function isc_blob_info(status: pstatus_vector; BLOB_HANDLE: pisc_blob_handle;
        ItemBufLen: short; ItemBuffer: pchar; ResultBufLen: short; ResultBuffer:
        pchar): ISC_STATUS; stdcall;
    function isc_close_blob(status: pstatus_vector; blob_handle: pisc_blob_handle): ISC_STATUS; stdcall;
    function isc_commit_transaction(status: pstatus_vector; tr_handle:
        pisc_tr_handle): ISC_STATUS; stdcall;
    function isc_create_blob(status: pstatus_vector; db_handle: pisc_db_handle;
        tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle; blob_id:
        PISC_QUAD): ISC_STATUS; stdcall;
    function isc_create_blob2(status: pstatus_vector; db_handle: pisc_db_handle;
        tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle;
        blob_id: PISC_QUAD; e: short; f: pchar): ISC_STATUS; stdcall;
    function isc_database_info(status: pstatus_vector; a: pisc_db_handle; b: short;
        c: pchar; d: short; e: pchar): ISC_STATUS; stdcall;
    procedure isc_decode_sql_date(a: PISC_DATE; b: PISC_LONG);
    procedure isc_decode_sql_time(a: PISC_TIME; b: PISC_LONG);
    procedure isc_decode_timestamp(a: PISC_TIMESTAMP; b: PISC_LONG);
    function isc_detach_database(status: pstatus_vector; db_handle:
        pisc_db_handle): ISC_STATUS; stdcall;
    function isc_drop_database(status: pstatus_vector; db_handle: pisc_db_handle):
        ISC_STATUS; stdcall;
    function isc_dsql_allocate_statement(status: pstatus_vector; db_handle:
        pisc_db_handle; st_handle: pisc_stmt_handle): ISC_STATUS;
    function isc_dsql_alloc_statement2(status: pstatus_vector; a:	pisc_db_handle;
        b:	pisc_stmt_handle): ISC_STATUS; stdcall;
    function isc_dsql_describe(status_vector: pstatus_vector; st_handle:
        pisc_stmt_handle; dialect: word; params: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_describe_bind(status: pstatus_vector; st_handle:
        pisc_stmt_handle; dialect: word; params: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_execute(status: pstatus_vector; tr_handle: pisc_tr_handle;
        st_handle: pisc_stmt_handle; dialect: word; params: PXSQLDA): ISC_STATUS;
        stdcall;
    function isc_dsql_execute2(status: pstatus_vector; tr_handle: pisc_tr_handle;
        st_handle: pisc_stmt_handle; a: word; d: PXSQLDA; e: PXSQLDA): ISC_STATUS;
        stdcall;
    function isc_dsql_execute_immediate(status: pstatus_vector; db_handle:
        pisc_db_handle; tr_handle: pisc_tr_handle; length: word; statement: PChar;
        dialect: word; params: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_fetch(status_vector: pstatus_vector; st_handle:
        pisc_stmt_handle; dialect: word; fields: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_free_statement(status_vector: pstatus_vector; st_handle:
        pisc_stmt_handle; option: word): ISC_STATUS; stdcall;
    function isc_dsql_prepare(status: pstatus_vector; tr_handle: pisc_tr_handle;
        st_handle: pisc_stmt_handle; len: word; statement: pchar; dialect: word;
        params: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_set_cursor_name(status_vector: pstatus_vector; st_handle:
        pisc_stmt_handle; cursor_name: PChar; unusedType: word): ISC_STATUS;
        stdcall;
    function isc_dsql_sql_info(status: pstatus_vector; st_handle: pisc_stmt_handle;
        item_length: short; items: pchar; buffer_length: short; result_buffer:
        pchar): ISC_STATUS; stdcall;
    procedure isc_encode_sql_date(a: pointer; b: PISC_DATE);
    procedure isc_encode_sql_time(a: pointer; b: PISC_TIME);
    procedure isc_encode_timestamp(a: pointer; b: PISC_TIMESTAMP);
    function isc_get_segment(status: pstatus_vector; a: pisc_blob_handle;
        b: pword; c: word; d: pchar): ISC_STATUS; stdcall;
    function isc_interprete(buffer: PChar; status: ppstatus_vector): ISC_STATUS;
        stdcall;
    function isc_open_blob(status: pstatus_vector; a: pisc_db_handle; b:
        pisc_tr_handle; c: pisc_blob_handle; d: PISC_QUAD): ISC_STATUS; stdcall;
    function isc_open_blob2(status: pstatus_vector; a: pisc_db_handle; b: pisc_tr_handle;
        c: pisc_blob_handle; d: PISC_QUAD; e: short; g: pchar): ISC_STATUS; stdcall;
    function isc_put_segment( status: pstatus_vector; a: pisc_blob_handle; b: word;
        c: pchar): ISC_STATUS; stdcall;
    function isc_rollback_transaction(status: pstatus_vector; tr_handle:
        pisc_tr_handle): ISC_STATUS; stdcall;
    function isc_service_attach(status: pstatus_vector; svc_name_len: short;
        svc_name: pchar; svc_handle: pisc_svc_handle; parm_buffer_len: short;
        parm_buffer: pchar): ISC_STATUS; stdcall;
    function isc_service_detach(status: pstatus_vector; svc_handle:
        pisc_svc_handle): ISC_STATUS; stdcall;
    function isc_service_query(status: pstatus_vector; svc_handle: pisc_svc_handle;
        recv_handle: pisc_svc_handle; isc_arg4: short; isc_arg5: pchar; isc_arg6:
        short; isc_arg7: pchar; isc_arg8: short; isc_arg9: pchar): ISC_STATUS;
        stdcall;
    function isc_service_start(status: pstatus_vector; svc_handle: pisc_svc_handle;
        recv_handle: pisc_svc_handle; isc_arg4: short; isc_arg5: pchar):
        ISC_STATUS; stdcall;
    function isc_sqlcode(status: PISC_STATUS): ISC_LONG; stdcall;
    function isc_start_multiple(status: pstatus_vector; tr_handle: pisc_tr_handle;
        db_handle_count: short; teb_vector_address: pointer): ISC_STATUS; stdcall;
    function isc_vax_integer(a: pchar; b: short): ISC_LONG; stdcall;
    procedure Setup(const aHandle: THandle);
  end;

  TFirebirdLibrary = class(TInterfacedObject, IFirebirdLibrary)
  strict private
    FDebugFactory: IFirebirdLibraryDebugFactory;
    FDebugger: IFirebirdLibraryDebugger;
    FProcs: TStringList;
    function Call(const aProc: pointer; const aParams: array of const): ISC_STATUS;
    function GetProc(const aHandle: THandle; const aProcName: PAnsiChar): pointer;
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
  protected
    function isc_attach_database(status: pstatus_vector; db_name_len: short;
        db_name: pchar; db_handle: pisc_db_handle; parm_buffer_len: short;
        parm_buffer: pchar): ISC_STATUS; stdcall;
    function isc_blob_info(status: pstatus_vector; BLOB_HANDLE: pisc_blob_handle;
        ItemBufLen: short; ItemBuffer: pchar; ResultBufLen: short; ResultBuffer:
        pchar): ISC_STATUS; stdcall;
    function isc_close_blob(status: pstatus_vector; blob_handle: pisc_blob_handle): ISC_STATUS; stdcall;
    function isc_commit_transaction(status: pstatus_vector; tr_handle:
        pisc_tr_handle): ISC_STATUS; stdcall;
    function isc_create_blob(status: pstatus_vector; db_handle: pisc_db_handle;
        tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle; blob_id:
        PISC_QUAD): ISC_STATUS; stdcall;
    function isc_create_blob2(status: pstatus_vector; db_handle: pisc_db_handle;
        tr_handle: pisc_tr_handle; blob_handle: pisc_blob_handle;
        blob_id: PISC_QUAD; e: short; f: pchar): ISC_STATUS; stdcall;
    function isc_database_info(status: pstatus_vector; a: pisc_db_handle; b: short;
        c: pchar; d: short; e: pchar): ISC_STATUS; stdcall;
    procedure isc_decode_sql_date(a: PISC_DATE; b: PISC_LONG);
    procedure isc_decode_sql_time(a: PISC_TIME; b: PISC_LONG);
    procedure isc_decode_timestamp(a: PISC_TIMESTAMP; b: PISC_LONG);
    function isc_detach_database(status: pstatus_vector; db_handle:
        pisc_db_handle): ISC_STATUS; stdcall;
    function isc_drop_database(status: pstatus_vector; db_handle: pisc_db_handle):
        ISC_STATUS; stdcall;
    function isc_dsql_allocate_statement(status: pstatus_vector; db_handle:
        pisc_db_handle; st_handle: pisc_stmt_handle): ISC_STATUS;
    function isc_dsql_alloc_statement2(status: pstatus_vector; a:	pisc_db_handle;
        b:	pisc_stmt_handle): ISC_STATUS; stdcall;
    function isc_dsql_describe(status_vector: pstatus_vector; st_handle:
        pisc_stmt_handle; dialect: word; params: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_describe_bind(status: pstatus_vector; st_handle:
        pisc_stmt_handle; dialect: word; params: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_execute(status: pstatus_vector; tr_handle: pisc_tr_handle;
        st_handle: pisc_stmt_handle; dialect: word; params: PXSQLDA): ISC_STATUS;
        stdcall;
    function isc_dsql_execute2(status: pstatus_vector; tr_handle: pisc_tr_handle;
        st_handle: pisc_stmt_handle; a: word; d: PXSQLDA; e: PXSQLDA): ISC_STATUS;
        stdcall;
    function isc_dsql_execute_immediate(status: pstatus_vector; db_handle:
        pisc_db_handle; tr_handle: pisc_tr_handle; length: word; statement: PChar;
        dialect: word; params: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_fetch(status_vector: pstatus_vector; st_handle:
        pisc_stmt_handle; dialect: word; fields: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_free_statement(status_vector: pstatus_vector; st_handle:
        pisc_stmt_handle; option: word): ISC_STATUS; stdcall;
    function isc_dsql_prepare(status: pstatus_vector; tr_handle: pisc_tr_handle;
        st_handle: pisc_stmt_handle; len: word; statement: pchar; dialect: word;
        params: PXSQLDA): ISC_STATUS; stdcall;
    function isc_dsql_set_cursor_name(status_vector: pstatus_vector; st_handle:
        pisc_stmt_handle; cursor_name: PChar; unusedType: word): ISC_STATUS;
        stdcall;
    function isc_dsql_sql_info(status: pstatus_vector; st_handle: pisc_stmt_handle;
        item_length: short; items: pchar; buffer_length: short; result_buffer:
        pchar): ISC_STATUS; stdcall;
    procedure isc_encode_sql_date(a: pointer; b: PISC_DATE);
    procedure isc_encode_sql_time(a: pointer; b: PISC_TIME);
    procedure isc_encode_timestamp(a: pointer; b: PISC_TIMESTAMP);
    function isc_get_segment(status: pstatus_vector; a: pisc_blob_handle;
        b: pword; c: word; d: pchar): ISC_STATUS; stdcall;
    function isc_interprete(buffer: PChar; status: ppstatus_vector): ISC_STATUS;
        stdcall;
    function isc_open_blob(status: pstatus_vector; a: pisc_db_handle; b:
        pisc_tr_handle; c: pisc_blob_handle; d: PISC_QUAD): ISC_STATUS; stdcall;
    function isc_open_blob2(status: pstatus_vector; a: pisc_db_handle; b: pisc_tr_handle;
        c: pisc_blob_handle; d: PISC_QUAD; e: short; g: pchar): ISC_STATUS; stdcall;
    function isc_put_segment( status: pstatus_vector; a: pisc_blob_handle; b: word;
        c: pchar): ISC_STATUS; stdcall;
    function isc_rollback_transaction(status: pstatus_vector; tr_handle:
        pisc_tr_handle): ISC_STATUS; stdcall;
    function isc_service_attach(status: pstatus_vector; svc_name_len: short;
        svc_name: pchar; svc_handle: pisc_svc_handle; parm_buffer_len: short;
        parm_buffer: pchar): ISC_STATUS; stdcall;
    function isc_service_detach(status: pstatus_vector; svc_handle:
        pisc_svc_handle): ISC_STATUS; stdcall;
    function isc_service_query(status: pstatus_vector; svc_handle: pisc_svc_handle;
        recv_handle: pisc_svc_handle; isc_arg4: short; isc_arg5: pchar; isc_arg6:
        short; isc_arg7: pchar; isc_arg8: short; isc_arg9: pchar): ISC_STATUS;
        stdcall;
    function isc_service_start(status: pstatus_vector; svc_handle: pisc_svc_handle;
        recv_handle: pisc_svc_handle; isc_arg4: short; isc_arg5: pchar):
        ISC_STATUS; stdcall;
    function isc_sqlcode(status: PISC_STATUS): ISC_LONG; stdcall;
    function isc_start_multiple(status: pstatus_vector; tr_handle: pisc_tr_handle;
        db_handle_count: short; teb_vector_address: pointer): ISC_STATUS; stdcall;
    function isc_vax_integer(a: pchar; b: short): ISC_LONG; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    procedure Setup(const aHandle: THandle);
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

  TFirebirdLibrary2 = class(TFirebirdLibrary)
  private
    FHandle: THandle;
    FLibrary: string;
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
        longint): boolean;
    function CheckResult(out aResult: word; const aFailed_Result: word): Boolean; overload;
    function CheckResult(out aResult: longint; const aFailed_Result: longint):
        Boolean; overload;
    function GetError(const aFirebirdClient: IFirebirdLibrary): IFirebirdError;
    function GetLastError: IFirebirdError;
    function GetpValue: pstatus_vector;
    function HasError: boolean;
    function Success: boolean;
    property pValue: pstatus_vector read GetpValue;
  end;

  TStatusVector = class(TInterfacedObject, IStatusVector)
  private
    FError: IFirebirdError;
    FStatusVector: status_vector;
  protected
    procedure CheckAndRaiseError(const aFirebirdClient: IFirebirdLibrary);
    function CheckError(const aFirebirdClient: IFirebirdLibrary; out aErrorCode:
        longint): boolean;
    function CheckResult(out aResult: word; const aFailed_Result: word): Boolean; overload;
    function CheckResult(out aResult: longint; const aFailed_Result: longint):
        Boolean; overload;
    function GetError(const aFirebirdClient: IFirebirdLibrary): IFirebirdError;
    function GetLastError: IFirebirdError;
    function GetpValue: pstatus_vector;
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

implementation

uses firebird.client.debug;

procedure TFirebirdLibrary.AfterConstruction;
begin
  inherited;
  FProcs := TStringList.Create;
  FDebugger := TFirebirdLibraryDebugger.Create;
  FDebugFactory := TFirebirdClientDebugFactory.Create;
end;

procedure TFirebirdLibrary.BeforeDestruction;
begin
  inherited;
  FProcs.Free;
end;

function TFirebirdLibrary.Call(const aProc: pointer; const aParams: array of
    const): ISC_STATUS;
var i: integer;
    aInteger: integer;
    aPointer: pointer;
    aPChar: PChar;
    sDebug: PAnsiChar;
begin
  for i := High(aParams) downto Low(aParams) do begin
    case aParams[i].VType of
      vtInteger: begin
        aInteger := aParams[i].VInteger;
        asm
          push dword [aInteger];
        end;
      end;
      vtPointer: begin
        aPointer := aParams[i].VPointer;
        asm
          push dword [aPointer];
        end;
      end;
      vtPChar: begin
        aPChar := aParams[i].VPChar;
        asm
          push dword [aPChar];
        end;
      end
      else
        raise Exception.CreateFmt('Unsupported data type: %d', [aParams[i].VType]);
    end;
  end;

  asm
    call aProc;
    mov  [Result],eax;
  end;

  if FDebugger.HasListener then begin
    i := FProcs.IndexOfObject(aProc);
    Assert(i <> -1);
    sDebug := PAnsiChar(FDebugFactory.Get(FProcs[i], aProc, aParams, Result));
    FDebugger.Notify(sDebug);
  end;
end;

function TFirebirdLibrary.GetProc(const aHandle: THandle; const aProcName:
    PAnsiChar): pointer;
begin
  Result := GetProcAddress(aHandle, aProcName);
  FProcs.AddObject(aProcName, Result);
  if Result = nil then
    RaiseLastOSError;
end;

function TFirebirdLibrary.isc_attach_database(status: pstatus_vector;
  db_name_len: short; db_name: pchar; db_handle: pisc_db_handle;
  parm_buffer_len: short; parm_buffer: pchar): ISC_STATUS;
begin
  Result := Call(@Fisc_attach_database, [status, db_name_len, db_name, db_handle, parm_buffer_len, parm_buffer]);
end;

function TFirebirdLibrary.isc_blob_info(status: pstatus_vector;
  BLOB_HANDLE: pisc_blob_handle; ItemBufLen: short; ItemBuffer: pchar;
  ResultBufLen: short; ResultBuffer: pchar): ISC_STATUS;
begin
  Result := Call(@FIsc_blob_info, [status, BLOB_HANDLE, ItemBufLen, ItemBuffer, ResultBufLen, ResultBuffer]);
end;

function TFirebirdLibrary.isc_close_blob(status: pstatus_vector;
  blob_handle: pisc_blob_handle): ISC_STATUS;
begin
  Result := Call(@Fisc_close_blob, [status, blob_handle]);
end;

function TFirebirdLibrary.isc_commit_transaction(status: pstatus_vector;
  tr_handle: pisc_tr_handle): ISC_STATUS;
begin
  Result := Call(@Fisc_commit_transaction, [status, tr_handle]);
end;

function TFirebirdLibrary.isc_create_blob(status: pstatus_vector;
  db_handle: pisc_db_handle; tr_handle: pisc_tr_handle;
  blob_handle: pisc_blob_handle; blob_id: PISC_QUAD): ISC_STATUS;
begin
  Result := Call(@Fisc_create_blob, [status, db_handle, tr_handle, blob_handle, blob_id]);
end;

function TFirebirdLibrary.isc_create_blob2(status: pstatus_vector;
  db_handle: pisc_db_handle; tr_handle: pisc_tr_handle;
  blob_handle: pisc_blob_handle; blob_id: PISC_QUAD; e: short;
  f: pchar): ISC_STATUS;
begin
  Result := Call(@Fisc_create_blob2, [status, db_handle, tr_handle, blob_handle, blob_id, e, f]);
end;

function TFirebirdLibrary.isc_database_info(status: pstatus_vector;
  a: pisc_db_handle; b: short; c: pchar; d: short; e: pchar): ISC_STATUS;
begin
  Call(@Fisc_database_info, [status, a, b, c, d, e]);
end;

procedure TFirebirdLibrary.isc_decode_sql_date(a: PISC_DATE; b: PISC_LONG);
begin
  Call(@Fisc_decode_sql_date, [a, b]);
end;

procedure TFirebirdLibrary.isc_decode_sql_time(a: PISC_TIME; b: PISC_LONG);
begin
  Call(@Fisc_decode_sql_time, [a, b]);
end;

procedure TFirebirdLibrary.isc_decode_timestamp(a: PISC_TIMESTAMP;
  b: PISC_LONG);
begin
  Call(@Fisc_decode_timestamp, [a, b]);
end;

function TFirebirdLibrary.isc_detach_database(status: pstatus_vector;
  db_handle: pisc_db_handle): ISC_STATUS;
begin
  Result := Call(@Fisc_detach_database, [status, db_handle]);
end;

function TFirebirdLibrary.isc_drop_database(status: pstatus_vector; db_handle:
    pisc_db_handle): ISC_STATUS;
begin
  Result := Call(@Fisc_drop_database, [status, db_handle]);
end;

function TFirebirdLibrary.isc_dsql_allocate_statement(
  status: pstatus_vector; db_handle: pisc_db_handle;
  st_handle: pisc_stmt_handle): ISC_STATUS;
begin
  Result := Call(@Fisc_dsql_allocate_statement, [status, db_handle, st_handle]);
end;

function TFirebirdLibrary.isc_dsql_alloc_statement2(status: pstatus_vector;
  a: pisc_db_handle; b: pisc_stmt_handle): ISC_STATUS;
begin
  Result := Call(@Fisc_dsql_alloc_statement2, [status, a, b]);
end;

function TFirebirdLibrary.isc_dsql_describe(status_vector: pstatus_vector;
  st_handle: pisc_stmt_handle; dialect: word; params: PXSQLDA): ISC_STATUS;
begin
  Result := Call(@Fisc_dsql_describe, [status_vector, st_handle, dialect, params]);
end;

function TFirebirdLibrary.isc_dsql_describe_bind(status: pstatus_vector;
  st_handle: pisc_stmt_handle; dialect: word; params: PXSQLDA): ISC_STATUS;
begin
  Result := Call(@Fisc_dsql_describe_bind, [status, st_handle, dialect, params]);
end;

function TFirebirdLibrary.isc_dsql_execute(status: pstatus_vector;
  tr_handle: pisc_tr_handle; st_handle: pisc_stmt_handle; dialect: word;
  params: PXSQLDA): ISC_STATUS;
begin
  Result := Call(@Fisc_dsql_execute, [status, tr_handle, st_handle, dialect, params]);
end;

function TFirebirdLibrary.isc_dsql_execute2(status: pstatus_vector;
  tr_handle: pisc_tr_handle; st_handle: pisc_stmt_handle; a: word; d,
  e: PXSQLDA): ISC_STATUS;
begin
  Result := call(@Fisc_dsql_execute2, [status, tr_handle, st_handle, a, d, e]);
end;

function TFirebirdLibrary.isc_dsql_execute_immediate(status: pstatus_vector;
  db_handle: pisc_db_handle; tr_handle: pisc_tr_handle; length: word;
  statement: PChar; dialect: word; params: PXSQLDA): ISC_STATUS;
begin
  Result := Call(@Fisc_dsql_execute_immediate, [status, db_handle, tr_handle, length, statement, dialect, params]);
end;

function TFirebirdLibrary.isc_dsql_fetch(status_vector: pstatus_vector;
  st_handle: pisc_stmt_handle; dialect: word; fields: PXSQLDA): ISC_STATUS;
begin
  Result := Call(@Fisc_dsql_fetch, [status_vector, st_handle, dialect, fields]);
end;

function TFirebirdLibrary.isc_dsql_free_statement(
  status_vector: pstatus_vector; st_handle: pisc_stmt_handle;
  option: word): ISC_STATUS;
begin
  Result := call(@Fisc_dsql_free_statement, [status_vector, st_handle, option]);
end;

function TFirebirdLibrary.isc_dsql_prepare(status: pstatus_vector;
  tr_handle: pisc_tr_handle; st_handle: pisc_stmt_handle; len: word;
  statement: pchar; dialect: word; params: PXSQLDA): ISC_STATUS;
begin
  Result := Call(@Fisc_dsql_prepare, [status, tr_handle, st_handle, len, statement, dialect, params]);
end;

function TFirebirdLibrary.isc_dsql_set_cursor_name(
  status_vector: pstatus_vector; st_handle: pisc_stmt_handle;
  cursor_name: PChar; unusedType: word): ISC_STATUS;
begin
  Result := Call(@Fisc_dsql_set_cursor_name, [status_vector, st_handle, cursor_name, unusedType]);
end;

function TFirebirdLibrary.isc_dsql_sql_info(status: pstatus_vector;
  st_handle: pisc_stmt_handle; item_length: short; items: pchar;
  buffer_length: short; result_buffer: pchar): ISC_STATUS;
begin
  Result := Call(@Fisc_dsql_sql_info, [status, st_handle, item_length, items, buffer_length, result_buffer]);
end;

procedure TFirebirdLibrary.isc_encode_sql_date(a: pointer; b: PISC_DATE);
begin
  Call(@Fisc_encode_sql_date, [a, b]);
end;

procedure TFirebirdLibrary.isc_encode_sql_time(a: pointer; b: PISC_TIME);
begin
  Call(@Fisc_encode_sql_time, [a, b]);
end;

procedure TFirebirdLibrary.isc_encode_timestamp(a: pointer;
  b: PISC_TIMESTAMP);
begin
  Call(@Fisc_encode_timestamp, [a, b]);
end;

function TFirebirdLibrary.isc_get_segment(status: pstatus_vector;
  a: pisc_blob_handle; b: pword; c: word; d: pchar): ISC_STATUS;
begin
  Result := Call(@Fisc_get_segment, [status, a, b, c, d]);
end;

function TFirebirdLibrary.isc_interprete(buffer: PChar;
  status: ppstatus_vector): ISC_STATUS;
begin
  Result := Call(@Fisc_interprete, [buffer, status]);
end;

function TFirebirdLibrary.isc_open_blob(status: pstatus_vector;
  a: pisc_db_handle; b: pisc_tr_handle; c: pisc_blob_handle;
  d: PISC_QUAD): ISC_STATUS;
begin
  Result := Call(@Fisc_open_blob, [status, a, b, c, d]);
end;

function TFirebirdLibrary.isc_open_blob2(status: pstatus_vector;
  a: pisc_db_handle; b: pisc_tr_handle; c: pisc_blob_handle; d: PISC_QUAD;
  e: short; g: pchar): ISC_STATUS;
begin
  Result := Call(@Fisc_open_blob2, [status, a, b, c, d, e, g]);
end;

function TFirebirdLibrary.isc_put_segment(status: pstatus_vector;
  a: pisc_blob_handle; b: word; c: pchar): ISC_STATUS;
begin
  Result := Call(@Fisc_put_segment, [status, a, b, c]);
end;

function TFirebirdLibrary.isc_rollback_transaction(status: pstatus_vector;
  tr_handle: pisc_tr_handle): ISC_STATUS;
begin
  Result := Call(@Fisc_rollback_transaction, [status, tr_handle]);
end;

function TFirebirdLibrary.isc_service_attach(status: pstatus_vector;
  svc_name_len: short; svc_name: pchar; svc_handle: pisc_svc_handle;
  parm_buffer_len: short; parm_buffer: pchar): ISC_STATUS;
begin
  Result := Call(@Fisc_service_attach, [status, svc_name_len, svc_name, svc_handle, parm_buffer_len, parm_buffer]);
end;

function TFirebirdLibrary.isc_service_detach(status: pstatus_vector;
  svc_handle: pisc_svc_handle): ISC_STATUS;
begin
  Result := Call(@Fisc_service_detach, [status, svc_handle]);
end;

function TFirebirdLibrary.isc_service_query(status: pstatus_vector; svc_handle:
    pisc_svc_handle; recv_handle: pisc_svc_handle; isc_arg4: short; isc_arg5:
    pchar; isc_arg6: short; isc_arg7: pchar; isc_arg8: short; isc_arg9: pchar):
    ISC_STATUS;
begin
  Result := Call(@Fisc_service_query, [status, svc_handle, recv_handle, isc_arg4, isc_arg5, isc_arg6, isc_arg7, isc_arg8, isc_arg9]);
end;

function TFirebirdLibrary.isc_service_start(status: pstatus_vector;
  svc_handle, recv_handle: pisc_svc_handle; isc_arg4: short;
  isc_arg5: pchar): ISC_STATUS;
begin
  Result := Call(@Fisc_service_start, [status, svc_handle, recv_handle, isc_arg4, isc_arg5]);
end;

function TFirebirdLibrary.isc_sqlcode(status: PISC_STATUS): ISC_LONG;
begin
  Result := Call(@Fisc_sqlcode, [status]);
end;

function TFirebirdLibrary.isc_start_multiple(status: pstatus_vector;
  tr_handle: pisc_tr_handle; db_handle_count: short;
  teb_vector_address: pointer): ISC_STATUS;
begin
  Result := Call(@Fisc_start_multiple, [status, tr_handle, db_handle_count, teb_vector_address]);
end;

function TFirebirdLibrary.isc_vax_integer(a: pchar; b: short): ISC_LONG;
begin
  Result := Call(@Fisc_vax_integer, [a, b]);
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
    aErrorCode: longint): boolean;
begin
  aErrorCode := 0;
  if HasError then
    aErrorCode := aFirebirdClient.isc_sqlcode(PISC_STATUS(GetpValue));
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
var P: array [0..511] of char;
    ptr: pstatus_vector;
    sError: string;
begin
  sError := '';
  ptr := GetpValue;
  while aFirebirdClient.isc_interprete(P, @ptr) > 0 do
    sError := sError + P;

  FError := nil;
  FError := TFirebirdError.Create(sError);
  Result := FError;
end;

function TStatusVector.GetpValue: pstatus_vector;
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
var tpb: AnsiString;
    b: byte;
begin
  inherited Create;
  FClient := aFirebirdClient;

  FTransInfo := aTransInfo;

  tpb := char(isc_tpb_version3) + char(isc_tpb_concurrency) + char(isc_tpb_write);
  b := 0;
  case aTransInfo.Isolation of
    isoReadCommitted:  b := isc_tpb_read_committed;
    isoRepeatableRead: b := 0;
  end;
  if b <> 0 then
    tpb := tpb + char(b);
  tpb := tpb + char(isc_tpb_rec_version) + char(isc_tpb_nowait);

  FTransactionHandle := nil;
  FTransParam.db_ptr := aDBHandle;
  FTransParam.tpb_len := Length(tpb);
  FTransParam.tpb_ptr := PAnsiChar(tpb);
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
var sDir: string;
begin
  inherited;
  sDir := GetCurrentDir;
  SetCurrentDir(ExtractFilePath(FLibrary));
  try
    FHandle := LoadLibrary(PAnsiChar(FLibrary));
    if FHandle = 0 then
      raise Exception.CreateFmt('Unable to load %s', [FLibrary]);
    Setup(FHandle);
  finally
    SetCurrentDir(sDir);
  end;
end;

procedure TFirebirdLibrary2.BeforeDestruction;
begin
  inherited;
  FreeLibrary(FHandle);
end;

constructor TFirebirdLibrary2.Create(const aLibrary: string);
begin
  inherited Create;
  FLibrary := aLibrary;
end;

end.
