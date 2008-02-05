unit firebird.dsql;

interface

uses Classes, IB_Header, firebird.client;

type
  TXSQLVAR = class(TObject)
  strict private
    FPrepared: boolean;
    FXSQLVAR: PXSQLVAR;
    FClient: IFirebirdLibrary;
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
    constructor Create(const aLibrary: IFirebirdLibrary; const aPtr: pointer);
    procedure BeforeDestruction; override;
    function CheckType(const aExpectedType: smallint): boolean;
    procedure GetBCD(aValue: pointer; out aIsNull: boolean);
    function GetBlob(const aStatusVector: IStatusVector; const aDBHandle:
        pisc_db_handle; const aTransaction: IFirebirdTransaction; aValue: pointer;
        out aIsNull: boolean; aLength: LongWord): ISC_STATUS;
    function GetBlobSize(const aStatusVector: IStatusVector; const aDBHandle:
        pisc_db_handle; const aTransaction: IFirebirdTransaction; out aBlobSize:
        longword; out aIsNull: boolean): ISC_STATUS;
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
    procedure SetBCD(const aValue: pointer; const aIsNull: boolean);
    function SetBlob(const aStatusVector: IStatusVector; const aDBHandle:
        pisc_db_handle; const aTransaction: IFirebirdTransaction; const aValue:
        pointer; const aLength: Integer; const aIsNull: boolean): ISC_STATUS;
    procedure SetDate(const aValue: pointer; const aLength: Integer; const aIsNull:
        boolean);
    procedure SetDouble(const aValue: pointer; const aLength: Integer; const
        aIsNull: boolean);
    procedure SetInteger(const aValue: pointer; const aLength: Integer; const
        aIsNull: boolean);
    procedure SetShort(const aValue: pointer; const aLength: Integer; const
        aIsNull: boolean);
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
    function Close(const aStatusVector: IStatusVector): Integer;
    function Execute(const aStatusVector: IStatusVector): Integer;
    function Fetch(const aStatusVector: IStatusVector): ISC_STATUS;
    function Geti_SQLDA: TXSQLDA;
    function Geto_SQLDA: TXSQLDA;
    function GetRowsAffected(const aStatusVector: IStatusVector; out aRowsAffected:
        LongWord): ISC_STATUS;
    function Open(const aStatusVector: IStatusVector; const aDBHandle:
        pisc_db_handle; const aTransaction: IFirebirdTransaction): Integer;
    function GetPlan(const aStatusVector: IStatusVector): string;
    function Prepare(const aStatusVector: IStatusVector; const aSQL: string; const
        aSQLDialect: word; const aParamCount: Integer = 0): Integer;
    function Transaction: IFirebirdTransaction;
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
    function StatementHandle: pisc_stmt_handle;
  private
    FLast_DBHandle: pisc_db_handle;
    FLast_SQL: string;
    FLast_SQLDialect: word;
    FLast_ParamCount: integer;
  protected
    function Close(const aStatusVector: IStatusVector): Integer;
    function Execute(const aStatusVector: IStatusVector): Integer;
    function Fetch(const aStatusVector: IStatusVector): ISC_STATUS;
    function Geti_SQLDA: TXSQLDA;
    function Geto_SQLDA: TXSQLDA;
    function GetPlan(const aStatusVector: IStatusVector): string;
    function GetRowsAffected(const aStatusVector: IStatusVector; out aRowsAffected:
        LongWord): ISC_STATUS;
    function Open(const aStatusVector: IStatusVector; const aDBHandle:
        pisc_db_handle; const aTransaction: IFirebirdTransaction): Integer;
    function Prepare(const aStatusVector: IStatusVector; const aSQL: string; const
        aSQLDialect: word; const aParamCount: Integer = 0): Integer;
    function Transaction: IFirebirdTransaction;
  public
    constructor Create(const aClientLibrary: IFirebirdLibrary; const
        aTransactionPool: TFirebirdTransactionPool);
    procedure BeforeDestruction; override;
  end;

implementation

uses SysUtils, FMTBcd, SqlTimSt, Math;

constructor TXSQLVAR.Create(const aLibrary: IFirebirdLibrary; const aPtr:
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
    FreeMem(FXSQLVAR^.sqlind);
    FreeMem(FXSQLVAR^.sqldata);
  end;
end;

function TXSQLVAR.CheckType(const aExpectedType: smallint): boolean;
begin
  Result := (sqltype and not 1) = aExpectedType;
end;

procedure TXSQLVAR.GetBCD(aValue: pointer; out aIsNull: boolean);

  procedure Test(aValue: pointer; const aScale: word; aData: string);
  var i, iLen: integer;
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

      Inc(iLen);  // To hold extra '.'
      SetLength(aData, iLen);
      for i := iLen downto iLen - aScale + 1 do
        aData[i] := aData[i-1];
      aData[i] := '.';

      if bNeg then
        aData := '-' + aData;
    end;
    PBCD(aValue)^ := StrToBcd(aData);
  end;

begin
  Assert(FPrepared);
  aIsNull := IsNull;
  if aIsNull then Exit;
  if CheckType(SQL_INT64) then
    Test(aValue, -sqlscale, IntToStr(PInt64(sqldata)^))
  else if CheckType(SQL_LONG) then
    Test(aValue, -sqlscale, IntToStr(PInteger(sqldata)^))
  else if CheckType(SQL_SHORT) then
    Test(aValue, -sqlscale, IntToStr(PSmallInt(sqldata)^))
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
    p: PChar;
begin
  Assert(FPrepared);
  Assert(CheckType(SQL_BLOB));

  aIsNull := IsNull;
  if aIsNull then Exit;

  pBlobID := sqldata;
  aIsNull := (pBlobID.isc_quad_high = 0) and (pBlobID.isc_quad_low = 0);
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
    iResult := FClient.isc_get_segment(aStatusVector.pValue, @hBlob, @iLen, iBufSize, p);
    if iResult = 0 then begin
      p := p + iLen;
      Inc(iLenTotal, iLen);
    end else if iResult <> isc_segstr_eof then
      if aStatusVector.CheckError(FClient, Result) then Exit
    else
      Break;
  until iLenTotal = aLength;
  
  FClient.isc_close_blob(aStatusVector.pValue, @hBlob);
  if aStatusVector.CheckError(FClient, Result) then Exit;
end;

function TXSQLVAR.GetBlobSize(const aStatusVector: IStatusVector; const
    aDBHandle: pisc_db_handle; const aTransaction: IFirebirdTransaction; out
    aBlobSize: longword; out aIsNull: boolean): ISC_STATUS;
var hBlob: isc_blob_handle;
    C: string;
    R: array[0..9] of char;
    pBlobID: PISC_QUAD;
    iLen: word;
begin
  Assert(FPrepared);
  Assert(CheckType(SQL_BLOB));

  aBlobSize := 0;

  aIsNull := IsNull;
  if aIsNull then Exit;

  pBlobID := sqldata;
  aIsNull := (pBlobID.isc_quad_high = 0) and (pBlobID.isc_quad_low = 0);
  if aIsNull then Exit;

  C := char(isc_info_blob_total_length);
  hBlob := nil;

  FClient.isc_open_blob(aStatusVector.pValue, aDBHandle, aTransaction.TransactionHandle, @hBlob, pBlobID);
  if aStatusVector.CheckError(FClient, Result) then Exit;

  FClient.isc_blob_info(aStatusVector.pValue, @hBlob, 1, PChar(C), SizeOf(R), R);
  if aStatusVector.CheckError(FClient, Result) then Exit;

  Assert(R[0] = C[1]);
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
  Assert(FPrepared);
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
  Assert(FPrepared);
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
  if aIsNull then Exit;

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

procedure TXSQLVAR.GetTime(aValue: pointer; out aIsNull: boolean);
var T: tm;
    D: ISC_TIME;
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
    D: ISC_TIMESTAMP;
    S: TSQLTimeStamp;
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
    S.Fractions := 0;
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

  GetMem(FXSQLVAR^.sqldata, FSize);

  GetMem(FXSQLVAR^.sqlind, sizeof(smallint));
  sqlind^ := 0;

  FPrepared := True;
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
    i := Pos('.', S);
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
    p: PChar;
begin
  IsNull := aIsNull;
  Assert(CheckType(SQL_BLOB));
  Assert(SizeOf(BlobID) = sqllen);

  hBlob := nil;
  BlobID.isc_quad_high := 0;
  BlobID.isc_quad_low := 0;
  FClient.isc_create_blob(aStatusVector.pValue, aDBHandle, aTransaction.TransactionHandle, @hBlob, @BlobID);
  if aStatusVector.CheckError(FClient, Result) then Exit;

  iCurPos := 0;
  wLen := High(Word);
  p := aValue;
  while iCurPos < aLength do begin
    if iCurPos + wLen > aLength then
      wLen := aLength - iCurPos;
    FClient.isc_put_segment(aStatusVector.pValue, @hBlob, wLen, p + iCurPos);
    if aStatusVector.CheckError(FClient, Result) then Exit;
    Inc(iCurPos, wLen);
  end;

  FClient.isc_close_blob(aStatusvector.pValue, @hBlob);
  if aStatusVector.CheckError(FClient, Result) then Exit;

  Move(BlobID, sqldata^, sqllen);
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
    iScaling: integer;
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

procedure TXSQLVAR.SetInteger(const aValue: pointer; const aLength: Integer;
    const aIsNull: boolean);
var i, iScaling: integer;
    iSmallInt: Smallint;
    iValue: INT64;
begin
  IsNull := aIsNull;
  if aIsNull then Exit;
  if CheckType(SQL_LONG) then
    Move(aValue^, sqldata^, sqllen)
  else if CheckType(SQL_SHORT) then begin
    Assert(aLength = 4);
    iSmallInt := PInteger(aValue)^;
    Move(iSmallInt, sqldata^, sqllen)
  end else if CheckType(SQL_INT64) then begin
    iScaling := 1;
    for i := -1 downto sqlscale do
      iScaling := iScaling * 10;

    iValue := PInteger(aValue)^;
    iValue := iValue * iScaling;
    Move(iValue, sqldata^, sqllen);
  end else
    Assert(False);
end;

procedure TXSQLVAR.SetIsNull(const Value: boolean);
begin
  Assert(FPrepared);
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
    iLong: integer;
    iValue: INT64;
begin
  IsNull := aIsNull;
  if aIsNull then Exit;
  if CheckType(SQL_SHORT) then
    Move(aValue^, sqldata^, sqllen)
  else if CheckType(SQL_LONG) then begin
    Assert(aLength = 2);
    iLong := PSmallInt(aValue)^;
    Move(iLong, sqldata^, sqllen);
  end else if CheckType(SQL_INT64) then begin
    iScaling := 1;
    for i := -1 downto sqlscale do
      iScaling := iScaling * 10;

    iValue := PSmallInt(aValue)^;
    iValue := iValue * iScaling;
    Move(iValue, sqldata^, sqllen);
  end else
    Assert(False);
end;

procedure TXSQLVAR.SetString(const aValue: pointer; const aLength: word; const
    aIsNull: boolean);
var p: PChar;
    iSmallInt: Smallint;
    iLong: Integer;
    B: TBcd;
    D: double;
    V: variant;
begin
  IsNull := aIsNull;
  if aIsNull then Exit;
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
  end else if CheckType(SQL_SHORT) then begin
    iSmallInt := StrToInt(string(PChar(aValue)));
    SetShort(@iSmallInt, SizeOf(iSmallInt), aIsNull);
  end else if CheckType(SQL_LONG) then begin
    iLong := StrToInt(string(PChar(aValue)));
    SetInteger(@iLong, SizeOf(iLong), aIsNull);
  end else if CheckType(SQL_INT64) then begin
    if not TryStrToBcd(string(PChar(aValue)), B) then begin
      D := StrToFloat(string(PChar(aValue)));
      V := VarFMTBcdCreate(D, 19, -sqlscale);
      B := VarToBcd(V);
    end;
    SetBCD(@B, aIsNull);
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
end;

function TXSQLDA.GetCount: integer;
begin
  Result := sqld;
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
begin
  Assert(sqln >= sqld);
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

constructor TFirebird_DSQL.Create(const aClientLibrary: IFirebirdLibrary; const
    aTransactionPool: TFirebirdTransactionPool);
begin
  inherited Create;
  FClient := aClientLibrary;
  FTransactionPool := aTransactionPool;
  FState := S_INACTIVE;
end;

procedure TFirebird_DSQL.BeforeDestruction;
begin
  inherited;
  Assert(FState = S_INACTIVE);

  if Assigned(FSQLDA_In) then FSQLDA_In.Free;
  FSQLDA_Out.Free;
end;

function TFirebird_DSQL.Execute(const aStatusVector: IStatusVector): Integer;
var X: PXSQLDA;
begin
  if FState = S_INACTIVE then begin
    Open(aStatusVector, FLast_DBHandle, nil);
    if aStatusVector.CheckError(FClient, Result) then Exit;

    Prepare(aStatusVector, FLast_SQL, FLast_SQLDialect, FLast_ParamCount);
    if aStatusVector.CheckError(FClient, Result) then Exit;
  end;

  if Assigned(FSQLDA_In) then
    X := FSQLDA_In.XSQLDA
  else
    X := nil;

  Assert(FState = S_PREPARED);

  Result := FClient.isc_dsql_execute(aStatusVector.pValue, FTransaction.TransactionHandle, StatementHandle, FSQLDA_Out.Version, X);
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
  else
    Assert(False);
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

  Result := String(PChar(@result_buffer[3]));
end;

function TFirebird_DSQL.GetRowsAffected(const aStatusVector: IStatusVector; out
    aRowsAffected: LongWord): ISC_STATUS;
var result_buffer: array[0..64] of Char;
    info_request: char;
    stmt_len: word;
    StmtType: integer;
begin
  if FState = S_INACTIVE then
    aRowsAffected := FFetchCount
  else begin
    aRowsAffected := 0;

    info_request := Char(isc_info_sql_stmt_type);
    FClient.isc_dsql_sql_info(aStatusVector.pValue, StatementHandle, 1, @info_request, SizeOf(result_buffer), result_buffer);
    if aStatusVector.CheckError(FClient, Result) then Exit;

    if (result_buffer[0] = Char(isc_info_sql_stmt_type)) then begin
      Move(result_buffer[1], stmt_len, 2);
      Move(result_buffer[3], StmtType, stmt_len);
    end;

    info_request := Char(isc_info_sql_records);
    FClient.isc_dsql_sql_info(aStatusVector.pValue, StatementHandle, 1, @info_request, SizeOf(result_buffer), result_buffer);
    if aStatusVector.CheckError(FClient, Result) then Exit;

    if (result_buffer[0] = Char(isc_info_sql_records)) then begin
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

function TFirebird_DSQL.Close(const aStatusVector: IStatusVector): Integer;
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

function TFirebird_DSQL.Open(const aStatusVector: IStatusVector; const
    aDBHandle: pisc_db_handle; const aTransaction: IFirebirdTransaction):
    Integer;
begin
  Assert(FState = S_INACTIVE);

  FLast_DBHandle := aDBHandle;

  {$region 'Allocate Statement'}
  FStatementHandle := nil;
  FClient.isc_dsql_allocate_statement(aStatusVector.pValue, aDBHandle, StatementHandle);
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
    string; const aSQLDialect: word; const aParamCount: Integer = 0): Integer;
begin
  Assert(FState = S_OPENED);

  FLast_SQL := aSQL;
  FLast_SQLDialect := aSQLDialect;
  FLast_ParamCount := aParamCount;

  {$region 'prepare'}
  FreeAndNil(FSQLDA_Out);
  FSQLDA_Out := TXSQLDA.Create(FClient);
  FClient.isc_dsql_prepare(aStatusVector.pValue, FTransaction.TransactionHandle, StatementHandle, Length(aSQL), pAnsiChar(aSQL), aSQLDialect, FSQLDA_Out.XSQLDA);
  if aStatusVector.CheckError(FClient, Result) then Exit;
  {$endregion}
  {$region 'describe'}
  if FSQLDA_Out.sqld > FSQLDA_Out.sqln then begin
    FSQLDA_Out.Count := FSQLDA_Out.sqld;
    FClient.isc_dsql_describe(aStatusVector.pValue, StatementHandle, FSQLDA_Out.Version, FSQLDA_Out.XSQLDA);
    if aStatusVector.CheckError(FClient, Result) then Exit;
  end;
  FSQLDA_Out.Prepare;
  {$endregion}
  {$region 'describe bind'}
  if (aParamCount > 0) and (FSQLDA_In = nil) then begin
    FSQLDA_In := TXSQLDA.Create(FClient, aParamCount);
    FClient.isc_dsql_describe_bind(aStatusVector.pValue, StatementHandle, FSQLDA_In.Version, FSQLDA_In.XSQLDA);
    if aStatusVector.CheckError(FClient, Result) then Exit;
    FSQLDA_In.Prepare;
  end;
  {$endregion}

  FState := S_PREPARED;
end;

end.
