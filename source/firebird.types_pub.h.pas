unit firebird.types_pub.h;

interface

(*
 * PROGRAM: Client/Server Common Code
 * MODULE:  types_pub.h
 * DESCRIPTION: Types that are used both internally and externally
 *
 *  The contents of this filename are subject to the Initial
 *  Developer's Public License Version 1.0 (the 'License');
 *  you may not use this filename except in compliance with the
 *  License. You may obtain a copy of the License at
 *  http://www.ibphoenix.com/main.nfs?a=ibphoenix&page=ibp_idpl.
 *
 *  Software distributed under the License is distributed AS IS,
 *  WITHOUT WARRANTY OF ANY KIND, either express or implied.
 *  See the License for the specific language governing rights
 *  and limitations under the License.
 *
 *  The Original Code was created by Dmitry Yemanov
 *  for the Firebird Open Source RDBMS project.
 *
 *  Copyright (c) 2004 Dmitry Yemanov <dimitr@users.sf.net>
 *  and all contributors integer below.
 *
 *  All Rights Reserved.
 *  Contributor(s): ______________________________________.
 *)

//ifndef FIREBIRD_IMPL_TYPES_PUB_H
//const FIREBIRD_IMPL_TYPES_PUB_H =;

//include <stddef.h>

//if defined(__GNUC__) || defined (__HP_cc) || defined (__HP_aCC)
//include <inttypes.h>
//else

//if  not defined(_INTPTR_T_DEFINED)
//if defined(_WIN64)
//type   intptr_t = __int64;
//type   __int64 uintptr_t = Word;
//else
type intptr_t = {$if CompilerVersion<=18.5}Integer{$else}NativeInt{$ifend};
//type uintptr_t = Cardinal;
//endif
//endif

//endif

(******************************************************************)
(* API handles                                                    *)
(******************************************************************)

//if defined(_LP64) or defined(__LP64__) or defined(__arch64__) or defined(_WIN64)
//type   FB_API_HANDLE = Word;
//else
type FB_API_HANDLE = Pointer;
     PFB_API_HANDLE = ^FB_API_HANDLE;
//endif

type isc_att_handle = FB_API_HANDLE;
     pisc_att_handle = ^isc_att_handle;
type isc_blob_handle = FB_API_HANDLE;
     pisc_blob_handle = ^isc_blob_handle;
type isc_db_handle = FB_API_HANDLE;
     pisc_db_handle = ^isc_db_handle;
type isc_req_handle = FB_API_HANDLE;
     pisc_req_handle = ^isc_req_handle;
type isc_stmt_handle = FB_API_HANDLE;
     pisc_stmt_handle = ^isc_stmt_handle;
type isc_svc_handle = FB_API_HANDLE;
     pisc_svc_handle = ^isc_svc_handle;
type isc_tr_handle = FB_API_HANDLE;
     pisc_tr_handle = ^isc_tr_handle;

(******************************************************************)
(* Sizes of memory blocks                                         *)
(******************************************************************)

//ifdef FB_USE_SIZE_T
(* NS: This is how things were done in original Firebird port to 64-bit platforms
   Basic classes use these quantities. However in many places in the engine and
   external libraries 32-bit quantities are used to hold sizes of objects.
   This produces many warnings. This also produces incredibly dirty interfaces,
   when functions take size_t as argument, but only handle 32 bits internally
   without any bounds checking.                                                    *)
//type FB_SIZE_T = size_t;
//type FB_SSIZE_T = intptr_t;
//else
(* NS: This is more clean way to handle things for now. We admit that engine is not
   prepared to handle 64-bit memory blocks in most places, and it is not necessary really. *)
type FB_SIZE_T = Cardinal;
type FB_SSIZE_T = integer;
//endif

(******************************************************************)
(* Status vector                                                  *)
(******************************************************************)

type ISC_STATUS = intptr_t;
type PISC_STATUS = ^ISC_STATUS;
     PPISC_STATUS = ^PISC_STATUS;

const ISC_STATUS_LENGTH = 20;
type ISC_STATUS_ARRAY = array[0..ISC_STATUS_LENGTH - 1] of ISC_STATUS;
     PISC_STATUS_ARRAY = ^ISC_STATUS_ARRAY;
     PPISC_STATUS_ARRAY = ^PISC_STATUS_ARRAY;

(* SQL State as defined in the SQL Standard. *)
const FB_SQLSTATE_LENGTH = 5;
const FB_SQLSTATE_SIZE = FB_SQLSTATE_LENGTH + 1;
type FB_SQLSTATE_STRING = array[0..FB_SQLSTATE_SIZE-1] of Char;

(******************************************************************)
(* Define type, export and other stuff based on c/c++ and Windows *)
(******************************************************************)
//if defined(WIN32) or defined(_WIN32) or defined(__WIN32__)
// const  ISC_EXPORT = __stdcall;
// const  ISC_EXPORT_VARARG = __cdecl;
//else
// const  ISC_EXPORT =;
// const  ISC_EXPORT_VARARG =;
//endif

(*
 * It is difficult to detect 64-bit LongInt from the redistributable header
 * we do not care of 16-bit platforms anymore thus we may use plain 'int'
 * which is 32-bit on all platforms we support
 *
 * We'll move to this definition in future API releases.
 *
 *)

//if defined(_LP64) or defined(__LP64__) or defined(__arch64__)
//type ISC_LONG = integer;
//type ISC_ULONG = Word;
//else
type ISC_LONG = integer;
type PISC_LONG = ^ISC_LONG;
type ISC_ULONG = Cardinal;
type PISC_ULONG = ^ISC_ULONG;
//endif

type ISC_SHORT = SmallInt;
type PISC_SHORT = ^ISC_SHORT;
type ISC_USHORT = Word;
type PISC_USHORT = ISC_USHORT;

type ISC_UCHAR = Byte;
type PISC_UCHAR = ^ISC_UCHAR;
type PPISC_UCHAR = ^PISC_UCHAR;
type ISC_SCHAR = AnsiChar;
type PISC_SCHAR = ^ISC_SCHAR;
type PPISC_SCHAR = ^PISC_SCHAR;

type FB_BOOLEAN = ISC_UCHAR;
const FB_FALSE = #0;
const FB_TRUE = #1;

(*******************************************************************)
(* 64 bit Integers                                                 *)
(*******************************************************************)

//if (defined(WIN32) or defined(_WIN32) or defined(__WIN32__)) and  not defined(__GNUC__)
type ISC_INT64 = Int64;
type ISC_UINT64 = UInt64;
//else
//type   LongInt   ISC_INT64 = LongInt;
//type   LongInt ISC_UINT64 = Cardinal;
//endif

(*******************************************************************)
(* Time & Date support                                             *)
(*******************************************************************)

type ISC_DATE = type Integer;
type PISC_DATE = ^ISC_DATE;

type ISC_TIME = type Cardinal;
type PISC_TIME = ^ISC_TIME;

type
  ISC_TIME_TZ = record
    utc_time: ISC_TIME;
    time_zone: ISC_USHORT;
  end;
  PISC_TIME_TZ = ^ISC_TIME_TZ;

type
  ISC_TIME_TZ_EX = record
    utc_time: ISC_TIME;
    time_zone: ISC_USHORT;
    ext_offset: ISC_SHORT;
  end;
  PISC_TIME_TZ_EX = ^ISC_TIME_TZ_EX;

type
  ISC_TIMESTAMP = record
   timestamp_date: ISC_DATE;
   timestamp_time: ISC_TIME;
  end;
  PISC_TIMESTAMP = ^ISC_TIMESTAMP;

type
  ISC_TIMESTAMP_TZ = record
   utc_timestamp: ISC_TIMESTAMP;
   time_zone: ISC_USHORT;
  end;
  PISC_TIMESTAMP_TZ = ^ISC_TIMESTAMP_TZ;

type
  ISC_TIMESTAMP_TZ_EX = record
   utc_timestamp: ISC_TIMESTAMP;
   time_zone: ISC_USHORT;
   ext_offset: ISC_SHORT;
  end;
  PISC_TIMESTAMP_TZ_EX = ^ISC_TIMESTAMP_TZ_EX;

(*******************************************************************)
(* Blob Id support                                                 *)
(*******************************************************************)

  GDS_QUAD_t = record
    gds_quad_high: ISC_LONG;
    gds_quad_low: ISC_ULONG;
  end;

type
  GDS_QUAD = GDS_QUAD_t;
type
  ISC_QUAD = GDS_QUAD_t;
  PISC_QUAD = ^ISC_QUAD;

//const isc_quad_high = gds_quad_high;
//const isc_quad_low = gds_quad_low;

type
  FB_SHUTDOWN_CALLBACK = function(
    const reason: Integer;
    const mask: Integer;
    arg: Pointer
  ): Integer;

  FB_DEC16_t = record
    fb_data: array[0..0] of ISC_UINT64;
  end;

  FB_DEC34_t = record
    fb_data: array[0..1] of ISC_UINT64;
  end;

  FB_I128_t = record
    fb_data: array[0..1] of ISC_UINT64;
  end;

  FB_DEC16 = FB_DEC16_t;
  FB_DEC34 = FB_DEC34_t;
  FB_I128 = FB_I128_t;

//endif (* FIREBIRD_IMPL_TYPES_PUB_H *)

implementation

end.
