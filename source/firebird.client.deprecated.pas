unit firebird.client.deprecated;

interface

{.$Message 'http://tracker.firebirdsql.org/browse/CORE-1745: Firebird Embedded DLL create fb_xxxx.LCK cause problem on multi connection in same project'}

uses
  firebird.client;

type
  TFirebirdLibrary_Deprecated = class(TFirebirdLibrary)
  protected
    procedure CORE_2186(aLibrary: string);
    procedure CORE_4508;
  end deprecated;

implementation

uses System.SysUtils, Winapi.Windows;

{$WARN SYMBOL_PLATFORM OFF}

type
  HANDLE = Winapi.Windows.THandle;
  PWSTR = PWideChar;

  PROCESS_BASIC_INFORMATION = record
    ExitStatus:         NativeUInt;
    PebBaseAddress:     {$if RtlVersion < 22}Pointer{$else}PVOID{$ifend};
    AffinityMask:       NativeUInt;
    BasePriority:       NativeUInt;
    UniqueProcessId:    NativeUInt;
    InheritedUniquePID: NativeUInt;
  end;

  _UNICODE_STRING = record
    Length: USHORT;
    MaximumLength: USHORT;
    Buffer: PWSTR;
  end;
  UNICODE_STRING = _UNICODE_STRING;

  _PEB_LDR_DATA = record // not packed!
  (*000*)Length: ULONG;
  (*004*)Initialized: BOOLEAN;
  (*008*)SsHandle: PVOID;
  (*00c*)InLoadOrderModuleList: LIST_ENTRY;
  (*014*)InMemoryOrderModuleList: LIST_ENTRY;
  (*01c*)InInitializationOrderModuleList: LIST_ENTRY;
  (*024*)EntryInProgress: PVOID;
  end;
  PEB_LDR_DATA = _PEB_LDR_DATA;
  PPEB_LDR_DATA = ^_PEB_LDR_DATA;
  PPPEB_LDR_DATA = ^PPEB_LDR_DATA;
  TPebLdrData = _PEB_LDR_DATA;
  PPebLdrData = ^_PEB_LDR_DATA;

  PLDR_DDAG_NODE = ^TLDR_DDAG_NODE;
  TLDR_DDAG_NODE = packed record
    Modules             : TListEntry;
    ServiceTagList      : Pointer(*PLDR_SERVICE_TAG_RECORD*);
    LoadCount           : ULONG;
    ReferenceCount      : ULONG;
    DependencyCount     : ULONG;
    case Integer of
      0: (Dependencies  : Pointer(*TLDRP_CSLIST*));
      1: (RemovalLink   : Pointer(*TSingleListEntry*);
    IncomingDependencies: Pointer(*TLDRP_CSLIST*);
    State               : Pointer(*TLDR_DDAG_STATE*);
    CondenseLink        : Pointer(*TSingleListEntry*);
    PreorderNumber      : ULONG;
    LowestLink          : ULONG);
  end;

  _LDR_DATA_TABLE_ENTRY = record // not packed!
  (*000*)InLoadOrderLinks: LIST_ENTRY;
  (*000*)InMemoryOrderLinks: LIST_ENTRY;
  (*000*)InInitializationOrderLinks: LIST_ENTRY;
  (*008*)DllBase: PVOID;
  (*00c*)EntryPoint: PVOID;
  (*010*)SizeOfImage: ULONG;
  (*014*)FullDllName: UNICODE_STRING;
  (*01c*)BaseDllName: UNICODE_STRING;
  (*024*)Flags: ULONG;
  (*028*)LoadCount: USHORT;
  (*02a*)TlsIndex: USHORT;
//  (*02c*)HashLinks: LIST_ENTRY;
  (*034*)SectionPointer: PVOID;
  (*038*)CheckSum: ULONG;
//  (*03C*)TimeDateStamp: ULONG;
  (*040*)LoadedImports: PVOID;
  (*044*)EntryPointActivationContext: PVOID; // PACTIVATION_CONTEXT
  (*048*)PatchInformation: PVOID;
    DdagNode: PLDR_DDAG_NODE;
  end;
  LDR_DATA_TABLE_ENTRY = _LDR_DATA_TABLE_ENTRY;
  PLDR_DATA_TABLE_ENTRY = ^_LDR_DATA_TABLE_ENTRY;
  PPLDR_DATA_TABLE_ENTRY = ^PLDR_DATA_TABLE_ENTRY;
  TLdrDataTableEntry = _LDR_DATA_TABLE_ENTRY;
  PLdrDataTableEntry = ^_LDR_DATA_TABLE_ENTRY;

  _PEB_WXP = record // packed!
  (*000*)InheritedAddressSpace: BOOLEAN;
  (*001*)ReadImageFileExecOptions: BOOLEAN;
  (*002*)BeingDebugged: BOOLEAN;
  (*003*)SpareBool: BOOLEAN;
  (*004*)Mutant: PVOID;
  (*008*)ImageBaseAddress: PVOID;
  (*00c*)Ldr: Pointer(*PPEB_LDR_DATA*);
  (*010*)ProcessParameters: Pointer(*PRTL_USER_PROCESS_PARAMETERS*);
  (*014*)SubSystemData: PVOID;
  (*018*)ProcessHeap: PVOID;
  (*01c*)FastPebLock: Pointer(*PRTL_CRITICAL_SECTION*);
  (*020*)FastPebLockRoutine: PVOID; // RtlEnterCriticalSection
  (*024*)FastPebUnlockRoutine: PVOID; // RtlLeaveCriticalSection
  (*028*)EnvironmentUpdateCount: ULONG;
  (*02c*)KernelCallbackTable: PPVOID; // List of callback functions
  (*030*)SystemReserved: array[0..0] of ULONG;
  (*034*)AtlThunkSListPtr32: PVOID; // (Windows XP)
  (*038*)FreeList: Pointer(*PPEB_FREE_BLOCK*);
  (*03c*)TlsExpansionCounter: ULONG;
  (*040*)TlsBitmap: PVOID; // ntdll!TlsBitMap of type PRTL_BITMAP
  (*044*)TlsBitmapBits: array[0..1] of ULONG; // 64 bits
  (*04c*)ReadOnlySharedMemoryBase: PVOID;
  (*050*)ReadOnlySharedMemoryHeap: PVOID;
  (*054*)ReadOnlyStaticServerData: Pointer(*PTEXT_INFO*);
  (*058*)AnsiCodePageData: PVOID;
  (*05c*)OemCodePageData: PVOID;
  (*060*)UnicodeCaseTableData: PVOID;
  (*064*)NumberOfProcessors: ULONG;
  (*068*)NtGlobalFlag: ULONG;
  (*06C*)Unknown01: ULONG; // Padding or something
  (*070*)CriticalSectionTimeout: LARGE_INTEGER;
  (*078*)HeapSegmentReserve: ULONG;
  (*07c*)HeapSegmentCommit: ULONG;
  (*080*)HeapDeCommitTotalFreeThreshold: ULONG;
  (*084*)HeapDeCommitFreeBlockThreshold: ULONG;
  (*088*)NumberOfHeaps: ULONG;
  (*08c*)MaximumNumberOfHeaps: ULONG;
  (*090*)ProcessHeaps: PPVOID;
  (*094*)GdiSharedHandleTable: PPVOID;
  (*098*)ProcessStarterHelper: PVOID;
  (*09c*)GdiDCAttributeList: ULONG;
  (*0a0*)LoaderLock: Pointer(*PCRITICAL_SECTION*);
  (*0a4*)OSMajorVersion: ULONG;
  (*0a8*)OSMinorVersion: ULONG;
  (*0ac*)OSBuildNumber: USHORT;
  (*0ae*)OSCSDVersion: USHORT;
  (*0b0*)OSPlatformId: ULONG;
  (*0b4*)ImageSubsystem: ULONG;
  (*0b8*)ImageSubsystemMajorVersion: ULONG;
  (*0bc*)ImageSubsystemMinorVersion: ULONG;
  (*0c0*)ImageProcessAffinityMask: ULONG;
  (*0c4*)GdiHandleBuffer: array[0..33] of HANDLE;
  (*14c*)PostProcessInitRoutine: PVOID;
  (*150*)TlsExpansionBitmap: PVOID;
  (*154*)TlsExpansionBitmapBits: array[0..31] of ULONG;
  (*1d4*)SessionId: ULONG;
  // Windows XP
  (*1d8*)AppCompatFlags: ULARGE_INTEGER;
  (*1e0*)AppCompatFlagsUser: ULARGE_INTEGER;
  (*1e8*)pShimData: PVOID;
  (*1ec*)AppCompatInfo: PVOID;
  (*1f0*)CSDVersion: UNICODE_STRING;
  (*1f8*)ActivationContextData: PVOID; // PACTIVATION_CONTEXT_DATA
  (*1fc*)ProcessAssemblyStorageMap: PVOID; // PASSEMBLY_STORAGE_MAP
  (*200*)SystemDefaultActivationContextData: PVOID; // PACTIVATION_CONTEXT_DATA
  (*204*)SystemAssemblyStorageMap: PVOID; // PASSEMBLY_STORAGE_MAP
  (*208*)MinimumStackCommit: ULONG;
  end;

  _PROCESSINFOCLASS = (
    ProcessBasicInformation,
    ProcessQuotaLimits,
    ProcessIoCounters,
    ProcessVmCounters,
    ProcessTimes,
    ProcessBasePriority,
    ProcessRaisePriority,
    ProcessDebugPort,
    ProcessExceptionPort,
    ProcessAccessToken,
    ProcessLdtInformation,
    ProcessLdtSize,
    ProcessDefaultHardErrorMode,
    ProcessIoPortHandlers, // Note: this is kernel mode only
    ProcessPooledUsageAndLimits,
    ProcessWorkingSetWatch,
    ProcessUserModeIOPL,
    ProcessEnableAlignmentFaultFixup,
    ProcessPriorityClass,
    ProcessWx86Information,
    ProcessHandleCount,
    ProcessAffinityMask,
    ProcessPriorityBoost,
    ProcessDeviceMap,
    ProcessSessionInformation,
    ProcessForegroundInformation,
    ProcessWow64Information, // = 26
    ProcessImageFileName, // added after W2K
    ProcessLUIDDeviceMapsEnabled,
    ProcessBreakOnTermination, // used by RtlSetProcessIsCritical()
    ProcessDebugObjectHandle,
    ProcessDebugFlags,
    ProcessHandleTracing,
    MaxProcessInfoClass);
  PROCESSINFOCLASS = _PROCESSINFOCLASS;
  PROCESS_INFORMATION_CLASS = PROCESSINFOCLASS;
  TProcessInfoClass = PROCESSINFOCLASS;

function ZwQueryInformationProcess(ProcessHandle: THANDLE; ProcessInformationClass: PROCESSINFOCLASS; ProcessInformation: PVOID; ProcessInformationLength: ULONG; ReturnLength: PULONG): NTSTATUS; stdcall; external 'ntdll.dll';

procedure TFirebirdLibrary_Deprecated.CORE_2186(aLibrary: string);
var H: THandle;
    s: string;
begin
  // Check if the FLibrary still in used, otherwise attempt to free library fbintl.dll
  H := GetModuleHandle(PChar(aLibrary));
  if H = 0 then begin
    // Firebird bug: http://tracker.firebirdsql.org/browse/CORE-2186
    // In Firebird version 2.X, when execute function isc_dsql_execute_immediate for CREATE DATABASE
    // intl/fbintl.dll will be loaded and never free.  The following code attempt to free the fbintl.dll library
    s := ExtractFilePath(aLibrary) + 'intl\fbintl.dll';
    H := GetModuleHandle(PChar(s));
    if H <> 0 then
      FreeLibrary(H);
  end;
end;

procedure TFirebirdLibrary_Deprecated.CORE_4508;
var M: string;
    H: THandle;
    PBI: PROCESS_BASIC_INFORMATION;
    i: ULONG;
    j: {$if RTLVersion < 23}DWORD{$else}NativeUInt{$ifend};
    PEB: _PEB_WXP;
    PebLDrData: TPebLdrData;
    Current: TLdrDataTableEntry;
    Index: Pointer;
    iLoadCount: Integer;
begin
  {http://tracker.firebirdsql.org/browse/CORE-4508}

  M := GetModuleName(FHandle);
  if M.IsEmpty then Exit;

  H := GetCurrentProcess;

  ZeroMemory(@PBI, SizeOf(PBI));
  if ZwQueryInformationProcess(H, ProcessBasicInformation, @PBI, SizeOf(PBI), @i) > 0 then Exit;

  j := i;
  ZeroMemory(@PEB, SizeOf(PEB));
  Win32Check(ReadProcessMemory(H, PBI.PebBaseAddress, @PEB, SizeOf(PEB), j));
  Win32Check(ReadProcessMemory(H, PEB.Ldr, @PebLDrData, sizeof(PebLDrData), j));

  ZeroMemory(@Current, SizeOf(Current));
  Index := PebLDrData.InLoadOrderModuleList.Flink;

  while Win32Check(ReadProcessMemory(GetCurrentProcess, Index, @Current, SizeOf(Current), j)) and Assigned(Current.DllBase) do begin
    if SameText(M, Current.FullDllName.Buffer) then begin
      if TOSVersion.Check(6, 2) then
        iLoadCount := Current.DdagNode.LoadCount
      else
        iLoadCount := Current.LoadCount;
      if iLoadCount = 1 then
        fb_shutdown;
      Break;
    end;
    Index := Current.InLoadOrderLinks.Flink;
  end;
end;

end.
