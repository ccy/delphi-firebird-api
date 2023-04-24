unit Firebird.helper;

interface

uses
  Firebird;

type
  IXpbBuilderHelper = class helper for IXpbBuilder
    procedure insertString(status: IStatus; tag: Byte; str: string); overload;
        inline;
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
  Winapi.Windows, System.AnsiStrings, System.IOUtils, System.SysUtils;

function fb_get_master_interface(aFBClient: string; out aHandle: THandle): IMaster;
var master: function: IMaster; cdecl;
begin
  aHandle := GetModuleHandle(PChar(aFBClient));
  if aHandle = 0 then begin
    var P := TPath.GetDirectoryName(aFBClient);
    if not P.IsEmpty then
      SetDllDirectory(PChar(P));
    aHandle := LoadLibrary(PChar(aFBClient));
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

procedure IXpbBuilderHelper.insertString(status: IStatus; tag: Byte; str:
    string);
begin
  insertString(status, tag, _PAnsiChar(str));
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

