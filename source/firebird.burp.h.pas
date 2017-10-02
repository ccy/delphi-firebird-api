unit firebird.burp.h;

interface

const
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

const SERIES = 1;

const // enum att_type
  att_end = 0;        // end of major record

  // Backup program attributes
  att_backup_date                   = SERIES;      // date of backup
  att_backup_format                 = SERIES + 1;  // backup format version
  att_backup_os                     = SERIES + 2;  // backup operating system
  att_backup_compress               = SERIES + 3;
  att_backup_transportable          = SERIES + 4;  // XDR datatypes for user data
  att_backup_blksize                = SERIES + 5;  // backup block size
  att_backup_file                   = SERIES + 6;  // database file name
  att_backup_volume                 = SERIES + 7;  // backup volume number

  // Database attributes
  att_file_name                     = SERIES;      // database file name (physical)
  att_file_size                     = SERIES + 1;  // size of original database (physical)
  att_jrd_version                   = SERIES + 2;  // jrd version (physical)
  att_creation_date                 = SERIES + 3;  // database creation date (physical)
  att_page_size                     = SERIES + 4;  // page size of original database (physical)
  att_database_description          = SERIES + 5;  // description from RDB$DATABASE (logical)
  att_database_security_class       = SERIES + 6;  // database level security (logical)
  att_sweep_interval                = SERIES + 7;  // sweep interval
  att_no_reserve                    = SERIES + 8;  // don't reserve space for versions
  att_database_description2         = SERIES + 9;
  att_database_dfl_charset          = SERIES + 10; // default character set from RDB$DATABASE
  att_forced_writes                 = SERIES + 11; // syncronous writes flag
  att_page_buffers                  = SERIES + 12; // page buffers for buffer cache
  att_SQL_dialect                   = SERIES + 13; // SQL dialect that it speaks
  att_db_read_only                  = SERIES + 14; // Is the database ReadOnly?
  att_database_linger               = SERIES + 15; // Disconnection timeout

  // Relation attributes

  att_relation_name                 = SERIES;
  att_relation_view_blr             = SERIES + 1;
  att_relation_description          = SERIES + 2;
  att_relation_record_length        = SERIES + 3;  // Record length in file
  att_relation_view_relation        = SERIES + 4;
  att_relation_view_context         = SERIES + 5;
  att_relation_system_flag          = SERIES + 6;
  att_relation_security_class       = SERIES + 7;
  att_relation_view_source          = SERIES + 8;
  att_relation_dummy                = SERIES + 9;  // this space available
  att_relation_ext_description      = SERIES + 10;
  att_relation_owner_name           = SERIES + 11;
  att_relation_description2         = SERIES + 12;
  att_relation_view_source2         = SERIES + 13;
  att_relation_ext_description2     = SERIES + 14;
  att_relation_flags                = SERIES + 15;
  att_relation_ext_file_name        = SERIES + 16; // name of file for external tables
  att_relation_type                 = SERIES + 17;

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
  att_field_owner_name              = SERIES + 44;  // FB3.0 = SERIES + ; ODS12_0 = SERIES + ;
  att_field_generator_name          = SERIES + 45;
  att_field_identity_type           = SERIES + 46;

  // Index attributes
  att_index_name                    = SERIES + 47;
  att_segment_count                 = SERIES + 48;
  att_index_inactive                = SERIES + 49;
  att_index_unique_flag             = SERIES + 50;
  att_index_field_name              = SERIES + 51;
  att_index_description             = SERIES + 52;
  att_index_type                    = SERIES + 53;
  att_index_foreign_key             = SERIES + 54;
  att_index_description2            = SERIES + 55;
  att_index_expression_source       = SERIES + 56;
  att_index_expression_blr          = SERIES + 57;

  // Data record
  att_data_length                   = SERIES;
  att_data_data                     = SERIES + 1;

  // Blob record
  att_blob_field_number             = SERIES + 2;  // Field number of blob field
  att_blob_type                     = SERIES + 3;  // Segmented = 0 = SERIES + ; stream = 1
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

  // Function attributes

  att_function_name                 = SERIES;
  att_function_description          = SERIES + 1;
  att_function_class                = SERIES + 2;
  att_function_module_name          = SERIES + 3;
  att_function_entrypoint           = SERIES + 4;
  att_function_return_arg           = SERIES + 5;
  att_function_query_name           = SERIES + 6;
  att_function_type                 = SERIES + 7;
  att_function_description2         = SERIES + 8;
  att_function_engine_name          = SERIES + 9; // FB3.0 = SERIES + ; ODS12_0
  att_function_package_name         = SERIES + 10;
  att_function_private_flag         = SERIES + 11;
  att_function_blr                  = SERIES + 12;
  att_function_source               = SERIES + 13;
  att_function_valid_blr            = SERIES + 14;
  att_function_debug_info           = SERIES + 15;
  att_function_security_class       = SERIES + 16;
  att_function_owner_name           = SERIES + 17;
  att_function_legacy_flag          = SERIES + 18;
  att_function_deterministic_flag   = SERIES + 19;

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
  att_gen_security_class            = SERIES + 4; // FB3.0 = SERIES + ; ODS12_0
  att_gen_owner_name                = SERIES + 5;
  att_gen_sysflag                   = SERIES + 6;
  att_gen_init_val                  = SERIES + 7;
  att_gen_id_increment              = SERIES + 8;

  // Stored procedure attributes
  att_procedure_name                = SERIES;
  att_procedure_inputs              = SERIES + 1;
  att_procedure_outputs             = SERIES + 2;
  att_procedure_description         = SERIES + 3;
  att_procedure_description2        = SERIES + 4;
  att_procedure_source              = SERIES + 5;
  att_procedure_source2             = SERIES + 6;
  att_procedure_blr                 = SERIES + 7;
  att_procedure_security_class      = SERIES + 8;
  att_procedure_owner_name          = SERIES + 9;
  att_procedure_type                = SERIES + 10;
  att_procedure_valid_blr           = SERIES + 11;
  att_procedure_debug_info          = SERIES + 12;
  att_procedure_engine_name         = SERIES + 13;
  att_procedure_entrypoint          = SERIES + 14;
  att_procedure_package_name        = SERIES + 15;
  att_procedure_private_flag        = SERIES + 16;

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
  att_exception_security_class      = SERIES + 5; // FB3.0 = SERIES + ; ODS12_0
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
  att_charset_security_class        = SERIES + 9; // FB3.0 = SERIES + ; ODS12_0
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
  att_coll_security_class           = SERIES + 10; // FB3.0 = SERIES + ; ODS12_0
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
  att_package_name                  = SERIES;
  att_package_header_source         = SERIES + 1;
  att_package_body_source           = SERIES + 2;
  att_package_valid_body_flag       = SERIES + 3;
  att_package_security_class        = SERIES + 4;
  att_package_owner_name            = SERIES + 5;
  att_package_description           = SERIES + 6;


implementation

end.
