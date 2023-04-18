unit firebird.charsets.h;

(*
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
 *)
(** Added Jan 23 2003 Blas Rodriguez Somoza
CS_737, CS_775, CS_858, CS_862, CS_864, CS_866, CS_869
*)
//#ifndef INTL_CHARSETS_H
//#define INTL_CHARSETS_H

interface

//#define DEFAULT_ATTACHMENT_CHARSET	CS_NONE

const CS_NONE         = 0;   (* No Character Set *)
const CS_BINARY       = 1;   (* BINARY BYTES     *)
const CS_ASCII        = 2;   (* ASCII            *)
const CS_UNICODE_FSS  = 3;   (* UNICODE in FSS format *)
const CS_UTF8         = 4;   (* UTF-8 *)

const DEFAULT_ATTACHMENT_CHARSET = CS_NONE;

const CS_SJIS         = 5;   (* SJIS             *)
const CS_EUCJ         = 6;   (* EUC-J            *)

const CS_JIS_0208     = 7;   (* JIS 0208; 1990   *)
const CS_UNICODE_UCS2 = 8;   (* UNICODE v 1.10   *)

const CS_DOS_737      = 9;
const CS_DOS_437      = 10;  (* DOS CP 437       *)
const CS_DOS_850      = 11;  (* DOS CP 850       *)
const CS_DOS_865      = 12;  (* DOS CP 865       *)
const CS_DOS_860      = 13;  (* DOS CP 860       *)
const CS_DOS_863      = 14;  (* DOS CP 863       *)

const CS_DOS_775      = 15;
const CS_DOS_858      = 16;
const CS_DOS_862      = 17;
const CS_DOS_864      = 18;

const CS_NEXT         = 19;  (* NeXTSTEP OS native charset *)

const CS_ISO8859_1    = 21;  (* ISO-8859.1       *)
const CS_ISO8859_2    = 22;  (* ISO-8859.2       *)
const CS_ISO8859_3    = 23;  (* ISO-8859.3       *)
const CS_ISO8859_4    = 34;  (* ISO-8859.4       *)
const CS_ISO8859_5    = 35;  (* ISO-8859.5       *)
const CS_ISO8859_6    = 36;  (* ISO-8859.6       *)
const CS_ISO8859_7    = 37;  (* ISO-8859.7       *)
const CS_ISO8859_8    = 38;  (* ISO-8859.8       *)
const CS_ISO8859_9    = 39;  (* ISO-8859.9       *)
const CS_ISO8859_13   = 40;  (* ISO-8859.13      *)

const CS_KSC5601      = 44;  (* KOREAN STANDARD 5601 *)

const CS_DOS_852      = 45;  (* DOS CP 852   *)
const CS_DOS_857      = 46;  (* DOS CP 857   *)
const CS_DOS_861      = 47;  (* DOS CP 861   *)

const CS_DOS_866      = 48;
const CS_DOS_869      = 49;

const CS_CYRL         = 50;
const CS_WIN1250      = 51;  (* Windows cp 1250  *)
const CS_WIN1251      = 52;  (* Windows cp 1251  *)
const CS_WIN1252      = 53;  (* Windows cp 1252  *)
const CS_WIN1253      = 54;  (* Windows cp 1253  *)
const CS_WIN1254      = 55;  (* Windows cp 1254  *)

const CS_BIG5         = 56;  (* Big Five unicode cs *)
const CS_GB2312       = 57;  (* GB 2312-80 cs *)

const CS_WIN1255      = 58;  (* Windows cp 1255  *)
const CS_WIN1256      = 59;  (* Windows cp 1256  *)
const CS_WIN1257      = 60;  (* Windows cp 1257  *)

const CS_UTF16        = 61;  (* UTF-16 *)
const CS_UTF32        = 62;  (* UTF-32 *)

const CS_KOI8R        = 63;  (* Russian KOI8R *)
const CS_KOI8U        = 64;  (* Ukrainian KOI8U *)

const CS_WIN1258      = 65;  (* Windows cp 1258  *)

const CS_TIS620       = 66;  (* TIS620 *)
const CS_GBK          = 67;  (* GBK *)
const CS_CP943C       = 68;  (* CP943C *)

const CS_GB18030      = 69;  // GB18030

const CS_dynamic      = 127; // Pseudo number for runtime charset

implementation

end.
