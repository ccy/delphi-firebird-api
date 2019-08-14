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

// relation types

const rel_persistent = 0;
const rel_view = 1;
const rel_external = 2;
const rel_virtual = 3;
const rel_global_temp_preserve = 4;
const rel_global_temp_delete = 5;

// backup states

const	backup_state_unknown = -1;
const	backup_state_normal = 0;
const	backup_state_stalled = 1;
const	backup_state_merge = 2;

implementation

end.
