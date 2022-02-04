unit firebird.sqlda_pub.h;

interface

uses firebird.types_pub.h;

(*
 *	PROGRAM:	C preprocessor
 *	MODULE:		sqlda_pub.h
 *	DESCRIPTION:	Public DSQL definitions (included in ibase.h)
 *
 * The contents of this filename are subject to the Interbase Public
 * License Version 1.0 (the 'License'); you may not use this filename
 * except in compliance with the License. You may obtain a copy
 * of the License at http://www.Inprise.com/IPL.html
 *
 * Software distributed under the License is distributed on an
 * 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, either express
 * or implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The Original Code was created by Inprise Corporation
 * and its predecessors. Portions created by Inprise Corporation are
 * Copyright (C) Inprise Corporation.
 *
 * All Rights Reserved.
 * Contributor(s): ______________________________________.
 *)

//ifndef DSQL_SQLDA_PUB_H
//const DSQL_SQLDA_PUB_H =;

(* Definitions for DSQL free_statement routine *)

const DSQL_close     = 1;
const DSQL_drop      = 2;
const DSQL_unprepare = 4;

(* Declare the extended SQLDA *)

type
  XSQLVAR = record
    sqltype:          ISC_SHORT;                    (* datatype of field *)
    sqlscale:         ISC_SHORT;                    (* scale factor *)
    sqlsubtype:       ISC_SHORT;                    (* datatype subtype - currently BLOBs only *)
    sqllen:           ISC_SHORT;                    (* length of data area *)
    sqldata:          PISC_SCHAR;                   (* address of data *)
    sqlind:           PISC_SHORT;                   (* address of indicator variable *)
    sqlname_length:   ISC_SHORT;                    (* length of sqlname field *)
    sqlname:          array[0..32-1] of ISC_SCHAR;  (* name of field, name length + space for NULL *)
    relname_length:   ISC_SHORT;                    (* length of relation name *)
    relname:          array[0..32-1] of ISC_SCHAR;  (* field's relation name + space for NULL *)
    ownname_length:   ISC_SHORT;                    (* length of owner name *)
    ownname:          array[0..32-1] of ISC_SCHAR;  (* relation's owner name + space for NULL *)
    aliasname_length: ISC_SHORT;                    (* length of alias name *)
    aliasname:        array[0..32-1] of ISC_SCHAR;  (* relation's alias name + space for NULL *)
  end;
  PXSQLVAR = ^XSQLVAR;

const SQLDA_VERSION1 = 1;

type
  XSQLDA = record
    version:     ISC_SHORT;                (* version of this me field *)
    sqldaid:     array[0..7] of ISC_SCHAR; (* XSQLDA name field *)
    sqldabc:     ISC_LONG;                 (* length in bytes of SQLDA *)
    sqln:        ISC_SHORT;                (* number of fields allocated *)
    sqld:        ISC_SHORT;                (* actual number of fields *)
    sqlvar:      array[0..0] of XSQLVAR;   (* first field address *)
  end;
  PXSQLDA = ^XSQLDA;

//const XSQLDA_LENGTH(n) = (SizeOf (XSQLDA) + (n - 1) * SizeOf (XSQLVAR));
function XSQLDA_LENGTH(n: smallint): longint;

const SQL_TEXT                  = 452;
const SQL_VARYING               = 448;
const SQL_SHORT                 = 500;
const SQL_LONG                  = 496;
const SQL_FLOAT                 = 482;
const SQL_DOUBLE                = 480;
const SQL_D_FLOAT               = 530;
const SQL_TIMESTAMP             = 510;
const SQL_BLOB                  = 520;
const SQL_ARRAY                 = 540;
const SQL_QUAD                  = 550;
const SQL_TYPE_TIME             = 560;
const SQL_TYPE_DATE             = 570;
const SQL_INT64                 = 580;
const SQL_TIMESTAMP_TZ_EX       = 32748;
const SQL_TIME_TZ_EX            = 32750;
const SQL_INT128                = 32752;
const SQL_TIMESTAMP_TZ          = 32754;
const SQL_TIME_TZ               = 32756;
const SQL_DEC16                 = 32760;
const SQL_DEC34                 = 32762;
const SQL_BOOLEAN               = 32764;
const SQL_NULL                  = 32766;

(* Historical alias for pre v6 code *)
const SQL_DATE                  = SQL_TIMESTAMP;

(***************************)
(* SQL Dialects            *)
(***************************)

const SQL_DIALECT_V5            = 1;          (* meaning is same as DIALECT_xsqlda *)
const SQL_DIALECT_V6_TRANSITION = 2;          (* flagging anything that is delimited
                                                 by Double quotes as an error and
                                                 flagging keyword DATE as an error *)
const SQL_DIALECT_V6            = 3;          (* supports SQL delimited identifier,
                                                 SQLDATE/DATE, TIME, TIMESTAMP,
                                                 CURRENT_DATE, CURRENT_TIME,
                                                 CURRENT_TIMESTAMP, and 64-bit exact
                                                 numeric ctype *)
const SQL_DIALECT_CURRENT       = SQL_DIALECT_V6; (* latest IB DIALECT *)

//endif (* DSQL_SQLDA_PUB_H *)

implementation

function XSQLDA_LENGTH(n: smallint): longint;
begin
  Result := ( SizeOf( XSQLDA ) + (n - 1) * SizeOf( XSQLVAR ) );
end;

end.
