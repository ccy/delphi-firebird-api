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

//ifndef INCLUDE_TYPES_PUB_H
//const INCLUDE_TYPES_PUB_H =;

//include <stddef.h>

//if defined(__GNUC__)
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
//endif

(******************************************************************)
(* Status vector                                                  *)
(******************************************************************)

type ISC_STATUS = intptr_t;
type PISC_STATUS = ^ISC_STATUS;

const ISC_STATUS_LENGTH = 20;
type ISC_STATUS_ARRAY = array[0..ISC_STATUS_LENGTH - 1] of ISC_STATUS;
     PISC_STATUS_ARRAY = ^ISC_STATUS_ARRAY;
     PPISC_STATUS_ARRAY = ^PISC_STATUS_ARRAY;

(* SQL State as defined in the SQL Standard. *)
const FB_SQLSTATE_SIZE = 6;
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
//type    ISC_LONG = integer;
//type   ISC_ULONG = Word;
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

//ifndef ISC_TIMESTAMP_DEFINED
type ISC_DATE = record Value: Integer; end;
type PISC_DATE = ^ISC_DATE;

type ISC_TIME = record Value: Integer; end;
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
//const ISC_TIMESTAMP_DEFINED =;
//endif (* ISC_TIMESTAMP_DEFINED *)

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

//type  integer (FB_SHUTDOWN_CALLBACK)( integer reason,  integer mask, Pointer  arg);

//endif (* INCLUDE_TYPES_PUB_H *)

implementation

end.
