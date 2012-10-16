unit firebird.dsql;

interface

uses SysUtils, Classes, Windows, FmtBcd, SqlTimSt,
     firebird.sqlda_pub.h, firebird.ibase.h, firebird.types_pub.h, firebird.iberror.h,
     firebird.inf_pub.h, firebird.time.h, firebird.charsets,
     firebird.client;

const
  CharSetBytes: array[CS_NONE..CS_GB18030] of byte = (
    {CS_NONE} 1,
    {CS_OCTETS} 1,
    {CS_ASCII} 1,
    {CS_UNICODE_FSS} 3,
    {CS_UTF8} 4,
    {CS_SJIS_0208} 2,
    {CS_EUCJ_0208} 2,
    {} 1,
    {} 1,
    {CS_DOS737} 1,
    {CS_DOS437} 1,
    {CS_DOS850} 1,
    {CS_DOS865} 1,
    {CS_DOS860} 1,
    {CS_DOS863} 1,
    {CS_DOS775} 1,
    {CS_DOS858} 1,
    {CS_DOS862} 1,
    {CS_DOS864} 1,
    {CS_NEXT} 1,
    {} 1,
    {CS_ISO8859_1} 1,
    {CS_ISO8859_2} 1,
    {CS_ISO8859_3} 1,
    {} 1,
    {} 1,
    {} 1,
    {} 1,
    {} 1,
    {} 1,
    {} 1,
    {} 1,
    {} 1,
    {} 1,
    {CS_ISO8859_4} 1,
    {CS_ISO8859_5} 1,
    {CS_ISO8859_6} 1,
    {CS_ISO8859_7} 1,
    {CS_ISO8859_8} 1,
    {CS_ISO8859_9} 1,
    {CS_ISO8859_13} 1,
    {} 1,
    {} 1,
    {} 1,
    {CS_KSC_5601} 2,
    {CS_DOS852} 1,
    {CS_DOS857} 1,
    {CS_DOS861} 1,
    {CS_DOS866} 1,
    {CS_DOS869} 1,
    {CS_CYRL} 1,
    {CS_WIN1250} 1,
    {CS_WIN1251} 1,
    {CS_WIN1252} 1,
    {CS_WIN1253} 1,
    {CS_WIN1254} 1,
    {CS_BIG_5} 2,
    {CS_GB_2312} 2,
    {CS_WIN1255} 1,
    {CS_WIN1256} 1,
    {CS_WIN1257} 1,
    {} 1,
    {} 1,
    {CS_KOI8R} 1,
    {CS_KOI8U} 1,
    {CS_WIN1258} 1,
    {CS_TIS620} 1,
    {CS_GBK} 2,
    {CS_CP943C} 2,
    {CS_GB18030} 4
  );

type
  TXSQLVARClass = class of TXSQLVAR;

  TXSQLVAR = class(TObject)
  strict private
    FClient: IFirebirdLibrary;
    FSQLVarReady: boolean;
    FPrepared: boolean;
    FXSQLVAR: PXSQLVAR;
  private
    FSize: word;
    FsqlDataSize: smallint;
    constructor Create(const aLibrary: IFirebirdLibrary; const aPtr: pointer;
        aSQLVarReady: Boolean = False);
    function GetSize: smallint;
    procedure SetIsNull(const Value: boolean);
    function GetPrepared: boolean;
  protected
    function Get_aliasname: string;
    function Get_aliasname_length: smallint;
    function Get_sqldata: Pointer;
    function Get_sqlind: PISC_SHORT;
    function Get_sqllen: smallint;
    function Get_sqlname: string;
    function Get_sqlname_length: smallint;
    function Get_relname: string;
    function Get_relname_length: smallint;
    function Get_sqlscale: smallint;
    function Get_sqlsubtype: smallint;
    function Get_sqltype: smallint;
    procedure Set_sqldata(Value: Pointer);
    procedure Set_sqltype(Value: smallint);
  public
    procedure BeforeDestruction; override;
    function CheckCharSet(const aExpectedCharSet: smallint): boolean;
    function CheckType(const aExpectedType: smallint): boolean;
    procedure GetAnsiString(aValue: pointer; out aIsNull: boolean);
    procedure GetBCD(aValue: pointer; out aIsNull: boolean);
    function GetBlob(const aStatusVector: IStatusVector; const aDBHandle:
        pisc_db_handle; const aTransaction: IFirebirdTransaction; aValue: pointer;
        out aIsNull: boolean; aLength: LongWord): ISC_STATUS;
    function GetBlobSize(const aStatusVector: IStatusVector; const aDBHandle:
        pisc_db_handle; const aTransaction: IFirebirdTransaction; out aBlobSize:
        longword; out aIsNull: boolean): ISC_STATUS;
    procedure GetDate(aValue: pointer; out aIsNull: boolean);
    procedure GetDouble(aValue: pointer; out aIsNull: boolean);
    procedure GetInt64(aValue: pointer; out aIsNull: boolean);
    procedure GetInteger(aValue: pointer; out aIsNull: boolean);
    function GetIsNull: boolean;
    procedure GetShort(aValue: pointer; out aIsNull: boolean);
    function GetTextLen: SmallInt; virtual;
    procedure GetTime(aValue: pointer; out aIsNull: boolean);
    procedure GetTimeStamp(aValue: pointer; out aIsNull: boolean);
    procedure GetWideString(aValue: pointer; out aIsNull: boolean);
    function IsNullable: boolean;
    procedure Prepare;
    procedure SetAnsiString(const aValue: pointer; const aLength: word; const
        aIsNull: boolean);
    procedure SetBCD(const aValue: pointer; const aIsNull: boolean);
    function SetBlob(const aStatusVector: IStatusVector; const aDBHandle:
        pisc_db_handle; const aTransaction: IFirebirdTransaction; const aValue:
        pointer; const aLength: Integer; const aIsNull: boolean): ISC_STATUS;
    procedure SetDate(const aValue: pointer; const aLength: Integer; const aIsNull:
        boolean);
    procedure SetDouble(const aValue: pointer; const aLength: Integer; const
        aIsNull: boolean);
    procedure SetInt64(const aValue: pointer; const aLength: Integer; const
        aIsNull: boolean);
    procedure SetInt8(const aValue: pointer; const aLength: Integer; const
        aIsNull: boolean);
    procedure SetInteger(const aValue: pointer; const aLength: Integer; const
        aIsNull: boolean);
    procedure SetShort(const aValue: pointer; const aLength: Integer; const
        aIsNull: boolean);
    procedure SetTime(const aValue: pointer; const aIsNull: boolean);
    procedure SetTimeStamp(const aValue: pointer; const aIsNull: boolean);
    procedure SetUInt8(const aValue: pointer; const aLength: Integer; const
        aIsNull: boolean);
    procedure SetWideString(const aValue: pointer; const aLength: word; const
        aIsNull: boolean);
    property aliasname: string read Get_aliasname;
    property aliasname_length: smallint read Get_aliasname_length;
    property IsNull: boolean read GetIsNull write SetIsNull;
    property Prepared: boolean read GetPrepared;
    property Size: smallint read GetSize;
    property sqldata: pointer read Get_sqldata write Set_sqldata;
    property sqlind: PISC_SHORT read Get_sqlind;
    property sqllen: smallint read Get_sqllen;
    property sqlname: string read Get_sqlname;
    property sqlname_length: smallint read Get_sqlname_length;
    property relname: string read Get_Relname;
    property relname_length: smallint read Get_relname_length;
    property sqlscale: smallint read Get_sqlscale;
    property sqlsubtype: smallint read Get_sqlsubtype;
    property sqltype: smallint read Get_sqltype write Set_sqltype;
  end;

  TXSQLVAR_10 = class(TXSQLVAR)
  public
    function GetTextLen: SmallInt; override;
  end;

  {$if CompilerVersion = 18.5}
  Int16  = SmallInt;
  Int32  = Integer;
  {$ifend}

  TXSQLVAREx = class helper for TXSQLVAR
  public
    function AsAnsiString: AnsiString;
    function AsBcd: TBcd;
    function AsDate: TDateTime;
    function AsDouble: double;
    function AsInt16: Int16;
    function AsInt32: Int32;
    function AsInt64: Int64;
    function AsQuoatedSQLValue: WideString;
    function AsSQLTimeStamp: TSQLTimeStamp;
    function AsTime: TDateTime;
    function AsWideString: WideString;
  end;

  TXSQLVarFactory = class abstract
  public
    class function New(const aLibrary: IFirebirdLibrary; const aPtr: pointer;
        aSQLVarReady: Boolean = False): TXSQLVar;
  end;

  TXSQLDA = class(TObject)
  strict private
    FVars: TList;
    FXSQLDA: PXSQLDA;
    FClient: IFirebirdLibrary;
    procedure Clear;
  private
    function GetVars(Index: Integer): TXSQLVAR;
    function Get_sqld: smallint;
    function Get_sqln: smallint;
    function Get_Version: smallint;
  protected
    function GetCount: integer;
    procedure SetCount(const aValue: integer);
  public
    constructor Create(const aLibrary: IFirebirdLibrary; const aVarCount: Integer =
        0);
    procedure BeforeDestruction; override;
    procedure Prepare;
    property Count: integer read GetCount write SetCount;
  public
    property sqld: smallint read Get_sqld;
    property sqln: smallint read Get_sqln;
    property Vars[Index: Integer]: TXSQLVAR read GetVars; default;
    property Version: smallint read Get_Version;
    property XSQLDA: PXSQLDA read FXSQLDA;
  end;

  IFirebird_DSQL = interface(IInterface)
  ['{D78064C2-2E8F-4BA0-8EBD-739826B7FC34}']
    function Close(const aStatusVector: IStatusVector): TFBIntType;
    function Execute(const aStatusVector: IStatusVector): TFBIntType;
    function Fetch(const aStatusVector: IStatusVector): ISC_STATUS;
    function GetIsStoredProc: Boolean;
    function Geti_SQLDA: TXSQLDA;
    function Geto_SQLDA: TXSQLDA;
    function GetRowsAffected(const aStatusVector: IStatusVector; out aRowsAffected:
        LongWord): ISC_STATUS;
    function Open(const aStatusVector: IStatusVector; const aDBHandle:
        pisc_db_handle; const aTransaction: IFirebirdTransaction): TFBIntType;
    function GetPlan(const aStatusVector: IStatusVector): string;
    function Prepare(const aStatusVector: IStatusVector; const aSQL: string; const
        aSQLDialect: word; const aParamCount: Integer = 0): TFBIntType; overload;
    function Prepare(const aStatusVector: IStatusVector; const aSQL: string; const
        aSQLDialect: word; const aParams: TXSQLDA): TFBIntType; overload;
    function Transaction: IFirebirdTransaction;
    property IsStoredProc: Boolean read GetIsStoredProc;
    property i_SQLDA: TXSQLDA read Geti_SQLDA;
    property o_SQLDA: TXSQLDA read Geto_SQLDA;
  end;

  TFirebird_DSQL = class(TInterfacedObject, IFirebird_DSQL)
  strict private
    type DSQLState = (S_INACTIVE, S_OPENED, S_PREPARED, S_EXECUTED, S_EOF);
  private
    FClient: IFirebirdLibrary;
    FFetchCount: Cardinal;
    FSQLDA_In: TXSQLDA;
    FSQLDA_Out: TXSQLDA;
    FState: DSQLState;
    FStatementHandle: isc_stmt_handle;
    FTransactionPool: TFirebirdTransactionPool;
    FManageTransaction: boolean;
    FTransaction: IFirebirdTransaction;
    FServerCharSet: WideString;
    FIsStoredProc: boolean;
    FManage_SQLDA_In: boolean;
    function StatementHandle: pisc_stmt_handle;
  private
    FLast_DBHandle: pisc_db_handle;
    FLast_SQL: string;
    FLast_SQLDialect: word;
    FLast_ParamCount: integer;
    procedure DoDebug;
  protected
    function Close(const aStatusVector: IStatusVector): TFBIntType;
    function Execute(const aStatusVector: IStatusVector): TFBIntType;
    function Fetch(const aStatusVector: IStatusVector): ISC_STATUS;
    function GetIsStoredProc: Boolean;
    function Geti_SQLDA: TXSQLDA;
    function Geto_SQLDA: TXSQLDA;
    function GetPlan(const aStatusVector: IStatusVector): string;
    function GetRowsAffected(const aStatusVector: IStatusVector; out aRowsAffected:
        LongWord): ISC_STATUS;
    function Open(const aStatusVector: IStatusVector; const aDBHandle:
        pisc_db_handle; const aTransaction: IFirebirdTransaction): TFBIntType;
    function Prepare(const aStatusVector: IStatusVector; const aSQL: string; const
        aSQLDialect: word; const aParamCount: Integer = 0): TFBIntType; overload;
    function Prepare(const aStatusVector: IStatusVector; const aSQL: string; const
        aSQLDialect: word; const aParams: TXSQLDA): TFBIntType; overload;
    function Transaction: IFirebirdTransaction;
  public
    constructor Create(const aClientLibrary: IFirebirdLibrary; const
        aTransactionPool: TFirebirdTransactionPool; const aServerCharSet:
        WideString = ''; const aIsStoredProc: Boolean = False);
    procedure BeforeDestruction; override;
  end;

  {$ifdef Unicode}
  TFirebird_DSQL_Unicode = class helper for TFirebird_DSQL
  protected
    function GetEncoding: TEncoding;
  end;
  {$endif}

implementation

uses {$if CompilerVersion <=18.5}WideStrUtils, {$ifend} Math, StrUtils;

constructor TXSQLVAR.Create(const aLibrary: IFirebirdLibrary; const aPtr:
    pointer; aSQLVarReady: Boolean = False);
begin
  inherited Create;
  FClient := aLibrary;
  FXSQLVAR := aPtr;
  FSQLVarReady := aSQLVarReady;

  FPrepared := False;
end;

procedure TXSQLVAR.BeforeDestruction;
begin
  inherited;
  if FPrepared then begin
    FreeMem(FXSQLVAR^.sqlind);
    FreeMem(FXSQLVAR^.sqldata);
  end;
end;

function TXSQLVAR.CheckCharSet(const aExpectedCharSet: smallint): boolean;
begin
  Result := (sqlsubtype and $00FF) = aExpectedCharSet;
end;

function TXSQLVAR.CheckType(const aExpectedType: smallint): boolean;
begin
  Result := (sqltype and not 1) = aExpectedType;
end;

procedure TXSQLVAR.GetAnsiString(aValue: pointer; out aIsNull: boolean);
var c: PByte;
    iLen: word;
begin
  Assert(Prepared);
  aIsNull := IsNull;
  if aIsNull then Exit;

  if CheckType(SQL_TEXT) then begin
    Move(FXSQLVar.sqldata^, aValue^, sqllen);
    c := aValue;
    Inc(c, sqllen);
    c^ := 0;
  end else if CheckType(SQL_VARYING) then begin
    Move(FXSQLVar.sqldata^, iLen, 2);
    c := PByte(FXSQLVar.sqldata);
    Inc(c, 2);
    Move(c^, aValue^, iLen);
    c := aValue;
    Inc(c, iLen);
    c^ := 0;
  end else
    Assert(False);
end;

procedure TXSQLVAR.GetBCD(aValue: pointer; out aIsNull: boolean);

  procedure TestNegative(aValue: pointer; const aScale: word; aData: string);
  var a, i, iLen: integer;
      bNeg: boolean;
  begin
    if aScale > 0 then begin
      bNeg := aData[1] = '-';
      if bNeg then
        Delete(aData, 1, 1);

      iLen := Length(aData);
      for i := 1 to aScale - iLen do begin
        aData := '0' + aData;
        Inc(iLen);
      end;

      Inc(iLen);  // To hold extra DecimalSeparator
      SetLength(aData, iLen);
      a := iLen;
      for i := iLen downto iLen - aScale + 1 do begin
        aData[i] := aData[i-1];
        Dec(a);
      end;
      aData[a] := {$if RTLVersion>=22}FormatSettings.{$ifend}DecimalSeparator;;

      if bNeg then
        aData := '-' + aData;
    end;
    PBCD(aValue)^ := StrToBcd(aData);
  end;

begin
  Assert(Prepared);
  aIsNull := IsNull;
  if aIsNull then Exit;
  if CheckType(SQL_INT64) then
    TestNegative(aValue, -sqlscale, IntToStr(PInt64(sqldata)^))
  else if CheckType(SQL_LONG) then
    TestNegative(aValue, -sqlscale, IntToStr(PInteger(sqldata)^))
  else if CheckType(SQL_SHORT) then
    TestNegative(aValue, -sqlscale, IntToStr(PSmallInt(sqldata)^))
  else
    Assert(False);
end;

function TXSQLVAR.GetBlob(const aStatusVector: IStatusVector; const aDBHandle:
    pisc_db_handle; const aTransaction: IFirebirdTransaction; aValue: pointer;
    out aIsNull: boolean; aLength: LongWord): ISC_STATUS;
var hBlob: isc_blob_handle;
    pBlobID: PISC_QUAD;
    iLen: word;
    iLenTotal: LongWord;
    iBufSize: word;
    iResult: ISC_STATUS;
    p: PByte;
begin
  Assert(Prepared);
  Assert(CheckType(SQL_BLOB));

  aIsNull := IsNull;
  if aIsNull then Exit;

  pBlobID := sqldata;
  aIsNull := (pBlobID.gds_quad_high = 0) and (pBlobID.gds_quad_low = 0);
  if aIsNull then Exit;

  hBlob := nil;
  FClient.isc_open_blob(aStatusVector.pValue, aDBHandle, aTransaction.TransactionHandle, @hBlob, pBlobID);
  if aStatusVector.CheckError(FClient, Result) then Exit;

  p := aValue;

  iBufSize := High(Word);
  iLenTotal := 0;
  repeat
    if aLength - iLenTotal <= High(Word) then
      iBufSize := aLength - iLenTotal;
    iResult := FClient.isc_get_segment(aStatusVector.pValue, @hBlob, @iLen, iBufSize, PISC_SCHAR(p));
    if iResult = 0 then begin
      Inc(p, iLen);
      Inc(iLenTotal, iLen);
    end else if iResult = isc_segstr_eof then
      Break
    else if aStatusVector.CheckError(FClient, Result) then
      Exit
  until iLenTotal = aLength;

  FClient.isc_close_blob(aStatusVector.pValue, @hBlob);
  if aStatusVector.CheckError(FClient, Result) then Exit;
end;

function TXSQLVAR.GetBlobSize(const aStatusVector: IStatusVector; const
    aDBHandle: pisc_db_handle; const aTransaction: IFirebirdTransaction; out
    aBlobSize: longword; out aIsNull: boolean): ISC_STATUS;
var hBlob: isc_blob_handle;
    C: array[0..0] of byte;
    R: array[0..9] of byte;
    pBlobID: PISC_QUAD;
    iLen: word;
begin
  Assert(Prepared);
  Assert(CheckType(SQL_BLOB));

  aBlobSize := 0;

  aIsNull := IsNull;
  if aIsNull then Exit;

  pBlobID := sqldata;
  aIsNull := (pBlobID.gds_quad_high = 0) and (pBlobID.gds_quad_low = 0);
  if aIsNull then Exit;

  C[0] := isc_info_blob_total_length;
  hBlob := nil;

  FClient.isc_open_blob(aStatusVector.pValue, aDBHandle, aTransaction.TransactionHandle, @hBlob, pBlobID);
  if aStatusVector.CheckError(FClient, Result) then Exit;

  FClient.isc_blob_info(aStatusVector.pValue, @hBlob, 1, @C, Length(R), @R);
  if aStatusVector.CheckError(FClient, Result) then Exit;

  Assert(R[0] = C[0]);
  Move(R[1], iLen, 2);
  Assert(iLen = 4);
  Move(R[3], aBlobSize, iLen);

  FClient.isc_close_blob(aStatusVector.pValue, @hBlob);
  if aStatusVector.CheckError(FClient, Result) then Exit;

  aIsNull := aBlobSize = 0;
end;

procedure TXSQLVAR.GetDate(aValue: pointer; out aIsNull: boolean);
var T: tm;
    D: ISC_DATE;
    G: ISC_TIMESTAMP;
    C: TDateTime;
    E: integer;
begin
  Assert(Prepared);
  aIsNull := IsNull;
  if aIsNull then Exit;

  if CheckType(SQL_TYPE_DATE) then begin
    Move(sqldata^, D, sqllen);
    FClient.isc_decode_sql_date(@D, @T);
    C := EncodeDate(T.tm_year + 1900, T.tm_mon + 1, T.tm_mday);
    E := DateTimeToTimeStamp(C).Date;
    Move(E, aValue^, sqllen);
  end else if CheckType(SQL_TIMESTAMP) then begin
    Move(sqldata^, G, sqllen);
    FClient.isc_decode_timestamp(@G, @T);
    C := EncodeDate(T.tm_year + 1900, T.tm_mon + 1, T.tm_mday);
    E := DateTimeToTimeStamp(C).Date;
    Move(E, aValue^, sqllen);
  end else
    Assert(False);
end;

procedure TXSQLVAR.GetDouble(aValue: pointer; out aIsNull: boolean);
var d: double;
begin
  Assert(Prepared);
  aIsNull := IsNull;
  if aIsNull then Exit;

  if CheckType(SQL_FLOAT) then begin
    Assert(sqllen = SizeOf(Single));
    d := PSingle(sqldata)^;
    Move(d, aValue^, SizeOf(Double));
  end else if CheckType(SQL_DOUBLE) then begin
    Assert(sqllen = SizeOf(Double));
    d := PDouble(sqldata)^;
    Move(d, aValue^, SizeOf(Double));
  end else
    Assert(False);
end;

procedure TXSQLVAR.GetInt64(aValue: pointer; out aIsNull: boolean);
begin
  Assert(Prepared and CheckType(SQL_INT64));
  aIsNull := IsNull;
  if not aIsNull then
    Move(FXSQLVar.sqldata^, aValue^, sqllen);
end;

procedure TXSQLVAR.GetInteger(aValue: pointer; out aIsNull: boolean);
begin
  Assert(Prepared and CheckType(SQL_LONG));
  aIsNull := IsNull;
  if not aIsNull then
    Move(FXSQLVar.sqldata^, aValue^, sqllen);
end;

function TXSQLVAR.GetIsNull: boolean;
begin
  Result := IsNullable;
  if Result then
    Result := psmallint(FXSQLVar.sqlind)^ = -1;
end;

function TXSQLVAR.GetPrepared: boolean;
begin
  Result := FSQLVarReady or FPrepared;
end;

procedure TXSQLVAR.GetShort(aValue: pointer; out aIsNull: boolean);
begin
  Assert(Prepared and CheckType(SQL_SHORT));
  aIsNull := IsNull;
  if not aIsNull then
    Move(FXSQLVar.sqldata^, aValue^, sqllen);
end;

function TXSQLVAR.GetSize: smallint;
begin
  Assert(Prepared);
  Result := FSize;
end;

function TXSQLVAR.GetTextLen: SmallInt;
begin
  Result := sqllen div CharSetBytes[sqlsubtype and $00FF];
end;

procedure TXSQLVAR.GetTime(aValue: pointer; out aIsNull: boolean);
var T: tm;
    D: ISC_TIME;
    C: TDateTime;
    E: integer;
begin
  Assert(Prepared and CheckType(SQL_TYPE_TIME));
  aIsNull := IsNull;
  if not aIsNull then begin
    Move(sqldata^, D, sqllen);
    FClient.isc_decode_sql_time(@D, @T);
    C := EncodeTime(T.tm_hour, T.tm_min, T.tm_sec, 0);
    E := DateTimeToTimeStamp(C).Time;
    Move(E, aValue^, sqllen);
  end;
end;

procedure TXSQLVAR.GetTimeStamp(aValue: pointer; out aIsNull: boolean);
var T: tm;
    D: ISC_TIMESTAMP;
    S: TSQLTimeStamp;
begin
  Assert(Prepared and CheckType(SQL_TIMESTAMP));
  aIsNull := IsNull;
  if not aIsNull then begin
    Move(sqldata^, D, sqllen);
    FClient.isc_decode_timestamp(@D, @T);
    S.Year := T.tm_year + 1900;
    S.Month := T.tm_mon + 1;
    S.Day := T.tm_mday;
    S.Hour := T.tm_hour;
    S.Minute := T.tm_min;
    S.Second := T.tm_sec;
    S.Fractions := 0;
    Move(S, aValue^, SizeOf(S));
  end;
end;

procedure TXSQLVAR.GetWideString(aValue: pointer; out aIsNull: boolean);
var iLen: word;
    W: PWideChar;
begin
  Assert(Prepared);
  aIsNull := IsNull;
  if aIsNull then Exit;

  if CheckType(SQL_TEXT) then begin
    { Character (space) padding is always require in firebird CHAR field,
      so FXSQLVar.sqldata always store sqllen bytes of data.  All available
      storage space allocated are always pad with space character.
      Also, Firebird didn't store the number of UTF-8 code point for the field.
      As a result, I couldn't determine the actual number of UTF-8 code point in
      FXSQLVar.sqldata beside the padding characters (The padding characters
      is also a valid UTF-8 code point).
      Thus, the return value from Utf8ToUnicode is always 0 indicates it can't
      perform the tranlation correctly as there is always not enough buffer for
      the action.
      Thus, I perform truncation on W for up to the number of pre-allocated
      UTF-16 code point.}

    W := PWideChar(aValue);
    Utf8ToUnicode(W, GetTextLen + 1, PAnsiChar(FXSQLVar.sqldata), sqllen);
    Inc(W, GetTextLen);
    W^ := #0;
  end else if CheckType(SQL_VARYING) then begin
    Move(FXSQLVar.sqldata^, iLen, 2);
    Utf8ToUnicode(PWideChar(aValue), GetTextLen + 1, PAnsiChar(FXSQLVar.sqldata) + 2, iLen);
  end else
    Assert(False);
end;

function TXSQLVAR.Get_aliasname: string;
begin
  Result := string(FXSQLVAR.aliasname);
end;

function TXSQLVAR.Get_aliasname_length: smallint;
begin
  Result := FXSQLVAR.aliasname_length;
end;

function TXSQLVAR.Get_relname: string;
begin
  Result := string(FXSQLVAR.relname);
end;

function TXSQLVAR.Get_relname_length: smallint;
begin
  Result := FXSQLVAR.relname_length;
end;

function TXSQLVAR.Get_sqldata: Pointer;
begin
  Result := FXSQLVAR.sqldata;
end;

function TXSQLVAR.Get_sqlind: PISC_SHORT;
begin
  Result := FXSQLVAR.sqlind;
end;

function TXSQLVAR.Get_sqllen: smallint;
begin
  Result := FXSQLVAR.sqllen;
end;

function TXSQLVAR.Get_sqlname: string;
begin
  Result := string(FXSQLVar.sqlname);
end;

function TXSQLVAR.Get_sqlname_length: smallint;
begin
  Result := FXSQLVar.sqlname_length;
end;

function TXSQLVAR.Get_sqlscale: smallint;
begin
  Result := FXSQLVar.sqlscale;
end;

function TXSQLVAR.Get_sqlsubtype: smallint;
begin
  Result := FXSQLVar.sqlsubtype;
end;

function TXSQLVAR.Get_sqltype: smallint;
begin
  Result := FXSQLVAR.sqltype;
end;

function TXSQLVAR.IsNullable: boolean;
begin
  Result := (FXSQLVar.sqltype and 1) <> 0;
end;

procedure TXSQLVAR.Prepare;
var iType, iSize: smallint;
begin
  Assert(not Prepared);

  FSize := sqllen;

  iType := sqltype and not 1;
  Assert(iType <> SQL_BOOLEAN);

  if iType = SQL_VARYING then begin
    iSize := 2{First 2 bytes indicate length of varchar string} + FSize + 1{Null Terminated for UnicodeToUtf8 used in SetWideString};
    FSize := GetTextLen;
    Inc(FSize, 1);
  end else if iType = SQL_TEXT then begin
    iSize := FSize + 1;
    FSize := GetTextLen;
    Inc(FSize, 1);
  end else
    iSize := FSize;

  FsqlDataSize := iSize;
  GetMem(FXSQLVAR^.sqldata, iSize);

  GetMem(FXSQLVAR^.sqlind, sizeof(smallint));
  sqlind^ := 0;

  FPrepared := True;
end;

procedure TXSQLVAR.SetAnsiString(const aValue: pointer; const aLength: word;
    const aIsNull: boolean);
var p: PByte;
    iSmallInt: Smallint;
    iLong: Integer;
    B: TBcd;
    D: double;
    V: variant;
    iLen: integer;
begin
  IsNull := aIsNull;
  if aIsNull then Exit;
  if CheckType(SQL_VARYING) then begin
    if FSize > aLength then begin
      iLen := aLength;
      if (aLength > 0) and ((pbyte(avalue) + iLen - 1)^ = 0) then
        Dec(iLen); // XE3 introduces additional null terminated character in method TDBXAnsiStringBuilderValue.SetAnsiString
    end else
      iLen := FSize - 1;
    p := sqldata;
    Move(iLen, p^, 2);
    Inc(p, 2);
    Move(aValue^, p^, iLen);
  end else if CheckType(SQL_TEXT) then begin
    if FSize > aLength then begin
      iLen := aLength;
      if (aLength > 0) and ((pbyte(avalue) + iLen - 1)^ = 0) then
        Dec(iLen); // XE3 introduces additional null terminated character in method TDBXAnsiStringBuilderValue.SetAnsiString
    end else
      iLen := FSize - 1;
    Move(aValue^, sqldata^, iLen);
    p := sqldata;
    Inc(p, iLen);
    FillChar(p^, sqllen - iLen, 32);
    Inc(p, sqllen - iLen);
    P^ := 0;
  end else if CheckType(SQL_SHORT) then begin
    iSmallInt := StrToInt(string(PAnsiChar(aValue)));
    SetShort(@iSmallInt, SizeOf(iSmallInt), aIsNull);
  end else if CheckType(SQL_LONG) then begin
    iLong := StrToInt(string(PAnsiChar(aValue)));
    SetInteger(@iLong, SizeOf(iLong), aIsNull);
  end else if CheckType(SQL_INT64) then begin
    if not TryStrToBcd(string(PAnsiChar(aValue)), B) then begin
      D := StrToFloat(string(PAnsiChar(aValue)));
      V := VarFMTBcdCreate(D, 19, -sqlscale);
      B := VarToBcd(V);
    end;
    SetBCD(@B, aIsNull);
  end else
    Assert(False);
end;

procedure TXSQLVAR.SetBCD(const aValue: pointer; const aIsNull: boolean);
var B: PBcd;
    i: integer;
    iScaling: INT64;
    iBigInt: INT64;
    iLong: integer;
    iShort: Smallint;
    S: string;
begin
  IsNull := aIsNull;
  if aIsNull then Exit;
  if CheckType(SQL_INT64) then begin
    B := aValue;
    iScaling := 1;
    for i := -1 downto sqlscale do
      iScaling := iScaling * 10;
    BcdMultiply(B^, IntToStr(iScaling), B^);
    S := BcdToStr(B^);
    i := Pos({$if RTLVersion>=22}FormatSettings.{$ifend}DecimalSeparator, S);
    if i = 1 then
      S := '0'
    else if i > 1 then begin
      SetLength(S, i - 1);
      if S = '-' then S := '0';
    end;
    iBigInt := StrToInt64(S);
    Move(iBigInt, sqldata^, sqllen)
  end else if CheckType(SQL_LONG) then begin
    B := aValue;
    iScaling := 1;
    for i := -1 downto sqlscale do
      iScaling := iScaling * 10;
    BcdMultiply(B^, IntToStr(iScaling), B^);
    S := BcdToStr(B^);
    iLong := StrToInt(S);
    Move(iLong, sqldata^, sqllen)
  end else if CheckType(SQL_SHORT) then begin
    B := aValue;
    iScaling := 1;
    for i := -1 downto sqlscale do
      iScaling := iScaling * 10;
    BcdMultiply(B^, IntToStr(iScaling), B^);
    S := BcdToStr(B^);
    iShort:= StrToInt(S);
    Move(iShort, sqldata^, sqllen)
  end else
    Assert(False);
end;

function TXSQLVAR.SetBlob(const aStatusVector: IStatusVector; const aDBHandle:
    pisc_db_handle; const aTransaction: IFirebirdTransaction; const aValue:
    pointer; const aLength: Integer; const aIsNull: boolean): ISC_STATUS;
var hBlob: isc_blob_handle;
    BlobID: ISC_QUAD;
    wLen: word;
    iCurPos: integer;
    p, q: PByte;
    iLong: Integer;
begin
  IsNull := aIsNull;

  if CheckTYPE(SQL_BLOB) then begin
    Assert(SizeOf(BlobID) = sqllen);

    hBlob := nil;
    BlobID.gds_quad_high := 0;
    BlobID.gds_quad_low := 0;
    FClient.isc_create_blob(aStatusVector.pValue, aDBHandle, aTransaction.TransactionHandle, @hBlob, @BlobID);
    if aStatusVector.CheckError(FClient, Result) then Exit;

    iCurPos := 0;
    wLen := High(Word);
    p := aValue;
    while iCurPos < aLength do begin
      if iCurPos + wLen > aLength then
        wLen := aLength - iCurPos;
      q := p;
      Inc(q, iCurPos);
      FClient.isc_put_segment(aStatusVector.pValue, @hBlob, wLen, PISC_SCHAR(q));
      if aStatusVector.CheckError(FClient, Result) then Exit;
      Inc(iCurPos, wLen);
    end;

    FClient.isc_close_blob(aStatusvector.pValue, @hBlob);
    if aStatusVector.CheckError(FClient, Result) then Exit;

    Move(BlobID, sqldata^, sqllen);
  end else if CheckType(SQL_TEXT) or CheckType(SQL_VARYING) then begin
    SetAnsiString(aValue, aLength, aIsNull);
  end else if CheckType(SQL_LONG) then begin
    iLong := StrToInt(AnsiString(PAnsiChar(aValue)));
    SetInteger(@iLong, SizeOf(iLong), aIsNull);
  end else
    Assert(False);
end;

procedure TXSQLVAR.SetDate(const aValue: pointer; const aLength: Integer; const
    aIsNull: boolean);
var T: tm;
    Yr, Mn, Dy: word;
    D: ISC_DATE;
    E: ISC_TIMESTAMP;
    S: TTimeStamp;
begin
  IsNull := aIsNull;
  if aIsNull then Exit;
  Assert(CheckType(SQL_TYPE_DATE) or CheckType(SQL_TIMESTAMP));

  if aLength = 4 then begin
    S.Time := 0;
    S.Date := PInteger(aValue)^;
  end else if aLength = 8 then
    S := MSecsToTimeStamp(PDouble(aValue)^)
  else
    Assert(False);

  DecodeDate(TimeStampToDateTime(S), Yr, Mn, Dy);
  with T do begin
    tm_sec := 0;
    tm_min := 0;
    tm_hour := 0;
    tm_mday := Dy;
    tm_mon := Mn - 1;
    tm_year := Yr - 1900;
  end;

  if CheckType(SQL_TYPE_DATE) then begin
    FClient.isc_encode_sql_date(@T, @D);
    Move(D, sqldata^, sqllen);
  end else begin
    FClient.isc_encode_timestamp(@T, @E);
    Move(E, sqldata^, sqllen);
  end;
end;

procedure TXSQLVAR.SetDouble(const aValue: pointer; const aLength: Integer;
    const aIsNull: boolean);
var S: Single;
    D: Double;
    iScaling: Int64;
    i: integer;
    iValue: INT64;
    iDec: INT64;
begin
  IsNull := aIsNull;
  if aIsNull then Exit;
  if CheckType(SQL_FLOAT) then begin
    Assert((aLength = 4) or (aLength = 8));
    if aLength = 8 then
      S := PDouble(aValue)^
    else
      S := PSingle(aValue)^;
    Move(S, sqldata^, sqllen);
  end else if CheckType(SQL_DOUBLE) then begin
    Assert(aLength = 8);
    D := PDouble(aValue)^;
    Move(D, sqldata^, sqllen);
  end else if CheckType(SQL_INT64) then begin
    Assert(aLength = 8);

    iScaling := 1;
    for i := -1 downto sqlscale do
      iScaling := iScaling * 10;

    D := PDouble(aValue)^;
    iValue := Trunc(D);
    iDec := Trunc(SimpleRoundTo((D - iValue) * iScaling, 0));
    iValue := iValue * iScaling + iDec;

    Move(iValue, sqldata^, sqllen);
  end else
    Assert(False);
end;

procedure TXSQLVAR.SetInt64(const aValue: pointer; const aLength: Integer;
  const aIsNull: boolean);
var i, iScaling: integer;
    iValue: INT64;
begin
  IsNull := aIsNull;
  if aIsNull then Exit;
  if CheckType(SQL_INT64) then begin
    iScaling := 1;
    for i := -1 downto sqlscale do
      iScaling := iScaling * 10;

    iValue := PInt64(aValue)^;
    iValue := iValue * iScaling;
    Move(iValue, sqldata^, sqllen);
  end else
    Assert(False);
end;

procedure TXSQLVAR.SetInt8(const aValue: pointer; const aLength: Integer;
  const aIsNull: boolean);
var i, iScaling: integer;
    i16: Smallint;
    i32: integer;
    i64: INT64;
begin
  IsNull := aIsNull;
  if aIsNull then Exit;
  if CheckType(SQL_SHORT) then begin
    Assert(aLength = 1);
    i16 := PShortInt(aValue)^;
    Move(i16, sqldata^, sqllen);
  end else if CheckType(SQL_LONG) then begin
    Assert(aLength = 1);
    i32 := PShortInt(aValue)^;
    Move(i32, sqldata^, sqllen);
  end else if CheckType(SQL_INT64) then begin
    iScaling := 1;
    for i := -1 downto sqlscale do
      iScaling := iScaling * 10;

    i64 := PByte(aValue)^;
    i64 := i64 * iScaling;
    Move(i64, sqldata^, sqllen);
  end else
    Assert(False);
end;

procedure TXSQLVAR.SetInteger(const aValue: pointer; const aLength: Integer;
    const aIsNull: boolean);
var i, iScaling: integer;
    i16: Smallint;
    i64: INT64;
begin
  IsNull := aIsNull;
  if aIsNull then Exit;
  if CheckType(SQL_LONG) then
    Move(aValue^, sqldata^, sqllen)
  else if CheckType(SQL_SHORT) then begin
    Assert(aLength = 4);
    i16 := PInteger(aValue)^;
    Move(i16, sqldata^, sqllen)
  end else if CheckType(SQL_INT64) then begin
    iScaling := 1;
    for i := -1 downto sqlscale do
      iScaling := iScaling * 10;

    i64 := PInteger(aValue)^;
    i64 := i64 * iScaling;
    Move(i64, sqldata^, sqllen);
  end else
    Assert(False);
end;

procedure TXSQLVAR.SetIsNull(const Value: boolean);
begin
  Assert(Prepared);
  if Value then begin
    if not IsNullable then
      FXSQLVAR.sqltype := FXSQLVAR.sqltype + 1;
    sqlind^ := -1
  end else
    sqlind^ := 0;
end;

procedure TXSQLVAR.SetShort(const aValue: pointer; const aLength: Integer;
    const aIsNull: boolean);
var i, iScaling: integer;
    i32: integer;
    i64: INT64;
begin
  IsNull := aIsNull;
  if aIsNull then Exit;
  if CheckType(SQL_SHORT) then
    Move(aValue^, sqldata^, sqllen)
  else if CheckType(SQL_LONG) then begin
    Assert(aLength = 2);
    i32 := PSmallInt(aValue)^;
    Move(i32, sqldata^, sqllen);
  end else if CheckType(SQL_INT64) then begin
    iScaling := 1;
    for i := -1 downto sqlscale do
      iScaling := iScaling * 10;

    i64 := PSmallInt(aValue)^;
    i64 := i64 * iScaling;
    Move(i64, sqldata^, sqllen);
  end else
    Assert(False);
end;

procedure TXSQLVAR.SetTime(const aValue: pointer; const aIsNull: boolean);
var T: tm;
    iHour, iMinute, iSecond, iMSec: word;
    D: ISC_TIME;
    S: TTimeStamp;
begin
  IsNull := aIsNull;
  if aIsNull then Exit;
  Assert(CheckType(SQL_TYPE_TIME));

  S.Time := PInteger(aValue)^;
  S.Date := 1;
  DecodeTime(TimeStampToDateTime(S), iHour, iMinute, iSecond, iMSec);
  with T do begin
    tm_sec := iSecond;
    tm_min := iMinute;
    tm_hour := iHour;
    tm_mday := 0;
    tm_mon := 0;
    tm_year := 0;
  end;
  FClient.isc_encode_sql_time(@T, @D);
  Move(D, sqldata^, sqllen)
end;

procedure TXSQLVAR.SetTimeStamp(const aValue: pointer;
  const aIsNull: boolean);
var T: tm;
    D: ISC_TIMESTAMP;
    S: PSQLTimeStamp;
begin
  IsNull := aIsNull;
  if aIsNull then Exit;
  Assert(CheckType(SQL_TYPE_DATE) or CheckType(SQL_TIMESTAMP));

  S := PSQLTimeStamp(aValue);
  with T do begin
    tm_sec := S^.Second;
    tm_min := S^.Minute;
    tm_hour := S^.Hour;
    tm_mday := S^.Day;
    tm_mon := S^.Month - 1;
    tm_year := S^.Year - 1900;
  end;
  FClient.isc_encode_timestamp(@T, @D);
  Move(D, sqldata^, sqllen)
end;

procedure TXSQLVAR.SetUInt8(const aValue: pointer; const aLength: Integer;
  const aIsNull: boolean);
var i, iScaling: integer;
    i16: word;
    i32: integer;
    i64: INT64;
begin
  IsNull := aIsNull;
  if aIsNull then Exit;
  if CheckType(SQL_SHORT) then begin
    Assert(aLength = 1);
    i16 := PByte(aValue)^;
    Move(i16, sqldata^, sqllen);
  end else if CheckType(SQL_LONG) then begin
    Assert(aLength = 1);
    i32 := PByte(aValue)^;
    Move(i32, sqldata^, sqllen);
  end else if CheckType(SQL_INT64) then begin
    iScaling := 1;
    for i := -1 downto sqlscale do
      iScaling := iScaling * 10;

    i64 := PByte(aValue)^;
    i64 := i64 * iScaling;
    Move(i64, sqldata^, sqllen);
  end else
    Assert(False);
end;

procedure TXSQLVAR.SetWideString(const aValue: pointer; const aLength: word;
    const aIsNull: boolean);
var p: PAnsiChar;
    iSmallInt: Smallint;
    iLong: Integer;
    iUTF8Len: integer;
    iPadLen: integer;
    iLen: integer;
    B: TBcd;
    D: double;
    V: variant;
begin
  IsNull := aIsNull;
  if aIsNull then Exit;
  if CheckType(SQL_VARYING) then begin
    if FSize > aLength then
      iLen := aLength
    else
      iLen := FSize - 1;
    iUTF8Len := UnicodeToUtf8(PAnsiChar(sqldata) + 2, FsqlDataSize - 2, aValue, iLen) - 1;
    if iUTF8Len = -1 then begin
      iUTF8Len := 1;
      p := sqldata;
      Inc(p, 2);
      p^ := #0;
    end;
    Move(iUTF8Len, sqldata^, 2);
  end else if CheckType(SQL_TEXT) then begin
    if FSize > aLength then
      iLen := aLength
    else
      iLen := FSize - 1;
    p := sqldata;
    iUTF8Len := UnicodeToUtf8(p, FsqlDataSize, aValue, iLen);
    if iUTF8Len > 0 then
      iUTF8Len := iUTF8Len - 1;
    P := P + iUTF8Len;
    iPadLen := sqllen - iUTF8Len;
    if iPadLen > 0 then begin
      FillChar(p^, iPadLen, 32);
      P := P + iPadLen;
      P^ := #0;
    end;
  end else if CheckType(SQL_SHORT) then begin
    iSmallInt := StrToInt(WideString(PWideChar(aValue)));
    SetShort(@iSmallInt, SizeOf(iSmallInt), aIsNull);
  end else if CheckType(SQL_LONG) then begin
    iLong := StrToInt(WideString(PWideChar(aValue)));
    SetInteger(@iLong, SizeOf(iLong), aIsNull);
  end else if CheckType(SQL_INT64) then begin
    if not TryStrToBcd(WideString(PWideChar(aValue)), B) then begin
      D := StrToFloat(WideString(PWideChar(aValue)));
      V := VarFMTBcdCreate(D, 19, -sqlscale);
      B := VarToBcd(V);
    end;
    SetBCD(@B, aIsNull);
  end else
    Assert(False);
end;

procedure TXSQLVAR.Set_sqldata(Value: Pointer);
begin
  Assert(not Prepared);
  FXSQLVAR.sqldata := Value;
end;

procedure TXSQLVAR.Set_sqltype(Value: smallint);
begin
  Assert(not Prepared);
  FXSQLVAR.sqltype := Value;
end;

function TXSQLVAR_10.GetTextLen: SmallInt;
var i: Integer;
    b: SmallInt;
begin
  i := sqlsubtype and $00FF;
  if i = CS_UNICODE_FSS then
    b := 1
  else
    b := CharSetBytes[i];
  Result := sqllen div b;
end;

function TXSQLVAREx.AsAnsiString: AnsiString;
var P: PAnsiChar;
    bIsNull: boolean;
begin
  P := {$ifdef Unicode}AnsiStrAlloc{$else}StrAlloc{$endif}(Size);
  try
    GetAnsiString(P, bIsNull);
    if not bIsNull then
      Result := P
    else
      Result := '';
  finally
    StrDispose(P);
  end;
end;

function TXSQLVAREx.AsBcd: TBcd;
var bIsNull: boolean;
begin
  GetBCD(@Result, bIsNull);
  if bIsNull then
    Result := NullBcd;
end;

function TXSQLVAREx.AsDate: TDateTime;
var M: TTimeStamp;
    bIsNull: boolean;
begin
  GetDate(@M.Date, bIsNull);
  if bIsNull then
    Result := 0
  else begin
    M.Time := 0;
    Result := TimeStampToDateTime(M);
  end;
end;

function TXSQLVAREx.AsDouble: double;
var bIsNull: boolean;
begin
  GetDouble(@Result, bIsNull);
  if bIsNull then
    Result := 0;
end;

function TXSQLVAREx.AsInt16: Int16;
var bIsNull: boolean;
begin
  GetShort(@Result, bIsNull);
  if bIsNull then
    Result := 0;
end;

function TXSQLVAREx.AsInt32: Int32;
var bIsNull: boolean;
begin
  GetInteger(@Result, bIsNull);
  if bIsNull then
    Result := 0;
end;

function TXSQLVAREx.AsInt64: Int64;
var bIsNull: boolean;
begin
  GetInt64(@Result, bIsNull);
  if bIsNull then
    Result := 0;
end;

function TXSQLVAREx.AsQuoatedSQLValue: WideString;
var bQuote: boolean;
begin
  bQuote := True;
  if IsNull then
    Result := 'NULL'
  else begin
    Result := Format('*UNKNOWN(%d,%d)*', [sqltype, sqlsubtype]);
    if CheckType(SQL_TEXT) or CheckType(SQL_VARYING) then begin
      if CheckCharSet(CS_UTF8) or CheckCharSet(CS_UNICODE_FSS) then
        Result := AsWideString
      else
        Result := string(AsAnsiString);
    end else if CheckType(SQL_SHORT) then begin
      if sqlsubtype = 0 then begin
        Result := IntToStr(AsInt16);
      end else if (sqlsubtype = 1) or (sqlsubtype = 2) then
        Result := BcdToStr(AsBcd);
      bQuote := False;
    end else if CheckType(SQL_LONG) then begin
      if sqlsubtype = 0 then begin
        Result := IntToStr(AsInt32);
      end else if (sqlsubtype = 1) or (sqlsubtype = 2) then
        Result := BcdToStr(AsBcd);
      bQuote := False;
    end else if CheckType(SQL_INT64) then begin
      if (sqlsubtype = 0) and (sqlscale = 0) then
        Result := {$if CompilerVersion <= 18.5} BcdToStr(AsBcd) {$else} IntToStr(AsInt64) {$ifend}
      else
        Result := BcdToStr(AsBcd);
      bQuote := False;
    end else if CheckType(SQL_TYPE_DATE) then begin
      Result := FormatDateTime('dd mmm yyyy', AsDate);
    end else if CheckType(SQL_TYPE_TIME) then begin
      Result := TimeToStr(AsTime);
    end else if CheckType(SQL_TIMESTAMP) then begin
      Result := SQLTimeStampToStr('dd mmm yy hh:mm:ss', AsSQLTimeStamp);
    end else if CheckType(SQL_FLOAT) or CheckType(SQL_DOUBLE) then begin
      Result := FloatToStr(AsDouble);
      bQuote := False;
    end else if CheckType(SQL_BLOB) then begin
      Result := '(BLOB)';
    end;
    if bQuote then
      Result := QuotedStr(Result);
  end;
end;

function TXSQLVAREx.AsSQLTimeStamp: TSQLTimeStamp;
var bIsNull: boolean;
begin
  GetTimeStamp(@Result, bIsNull);
  if bIsNull then
    Result := NullSQLTimeStamp;
end;

function TXSQLVAREx.AsTime: TDateTime;
var M: TTimeStamp;
    bIsNull: boolean;
begin
  M := DateTimeToTimeStamp(0);
  GetTime(@M.Time, bIsNull);
  if bIsNull then
    Result := 0
  else
    Result := TimeStampToDateTime(M);
end;

function TXSQLVAREx.AsWideString: WideString;
var bIsNull: boolean;
    W: PWideChar;
begin
  W := {$if CompilerVersion <=18.5}WStrAlloc{$else}StrAlloc{$ifend}(Size);
  try
    GetWideString(W, bIsNull);
    if not bIsNull then
      Result := W
    else
      Result := '';
  finally
    {$if CompilerVersion <=18.5}WStrDispose{$else}StrDispose{$ifend}(W);
  end;
end;

class function TXSQLVarFactory.New(const aLibrary: IFirebirdLibrary; const
    aPtr: pointer; aSQLVarReady: Boolean = False): TXSQLVar;
var o: integer;
    C: TXSQLVARClass;
begin
  C := TXSQLVAR;
  if aLibrary.TryGetODSMajor(o) and (o = 10) then
    C := TXSQLVAR_10;
  Result := C.Create(aLibrary, aPtr, aSQLVarReady);
end;

constructor TXSQLDA.Create(const aLibrary: IFirebirdLibrary; const aVarCount:
    Integer = 0);
begin
  inherited Create;
  FClient := aLibrary;
  FVars := TList.Create;
  SetCount(aVarCount);
end;

{ TXSQLDA }

procedure TXSQLDA.BeforeDestruction;
begin
  inherited;
  Clear;
  FVars.Free;
end;

procedure TXSQLDA.Clear;
var i: integer;
begin
  for i := 0 to FVars.Count - 1 do
    TXSQLVar(FVars[i]).Free;
  FVars.Clear;
  FreeMem(FXSQLDA);
  FXSQLDA := nil;
end;

function TXSQLDA.GetCount: integer;
begin
  Result := sqln;
end;

function TXSQLDA.GetVars(Index: Integer): TXSQLVAR;
begin
  {$if CompilerVersion > 18}
    Result := TXSQLVar(FVars[Index]);
  {$else}
    Assert(Index > 0);
    Result := TXSQLVar(FVars[Index - 1]);
  {$ifend}
end;

function TXSQLDA.Get_sqld: smallint;
begin
  Result := FXSQLDA.sqld;
end;

function TXSQLDA.Get_sqln: smallint;
begin
  Result := FXSQLDA.sqln;
end;

function TXSQLDA.Get_Version: smallint;
begin
  Result := FxSQLDA.version;
end;

procedure TXSQLDA.Prepare;
var i: integer;
    V: TXSQLVAR;
begin
  Assert(sqln >= sqld);
  for i := 0 to FVars.Count - 1 do begin
    V := TXSQLVAR(FVars[i]);
    if not V.Prepared then
      V.Prepare;
  end;
end;

procedure TXSQLDA.SetCount(const aValue: integer);
var o: TXSQLVAR;
    iLen: integer;
    i: Integer;
    iVarSize: integer;
    p: PByte;
begin
  Clear;
  iLen := XSQLDA_LENGTH(aValue);
  GetMem(FXSQLDA, iLen);
  FXSQLDA.version := SQLDA_VERSION1;
  FXSQLDA.sqln := aValue;

  iVarSize := SizeOf(XSQLVAR);
  for i := 1 to aValue do begin
    p := @FXSQLDA.sqlvar;
    Inc(p, (i - 1) * iVarSize);
    o := TXSQLVARFactory.New(FClient, p);
    FVars.Add(o);
  end;
end;

constructor TFirebird_DSQL.Create(const aClientLibrary: IFirebirdLibrary; const
    aTransactionPool: TFirebirdTransactionPool; const aServerCharSet:
    WideString = ''; const aIsStoredProc: Boolean = False);
begin
  inherited Create;
  FClient := aClientLibrary;
  FTransactionPool := aTransactionPool;
  FServerCharSet := aServerCharSet;
  FIsStoredProc := aIsStoredProc;

  FState := S_INACTIVE;
end;

procedure TFirebird_DSQL.DoDebug;
var s: string;
    x: TXSQLDA;
    i: integer;
begin
  s := StringReplace(FLast_SQL, #13#10, ' ', [rfReplaceAll]);
  while Pos('  ', s) > 0 do
    s := StringReplace(s, '  ', ' ', [rfReplaceAll]);
  x := Geti_SQLDA;
  if Assigned(x) then begin
    for i := 0 to x.Count - 1 do
      s := StringReplace(s, '?', x[i].AsQuoatedSQLValue, []);
  end;
  OutputDebugString(PChar(s));
end;

procedure TFirebird_DSQL.BeforeDestruction;
begin
  inherited;
  Assert(FState = S_INACTIVE);
  FSQLDA_Out.Free;
  if FManage_SQLDA_In and Assigned(FSQLDA_In) then FSQLDA_In.Free;
end;

function TFirebird_DSQL.Execute(const aStatusVector: IStatusVector): TFBIntType;
var X: PXSQLDA;
    bHasOutput: boolean;
begin
  if FState = S_INACTIVE then begin
    Open(aStatusVector, FLast_DBHandle, nil);
    if aStatusVector.CheckError(FClient, Result) then Exit;

    Prepare(aStatusVector, FLast_SQL, FLast_SQLDialect, FLast_ParamCount);
    if aStatusVector.CheckError(FClient, Result) then Exit;
  end;

  if Geti_SQLDA <> nil then
    X := Geti_SQLDA.XSQLDA
  else
    X := nil;

  (* DoDebug; *)

  Assert((FState = S_PREPARED) or (FState = S_EXECUTED));

  bHasOutput := FIsStoredProc or (StartsText('INSERT', FLast_SQL) and ContainsText(FLast_SQL, 'RETURNING'));
  if not bHasOutput then
    Result := FClient.isc_dsql_execute(aStatusVector.pValue, FTransaction.TransactionHandle, StatementHandle, FLast_SQLDialect, X)
  else
    Result := FClient.isc_dsql_execute2(aStatusVector.pValue, FTransaction.TransactionHandle, StatementHandle, FLast_SQLDialect, X, FSQLDA_Out.XSQLDA);

  if Result = isc_no_cur_rec then begin
    FState := S_EOF;
    aStatusVector.pValue[1] := 0;
    Result := 0;
    Exit;
  end else if aStatusVector.CheckError(FClient, Result) then
    Exit;

  FState := S_EXECUTED;
  FFetchCount := 0;
end;

function TFirebird_DSQL.Fetch(const aStatusVector: IStatusVector): ISC_STATUS;
begin
  if FState = S_EXECUTED then begin
    Result := FClient.isc_dsql_fetch(aStatusVector.pValue, StatementHandle, FSQLDA_Out.Version, FSQLDA_Out.XSQLDA);
    if (Result = 0) or (Result = 100) then
      FFetchCount := FFetchCount + 1;
  end else if FState = S_EOF then
    Result := 100
  else begin
    Assert(False);
    Result := -1;
  end;
end;

function TFirebird_DSQL.Geti_SQLDA: TXSQLDA;
begin
  Result := FSQLDA_In;
end;

function TFirebird_DSQL.Geto_SQLDA: TXSQLDA;
begin
  Result := FSQLDA_Out;
end;

function TFirebird_DSQL.GetPlan(const aStatusVector: IStatusVector): string;
var info_request: byte;
    result_buffer: array[0..16384] of Byte;
    pLen: PWord;
begin
  Assert(FState = S_PREPARED);

  info_request := isc_info_sql_get_plan;
  FClient.isc_dsql_sql_info(aStatusVector.pValue, StatementHandle, 1, @info_request, SizeOf(result_buffer), @result_buffer);
  Assert(aStatusVector.Success);

  Assert(result_buffer[0] = isc_info_sql_get_plan);

  pLen := @result_buffer[1];
  result_buffer[3 + pLen^] := 0;

  Result := String(PAnsiChar(@result_buffer[3]));
end;

function TFirebird_DSQL.GetRowsAffected(const aStatusVector: IStatusVector; out
    aRowsAffected: LongWord): ISC_STATUS;
var result_buffer: array[0..64] of byte;
    info_request: byte;
    stmt_len: word;
    StmtType: integer;
begin
  if FState = S_INACTIVE then
    aRowsAffected := FFetchCount
  else begin
    aRowsAffected := 0;

    info_request := isc_info_sql_stmt_type;
    FClient.isc_dsql_sql_info(aStatusVector.pValue, StatementHandle, 1, @info_request, Length(result_buffer), @result_buffer);
    if aStatusVector.CheckError(FClient, Result) then Exit;

    if (result_buffer[0] = isc_info_sql_stmt_type) then begin
      Move(result_buffer[1], stmt_len, 2);
      Move(result_buffer[3], StmtType, stmt_len);
    end;

    info_request := isc_info_sql_records;
    FClient.isc_dsql_sql_info(aStatusVector.pValue, StatementHandle, 1, @info_request, Length(result_buffer), @result_buffer);
    if aStatusVector.CheckError(FClient, Result) then Exit;

    if (result_buffer[0] = isc_info_sql_records) then begin
      case StmtType of
        isc_info_sql_stmt_insert: Move(result_buffer[27], aRowsAffected, 4);
        isc_info_sql_stmt_update: Move(result_buffer[6], aRowsAffected, 4);
        isc_info_sql_stmt_delete: Move(result_buffer[13], aRowsAffected, 4);
      end;
    end;
  end;
end;

function TFirebird_DSQL.StatementHandle: pisc_stmt_handle;
begin
  Result := @FStatementHandle;
end;

function TFirebird_DSQL.Transaction: IFirebirdTransaction;
begin
  Result := FTransaction;
end;

function TFirebird_DSQL.Close(const aStatusVector: IStatusVector): TFBIntType;
begin
  if FState = S_INACTIVE then begin
    Result := 0;
    Exit;
  end;

  if FManageTransaction then begin
    if (FState = S_EXECUTED) or (FState = S_EOF) then begin
      FTransactionPool.Commit(aStatusVector, FTransaction);
      FTransaction := nil;
      if aStatusVector.CheckError(FClient, Result) then Exit;
    end else begin
      FTransactionPool.RollBack(aStatusVector, FTransaction);
      FTransaction := nil;
      if aStatusVector.CheckError(FClient, Result) then Exit;
    end;
  end;

  FClient.isc_dsql_free_statement(aStatusVector.pValue, StatementHandle, DSQL_drop);
  if aStatusVector.CheckError(FClient, Result) then Exit;

  FState := S_INACTIVE;
end;

function TFirebird_DSQL.GetIsStoredProc: Boolean;
begin
  Result := FIsStoredProc;
end;

function TFirebird_DSQL.Open(const aStatusVector: IStatusVector; const
    aDBHandle: pisc_db_handle; const aTransaction: IFirebirdTransaction):
    TFBIntType;
begin
  Assert(FState = S_INACTIVE);

  FLast_DBHandle := aDBHandle;

  {$region 'Allocate Statement'}
  FStatementHandle := nil;
  FClient.isc_dsql_alloc_statement2(aStatusVector.pValue, aDBHandle, StatementHandle);
  if aStatusVector.CheckError(FClient, Result) then Exit;
  {$endregion}

  FTransaction := aTransaction;
  if FTransaction = nil then FTransaction := FTransactionPool.CurrentTransaction;
  FManageTransaction := FTransaction = nil;
  if FManageTransaction then begin
    FTransaction := FTransactionPool.Add;
    FTransaction.Start(aStatusVector);
  end;
  if aStatusVector.CheckError(FClient, Result) then Exit;
  FState := S_OPENED;
end;

function TFirebird_DSQL.Prepare(const aStatusVector: IStatusVector; const aSQL:
    string; const aSQLDialect: word; const aParamCount: Integer = 0):
    TFBIntType;
begin
  if (aParamCount > 0) and (FSQLDA_In = nil) then begin
    FManage_SQLDA_In := True;
    FSQLDA_In := TXSQLDA.Create(FClient, aParamCount);
  end;
  Result := Prepare(aStatusVector, aSQL, aSQLDialect, FSQLDA_In);
end;

function TFirebird_DSQL.Prepare(const aStatusVector: IStatusVector; const aSQL:
    string; const aSQLDialect: word; const aParams: TXSQLDA): TFBIntType;
{$ifdef Unicode}var B: TBytes;{$endif}
begin
  Assert(FState = S_OPENED);

  FLast_SQL := aSQL;
  FLast_SQLDialect := aSQLDialect;
  if Assigned(aParams) then
    FLast_ParamCount := aParams.Count
  else
    FLast_ParamCount := 0;

  {$region 'prepare'}
  FreeAndNil(FSQLDA_Out);
  FSQLDA_Out := TXSQLDA.Create(FClient);

  {$ifdef Unicode}
  B := GetEncoding.GetBytes(aSQL);
  FClient.isc_dsql_prepare(aStatusVector.pValue, FTransaction.TransactionHandle, StatementHandle, Length(B), @B[0], FLast_SQLDialect, FSQLDA_Out.XSQLDA);
  {$else}
  FClient.isc_dsql_prepare(aStatusVector.pValue, FTransaction.TransactionHandle, StatementHandle, Length(aSQL), PISC_SChar(aSQL), FLast_SQLDialect, FSQLDA_Out.XSQLDA);
  {$endif}

  if aStatusVector.CheckError(FClient, Result) then Exit;
  {$endregion}
  {$region 'describe'}
  if FSQLDA_Out.sqld > FSQLDA_Out.sqln then begin
    FSQLDA_Out.Count := FSQLDA_Out.sqld;
    FClient.isc_dsql_describe(aStatusVector.pValue, StatementHandle, FLast_SQLDialect, FSQLDA_Out.XSQLDA);
    if aStatusVector.CheckError(FClient, Result) then Exit;
  end;
  FSQLDA_Out.Prepare;
  {$endregion}
  {$region 'describe bind'}
  if Assigned(aParams) and (aParams.Count > 0) then begin
    if FSQLDA_In = nil then
      FManage_SQLDA_In := False;
    FSQLDA_In := aParams;
    FClient.isc_dsql_describe_bind(aStatusVector.pValue, StatementHandle, FLast_SQLDialect, FSQLDA_In.XSQLDA);
    if aStatusVector.CheckError(FClient, Result) then Exit;
    FSQLDA_In.Prepare;
  end;
  {$endregion}

  FState := S_PREPARED;
end;

{$ifdef Unicode}
function TFirebird_DSQL_Unicode.GetEncoding: TEncoding;
begin
  if (FServerCharSet = 'NONE') or (FServerCharSet = 'UTF8') then
    Result := TEncoding.UTF8
  else
    Result := TEncoding.Default;
end;

{$endif}

end.
