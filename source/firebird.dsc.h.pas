unit firebird.dsc.h;

(*
 *  PROGRAM:  JRD access method
 *  MODULE:    dsc.h
 *  DESCRIPTION:  Definitions associated with descriptors
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
 * Adriano dos Santos Fernandes
 *)

interface

// In DSC_*_result tables, DTYPE_CANNOT means that the two operands
// cannot participate together in the requested operation.

const DTYPE_CANNOT = 127;

// Text Sub types, distinct from character sets & collations

const dsc_text_type_none     = 0;  // Normal text
const dsc_text_type_fixed    = 1;  // strings can contain null bytes
const dsc_text_type_ascii    = 2;  // string contains only ASCII characters
const dsc_text_type_metadata = 3;  // string represents system metadata


// Exact numeric subtypes: with ODS >= 10, these apply when dtype
// is short, long, or quad.

const dsc_num_type_none    = 0;  // defined as SMALLINT or INTEGER
const dsc_num_type_numeric = 1;  // defined as NUMERIC(n,m)
const dsc_num_type_decimal = 2;  // defined as DECIMAL(n,m)

implementation

end.
