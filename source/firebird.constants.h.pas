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

//ifndef JRD_CONSTANTS_H
//const JRD_CONSTANTS_H =;

// BLOb Subtype definitions

(* Subtypes < 0  are user defined
 * Subtype  0    means "untyped"
 * Subtypes > 0  are Firebird defined
 *)

// BRS 29-Apr-2004
// replace those constants with public defined ones isc_blob_*
//
//const BLOB_untyped    = 0;
//
//const BLOB_text       = 1;
//const BLOB_blr        = 2;
//const BLOB_acl        = 3;
//const BLOB_ranges     = 4;
//const BLOB_summary    = 5;
//const BLOB_format     = 6;
//const BLOB_tra        = 7;
//const BLOB_extfile    = 8;
//const BLOB_max_predefined_subtype = 9;
//

// Column Limits (in bytes)

const MAX_COLUMN_SIZE      = 32767;
const MAX_VARY_COLUMN_SIZE = MAX_COLUMN_SIZE - sizeof(Word);

const MAX_STR_SIZE = 65535;

const TEMP_STR_LENGTH = 128;

// Metadata constants

// When changing these constants, change MaxIdentifierByteLength and MaxIdentifierCharLength in
// firebird.conf too.
const METADATA_IDENTIFIER_CHAR_LEN  = 63;
const METADATA_BYTES_PER_CHAR       = 4;

// Misc constant values

const USERNAME_LENGTH	= METADATA_IDENTIFIER_CHAR_LEN * METADATA_BYTES_PER_CHAR;

const MAX_SQL_IDENTIFIER_LEN  = METADATA_IDENTIFIER_CHAR_LEN * METADATA_BYTES_PER_CHAR;
const MAX_SQL_IDENTIFIER_SIZE = MAX_SQL_IDENTIFIER_LEN + 1;
const MAX_CONFIG_NAME_LEN     = 63;

const MAX_SQL_LENGTH = 10 * 1024 * 1024; // 10 MB - just a safety check

const DB_KEY_NAME             = 'DB_KEY';
const RDB_DB_KEY_NAME         = 'RDB$DB_KEY';
const RDB_RECORD_VERSION_NAME = 'RDB$RECORD_VERSION';

const NULL_STRING_MARK    = '*** null ***';
const UNKNOWN_STRING_MARK = '*** unknown ***';

const ISC_USER     = 'ISC_USER';
const ISC_PASSWORD = 'ISC_PASSWORD';

const NULL_ROLE  = 'NONE';
const ADMIN_ROLE = 'RDB$ADMIN';		// It's used in C-string concatenations

// User name assigned to any user granted USR_locksmith rights.
// If this name is changed, modify also the trigger in
// jrd/grant.gdl (which turns into jrd/trig.h.
const DBA_USER_NAME = 'SYSDBA';

const PRIMARY_KEY     = 'PRIMARY KEY';
const FOREIGN_KEY     = 'FOREIGN KEY';
const UNIQUE_CNSTRT   = 'UNIQUE';
const CHECK_CNSTRT    = 'CHECK';
const NOT_NULL_CNSTRT = 'NOT NULL';

const REL_SCOPE_PERSISTENT   = 'persistent table "%s"';
const REL_SCOPE_GTT_PRESERVE = 'global temporary table "%s" of type ON COMMIT PRESERVE ROWS';
const REL_SCOPE_GTT_DELETE   = 'global temporary table "%s" of type ON COMMIT DELETE ROWS';
const REL_SCOPE_EXTERNAL     = 'external table "%s"';
const REL_SCOPE_VIEW         = 'view "%s"';
const REL_SCOPE_VIRTUAL      = 'virtual table "%s"';

// literal strings in rdb$ref_constraints to be used to identify
// the cascade actions for referential constraints. Used
// by isql/show and isql/extract for now.

const RI_ACTION_CASCADE = 'CASCADE';
const RI_ACTION_NULL    = 'SET NULL';
const RI_ACTION_DEFAULT = 'SET DEFAULT';
const RI_ACTION_NONE    = 'NO ACTION';
const RI_RESTRICT       = 'RESTRICT';

// Automatically created domains for fields with direct data type.
// Also, automatically created indices that are unique or non-unique, but not PK.
const IMPLICIT_DOMAIN_PREFIX     = 'RDB$';
const IMPLICIT_DOMAIN_PREFIX_LEN = 4;

// Automatically created indices for PKs.
const IMPLICIT_PK_PREFIX     = 'RDB$PRIMARY';
const IMPLICIT_PK_PREFIX_LEN = 11;

// The invisible "id zero" generator.
const MASTER_GENERATOR = ''; //Was "RDB$GENERATORS";


// Automatically created security classes for SQL objects.
// Keep in sync with trig.h
const DEFAULT_CLASS               = 'SQL$DEFAULT';
const SQL_SECCLASS_GENERATOR      = 'RDB$SECURITY_CLASS';
const SQL_SECCLASS_PREFIX         = 'SQL$';
const SQL_SECCLASS_PREFIX_LEN     = 4;
const SQL_FLD_SECCLASS_PREFIX     = 'SQL$GRANT';
const SQL_FLD_SECCLASS_PREFIX_LEN = 9;
const GEN_SECCLASS_PREFIX         = 'GEN$';
const GEN_SECCLASS_PREFIX_LEN     = 4;

const PROCEDURES_GENERATOR = 'RDB$PROCEDURES';
const FUNCTIONS_GENERATOR  = 'RDB$FUNCTIONS';

// Automatically created check constraints for unnamed PRIMARY and UNIQUE declarations.
const IMPLICIT_INTEGRITY_PREFIX     = 'INTEG_';
const IMPLICIT_INTEGRITY_PREFIX_LEN = 6;

// Default publication name
const DEFAULT_PUBLICATION = 'RDB$DEFAULT';

//*****************************************
// System flag meaning - mainly Firebird.
//*****************************************

const fb_sysflag_user                   = 0;
const fb_sysflag_system                 = 1;
const fb_sysflag_qli                    = 2;
const fb_sysflag_check_constraint       = 3;
const fb_sysflag_referential_constraint = 4;
const fb_sysflag_view_check             = 5;
const fb_sysflag_identity_generator     = 6;

// view context type

const VCT_TABLE     = 0;
const VCT_VIEW      = 1;
const VCT_PROCEDURE = 2;

// identity type

const IDENT_TYPE_ALWAYS     = 0;
const IDENT_TYPE_BY_DEFAULT = 1;

// sub-routine type

const SUB_ROUTINE_TYPE_PSQL = 0;

// UDF Arguments are numbered from 0 to MAX_UDF_ARGUMENTS --
// argument 0 is reserved for the return-type of the UDF

const MAX_UDF_ARGUMENTS = 15;

// Maximum length of single line returned from pretty printer
const PRETTY_BUFFER_SIZE = 1024;

const MAX_INDEX_SEGMENTS = 16;

// Maximum index key length (must be in sync with MAX_PAGE_SIZE in ods.h)
const MAX_KEY             = 8192;		// Maximum page size possible divide by 4 (MAX_PAGE_SIZE / 4)

const SQL_MATCH_1_CHAR    = '_';	// Not translatable
const SQL_MATCH_ANY_CHARS = '%';	// Not translatable

const MAX_CONTEXT_VARS    = 1000;		// Maximum number of context variables allowed for a single object

// Time precision limits and defaults for TIME/TIMESTAMP values.
// Currently they're applied to CURRENT_TIME[STAMP] expressions only.

// Should be more than 6 as per SQL spec, but we don't support more than 3 yet
const MAX_TIME_PRECISION          = 3;
// Consistent with the SQL spec
const DEFAULT_TIME_PRECISION      = 0;
// Should be 6 as per SQL spec
const DEFAULT_TIMESTAMP_PRECISION = 3;

const MAX_ARRAY_DIMENSIONS = 16;

const MAX_SORT_ITEMS = 255; // ORDER BY f1,...,f255

const MAX_DB_PER_TRANS = 256; // A multi-db txn can span up to 256 dbs

// relation types

const rel_persistent           = 0;
const rel_view                 = 1;
const rel_external             = 2;
const rel_virtual              = 3;
const rel_global_temp_preserve = 4;
const rel_global_temp_delete   = 5;

// procedure types

const prc_legacy     = 0;
const prc_selectable = 1;
const prc_executable = 2;

// procedure parameter mechanism

const prm_mech_normal  = 0;
const prm_mech_type_of = 1;

// states

const mon_state_idle    = 0;
const mon_state_active  = 1;
const mon_state_stalled = 2;

// shutdown modes

const shut_mode_online = 0;
const shut_mode_multi  = 1;
const shut_mode_single = 2;
const shut_mode_full   = 3;

// backup states

const backup_state_unknown = -1;
const backup_state_normal  = 0;
const backup_state_stalled = 1;
const backup_state_merge   = 2;

// transaction isolation levels

const iso_mode_consistency         = 0;
const iso_mode_concurrency         = 1;
const iso_mode_rc_version          = 2;
const iso_mode_rc_no_version       = 3;
const iso_mode_rc_read_consistency = 4;

// statistics groups

const stat_database    = 0;
const stat_attachment  = 1;
const stat_transaction = 2;
const stat_statement   = 3;
const stat_call        = 4;

// info type

const INFO_TYPE_CONNECTION_ID     = 1;
const INFO_TYPE_TRANSACTION_ID    = 2;
const INFO_TYPE_GDSCODE           = 3;
const INFO_TYPE_SQLCODE           = 4;
const INFO_TYPE_ROWS_AFFECTED     = 5;
const INFO_TYPE_TRIGGER_ACTION    = 6;
const INFO_TYPE_SQLSTATE          = 7;
const INFO_TYPE_EXCEPTION         = 8;
const INFO_TYPE_ERROR_MSG         = 9;
const INFO_TYPE_SESSION_RESETTING = 10;
const MAX_INFO_TYPE               = 11;

// replica mode

const REPLICA_NONE       = 0;
const REPLICA_READ_ONLY  = 1;
const REPLICA_READ_WRITE = 2;

// trigger type

const PRE_STORE_TRIGGER   = 1;
const POST_STORE_TRIGGER  = 2;
const PRE_MODIFY_TRIGGER  = 3;
const POST_MODIFY_TRIGGER = 4;
const PRE_ERASE_TRIGGER   = 5;
const POST_ERASE_TRIGGER  = 6;

// trigger action

// Order should be maintained because the numbers are stored in BLR
// and should be in sync with IExternalTrigger::ACTION_* .
const TRIGGER_INSERT         = 1;
const TRIGGER_UPDATE         = 2;
const TRIGGER_DELETE         = 3;
const TRIGGER_CONNECT        = 4;
const TRIGGER_DISCONNECT     = 5;
const TRIGGER_TRANS_START    = 6;
const TRIGGER_TRANS_COMMIT   = 7;
const TRIGGER_TRANS_ROLLBACK = 8;
const TRIGGER_DDL            = 9;

const TRIGGER_TYPE_SHIFT = 13;
const TRIGGER_TYPE_MASK  = (3 shl TRIGGER_TYPE_SHIFT);

const TRIGGER_TYPE_DML   = (0 shl TRIGGER_TYPE_SHIFT);
const TRIGGER_TYPE_DB    = (1 shl TRIGGER_TYPE_SHIFT);
const TRIGGER_TYPE_DDL   = (2 shl TRIGGER_TYPE_SHIFT);

const DB_TRIGGER_CONNECT        = 0;
const DB_TRIGGER_DISCONNECT     = 1;
const DB_TRIGGER_TRANS_START    = 2;
const DB_TRIGGER_TRANS_COMMIT   = 3;
const DB_TRIGGER_TRANS_ROLLBACK	= 4;
const DB_TRIGGER_MAX            = 5;

const DDL_TRIGGER_ACTION_NAMES: array[0..47, 0..1] of PChar =
  (
    (nil, nil),
    ('CREATE', 'TABLE'),
    ('ALTER', 'TABLE'),
    ('DROP', 'TABLE'),
    ('CREATE', 'PROCEDURE'),
    ('ALTER', 'PROCEDURE'),
    ('DROP', 'PROCEDURE'),
    ('CREATE', 'FUNCTION'),
    ('ALTER', 'FUNCTION'),
	  ('DROP', 'FUNCTION'),
	  ('CREATE', 'TRIGGER'),
	  ('ALTER', 'TRIGGER'),
    ('DROP', 'TRIGGER'),
    ('', ''), ('', ''), ('', ''),	// gap for TRIGGER_TYPE_MASK - 3 bits
    ('CREATE', 'EXCEPTION'),
    ('ALTER', 'EXCEPTION'),
    ('DROP', 'EXCEPTION'),
    ('CREATE', 'VIEW'),
    ('ALTER', 'VIEW'),
    ('DROP', 'VIEW'),
    ('CREATE', 'DOMAIN'),
    ('ALTER', 'DOMAIN'),
    ('DROP', 'DOMAIN'),
    ('CREATE', 'ROLE'),
    ('ALTER', 'ROLE'),
    ('DROP', 'ROLE'),
    ('CREATE', 'INDEX'),
    ('ALTER', 'INDEX'),
    ('DROP', 'INDEX'),
    ('CREATE', 'SEQUENCE'),
    ('ALTER', 'SEQUENCE'),
    ('DROP', 'SEQUENCE'),
    ('CREATE', 'USER'),
    ('ALTER', 'USER'),
    ('DROP', 'USER'),
    ('CREATE', 'COLLATION'),
    ('DROP', 'COLLATION'),
    ('ALTER', 'CHARACTER SET'),
    ('CREATE', 'PACKAGE'),
    ('ALTER', 'PACKAGE'),
    ('DROP', 'PACKAGE'),
    ('CREATE', 'PACKAGE BODY'),
    ('DROP', 'PACKAGE BODY'),
    ('CREATE', 'MAPPING'),
    ('ALTER', 'MAPPING'),
    ('DROP', 'MAPPING')
  );

const DDL_TRIGGER_BEFORE = 0;
const DDL_TRIGGER_AFTER  = 1;

const DDL_TRIGGER_ANY    = $7FFFFFFFFFFFFFFF and (not Int64(TRIGGER_TYPE_MASK)) and (not 1);

const DDL_TRIGGER_CREATE_TABLE        = 1;
const DDL_TRIGGER_ALTER_TABLE         = 2;
const DDL_TRIGGER_DROP_TABLE          = 3;
const DDL_TRIGGER_CREATE_PROCEDURE    = 4;
const DDL_TRIGGER_ALTER_PROCEDURE     = 5;
const DDL_TRIGGER_DROP_PROCEDURE      = 6;
const DDL_TRIGGER_CREATE_FUNCTION     = 7;
const DDL_TRIGGER_ALTER_FUNCTION      = 8;
const DDL_TRIGGER_DROP_FUNCTION       = 9;
const DDL_TRIGGER_CREATE_TRIGGER      = 10;
const DDL_TRIGGER_ALTER_TRIGGER       = 11;
const DDL_TRIGGER_DROP_TRIGGER        = 12;
// gap for TRIGGER_TYPE_MASK - 3 bits
const DDL_TRIGGER_CREATE_EXCEPTION    = 16;
const DDL_TRIGGER_ALTER_EXCEPTION     = 17;
const DDL_TRIGGER_DROP_EXCEPTION      = 18;
const DDL_TRIGGER_CREATE_VIEW         = 19;
const DDL_TRIGGER_ALTER_VIEW          = 20;
const DDL_TRIGGER_DROP_VIEW           = 21;
const DDL_TRIGGER_CREATE_DOMAIN       = 22;
const DDL_TRIGGER_ALTER_DOMAIN        = 23;
const DDL_TRIGGER_DROP_DOMAIN         = 24;
const DDL_TRIGGER_CREATE_ROLE         = 25;
const DDL_TRIGGER_ALTER_ROLE          = 26;
const DDL_TRIGGER_DROP_ROLE           = 27;
const DDL_TRIGGER_CREATE_INDEX        = 28;
const DDL_TRIGGER_ALTER_INDEX         = 29;
const DDL_TRIGGER_DROP_INDEX          = 30;
const DDL_TRIGGER_CREATE_SEQUENCE     = 31;
const DDL_TRIGGER_ALTER_SEQUENCE      = 32;
const DDL_TRIGGER_DROP_SEQUENCE       = 33;
const DDL_TRIGGER_CREATE_USER         = 34;
const DDL_TRIGGER_ALTER_USER          = 35;
const DDL_TRIGGER_DROP_USER           = 36;
const DDL_TRIGGER_CREATE_COLLATION    = 37;
const DDL_TRIGGER_DROP_COLLATION      = 38;
const DDL_TRIGGER_ALTER_CHARACTER_SET = 39;
const DDL_TRIGGER_CREATE_PACKAGE      = 40;
const DDL_TRIGGER_ALTER_PACKAGE       = 41;
const DDL_TRIGGER_DROP_PACKAGE        = 42;
const DDL_TRIGGER_CREATE_PACKAGE_BODY = 43;
const DDL_TRIGGER_DROP_PACKAGE_BODY   = 44;
const DDL_TRIGGER_CREATE_MAPPING      = 45;
const DDL_TRIGGER_ALTER_MAPPING       = 46;
const DDL_TRIGGER_DROP_MAPPING        = 47;

// that's how database trigger action types are encoded
//    (TRIGGER_TYPE_DB | type)

// that's how DDL trigger action types are encoded
//    (TRIGGER_TYPE_DDL | DDL_TRIGGER_{AFTER | BEFORE} [ | DDL_TRIGGER_??? ...])

// switches for username and password used when an username and/or password
// is specified by the client application
const USERNAME_SWITCH = 'USER';
const PASSWORD_SWITCH = 'PASSWORD';

// The highest transaction number possible
const MAX_TRA_NUMBER  = $0000FFFFFFFFFFFF;	// ~2.8 * 10^14

// Number of streams, conjuncts, indices that will be statically allocated
// in various arrays. Larger numbers will have to be allocated dynamically
// CVC: I think we need to have a special, higher value for streams.
const OPT_STATIC_ITEMS = 64;

const CURRENT_ENGINE     = 'Engine13';
const EMBEDDED_PROVIDERS = 'Providers=' + CURRENT_ENGINE;

// Features set for current version of engine provider
const ENGINE_FEATURES: array [0..5] of string =
  (
    'fb_feature_multi_statements',
    'fb_feature_multi_transactions',
    'fb_feature_session_reset',
    'fb_feature_read_consistency',
    'fb_feature_statement_timeout',
    'fb_feature_statement_long_life'
  );

const WITH_GRANT_OPTION = 1;
const WITH_ADMIN_OPTION = 2;

// Max length of the string returned by ERROR_TEXT context variable
const MAX_ERROR_MSG_LENGTH = 1024 * METADATA_BYTES_PER_CHAR; // 1024 UTF-8 characters

implementation

end.
