unit firebird.dsc.h;

(*
 *  PROGRAM:  JRD access method
 *  MODULE:    dsc.h
 *  DESCRIPTION:  Definitions associated with descriptors
 *
 * The contents of this file are subject to the Interbase Public
 * License Version 1.0 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy
 * of the License at http://www.Inprise.com/IPL.html
 *
 * Software distributed under the License is distributed on an
 * "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express
 * or implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The Original Code was created by Inprise Corporation
 * and its predecessors. Portions created by Inprise Corporation are
 * Copyright (C) Inprise Corporation.
 *
 * All Rights Reserved.
 * Contributor(s): ______________________________________.
 * 2002.04.16  Paul Beach - HP10 Define changed from -4 to (-4) to make it
 *             compatible with the HP Compiler
 * Adriano dos Santos Fernandes
 *)

//#ifndef JRD_DSC_H
//#define JRD_DSC_H
//
//#include "firebird/impl/dsc_pub.h"
//#include "firebird/impl/consts_pub.h"
//#include "../jrd/ods.h"
//#include "../intl/charsets.h"
//#include "../common/DecFloat.h"
//#include "../common/Int128.h"

interface

uses firebird.dsc_pub.h, firebird.ods.h, firebird.types_pub.h;

// Data type information

function DTYPE_IS_TEXT(d: Byte): Boolean; inline;

function DTYPE_IS_DATE(t: Byte): Boolean; inline;

// DTYPE_IS_BLOB includes both BLOB and ARRAY since array's are implemented over blobs.
function DTYPE_IS_BLOB(d: Byte): Boolean; inline;

// DTYPE_IS_BLOB_OR_QUAD includes both BLOB, QUAD and ARRAY since array's are implemented over blobs.
function DTYPE_IS_BLOB_OR_QUAD(d: Byte): Boolean; inline;

// Exact numeric?
function DTYPE_IS_EXACT(d: Byte): Boolean; inline;

function DTYPE_IS_APPROX(d: Byte): Boolean; inline;

function DTYPE_IS_DECFLOAT(d: Byte): Boolean; inline;

function DTYPE_IS_NUMERIC(d: Byte): Boolean; inline;

// Descriptor format

type
  dsc = record
    dsc_dtype: Byte;
    dsc_scale: ShortInt;
    dsc_length: Word;
    dsc_sub_type: SmallInt;
    dsc_flags: Word;
    dsc_address: PByte; // Used either as offset in a message or as a pointer

    function Create(): dsc; overload;

  {$ifdef __cplusplus}
    function dsc_blob_ttype: SmallInt;
    //function dsc_ttype: &SmallInt;
    function dsc_ttype: SmallInt;

    function isNullable: Boolean;
    procedure setNullable(nullable: Boolean);
    function isNull: Boolean;
    procedure setNull;
    procedure clearNull;
    function isBlob: Boolean;
    function isExact: Boolean;
    function isNumeric: Boolean;
    function isText: Boolean;
    function isDBKey: Boolean;
    function isDateTime: Boolean;
    function isDateTimeTz: Boolean;
    function isDate: Boolean;
    function isTime: Boolean;
    function isTimeStamp: Boolean;
    function isDecFloat: Boolean;
    function isInt128: Boolean;
    function isDecOrInt: Boolean;
    function isDecOrInt128: Boolean;
    function is128: Boolean;
    function isApprox: Boolean;
    function isUnknown: Boolean;
    function getBlobSubType: SmallInt;
    function getSubType: SmallInt;
    procedure setBlobSubType(subType: SmallInt);
    function getCharSet: Byte;
    function getTextType: Word;
    procedure setTextType(ttype: Word);
    function getCollation: Word;
    procedure clear;
    procedure clearFlags;
    procedure makeBlob(subType: SmallInt; ttype: Word; address: PISC_QUAD = nil);
    procedure makeDate(address: PISC_DATE = nil);
    procedure makeDBKey(address: Pointer = nil);
    procedure makeDouble(address: PDouble = nil);
//    procedure makeDecimal64(address: PDecimal64 = nil);
//    procedure makeDecimal128(address: PDecimal128 = nil);
    procedure makeInt64(scale: ShortInt; address: PInt64 = nil);
//    procedure makeInt128(scale: ShortInt; address: PInt128 = nil);
    procedure makeLong(scale: ShortInt; address: PLongInt = nil);
    procedure makeBoolean(address: PByte = nil);
    procedure makeNullString;
    procedure makeShort(scale: ShortInt; address: PSmallInt = nil);
    procedure makeText(length: Word; ttype: Word; address: PByte = nil);
    procedure makeTime(address: PISC_TIME = nil);
    procedure makeTimeTz(address: PISC_TIME_TZ = nil);
    procedure makeTimeTzEx(address: PISC_TIME_TZ_EX = nil);
    procedure makeTimeStamp(address: PISC_TIMESTAMP = nil);
    procedure makeTimeStampTz(address: PISC_TIMESTAMP_TZ = nil);
    procedure makeTimeStampTzEx(address: PISC_TIMESTAMP_TZ_EX = nil);
    procedure makeVarying(length: Word; ttype: Word; address: PByte = nil);

    function getStringLength: Integer;

    class operator Implicit(const od: &Descriptor): dsc;
    class operator Implicit(myRecord: dsc): Descriptor;

    {$ifdef DEV_BUILD}
	    procedure address32bit;
    {$endif}

    function typeToText: PChar;
    procedure getSQLInfo(sqlLength: PLongInt; sqlSubType: PLongInt; sqlScale: PLongInt; sqlType: PLongInt);

  {$endif}
  end;

function DSC_GET_CHARSET(const desc: &dsc): SmallInt; inline;

function DSC_GET_COLLATE(const desc: &dsc): SmallInt; inline;

type
  alt_dsc = record
    dsc_combined_type: Integer;
    dsc_sub_type: SmallInt;
    dsc_flags: Word;                 // Not currently used
  end;

(* function DSC_EQUIV(const d1: &dsc; const d2: &dsc; check_collate: Boolean): Boolean; inline; *)

// In DSC_*_result tables, DTYPE_CANNOT means that the two operands
// cannot participate together in the requested operation.

const DTYPE_CANNOT = 127;

// Historical alias definition
const dtype_date     = dtype_timestamp;

const dtype_aligned  = dtype_varying;
const dtype_any_text = dtype_varying;
const dtype_min_comp = dtype_packed;
const dtype_max_comp = dtype_d_float;

// NOTE: For types <= dtype_any_text the dsc_sub_type field defines the text type

function TEXT_LEN(const desc: &dsc): Word; inline;


// Text Sub types, distinct from character sets & collations

const dsc_text_type_none     = 0;  // Normal text
const dsc_text_type_fixed    = 1;  // strings can contain null bytes
const dsc_text_type_ascii    = 2;  // string contains only ASCII characters
const dsc_text_type_metadata = 3;  // string represents system metadata


// Exact numeric subtypes: with ODS >= 10, these apply when dtype
// is short, long, or quad.

const dsc_num_type_none    = 0;  // defined as SMALLINT or INTEGER
const dsc_num_type_numeric = 1;  // defined as NUMERIC(n,m)
const dsc_num_type_decimal = 2;  // defined as DECIMAL(n,m)

// Date type information

function NUMERIC_SCALE(const desc: dsc): ShortInt; inline;

const DEFAULT_DOUBLE = dtype_double;

implementation

uses firebird.charsets.h, firebird.consts_pub.h;

function DTYPE_IS_TEXT(d: Byte): Boolean;
begin
  Result := (d >= dtype_text) and (d <= dtype_varying);
end;

function DTYPE_IS_DATE(t: Byte): Boolean;
begin
  Result := ((t >= dtype_sql_date) and (t <= dtype_timestamp)) or ((t >= dtype_sql_time_tz) and (t <= dtype_ex_timestamp_tz));
end;

function DTYPE_IS_BLOB(d: Byte): Boolean;
begin
  Result := (d = dtype_blob) or (d = dtype_array);
end;

function DTYPE_IS_BLOB_OR_QUAD(d: Byte): Boolean;
begin
  Result := (d = dtype_blob) or (d = dtype_quad) or (d = dtype_array);
end;

function DTYPE_IS_EXACT(d: Byte): Boolean;
begin
  Result := (d = dtype_int64) or (d = dtype_long) or (d = dtype_short) or (d = dtype_int128);
end;

function DTYPE_IS_APPROX(d: Byte): Boolean;
begin
  Result := (d = dtype_double) or (d = dtype_real);
end;

function DTYPE_IS_DECFLOAT(d: Byte): Boolean;
begin
  Result := (d = dtype_dec128) or (d = dtype_dec64);
end;

function DTYPE_IS_NUMERIC(d: Byte): Boolean;
begin
  Result := ((d >= dtype_byte) and (d <= dtype_d_float)) or (d = dtype_int64) or
			(d = dtype_int128) or DTYPE_IS_DECFLOAT(d);
end;

function dsc.Create(): dsc;
begin
  Result.dsc_dtype    := 0;
  Result.dsc_scale    := 0;
  Result.dsc_length   := 0;
  Result.dsc_sub_type := 0;
  Result.dsc_flags    := 0;
  Result.dsc_address  := nil;
end;

{$ifdef __cplusplus}
function dsc.dsc_blob_ttype: SmallInt;
begin
  Result := dsc_scale or (dsc_flags and $FF00);
end;

//function dsc.dsc_ttype: &SmallInt;
//begin
//  Result := dsc_sub_type;
//end;

function dsc.dsc_ttype: SmallInt;
begin
  Result := dsc_sub_type;
end;

function dsc.isNullable: Boolean;
begin
  Result := (dsc_flags and DSC_nullable) <> 0;
end;

procedure dsc.setNullable(nullable: Boolean);
begin
  if nullable then dsc_flags := dsc_flags or DSC_nullable
  else dsc_flags := dsc_flags and (not (DSC_nullable or DSC_null));
end;

function dsc.isNull: Boolean;
begin
  Result := (dsc_flags and DSC_null) <> 0;
end;

procedure dsc.setNull;
begin
  dsc_flags := dsc_flags or (DSC_null or DSC_nullable);
end;

procedure dsc.clearNull;
begin
  dsc_flags := dsc_flags and (not DSC_null);
end;

function dsc.isBlob: Boolean;
begin
  Result := (dsc_dtype = dtype_blob) or (dsc_dtype = dtype_quad);
end;

function dsc.isExact: Boolean;
begin
  Result := (dsc_dtype = dtype_int128) or (dsc_dtype = dtype_int64) or
			   (dsc_dtype = dtype_long) or (dsc_dtype = dtype_short);
end;

function dsc.isNumeric: Boolean;
begin
  Result := DTYPE_IS_NUMERIC(dsc_dtype);
end;

function dsc.isText: Boolean;
begin
  Result := DTYPE_IS_TEXT(dsc_dtype);
end;

function dsc.isDBKey: Boolean;
begin
  Result := dsc_dtype = dtype_dbkey;
end;

function dsc.isDateTime: Boolean;
begin
  Result := DTYPE_IS_DATE(dsc_dtype);
end;

function dsc.isDateTimeTz: Boolean;
begin
  Result := (dsc_dtype >= dtype_sql_time_tz) and (dsc_dtype <= dtype_ex_timestamp_tz);
end;

function dsc.isDate: Boolean;
begin
  Result := dsc_dtype = dtype_sql_date;
end;

function dsc.isTime: Boolean;
begin
  Result := (dsc_dtype = dtype_sql_time) or (dsc_dtype = dtype_sql_time_tz) or (dsc_dtype = dtype_ex_time_tz);
end;

function dsc.isTimeStamp: Boolean;
begin
  Result := (dsc_dtype = dtype_timestamp) or (dsc_dtype = dtype_timestamp_tz) or (dsc_dtype = dtype_ex_timestamp_tz);
end;

function dsc.isDecFloat: Boolean;
begin
  Result := DTYPE_IS_DECFLOAT(dsc_dtype);
end;

function dsc.isInt128: Boolean;
begin
  Result := dsc_dtype = dtype_int128;
end;

function dsc.isDecOrInt: Boolean;
begin
  Result := isDecFloat or isExact;
end;

function dsc.isDecOrInt128: Boolean;
begin
  Result := isDecFloat or isInt128;
end;

function dsc.is128: Boolean;
begin
  Result := (dsc_dtype = dtype_dec128) or (dsc_dtype = dtype_int128);
end;

function dsc.isApprox: Boolean;
begin
  Result := DTYPE_IS_APPROX(dsc_dtype);
end;

function dsc.isUnknown: Boolean;
begin
  Result := dsc_dtype = dtype_unknown;
end;

function dsc.getBlobSubType: SmallInt;
begin
  Result := isc_blob_text;
  if isBlob then Result := dsc_sub_type;
end;

function dsc.getSubType: SmallInt;
begin
  Result := 0;
  if isBlob or isExact then Result := dsc_sub_type;
end;

procedure dsc.setBlobSubType(subType: SmallInt);
begin
  if isBlob then dsc_sub_type := subType;
end;

function dsc.getCharSet: Byte;
begin
  Result := CS_NONE;
  if isText then
    Result := dsc_sub_type and $FF
  else if isBlob then begin
    if dsc_sub_type = isc_blob_text then Result := dsc_scale
    else Result := CS_BINARY;
  end else if isDBKey then
    Result := CS_BINARY;
end;

function dsc.getTextType: Word;
begin
  Result := CS_NONE;
  if isText then
    Result := dsc_sub_type
  else if isBlob then begin
    if dsc_sub_type = isc_blob_text then Result := dsc_scale or (dsc_flags and $FF00)
    else Result := CS_BINARY;
  end else if isDBKey then
    Result := CS_BINARY;
end;

procedure dsc.setTextType(ttype: Word);
begin
  if isText then dsc_sub_type := ttype
  else if isBlob and (dsc_sub_type = isc_blob_text) then begin
    dsc_scale := ttype and $FF;
    dsc_flags := (dsc_flags and $FF) or (ttype and $FF00);
  end;
end;

function dsc.getCollation: Word;
begin
  Result := getTextType shr 8;
end;

procedure dsc.clear;
begin
  Self := Create;
end;

procedure dsc.clearFlags;
begin
  if isBlob and (dsc_sub_type = isc_blob_text) then dsc_flags := dsc_flags and $FF00
  else dsc_flags := 0;
end;

procedure dsc.makeBlob(subType: SmallInt; ttype: Word; address: PISC_QUAD = nil);
begin
  clear;
  dsc_dtype := dtype_blob;
  dsc_length := sizeof(ISC_QUAD);
  setBlobSubType(subType);
  setTextType(ttype);
  dsc_address := @Byte(address);
end;

procedure dsc.makeDate(address: PISC_DATE = nil);
begin
  clear;
  dsc_dtype := dtype_sql_date;
  dsc_length := sizeof(ISC_DATE);
  dsc_address := @Byte(address);
end;

procedure dsc.makeDBKey(address: Pointer = nil);
begin
  clear;
  dsc_dtype := dtype_dbkey;
  dsc_length := sizeof(ISC_QUAD);
  dsc_address := @Byte(address);
end;

procedure dsc.makeDouble(address: PDouble = nil);
begin
  clear;
  dsc_dtype := dtype_double;
  dsc_length := sizeof(Double);
  dsc_address := @Byte(address);
end;

//procedure dsc.makeDecimal64(address: PDecimal64 = nil);
//begin
//  clear;
//  dsc_dtype := dtype_dec64;
//  dsc_length := sizeof(Decimal64);
//  dsc_address := @Byte(address);
//end;

//procedure dsc.makeDecimal128(address: PDecimal128 = nil);
//begin
//  clear;
//  dsc_dtype := dtype_dec128;
//  dsc_length := sizeof(Decimal128);
//  dsc_address := @Byte(address);
//end;

procedure dsc.makeInt64(scale: ShortInt; address: PInt64 = nil);
begin
  clear;
  dsc_dtype := dtype_int64;
  dsc_length := sizeof(Int64);
  dsc_scale := scale;
  dsc_address := @Byte(address);
end;

//procedure dsc.makeInt128(scale: ShortInt; address: PInt128 = nil);
//begin
//  clear;
//  dsc_dtype := dtype_int128;
//  dsc_length := sizeof(Int128);
//  dsc_scale := scale;
//  dsc_address := @Byte(address);
//end;

procedure dsc.makeLong(scale: ShortInt; address: PLongInt = nil);
begin
  clear;
  dsc_dtype := dtype_long;
  dsc_length := sizeof(LongInt);
  dsc_scale := scale;
  dsc_address := @Byte(address);
end;

procedure dsc.makeBoolean(address: PByte = nil);
begin
  clear;
  dsc_dtype := dtype_boolean;
  dsc_length := sizeof(Byte);
  dsc_address := @address;
end;

procedure dsc.makeNullString;
begin
  clear;

  // CHAR(1) CHARSET SET NONE
  dsc_dtype := dtype_text;
  setTextType(CS_NONE);
  dsc_length := 1;
  dsc_flags := DSC_nullable or DSC_null;
end;

procedure dsc.makeShort(scale: ShortInt; address: PSmallInt = nil);
begin
  clear;
  dsc_dtype := dtype_short;
  dsc_length := sizeof(SmallInt);
  dsc_scale := scale;
  dsc_address := @Byte(address);
end;

procedure dsc.makeText(length: Word; ttype: Word; address: PByte = nil);
begin
  clear;
  dsc_dtype := dtype_text;
  dsc_length := length;
  setTextType(ttype);
  dsc_address := @address;
end;

procedure dsc.makeTime(address: PISC_TIME = nil);
begin
  clear;
  dsc_dtype := dtype_sql_time;
  dsc_length := sizeof(ISC_TIME);
  dsc_scale := 0;
  dsc_address := @Byte(address);
end;

procedure dsc.makeTimeTz(address: PISC_TIME_TZ = nil);
begin
  clear;
  dsc_dtype := dtype_sql_time_tz;
  dsc_length := sizeof(ISC_TIME_TZ);
  dsc_scale := 0;
  dsc_address := @Byte(address);
end;

procedure dsc.makeTimeTzEx(address: PISC_TIME_TZ_EX = nil);
begin
  clear;
  dsc_dtype := dtype_ex_time_tz;
  dsc_length := sizeof(ISC_TIME_TZ_EX);
  dsc_scale := 0;
  dsc_address := @Byte(address);
end;

procedure dsc.makeTimeStamp(address: PISC_TIMESTAMP = nil);
begin
  clear;
  dsc_dtype := dtype_timestamp;
  dsc_length := sizeof(ISC_TIMESTAMP);
  dsc_scale := 0;
  dsc_address := @Byte(address);
end;

procedure dsc.makeTimeStampTz(address: PISC_TIMESTAMP_TZ = nil);
begin
  clear;
  dsc_dtype := dtype_timestamp_tz;
  dsc_length := sizeof(ISC_TIMESTAMP_TZ);
  dsc_scale := 0;
  dsc_address := @byte(address);
end;

procedure dsc.makeTimeStampTzEx(address: PISC_TIMESTAMP_TZ_EX = nil);
begin
  clear;
  dsc_dtype := dtype_ex_timestamp_tz;
  dsc_length := sizeof(ISC_TIMESTAMP_TZ_EX);
  dsc_scale := 0;
  dsc_address := @Byte(address);
end;

procedure dsc.makeVarying(length: Word; ttype: Word; address: PByte = nil);
begin
  clear;
  dsc_dtype := dtype_varying;
  dsc_length := sizeof(Word) + length;
  if dsc_length < length then begin
    // overflow - avoid segfault
    dsc_length := Word($FFFF);
  end;
  setTextType(ttype);
  dsc_address := @Byte(address);
end;

function dsc.getStringLength: Integer;
begin

end;

class operator dsc.Implicit(const od: &Descriptor): dsc;
begin
  Result.dsc_dtype := od.dsc_dtype;
  Result.dsc_scale := od.dsc_scale;
  Result.dsc_length := od.dsc_length;
  Result.dsc_sub_type := od.dsc_sub_type;
  Result.dsc_flags := od.dsc_flags;
  Result.dsc_address := @Byte(LongInt(od.dsc_offset));
end;

class operator dsc.Implicit(myRecord: dsc): Descriptor;
begin
{$ifdef DEV_BUILD}
		address32bit();
{$endif}
  Result.dsc_dtype := myRecord.dsc_dtype;
  Result.dsc_scale := myRecord.dsc_scale;
  Result.dsc_length := myRecord.dsc_length;
  Result.dsc_sub_type := myRecord.dsc_sub_type;
  Result.dsc_flags := myRecord.dsc_flags;
  Result.dsc_offset := Cardinal(LongInt(myRecord.dsc_address));
end;

{$ifdef DEV_BUILD}
procedure dsc.address32bit;
begin

end;
{$endif}

function dsc.typeToText: PWideChar;
begin

end;

procedure dsc.getSQLInfo(sqlLength: PLongInt; sqlSubType: PLongInt; sqlScale: PLongInt; sqlType: PLongInt);
begin

end;
{$endif}

function DSC_GET_CHARSET(const desc: &dsc): SmallInt;
begin
  Result := desc.dsc_sub_type and $00FF;
end;

function DSC_GET_COLLATE(const desc: &dsc): SmallInt;
begin
  Result := desc.dsc_sub_type shr 8;
end;

(* function DSC_EQUIV(const d1: &dsc; const d2: &dsc; check_collate: Boolean): Boolean;
begin
  if (((alt_dsc^) d1)->dsc_combined_type == ((alt_dsc^) d2)->dsc_combined_type)
	{
		if ((d1->dsc_dtype >= dtype_text && d1->dsc_dtype <= dtype_varying) ||
			d1->dsc_dtype == dtype_blob)
		{
			if (d1->getCharSet() == d2->getCharSet())
			{
				if (check_collate)
					return d1->getCollation() == d2->getCollation();

				return true;
			}

			return false;
		}

		return true;
	}

	return false;
end; *)

function TEXT_LEN(const desc: &dsc): Word;
begin
  Result := desc.dsc_length - sizeof(Word);
  if desc.dsc_dtype = dtype_text then Result := desc.dsc_length
  else if desc.dsc_dtype = dtype_cstring then Result := desc.dsc_length - 1;
end;

function NUMERIC_SCALE(const desc: dsc): ShortInt;
begin
  Result := desc.dsc_scale;
  if DTYPE_IS_TEXT(desc.dsc_dtype) then Result := 0;
end;

end.
