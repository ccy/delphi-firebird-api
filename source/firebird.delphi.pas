unit firebird.delphi;

interface

uses
  System.SysUtils, Data.SqlTimSt,
  firebird.dsc.h, firebird.dsc_pub.h, firebird.types_pub.h;

type
  TTimeZoneOffset = record
    TimeZoneHour: SmallInt;
    TimeZoneMinute: SmallInt;
    class operator Implicit(Value: SmallInt): TTimeZoneOffset;
    class function Default: TTimeZoneOffset; static;
  end;

  TGetTimeZoneOffSet = TFunc<Word, TTimeZoneOffset>;
  TAddTimeZone = reference to procedure (const aID: Word; const aTimeZoneOffset: TTimeZoneOffset);

  ISC_DATE_Helper = record helper for ISC_DATE
  private
    class procedure decode_date(nday: Integer; out year, month, day: Word); static;
        inline;
    class function encode_date(year, month, day: Word): ISC_DATE; static; inline;
  public
    class function Create(Value: TTimeStamp): ISC_DATE; static; inline;
    function ToTimeStamp: TTimeStamp;
  end;

  ISC_TIME_Helper = record helper for ISC_TIME
  private
    class procedure decode_time(ntime: Integer; out hours, minutes, seconds, msec:
        Word); static;
    class function encode_time(hours, minutes, seconds, msec: Word): ISC_TIME;
        static;
  public
    class function Create(Value: TTimeStamp): ISC_TIME; static; inline;
    function ToTimeStamp: TTimeStamp;
  end;

  ISC_TIMESTAMP_Helper = record helper for ISC_TIMESTAMP
  public
    class operator Implicit(Value: ISC_TIMESTAMP): TTimeStamp;
    class operator Implicit(Value: ISC_TIMESTAMP): TSQLTimeStamp;
    class operator Implicit(Value: TSQLTimeStamp): ISC_TIMESTAMP;
    class operator Implicit(Value: TSQLTimeStampOffset): ISC_TIMESTAMP;
    class operator Implicit(Value: TTimeStamp): ISC_TIMESTAMP;
  end;

  ISC_TIMESTAMP_TZ_Helper = record helper for ISC_TIMESTAMP_TZ
  public
    class operator Implicit(Value: TSQLTimeStamp): ISC_TIMESTAMP_TZ;
    class operator Implicit(Value: TTimeStamp): ISC_TIMESTAMP_TZ;
    class operator Implicit(Value: TSQLTimeStampOffset): ISC_TIMESTAMP_TZ;
  end;

  ISC_TIMESTAMP_TZ_IANA = record
  strict private
    GetTimeZoneOffset: TGetTimeZoneOffSet;
    FValue: ISC_TIMESTAMP_TZ;
    class function DefaultTimeZoneOffset(aFBTimeZoneID: Word): TTimeZoneOffset; static;
  public
    class operator Initialize(out Dest: ISC_TIMESTAMP_TZ_IANA);
    class operator Implicit(Value: ISC_TIMESTAMP_TZ_IANA): TSQLTimeStampOffset;
    class operator Implicit(Value: ISC_TIMESTAMP_TZ): ISC_TIMESTAMP_TZ_IANA;
    procedure Setup(aGetTimeZoneOffset: TGetTimeZoneOffSet);
  end;

implementation

uses
  System.DateUtils, System.TimeSpan;

class function ISC_DATE_Helper.Create(Value: TTimeStamp): ISC_DATE;
begin
  var y, m, d: Word;
  DecodeDate(TimeStampToDateTime(Value), y, m, d);
  Result := encode_date(y, m, d);
end;

class procedure ISC_DATE_Helper.decode_date(nday: Integer; out year, month,
    day: Word);
begin
//  var tm_wday := (nday + 3) mod 7;
//  if tm_wday < 0 then
//    Inc(tm_wday, 7);

  Inc(nday, 2400001 - 1721119);

  var century := (4 * nday - 1) div 146097;

  nday := 4 * nday - 1 - 146097 * century;
  day := nday div 4;

  nday := (4 * day + 3) div 1461;
  day := 4 * day + 3 - 1461 * nday;
  day := (day + 4) div 4;

  month := (5 * day - 3) div 153;
  day := 5 * day - 3 - 153 * month;
  day := (day + 5) div 5;

  year := 100 * century + nday;

  if (month < 10) then
    Inc(month, 3)
  else begin
    Dec(month, 9);
    Inc(year, 1);
  end;
end;

class function ISC_DATE_Helper.encode_date(year, month, day: Word): ISC_DATE;
begin
//	const int day = times->tm_mday;
//	int month = times->tm_mon + 1;
//	int year = times->tm_year + 1900;

  if (month > 2) then
    Dec(month, 3)
  else begin
    Inc(month, 9);
    Dec(year);
  end;

  var c := year div 100;
  var ya := year - 100 * c;

  Result := (146097 * c) div 4 +
            (1461 * ya) div 4 +
            (153 * month + 2) div 5 + day + 1721119 - 2400001;
end;

function ISC_DATE_Helper.ToTimeStamp: TTimeStamp;
begin
  var y, m, d: Word;
  decode_date(Self, y, m, d);
  Result := DateTimeToTimeStamp(EncodeDate(y, m, d));
end;

class procedure ISC_TIME_Helper.decode_time(ntime: Integer; out hours, minutes,
    seconds, msec: Word);
begin
  hours := ntime div (3600 * ISC_TIME_SECONDS_PRECISION);
  ntime := ntime mod (3600 * ISC_TIME_SECONDS_PRECISION);
  minutes := ntime div (60 * ISC_TIME_SECONDS_PRECISION);
  ntime := ntime mod (60 * ISC_TIME_SECONDS_PRECISION);
  seconds := ntime div ISC_TIME_SECONDS_PRECISION;
  msec := (ntime mod ISC_TIME_SECONDS_PRECISION) div 10;
end;

class function ISC_TIME_Helper.encode_time(hours, minutes, seconds, msec:
    Word): ISC_TIME;
begin
  Result := ((hours * 60 + minutes) * 60 + seconds) * ISC_TIME_SECONDS_PRECISION + msec * 10;
end;

class function ISC_TIME_HELPER.Create(Value: TTimeStamp): ISC_TIME;
begin
  var hh, mm, ss, msec: Word;
  DecodeTime(TimeStampToDateTime(Value), hh, mm, ss, msec);
  Result := encode_time(hh, mm, ss, msec);
end;

function ISC_TIME_HELPER.ToTimeStamp: TTimeStamp;
begin
  var hh, mm, ss, ff: Word;
  decode_time(Self, hh, mm, ss, ff);
  Result := DateTimeToTimeStamp(EncodeTime(hh, mm, ss, ff));
end;

class operator ISC_TIMESTAMP_Helper.Implicit(Value: ISC_TIMESTAMP): TTimeStamp;
begin
  var y, m, d: Word;
  var hh, mm, ss, ff: Word;
  ISC_DATE.decode_date(Value.timestamp_date, y, m, d);
  ISC_TIME.decode_time(Value.timestamp_time, hh, mm, ss, ff);
  Result := DateTimeToTimeStamp(EncodeDateTime(y, m, d, hh, mm, ss, ff));
end;

class operator ISC_TIMESTAMP_Helper.Implicit(
  Value: ISC_TIMESTAMP): TSQLTimeStamp;
begin
  var f: Word;
  ISC_DATE.decode_date(Value.timestamp_date, Result.Year, Result.Month, Result.Day);
  ISC_TIME.decode_time(Value.timestamp_time, Result.Hour, Result.Minute, Result.Second, f);
  Result.Fractions := f;
end;

class operator ISC_TIMESTAMP_Helper.Implicit(
  Value: TSQLTimeStamp): ISC_TIMESTAMP;
begin
  Result.timestamp_date := ISC_DATE.encode_date(Value.Year, Value.Month, Value.Day);
  Result.timestamp_time := ISC_TIME.encode_time(Value.Hour, Value.Minute, Value.Second, Value.Fractions);
end;

class operator ISC_TIMESTAMP_Helper.Implicit(Value: TTimeStamp): ISC_TIMESTAMP;
begin
  var y, m, d: Word;
  var hh, mm, ss, msec: Word;
  DecodeDateTime(TimeStampToDateTime(Value), y, m, d, hh, mm, ss, msec);
  Result.timestamp_date := ISC_DATE.encode_date(y, m, d);
  Result.timestamp_time := ISC_TIME.encode_time(hh, mm, ss, msec);
end;

class operator ISC_TIMESTAMP_Helper.Implicit(
  Value: TSQLTimeStampOffset): ISC_TIMESTAMP;
begin
  Result.timestamp_date := ISC_DATE.encode_date(Value.Year, Value.Month, Value.Day);
  Result.timestamp_time := ISC_TIME.encode_time(Value.Hour, Value.Minute, Value.Second, Value.Fractions);
end;

class operator ISC_TIMESTAMP_TZ_Helper.Implicit(
  Value: TSQLTimeStamp): ISC_TIMESTAMP_TZ;
begin
  Result.utc_timestamp := Value;
  Result.time_zone := Trunc(TTimeZone.Local.UtcOffset.TotalMinutes);
end;

class operator ISC_TIMESTAMP_TZ_Helper.Implicit(Value: TSQLTimeStampOffset):
    ISC_TIMESTAMP_TZ;
begin
  Result.utc_timestamp := Value;
  Result.time_zone := Value.TimeZoneHour * MinsPerHour + Value.TimeZoneMinute;
end;

class operator ISC_TIMESTAMP_TZ_Helper.Implicit(
  Value: TTimeStamp): ISC_TIMESTAMP_TZ;
begin
  Result.utc_timestamp := Value;
  Result.time_zone := Trunc(TTimeZone.Local.UtcOffset.TotalMinutes);
end;

class function TTimeZoneOffset.Default: TTimeZoneOffset;
begin
  var m := Trunc(TTimeZone.Local.UtcOffset.TotalMinutes);
  Result.TimeZoneHour := m div MinsPerHour;
  Result.TimeZoneMinute := m mod MinsPerHour;
end;

class operator TTimeZoneOffset.Implicit(
  Value: SmallInt): TTimeZoneOffset;
begin
  Result.TimeZoneHour := Value div MinsPerHour;
  Result.TimeZoneMinute := Value mod MinsPerHour;
end;

class operator ISC_TIMESTAMP_TZ_IANA.Implicit(
  Value: ISC_TIMESTAMP_TZ_IANA): TSQLTimeStampOffset;
begin
  var f: Word;
  ISC_DATE.decode_date(Value.FValue.utc_timestamp.timestamp_date, Result.Year, Result.Month, Result.Day);
  ISC_TIME.decode_time(Value.FValue.utc_timestamp.timestamp_time, Result.Hour, Result.Minute, Result.Second, f);
  Result.Fractions := f;

  const ONE_DAY = 24 * 60 - 1;
  if Value.FValue.time_zone <= ONE_DAY * 2 then begin
    Result.TimeZoneHour := Value.FValue.time_zone div 60;
    Result.TimeZoneMinute := Value.FValue.time_zone mod 60;
  end else begin
    var z := Value.GetTimeZoneOffset(Value.FValue.time_zone);
    Result.TimeZoneHour := z.TimeZoneHour;
    Result.TimeZoneMinute := z.TimeZoneMinute;
  end;
end;

class function ISC_TIMESTAMP_TZ_IANA.DefaultTimeZoneOffset(
  aFBTimeZoneID: Word): TTimeZoneOffset;
begin
  Result := TTimeZoneOffset.Default;
end;

class operator ISC_TIMESTAMP_TZ_IANA.Implicit(
  Value: ISC_TIMESTAMP_TZ): ISC_TIMESTAMP_TZ_IANA;
begin
  Result.FValue := Value;
end;

class operator ISC_TIMESTAMP_TZ_IANA.Initialize(
  out Dest: ISC_TIMESTAMP_TZ_IANA);
begin
  Dest.GetTimeZoneOffset := DefaultTimeZoneOffset;
end;

procedure ISC_TIMESTAMP_TZ_IANA.Setup(aGetTimeZoneOffset: TGetTimeZoneOffSet);
begin
  if Assigned(aGetTimeZoneOffset) then
    GetTimeZoneOffset := aGetTimeZoneOffset;
end;

end.
