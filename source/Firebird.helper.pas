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

function fb_get_master_interface(aFBClient: string; out aHandle: THandle): IMaster;

implementation

uses
  Winapi.Windows, System.IOUtils, System.SysUtils;

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

end.

