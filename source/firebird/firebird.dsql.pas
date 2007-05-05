unit firebird.dsql;

interface

uses Classes, IB_Header, firebird.client;

type
  TXSQLVAR = class(TObject)
  strict private
    FPrepared: boolean;
    FXSQLVAR: PXSQLVAR;
    FClient: IFirebirdClient;
  private
    FSize: smallint;
    function GetSize: smallint;
    procedure SetIsNull(const Value: boolean);
  protected
    function Get_aliasname: TIB_Identifier;
    function Get_aliasname_length: smallint;
    function Get_ownname: TIB_Identifier;
    function Get_ownname_length: smallint;
    function Get_relname: TIB_Identifier;
    function Get_relname_length: smallint;
    function Get_sqldata: Pointer;
    function Get_sqlind: psmallint;
    function Get_sqllen: smallint;
    function Get_sqlname: TIB_Identifier;
    function Get_sqlname_length: smallint;
    function Get_sqlscale: smallint;
    function Get_sqlsubtype: smallint;
    function Get_sqltype: smallint;
    procedure Set_sqldata(Value: Pointer);
    procedure Set_sqltype(Value: smallint);
  public
    constructor Create(const aLibrary: IFirebirdClient; const aPtr: pointer);
    procedure BeforeDestruction; override;
    function CheckType(const aExpectedType: smallint): boolean;
    procedure GetBCD(aValue: pointer; out aIsNull: boolean);
    procedure GetDate(aValue: pointer; out aIsNull: boolean);
    procedure GetDouble(aValue: pointer; out aIsNull: boolean);
    procedure GetInteger(aValue: pointer; out aIsNull: boolean);
    function GetIsNull: boolean;
    procedure GetShort(aValue: pointer; out aIsNull: boolean);
    procedure GetString(aValue: pointer; out aIsNull: boolean);
    procedure GetTime(aValue: pointer; out aIsNull: boolean);
    procedure GetTimeStamp(aValue: pointer; out aIsNull: boolean);
    function IsNullable: boolean;
    procedure Prepare;
    procedure SetBCD(const aValue: pointer; const aScale: integer; const aIsNull:
        boolean);
    procedure SetDate(const aValue: pointer; const aLength: Integer; const aIsNull:
        boolean);
    procedure SetDouble(const aValue: pointer; const aLength: Integer; const
        aIsNull: boolean);
    procedure SetInteger(const aValue: pointer; const aIsNull: boolean);
    procedure SetShort(const aValue: pointer; const aIsNull: boolean);
    procedure SetString(const aValue: pointer; const aLength: word; const aIsNull:
        boolean);
    procedure SetTime(const aValue: pointer; const aIsNull: boolean);
    procedure SetTimeStamp(const aValue: pointer; const aIsNull: boolean);
  public
    property aliasname: TIB_Identifier read Get_aliasname;
    property aliasname_length: smallint read Get_aliasname_length;
    property IsNull: boolean read GetIsNull write SetIsNull;
    property ownname: TIB_Identifier read Get_ownname;
    property ownname_length: smallint read Get_ownname_length;
    property relname: TIB_Identifier read Get_relname;
    property relname_length: smallint read Get_relname_length;
    property Size: smallint read GetSize;
    property sqldata: pointer read Get_sqldata write Set_sqldata;
    property sqlind: psmallint read Get_sqlind;
    property sqllen: smallint read Get_sqllen;
    property sqlname: TIB_Identifier read Get_sqlname;
    property sqlname_length: smallint read Get_sqlname_length;
    property sqlscale: smallint read Get_sqlscale;
    property sqlsubtype: smallint read Get_sqlsubtype;
    property sqltype: smallint read Get_sqltype write Set_sqltype;
  end;

  TXSQLDA = class(TObject)
  strict private
    FVars: TList;
    FXSQLDA: PXSQLDA;
    FClient: IFirebirdClient;
    procedure Clear;
  private
    function GetVars(Index: Integer): TXSQLVAR;
    function Get_sqld: smallint;
    function Get_sqln: smallint;
    function Get_Version: smallint;
  protected
    function GetCount: integer; inline;
    procedure SetCount(const aValue: integer);
  public
    constructor Create(const aLibrary: IFirebirdClient; const aVarCount: Integer =
        0);
    procedure BeforeDestruction; override;
    function Clone: TXSQLDA;
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
    function Close(const aStatusVector: IStatusVector): Integer;
    function Execute(const aStatusVector: IStatusVector): Integer;
    function Fetch(const aStatusVector: IStatusVector): ISC_STATUS;
    function Geti_SQLDA: TXSQLDA;
    function Geto_SQLDA: TXSQLDA;
    function GetRowsAffected(const aStatusVector: IStatusVector; out aRowsAffected:
        LongWord): ISC_STATUS;
    function Open(const aStatusVector: IStatusVector; const aDBHandle:
        pisc_db_handle): Integer;
    function Prepare(const aStatusVector: IStatusVector; const aSQL: string; const
        aSQLDialect: word; const aParamCount: Integer = 0): Integer;
    property i_SQLDA: TXSQLDA read Geti_SQLDA;
    property o_SQLDA: TXSQLDA read Geto_SQLDA;
  end;

  TFirebird_DSQL = class(TInterfacedObject, IFirebird_DSQL)
  strict private
    type DSQLState = (S_INACTIVE, S_OPENED, S_PREPARED, S_EXECUTED, S_CLOSED);
  private
    FClient: IFirebirdClient;
    FSQLDA_In: TXSQLDA;
    FSQLDA_Out: TXSQLDA;
    FState: DSQLState;
    FStatementHandle: isc_stmt_handle;
    FTransactionHandle: isc_tr_handle;
    function StatementHandle: pisc_stmt_handle;
    function TransactionHandle: pisc_tr_handle;
  protected
    function Close(const aStatusVector: IStatusVector): Integer;
    function Execute(const aStatusVector: IStatusVector): Integer;
    function Fetch(const aStatusVector: IStatusVector): ISC_STATUS;
    function Geti_SQLDA: TXSQLDA;
    function Geto_SQLDA: TXSQLDA;
    function GetRowsAffected(const aStatusVector: IStatusVector; out aRowsAffected:
        LongWord): ISC_STATUS;
    function Open(const aStatusVector: IStatusVector; const aDBHandle:
        pisc_db_handle): Integer;
    function Prepare(const aStatusVector: IStatusVector; const aSQL: string; const
        aSQLDialect: word; const aParamCount: Integer = 0): Integer;
  public
    constructor Create(const aClientLibrary: IFirebirdClient);
    procedure BeforeDestruction; override;
  end;

implementation

uses SysUtils, FMTBcd, SqlTimSt;

constructor TXSQLVAR.Create(const aLibrary: IFirebirdClient; const aPtr:
    pointer);
begin
  inherited Create;
  FClient := aLibrary;
  FXSQLVAR := aPtr;
  FPrepared := False;
end;

procedure TXSQLVAR.BeforeDestruction;
begin
  inherited;
  if FPrepared then begin
    if sqltype and 1 = 1 then
      FreeMem(sqlind);
    FreeMem(sqldata);
  end;
end;

function TXSQLVAR.CheckType(const aExpectedType: smallint): boolean;
begin
  Result := (sqltype and not 1) = aExpectedType;
end;

procedure TXSQLVAR.GetBCD(aValue: pointer; out aIsNull: boolean);
var B: PBCD;
    S: string;
    i: integer;
    iScaling: Int64;
begin
  Assert(FPrepared and CheckType(SQL_INT64));
  aIsNull := IsNull;
  if not aIsNull then begin
    B := aValue;
    S := IntToStr(PInt64(sqldata)^);
    B^ := StrToBcd(S);

    iScaling := 1;
    for i := -1 downto sqlscale do
      iScaling := iScaling * 10;
    BcdDivide(B^, iScaling, B^);
  end;
end;

procedure TXSQLVAR.GetDate(aValue: pointer; out aIsNull: boolean);
var T: tm;
    Yr, Mn, Dy: word;
    D: ISC_DATE;
    G: ISC_TIMESTAMP;
    S: TTimeStamp;
    C: TDateTime;
    E: integer;
begin
  Assert(FPrepared);
  aIsNull := IsNull;
  if not aIsNull then begin
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
end;

procedure TXSQLVAR.GetDouble(aValue: pointer; out aIsNull: boolean);
var d: double;
begin
  Assert(FPrepared);
  aIsNull := IsNull;
  if not aIsNull then begin
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
end;

procedure TXSQLVAR.GetInteger(aValue: pointer; out aIsNull: boolean);
begin
  Assert(FPrepared and CheckType(SQL_LONG));
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

procedure TXSQLVAR.GetShort(aValue: pointer; out aIsNull: boolean);
begin
  Assert(FPrepared and CheckType(SQL_SHORT));
  aIsNull := IsNull;
  if not aIsNull then
    Move(FXSQLVar.sqldata^, aValue^, sqllen);
end;

function TXSQLVAR.GetSize: smallint;
begin
  Assert(FPrepared);
  Result := FSize;
end;

procedure TXSQLVAR.GetString(aValue: pointer; out aIsNull: boolean);
var c: PChar;
    iLen: word;
begin
  Assert(FPrepared);
  aIsNull := IsNull;
  if not aIsNull then begin
    if CheckType(SQL_TEXT) then begin
      Move(FXSQLVar.sqldata^, aValue^, sqllen);
      c := aValue;
      c := c + sqllen;
      c^ := #0;
    end else if CheckType(SQL_VARYING) then begin
      Move(FXSQLVar.sqldata^, iLen, 2);
      c := PChar(FXSQLVar.sqldata) + 2;
      Move(c^, aValue^, iLen);
      c := aValue;
      c := c + iLen;
      c^ := #0;
    end else
      Assert(False);
  end;
end;

procedure TXSQLVAR.GetTime(aValue: pointer; out aIsNull: boolean);
var T: tm;
    Yr, Mn, Dy: word;
    D: ISC_TIME;
    S: TTimeStamp;
    C: TDateTime;
    E: integer;
begin
  Assert(FPrepared and CheckType(SQL_TYPE_TIME));
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
    Yr, Mn, Dy: word;
    D: ISC_TIMESTAMP;
    S: TSQLTimeStamp;
    C: TDateTime;
    E: integer;
begin
  Assert(FPrepared and CheckType(SQL_TIMESTAMP));
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
    Move(S, aValue^, SizeOf(S));
  end;
end;

function TXSQLVAR.Get_aliasname: TIB_Identifier;
begin
  Result := FXSQLVAR.aliasname;
end;

function TXSQLVAR.Get_aliasname_length: smallint;
begin
  Result := FXSQLVAR.aliasname_length;
end;

function TXSQLVAR.Get_ownname: TIB_Identifier;
begin
  Assert(False);
end;

function TXSQLVAR.Get_ownname_length: smallint;
begin
  Assert(False);
end;

function TXSQLVAR.Get_relname: TIB_Identifier;
begin
  Assert(False);
end;

function TXSQLVAR.Get_relname_length: smallint;
begin
  Assert(False);
end;

function TXSQLVAR.Get_sqldata: Pointer;
begin
  Result := FXSQLVAR.sqldata;
end;

function TXSQLVAR.Get_sqlind: psmallint;
begin
  Result := FXSQLVAR.sqlind;
end;

function TXSQLVAR.Get_sqllen: smallint;
begin
  Result := FXSQLVAR.sqllen;
end;

function TXSQLVAR.Get_sqlname: TIB_Identifier;
begin
  Result := FXSQLVar.sqlname
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
var iType: smallint;
begin
  Assert(not FPrepared);

  FSize := sqllen;

  iType := sqltype and not 1;
  Assert(iType <> SQL_BOOLEAN);

  if iType = SQL_VARYING then
    Inc(FSize, 2)
  else if iType = SQL_TEXT then
    Inc(FSize, 1);

  GetMem(FXSQLVAR.sqldata, FSize);

  GetMem(FXSQLVAR.sqlind, sizeof(smallint));
  sqlind^ := 0;

  FPrepared := True;
end;

procedure TXSQLVAR.SetBCD(const aValue: pointer; const aScale: integer; const
    aIsNull: boolean);
var B: PBcd;
    i: integer;
    iScaling: INT64;
    iValue: INT64;
    S: string;
begin
  IsNull := aIsNull;
  if CheckType(SQL_INT64) then begin
    B := aValue;
    iScaling := 1;
    for i := 1 to aScale do
      iScaling := iScaling * 10;
    BcdMultiply(B^, IntToStr(iScaling), B^);
    S := BcdToStr(B^);
    iValue := StrToInt64(S);
    Move(iValue, sqldata^, sqllen)
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
  Assert(CheckType(SQL_TYPE_DATE) or CheckType(SQL_TIMESTAMP));
  Assert(aLength = 4);

  S.Time := 0;
  S.Date := PInteger(aValue)^;
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
begin
  IsNull := aIsNull;
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
  end else
    Assert(False);
end;

procedure TXSQLVAR.SetInteger(const aValue: pointer; const aIsNull: boolean);
begin
  IsNull := aIsNull;
  if CheckType(SQL_LONG) then
    Move(aValue^, sqldata^, sqllen)
  else
    Assert(False);
end;

procedure TXSQLVAR.SetIsNull(const Value: boolean);
begin
  Assert(FPrepared);
  if Value then
    sqlind^ := -1
  else
    sqlind^ := 0;
end;

procedure TXSQLVAR.SetShort(const aValue: pointer; const aIsNull: boolean);
begin
  IsNull := aIsNull;
  if CheckType(SQL_SHORT) then
    Move(aValue^, sqldata^, sqllen)
  else
    Assert(False);
end;

procedure TXSQLVAR.SetString(const aValue: pointer; const aLength: word; const
    aIsNull: boolean);
var p: PChar;
begin
  IsNull := aIsNull;
  if CheckType(SQL_VARYING) then begin
    p := sqldata;
    Move(aLength, p^, 2);
    p := p + 2;
    Move(aValue^, p^, aLength);
  end else if CheckType(SQL_TEXT) then begin
    Move(aValue^, sqldata^, aLength);
    p := sqldata;
    P := P + aLength;
    FillChar(p^, sqllen - aLength, 32);
    P := P + sqllen - aLength;
    P^ := #0;
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
    iHour, iMinute, iSecond, iMSec: word;
    D: ISC_TIMESTAMP;
    S: PSQLTimeStamp;
begin
  IsNull := aIsNull;
  Assert(CheckType(SQL_TIMESTAMP));

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

procedure TXSQLVAR.Set_sqldata(Value: Pointer);
begin
  Assert(not FPrepared);
  FXSQLVAR.sqldata := Value;
end;

procedure TXSQLVAR.Set_sqltype(Value: smallint);
begin
  Assert(not FPrepared);
  FXSQLVAR.sqltype := Value;
end;

constructor TXSQLDA.Create(const aLibrary: IFirebirdClient; const aVarCount:
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
end;

function TXSQLDA.Clone: TXSQLDA;
begin
  Result := TXSQLDA.Create(FClient, Count);
  Move(FXSQLDA^, Result.XSQLDA^, XSQLDA_LENGTH(Count));
end;

function TXSQLDA.GetCount: integer;
begin
  Result := sqld;
end;

function TXSQLDA.GetVars(Index: Integer): TXSQLVAR;
begin
  Assert(Index > 0);
  Result := TXSQLVar(FVars[Index - 1]);
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
begin
  Assert(sqln = sqld);
  for i := 0 to FVars.Count - 1 do
    TXSQLVAR(FVars[i]).Prepare;
end;

procedure TXSQLDA.SetCount(const aValue: integer);
var o: TXSQLVAR;
    iLen: integer;
    i: Integer;
    iVarSize: integer;
begin
  Clear;
  iLen := XSQLDA_LENGTH(aValue);
  GetMem(FXSQLDA, iLen);
  FXSQLDA.version := SQLDA_VERSION1;
  FXSQLDA.sqln := aValue;

  iVarSize := SizeOf(XSQLVAR);
  for i := 1 to aValue do begin
    o := TXSQLVAR.Create(FClient, Pointer(PChar(@FXSQLDA.sqlvar) + (i - 1) * iVarSize));
    FVars.Add(o);
  end;
end;

constructor TFirebird_DSQL.Create(const aClientLibrary: IFirebirdClient);
begin
  inherited Create;
  FClient := aClientLibrary;
  FState := S_INACTIVE;
//  FEOF := False;
end;

{ TFirebird_DSQL }

procedure TFirebird_DSQL.BeforeDestruction;
begin
  inherited;
  Assert(FState = S_CLOSED);

  if Assigned(FSQLDA_In) then FSQLDA_In.Free;
  FSQLDA_Out.Free;
end;

function TFirebird_DSQL.Execute(const aStatusVector: IStatusVector): Integer;
var X: PXSQLDA;
    result_buffer: array[0..10] of Char;
    info_request: char;
    stmt_len: integer;
begin
  if Assigned(FSQLDA_In) then
    X := FSQLDA_In.XSQLDA
  else
    X := nil;

  Assert(FState = S_PREPARED);
  FClient.isc_dsql_execute(aStatusVector.pValue, TransactionHandle, StatementHandle, FSQLDA_Out.Version, X);
  if aStatusVector.CheckError(FClient, Result) then Exit;
  FState := S_EXECUTED;
end;

function TFirebird_DSQL.Fetch(const aStatusVector: IStatusVector): ISC_STATUS;
begin
  Assert(FState = S_EXECUTED);
  Result := FClient.isc_dsql_fetch(aStatusVector.pValue, StatementHandle, FSQLDA_Out.Version, FSQLDA_Out.XSQLDA);
end;

function TFirebird_DSQL.Geti_SQLDA: TXSQLDA;
begin
  Result := FSQLDA_In;
end;

function TFirebird_DSQL.Geto_SQLDA: TXSQLDA;
begin
  Result := FSQLDA_Out;
end;

function TFirebird_DSQL.GetRowsAffected(const aStatusVector: IStatusVector; out
    aRowsAffected: LongWord): ISC_STATUS;
var result_buffer: array[0..64] of Char;
    info_request: char;
    stmt_len: word;
    StmtType: integer;
begin
  aRowsAffected := 0;

  info_request := Char(isc_info_sql_stmt_type);
  FClient.isc_dsql_sql_info(aStatusVector.pValue, StatementHandle, 1, @info_request, SizeOf(result_buffer), result_buffer);
  if aStatusVector.CheckError(FClient, Result) then Exit;

  if (result_buffer[0] = Char(isc_info_sql_stmt_type)) then begin
    stmt_len := FClient.isc_vax_integer(@result_buffer[1], 2);
    StmtType := FClient.isc_vax_integer(@result_buffer[3], stmt_len);
  end;

  info_request := Char(isc_info_sql_records);
  FClient.isc_dsql_sql_info(aStatusVector.pValue, StatementHandle, 1, @info_request, SizeOf(result_buffer), result_buffer);
  if aStatusVector.CheckError(FClient, Result) then Exit;

  if (result_buffer[0] = Char(isc_info_sql_records)) then begin
    case StmtType of
      isc_info_sql_stmt_insert: aRowsAffected := FClient.isc_vax_integer(@result_buffer[27], 4);
      isc_info_sql_stmt_update: aRowsAffected := FClient.isc_vax_integer(@result_buffer[6], 4);
      isc_info_sql_stmt_delete: aRowsAffected := FClient.isc_vax_integer(@result_buffer[13], 4);
    end;
  end;
end;

function TFirebird_DSQL.StatementHandle: pisc_stmt_handle;
begin
  Result := @FStatementHandle;
end;

function TFirebird_DSQL.TransactionHandle: pisc_tr_handle;
begin
  Result := @FTransactionHandle;
end;

function TFirebird_DSQL.Close(const aStatusVector: IStatusVector): Integer;
var i: ISC_STATUS;
begin
  Assert(FState = S_EXECUTED);

  {$region 'Fetch incomplete rows'}
//  if FStatementType = isc_info_sql_stmt_select then begin
//    while not FEOF do begin
//      i := Fetch(aStatusVector);
//      if i <> 0 then Break;
//    end;
//    if (i <> 100) then
//      if aStatusVector.CheckError(FClient, Result) then Exit;
//  end;
  {$endregion}

  FClient.isc_commit_transaction(aStatusVector.pValue, TransactionHandle);
  if aStatusVector.CheckError(FClient, Result) then Exit;

  FClient.isc_dsql_free_statement(aStatusVector.pValue, StatementHandle, DSQL_drop);
  if aStatusVector.CheckError(FClient, Result) then Exit;

  FState := S_CLOSED;
end;

function TFirebird_DSQL.Open(const aStatusVector: IStatusVector; const
    aDBHandle: pisc_db_handle): Integer;
var tpb: AnsiString;
    teb: isc_teb;
begin
  Assert(FState = S_INACTIVE);
  {$region 'Allocate Statement'}
  FStatementHandle := nil;
  FClient.isc_dsql_allocate_statement(aStatusVector.pValue, aDBHandle, StatementHandle);
  if aStatusVector.CheckError(FClient, Result) then Exit;
  {$endregion}
  {$region 'Start Transaction'}
  tpb := char(isc_tpb_version3) + char(isc_tpb_write) + char(isc_tpb_read_committed) +
         char(isc_tpb_no_rec_version) + char(isc_tpb_nowait);

  FTransactionHandle := nil;
  teb.db_ptr := aDBHandle;
  teb.tpb_len := Length(tpb);
  teb.tpb_ptr := PAnsiChar(tpb);

  FClient.isc_start_multiple(aStatusVector.pValue, TransactionHandle, 1, @teb);
  if aStatusVector.CheckError(FClient, Result) then Exit;
  {$endregion}
  FState := S_OPENED;
end;

function TFirebird_DSQL.Prepare(const aStatusVector: IStatusVector; const aSQL:
    string; const aSQLDialect: word; const aParamCount: Integer = 0): Integer;
begin
  Assert(FState = S_OPENED);

  {$region 'prepare'}
  FSQLDA_Out := TXSQLDA.Create(FClient);
  FClient.isc_dsql_prepare(aStatusVector.pValue, TransactionHandle, StatementHandle, Length(aSQL), pAnsiChar(aSQL), aSQLDialect, FSQLDA_Out.XSQLDA);
  if aStatusVector.CheckError(FClient, Result) then Exit;
  {$endregion}
  {$region 'describe'}
  if FSQLDA_Out.sqld > FSQLDA_Out.sqln then begin
    FSQLDA_Out.Count := FSQLDA_Out.sqld;
    FClient.isc_dsql_describe(aStatusVector.pValue, StatementHandle, FSQLDA_Out.Version, FSQLDA_Out.XSQLDA);
    FSQLDA_Out.Prepare;
    if aStatusVector.CheckError(FClient, Result) then Exit;
  end;
  {$endregion}
  {$region 'describe bind'}
  if aParamCount > 0 then begin
    FSQLDA_In := TXSQLDA.Create(FClient, aParamCount);
    FClient.isc_dsql_describe_bind(aStatusVector.pValue, StatementHandle, FSQLDA_In.Version, FSQLDA_In.XSQLDA);
    if aStatusVector.CheckError(FClient, Result) then Exit;
    FSQLDA_In.Prepare;
  end;
  {$endregion}

  FState := S_PREPARED;
end;

end.
