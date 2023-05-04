unit Firebird.helper;

interface

uses
  System.SysUtils, Firebird;

const isc_info_end      = 1; // undefined in Firebird.pas

type
  IXpbBuilderBuffer = type Pointer;

  IXpbBuilderBufferHelper = record helper for IXpbBuilderBuffer
    function AsBigInt: Int64;
    function AsInt(aLen: Integer): Int32;
    function AsString(aLen: Int32): string;
    function AsStringFromBytes: string;
  end;

  TXpbBuilderBufferVisitor = TFunc<Byte,IXpbBuilderBuffer,UInt32,UInt32>;

  IXpbBuilderHelper = class helper for IXpbBuilder
  public
    function getString(status: IStatus; Dummy: Integer): string; overload; inline;
    function getTag(status: IStatus; out Tag: Byte): Byte; overload; inline;
    procedure insertString(status: IStatus; tag: Byte; str: string); overload;
        inline;
    function Parse(aStatus: IStatus; Visit: TXpbBuilderBufferVisitor; endTag: Byte
        = isc_info_end): UInt64;
  end;

  IProviderHelper = class helper for IProvider
    function attachDatabase(status: IStatus; fileName: string; dpbLength: Cardinal;
        dpb: BytePtr): IAttachment; overload; inline;
    function attachServiceManager(status: IStatus; service: string; spbLength:
        Cardinal; spb: BytePtr): IService; overload; inline;
    function createDatabase(status: IStatus; fileName: string; dpbLength: Cardinal;
        dpb: BytePtr): IAttachment; overload; inline;
  end;

  IFirebirdConfHelper = class helper for IFirebirdConf
    function asString(key: Cardinal; Dummy: Integer): string; overload; inline;
    function getKey(name: string): Cardinal; overload; inline;
  end;

  IConfigManagerHelper = class helper for IConfigManager
    function getDirectory(code: Cardinal; Dummy: Integer): string; overload; inline;
  end;

  IAttachmentHelper = class helper for IAttachment
    function prepare(status: IStatus; tra: ITransaction; stmtLength: Cardinal;
        sqlStmt: string; dialect: Cardinal; flags: Cardinal): IStatement; overload;
        inline;
  end;

  IStatementHelper = class helper for IStatement
    function getPlan(status: IStatus; detailed: Boolean; Dummy: Integer): string;
        overload; inline;
  end;

function fb_get_master_interface(aFBClient: string; out aHandle: THandle): IMaster;

implementation

uses
  Winapi.Windows, System.AnsiStrings, System.IOUtils;

function fb_get_master_interface(aFBClient: string; out aHandle: THandle): IMaster;
var master: function: IMaster; cdecl;
begin
  aHandle := GetModuleHandle(PChar(aFBClient));
  if aHandle = 0 then begin
    var P := TPath.GetDirectoryName(aFBClient);
    if not P.IsEmpty then
      SetDllDirectory(PChar(P));
    aHandle := SafeLoadLibrary(aFBClient);
  end;
  @master := GetProcAddress(aHandle, 'fb_get_master_interface');
  Result := master();
end;

function _PAnsiChar(a: string): PAnsiChar; inline;
begin
  Result := PAnsiChar(AnsiString(A));
end;

function _string(a: PAnsiChar): string; inline;
begin
  Result := string(System.AnsiStrings.StrPas(a));
end;

function IXpbBuilderBufferHelper.AsBigInt: Int64;
begin
  Result := PInt64(Self)^;
end;

function IXpbBuilderBufferHelper.AsInt(aLen: Integer): Int32;
begin
  case aLen of
    1: Result := PByte(Self)^;
    2: Result := PWord(Self)^;
    4: Result := PInteger(Self)^
    else raise Exception.CreateFmt('Unsupported Length: %d', [aLen]);
  end;
end;

function IXpbBuilderBufferHelper.AsString(aLen: Int32): string;
begin
  Result := TEncoding.ANSI.GetString(TBytes(Self), 0, aLen);
end;

function IXpbBuilderBufferHelper.AsStringFromBytes: string;
begin
  var p: PByte := Self;
  var iCount := p^;
  Inc(p);
  var A: TArray<string>;
  while iCount > 0 do begin
    A := A + [TEncoding.ANSI.GetString(TBytes(p), 1, p^)];
    Inc(p, p^ + 1);
    Dec(iCount);
  end;
  Result := string.Join(sLineBreak, A);
end;

function IXpbBuilderHelper.getString(status: IStatus;
  Dummy: Integer): string;
begin
  Result := _string(getString(status));
end;

function IXpbBuilderHelper.getTag(status: IStatus; out Tag: Byte): Byte;
begin
  Tag := getTag(status);
  Result := Tag;
end;

procedure IXpbBuilderHelper.insertString(status: IStatus; tag: Byte; str:
    string);
begin
  insertString(status, tag, _PAnsiChar(str));
end;

function IXpbBuilderHelper.Parse(aStatus: IStatus; Visit:
    TXpbBuilderBufferVisitor; endTag: Byte = isc_info_end): UInt64;
begin
  Result := 0;
  var t: byte;
  while getTag(aStatus, t) <> endTag do begin
    if Assigned(Visit) then
      Inc(Result, Visit(t, getBytes(aStatus), getLength(aStatus)));
    moveNext(aStatus);
  end;
end;

function IProviderHelper.attachDatabase(status: IStatus; fileName: string;
    dpbLength: Cardinal; dpb: BytePtr): IAttachment;
begin
  Result := attachDatabase(status, _PAnsiChar(fileName), dpbLength, dpb);
end;

function IProviderHelper.attachServiceManager(status: IStatus; service: string;
    spbLength: Cardinal; spb: BytePtr): IService;
begin
  Result := attachServiceManager(status, _PAnsiChar(service), spbLength, spb);
end;

function IProviderHelper.createDatabase(status: IStatus; fileName: string;
    dpbLength: Cardinal; dpb: BytePtr): IAttachment;
begin
  Result := createDatabase(status, _PAnsiChar(fileName), dpbLength, dpb);
end;

function IFirebirdConfHelper.asString(key: Cardinal; Dummy: Integer): string;
begin
  Result := _string(asString(key));
end;

function IFirebirdConfHelper.getKey(name: string): Cardinal;
begin
  Result := getKey(_PAnsiChar(name));
end;

function IConfigManagerHelper.getDirectory(code: Cardinal; Dummy: Integer):
    string;
begin
  Result := _string(getDirectory(code));
end;

function IAttachmentHelper.prepare(status: IStatus; tra: ITransaction;
  stmtLength: Cardinal; sqlStmt: string; dialect,
  flags: Cardinal): IStatement;
begin
  Result := prepare(status, tra, stmtLength, _PAnsiChar(sqlStmt), dialect, flags);
end;

function IStatementHelper.getPlan(status: IStatus; detailed: Boolean; Dummy:
    Integer): string;
begin
  Result := _string(getPlan(status, detailed));
end;

end.

