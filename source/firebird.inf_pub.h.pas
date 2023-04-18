unit firebird.inf_pub.h;

interface

(*
 *	PROGRAM:	JRD Access Method
 *	MODULE:		inf.h
 *  DESCRIPTION:  Information call declarations.
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
 * 2001.07.28: John Bellardo: Added isc_info_rsb_skip to support LIMIT.
 *)

//ifndef FIREBIRD_JRD_INF_PUB_H
//const FIREBIRD_JRD_INF_PUB_H =;

(* Common, structural codes *)
(****************************)

const isc_info_end            = 1;
const isc_info_truncated      = 2;
const isc_info_error          = 3;
const isc_info_data_not_ready = 4;
const isc_info_length         = 126;
const isc_info_flag_end       = 127;

(******************************)
(* Database information items *)
(******************************)

// db_info_types

const isc_info_db_id      = 4;
const isc_info_reads      = 5;
const isc_info_writes     = 6;
const isc_info_fetches    = 7;
const isc_info_marks      = 8;

const isc_info_implementation = 11;
const isc_info_isc_version    = 12;
const isc_info_base_level     = 13;
const isc_info_page_size      = 14;
const isc_info_num_buffers    = 15;
const isc_info_limbo          = 16;
const isc_info_current_memory = 17;
const isc_info_max_memory     = 18;
const isc_info_window_turns   = 19;
const isc_info_license        = 20;

const isc_info_allocation     = 21;
const isc_info_attachment_id  = 22;
const isc_info_read_seq_count = 23;
const isc_info_read_idx_count = 24;
const isc_info_insert_count   = 25;
const isc_info_update_count   = 26;
const isc_info_delete_count   = 27;
const isc_info_backout_count  = 28;
const isc_info_purge_count    = 29;
const isc_info_expunge_count  = 30;

const isc_info_sweep_interval    = 31;
const isc_info_ods_version       = 32;
const isc_info_ods_minor_version = 33;
const isc_info_no_reserve        = 34;
(* Begin deprecated WAL and JOURNAL items. *)
const isc_info_logfile             = 35;
const isc_info_cur_logfile_name    = 36;
const isc_info_cur_log_part_offset = 37;
const isc_info_num_wal_buffers     = 38;
const isc_info_wal_buffer_size     = 39;
const isc_info_wal_ckpt_length     = 40;

const isc_info_wal_cur_ckpt_interval = 41;
const isc_info_wal_prv_ckpt_fname    = 42;
const isc_info_wal_prv_ckpt_poffset  = 43;
const isc_info_wal_recv_ckpt_fname   = 44;
const isc_info_wal_recv_ckpt_poffset = 45;
const isc_info_wal_grpc_wait_usecs   = 47;
const isc_info_wal_num_io            = 48;
const isc_info_wal_avg_io_size       = 49;
const isc_info_wal_num_commits       = 50;
const isc_info_wal_avg_grpc_size     = 51;
(* End deprecated WAL and JOURNAL items. *)

const isc_info_forced_writes = 52;
const isc_info_user_names    = 53;
const isc_info_page_errors   = 54;
const isc_info_record_errors = 55;
const isc_info_bpage_errors  = 56;
const isc_info_dpage_errors  = 57;
const isc_info_ipage_errors  = 58;
const isc_info_ppage_errors  = 59;
const isc_info_tpage_errors  = 60;

const isc_info_set_page_buffers = 61;
const isc_info_db_sql_dialect   = 62;
const isc_info_db_read_only     = 63;
const isc_info_db_size_in_pages = 64;

(* Values 65 -100 unused to avoid conflict with InterBase *)

const frb_info_att_charset         = 101;
const isc_info_db_class            = 102;
const isc_info_firebird_version    = 103;
const isc_info_oldest_transaction  = 104;
const isc_info_oldest_active       = 105;
const isc_info_oldest_snapshot     = 106;
const isc_info_next_transaction    = 107;
const isc_info_db_provider         = 108;
const isc_info_active_transactions = 109;
const isc_info_active_tran_count   = 110;
const isc_info_creation_date       = 111;
const isc_info_db_file_size        = 112;
const fb_info_page_contents        = 113;

const fb_info_implementation = 114;

const fb_info_page_warns   = 115;
const fb_info_record_warns = 116;
const fb_info_bpage_warns  = 117;
const fb_info_dpage_warns  = 118;
const fb_info_ipage_warns  = 119;
const fb_info_ppage_warns  = 120;
const fb_info_tpage_warns  = 121;
const fb_info_pip_errors   = 122;
const fb_info_pip_warns    = 123;

const fb_info_pages_used = 124;
const fb_info_pages_free = 125;

// codes 126 and 127 are used for special purposes
// do not use them here

const fb_info_ses_idle_timeout_db  = 129;
const fb_info_ses_idle_timeout_att = 130;
const fb_info_ses_idle_timeout_run = 131;

const fb_info_conn_flags = 132;

const fb_info_crypt_key   = 133;
const fb_info_crypt_state = 134;

const fb_info_statement_timeout_db  = 135;
const fb_info_statement_timeout_att = 136;

const fb_info_protocol_version = 137;
const fb_info_crypt_plugin     = 138;

const fb_info_creation_timestamp_tz = 139;

const fb_info_wire_crypt = 140;

// Return list of features supported by provider of current connection
const fb_info_features = 141;

const fb_info_next_attachment = 142;
const fb_info_next_statement  = 143;

const fb_info_db_guid    = 144;
const fb_info_db_file_id = 145;

const fb_info_replica_mode = 146;

const fb_info_username = 147;
const fb_info_sqlrole  = 148;

const isc_info_db_last_value = 149;  (* Leave this LAST! *)

// db_info_crypt
const fb_info_crypt_encrypted = $01;
const fb_info_crypt_process   = $02;

// info_features
const fb_feature_multi_statements    = 1;  // Multiple prepared statements in single attachment
const fb_feature_multi_transactions  = 2;  // Multiple concurrent transaction in single attachment
const fb_feature_named_parameters    = 3;  // Query parameters can be named
const fb_feature_session_reset       = 4;  // ALTER SESSION RESET is supported
const fb_feature_read_consistency    = 5;  // Read consistency TIL is supported
const fb_feature_statement_timeout   = 6;  // Statement timeout is supported
const fb_feature_statement_long_life = 7;  // Prepared statements are not dropped on transaction end

const fb_feature_max                 = 8;  // Not really a feature. Keep this last.

// replica_mode
const fb_info_replica_none       = 0;
const fb_info_replica_read_only  = 1;
const fb_info_replica_read_write = 2;

const isc_info_version = isc_info_isc_version;


(**************************************)
(* Database information return values *)
(**************************************)

// info_db_implementations
const isc_info_db_impl_rdb_vms     = 1;
const isc_info_db_impl_rdb_eln     = 2;
const isc_info_db_impl_rdb_eln_dev = 3;
const isc_info_db_impl_rdb_vms_y   = 4;
const isc_info_db_impl_rdb_eln_y   = 5;
const isc_info_db_impl_jri         = 6;
const isc_info_db_impl_jsv         = 7;

const isc_info_db_impl_isc_apl_68K  = 25;
const isc_info_db_impl_isc_vax_ultr = 26;
const isc_info_db_impl_isc_vms      = 27;
const isc_info_db_impl_isc_sun_68k  = 28;
const isc_info_db_impl_isc_os2      = 29;
const isc_info_db_impl_isc_sun4     = 30;     (* 30 *)

const isc_info_db_impl_isc_hp_ux    = 31;
const isc_info_db_impl_isc_sun_386i = 32;
const isc_info_db_impl_isc_vms_orcl = 33;
const isc_info_db_impl_isc_mac_aux  = 34;
const isc_info_db_impl_isc_rt_aix   = 35;
const isc_info_db_impl_isc_mips_ult = 36;
const isc_info_db_impl_isc_xenix    = 37;
const isc_info_db_impl_isc_dg       = 38;
const isc_info_db_impl_isc_hp_mpexl = 39;
const isc_info_db_impl_isc_hp_ux68K = 40;    (* 40 *)

const isc_info_db_impl_isc_sgi       = 41;
const isc_info_db_impl_isc_sco_unix  = 42;
const isc_info_db_impl_isc_cray      = 43;
const isc_info_db_impl_isc_imp       = 44;
const isc_info_db_impl_isc_delta     = 45;
const isc_info_db_impl_isc_next      = 46;
const isc_info_db_impl_isc_dos       = 47;
const isc_info_db_impl_m88K          = 48;
const isc_info_db_impl_unixware      = 49;
const isc_info_db_impl_isc_winnt_x86 = 50;

const isc_info_db_impl_isc_epson   = 51;
const isc_info_db_impl_alpha_osf   = 52;
const isc_info_db_impl_alpha_vms   = 53;
const isc_info_db_impl_netware_386 = 54; 
const isc_info_db_impl_win_only    = 55;
const isc_info_db_impl_ncr_3000    = 56;
const isc_info_db_impl_winnt_ppc   = 57;
const isc_info_db_impl_dg_x86      = 58;
const isc_info_db_impl_sco_ev      = 59;
const isc_info_db_impl_i386        = 60;

const isc_info_db_impl_freebsd     = 61;
const isc_info_db_impl_netbsd      = 62;
const isc_info_db_impl_darwin_ppc  = 63;
const isc_info_db_impl_sinixz      = 64;

const isc_info_db_impl_linux_sparc = 65;
const isc_info_db_impl_linux_amd64 = 66;

const isc_info_db_impl_freebsd_amd64 = 67;

const isc_info_db_impl_winnt_amd64 = 68;

const isc_info_db_impl_linux_ppc    = 69;
const isc_info_db_impl_darwin_x86   = 70;
const isc_info_db_impl_linux_mipsel = 71;
const isc_info_db_impl_linux_mips   = 72;
const isc_info_db_impl_darwin_x64   = 73;
const isc_info_db_impl_sun_amd64    = 74;

const isc_info_db_impl_linux_arm  = 75;
const isc_info_db_impl_linux_ia64 = 76;

const isc_info_db_impl_darwin_ppc64 = 77;
const isc_info_db_impl_linux_s390x  = 78;
const isc_info_db_impl_linux_s390   = 79;

const isc_info_db_impl_linux_sh      = 80;
const isc_info_db_impl_linux_sheb    = 81;
const isc_info_db_impl_linux_hppa    = 82;
const isc_info_db_impl_linux_alpha   = 83;
const isc_info_db_impl_linux_arm64   = 84;
const isc_info_db_impl_linux_ppc64el = 85;
const isc_info_db_impl_linux_ppc64   = 86;
const isc_info_db_impl_linux_m68k    = 87;
const isc_info_db_impl_linux_riscv64 = 88;

const isc_info_db_impl_last_value = 89;  // Leave this LAST!

// info_db_class 
const isc_info_db_class_access         = 1;
const isc_info_db_class_y_valve        = 2;
const isc_info_db_class_rem_int        = 3;
const isc_info_db_class_rem_srvr       = 4;
const isc_info_db_class_pipe_int       = 7;
const isc_info_db_class_pipe_srvr      = 8;
const isc_info_db_class_sam_int        = 9;
const isc_info_db_class_sam_srvr       = 10;
const isc_info_db_class_gateway        = 11;
const isc_info_db_class_cache          = 12;
const isc_info_db_class_classic_access = 13;
const isc_info_db_class_server_access  = 14;

const isc_info_db_class_last_value = 15;  (* Leave this LAST! *)

// info_db_provider
const isc_info_db_code_rdb_eln   = 1;
const isc_info_db_code_rdb_vms   = 2;
const isc_info_db_code_interbase = 3;
const isc_info_db_code_firebird  = 4;

const isc_info_db_code_last_value = 5;  (* Leave this LAST! *)


(*****************************)
(* Request information items *)
(*****************************)

const isc_info_number_messages  = 4;
const isc_info_max_message      = 5;
const isc_info_max_send         = 6;
const isc_info_max_receive      = 7;
const isc_info_state            = 8;
const isc_info_message_number   = 9;
const isc_info_message_size     = 10;
const isc_info_request_cost     = 11;
const isc_info_access_path      = 12;
const isc_info_req_select_count = 13;
const isc_info_req_insert_count = 14;
const isc_info_req_update_count = 15;
const isc_info_req_delete_count = 16;


(*********************)
(* Access path items *)
(*********************)

const isc_info_rsb_end      = 0;
const isc_info_rsb_begin    = 1;
const isc_info_rsb_type     = 2;
const isc_info_rsb_relation = 3;
const isc_info_rsb_plan     = 4;

(*************)
(* RecordSource (RSB) types *)
(*************)

const isc_info_rsb_unknown         = 1;
const isc_info_rsb_indexed         = 2;
const isc_info_rsb_navigate        = 3;
const isc_info_rsb_sequential      = 4;
const isc_info_rsb_cross           = 5;
const isc_info_rsb_sort            = 6;
const isc_info_rsb_first           = 7;
const isc_info_rsb_boolean         = 8;
const isc_info_rsb_union           = 9;
const isc_info_rsb_aggregate       = 10;
const isc_info_rsb_merge           = 11;
const isc_info_rsb_ext_sequential  = 12;
const isc_info_rsb_ext_indexed     = 13;
const isc_info_rsb_ext_dbkey       = 14;
const isc_info_rsb_left_cross      = 15;
const isc_info_rsb_select          = 16;
const isc_info_rsb_sql_join        = 17;
const isc_info_rsb_simulate        = 18;
const isc_info_rsb_sim_cross       = 19;
const isc_info_rsb_once            = 20;
const isc_info_rsb_procedure       = 21;
const isc_info_rsb_skip            = 22;
const isc_info_rsb_virt_sequential = 23;
const isc_info_rsb_recursive       = 24;
const isc_info_rsb_window          = 25;
const isc_info_rsb_singular        = 26;
const isc_info_rsb_writelock       = 27;
const isc_info_rsb_buffer          = 28;
const isc_info_rsb_hash            = 29;

(**********************)
(* Bitmap expressions *)
(**********************)

const isc_info_rsb_and   = 1;
const isc_info_rsb_or    = 2;
const isc_info_rsb_dbkey = 3;
const isc_info_rsb_index = 4;

const isc_info_req_active    = 2;
const isc_info_req_inactive  = 3;
const isc_info_req_send      = 4;
const isc_info_req_receive   = 5;
const isc_info_req_select    = 6;
const isc_info_req_sql_stall = 7;

(**************************)
(* Blob information items *)
(**************************)

const isc_info_blob_num_segments = 4;
const isc_info_blob_max_segment  = 5;
const isc_info_blob_total_length = 6;
const isc_info_blob_type         = 7;

(*********************************)
(* Transaction information items *)
(*********************************)

const isc_info_tra_id                 = 4;
const isc_info_tra_oldest_interesting = 5;
const isc_info_tra_oldest_snapshot    = 6;
const isc_info_tra_oldest_active      = 7;
const isc_info_tra_isolation          = 8;
const isc_info_tra_access             = 9;
const isc_info_tra_lock_timeout       = 10;
const fb_info_tra_dbpath              = 11;
const fb_info_tra_snapshot_number     = 12;

// isc_info_tra_isolation responses
const isc_info_tra_consistency    = 1;
const isc_info_tra_concurrency    = 2;
const isc_info_tra_read_committed = 3;

// isc_info_tra_read_committed options
const isc_info_tra_no_rec_version   = 0;
const isc_info_tra_rec_version      = 1;
const isc_info_tra_read_consistency = 2;

// isc_info_tra_access responses
const isc_info_tra_readonly  = 0;
const isc_info_tra_readwrite = 1;


(*************************)
(* SQL information items *)
(*************************)

const isc_info_sql_select              = 4;
const isc_info_sql_bind                = 5;
const isc_info_sql_num_variables       = 6;
const isc_info_sql_describe_vars       = 7;
const isc_info_sql_describe_end        = 8;
const isc_info_sql_sqlda_seq           = 9;
const isc_info_sql_message_seq         = 10;
const isc_info_sql_type                = 11;
const isc_info_sql_sub_type            = 12;
const isc_info_sql_scale               = 13;
const isc_info_sql_length              = 14;
const isc_info_sql_null_ind            = 15;
const isc_info_sql_field               = 16;
const isc_info_sql_relation            = 17;
const isc_info_sql_owner               = 18;
const isc_info_sql_alias               = 19;
const isc_info_sql_sqlda_start         = 20;
const isc_info_sql_stmt_type           = 21;
const isc_info_sql_get_plan            = 22;
const isc_info_sql_records             = 23;
const isc_info_sql_batch_fetch         = 24;
const isc_info_sql_relation_alias      = 25;
const isc_info_sql_explain_plan        = 26;
const isc_info_sql_stmt_flags          = 27;
const isc_info_sql_stmt_timeout_user   = 28;
const isc_info_sql_stmt_timeout_run    = 29;
const isc_info_sql_stmt_blob_align     = 30;
const isc_info_sql_exec_path_blr_bytes = 31;
const isc_info_sql_exec_path_blr_text  = 32;

(*********************************)
(* SQL information return values *)
(*********************************)

const isc_info_sql_stmt_select         = 1;
const isc_info_sql_stmt_insert         = 2;
const isc_info_sql_stmt_update         = 3;
const isc_info_sql_stmt_delete         = 4;
const isc_info_sql_stmt_ddl            = 5;
const isc_info_sql_stmt_get_segment    = 6;
const isc_info_sql_stmt_put_segment    = 7;
const isc_info_sql_stmt_exec_procedure = 8;
const isc_info_sql_stmt_start_trans    = 9;
const isc_info_sql_stmt_commit         = 10;
const isc_info_sql_stmt_rollback       = 11;
const isc_info_sql_stmt_select_for_upd = 12;
const isc_info_sql_stmt_set_generator  = 13;
const isc_info_sql_stmt_savepoint      = 14;

//endif (* FIREBIRD_IMPL_INF_PUB_H *)

implementation

end.
