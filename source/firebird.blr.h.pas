unit firebird.blr.h;

interface

(*
 *        PROGRAM:        C preprocessor
 *        MODULE:                blr.h
 *        DESCRIPTION:        BLR constants
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
 * Claudio Valderrama: 2001.6.18: Add blr_current_role.
 * 2002.09.28 Dmitry Yemanov: Reworked internal_info stuff, enhanced
 *                            exception handling in SPs/triggers,
 *                            implemented ROWS_AFFECTED system variable
 * 2002.10.21 Nickolay Samofatov: Added support for explicit pessimistic locks
 * 2002.10.29 Nickolay Samofatov: Added support for savepoints
 * 2003.10.05 Dmitry Yemanov: Added support for explicit cursors in PSQL
 * Adriano dos Santos Fernandes
 *)

//ifndef JRD_BLR_H
//const JRD_BLR_H =;

(*  WARNING: if you add a new BLR representing a data type, and the value
 *           is greater than the numerically greatest value which now
 *           represents a data ctype, you must change the define for
 *           DTYPE_BLR_MAX in jrd/align.h, and add the necessary entries
 *           to all the arrays in that filename.
 *)

const blr_text =             {(Byte)}14;
const blr_text2 =            {(Byte)}15;        (* added in 3.2 JPN *)
const blr_short =            {(Byte)}7;
const blr_long =             {(Byte)}8;
const blr_quad =             {(Byte)}9;
const blr_float =            {(Byte)}10;
const blr_double =           {(Byte)}27;
const blr_d_float =          {(Byte)}11;
const blr_timestamp =        {(Byte)}35;
const blr_varying =          {(Byte)}37;
const blr_varying2 =         {(Byte)}38;        (* added in 3.2 JPN *)
const blr_blob =             {(Word)}261;
const blr_cstring =          {(Byte)}40;
const blr_cstring2 =         {(Byte)}41;        (* added in 3.2 JPN *)
const blr_blob_id =          {(Byte)}45;        (* added from gds.h *)
const blr_sql_date =         {(Byte)}12;
const blr_sql_time =         {(Byte)}13;
const blr_int64 =            {(Byte)}16;
const blr_blob2 =            {(Byte)}17;
const blr_domain_name =      {(Byte)}18;
const blr_domain_name2 =     {(Byte)}19;
const blr_not_nullable =     {(Byte)}20;
const blr_column_name =      {(Byte)}21;
const blr_column_name2 =     {(Byte)}22;
const blr_bool =             {(Byte)}23;
const blr_dec64 =            {(Byte)}24;
const blr_dec128 =		       {(Byte)}25;
const blr_int128 =           {(Byte)}26;
const blr_sql_time_tz =      {(Byte)}28;
const blr_timestamp_tz =     {(Byte)}29;
const blr_ex_time_tz =       {(Byte)}30;
const blr_ex_timestamp_tz =	 {(Byte)}31;

// first sub parameter for blr_domain_name[2]
const blr_domain_type_of =   {(Byte)}0;
const blr_domain_full =      {(Byte)}1;

(* Historical alias for pre V6 applications *)
const blr_date =           blr_timestamp;

const blr_inner =            {(Byte)}0;
const blr_left =             {(Byte)}1;
const blr_right =            {(Byte)}2;
const blr_full =             {(Byte)}3;

const blr_gds_code =         {(Byte)}0;
const blr_sql_code =         {(Byte)}1;
const blr_exception =        {(Byte)}2;
const blr_trigger_code =     {(Byte)}3;
const blr_default_code =     {(Byte)}4;
const blr_raise =            {(Byte)}5;
const blr_exception_msg =    {(Byte)}6;
const blr_exception_params = {(Byte)}7;
const blr_sql_state =        {(Byte)}8;

const blr_version4 =         {(Byte)}4;
const blr_version5 =         {(Byte)}5;
//const blr_version6 =         {(Byte)}6;
const blr_eoc =              {(Byte)}76;
const blr_end =              {(Byte)}255;        (* note: defined as -1 in gds.h *)

const blr_assignment =       {(Byte)}1;
const blr_begin =            {(Byte)}2;
const blr_dcl_variable =     {(Byte)}3;        (* added from gds.h *)
const blr_message =          {(Byte)}4;
const blr_erase =            {(Byte)}5;
const blr_fetch =            {(Byte)}6;
const blr_for =              {(Byte)}7;
const blr_if =               {(Byte)}8;
const blr_loop =             {(Byte)}9;
const blr_modify =           {(Byte)}10;
const blr_handler =          {(Byte)}11;
const blr_receive =          {(Byte)}12;
const blr_select =           {(Byte)}13;
const blr_send =             {(Byte)}14;
const blr_store =            {(Byte)}15;
const blr_label =            {(Byte)}17;
const blr_leave =            {(Byte)}18;
const blr_store2 =           {(Byte)}19;
const blr_post =             {(Byte)}20;
const blr_literal =          {(Byte)}21;
const blr_dbkey =            {(Byte)}22;
const blr_field =            {(Byte)}23;
const blr_fid =              {(Byte)}24;
const blr_parameter =        {(Byte)}25;
const blr_variable =         {(Byte)}26;
const blr_average =          {(Byte)}27;
const blr_count =            {(Byte)}28;
const blr_maximum =          {(Byte)}29;
const blr_minimum =          {(Byte)}30;
const blr_total =            {(Byte)}31;
const blr_receive_batch =    {(Byte)}32;

const blr_add =            {(Byte)}34;
const blr_subtract =       {(Byte)}35;
const blr_multiply =       {(Byte)}36;
const blr_divide =         {(Byte)}37;
const blr_negate =         {(Byte)}38;
const blr_concatenate =    {(Byte)}39;
const blr_substring =      {(Byte)}40;
const blr_parameter2 =     {(Byte)}41;
const blr_from =           {(Byte)}42;
const blr_via =            {(Byte)}43;
//const blr_parameter2_old = {(Byte)}44;        (* Confusion *)
const blr_user_name =      {(Byte)}44;        (* added from gds.h *)
const blr_null =           {(Byte)}45;

const blr_equiv =          {(Byte)}46;
const blr_eql =            {(Byte)}47;
const blr_neq =            {(Byte)}48;
const blr_gtr =            {(Byte)}49;
const blr_geq =            {(Byte)}50;
const blr_lss =            {(Byte)}51;
const blr_leq =            {(Byte)}52;
const blr_containing =     {(Byte)}53;
const blr_matching =       {(Byte)}54;
const blr_starting =       {(Byte)}55;
const blr_between =        {(Byte)}56;
const blr_or =             {(Byte)}57;
const blr_and =            {(Byte)}58;
const blr_not =            {(Byte)}59;
const blr_any =            {(Byte)}60;
const blr_missing =        {(Byte)}61;
const blr_unique =         {(Byte)}62;
const blr_like =           {(Byte)}63;

//#define blr_stream              (unsigned char)65
//#define blr_set_index           (unsigned char)66

const blr_rse =            {(Byte)}67;
const blr_first =          {(Byte)}68;
const blr_project =        {(Byte)}69;
const blr_sort =           {(Byte)}70;
const blr_boolean =        {(Byte)}71;
const blr_ascending =      {(Byte)}72;
const blr_descending =     {(Byte)}73;
const blr_relation =       {(Byte)}74;
const blr_rid =            {(Byte)}75;
const blr_union =          {(Byte)}76;
const blr_map =            {(Byte)}77;
const blr_group_by =       {(Byte)}78;
const blr_aggregate =      {(Byte)}79;
const blr_join_type =      {(Byte)}80;

const blr_agg_count =      {(Byte)}83;
const blr_agg_max =        {(Byte)}84;
const blr_agg_min =        {(Byte)}85;
const blr_agg_total =      {(Byte)}86;
const blr_agg_average =    {(Byte)}87;
const blr_parameter3 =     {(Byte)}88;        (* same as Rdb definition *)
//const blr_run_max =        {(Byte)}89;
//const blr_run_min =        {(Byte)}90;
//const blr_run_total =      {(Byte)}91;
//const blr_run_average =    {(Byte)}92;
const blr_agg_count2 =     {(Byte)}93;
const blr_agg_count_distinct =   {(Byte)}94;
const blr_agg_total_distinct =   {(Byte)}95;
const blr_agg_average_distinct = {(Byte)}96;

const blr_function =       {(Byte)}100;
const blr_gen_id =         {(Byte)}101;
//const blr_prot_mask =      {(Byte)}102;
const blr_upcase =         {(Byte)}103;
//const blr_lock_state =     {(Byte)}104;
const blr_value_if =       {(Byte)}105;
const blr_matching2 =      {(Byte)}106;
const blr_index =          {(Byte)}107;
const blr_ansi_like =      {(Byte)}108;
const blr_scrollable =     {(Byte)}109;
const blr_lateral_rse =    {(Byte)}110;
//#define blr_bookmark                (unsigned char)109
//#define blr_crack                (unsigned char)110
//#define blr_force_crack                (unsigned char)111
//const blr_seek =           {(Byte)}112;
//#define blr_find                (unsigned char)113

(* these indicate directions for blr_seek and blr_find *)

//const blr_continue =       {(Byte)}0;
//const blr_forward =        {(Byte)}1;
//const blr_backward =       {(Byte)}2;
//const blr_bof_forward =    {(Byte)}3;
//const blr_eof_backward =   {(Byte)}4;

//#define blr_lock_relation         (unsigned char)114
//#define blr_lock_record                (unsigned char)115
//#define blr_set_bookmark         (unsigned char)116
//#define blr_get_bookmark         (unsigned char)117

const blr_run_count =      {(Byte)}118;        (* changed from 88 to avoid conflict with blr_parameter3 *)
const blr_rs_stream =      {(Byte)}119;
const blr_exec_proc =      {(Byte)}120;
//#define blr_begin_range         (unsigned char)121
//#define blr_end_range                 (unsigned char)122
//#define blr_delete_range         (unsigned char)123
const blr_procedure =      {(Byte)}124;
const blr_pid =            {(Byte)}125;
const blr_exec_pid =       {(Byte)}126;
const blr_singular =       {(Byte)}127;
const blr_abort =          {(Byte)}128;
const blr_block =          {(Byte)}129;
const blr_error_handler =  {(Byte)}130;

const blr_cast =           {(Byte)}131;

const blr_pid2 =           {(Byte)}132;
const blr_procedure2 =     {(Byte)}133;
//#define blr_release_lock        (unsigned char)132
//#define blr_release_locks        (unsigned char)133
const blr_start_savepoint = {(Byte)}134;
const blr_end_savepoint =   {(Byte)}135;
//#define blr_find_dbkey                (unsigned char)136
//#define blr_range_relation        (unsigned char)137
//#define blr_delete_ranges        (unsigned char)138

const blr_plan =            {(Byte)}139;        (* access plan items *)
const blr_merge =           {(Byte)}140;
const blr_join =            {(Byte)}141;
const blr_sequential =      {(Byte)}142;
const blr_navigational =    {(Byte)}143;
const blr_indices =         {(Byte)}144;
const blr_retrieve =        {(Byte)}145;

const blr_relation2 =       {(Byte)}146;
const blr_rid2 =            {(Byte)}147;
//#define blr_reset_stream        (unsigned char)148
//#define blr_release_bookmark        (unsigned char)149

const blr_set_generator =   {(Byte)}150;

const blr_ansi_any =        {(Byte)}151;   (* required for NULL handling *)
const blr_exists =          {(Byte)}152;   (* required for NULL handling *)
//#define blr_cardinality                (unsigned char)153

const blr_record_version =  {(Byte)}154;        (* get tid of record *)
const blr_stall =           {(Byte)}155;        (* fake server stall *)

//#define blr_seek_no_warn        (unsigned char)156
//#define blr_find_dbkey_version        (unsigned char)157   /* find dbkey with record version */
const blr_ansi_all =        {(Byte)}158;   (* required for NULL handling *)

const blr_extract =         {(Byte)}159;

(* sub parameters for blr_extract *)

const blr_extract_year =             {(Byte)}0;
const blr_extract_month =            {(Byte)}1;
const blr_extract_day =              {(Byte)}2;
const blr_extract_hour =             {(Byte)}3;
const blr_extract_minute =           {(Byte)}4;
const blr_extract_second =           {(Byte)}5;
const blr_extract_weekday =          {(Byte)}6;
const blr_extract_yearday =          {(Byte)}7;
const blr_extract_millisecond =      {(Byte)}8;
const blr_extract_week =             {(Byte)}9;
const blr_extract_timezone_hour	=    {(Byte)}10;
const blr_extract_timezone_minute	=  {(Byte)}11;

const blr_current_date =       {(Byte)}160;
const blr_current_timestamp =  {(Byte)}161;
const blr_current_time =       {(Byte)}162;

(* These codes reuse BLR code space *)

const blr_post_arg =           {(Byte)}163;
const blr_exec_into =          {(Byte)}164;
const blr_user_savepoint =     {(Byte)}165;
const blr_dcl_cursor =         {(Byte)}166;
const blr_cursor_stmt =        {(Byte)}167;
const blr_current_timestamp2 = {(Byte)}168;
const blr_current_time2 =      {(Byte)}169;
const blr_agg_list =           {(Byte)}170;
const blr_agg_list_distinct =  {(Byte)}171;
const blr_modify2 =            {(Byte)}172;

(* FB 1.0 specific BLR *)

const blr_current_role =       {(Byte)}174;
const blr_skip =               {(Byte)}175;

(* FB 1.5 specific BLR *)

const blr_exec_sql =           {(Byte)}176;
const blr_internal_info =      {(Byte)}177;
const blr_nullsfirst =         {(Byte)}178;
const blr_writelock =          {(Byte)}179;
const blr_nullslast =          {(Byte)}180;

(* FB 2.0 specific BLR *)

const blr_lowcase =            {(Byte)}181;
const blr_strlen =             {(Byte)}182;

(* sub parameter for blr_strlen *)
const blr_strlen_bit =         {(Byte)}0;
const blr_strlen_char =        {(Byte)}1;
const blr_strlen_octet =       {(Byte)}2;

const blr_trim =               {(Byte)}183;

(* first sub parameter for blr_trim *)
const blr_trim_both =          {(Byte)}0;
const blr_trim_leading =       {(Byte)}1;
const blr_trim_trailing =      {(Byte)}2;

(* second sub parameter for blr_trim *)
const blr_trim_spaces =        {(Byte)}0;
const blr_trim_characters =    {(Byte)}1;

(* These codes are actions for user-defined savepoints *)

const blr_savepoint_set =            {(Byte)}0;
const blr_savepoint_release =        {(Byte)}1;
const blr_savepoint_undo =           {(Byte)}2;
const blr_savepoint_release_single = {(Byte)}3;

(* These codes are actions for cursors *)

const blr_cursor_open =              {(Byte)}0;
const blr_cursor_close =             {(Byte)}1;
const blr_cursor_fetch =             {(Byte)}2;
const blr_cursor_fetch_scroll	=      {(Byte)}3;

(* scroll options *)

const blr_scroll_forward =     {(Byte)}0;
const blr_scroll_backward =    {(Byte)}1;
const blr_scroll_bof =         {(Byte)}2;
const blr_scroll_eof =         {(Byte)}3;
const blr_scroll_absolute =    {(Byte)}4;
const blr_scroll_relative =    {(Byte)}5;

(* FB 2.1 specific BLR *)

const blr_init_variable =      {(Byte)}184;
const blr_recurse =            {(Byte)}185;
const blr_sys_function =       {(Byte)}186;

// FB 2.5 specific BLR

const blr_auto_trans =         {(Byte)}187;
const blr_similar =            {(Byte)}188;
const blr_exec_stmt =          {(Byte)}189;

// subcodes of blr_exec_stmt
const blr_exec_stmt_inputs =        {(Byte)}1;        // input parameters count
const blr_exec_stmt_outputs =       {(Byte)}2;        // output parameters count
const blr_exec_stmt_sql =           {(Byte)}3;
const blr_exec_stmt_proc_block =    {(Byte)}4;
const blr_exec_stmt_data_src =      {(Byte)}5;
const blr_exec_stmt_user =          {(Byte)}6;
const blr_exec_stmt_pwd =           {(Byte)}7;
const blr_exec_stmt_tran =          {(Byte)}8;        // not implemented yet
const blr_exec_stmt_tran_clone =    {(Byte)}9;        // make transaction parameters equal to current transaction
const blr_exec_stmt_privs =         {(Byte)}10;
const blr_exec_stmt_in_params =     {(Byte)}11;        // not named input parameters
const blr_exec_stmt_in_params2 =    {(Byte)}12;        // named input parameters
const blr_exec_stmt_out_params =    {(Byte)}13;        // output parameters
const blr_exec_stmt_role =          {(Byte)}14;
const blr_exec_stmt_in_excess =     {(Byte)}15;

const blr_stmt_expr =               {(Byte)}190;
const blr_derived_expr =            {(Byte)}191;

// FB 3.0 specific BLR

const blr_procedure3 =         {(Byte)}192;
const blr_exec_proc2 =         {(Byte)}193;
const blr_function2 =          {(Byte)}194;
const blr_window =             {(Byte)}195;
const blr_partition_by =       {(Byte)}196;
const blr_continue_loop =      {(Byte)}197;
const blr_procedure4 =         {(Byte)}198;
const blr_agg_function =       {(Byte)}199;
const blr_substring_similar =  {(Byte)}200;
const blr_bool_as_value =      {(Byte)}201;
const blr_coalesce =           {(Byte)}202;
const blr_decode =             {(Byte)}203;
const blr_exec_subproc =       {(Byte)}204;
const blr_subproc_decl =       {(Byte)}205;
const blr_subproc =            {(Byte)}206;
const blr_subfunc_decl =       {(Byte)}207;
const blr_subfunc =            {(Byte)}208;
const blr_record_version2 =    {(Byte)}209;
const blr_gen_id2 =            {(Byte)}210; // NEXT VALUE FOR generator

// FB 4.0 specific BLR

const blr_window_win =         {(Byte)}211;

// subcodes of blr_window_win
const blr_window_win_partition =          {(Byte)}1;
const blr_window_win_order =              {(Byte)}2;
const blr_window_win_map =                {(Byte)}3;
const blr_window_win_extent_unit =        {(Byte)}4;
const blr_window_win_extent_frame_bound = {(Byte)}5;
const blr_window_win_extent_frame_value = {(Byte)}6;
const blr_window_win_exclusion =          {(Byte)}7;

const blr_default =        {(Byte)}212;
const blr_store3 =         {(Byte)}213;

// subcodes of blr_store3
const blr_store_override_user =   {(Byte)}1;
const blr_store_override_system = {(Byte)}2;

const blr_local_timestamp =  {(Byte)}214;
const blr_local_time =       {(Byte)}215;

const blr_at =               {(Byte)}216;

// subcodes of blr_at
const blr_at_local =       {(Byte)}0;
const blr_at_zone =        {(Byte)}1;

const blr_marks =          {(Byte)}217;		// mark some blr code with specific flags

//endif // JRD_BLR_H

implementation


end.
