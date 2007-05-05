unit firebird.client.debug;

interface

uses firebird.client;

type
  TFirebirdClientDebugFactory = class(TInterfacedObject, IFirebirdClientDebugFactory)
  protected
    function Get(const aProcName: string; const aProc: pointer; const aParams:
        array of const; const aResult: longint): string;
  published
    function isc_attach_database(const aProcName: string; const aProc: pointer;
        const aParams: array of const; const aResult: longint): string;
    function isc_commit_transaction(const aProcName: string; const aProc: pointer;
        const aParams: array of const; const aResult: longint): string;
    function isc_detach_database(const aProcName: string; const aProc: pointer;
        const aParams: array of const; const aResult: longint): string;
    function isc_dsql_allocate_statement(const aProcName: string; const aProc:
        pointer; const aParams: array of const; const aResult: longint): string;
    function isc_dsql_execute_immediate(const aProcName: string; const aProc:
        pointer; const aParams: array of const; const aResult: longint): string;
    function isc_dsql_fetch(const aProcName: string; const aProc: pointer; const
        aParams: array of const; const aResult: longint): string;
    function isc_dsql_free_statement(const aProcName: string; const aProc: pointer;
        const aParams: array of const; const aResult: longint): string;
    function isc_dsql_prepare(const aProcName: string; const aProc: pointer; const
        aParams: array of const; const aResult: longint): string;
    function isc_rollback_transaction(const aProcName: string; const aProc:
        pointer; const aParams: array of const; const aResult: longint): string;
    function isc_start_multiple(const aProcName: string; const aProc: pointer;
        const aParams: array of const; const aResult: longint): string;
  end;

implementation

uses IB_Header, SysUtils;

function TFirebirdClientDebugFactory.Get(const aProcName: string; const aProc:
    pointer; const aParams: array of const; const aResult: longint): string;
var pMethod: pointer;
    H: integer;
begin
  Result := aProcName;
  pMethod := Self.MethodAddress(aProcName);   // Find method in Message Class
  if Assigned(pMethod) then begin
    H := High(aParams);
    asm
      mov  eax,[aParams]        // 3rd argument: @aParams
      push eax
      mov  eax,[H]              // 4th argument: Highest index of dynamic array. Eg: High(aParams)
      push eax
      mov  eax,[aResult]        // 5th argument: aResult
      push eax
      mov  eax,[Result]         // 6th argument: @Result
      push eax
      mov  ecx,aProc            // 2nd argument: aProc
      mov  edx,[aProcName]      // 1st argument: aProcName
      mov  eax,[Self]           // address of self or class
      call pMethod              // call message method
    end;
  end;
end;

function TFirebirdClientDebugFactory.isc_attach_database(const aProcName:
    string; const aProc: pointer; const aParams: array of const; const aResult:
    longint): string;
var P: ^Pointer;
begin
  P := aParams[3].VPointer;
  Result := Format('%s db_name: %s db_handle: %d', [aProcName, aParams[2].VPChar, integer(P^)]);
end;

function TFirebirdClientDebugFactory.isc_commit_transaction(const aProcName:
    string; const aProc: pointer; const aParams: array of const; const aResult:
    longint): string;
var P: ^Pointer;
begin
  P := aParams[1].VPointer;
  Result := Format('%s tr_handle: %d', [aProcName, integer(P^)]);
end;

function TFirebirdClientDebugFactory.isc_detach_database(const aProcName:
    string; const aProc: pointer; const aParams: array of const; const aResult:
    longint): string;
var P: ^Pointer;
begin
  P := aParams[1].VPointer;
  Result := Format('%s db_handle: %d', [aProcName, integer(P^)]);
end;

function TFirebirdClientDebugFactory.isc_dsql_allocate_statement(const
    aProcName: string; const aProc: pointer; const aParams: array of const;
    const aResult: longint): string;
var P1, P2: ^Pointer;
begin
  P1 := aParams[1].VPointer;
  P2 := aParams[2].VPointer;
  Result := Format('%s db_handle: %d statement handle: %d', [aProcName, integer(P1^), integer(P2^)]);
end;

function TFirebirdClientDebugFactory.isc_dsql_execute_immediate(const
    aProcName: string; const aProc: pointer; const aParams: array of const;
    const aResult: longint): string;
var P1, P2: ^pointer;
begin
  P1 := aParams[1].VPointer;
  P2 := aParams[2].VPointer;

  Result := Format('%s db_handle: %d transaction handle: %d'#13'%s', [aProcName, integer(P1^), integer(P2^), aParams[4].VPChar]);
end;

function TFirebirdClientDebugFactory.isc_dsql_fetch(const aProcName: string;
    const aProc: pointer; const aParams: array of const; const aResult:
    longint): string;
var s: string;
begin
  case aResult of
    0: s := 'success';
    100: s := 'EOF';
    else s := 'Error';
  end;
  Result := Format('%s: %s', [aProcName, s]);
end;

function TFirebirdClientDebugFactory.isc_dsql_free_statement(const aProcName:
    string; const aProc: pointer; const aParams: array of const; const aResult:
    longint): string;
var P: ^Pointer;
    s: string;
begin
  P := aParams[1].VPointer;
  case aParams[2].VInteger of
    DSQL_close: s := 'DSQL_CLOSE';
    DSQL_drop: s := 'DSQL_DROP';
    DSQL_cancel: s := 'DSQL_CANCEL';
    else s := 'unknown';
  end;
  Result := Format('%s statement handle: %d Option: %s', [aProcName, integer(P^), s]);
end;

function TFirebirdClientDebugFactory.isc_dsql_prepare(const aProcName: string;
    const aProc: pointer; const aParams: array of const; const aResult:
    longint): string;
var s: string;
begin
  SetString(S, aParams[4].VPChar, aParams[3].VInteger);
  Result := Format('%s SQLDialect: %d'#13'%s', [aProcName, aParams[5].VInteger, S]);
end;

function TFirebirdClientDebugFactory.isc_rollback_transaction(const aProcName:
    string; const aProc: pointer; const aParams: array of const; const aResult:
    longint): string;
begin
  Result := Format('%s tr_handle: %d', [aProcName, integer(aParams[1].VPointer)]);
end;

function TFirebirdClientDebugFactory.isc_start_multiple(const aProcName:
    string; const aProc: pointer; const aParams: array of const; const aResult:
    longint): string;
var P: ^Pointer;
begin
  P := aParams[1].VPointer;
  Result := Format('%s tr_handle: %d', [aProcName, integer(P^)]);
end;

end.
