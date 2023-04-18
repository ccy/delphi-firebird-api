unit firebird.burp.h;

interface

uses firebird.constants.h, firebird.types_pub.h;

(*
 *	PROGRAM:	JRD Backup and Restore Program
 *	MODULE:		burp.h
 *	DESCRIPTION:	Burp file format
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
 * 2002.10.29 Sean Leyne - Removed obsolete "Netware" port
 *
// 2002.10.30 Sean Leyne - Removed support for obsolete "PC_PLATFORM" define
//
 *)

//#ifndef BURP_BURP_H
//#define BURP_BURP_H

//#include <stdio.h>
//#include "ibase.h"
//#include "firebird/Interface.h"
//#include "firebird/Message.h"
//#include "../common/dsc.h"
//#include "../burp/misc_proto.h"
//#include "../burp/mvol_proto.h"
//#include "../yvalve/gds_proto.h"
//#include "../common/ThreadData.h"
//#include "../common/UtilSvc.h"
//#include "../common/classes/array.h"
//#include "../common/classes/fb_pair.h"
//#include "../common/classes/MetaString.h"
//#include "../common/classes/Nullable.h"
//#include "../common/SimilarToRegex.h"
//#include "../common/status.h"
//#include "../common/sha.h"
//#include "../common/classes/ImplementHelper.h"

//#ifdef HAVE_UNISTD_H
//#include <unistd.h>
//#endif

//#ifdef HAVE_FCNTL_H
//#include <fcntl.h>
//#endif

//#if defined(HAVE_ZLIB_H)
//#define WIRE_COMPRESS_SUPPORT 1
//#endif

//#ifdef WIRE_COMPRESS_SUPPORT
//#include <zlib.h>
////#define COMPRESS_DEBUG 1
//#endif // WIRE_COMPRESS_SUPPORT

const GDS_NAME_LEN = METADATA_IDENTIFIER_CHAR_LEN * 4 (* max bytes per char *) + 1;
type GDS_NAME = array[0..GDS_NAME_LEN - 1] of Char;

const      // enum redirect_vals
  NOREDIRECT = 0;
	REDIRECT   = 1;
	NOOUTPUT   = 2;

const burp_msg_fac = 12;

// Record types in backup file

const      // enum rec_type
  rec_burp             = 0;   // Restore program attributes
  rec_database         = 1;   // Logical database parameters
  rec_global_field     = 2;   // Global field description
  rec_relation         = 3;   // Relation description
  rec_field            = 4;   // Local field description
  rec_index            = 5;   // Index description
  rec_data             = 6;   // Data for relation
  rec_blob             = 7;   // Blob
  rec_relation_data    = 8;   // Standalone data header
  rec_relation_end     = 9;   // End of data for relation
  rec_end              = 10;  // End of file
  rec_view             = 11;  // View attributes
  rec_security_class   = 12;  // Security class acl
  rec_trigger          = 13;  // Trigger definition
  rec_physical_db      = 14;  // Physical database parameters
  rec_function         = 15;  // Function description
  rec_function_arg     = 16;  // Function arguement description
  rec_function_end     = 17;  // End of function and its args
  rec_gen_id           = 18;  // From blr_gen_id
  rec_system_type      = 19;  // Type of field
  rec_filter           = 20;  // Filter
  rec_trigger_message  = 21;  // Trigger message texts
  rec_user_privilege   = 22;  // User privilege
  rec_array            = 23;  // Array blob (23)
  rec_field_dimensions = 24;  // Array field dimensions
  rec_files            = 25;  // files for shadowing
  rec_generator        = 26;  // another format for gen-ids
  rec_procedure        = 27;  // Stored procedure
  rec_procedure_prm    = 28;  // Stored procedure parameters
  rec_procedure_end    = 29;  // End of procedure and its args
  rec_exception        = 30;  // Exception
  rec_rel_constraint   = 31;  // Relation constraints
  rec_ref_constraint   = 32;  // Referential constraints
  rec_chk_constraint   = 33;  // Check constraints
  rec_charset          = 34;  // Character sets
  rec_collation        = 35;  // Collations
  rec_sql_roles        = 36;  // SQL roles
  rec_mapping          = 37;  // Mapping of security names
  rec_package          = 38;  // Package
  rec_db_creator       = 39;  // Database creator
  rec_publication      = 40;  // Publication
  rec_pub_table        = 41;  // Publication table


(* The order of battle for major records is:

	[<rec_physical_database>] <rec_database> <global fields> <field dimensions> <relation> <function>
	 <types> <filters> <relation data> <trigger-new> <trigger messages> <user privileges> <security> rec_end

where each relation is:

	<rec_relation> <rel name> <att_end> <local fields> <view> <rec_relation_end>

where local fields is:
	<rec_field> <att_field_... att_field_dimensions, att_field_range_low, att_field_range_high...> <att_end>

where each relation data is:

	<rec_relation_data> <rel attributes> <gen id> <indices> <data> <trigger-old> <rec_relation_end>

where data is:
	<rec_data> <rec length> [<xdr_length>]  <data attr>  [ <blob>, <array>...]

and <blob> is

	<rec_blob> <blob_field_number> <max_sigment> <blob_type> <number_segments> <blob_data>

and <array> is

	<rec_array> <blob_field_number> <att_array_dimensions> <att_array_range_low>
	<att_array_range_high> <blob_data> [<att_xdr_array>]


where each function is:

	<rec_function> <function attributes> <att_end> [<function_arguments>] <rec_function_end>

and <function_arguments> is

	<rec_function_arg> <function argument attributes> <att_end>

where trigger-old is:
	<rec_trigger> <trig_type> <trig_blr> <trig_source> <att_end>

and trigger-new is:
	<rec_trigger> <trig_type> <trig_blr> <trig_source> <trigger name> <relation name> <trig_seqence>
				  <description> <system flag> <att_end>


*)

// Attributes within major record

(*
   CAREFUL not to pull the lastest version into maint version without
   modifying the att_backup_format to be one version back


Version 6: IB6, FB1, FB1.5.
			Supports SQL Time & Date columns.
			  RDB$FIELD_PRECISION
			  SQL Dialect from database header
			  SQL_INT64 columns and generator values

Version 7: FB2.0.
			RDB$DESCRIPTION in roles and generators.
			RDB$BASE_COLLATION_NAME and RDB$SPECIFIC_ATTRIBUTES in collations

Version 8: FB2.1.
			RDB$RELATION_TYPE in relations
			RDB$PROCEDURE_TYPE and RDB$VALID_BLR in procedures
			RDB$VALID_BLR in triggers
			RDB$DEFAULT_VALUE, RDB$DEFAULT_SOURCE and RDB$COLLATION_ID in procedure_parameters

Version 9: FB2.5.
			RDB$MESSAGE domain was enlarged from 78 to 1021 in FB2.0 and to 1023 in FB2.5,
			but gbak wasn't adjusted accordingly and thus it cannot store reliably text that's
			longer than 255 bytes.
			We anyway tried a recovery routine in v2.5 that may be backported.

Version 10: FB3.0.
			See backup_capabilities in OdsDetection.h.

Version 11: FB4.0.
			SQL SECURITY feature, tables RDB$PUBLICATIONS/RDB$PUBLICATION_TABLES.
*)

const ATT_BACKUP_FORMAT = 11;

// max array dimension

const MAX_DIMENSION = 16;

const SERIES = 1;

const MAX_UPDATE_DBKEY_RECURSION_DEPTH = 16;


const // enum att_type
  att_end = 0;        // end of major record

  // Backup program attributes
  att_backup_date                   = SERIES;      // date of backup
  att_type_att_backup_format        = SERIES + 1;  // backup format version
  att_backup_os                     = SERIES + 2;  // backup operating system
  att_backup_compress               = SERIES + 3;
  att_backup_transportable          = SERIES + 4;  // XDR datatypes for user data
  att_backup_blksize                = SERIES + 5;  // backup block size
  att_backup_file                   = SERIES + 6;  // database file name
  att_backup_volume                 = SERIES + 7;  // backup volume number
  att_backup_keyname                = SERIES + 8;  // name of crypt key
	att_backup_zip                    = SERIES + 9;  // zipped backup file
	att_backup_hash                   = SERIES + 10; // hash of crypt key
	att_backup_crypt                  = SERIES + 11; // name of crypt plugin

  // Database attributes

  att_file_name                        = SERIES;      // database file name (physical)
  att_file_size                        = SERIES + 1;  // size of original database (physical)
  att_jrd_version                      = SERIES + 2;  // jrd version (physical)
  att_creation_date                    = SERIES + 3;  // database creation date (physical)
  att_page_size                        = SERIES + 4;  // page size of original database (physical)
  att_database_description             = SERIES + 5;  // description from RDB$DATABASE (logical)
  att_database_security_class          = SERIES + 6;  // database level security (logical)
  att_sweep_interval                   = SERIES + 7;  // sweep interval
  att_no_reserve                       = SERIES + 8;  // don't reserve space for versions
  att_database_description2            = SERIES + 9;
  att_database_dfl_charset             = SERIES + 10; // default character set from RDB$DATABASE
  att_forced_writes                    = SERIES + 11; // syncronous writes flag
  att_page_buffers                     = SERIES + 12; // page buffers for buffer cache
  att_SQL_dialect                      = SERIES + 13; // SQL dialect that it speaks
  att_db_read_only                     = SERIES + 14; // Is the database ReadOnly?
  att_database_linger                  = SERIES + 15; // Disconnection timeout
  att_database_sql_security_deprecated = SERIES + 16; // can be removed later
	att_replica_mode                     = SERIES + 17; // replica mode
	att_database_sql_security            = SERIES + 18; // default sql security value

  // Relation attributes

  att_relation_name                    = SERIES;
  att_relation_view_blr                = SERIES + 1;
  att_relation_description             = SERIES + 2;
  att_relation_record_length           = SERIES + 3;  // Record length in file
  att_relation_view_relation           = SERIES + 4;
  att_relation_view_context            = SERIES + 5;
  att_relation_system_flag             = SERIES + 6;
  att_relation_security_class          = SERIES + 7;
  att_relation_view_source             = SERIES + 8;
  att_relation_dummy                   = SERIES + 9;  // this space available
  att_relation_ext_description         = SERIES + 10;
  att_relation_owner_name              = SERIES + 11;
  att_relation_description2            = SERIES + 12;
  att_relation_view_source2            = SERIES + 13;
  att_relation_ext_description2        = SERIES + 14;
  att_relation_flags                   = SERIES + 15;
  att_relation_ext_file_name           = SERIES + 16; // name of file for external tables
  att_relation_type                    = SERIES + 17;
  att_relation_sql_security_deprecated = SERIES + 18; // can be removed later
	att_relation_sql_security            = SERIES + 19;

  // Field attributes (used for both global and local fields)

  att_field_name                    = SERIES;      // name of field
  att_field_source                  = SERIES + 1;  // Global field name for local field

  att_base_field                    = SERIES + 2;  // Source field for view
  att_view_context                  = SERIES + 3;  // Context variable for view definition

  att_field_query_name              = SERIES + 4;  // Query attributes
  att_field_query_header            = SERIES + 5;
  att_field_edit_string             = SERIES + 6;

  att_field_type                    = SERIES + 7;  // Physical attributes
  att_field_sub_type                = SERIES + 8;
  att_field_length                  = SERIES + 9;  // 10
  att_field_scale                   = SERIES + 10;
  att_field_segment_length          = SERIES + 11;
  att_field_position                = SERIES + 12; // Field position in relation (not in file)
  att_field_offset                  = SERIES + 13; // Offset in data record (local fields only)

  att_field_default_value           = SERIES + 14; // Fluff
  att_field_description             = SERIES + 15;
  att_field_missing_value           = SERIES + 16;
  att_field_computed_blr            = SERIES + 17;
  att_field_computed_source         = SERIES + 18;
  att_field_validation_blr          = SERIES + 19; // 20
  att_field_validation_source       = SERIES + 20;
  att_field_number                  = SERIES + 21; // Field number to match up blobs
  att_field_computed_flag           = SERIES + 22; // Field is computed = SERIES + ; not real
  att_field_system_flag             = SERIES + 23; // Interesting system flag
  att_field_security_class          = SERIES + 24;

  att_field_external_length         = SERIES + 25;
  att_field_external_type           = SERIES + 26;
  att_field_external_scale          = SERIES + 27;
  att_field_dimensions              = SERIES + 28; // 29
  att_field_ranges                  = SERIES + 29; // this space for rent
  att_field_complex_name            = SERIES + 30; // relation field attribute
  att_field_range_low               = SERIES + 31; // low range for array
  att_field_range_high              = SERIES + 32; // high range for array
  att_field_update_flag             = SERIES + 33;
  att_field_description2            = SERIES + 34;
  att_field_validation_source2      = SERIES + 35;
  att_field_computed_source2        = SERIES + 36;
  att_field_null_flag               = SERIES + 37;  // If field can be null
  att_field_default_source          = SERIES + 38;  // default source for field (new fmt only)
  att_field_missing_source          = SERIES + 39;  // missing source for field (new fmt only)
  att_field_character_length        = SERIES + 40;  // length of field in characters
  att_field_character_set           = SERIES + 41;  // Charset id of field
  att_field_collation_id            = SERIES + 42;  // Collation id of field
  att_field_precision               = SERIES + 43;  // numeric field precision of RDB$FIELDS (44)

  // beware that several items are shared between rdb$fields and rdb$relation_fields,
  // hence the new atributes for rdb$fields may be already present
  // att_field_security_class, // already used for relation_fields
  att_field_owner_name              = SERIES + 44;  // FB3.0, ODS12_0,
  att_field_generator_name          = SERIES + 45;
  att_field_identity_type           = SERIES + 46;

  // Index attributes

  att_index_name                    = SERIES;
  att_segment_count                 = SERIES + 1;
  att_index_inactive                = SERIES + 2;
  att_index_unique_flag             = SERIES + 3;
  att_index_field_name              = SERIES + 4;
  att_index_description             = SERIES + 5;
  att_index_type                    = SERIES + 6;
  att_index_foreign_key             = SERIES + 7;
  att_index_description2            = SERIES + 8;
  att_index_expression_source       = SERIES + 9;
  att_index_expression_blr          = SERIES + 10;

  // Data record

  att_data_length                   = SERIES;
  att_data_data                     = SERIES + 1;

  // Blob record

  att_blob_field_number             = SERIES + 2;  // Field number of blob field
  att_blob_type                     = SERIES + 3;  // Segmented = 0, stream = 1
  att_blob_number_segments          = SERIES + 4;  // Number of segments
  att_blob_max_segment              = SERIES + 5;  // Longest segment
  att_blob_data                     = SERIES + 6;

  // View attributes

  att_view_relation_name            = SERIES + 7;
  att_view_context_id               = SERIES + 8;
  att_view_context_name             = SERIES + 9;
  att_view_context_type             = SERIES + 10;
  att_view_context_package          = SERIES + 11;

  // Security class attributes

  att_class_security_class          = SERIES + 10;
  att_class_acl                     = SERIES + 11;
  att_class_description             = SERIES + 12;


  // Array attributes

  att_array_dimensions              = SERIES + 13;
  att_array_range_low               = SERIES + 14;
  att_array_range_high              = SERIES + 15;

  // XDR encoded data attributes

  att_xdr_length                    = SERIES + 16;
  att_xdr_array                     = SERIES + 17;
  att_class_description2            = SERIES + 18;

  // Trigger attributes

  att_trig_type                     = SERIES;
  att_trig_blr                      = SERIES + 1;
  att_trig_source                   = SERIES + 2;
  att_trig_name                     = SERIES + 3;
  att_trig_relation_name            = SERIES + 4;
  att_trig_sequence                 = SERIES + 5;
  att_trig_description              = SERIES + 6;
  att_trig_system_flag              = SERIES + 7;
  att_trig_inactive                 = SERIES + 8;
  att_trig_source2                  = SERIES + 9;
  att_trig_description2             = SERIES + 10;
  att_trig_flags                    = SERIES + 11;
  att_trig_valid_blr                = SERIES + 12;
  att_trig_debug_info               = SERIES + 13;
  att_trig_engine_name              = SERIES + 14;
  att_trig_entrypoint               = SERIES + 15;
  att_trig_type2                    = SERIES + 16;
  att_trig_sql_security_deprecated  = SERIES + 17; // can be removed later
	att_trig_sql_security             = SERIES + 18;

  // Function attributes

  att_function_name                    = SERIES;
  att_function_description             = SERIES + 1;
  att_function_class                   = SERIES + 2;
  att_function_module_name             = SERIES + 3;
  att_function_entrypoint              = SERIES + 4;
  att_function_return_arg              = SERIES + 5;
  att_function_query_name              = SERIES + 6;
  att_function_type                    = SERIES + 7;
  att_function_description2            = SERIES + 8;
  att_function_engine_name             = SERIES + 9; // FB3.0, ODS12_0
  att_function_package_name            = SERIES + 10;
  att_function_private_flag            = SERIES + 11;
  att_function_blr                     = SERIES + 12;
  att_function_source                  = SERIES + 13;
  att_function_valid_blr               = SERIES + 14;
  att_function_debug_info              = SERIES + 15;
  att_function_security_class          = SERIES + 16;
  att_function_owner_name              = SERIES + 17;
  att_function_legacy_flag             = SERIES + 18;
  att_function_deterministic_flag      = SERIES + 19;
  att_function_sql_security_deprecated = SERIES + 20; // can be removed later
	att_function_sql_security            = SERIES + 21;

  // Function argument attributes

  att_functionarg_name              = SERIES;
  att_functionarg_position          = SERIES + 1;
  att_functionarg_passing_mechanism = SERIES + 2; // by value = SERIES + ; ref = SERIES + ; descriptor
  att_functionarg_field_type        = SERIES + 3;
  att_functionarg_field_scale       = SERIES + 4;
  att_functionarg_field_length      = SERIES + 5;
  att_functionarg_field_sub_type    = SERIES + 6;
  att_functionarg_character_set     = SERIES + 7;
  att_functionarg_field_precision   = SERIES + 8;
  att_functionarg_package_name      = SERIES + 9; // FB3.0 = SERIES + ; ODS12_0
  att_functionarg_arg_name          = SERIES + 10;
  att_functionarg_field_source      = SERIES + 11;
  att_functionarg_default_value     = SERIES + 12;
  att_functionarg_default_source    = SERIES + 13;
  att_functionarg_collation_id      = SERIES + 14;
  att_functionarg_null_flag         = SERIES + 15;
  att_functionarg_type_mechanism    = SERIES + 16; // type inheritance
  att_functionarg_field_name        = SERIES + 17;
  att_functionarg_relation_name     = SERIES + 18;
  att_functionarg_description       = SERIES + 19;

  // TYPE relation attributes
  att_type_name                     = SERIES;
  att_type_type                     = SERIES + 1;
  att_type_field_name               = SERIES + 2;
  att_type_description              = SERIES + 3;
  att_type_system_flag              = SERIES + 4;
  // Also see att_type_description2 below!

  // Filter attributes
  att_filter_name                   = SERIES + 5;
  att_filter_description            = SERIES + 6;
  att_filter_module_name            = SERIES + 7;
  att_filter_entrypoint             = SERIES + 8;
  att_filter_input_sub_type         = SERIES + 9;
  att_filter_output_sub_type        = SERIES + 10;
  att_filter_description2           = SERIES + 11;
  att_type_description2             = SERIES + 12;

  // Trigger message attributes
  att_trigmsg_name                  = SERIES;
  att_trigmsg_number                = SERIES + 1;
  att_trigmsg_text                  = SERIES + 2;

  // User privilege attributes
  att_priv_user                     = SERIES;
  att_priv_grantor                  = SERIES + 1;
  att_priv_privilege                = SERIES + 2;
  att_priv_grant_option             = SERIES + 3;
  att_priv_object_name              = SERIES + 4;
  att_priv_field_name               = SERIES + 5;
  att_priv_user_type                = SERIES + 6;
  att_priv_obj_type                 = SERIES + 7;

  // files for shadowing purposes
  att_file_filename                 = SERIES;
  att_file_sequence                 = SERIES + 1;
  att_file_start                    = SERIES + 2;
  att_file_length                   = SERIES + 3;
  att_file_flags                    = SERIES + 4;
  att_shadow_number                 = SERIES + 5;

  // Attributes for gen_id
  att_gen_generator                 = SERIES;
  att_gen_value                     = SERIES + 1;
  att_gen_value_int64               = SERIES + 2;
  att_gen_description               = SERIES + 3;
  att_gen_security_class            = SERIES + 4; // FB3.0, ODS12_0
  att_gen_owner_name                = SERIES + 5;
  att_gen_sysflag                   = SERIES + 6;
  att_gen_init_val                  = SERIES + 7;
  att_gen_id_increment              = SERIES + 8;

  // Stored procedure attributes

  att_procedure_name                    = SERIES;
  att_procedure_inputs                  = SERIES + 1;
  att_procedure_outputs                 = SERIES + 2;
  att_procedure_description             = SERIES + 3;
  att_procedure_description2            = SERIES + 4;
  att_procedure_source                  = SERIES + 5;
  att_procedure_source2                 = SERIES + 6;
  att_procedure_blr                     = SERIES + 7;
  att_procedure_security_class          = SERIES + 8;
  att_procedure_owner_name              = SERIES + 9;
  att_procedure_type                    = SERIES + 10;
  att_procedure_valid_blr               = SERIES + 11;
  att_procedure_debug_info              = SERIES + 12;
  att_procedure_engine_name             = SERIES + 13;
  att_procedure_entrypoint              = SERIES + 14;
  att_procedure_package_name            = SERIES + 15;
  att_procedure_private_flag            = SERIES + 16;
  att_procedure_sql_security_deprecated = SERIES + 17; // can be removed later
  att_procedure_sql_security            = SERIES + 18;

  // Stored procedure parameter attributes

  att_procedureprm_name             = SERIES;
  att_procedureprm_number           = SERIES + 1;
  att_procedureprm_type             = SERIES + 2;
  att_procedureprm_field_source     = SERIES + 3;
  att_procedureprm_description      = SERIES + 4;
  att_procedureprm_description2     = SERIES + 5;
  att_procedureprm_default_value    = SERIES + 6;
  att_procedureprm_default_source   = SERIES + 7;
  att_procedureprm_collation_id     = SERIES + 8;
  att_procedureprm_null_flag        = SERIES + 9;
  att_procedureprm_mechanism        = SERIES + 10;
  att_procedureprm_field_name       = SERIES + 11;
  att_procedureprm_relation_name    = SERIES + 12;

  // Exception attributes

  att_exception_name                = SERIES;
  att_exception_msg                 = SERIES + 1;
  att_exception_description         = SERIES + 2;
  att_exception_description2        = SERIES + 3;
  att_exception_msg2                = SERIES + 4;
  att_exception_security_class      = SERIES + 5; // FB3.0, ODS12_0
  att_exception_owner_name          = SERIES + 6;

  // Relation constraints attributes

  att_rel_constraint_name           = SERIES;
  att_rel_constraint_type           = SERIES + 1;
  att_rel_constraint_rel_name       = SERIES + 2;
  att_rel_constraint_defer          = SERIES + 3;
  att_rel_constraint_init           = SERIES + 4;
  att_rel_constraint_index          = SERIES + 5;

  // Referential constraints attributes

  att_ref_constraint_name           = SERIES;
  att_ref_unique_const_name         = SERIES + 1;
  att_ref_match_option              = SERIES + 2;
  att_ref_update_rule               = SERIES + 3;
  att_ref_delete_rule               = SERIES + 4;

  // SQL roles attributes
  att_role_name                     = SERIES;
  att_role_owner_name               = SERIES + 1;
  att_role_description              = SERIES + 2;
  att_role_sys_priveleges           = SERIES + 3;

  // Check constraints attributes
  att_chk_constraint_name           = SERIES;
  att_chk_trigger_name              = SERIES + 1;

  // Character Set attributes
  att_charset_name                  = SERIES;
  att_charset_form                  = SERIES + 1;
  att_charset_numchar               = SERIES + 2;
  att_charset_coll                  = SERIES + 3;
  att_charset_id                    = SERIES + 4;
  att_charset_sysflag               = SERIES + 5;
  att_charset_description           = SERIES + 6;
  att_charset_funct                 = SERIES + 7;
  att_charset_bytes_char            = SERIES + 8;
  att_charset_security_class        = SERIES + 9; // FB3.0, ODS12_0
  att_charset_owner_name            = SERIES + 10;

  att_coll_name                     = SERIES;
  att_coll_id                       = SERIES + 1;
  att_coll_cs_id                    = SERIES + 2;
  att_coll_attr                     = SERIES + 3;
  att_coll_subtype                  = SERIES + 4;    // Unused: 93-11-12 Daves
  att_coll_sysflag                  = SERIES + 5;
  att_coll_description              = SERIES + 6;
  att_coll_funct                    = SERIES + 7;
  att_coll_base_collation_name      = SERIES + 8;
  att_coll_specific_attr            = SERIES + 9;
  att_coll_security_class           = SERIES + 10; // FB3.0, ODS12_0
  att_coll_owner_name               = SERIES + 11;

  // Names mapping
  att_map_name                      = SERIES;
  att_map_using                     = SERIES + 1;
  att_map_plugin                    = SERIES + 2;
  att_auto_map_role                 = SERIES + 3;    // Keep it at pos.4 - ODS11.2 compatibility issue
  att_map_db                        = SERIES + 4;
  att_map_from_type                 = SERIES + 5;
  att_map_from                      = SERIES + 6;
  att_map_to_type                   = SERIES + 7;
  att_map_to                        = SERIES + 8;
  att_map_description               = SERIES + 9;

  // Package attributes
  att_package_name                    = SERIES;
  att_package_header_source           = SERIES + 1;
  att_package_body_source             = SERIES + 2;
  att_package_valid_body_flag         = SERIES + 3;
  att_package_security_class          = SERIES + 4;
  att_package_owner_name              = SERIES + 5;
  att_package_description             = SERIES + 6;
  att_package_sql_security_deprecated = SERIES + 7; // can be removed later
	att_package_sql_security            = SERIES + 8;

  // Database creators
	att_dbc_user   = SERIES;
	att_dbc_type   = SERIES + 1;

  // Publications
	att_pub_name         = SERIES;
	att_pub_owner_name   = SERIES + 1;
	att_pub_active_flag  = SERIES + 2;
	att_pub_auto_enable  = SERIES + 3;

  // Publication tables
	att_ptab_pub_name    = SERIES;
	att_ptab_table_name  = SERIES + 1;



const   // enum Trigger types
  trig_pre_store  = 1;   // default
  trig_pre_modify = 2;   // default
  trig_post_erase = 3;   // default

// these types to go away when recognized by gpre as
// <relation>.<field>.<type>  some time in the future

const TRIG_TYPE_PRE_STORE  = 1;
const TRIG_TYPE_PRE_MODIFY = 3;
const TRIG_TYPE_POST_ERASE = 6;

// default trigger name templates

const TRIGGER_SEQUENCE_DEFAULT = 0;

// common structure definitions

// field block, used to hold local field definitions

type
  burp_fld = record
    fld_next: ^burp_fld;
    fld_type: Int16;
    fld_sub_type: Int16;
    fld_length: Word;
    fld_total_len: Word;  // including additional 2 bytes for VARYING CHAR
    fld_scale: Int16;
    fld_position: Int16;
    fld_parameter: Int16;
    fld_missing_parameter: Int16;
    fld_id: Int16;
    fld_offset: Cardinal;
    fld_missing_offset: Cardinal;
    fld_old_offset: Cardinal;
    fld_number: Int16;
    fld_system_flag: Int16;
    fld_name_length: Int16;
    fld_name: array[0..GDS_NAME_LEN - 1] of Char;
    fld_source: array[0..GDS_NAME_LEN - 1] of Char;
    fld_base: array[0..GDS_NAME_LEN - 1] of Char;
    fld_query_name: array[0..GDS_NAME_LEN - 1] of Char;
    fld_security_class: array[0..GDS_NAME_LEN - 1] of Char;
    fld_generator: array[0..GDS_NAME_LEN - 1] of Char;
    fld_identity_type: Int16;
    //fld_edit_length: Int16;
    fld_view_context: Int16;
    fld_update_flag: Int16;
    fld_flags: Int16;
    // Can't do here
    // BASED_ON RDB$RDB$RELATION_FIELDS.RDB$EDIT_STRING fld_edit_string;
    fld_edit_string: array[0..127] of Char; // was [256]
    fld_description: ISC_QUAD;
    fld_query_header: ISC_QUAD;
    fld_complex_name: array[0..GDS_NAME_LEN - 1] of Char;
    fld_dimensions: Int16;
    fld_ranges: array[0..((2 * MAX_DIMENSION) - 1)] of Integer;
    fld_null_flag: Int16;
    fld_default_value: ISC_QUAD;
    fld_default_source: ISC_QUAD;
    fld_character_set_id: Int16;
    fld_collation_id: Int16;
    fld_sql: Cardinal;
    fld_null: Cardinal;
  end;

const   // enum fld_flags_vals
  FLD_computed         = 1;
	FLD_position_missing = 2;
	FLD_array            = 4;
	FLD_update_missing   = 8;
	FLD_null_flag        = 16;
	FLD_charset_flag     = 32;  // column has global charset
	FLD_collate_flag     = 64;  // local column has specific collation

// relation definition - holds useful relation type stuff

type
  burp_rel = record
    rel_next: ^burp_rel;
    rel_fields: ^burp_fld;
    rel_flags: Int16;
    rel_id: Int16;
    rel_name_length: Int16;
    rel_name: GDS_NAME;
    rel_owner: GDS_NAME;    // relation owner, if not us
  end;

const   // enum burp_rel_flags_vals
  REL_view     = 1;
	REL_external = 2;

type
  // package definition
  burp_pkg = record
    pkg_next: ^burp_pkg;
    pkg_name: GDS_NAME;
    pkg_owner: GDS_NAME;
  end;

  // procedure definition - holds useful procedure type stuff

  burp_prc = record
    prc_next: ^burp_prc;
    //prc_name_length: Int16; // Currently useless, but didn't want to delete it.
    prc_package: GDS_NAME;
    prc_name: GDS_NAME;
    prc_owner: GDS_NAME;    // relation owner, if not us
  end;

  gfld = record
    gfld_name: array[0..GDS_NAME_LEN - 1] of Char;
    gfld_vb: ISC_QUAD;
    gfld_vs: ISC_QUAD;
    gfld_vs2: ISC_QUAD;
    gfld_computed_blr: ISC_QUAD;
    gfld_computed_source: ISC_QUAD;
    gfld_computed_source2: ISC_QUAD;
    gfld_next: ^gfld;
    gfld_flags: Word;
  end;

const   // enum gfld_flags_vals
  GFLD_validation_blr     = 1;
	GFLD_validation_source  = 2;
	GFLD_validation_source2 = 4;
	GFLD_computed_blr       = 8;
	GFLD_computed_source    = 16;
	GFLD_computed_source2   = 32;


type
  burp_meta_obj = record
    obj_next: ^burp_meta_obj;
    obj_type: Word;
    obj_name: GDS_NAME;
    obj_class: Boolean;
  end;

// CVC: Could use MAXPATHLEN, but what about restoring in a different system?
// I need to review if we tolerate different lengths for different OS's here.
const MAX_FILE_NAME_SIZE = 256;

//#include "../burp/std_desc.h"

//#ifdef WIN_NT

//inline static void close_platf(DESC file)
//{
//	CloseHandle(file);
//}

//inline static void unlink_platf(const TEXT* file_name)
//{
//	DeleteFile(file_name);
//}

//inline static void flush_platf(DESC file)
//{
//	FlushFileBuffers(file);
//}

//#else // WIN_NT

//void close_platf(DESC file);

//inline static void unlink_platf(const TEXT* file_name)
//{
//	unlink(file_name);
//}

//inline static void flush_platf(DESC file)
//{
//#if defined(HAVE_FDATASYNC)
//	fdatasync(file);
//#elif defined(HAVE_FSYNC)
//	fsync(file);
//#endif
//}

//#endif // WIN_NT

// File block -- for multi-file databases

const   // enum SIZE_CODE
  size_n = 0;  // none
	size_k = 1;  // k = 1024
	size_m = 2;  // m = k x 1024
	size_g = 3;  // g = m x 1024
	size_e = 4;  // error

//class burp_fil
//{
//public:
//	burp_fil*	fil_next;
//	Firebird::PathName	fil_name;
//	FB_UINT64	fil_length;
//	DESC		fil_fd;
//	USHORT		fil_seq;
//	SIZE_CODE	fil_size_code;
//
//burp_fil(Firebird::MemoryPool& p)
//	: fil_next(0), fil_name(p), fil_length(0),
//	  fil_fd(INVALID_HANDLE_VALUE), fil_seq(0), fil_size_code(size_n) { }
//};

// Split & Join stuff

type
  act_t = (
    ACT_unknown,      // action is unknown
    ACT_backup,
    ACT_backup_split,
    ACT_backup_fini,
    ACT_restore,
    ACT_restore_join
  );

//  burp_act = record
//    act_total: Word;
//		act_file: ^burp_fil;
//		act_action: act_t;
//  end;

//const ACT_LEN = sizeof(burp_act);

const MAX_LENGTH = not Int64(0);	// Keep in sync with burp_fil.fil_length

type
  hdr_split = record
    hdr_split_tag: array[0..17] of Char;
    hdr_split_timestamp: array[0..29] of Char;
    hdr_split_text1: array[0..10] of Char;
    hdr_split_sequence: array[0..3] of Char;  // File sequence number
    hdr_split_text2: array[0..3] of Char;
    hdr_split_total: array[0..3] of Char;     // Total number of files
    hdr_split_text3: array[0..1] of Char;
    hdr_split_name: array[0..26] of Char;     // File name
  end;


// NOTE: size of the hdr_split_tag and HDR_SPLIT_TAG must be the same and equal
// to 18. Otherwise we will not be able to join the gbk files v5.x

const HDR_SPLIT_SIZE = sizeof(hdr_split);
const HDR_SPLIT_TAG5 = 'InterBase/gsplit, ';
const HDR_SPLIT_TAG6 = 'InterBase/gbak,   ';
// CVC: Don't convert to const char* or you will have to fix the sizeof()'s!!!
const HDR_SPLIT_TAG = HDR_SPLIT_TAG6;
const MIN_SPLIT_SIZE = Int64(2048);		// bytes


// Global switches and data

type BurpCrypt = record end;

//class GblPool
//{
//private:
//	// Moved it to separate class in order to ensure 'first create/last destroy' order
//	Firebird::MemoryPool* gbl_pool;
//public:
//	Firebird::MemoryPool& getPool()
//	{
//		fb_assert(gbl_pool);
//		return *gbl_pool;
//	}
//
//	explicit GblPool(bool ownPool)
//		: gbl_pool(ownPool ? MemoryPool::createPool(getDefaultMemoryPool()) : getDefaultMemoryPool())
//	{ }
//
//	~GblPool()
//	{
//		if (gbl_pool != getDefaultMemoryPool())
//			Firebird::MemoryPool::deletePool(gbl_pool);
//	}
//};

//class BurpGlobals : public Firebird::ThreadData, public GblPool
//{
//public:
//	explicit BurpGlobals(Firebird::UtilSvc* us)
//		: ThreadData(ThreadData::tddGBL),
//		  GblPool(us->isService()),
//		  defaultCollations(getPool()),
//		  uSvc(us),
//		  verboseInterval(10000),
//		  flag_on_line(true),
//		  firstMap(true),
//		  firstDbc(true),
//		  stdIoMode(false)
//	{
//		// this is VERY dirty hack to keep current (pre-FB2) behaviour
//		memset (&gbl_database_file_name, 0,
//			&veryEnd - reinterpret_cast<char*>(&gbl_database_file_name));
//
//		// normal code follows
//		gbl_stat_flags = 0;
//		gbl_stat_header = false;
//		gbl_stat_done = false;
//		memset(gbl_stats, 0, sizeof(gbl_stats));
//		gbl_stats[TIME_TOTAL] = gbl_stats[TIME_DELTA] = fb_utils::query_performance_counter();
//
//		exit_code = FINI_ERROR;	// prevent FINI_OK in case of unknown error thrown
//								// would be set to FINI_OK (==0) in exit_local
//	}
//
//	const TEXT*	gbl_database_file_name;
//	TEXT		gbl_backup_start_time[30];
//	bool		gbl_sw_verbose;
//	bool		gbl_sw_ignore_limbo;
//	bool		gbl_sw_meta;
//	bool		gbl_sw_novalidity;
//	USHORT		gbl_sw_page_size;
//	bool		gbl_sw_compress;
//	bool		gbl_sw_version;
//	bool		gbl_sw_transportable;
//	bool		gbl_sw_incremental;
//	bool		gbl_sw_deactivate_indexes;
//	bool		gbl_sw_kill;
//	USHORT		gbl_sw_blk_factor;
//	USHORT		gbl_dialect;
//	const SCHAR*	gbl_sw_fix_fss_data;
//	USHORT			gbl_sw_fix_fss_data_id;
//	const SCHAR*	gbl_sw_fix_fss_metadata;
//	USHORT			gbl_sw_fix_fss_metadata_id;
//	bool		gbl_sw_no_reserve;
//	bool		gbl_sw_old_descriptions;
//	bool		gbl_sw_convert_ext_tables;
//	bool		gbl_sw_mode;
//	bool		gbl_sw_mode_val;
//	bool		gbl_sw_overwrite;
//	bool		gbl_sw_zip;
//	const SCHAR*	gbl_sw_keyholder;
//	const SCHAR*	gbl_sw_crypt;
//	const SCHAR*	gbl_sw_keyname;
//	SCHAR			gbl_hdr_keybuffer[MAX_SQL_IDENTIFIER_SIZE];
//	SCHAR			gbl_hdr_cryptbuffer[MAX_SQL_IDENTIFIER_SIZE];
//	const SCHAR*	gbl_sw_sql_role;
//	const SCHAR*	gbl_sw_user;
//	const SCHAR*	gbl_sw_password;
//	SLONG		gbl_sw_skip_count;
//	SLONG		gbl_sw_page_buffers;
//	burp_fil*	gbl_sw_files;
//	burp_fil*	gbl_sw_backup_files;
//	gfld*		gbl_global_fields;
//	unsigned	gbl_network_protocol;
//	burp_act*	action;
//	BurpCrypt*	gbl_crypt;
//	ULONG		io_buffer_size;
//	redirect_vals	sw_redirect;
//	bool		burp_throw;
//	Nullable<ReplicaMode>	gbl_sw_replica;
//
//	UCHAR*		blk_io_ptr;
//	int			blk_io_cnt;
//
//	void put(const UCHAR c)
//	{
//		if (gbl_io_cnt <= 0)
//			MVOL_write(this);
//
//		--gbl_io_cnt;
//		*gbl_io_ptr++ = c;
//	}
//
//	UCHAR get()
//	{
//		if (gbl_io_cnt <= 0)
//			MVOL_read(this);
//
//		--gbl_io_cnt;
//		return *gbl_io_ptr++;
//	}
//
//#ifdef WIRE_COMPRESS_SUPPORT
//	z_stream	gbl_stream;
//#endif
//	UCHAR*		gbl_io_ptr;
//	int			gbl_io_cnt;
//	UCHAR*		gbl_compress_buffer;
//	UCHAR*		gbl_crypt_buffer;
//	ULONG		gbl_crypt_left;
//	UCHAR*      gbl_decompress;
//
//	burp_rel*	relations;
//	burp_pkg*	packages;
//	burp_prc*	procedures;
//	burp_meta_obj*	miss_privs;
//	// ODS of the target server (not necessarily the same version as gbak)
//	int			runtimeODS;
//	// Format of the backup being read on restore; gbak always creates it using the latest version
//	// but it can read backups created by previous versions.
//	USHORT		RESTORE_format;
//	ULONG		mvol_io_buffer_size;
//	ULONG		mvol_actual_buffer_size;
//	FB_UINT64	mvol_cumul_count;
//	UCHAR*		mvol_io_ptr;
//	int			mvol_io_cnt;
//	UCHAR*		mvol_io_buffer;
//	UCHAR*		mvol_io_volume;
//	UCHAR*		mvol_io_header;
//	UCHAR*		mvol_io_data;
//	TEXT		mvol_db_name_buffer [MAX_FILE_NAME_SIZE];
//	SCHAR		mvol_old_file [MAX_FILE_NAME_SIZE];
//	int			mvol_volume_count;
//	bool		mvol_empty_file;
//	TEXT		mvol_keyname_buffer[MAX_FILE_NAME_SIZE];
//	const TEXT*	mvol_keyname;
//	TEXT		mvol_crypt_buffer[MAX_FILE_NAME_SIZE];
//	const TEXT*	mvol_crypt;
//	TEXT		gbl_key_hash[(Firebird::Sha1::HASH_SIZE + 1) * 4 / 3 + 1];	// take into an account base64
//	Firebird::IAttachment*	db_handle;
//	Firebird::ITransaction*	tr_handle;
//	Firebird::ITransaction*	global_trans;
//	DESC		file_desc;
//	int			exit_code;
//	UCHAR*		head_of_mem_list;
//	FILE*		output_file;
//
//	// Link list of global fields that were converted from V3 sub_type
//	// to V4 char_set_id/collate_id. Needed for local fields conversion.
//	// burp_fld*	v3_cvt_fld_list;
//
//	// The handles_get... are for restore.
//	Firebird::IRequest*	handles_get_character_sets_req_handle1;
//	Firebird::IRequest*	handles_get_chk_constraint_req_handle1;
//	Firebird::IRequest*	handles_get_collation_req_handle1;
//	Firebird::IRequest*	handles_get_db_creators_req_handle1;
//	Firebird::IRequest*	handles_get_exception_req_handle1;
//	Firebird::IRequest*	handles_get_field_dimensions_req_handle1;
//	Firebird::IRequest*	handles_get_field_req_handle1;
//	Firebird::IRequest*	handles_get_fields_req_handle1;
//	Firebird::IRequest*	handles_get_fields_req_handle2;
//	Firebird::IRequest*	handles_get_fields_req_handle3;
//	Firebird::IRequest*	handles_get_fields_req_handle4;
//	Firebird::IRequest*	handles_get_fields_req_handle5;
//	Firebird::IRequest*	handles_get_fields_req_handle6;
//	Firebird::IRequest*	handles_get_files_req_handle1;
//	Firebird::IRequest*	handles_get_filter_req_handle1;
//	Firebird::IRequest*	handles_get_function_arg_req_handle1;
//	Firebird::IRequest*	handles_get_function_req_handle1;
//	Firebird::IRequest*	handles_get_global_field_req_handle1;
//	Firebird::IRequest*	handles_get_index_req_handle1;
//	Firebird::IRequest*	handles_get_index_req_handle2;
//	Firebird::IRequest*	handles_get_index_req_handle3;
//	Firebird::IRequest*	handles_get_index_req_handle4;
//	Firebird::IRequest*	handles_get_mapping_req_handle1;
//	Firebird::IRequest*	handles_get_package_req_handle1;
//	Firebird::IRequest*	handles_get_procedure_prm_req_handle1;
//	Firebird::IRequest*	handles_get_procedure_req_handle1;
//	Firebird::IRequest*	handles_get_pub_req_handle1;
//	Firebird::IRequest*	handles_get_pub_tab_req_handle1;
//	Firebird::IRequest*	handles_get_ranges_req_handle1;
//	Firebird::IRequest*	handles_get_ref_constraint_req_handle1;
//	Firebird::IRequest*	handles_get_rel_constraint_req_handle1;
//	Firebird::IRequest*	handles_get_relation_req_handle1;
//	Firebird::IRequest*	handles_get_security_class_req_handle1;
//	Firebird::IRequest*	handles_get_sql_roles_req_handle1;
//	Firebird::IRequest*	handles_get_trigger_message_req_handle1;
//	Firebird::IRequest*	handles_get_trigger_message_req_handle2;
//	Firebird::IRequest*	handles_get_trigger_old_req_handle1;
//	Firebird::IRequest*	handles_get_trigger_req_handle1;
//	Firebird::IRequest*	handles_get_trigger_req_handle2;
//	Firebird::IRequest*	handles_get_type_req_handle1;
//	Firebird::IRequest*	handles_get_user_privilege_req_handle1;
//	Firebird::IRequest*	handles_get_view_req_handle1;
//
//	// The handles_put.. are for backup.
//	Firebird::IRequest*	handles_put_index_req_handle1;
//	Firebird::IRequest*	handles_put_index_req_handle2;
//	Firebird::IRequest*	handles_put_index_req_handle3;
//	Firebird::IRequest*	handles_put_index_req_handle4;
//	Firebird::IRequest*	handles_put_index_req_handle5;
//	Firebird::IRequest*	handles_put_index_req_handle6;
//	Firebird::IRequest*	handles_put_index_req_handle7;
//	Firebird::IRequest*	handles_put_relation_req_handle1;
//	Firebird::IRequest*	handles_put_relation_req_handle2;
//	Firebird::IRequest*	handles_store_blr_gen_id_req_handle1;
//	Firebird::IRequest*	handles_write_function_args_req_handle1;
//	Firebird::IRequest*	handles_write_function_args_req_handle2;
//	Firebird::IRequest*	handles_write_procedure_prms_req_handle1;
//	Firebird::IRequest*	handles_fix_security_class_name_req_handle1;
//
//	bool			hdr_forced_writes;
//	TEXT			database_security_class[GDS_NAME_LEN]; // To save database security class for deferred update
//	unsigned		batchInlineBlobLimit;
//
//	static inline BurpGlobals* getSpecific()
//	{
//		return (BurpGlobals*) ThreadData::getSpecific();
//	}
//	static inline void putSpecific(BurpGlobals* tdgbl)
//	{
//		tdgbl->ThreadData::putSpecific();
//	}
//	static inline void restoreSpecific()
//	{
//		ThreadData::restoreSpecific();
//	}
//	void setupSkipData(const Firebird::string& regexp);
//	void setupIncludeData(const Firebird::string& regexp);
//	bool skipRelation(const char* name);
//
//	char veryEnd;
//	//starting after this members must be initialized in constructor explicitly
//
//	Firebird::FbLocalStatus status_vector;
//	Firebird::ThrowLocalStatus throwStatus;
//
//	Firebird::Array<Firebird::Pair<Firebird::NonPooled<Firebird::MetaString, Firebird::MetaString> > >
//		defaultCollations;
//	Firebird::UtilSvc* uSvc;
//	ULONG verboseInterval;	// How many records should be backed up or restored before we show this message
//	bool flag_on_line;		// indicates whether we will bring the database on-line
//	bool firstMap;			// this is the first time we entered get_mapping()
//	bool firstDbc;			// this is the first time we entered get_db_creators()
//	bool stdIoMode;			// stdin or stdout is used as backup file
//	Firebird::AutoPtr<Firebird::SimilarToRegex> skipDataMatcher;
//	Firebird::AutoPtr<Firebird::SimilarToRegex> includeDataMatcher;
//
//public:
//	Firebird::string toSystem(const Firebird::PathName& from);
//
//	enum StatCounter { TIME_TOTAL = 0, TIME_DELTA, READS, WRITES, LAST_COUNTER};
//
//	void read_stats(SINT64* stats);
//	void print_stats(USHORT number);
//	void print_stats_header();
//
//	int gbl_stat_flags;					// bitmask, bit numbers see at enum StatCounter
//	bool gbl_stat_header;				// true, if stats header was printed
//	bool gbl_stat_done;					// true, if main process is done, stop to collect db-level stats
//	SINT64 gbl_stats[LAST_COUNTER];
//};

// CVC: This aux routine declared here to not force inclusion of burp.h with burp_proto.h
// in other modules.
//void	BURP_exit_local(int code, BurpGlobals* tdgbl);

// database is not on-line due to failure to activate one or more indices
const FINI_DB_NOT_ONLINE = 2;

(* Burp will always write a backup in multiples of the following number
 * of bytes.  The initial value is the smallest which ensures that writes
 * to fixed-block SCSI tapes such as QIC-150 will work.  The value should
 * always be a multiple of 512 for that reason.
 * If you change to a value which is NOT a power of 2, then change the
 * BURP_UP_TO_BLOCK macro to use division and multiplication instead of
 * bit masking.
 *)

const BURP_BLOCK		= 512;
function BURP_UP_TO_BLOCK(const size: Cardinal): Cardinal; inline;

// Move the read and write mode declarations in here from burp.cpp
// so that other files can see them for multivolume opens

{$ifdef WIN_NT}
const MODE_READ = $80000000;
const MODE_WRITE = $40000000;
{$else}
const MODE_READ = $0000;
const MODE_WRITE = $0001 or $0100;
{$endif}


// Burp Messages

const   // enum burp_messages_vals
  msgVerbose_write_charsets		= 211;
	msgVerbose_write_collations		= 212;
	msgErr_restore_charset			= 213;
	msgVerbose_restore_charset		= 214;
	msgErr_restore_collation		= 215;
	msgVerbose_restore_collation	= 216;

// BLOB buffer
//typedef Firebird::HalfStaticArray<UCHAR, 1024> BlobBuffer;

//class BurpSql : public Firebird::AutoStorage
//{
//public:
//	BurpSql(BurpGlobals* g, const char* sql)
//		: Firebird::AutoStorage(),
//		  tdgbl(g), stmt(nullptr)
//	{
//		stmt = tdgbl->db_handle->prepare(&tdgbl->throwStatus, tdgbl->tr_handle, 0, sql, 3, 0);
//	}
//
//	template <typename M>
//	void singleSelect(Firebird::ITransaction* trans, M* msg)
//	{
//		stmt->execute(&tdgbl->throwStatus, tdgbl->tr_handle, nullptr, nullptr, msg->getMetadata(), msg->getData());
//	}
//
//	template <typename M>
//	void execute(Firebird::ITransaction* trans, M* msg)
//	{
//		stmt->execute(&tdgbl->throwStatus, tdgbl->tr_handle, msg->getMetadata(), msg->getData(), nullptr, nullptr);
//	}
//
//	void execute(Firebird::ITransaction* trans)
//	{
//		stmt->execute(&tdgbl->throwStatus, tdgbl->tr_handle, nullptr, nullptr, nullptr, nullptr);
//	}
//
//private:
//	BurpGlobals* tdgbl;
//	Firebird::IStatement* stmt;
//};

//class OutputVersion : public Firebird::IVersionCallbackImpl<OutputVersion, Firebird::CheckStatusWrapper>
//{
//public:
//	OutputVersion(const char* printFormat)
//		: format(printFormat)
//	{ }
//
//	void callback(Firebird::CheckStatusWrapper* status, const char* text);
//
//private:
//	const char* format;
//};

//static inline UCHAR* BURP_alloc(ULONG size)
//{
//	BurpGlobals* tdgbl = BurpGlobals::getSpecific();
//	return (UCHAR*)(tdgbl->getPool().allocate(size ALLOC_ARGS));
//}

//static inline UCHAR* BURP_alloc_zero(ULONG size)
//{
//	BurpGlobals* tdgbl = BurpGlobals::getSpecific();
//	return (UCHAR*)(tdgbl->getPool().calloc(size ALLOC_ARGS));
//}

//static inline void BURP_free(void* block)
//{
//	MemoryPool::globalFree(block);
//}

implementation

function BURP_UP_TO_BLOCK(const size: Cardinal): Cardinal;
begin
  Result := (((size) + BURP_BLOCK - 1) and (not (BURP_BLOCK - 1)));
end;

end.
