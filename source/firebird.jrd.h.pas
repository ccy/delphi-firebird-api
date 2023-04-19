unit firebird.jrd.h;

interface

uses
  firebird.ibase.h, firebird.types_pub.h;

type
  isc_teb = record
    database: pisc_db_handle;
    tpb_len:  longint;
    tpb:      PISC_UCHAR;
  end;

  pisc_teb = ^isc_teb;

implementation

end.
