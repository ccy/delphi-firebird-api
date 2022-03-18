unit firebird.constants.h;

interface

(*
 *  PROGRAM:  JRD Access Method
 *  MODULE:    constants.h
 *  DESCRIPTION:  Misc system constants
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
 *
 * 2001.10.08 Claudio Valderrama: fb_sysflag enum with numbering
 *   for automatically created triggers that aren't system triggers.
 *)

// Firebird system flag 

const fb_sysflag_user = 0;
const fb_sysflag_system = 1;
const fb_sysflag_qli = 2;
const fb_sysflag_check_constraint = 3;
const fb_sysflag_referential_constraint = 4;
const fb_sysflag_view_check = 5;
const fb_sysflag_identity_generator = 6;

// view context type

const VCT_TABLE = 0;
const VCT_VIEW = 1;
const VCT_PROCEDURE = 2;

// identity type

const IDENT_TYPE_ALWAYS = 0;
const IDENT_TYPE_BY_DEFAULT = 1;

// sub-routine type

const SUB_ROUTINE_TYPE_PSQL = 0;

// relation types

const rel_persistent = 0;
const rel_view = 1;
const rel_external = 2;
const rel_virtual = 3;
const rel_global_temp_preserve = 4;
const rel_global_temp_delete = 5;

// procedure types

const prc_legacy = 0;
const prc_selectable = 1;
const prc_executable = 2;

// procedure parameter mechanism

const prm_mech_normal = 0;
const prm_mech_type_of = 1;

// states

const mon_state_idle = 0;
const mon_state_active = 1;
const mon_state_stalled = 2;

// shutdown modes

const shut_mode_online = 0;
const shut_mode_multi = 1;
const shut_mode_single = 2;
const shut_mode_full = 3;

// backup states

const backup_state_unknown = -1;
const backup_state_normal = 0;
const backup_state_stalled = 1;
const backup_state_merge = 2;

// transaction isolation levels

const iso_mode_consistency = 0;
const iso_mode_concurrency = 1;
const iso_mode_rc_version = 2;
const iso_mode_rc_no_version = 3;
const iso_mode_rc_read_consistency = 4;

// statistics groups

const stat_database = 0;
const stat_attachment = 1;
const stat_transaction = 2;
const stat_statement = 3;
const stat_call = 4;

// info type

const INFO_TYPE_CONNECTION_ID = 1;
const INFO_TYPE_TRANSACTION_ID = 2;
const INFO_TYPE_GDSCODE = 3;
const INFO_TYPE_SQLCODE = 4;
const INFO_TYPE_ROWS_AFFECTED = 5;
const INFO_TYPE_TRIGGER_ACTION = 6;
const INFO_TYPE_SQLSTATE = 7;
const INFO_TYPE_EXCEPTION = 8;
const INFO_TYPE_ERROR_MSG = 9;
const INFO_TYPE_SESSION_RESETTING = 10;
const MAX_INFO_TYPE = 11;

// replica mode

const REPLICA_NONE = 0;
const REPLICA_READ_ONLY = 1;
const REPLICA_READ_WRITE = 2;

// trigger type

const PRE_STORE_TRIGGER = 1;
const POST_STORE_TRIGGER = 2;
const PRE_MODIFY_TRIGGER = 3;
const POST_MODIFY_TRIGGER = 4;
const PRE_ERASE_TRIGGER = 5;
const POST_ERASE_TRIGGER = 6;

// trigger action

// Order should be maintained because the numbers are stored in BLR
// and should be in sync with IExternalTrigger::ACTION_* .
const TRIGGER_INSERT = 1;
const TRIGGER_UPDATE = 2;
const TRIGGER_DELETE = 3;
const TRIGGER_CONNECT = 4;
const TRIGGER_DISCONNECT  = 5;
const TRIGGER_TRANS_START = 6;
const TRIGGER_TRANS_COMMIT = 7;
const TRIGGER_TRANS_ROLLBACK = 8;
const TRIGGER_DDL = 9;

implementation

end.
