unit firebird.ibase.h;

interface

uses firebird.types_pub.h, firebird.sqlda_pub.h;

(*
 * MODULE:  ibase.h
 * DESCRIPTION: OSRI entrypoints and defines
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
 *
 * 2001.07.28: John Bellardo:  Added blr_skip
 * 2001.09.18: Ann Harrison:   New info codes
 * 17-Oct-2001 Mike Nordell: CPU affinity
 * 2001-04-16 Paul Beach: ISC_TIME_SECONDS_PRECISION_SCALE modified for HP10
 * Compiler Compatibility
 * 2002.02.15 Sean Leyne - Code Cleanup, removed obsolete ports:
 *                          - EPSON, XENIX, MAC (MAC_AUX), Cray and OS/2
 * 2002.10.29 Nickolay Samofatov: Added support for savepoints
 *
 * 2002.10.29 Sean Leyne - Removed support for obsolete IPX/SPX Protocol
 *
 * 2006.09.06 Steve Boyd - Added various prototypes required by Cobol ESQL
 *                         isc_embed_dsql_length
 *                         isc_event_block_a
 *                         isc_sqlcode_s
 *                         isc_embed_dsql_fetch_a
 *                         isc_event_block_s
 *                         isc_baddress
 *                         isc_baddress_s
 *
 *)

//ifndef FIREBIRD_IBASE_H
//const FIREBIRD_IBASE_H =;

const FB_API_VER = 40;
//const isc_version4 =;

const ISC_TRUE = 1;
const ISC_FALSE = 0;
//if  not (defined __cplusplus)
const ISC__TRUE = ISC_TRUE;
const ISC__FALSE = ISC_FALSE;
//endif

//const ISC_FAR =;

//if defined _MSC_VER  and  _MSC_VER >= 1300
//const FB_API_DEPRECATED = __declspec(deprecated);
//elif defined __GNUC__  and  (__GNUC__ > 3 or (__GNUC__  =  3  and  __GNUC_MINOR__ >= 2))
//const FB_API_DEPRECATED = __attribute__((__deprecated__));
//else
//const FB_API_DEPRECATED =;
//endif

//if defined(WIN32) || defined(_WIN32) || defined(__WIN32__)
//define FB_DLL_EXPORT __declspec(dllexport)
//elif defined __has_attribute
//if __has_attribute (visibility)
//define FB_DLL_EXPORT __attribute__ ((visibility("default")))
//else
//define FB_DLL_EXPORT
//endif
//else
//define FB_DLL_EXPORT
//endif

//include "./firebird/impl/types_pub.h"

(***********************)
(* Firebird misc types *)
(***********************)

type isc_callback = procedure; stdcall;
type isc_resv_handle = ISC_LONG;
     pisc_resv_handle = ^isc_resv_handle;

type ISC_PRINT_CALLBACK = procedure(a: Pointer; b: ISC_SHORT; const c: PChar); stdcall;
type ISC_VERSION_CALLBACK = procedure(a: Pointer; const c: PChar); stdcall;
type ISC_EVENT_CALLBACK = procedure(a: Pointer; b: ISC_USHORT; const c: PISC_UCHAR); stdcall;

(*******************************************************************)
(* Blob id structure                                               *)
(*******************************************************************)

//if  not (defined __cplusplus)
type GDS__QUAD = GDS_QUAD;
//endif (* !(defined __cplusplus) *)

type
  ISC_ARRAY_BOUND = record
    array_bound_lower: SmallInt;
    array_bound_upper: SmallInt;
  end;

type
  PISC_ARRAY_DESC = ^ISC_ARRAY_DESC;
  ISC_ARRAY_DESC = record
    array_desc_dtype:            ISC_UCHAR;
    array_desc_scale:            ISC_SCHAR;
    array_desc_length:           Word;
    array_desc_field_name:       array[0..32-1] of ISC_SCHAR;
    array_desc_relation_name:    array[0..32-1] of ISC_SCHAR;
    array_desc_dimensions:       SmallInt;
    array_desc_flags:            SmallInt;
    array_desc_bounds:           array[0..16-1] of ISC_ARRAY_BOUND;
  end;

type
  PISC_BLOB_DESC = ^ISC_BLOB_DESC;
  ISC_BLOB_DESC = record
    blob_desc_subtype:        SmallInt;
    blob_desc_charset:        SmallInt;
    blob_desc_segment_size:   SmallInt;
    blob_desc_field_name:     array[0..32-1] of ISC_UCHAR;
    blob_desc_relation_name:  array[0..32-1] of ISC_UCHAR;
  end;

(***************************)
(* Blob control structure  *)
(***************************)

type
  pisc_blob_ctl = ^ISC_BLOB_CTL;
  ISC_BLOB_CTL = record
    ctl_source:           function: ISC_STATUS;       (* Source filter *)
    ctl_source_handle:    pisc_blob_ctl;              (* Argument to pass to source filter *)
    ctl_to_sub_type:      SmallInt;                   (* Target ctype *)
    ctl_from_sub_type:    SmallInt;                   (* Source ctype *)
    ctl_buffer_length:    Word;                       (* Length of buffer *)
    ctl_segment_length:   Word;                       (* Length of current segment *)
    ctl_bpb_length:       Word;                       (* Length of blob parameter  block *)
    (* Internally, this is const UCHAR*, but this public struct probably can't change. *)
    ctl_bpb:              PISC_SCHAR;                 (* Address of blob parameter block *)
    ctl_buffer:           PISC_UCHAR;                 (* Address of segment buffer *)
    ctl_max_segment:      ISC_LONG;                   (* Length of longest segment *)
    ctl_number_segments:  ISC_LONG;                   (* Total number of segments *)
    ctl_total_length:     ISC_LONG;                   (* Total length of blob *)
    ctl_status:           PISC_STATUS;                (* Address of status vector *)
    ctl_data:             array[0..8-1] of LongInt;   (* Application specific data *)
  end;

(***************************)
(* Blob stream definitions *)
(***************************)

type
  BSTREAM = record
   bstr_blob:     isc_blob_handle;  (* Blob handle *)
   bstr_buffer:   PISC_SCHAR;       (* Address of buffer *)
   bstr_ptr:      PISC_SCHAR;       (* Next character *)
   bstr_length:   SmallInt;         (* Length of buffer *)
   bstr_cnt:      SmallInt;         (* Characters in buffer *)
   bstr_mode:     Char;             (* (mode) ? OUTPUT : INPUT *)
  end;
  FB_BLOB_STREAM = ^BSTREAM;

(* Three ugly macros, one even using octal radix... sigh... *)
//const getb(p) (--(p)^.bstr_cnt >= 0 ? *(p)^.bstr_ptr++ and 0377: BLOB_get (p))
//const putb(x,p) (((x) = '' or ( not (--(p)^.bstr_cnt))) ? BLOB_put ((x),p) : ((integer) ((p)^.bstr_ptr++ = (Word) (x))))
//const putbx(x,p) (( not (--(p)^.bstr_cnt)) ? BLOB_put ((x),p) : ((integer) ((p)^.bstr_ptr++ = (Word) (x))))

(********************************************************************)
(* CVC: Public blob interface definition held in val.h.             *)
(* For some unknown reason, it was only documented in langRef       *)
(* and being the structure passed by the engine to UDFs it never    *)
(* made its way into this public definitions file.                  *)
(* Being its original name "blob", I renamed it blobcallback here.  *)
(* I did the full definition with the proper parameters instead of  *)
(* the weak C declaration with any number and type of parameters.   *)
(* Since the first parameter -BLB- is unknown outside the engine,   *)
(* it's more accurate to use void* than int* as the blob pointer    *)
(********************************************************************)

//if  not defined(JRD_VAL_H)
(* Blob passing structure *)

(* This enum applies to parameter "mode" in blob_lseek *)
type blob_lseek_mode = (blb_seek_relative = 1, blb_seek_from_tail = 2);
(* This enum applies to the value returned by blob_get_segment *)
type blob_get_result = (blb_got_fragment = -1, blb_got_eof = 0, blb_got_full_segment = 1);

type
  BLOBCALLBACK = record
    blob_get_segment:       function(hnd: Pointer; buffer: PISC_UCHAR; buf_size: ISC_USHORT; result_len: PISC_USHORT): SmallInt;
    blob_handle:            Pointer;
    blob_number_segments:   ISC_LONG;
    blob_max_segment:       ISC_LONG;
    blob_total_length:      ISC_LONG;
    blob_put_segment:       procedure(hnd: Pointer; const buffer: PISC_UCHAR; buf_size: ISC_USHORT);
    blob_lseek:             function(hnd: Pointer; mode: ISC_USHORT; offset: ISC_LONG): ISC_LONG;
 end;
//endif (* !defined(JRD_VAL_H) *)


(********************************************************************)
(* CVC: Public descriptor interface held in dsc2.h.                  *)
(* We need it documented to be able to recognize NULL in UDFs.      *)
(* Being its original name "dsc", I renamed it paramdsc here.       *)
(* Notice that I adjust to the original definition: contrary to     *)
(* other cases, the typedef is the same struct not the pointer.     *)
(* I included the enumeration of dsc_dtype possible values.         *)
(* Ultimately, dsc2.h should be part of the public interface.        *)
(********************************************************************)

//if  not defined(JRD_DSC_H)
(* This is the famous internal descriptor that UDFs can use, too. *)
type
  PARAMDSC = record
    dsc_dtype:     ISC_UCHAR;
    dsc_scale:     ShortInt;
    dsc_length:    ISC_USHORT;
    dsc_sub_type:  SmallInt;
    dsc_flags:     ISC_USHORT;
    dsc_address:   PISC_UCHAR;
  end;

//if  not defined(JRD_VAL_H)
(* This is a helper struct to work with varchars. *)
type
  PARAMVARY = record
    vary_length: ISC_USHORT;
    vary_string: array[0..0] of ISC_UCHAR;
  end;
//endif (* !defined(JRD_VAL_H) *)

//include './firebird/impl/dsc_pub.h'

//endif (* !defined(JRD_DSC_H) *)

(***************************)
(* Dynamic SQL definitions *)
(***************************)

//include './firebird/impl/sqlda_pub.h'

(***************************)
(* OSRI database functions *)
(***************************)

//#ifdef __cplusplus
// 'C' begin
//endif

type
  Tisc_attach_database = function(
    status_vector:     PISC_STATUS;
    file_length:       SmallInt;
    const file_name:   PISC_SCHAR;
    public_handle:     pisc_db_handle;
    dpb_length:        SmallInt;
    const dpb:         PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_array_gen_sdl = function(
    status_vector:     PISC_STATUS;
    const a:           PISC_ARRAY_DESC;
    b:                 PISC_SHORT;
    c:                 PISC_UCHAR;
    d:                 PISC_SHORT
  ): ISC_STATUS; stdcall;

  Tisc_array_get_slice = function(
    status_vector:     PISC_STATUS;
    a:                 pisc_db_handle;
    b:                 pisc_tr_handle;
    c:                 PISC_QUAD;
    const d:           PISC_ARRAY_DESC;
    e:                 Pointer;
    f:                 PISC_LONG
  ): ISC_STATUS; stdcall;

  Tisc_array_lookup_bounds = function(
    status_vector:     PISC_STATUS;
    a:                 pisc_db_handle;
    b:                 pisc_tr_handle;
    const c:           PISC_SCHAR;
    const d:           PISC_SCHAR;
    e:                 PISC_ARRAY_DESC
  ): ISC_STATUS; stdcall;

  Tisc_array_lookup_desc = function(
    status_vector:     PISC_STATUS;
    a:                 pisc_db_handle;
    b:                 pisc_tr_handle;
    const c:           PISC_SCHAR;
    const d:           PISC_SCHAR;
    e:                 PISC_ARRAY_DESC
  ): ISC_STATUS; stdcall;

  Tisc_array_set_desc = function(
    status_vector:     PISC_STATUS;
    const a:           PISC_SCHAR;
    const b:           PISC_SCHAR;
    const c:           PSmallInt;
    const d:           PSmallInt;
    const e:           PSmallInt;
    f:                 PISC_ARRAY_DESC
  ): ISC_STATUS; stdcall;

  Tisc_array_put_slice = function(
    status_vector:     PISC_STATUS;
    a:                 pisc_db_handle;
    b:                 pisc_tr_handle;
    c:                 PISC_QUAD;
    const d:           PISC_ARRAY_DESC;
    e:                 Pointer;
    f:                 PISC_LONG
  ): ISC_STATUS; stdcall;

  Tisc_blob_default_desc = procedure(
    a:                 PISC_BLOB_DESC;
    const b:           PISC_UCHAR;
    const c:           PISC_UCHAR
  ); stdcall;

  Tisc_blob_gen_bpb = function(
    status_vector:     PISC_STATUS;
    const a:           PISC_BLOB_DESC;
    const b:           PISC_BLOB_DESC;
    c:                 Word;
    d:                 PISC_UCHAR;
    e:                 PWord
  ): ISC_STATUS; stdcall;

  Tisc_blob_info = function(
    status_vector:     PISC_STATUS;
    isc_blob_handle:   pisc_blob_handle;
    item_length:       SmallInt;
    const items:       PISC_SCHAR;
    buffer_length:     SmallInt;
    buffer:            PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_blob_lookup_desc = function(
    status_vector:     PISC_STATUS;
    a:                 pisc_db_handle;
    b:                 pisc_tr_handle;
    const c:           PISC_UCHAR;
    const d:           PISC_UCHAR;
    e:                 PISC_BLOB_DESC;
    f:                 PISC_UCHAR
  ): ISC_STATUS; stdcall;

  Tisc_blob_set_desc = function(
    status_vector:     PISC_STATUS;
    const a:           PISC_UCHAR;
    const b:           PISC_UCHAR;
    c:                 SmallInt;
    d:                 SmallInt;
    e:                 SmallInt;
    f:                 PISC_BLOB_DESC
  ): ISC_STATUS; stdcall;

  Tisc_cancel_blob = function(
    status_vector:     PISC_STATUS;
    blob_handle:       pisc_blob_handle
  ): ISC_STATUS; stdcall;


  Tisc_cancel_events = function(
    status_vector:     PISC_STATUS;
    a:                 pisc_db_handle;
    b:                 PISC_LONG
  ): ISC_STATUS; stdcall;

  Tisc_close_blob = function(
    status_vector:     PISC_STATUS;
    blob_handle:       pisc_blob_handle
  ): ISC_STATUS; stdcall;

  Tisc_commit_retaining = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle
  ): ISC_STATUS; stdcall;

  Tisc_commit_transaction = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle
  ): ISC_STATUS; stdcall;

  Tisc_create_blob = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    tr_handle:         pisc_tr_handle;
    blob_handle:       pisc_blob_handle;
    blob_id:           PISC_QUAD
  ): ISC_STATUS; stdcall;

  Tisc_create_blob2 = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    tr_handle:         pisc_tr_handle;
    blob_handle:       pisc_blob_handle;
    blob_id:           PISC_QUAD;
    bpb_length:        SmallInt;
    const bpb:         PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_create_database = function(
    status_vector:     PISC_STATUS;
    a:                 Word;
    const b:           PISC_SCHAR;
    c:                 pisc_db_handle;
    d:                 Word;
    const e:           PISC_SCHAR;
    f:                 Word
  ): ISC_STATUS; stdcall;

  Tisc_database_info = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    info_len:          SmallInt;
    const info:        PISC_SCHAR;
    res_len:           SmallInt;
    res:               PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_decode_date = procedure(
    const date:        PISC_QUAD;
    times_arg:         pointer
  ); stdcall;

  Tisc_decode_sql_date = procedure(
    const date:        PISC_DATE;
    times_arg:         pointer
  ); stdcall;

  Tisc_decode_sql_time = procedure(
    const sql_time:    PISC_TIME;
    times_args:        pointer
  ); stdcall;

  Tisc_decode_timestamp = procedure(
    const date:        PISC_TIMESTAMP;
    times_arg:         pointer
  ); stdcall;

  Tisc_detach_database = function(
    status_vector:     PISC_STATUS;
    public_handle:     pisc_db_handle
  ): ISC_STATUS; stdcall;

  Tisc_drop_database = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle
  ): ISC_STATUS; stdcall;

  Tisc_dsql_allocate_statement = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    stmt_handle:       pisc_stmt_handle
  ): ISC_STATUS; stdcall;

  Tisc_dsql_alloc_statement2 = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    stmt_handle:       pisc_stmt_handle
  ): ISC_STATUS; stdcall;

  Tisc_dsql_describe = function(
    status_vector:     PISC_STATUS;
    stmt_handle:       pisc_stmt_handle;
    dialect:           Word;
    sqlda:             PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_dsql_describe_bind = function(
    status_vector:     PISC_STATUS;
    stmt_handle:       pisc_stmt_handle;
    dialect:           Word;
    sqlda:             PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_dsql_exec_immed2 = function(
    status_vector:     PISC_STATUS;
    a:                 pisc_db_handle;
    b:                 pisc_tr_handle;
    c:                 Word;
    const d:           PISC_SCHAR;
    e:                 Word;
    const f:           PXSQLDA;
    const g:           PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_dsql_execute = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle;
    stmt_handle:       pisc_stmt_handle;
    dialect:           Word;
    const sqlda:       PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_dsql_execute2 = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle;
    stmt_handle:       pisc_stmt_handle;
    dialect:           Word;
    const in_sqlda:    PXSQLDA;
    const out_sqlda:   PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_dsql_execute_immediate = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    tra_handle:        pisc_tr_handle;
    length:            Word;
    const statement:   PISC_SCHAR;
    dialect:           Word;
    const sqlda:       PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_dsql_fetch = function(
    status_vector:     PISC_STATUS;
    stmt_handle:       pisc_stmt_handle;
    da_version:        Word;
    const sqlda:       PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_dsql_finish = function(
    a: pisc_db_handle
  ): ISC_STATUS; stdcall;

  Tisc_dsql_free_statement = function(
    status_vector:     PISC_STATUS;
    stmt_handle:       pisc_stmt_handle;
    option:            Word
  ): ISC_STATUS; stdcall;

  Tisc_dsql_insert = function(
    status_vector:     PISC_STATUS;
    a:                 pisc_stmt_handle;
    b:                 Word;
    d:                 PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_dsql_prepare = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle;
    stmt_handle:       pisc_stmt_handle;
    length:            Word;
    const str:         PISC_SCHAR;
    dialect:           Word;
    sqlda:             PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_dsql_set_cursor_name = function(
    status_vector:     PISC_STATUS;
    stmt_handle:       pisc_stmt_handle;
    const cursor_name: PISC_SCHAR;
    reserve:           Word
  ): ISC_STATUS; stdcall;

  Tisc_dsql_sql_info = function(
    status_vector:     PISC_STATUS;
    stmt_handle:       pisc_stmt_handle;
    items_len:         SmallInt;
    const items:       PISC_SCHAR;
    buffer_len:        SmallInt;
    buffer:            PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tfb_dsql_set_timeout = function(
    status_vector:     PISC_STATUS;
    stmt_handle:       pisc_stmt_handle;
    a:                 ISC_ULONG
  ): ISC_STATUS; stdcall;

  (*Tfb_get_statement_interface = function(
    status_vector:     PISC_STATUS;
    api_handle:        PFB_API_HANDLE;
    a:                 PPointer
  ): ISC_STATUS; stdcall;
  *)

  Tisc_encode_date = procedure(
    const times_arg:   pointer;
    date:              PISC_QUAD
  ); stdcall;

  Tisc_encode_sql_date = procedure(
    const times_arg:   pointer;
    date:              PISC_DATE
  ); stdcall;

  Tisc_encode_sql_time = procedure(
    const times_arg:   pointer;
    isc_time:          PISC_TIME
  ); stdcall;

  Tisc_encode_timestamp = procedure(
    const times_arg:   pointer;
    date:              PISC_TIMESTAMP
  ); stdcall;

  Tisc_event_block = function(
    a:                 PPISC_UCHAR;
    b:                 PPISC_UCHAR;
    c:                 ISC_USHORT;
    d:                 array of const
  ): ISC_LONG; stdcall;

  Tisc_event_block_a = function(
    a:                 PPISC_SCHAR;
    b:                 PPISC_SCHAR;
    c:                 ISC_USHORT;
    d:                 PPISC_SCHAR
  ): ISC_USHORT; stdcall;

  Tisc_event_block_s = procedure(
    a:                 PPISC_SCHAR;
    b:                 PPISC_SCHAR;
    c:                 ISC_USHORT;
    d:                 PPISC_SCHAR;
    e:                 PISC_USHORT
  ); stdcall;

  Tisc_event_counts = procedure(
    a:                 PISC_ULONG;
    b:                 SmallInt;
    c:                 PISC_UCHAR;
    const d:           PISC_UCHAR
  ); stdcall;

(* 17 May 2001 - isc_expand_dpb is DEPRECATED *)
  Tisc_expand_dpb = procedure(
    a:                 PPISC_SCHAR;
    b:                 PSmallInt;
    c:                 array of const
  ); stdcall;

  Tisc_modify_dpb = function(
    a:                 PPISC_SCHAR;
    b:                 PSmallInt;
    c:                 Word;
    const d:           PISC_SCHAR;
    e:                 SmallInt
  ): integer; stdcall;

  Tisc_free = function(
    a:                 PISC_SCHAR
  ): ISC_LONG; stdcall;

  Tisc_get_segment = function(
    status_vector:     PISC_STATUS;
    blob_handle:       pisc_blob_handle;
    length:            pWord;
    buffer_length:     Word;
    buffer:            PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_get_slice = function(
    status_vector:     PISC_STATUS;
    a:                 pisc_db_handle;
    b:                 pisc_tr_handle;
    c:                 PISC_QUAD;
    d:                 Word;
    const e:           PISC_SCHAR;
    f:                 Word;
    const g:           PISC_LONG;
    h:                 ISC_LONG;
    i:                 Pointer;
    j:                 PISC_LONG
  ): ISC_STATUS; stdcall;

(* CVC: This non-const signature is needed for compatibility, see gds.cpp. *)
  Tisc_interprete = function(
    buffer:            PISC_SCHAR;
    status_vector:     PPISC_STATUS
  ): ISC_LONG; stdcall;

(* This const params version used in the engine and other places. *)
  Tfb_interpret = function(
    a:                 PISC_SCHAR;
    b:                 Word;
    const c:           PPISC_STATUS
  ): ISC_LONG; stdcall;

  Tisc_open_blob = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    tr_handle:         pisc_tr_handle;
    blob_handle:       pisc_blob_handle;
    blob_id:           PISC_QUAD
  ): ISC_STATUS; stdcall;

  Tisc_open_blob2 = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    tr_handle:         pisc_tr_handle;
    blob_handle:       pisc_blob_handle;
    blob_id:           PISC_QUAD;
    bpb_length:        ISC_USHORT;
    const bpb:         PISC_UCHAR
  ): ISC_STATUS; stdcall;

  Tisc_prepare_transaction2 = function(
    status_vector:     PISC_STATUS;
    a:                 pisc_tr_handle;
    b:                 ISC_USHORT;
    const c:           PISC_UCHAR
  ): ISC_STATUS; stdcall;

  Tisc_print_sqlerror = procedure(
    a:                 ISC_SHORT;
    const b:           PISC_STATUS
  ); stdcall;

  Tisc_print_status = function(
    const a:           PISC_STATUS
  ): ISC_STATUS; stdcall;

  Tisc_put_segment = function(
    status_vector:     PISC_STATUS;
    blob_handle:       pisc_blob_handle;
    buffer_length:     Word;
    const buffer:      PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_put_slice = function(
    status_vector:     PISC_STATUS;
    a:                 pisc_db_handle;
    b:                 pisc_tr_handle;
    c:                 PISC_QUAD;
    d:                 Word;
    const e:           PISC_SCHAR;
    f:                 Word;
    const g:           PISC_LONG;
    h:                 ISC_LONG;
    i:                 pointer
  ): ISC_STATUS; stdcall;

  Tisc_que_events = function(
    status_vector:     PISC_STATUS;
    a:                 pisc_db_handle;
    b:                 PISC_LONG;
    c:                 Word;
    const d:           PISC_UCHAR;
    e:                 ISC_EVENT_CALLBACK;
    f:                 pointer
  ): ISC_STATUS; stdcall;

  Tisc_rollback_retaining = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle
  ): ISC_STATUS; stdcall;

  Tisc_rollback_transaction = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle
  ): ISC_STATUS; stdcall;

  Tisc_start_multiple = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle;
    count:             SmallInt;
    vec:               pointer
  ): ISC_STATUS; stdcall;

  Tisc_start_transaction = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle;
    count:             SmallInt;
    Args:              array of const
  ): ISC_STATUS; stdcall;

  Tfb_disconnect_transaction = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle
  ): ISC_STATUS; stdcall;

  Tisc_sqlcode = function(
    const status_vector: PISC_STATUS
  ): ISC_LONG; stdcall;

  Tisc_sqlcode_s = procedure(
    const status_vector: PISC_STATUS;
    a:                 PISC_ULONG
  ); stdcall;

  Tfb_sqlstate = procedure(
    a:                 PShortInt;
    const status_vector: PISC_STATUS
  ); stdcall;

  Tisc_sql_interprete = procedure(
    a:                 SmallInt;
    b:                 PISC_SCHAR;
    c:                 SmallInt
  ); stdcall;

  Tisc_transaction_info = function(
    status_vector:     PISC_STATUS;
    a:                 pisc_tr_handle;
    b:                 SmallInt;
    const c:           PISC_SCHAR;
    d:                 SmallInt;
    e:                 PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_transact_request = function(
    status_vector:     PISC_STATUS;
    a:                 pisc_db_handle;
    b:                 pisc_tr_handle;
    c:                 Word;
    d:                 PISC_SCHAR;
    e:                 Word;
    f:                 ISC_SCHAR;
    g:                 Word;
    h:                 PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_vax_integer = function(
    const buffer:      PISC_SCHAR;
    len:               SmallInt
  ): ISC_LONG; stdcall;

  Tisc_portable_integer = function(
    const p:           PISC_UCHAR;
    len:               SmallInt
  ): ISC_INT64; stdcall;


(*************************************)
(* Security Functions and structures *)
(*************************************)

const sec_uid_spec               = $01;
const sec_gid_spec               = $02;
const sec_server_spec            = $04;
const sec_password_spec          = $08;
const sec_group_name_spec        = $10;
const sec_first_name_spec        = $20;
const sec_middle_name_spec       = $40;
const sec_last_name_spec         = $80;
const sec_dba_user_name_spec     = $100;
const sec_dba_password_spec      = $200;

const sec_protocol_tcpip         = 1;
const sec_protocol_netbeui       = 2;
const sec_protocol_spx           = 3; (* -- Deprecated Protocol. Declaration retained for compatibility   *)
const sec_protocol_local         = 4;

type
  USER_SEC_DATA = record
    sec_flags:     SmallInt;     (* which fields are specified *)
    uid:           integer;      (* the user's id *)
    gid:           integer;      (* the user's group id *)
    protocol:      integer;      (* protocol to use for connection *)
    server:        PISC_SCHAR;   (* server to administer *)
    user_name:     PISC_SCHAR;   (* the user's name *)
    password:      PISC_SCHAR;   (* the user's password *)
    group_name:    PISC_SCHAR;   (* the group name *)
    first_name:    PISC_SCHAR;   (* the user's first name *)
    middle_name:   PISC_SCHAR;   (* the user's middle name *)
    last_name:     PISC_SCHAR;   (* the user's last name *)
    dba_user_name: PISC_SCHAR;   (* the dba user name *)
    dba_password:  PISC_SCHAR;   (* the dba password *)
  end;

  PUSER_SEC_DATA = ^USER_SEC_DATA;

  Tisc_add_user = function(
    status:            PISC_STATUS;
    const input_user_data: PUSER_SEC_DATA
  ): ISC_STATUS; stdcall;

  Tisc_delete_user = function(
    status:            PISC_STATUS;
    const input_user_data: PUSER_SEC_DATA
  ): ISC_STATUS; stdcall;

  Tisc_modify_user = function(
    status:            PISC_STATUS;
    const input_user_data: PUSER_SEC_DATA
  ): ISC_STATUS; stdcall;

(**********************************)
(*  Other OSRI functions          *)
(**********************************)
  Tisc_compile_request = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    req_handle:        pisc_req_handle;
    blr_length:        ISC_USHORT;
    const blr:         PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_compile_request2 = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    req_handle:        pisc_req_handle;
    blr_length:        Word;
    const blr:         PISC_SCHAR
  ): ISC_STATUS; stdcall;

  // This function always returns error since FB 3.0.
  Tisc_ddl = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    tra_handle:        pisc_tr_handle;
    ddl_length:        SmallInt;
    const ddl:         PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_prepare_transaction = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle
  ): ISC_STATUS; stdcall;


  Tisc_receive = function(
    status_vector:     PISC_STATUS;
    req_handle:        pisc_req_handle;
    msg_type:          ISC_USHORT;
    msg_length:        ISC_USHORT;
    msg:               Pointer;
    req_level:         SmallInt
  ): ISC_STATUS; stdcall;

  Tisc_reconnect_transaction = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    tra_handle:        pisc_tr_handle;
    msg_length:        Word;
    const msg:         PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_release_request = function(
    status_vector:     PISC_STATUS;
    req_handle:        pisc_req_handle
  ): ISC_STATUS; stdcall;

  Tisc_request_info = function(
    status_vector:     PISC_STATUS;
    req_handle:        pisc_req_handle;
    req_level:         SmallInt;
    msg_length:        SmallInt;
    const msg:         PISC_SCHAR;
    buffer_length:     SmallInt;
    buffer:            PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_seek_blob = function(
    status_vector:     PISC_STATUS;
    blob_handle:       pisc_blob_handle;
    mode:              SmallInt;
    offset:            ISC_LONG;
    result_:           PISC_LONG
  ): ISC_STATUS; stdcall;

  Tisc_send = function(
    status_vector:     PISC_STATUS;
    req_handle:        pisc_req_handle;
    msg_type:          Word;
    msg_length:        Word;
    const msg:         Pointer;
    req_level:         SmallInt
  ): ISC_STATUS; stdcall;

  Tisc_start_and_send = function(
    status_vector:     PISC_STATUS;
    req_handle:        pisc_req_handle;
    tra_handle:        pisc_tr_handle;
    msg_type:          ISC_USHORT;
    msg_length:        ISC_USHORT;
    const msg:         Pointer;
    req_level:         SmallInt
  ): ISC_STATUS; stdcall;

  Tisc_start_request = function(
    status_vector:     PISC_STATUS;
    req_handle:        pisc_req_handle;
    tra_handle:        pisc_tr_handle;
    req_level:         SmallInt
  ): ISC_STATUS; stdcall;

  Tisc_unwind_request = function(
    status_vector:     PISC_STATUS;
    req_handle:        pisc_tr_handle;
    req_level:         SmallInt
  ): ISC_STATUS; stdcall;

  Tisc_wait_for_event = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    events_length:     Word;
    const events:      PISC_UCHAR;
    events_update:     PISC_UCHAR
  ): ISC_STATUS; stdcall;

(*****************************)
(* Other Sql functions       *)
(*****************************)

  Tisc_close = function(
    status_vector:     PISC_STATUS;
    const statement_name: PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_declare = function(
    status_vector:     PISC_STATUS;
    const statement_name: PISC_SCHAR;
    const cursor_name: PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_describe = function(
    status_vector:     PISC_STATUS;
    const statement_name: PISC_SCHAR;
    sqlda:             PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_describe_bind = function(
    status_vector:     PISC_STATUS;
    const statement_name: PISC_SCHAR;
    sqlda:             PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_execute = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle;
    const statement_name: PISC_SCHAR;
    sqlda:             PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_execute_immediate = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    tra_handle:        pisc_tr_handle;
    sql_length:        PSmallInt;
    const sql:         PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_fetch = function(
    status_vector:     PISC_STATUS;
    const cursor_name: PISC_SCHAR;
    sqlda:             PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_open = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle;
    const cursor_name: PISC_SCHAR;
    sqlda:             PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_prepare = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    tra_handle:        pisc_tr_handle;
    const statement_name: PISC_SCHAR;
    const sql_length:  PSmallInt;
    const sql:         PISC_SCHAR;
    sqlda:             PXSQLDA
  ): ISC_STATUS; stdcall;

(*************************************)
(* Other Dynamic sql functions       *)
(*************************************)

  Tisc_dsql_execute_m = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle;
    statement_handle:  pisc_stmt_handle;
    a:                 Word;
    const b:           PISC_SCHAR;
    c:                 Word;
    d:                 Word;
    e:                 PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_dsql_execute2_m = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle;
    statement_handle:  pisc_stmt_handle;
    a:                 Word;
    const b:           PISC_SCHAR;
    c:                 Word;
    d:                 Word;
    const e:           PISC_SCHAR;
    f:                 Word;
    g:                 PISC_SCHAR;
    h:                 Word;
    i:                 Word;
    j:                 PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_dsql_execute_immediate_m = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    tra_handle:        pisc_tr_handle;
    a:                 Word;
    const b:           PISC_SCHAR;
    c:                 Word;
    d:                 Word;
    e:                 PISC_SCHAR;
    f:                 Word;
    g:                 Word;
    h:                 PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_dsql_fetch_m = function(
    status_vector:     PISC_STATUS;
    statement_handle:  pisc_stmt_handle;
    a:                 Word;
    b:                 PISC_SCHAR;
    c:                 Word;
    d:                 Word;
    e:                 PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_dsql_insert_m = function(
    status_vactor:     PISC_STATUS;
    statement_handle:  pisc_stmt_handle;
    a:                 Word;
    const b:           PISC_SCHAR;
    c:                 Word;
    d:                 Word;
    const e:           PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_dsql_prepare_m = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle;
    statement_handle:  pisc_stmt_handle;
    a:                 Word;
    const b:           PISC_SCHAR;
    c:                 Word;
    d:                 Word;
    const e:           PISC_SCHAR;
    f:                 Word;
    g:                 PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_dsql_release = function(
    status_vactor:     PISC_STATUS;
    const a:           PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_embed_dsql_close = function(
    status_vector:     PISC_STATUS;
    const a:           PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_embed_dsql_declare = function(
    status_vector:     PISC_STATUS;
    const a:           PISC_SCHAR;
    const b:           PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_embed_dsql_describe = function(
    status_vector:     PISC_STATUS;
    const a:           PISC_SCHAR;
    b:                 Word;
    c:                 PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_embed_dsql_describe_bind = function(
    status_vector:     PISC_STATUS;
    const a:           PISC_SCHAR;
    b:                 Word;
    c:                 PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_embed_dsql_execute = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle;
    const a:           PISC_SCHAR;
    b:                 Word;
    c:                 PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_embed_dsql_execute2 = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle;
    const a:           PISC_SCHAR;
    b:                 Word;
    c:                 PXSQLDA;
    d:                 PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_embed_dsql_execute_immed = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    tra_handle:        pisc_tr_handle;
    a:                 Word;
    const b:           PISC_SCHAR;
    c:                 Word;
    d:                 PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_embed_dsql_fetch = function(
    status_vector:     PISC_STATUS;
    const a:           PISC_SCHAR;
    b:                 Word;
    c:                 PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_embed_dsql_fetch_a = function(
    status_vector:     PISC_STATUS;
    a:                 Pinteger;
    const b:           PISC_SCHAR;
    c:                 ISC_USHORT;
    d:                 PXSQLDA
  ): ISC_STATUS; stdcall;

  isc_embed_dsql_length = procedure(
    const a:           PISC_UCHAR;
    b:                 PISC_USHORT
  );

  Tisc_embed_dsql_open = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle;
    const a:           PISC_SCHAR;
    b:                 Word;
    c:                 PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_embed_dsql_open2 = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle;
    const a:           PISC_SCHAR;
    b:                 Word;
    c:                 PXSQLDA;
    d:                 PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_embed_dsql_insert = function(
    status_vector:     PISC_STATUS;
    const a:           PISC_SCHAR;
    b:                 Word;
    c:                 PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_embed_dsql_prepare = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    tra_handle:        pisc_tr_handle;
    const a:           PISC_SCHAR;
    b:                 Word;
    const c:           PISC_SCHAR;
    d:                 Word;
    e:                 PXSQLDA
  ): ISC_STATUS; stdcall;

  Tisc_embed_dsql_release = function(
    status_vector:     PISC_STATUS;
    const a:           PISC_SCHAR
  ): ISC_STATUS; stdcall;


(******************************)
(* Other Blob functions       *)
(******************************)

  BLOB_open = function(
    a:                 isc_blob_handle;
    b:                 PISC_SCHAR;
    c:                 integer
  ): FB_BLOB_STREAM;

  BLOB_put = function(
    a:                 ISC_SCHAR;
    b:                 FB_BLOB_STREAM
  ): integer;

  BLOB_close = function(a: FB_BLOB_STREAM): integer;

  BLOB_get = function(a: FB_BLOB_STREAM): integer;

  BLOB_display = function(
    a:                 PISC_QUAD;
    db_handle:         isc_db_handle;
    tra_handle:        isc_tr_handle;
    const b:           PISC_SCHAR
  ): integer;

  BLOB_dump = function(
    a:                 PISC_QUAD;
    db_handle:         isc_db_handle;
    tra_handle:        isc_tr_handle;
    const b:           PISC_SCHAR
  ): integer;

  BLOB_edit = function(
    a:                 PISC_QUAD;
    db_handle:         isc_db_handle;
    tra_handle:        isc_tr_handle;
    const b:           PISC_SCHAR
  ): integer;

  BLOB_load = function(
    a:                 PISC_QUAD;
    db_handle:         isc_db_handle;
    tra_handle:        isc_tr_handle;
    const b:           PISC_SCHAR
  ): integer;

  BLOB_text_dump = function(
    a:                 PISC_QUAD;
    db_handle:         isc_db_handle;
    tra_handle:        isc_tr_handle;
    const b:           PISC_SCHAR
  ): integer;

  BLOB_text_load = function(
    a:                 PISC_QUAD;
    db_handle:         isc_db_handle;
    tra_handle:        isc_tr_handle;
    const b:           PISC_SCHAR
  ): integer;

  Bopen = function(
    a:                 PISC_QUAD;
    db_handle:         isc_db_handle;
    tra_handle:        isc_tr_handle;
    const b:           PISC_SCHAR
  ): FB_BLOB_STREAM;


(******************************)
(* Other Misc functions       *)
(******************************)

  Tisc_ftof = function(
    const a:           PISC_SCHAR;
    const b:           Word;
    c:                 PISC_SCHAR;
    const d:           Word
  ): ISC_LONG;

  Tisc_print_blr = function(
    const a:           PISC_SCHAR;
    b:                 ISC_PRINT_CALLBACK;
    c:                 Pointer;
    d:                 SmallInt
  ): ISC_STATUS;

  Tfb_print_blr = function(
    const a:           PISC_UCHAR;
    b:                 ISC_ULONG;
    c:                 ISC_PRINT_CALLBACK;
    d:                 Pointer;
    e:                 SmallInt
  ): integer;

  Tisc_set_debug = procedure(a: integer);

  Tisc_qtoq = procedure(
    const a:           PISC_QUAD;
    b:                 PISC_QUAD
  );

  Tisc_vtof = procedure(
    const a:           PISC_SCHAR;
    b:                 PISC_SCHAR;
    c:                 Word
  );

  Tisc_vtov = procedure(
    const a:           PISC_SCHAR;
    b:                 PISC_SCHAR;
    c:                 SmallInt
  );

  Tisc_version = function(
    db_handle:         pisc_db_handle;
    version_callback:  ISC_VERSION_CALLBACK;
    a:                 Pointer
  ): integer;

  Tisc_reset_fpe = function(a: ISC_USHORT): ISC_LONG;

  Tisc_baddress = function(a: PISC_SCHAR): UInt64;
  Tisc_baddress_s = procedure(
    const a:           PISC_SCHAR;
    b:                 PUInt64
  );

(*****************************************)
(* Service manager functions             *)
(*****************************************)

//const ADD_SPB_LENGTH(p, length) begin *(p)++ = (length); \
//          *(p)++ := (length) shr 8; end;

//const ADD_SPB_NUMERIC(p, data) begin *(p)++ = (ISC_SCHAR) (data); \
//          *(p)++ := (ISC_SCHAR) ((data) shr 8); \
//      *(p)++ := (ISC_SCHAR) ((data) shr 16); \
//      *(p)++ := (ISC_SCHAR) ((data) shr 24); end;

  Tisc_service_attach = function(
    status_vector:     PISC_STATUS;
    service_length:    Word;
    const service:     PISC_SCHAR;
    svc_handle:        pisc_svc_handle;
    spb_length:        Word;
    const spb:         PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_service_detach = function(
    status_vector:     PISC_STATUS;
    svc_handle:        pisc_svc_handle
  ): ISC_STATUS; stdcall;

  Tisc_service_query = function(
    status_vector:     PISC_STATUS;
    svc_handle:        pisc_svc_handle;
    reserved:          pisc_resv_handle;
    send_spb_length:   Word;
    const send_spb:    PISC_SCHAR;
    request_spb_length:Word;
    const request_spb: PISC_SCHAR;
    buffer_length:     Word;
    buffer:            PISC_SCHAR
  ): ISC_STATUS; stdcall;

  Tisc_service_start = function(
    status_vector:     PISC_STATUS;
    svc_handle:        pisc_svc_handle;
    reserved:          pisc_resv_handle;
    spb_length:        Word;
    const spb:         PISC_SCHAR
  ): ISC_STATUS; stdcall;

(***********************)
(* Shutdown and cancel *)
(***********************)

  Tfb_shutdown = function(
    timeout:           Cardinal;
    const reason:      Integer
  ): Integer; stdcall;

  Tfb_shutdown_callback = function(
    status_vector:     PISC_STATUS;
    shutdown_callback: FB_SHUTDOWN_CALLBACK;
    const a:           integer;
    b:                 Pointer
  ): ISC_STATUS; stdcall;

  Tfb_cancel_operation = function(
    status_vactor:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    a:                 ISC_USHORT
  ): ISC_STATUS; stdcall;

(***********************)
(* Ping the connection *)
(***********************)

  Tfb_ping = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle
  ): ISC_STATUS; stdcall;


(********************)
(* Object interface *)
(********************)

  Tfb_get_database_handle = function(
    status_vector:     PISC_STATUS;
    db_handle:         pisc_db_handle;
    a:                 Pointer
  ): ISC_STATUS;
  Tfb_get_transaction_handle = function(
    status_vector:     PISC_STATUS;
    tra_handle:        pisc_tr_handle;
    a:                 Pointer
  ): ISC_STATUS;
  Tfb_get_transaction_interface = function(
    status_vector:     PISC_STATUS;
    a:                 Pointer;
    tra_handle:        pisc_tr_handle
  ): ISC_STATUS;
  Tfb_get_statement_interface = function(
    status_vector:     PISC_STATUS;
    a:                 Pointer;
    statement_handle:  pisc_stmt_handle
  ): ISC_STATUS;

(********************************)
(* Client information functions *)
(********************************)

  Tisc_get_client_version = procedure(a: PISC_SCHAR);
  Tisc_get_client_major_version = function(): integer;
  Tisc_get_client_minor_version = function(): integer;

(*******************************************)
(* Set callback for database crypt plugins *)
(*******************************************)

  Tfb_database_crypt_callback = function(
    status_vector:     PISC_STATUS;
    a:                 Pointer
  ): ISC_STATUS;

//#ifdef __cplusplus
// end; (* extern "C" *)
//endif


(***************************************************)
(* Actions to pass to the blob filter (ctl_source) *)
(***************************************************)

const isc_blob_filter_open        = 0;
const isc_blob_filter_get_segment = 1;
const isc_blob_filter_close       = 2;
const isc_blob_filter_create      = 3;
const isc_blob_filter_put_segment = 4;
const isc_blob_filter_alloc       = 5;
const isc_blob_filter_free        = 6;
const isc_blob_filter_seek        = 7;

(*******************)
(* Blr definitions *)
(*******************)

//include './firebird/impl/blr.h'

//include './firebird/impl/consts_pub.h'

(*********************************)
(* Information call declarations *)
(*********************************)

//include './firebird/impl/inf_pub.h'

//include './iberror.h'

//endif (* FIREBIRD_IBASE_H *)


implementation

end.
