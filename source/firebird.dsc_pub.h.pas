unit firebird.dsc_pub.h;

(*
 *	PROGRAM:	JRD access method
 *	MODULE:		dsc.h
 *	DESCRIPTION:	Definitions associated with descriptors
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
 *)

//#ifndef FIREBIRD_IMPL_DSC_PUB_H
//#define FIREBIRD_IMPL_DSC_PUB_H

interface

(*
 * The following flags are used in an internal structure dsc (dsc.h) or in the external one paramdsc (ibase.h)
 *)

(* values for dsc_flags
 * Note: DSC_null is only reliably set for local variables (blr_variable)
 *)

const DSC_null       = 1;
const DSC_no_subtype = 2; (* dsc has no sub type specified *)
const DSC_nullable   = 4; (* not stored. instead, is derived
                             from metadata primarily to flag
                             SQLDA (in DSQL)               *)

const dtype_unknown = 0;
const dtype_text    = 1;
const dtype_cstring = 2;
const dtype_varying	= 3;

const dtype_packed          = 6;
const dtype_byte            = 7;
const dtype_short           = 8;
const dtype_long            = 9;
const dtype_quad            = 10;
const dtype_real            = 11;
const dtype_double          = 12;
const dtype_d_float         = 13;
const dtype_sql_date        = 14;
const dtype_sql_time        = 15;
const dtype_timestamp       = 16;
const dtype_blob            = 17;
const dtype_array           = 18;
const dtype_int64           = 19;
const dtype_dbkey           = 20;
const dtype_boolean         = 21;
const dtype_dec64           = 22;
const dtype_dec128          = 23;
const dtype_int128          = 24;
const dtype_sql_time_tz     = 25;
const dtype_timestamp_tz    = 26;
const dtype_ex_time_tz      = 27;
const dtype_ex_timestamp_tz = 28;
const DTYPE_TYPE_MAX        = 29;

const ISC_TIME_SECONDS_PRECISION = 10000;
const ISC_TIME_SECONDS_PRECISION_SCALE = (-4);

implementation

end.
