// -------------------------------------------------------------------------- //
// Copyright (c) 2019-2022, Jairus Martin.                                    //
// Distributed under the terms of the MIT License.                            //
// The full license is in the file LICENSE, distributed with this software.   //
// -------------------------------------------------------------------------- //

// Some of this is ported from cpython's datetime module
const std = @import("std");
const time = std.time;
const math = std.math;
const ascii = std.ascii;

pub const tmz = @import("timezones");

const AllocDate = std.mem.Allocator;
const Order = std.math.Order;
const assert = std.debug.assert;




pub const MIN_YEAR: u16 = 1;
pub const MAX_YEAR: u16 = 9999;
pub const MAX_ORDINAL: u32 = 3652059;

const DAYS_IN_MONTH = [12]u8{ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
const DAYS_BEFORE_MONTH = [12]u16{ 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 };


const allocDateTime = std.heap.page_allocator;

//----------------------------------
// outils
//----------------------------------
fn isLeapYear(year: usize) bool {
    return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0);
}

fn dayInYear(year : u32) i64 {
    if (isLeapYear(year)) return 366 else return 365 ;
}

fn daysInMonth(year: u32, month: u32) u32 {
    const days_per_month = [_]u8 { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
    if (month == 2 and isLeapYear(year)) {
        return 29;
    }
    return days_per_month[month - 1];
}

// Number of days before Jan 1st of year
fn daysBeforeYear(year: u32) u32 {
    const y: u32 = year - 1;
    return y * 365 + @divFloor(y, 4) - @divFloor(y, 100) + @divFloor(y, 400);
}

// Days before 1 Jan 1970
const EPOCH = daysBeforeYear(1970) + 1;

// Number of days in the year preceding the first day of the month
fn daysBeforeMonth(year: u32, month: u32) u32 {
    assert(month >= 1 and month <= 12);
    var d = DAYS_BEFORE_MONTH[month - 1];
    if (month > 2 and isLeapYear(year)) d += 1;
    return d;
}
// Calculate the number of days of the first monday for week 1 iso calendar
// for the given year since 01-Jan-0001
fn daysBeforeFirstMonday(year: u16) u32 {
    // From cpython/datetime.py _isoweek1monday
    const THURSDAY = 3;
    const first_day = ymd2ord(year, 1, 1);
    const first_weekday = (first_day + 6) % 7;
    var week1_monday = first_day - first_weekday;
    if (first_weekday > THURSDAY) {
        week1_monday += 7;
    }
    return week1_monday;
}
// Return number of days since 01-Jan-0001
fn ymd2ord(year: u16, month: u8, day: u8) u32 {
    assert(month >= 1 and month <= 12);
    assert(day >= 1 and day <= daysInMonth(year, month));
    return daysBeforeYear(year) + daysBeforeMonth(year, month) + day;
}




//------------------------------------
// Datetime
// -----------------------------------
pub const DTime = struct {
    year: u16,
    month: u4,
    day: u8,
    hour: u8 = 0,// 0>23
    minute: u8 = 0,// 0>59
    second: u8 = 0,// 0>59
    nanosecond: u64 = 0,// 0> 999999999
    tmz : u16 = 0,

    //Change of field attribute
    pub fn hardTime(buf :[]const u8) DTime{

        var tm = DTime {
            .year  = 0,
            .month = 0,
            .day   = 0,
            .hour  = 0,
            .minute = 0,
            .second = 0,
            .nanosecond = 0,
            .tmz   = 0
        };
        for(buf[0..26], 0..26) |n,x| {
            var d : u8 = 0;
            switch(n) {
                48 => d=0, 49 => d=1, 50=> d=2, 51 => d=3, 52=> d=4,
                53 => d=5, 54 => d=6, 55 => d=7, 56 => d=8, 57 => d =9, 
                else => {},
             }
            switch(x){
                0 => { if ( d > 0 ) tm.year   = d * @as(u16,1000); },
                1 => { if ( d > 0 ) tm.year  += d * @as(u16,100); } ,
                2 => { if ( d > 0 ) tm.year  += d * 10 ; },
                3 => tm.year += d,
            
                4 => { if ( d > 0 ) tm.month += @intCast( d * 10 ); },
                5 => tm.month += @intCast(d),
            
                6 => { if ( d > 0 ) tm.day   +=  d * 10 ; },
                7 => tm.day += d,
            
                8 => { if ( d > 0 ) tm.hour  +=  d * 10 ; },
                9 => tm.hour += d,
            
                10 => { if ( d > 0 ) tm.minute +=  d * 10 ; },
                11 => tm.minute += d,
            
                12 => { if ( d > 0 ) tm.second +=  d * 10 ; },
                13 => tm.second += d,
            
                15 => { if ( d > 0 ) tm.nanosecond += d * @as(u64,10000000); } ,
                16 => { if ( d > 0 ) tm.nanosecond += d * @as(u64,1000000); } ,
                17 => { if ( d > 0 ) tm.nanosecond += d * @as(u64,100000); } ,
                18 => { if ( d > 0 ) tm.nanosecond += d * @as(u64,10000); } ,
                19 => { if ( d > 0 ) tm.nanosecond += d * @as(u64,1000); } ,
                20 => { if ( d > 0 ) tm.nanosecond += d * @as(u64,100); } ,
                21 => { if ( d > 0 ) tm.nanosecond += d * 10 ; },
                22 => tm.nanosecond += d,

                23 => { if ( d > 0 ) tm.tmz  = d * @as(u16, 100); } ,
                24 => { if ( d > 0 ) tm.tmz += d * 10 ; },
                25 => tm.tmz += d,
                else => {}, 
            }
        }    
        return tm;
    }

    // Date initialization in UTC ONLY time-stamp format.
    // use is made of a chronolog
    pub fn nowUTC() !DTime {
        const TS: u128 = @abs(time.nanoTimestamp());
        var th: u64 = @intCast(@mod(TS, time.ns_per_day));
          
        // th is now only the time part of the day
        const hr: u64 = @intCast(@divFloor(th, time.ns_per_hour));
        th -= hr * time.ns_per_hour;
        const min: u64 = @intCast(@divFloor(th, time.ns_per_min));
        th -= min * time.ns_per_min;
        const sec: u64 = @intCast(@divFloor(th, time.ns_per_s));
        const ns: u64 = th - sec * time.ns_per_s;

        var days_since_epoch: u64 = @intCast(@divFloor(TS , time.ns_per_day));
   

        // Back to year/month/day from 1970
        var year: u32 = 1970;
        while (days_since_epoch >= dayInYear(year)) {
            days_since_epoch -= if (isLeapYear(year)) 366 else 365;
            year += 1;
        }
        var month: u32 = 1;
        while (days_since_epoch >= daysInMonth(year, month)) {
            days_since_epoch -= daysInMonth(year, month);
            month += 1;
        }

        const day: u64 = days_since_epoch + 1;

        
        const chronoHardFMT :[]const u8 = "{:0>4}{:0>2}{:0>2}{:0>2}{:0>2}{:0>2}{:0>9}{:0>3}";
        const  r : []const u8 = try  std.fmt.allocPrint(allocDateTime, chronoHardFMT,
            .{ year, month, day , hr, min,sec,ns, 0 }) ;

        const tm = hardTime(r) ;
        defer allocDateTime.free(r);
        return tm;
    }

    //  Date time reverse  timestamp
    pub fn Timestamp(self: DTime) u64 {

        // Only for a simplified calculation and without leap years here
        const days_per_month = [_]u8 { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
        var total_days: u64 = 0;

        // Add days from previous years
        for (1970..self.year) |y| {
        total_days += if (isLeapYear(y)) 366 else 365;
        }

        // Add days of the months of the current year
        for (0..(self.month - 1)) |m| {
            total_days += days_per_month[m];
            if (m == 1 and isLeapYear(self.year)) {
            total_days += 1; // Add a day for February if leap year
            }
        }

        // Add days of current month
        total_days += self.day - 1;

        const seconds_since_epoch = total_days * @as(u32,86400) + self.hour * @as(u32,3600)
                                    + self.minute * @as(u32,60) + self.second;
        return seconds_since_epoch * std.time.ns_per_s + self.nanosecond;
    }





    // Timestamp date into time-zone
    pub fn nowTime(mz :tmz.Timezone) !DTime {
        //timezoneem  Europe.Paris = 60 minutes in nanoseconds
        const TS : u128 = @intCast(time.nanoTimestamp() + (mz.offset * @as(i64,time.ns_per_min))) ;

        var th: u64 = @intCast(@mod(TS, time.ns_per_day));
          
        // th is now only the time part of the day
        const hr: u64 = @intCast(@divFloor(th, time.ns_per_hour));
        th -= hr * time.ns_per_hour;
        const min: u64 = @intCast(@divFloor(th, time.ns_per_min));
        th -= min * time.ns_per_min;
        const sec: u64 = @intCast(@divFloor(th, time.ns_per_s));
         const ns: u64 = th - sec * time.ns_per_s;



        var days_since_epoch: u64 = @intCast(@divFloor(TS , time.ns_per_day));
          // Back to year/month/day from 1970
        var year: u32 = 1970;
        while (days_since_epoch >= dayInYear(year)) {
            days_since_epoch -= if (isLeapYear(year)) 366 else 365;
            year += 1;
        }
        var month: u32 = 1;
        while (days_since_epoch >= daysInMonth(year, month)) {
            days_since_epoch -= daysInMonth(year, month);
            month += 1;
        }

        const day: u64 = days_since_epoch + 1;

        
        const chronoHardFMT :[]const u8 = "{:0>4}{:0>2}{:0>2}{:0>2}{:0>2}{:0>2}{:0>9}{:0>3}";
        const  r : []const u8 = try  std.fmt.allocPrint(allocDateTime, chronoHardFMT,
            .{ year, month, day , hr, min,sec,ns, mz.offset }) ;

        
        const tm = hardTime(r) ;
        defer allocDateTime.free(r);
        return tm;
    }


    // Date-time formatting

    const  chronoTimeFMT :[]const u8 = "{:0>4}-{:0>2}-{:0>2}T:{:0>2}:{:0>2}:{:0>2}N:{:0>9}Z:{:0>3}";

    pub fn stringTime(self: DTime, allocat: AllocDate) ![]const u8 {
        return try std.fmt.allocPrint(allocat, chronoTimeFMT,
            .{ self.year, self.month, self.day, self.hour, self.minute,self.second,self.nanosecond,self.tmz });
    }

    const chronoNumFMT = "{:0>4}{:0>2}{:0>2}{:0>2}{:0>2}{:0>2}{:0>9}{:0>3}";

    pub fn numTime(self: DTime, allocat: AllocDate) !u128 {
        const  r : []const u8 = try std.fmt.allocPrint(allocat, chronoNumFMT,
            .{ self.year, self.month, self.day, self.hour, self.minute,self.second,self.nanosecond,self.tmz });
        const i :u128 = try std.fmt.parseInt(u128,r,10);
        return i;
    }

};

//-------------------------------------------------------------
// Date
//-------------------------------------------------------------

pub const ISOCalendar = struct {
    year: u16,
    week: u6, // Week of year 1-53
    weekday: u3, // Day of week 1-7
};

pub const Date = struct {
    year: u16,
    month: u4 = 1, // Month of year
    day: u8 = 1, // Day of month


    // Number of days in each month not accounting for leap year
    pub const Weekday = enum(u3) {
         Monday = 1,
         Tuesday,
         Wednesday,
         Thursday,
         Friday,
         Saturday,
         Sunday,
    };

    pub const Month = enum(u4) {
        January = 1,
        February,
        March,
        April,
        May,
        June,
        July,
        August,
        September,
        October,
        November,
        December,
    };


    // Create and validate the date
    pub fn create(year: u32, month: u32, day: u32) !Date {
        if (year < MIN_YEAR or year > MAX_YEAR) return error.InvalidDate;
        if (month < 1 or month > 12) return error.InvalidDate;
        if (day < 1 or day > daysInMonth(year, month)) return error.InvalidDate;
        // Since we just validated the ranges we can now savely cast
        return Date{
            .year = @intCast(year),
            .month = @intCast(month),
            .day = @intCast(day),
        };
    }
    
    // Return a copy of the date
    pub fn copy(self: Date) !Date {
        return Date.create(self.year, self.month, self.day);
    }

    // Create a Date from the number of days since 01-Jan-0001
    fn fromOrdinal(ordinal: u32) Date {
        // n is a 1-based index, starting at 1-Jan-1.  The pattern of leap years
        // repeats exactly every 400 years.  The basic strategy is to find the
        // closest 400-year boundary at or before n, then work with the offset
        // from that boundary to n.  Life is much clearer if we subtract 1 from
        // n first -- then the values of n at 400-year boundaries are exactly
        // those divisible by DI400Y:
        //
        //     D  M   Y            n              n-1
        //     -- --- ----        ----------     ----------------
        //     31 Dec -400        -DI400Y        -DI400Y -1
        //      1 Jan -399        -DI400Y +1     -DI400Y       400-year boundary
        //     ...
        //     30 Dec  000        -1             -2
        //     31 Dec  000         0             -1
        //      1 Jan  001         1              0            400-year boundary
        //      2 Jan  001         2              1
        //      3 Jan  001         3              2
        //     ...
        //     31 Dec  400         DI400Y        DI400Y -1
        //      1 Jan  401         DI400Y +1     DI400Y        400-year boundary
        assert(ordinal >= 1 and ordinal <= MAX_ORDINAL);

        var n = ordinal - 1;
        const DI400Y = comptime daysBeforeYear(401); // Num of days in 400 years
        const DI100Y = comptime daysBeforeYear(101); // Num of days in 100 years
        const DI4Y = comptime daysBeforeYear(5); // Num of days in 4   years
        const n400 = @divFloor(n, DI400Y);
        n = @mod(n, DI400Y);
        var year = n400 * 400 + 1; //  ..., -399, 1, 401, ...

        // Now n is the (non-negative) offset, in days, from January 1 of year, to
        // the desired date.  Now compute how many 100-year cycles precede n.
        // Note that it's possible for n100 to equal 4!  In that case 4 full
        // 100-year cycles precede the desired day, which implies the desired
        // day is December 31 at the end of a 400-year cycle.
        const n100 = @divFloor(n, DI100Y);
        n = @mod(n, DI100Y);

        // Now compute how many 4-year cycles precede it.
        const n4 = @divFloor(n, DI4Y);
        n = @mod(n, DI4Y);

        // And now how many single years.  Again n1 can be 4, and again meaning
        // that the desired day is December 31 at the end of the 4-year cycle.
        const n1 = @divFloor(n, 365);
        n = @mod(n, 365);

        year += n100 * 100 + n4 * 4 + n1;

        if (n1 == 4 or n100 == 4) {
            assert(n == 0);
            return Date.create(year - 1, 12, 31) catch unreachable;
        }

        // Now the year is correct, and n is the offset from January 1.  We find
        // the month via an estimate that's either exact or one too large.
        const leapyear = (n1 == 3) and (n4 != 24 or n100 == 3);
        assert(leapyear == isLeapYear(year));
        var month = (n + 50) >> 5;
        if (month == 0) month = 12; // Loop around
        var preceding = daysBeforeMonth(year, month);

        if (preceding > n) { // estimate is too large
            month -= 1;
            if (month == 0) month = 12; // Loop around
            preceding -= daysInMonth(year, month);
        }
        n -= preceding;
        // assert(n > 0 and n < daysInMonth(year, month));

        // Now the year and month are correct, and n is the offset from the
        // start of that month:  we're done!
        return Date.create(year, month, n + 1) catch unreachable;
    }

    // Return proleptic Gregorian ordinal for the year, month and day.
    // January 1 of year 1 is day 1.  Only the year, month and day values
    // contribute to the result.
    fn toOrdinal(self: Date) u32 {
        return ymd2ord(self.year, self.month, self.day);
    }


    //Change of field attribute
    fn hardDate(buf :[]const u8) Date{

        var dt = Date {
            .year  = 0,
            .month = 0,
            .day   = 0,
        };
        for(buf[0..8], 0..8) |n,x| {
            var d : u8 = 0;
            switch(n) {
                48 => d=0, 49 => d=1, 50=> d=2, 51 => d=3, 52=> d=4,
                53 => d=5, 54 => d=6, 55 => d=7, 56 => d=8, 57 => d =9, 
                else => {},
             }
            switch(x){
                0 => { if ( d > 0 ) dt.year   = d * @as(u16,1000); },
                1 => { if ( d > 0 ) dt.year  += d * @as(u16,100); } ,
                2 => { if ( d > 0 ) dt.year  += d * 10 ; },
                3 => dt.year += d,
            
                4 => { if ( d > 0 ) dt.month += @intCast( d * 10 ); },
                5 => dt.month += @intCast(d),
            
                6 => { if ( d > 0 ) dt.day   +=  d * 10 ; },
                7 => dt.day += d,
            
            
                else => {}, 
            }
        }    
        return dt;
    }

    // Returns today's date into time-zone
    pub fn nowDate(mz : tmz.Timezone) !Date {

        // Ajouter ex; from paris 60  minutes en nanosecond
        const TS : u128 = @intCast(time.nanoTimestamp() + (mz.offset * @as(i64,time.ns_per_min))); 
        var days_since_epoch: u64 = @intCast(@divFloor(TS , time.ns_per_day));


        // Revenir à l'année/mois/jour en partant de 1970
        var year: u32 = 1970;
        while (days_since_epoch >= dayInYear(year)) {
            days_since_epoch -= if (isLeapYear(year)) 366 else 365;
            year += 1;
        }
        var month: u32 = 1;
        while (days_since_epoch >= daysInMonth(year, month)) {
            days_since_epoch -= daysInMonth(year, month);
            month += 1;
        }

        const day: u64 = days_since_epoch + 1;

        
        const chronoHardFMT :[]const u8 = "{:0>4}{:0>2}{:0>2}";
        const  r : []const u8 = try  std.fmt.allocPrint(allocDateTime, chronoHardFMT,
            .{ year, month, day }) ;
        defer allocDateTime.free(r);
        return hardDate(r);
 
    }


    // Convert to an ISOCalendar date containing the year, week number, and
    // weekday. First week is 1. Monday is 1, Sunday is 7.
    pub fn isoCalendar(self: Date) ISOCalendar {
        // Ported from python's isocalendar.
        var y = self.year;
        var first_monday = daysBeforeFirstMonday(y);
        const today = ymd2ord(self.year, self.month, self.day);
        if (today < first_monday) {
            y -= 1;
            first_monday = daysBeforeFirstMonday(y);
        }
        const days_between = today - first_monday;
        var week = @divFloor(days_between, 7);
        const day = @mod(days_between, 7);
        if (week >= 52 and today >= daysBeforeFirstMonday(y + 1)) {
            y += 1;
            week = 0;
        }
        assert(week >= 0 and week < 53);
        assert(day >= 0 and day < 8);
        return ISOCalendar{ .year = y, .week = @intCast(week + 1), .weekday = @intCast(day + 1) };
    }

    // ------------------------------------------------------------------------
    // Comparisons
    // ------------------------------------------------------------------------
    pub fn eql(self: Date, other: Date) bool {
        return self.cmp(other) == .eq;
    }

    pub fn cmp(self: Date, other: Date) Order {
        if (self.year > other.year) return .gt;
        if (self.year < other.year) return .lt;
        if (self.month > other.month) return .gt;
        if (self.month < other.month) return .lt;
        if (self.day > other.day) return .gt;
        if (self.day < other.day) return .lt;
        return .eq;
    }

    pub fn gt(self: Date, other: Date) bool {
        return self.cmp(other) == .gt;
    }

    pub fn gte(self: Date, other: Date) bool {
        const r = self.cmp(other);
        return r == .eq or r == .gt;
    }

    pub fn lt(self: Date, other: Date) bool {
        return self.cmp(other) == .lt;
    }

    pub fn lte(self: Date, other: Date) bool {
        const r = self.cmp(other);
        return r == .eq or r == .lt;
    }

    // ------------------------------------------------------------------------
    // Parsing
    // ------------------------------------------------------------------------
    // Parse date in format YYYY-MM-DD. Numbers must be zero padded.
    pub fn parseIso(ymd: []const u8) !Date {
        const value = std.mem.trim(u8, ymd, " ");
        if (value.len != 10) return error.InvalidFormat;
        const year = std.fmt.parseInt(u16, value[0..4], 10) catch return error.InvalidFormat;
        const month = std.fmt.parseInt(u8, value[5..7], 10) catch return error.InvalidFormat;
        const day = std.fmt.parseInt(u8, value[8..10], 10) catch return error.InvalidFormat;
        return Date.create(year, month, day);
    }
    pub fn parseFR(dmy: []const u8) !Date {
        const value = std.mem.trim(u8, dmy, " ");
        if (value.len != 10) return error.InvalidFormat;
        const day = std.fmt.parseInt(u8, value[0..2], 10) catch return error.InvalidFormat;
        const month = std.fmt.parseInt(u8, value[3..5], 10) catch return error.InvalidFormat;
        const year = std.fmt.parseInt(u16, value[6..10], 10) catch return error.InvalidFormat;
        return Date.create(year, month, day);
    }
    pub fn parseUS(mdy: []const u8) !Date {
        const value = std.mem.trim(u8, mdy, " ");
        if (value.len != 10) return error.InvalidFormat;
        const month = std.fmt.parseInt(u8, value[0..2], 10) catch return error.InvalidFormat;
        const day = std.fmt.parseInt(u8, value[3..5], 10) catch return error.InvalidFormat;
        const year = std.fmt.parseInt(u16, value[6..10], 10) catch return error.InvalidFormat;
        return Date.create(year, month, day);
    }
    // TODO: Parsing

    // ------------------------------------------------------------------------
    // Formatting
    // ------------------------------------------------------------------------

    // Return date in ISO format YYYY-MM-DD
    const ISO_DATE_FMT = "{:0>4}-{:0>2}-{:0>2}";
    pub fn stringIso(self: Date, allocator: AllocDate) ![]const u8 {
        return std.fmt.allocPrint(allocator, ISO_DATE_FMT, .{ self.year, self.month, self.day });
    }

   // Return date in FR format DD/MM/YYYY
    const FR_DATE_FMT = "{:0>2}/{:0>2}/{:0>4}";
    pub fn stringFR(self: Date, allocator: AllocDate) ![]const u8 {
        return std.fmt.allocPrint(allocator, FR_DATE_FMT, .{ self.day, self.month, self.year }) ;
    }

   // Return date in FR format MM/DD/YYYY
    const US_DATE_FMT = "{:0>2}/{:0>2}/{:0>4}";
    pub fn stringUS(self: Date, allocator: AllocDate) ![]const u8 {
        return std.fmt.allocPrint(allocator, US_DATE_FMT, .{ self.month, self.day, self.year });
    }

    // ------------------------------------------------------------------------
    // Properties
    // ------------------------------------------------------------------------

    // Return day of year starting with 1
    pub fn dayOfYear(self: Date) u16 {
        const d = self.toOrdinal() - daysBeforeYear(self.year);
        assert(d >= 1 and d <= 366);
        return @intCast(d);
    }

     // Return day of week starting with Monday = 1 and Sunday = 7
    fn dayOfWeek(self: Date) Weekday {
        const dow: u3 = @intCast(self.toOrdinal() % 7);
        return @enumFromInt(if (dow == 0) 7 else dow);
    }
    // Return day of week starting with Monday = 0 and Sunday = 6
    fn weekday(self: Date) u4 {
        return @intFromEnum(self.dayOfWeek()) - 1;
    }

    // Return whether the date is a weekend (Saturday or Sunday)
    pub fn isWeekend(self: Date) bool {
        return self.weekday() >= 5;
    }

    // Return day of week starting with Monday = 1 and Sunday = 7
    pub fn dayNum(self: Date) u8 {
        const dow: u8 = @intCast(self.toOrdinal() % 7);
        return if (dow == 0) 7 else dow;
    }

    pub fn getYear(self:Date) u16 {return self.year;}

    pub fn getMonth(self:Date) u4 {return self.month;}

    pub fn getDay(self:Date) u8 {return self.day;}

    // Return the ISO calendar based week of year. With 1 being the first week.
    pub fn getWeek(self: Date) u32 {
        // Ported from python's isocalendar.
        var y = self.year;
        var first_monday = daysBeforeFirstMonday(y);
        const today = ymd2ord(self.year, self.month, self.day);
        if (today < first_monday) {
            y -= 1;
            first_monday = daysBeforeFirstMonday(y);
        }
        const days_between = today - first_monday;
        var week = @divFloor(days_between, 7);
        if (week >= 52 and today >= daysBeforeFirstMonday(y + 1)) {
            y += 1;
            week = 0;
        }
        assert(week >= 0 and week < 53);
        week = @intCast(week + 1);
        return week ;
    }
    // ------------------------------------------------------------------------
    // Operations
    // ------------------------------------------------------------------------

    // Return a copy of the date shifted by the given number of days
    pub fn shiftDays(self: Date, days: i32) Date {
        return self.shift(Delta{ .days = days });
    }

    // Return a copy of the date shifted by the given number of years
    pub fn shiftYears(self: Date, years: i16) Date {
        return self.shift(Delta{ .years = years });
    }

    pub const Delta = struct {
        years: i16 = 0,
        days: i32 = 0,
    };

    // Return a copy of the date shifted in time by the delta
    pub fn shift(self: Date, delta: Delta) Date {
        if (delta.years == 0 and delta.days == 0) {
            return self.copy() catch unreachable;
        }

        // Shift year
        var year = self.year;
        if (delta.years < 0) {
            year -= @intCast(-delta.years);
        } else {
            year += @intCast(delta.years);
        }
        var ord = daysBeforeYear(year);
        var days = self.dayOfYear();
        const from_leap = isLeapYear(self.year);
        const to_leap = isLeapYear(year);
        if (days == 59 and from_leap and to_leap) {
            // No change before leap day
        } else if (days < 59) {
            // No change when jumping from leap day to leap day
        } else if (to_leap and !from_leap) {
            // When jumping to a leap year to non-leap year
            // we have to add a leap day to the day of year
            days += 1;
        } else if (from_leap and !to_leap) {
            // When jumping from leap year to non-leap year we have to undo
            // the leap day added to the day of yearear
            days -= 1;
        }
        ord += days;

        // Shift days
        if (delta.days < 0) {
            ord -= @intCast(-delta.days);
        } else {
            ord += @intCast(delta.days);
        }
        return Date.fromOrdinal(ord);
    }


//--------------------------------
//  translate
//--------------------------------


   // Return date extended
    const DATE_FMT_EXT= "{s} {:0>2} {s} {:0>4}";
    pub fn dateExt(self: Date, allocator: AllocDate, lng: Idiom) ![]u8 {
        return std.fmt.allocPrint(allocator, DATE_FMT_EXT,
            .{ self.nameDay(lng), self.day, self.nameMonth(lng), self.year });
    }
    const DATE_FMT_ABR= "{s}. {:0>2} {s}. {:0>4}";
    pub fn dateAbr(self: Date, allocator: AllocDate, lng: Idiom) ![]u8 {
        return std.fmt.allocPrint(allocator, DATE_FMT_ABR,
            .{ self.abbrevDay(lng), self.day, self.abbrevMonth(lng), self.year });
    }

     pub const Idiom = enum(u5) {
        en, // English
        fr, // French
        sp, // Spanish
        po, // Portuguese
        it, // Italian
        de, // German
        ne, // Netherlands
        fi, // finland
        gr, // Greece
        so, // Slovakia
        lu, // Lutuania
        es, // Estonia
        pl, // Poland
        ro, // Romania
        cn, // china
        co, // Korean
        jp, // Japan
        ru, // Russia
    };

    
    // Return the abbreviation name of the day of the week, eg "Sunday"
    pub fn abbrevDay(date:Date, lng : Idiom) [] const u8 {
        var nday: u8 = @intCast(date.toOrdinal() % 7);
        if (nday == 0 ) nday = 7;
        switch(lng) {
            .en => {
                switch(nday) {
                    1  => return "Mon",
                    2  => return "Tue",
                    3  => return "Wed",
                    4  => return "Thu",
                    5  => return "Fri",
                    6  => return "Sat",
                    7  => return "Sun",
                    else => {},
                }   
             },
            .fr =>{
                switch(nday) {
                    1  => return "Lun",
                    2  => return "Mar",
                    3  => return "Mer",
                    4  => return "Jeu",
                    5  => return "Ven",
                    6  => return "Sam",
                    7  => return "Dim",
                    else => {},
                }
            },    
            .sp =>{
                switch(nday) {
                    1  => return "Lun",
                    2  => return "Mar",
                    3  => return "Mié",
                    4  => return "Jue",
                    5  => return "Vie",
                    6  => return "Sáb",
                    7  => return "Dom",
                    else => {},
                }    
            },
            .po =>{
                switch(nday) {
                    1  => return "seg",
                    2  => return "Ter",
                    3  => return "Qua",
                    4  => return "Qui",
                    5  => return "Sex",
                    6  => return "Sáb",
                    7  => return "dom",
                    else => {},
                }    
            },
            .it =>{
                switch(nday) {
                    1  => return "Lun",
                    2  => return "Mar",
                    3  => return "Mer",
                    4  => return "Gio",
                    5  => return "Ven",
                    6  => return "Sab",
                    7  => return "Dom",
                    else => {},
                }    
            },
            .de =>{
                switch(nday) {
                    1  => return "Mon",
                    2  => return "Die",
                    3  => return "Mit",
                    4  => return "Don",
                    5  => return "Fre",
                    6  => return "Sam",
                    7  => return "Son",
                    else => return "",
                }    
            },
            .ne =>{
                switch(nday) {
                    1  => return "Maa",
                    2  => return "Din",
                    3  => return "Woe",
                    4  => return "Don",
                    5  => return "Vri",
                    6  => return "Zat",
                    7  => return "Zon",
                    else => {},
                }    
            },
            .fi =>{
                switch(nday) {
                    1  => return "Maa",
                    2  => return "Tii",
                    3  => return "Kes",
                    4  => return "Tor",
                    5  => return "Per",
                    6  => return "Lau",
                    7  => return "Sun",
                    else => {},
                }    
            },
            .gr =>{
                switch(nday) {
                    1  => return "Δευ",
                    2  => return "Τρί",
                    3  => return "Τετ",
                    4  => return "Πέμ",
                    5  => return "Παρ",
                    6  => return "Σάβ",
                    7  => return "Κυρ",
                    else => {},
                }    
            },
            .so =>{
                switch(nday) {
                    1  => return "Pon",
                    2  => return "Uto",
                    3  => return "Str",
                    4  => return "Štv",
                    5  => return "Pia",
                    6  => return "Sob",
                    7  => return "Ned",
                    else => {},
                }    
            },
            .lu =>{
                switch(nday) {
                    1  => return "Pir",
                    2  => return "Ant",
                    3  => return "Tre",
                    4  => return "Ket",
                    5  => return "Pen",
                    6  => return "Šeš",
                    7  => return "Sek",
                    else => {},
                }    
            },
            .es =>{
                switch(nday) {
                    1  => return "Esmv",
                    2  => return "Tei",
                    3  => return "Kol",
                    4  => return "Nel",
                    5  => return "Red",
                    6  => return "Lau",
                    7  => return "Püh",
                    else => {},
                }    
            },
            .pl =>{
                switch(nday) {
                    1  => return "Pon",
                    2  => return "wto",
                    3  => return "śro",
                    4  => return "czw",
                    5  => return "pią",
                    6  => return "sob",
                    7  => return "niea",
                    else => {},
                }    
            },
            .ro =>{
                switch(nday) {
                    1  => return "Lun",
                    2  => return "Mar",
                    3  => return "Mie",
                    4  => return "joi",
                    5  => return "vin",
                    6  => return "sâm",
                    7  => return "Dum",
                    else => {},
                }    
            },
            .cn =>{
                switch(nday) {
                    1  => return "星期一",
                    2  => return "星期二",
                    3  => return "星期三",
                    4  => return "星期四",
                    5  => return "星期五",
                    6  => return "星期六",
                    7  => return "星期日",
                    else => {},
                }    
            },
            .co =>{
                switch(nday) {
                    1  => return "월요일",
                    2  => return "화요일",
                    3  => return "수요일",
                    4  => return "목요일",
                    5  => return "금요일",
                    6  => return "토요일",
                    7  => return "일요일",
                    else => {},
                }    
            },
            .jp =>{
                switch(nday) {
                    1  => return "月曜日",
                    2  => return "火曜日",
                    3  => return "水曜日",
                    4  => return "木曜日",
                    5  => return "金曜日",
                    6  => return "土曜日",
                    7  => return "日曜日",
                    else => {},
                }    
            },
            .ru =>{
                switch(nday) {
                    1  => return "Пон",
                    2  => return "Вто",
                    3  => return "Сре",
                    4  => return "Чет",
                    5  => return "Пят",
                    6  => return "Суб",
                    7  => return "Вос",
                    else => {},
                }    
            },
       }
        return "";
    }

    // Return the name of the day of the week, eg "Sunday"
    pub fn nameDay(date:Date, lng : Idiom) []const u8 {
        var nday: u8 = @intCast(date.toOrdinal() % 7);
        if (nday == 0 ) nday = 7;
        switch( lng) {
            .en => {
                switch(nday) {
                    1  => return "Monday",
                    2  => return "Tuesday",
                    3  => return "Wednesday",
                    4  => return "Thursday",
                    5  => return "Friday",
                    6  => return "Saturday",
                    7  => return "Sunday",
                    else => {},
                }   
             },
            .fr =>{
                switch(nday) {
                    1  => return "Lundi",
                    2  => return "Mardi",
                    3  => return "Mercredi",
                    4  => return "Jeudi",
                    5  => return "Vendredi",
                    6  => return "Samedi",
                    7  => return "Dimanche",
                    else => {},
                }    
            },
            .sp =>{
                switch(nday) {
                    1  => return "Lunes",
                    2  => return "Martes",
                    3  => return "Miércoles",
                    4  => return "Jueves",
                    5  => return "Viernes",
                    6  => return "Sábado",
                    7  => return "Domingo",
                    else => {},
                }    
            },
            .po =>{
                switch(nday) {
                    1  => return "segunda-feira",
                    2  => return "Terça-feira",
                    3  => return "Quarta-feira",
                    4  => return "Quinta-feira",
                    5  => return "Sexta-feira",
                    6  => return "Sábado",
                    7  => return "domingo",
                    else => {},
                }    
            },
            .it =>{
                switch(nday) {
                    1  => return "Lunedì",
                    2  => return "Martedì",
                    3  => return "Mercoledì",
                    4  => return "Giovedì",
                    5  => return "Venerdì",
                    6  => return "Sabato",
                    7  => return "Domenica",
                    else => {},
                }    
            },
            .de =>{
                switch(nday) {
                    1  => return "Montag",
                    2  => return "Dienstag",
                    3  => return "Mittwoch",
                    4  => return "Donnersta",
                    5  => return "Freitag",
                    6  => return "Samstag",
                    7  => return "Sonntag",
                    else => {},
                }    
            },
            .ne =>{
                switch(nday) {
                    1  => return "Maandag",
                    2  => return "Dinsdag",
                    3  => return "Woensdag",
                    4  => return "Donderdag",
                    5  => return "Vrijdag",
                    6  => return "Zaterdag",
                    7  => return "Zondag",
                    else => {},
                }    
            },
            .fi =>{
                switch(nday) {
                    1  => return "Maanantai",
                    2  => return "Tiistai",
                    3  => return "Keskiviikko",
                    4  => return "Torstai",
                    5  => return "Perjantai",
                    6  => return "Lauantai",
                    7  => return "Sunnuntai",
                    else => {},
                }    
            },
            .gr =>{
                switch(nday) {
                    1  => return "Δευτέρα",
                    2  => return "Τρίτη",
                    3  => return "Τετάρτη",
                    4  => return "Πέμπτη",
                    5  => return "Παρασκευή",
                    6  => return "Σάββατο",
                    7  => return "Κυριακή",
                    else => {},
                }    
            },
            .so =>{
                switch(nday) {
                    1  => return "Pondelok",
                    2  => return "Utorok",
                    3  => return "Streda",
                    4  => return "Štvrtok",
                    5  => return "Piatok",
                    6  => return "Sobota",
                    7  => return "Nedeľ",
                    else => {},
                }    
            },
            .lu =>{
                switch(nday) {
                    1  => return "Pirmadienis",
                    2  => return "Antradienis",
                    3  => return "Trečiadienis",
                    4  => return "Ketvirtadienis",
                    5  => return "Penktadienis",
                    6  => return "Šeštadienis",
                    7  => return "Sekmadienis",
                    else => {},
                }    
            },
            .es =>{
                switch(nday) {
                    1  => return "Esmaspäev",
                    2  => return "Teisipäev",
                    3  => return "Kolmapäev",
                    4  => return "Neljapäev",
                    5  => return "Reede",
                    6  => return "Laupäev",
                    7  => return "Pühapäev",
                    else => {},
                }    
            },
            .pl =>{
                switch(nday) {
                    1  => return "Poniedziałek",
                    2  => return "wtorek",
                    3  => return "środa",
                    4  => return "czwartek",
                    5  => return "piątek",
                    6  => return "sobota",
                    7  => return "niedziela",
                    else => {},
                }    
            },
            .ro =>{
                switch(nday) {
                    1  => return "Luni",
                    2  => return "Marți",
                    3  => return "Miercuri",
                    4  => return "joi",
                    5  => return "vineri",
                    6  => return "sâmbătă",
                    7  => return "Duminică",
                    else => {},
                }    
            },
            .cn =>{
                switch(nday) {
                    1  => return "星期一",
                    2  => return "星期二",
                    3  => return "星期三",
                    4  => return "星期四",
                    5  => return "星期五",
                    6  => return "星期六",
                    7  => return "星期日",
                    else => {},
                }    
            },
            .co =>{
                switch(nday) {
                    1  => return "월요일",
                    2  => return "화요일",
                    3  => return "수요일",
                    4  => return "목요일",
                    5  => return "금요일",
                    6  => return "토요일",
                    7  => return "일요일",
                    else => {},
                }    
            },
            .jp =>{
                switch(nday) {
                    1  => return "月曜日",
                    2  => return "火曜日",
                    3  => return "水曜日",
                    4  => return "木曜日",
                    5  => return "金曜日",
                    6  => return "土曜日",
                    7  => return "日曜日",
                    else => {},
                }    
            },
            .ru =>{
                switch(nday) {
                    1  => return "Понедельник",
                    2  => return "Вторник",
                    3  => return "Среда",
                    4  => return "Четверг",
                    5  => return "Пятница",
                    6  => return "Суббота",
                    7  => return "Воскресенье",
                    else => {},
                }    
            },
        }
        return "";
    }     


   // Return the Abbreviation name of the day of the month, eg "January"
    pub fn abbrevMonth(date:Date, lng : Idiom) [] const u8 {
        switch(lng) {
            .en => {
                switch(date.month) {
                    1  => return "Jan",
                    2  => return "Feb",
                    3  => return "Mar",
                    4  => return "Apr",
                    5  => return "May",
                    6  => return "Jun",
                    7  => return "Jul",
                    8  => return "Aug",
                    9  => return "Sep",
                    10 => return "Oct",
                    11 => return "Nov",
                    12 => return "Dec",
                    else => {},
                }   
             },
            .fr =>{
                switch(date.month) {
                    1  => return "Jan",
                    2  => return "Fev",
                    3  => return "Mar",
                    4  => return "Avr",
                    5  => return "Mai",
                    6  => return "Jun",
                    7  => return "Jul",
                    8  => return "Aoû",
                    9  => return "Sep",
                    10 => return "Oct",
                    11 => return "Nov",
                    12 => return "Dec",
                    else => {},
                }
            },    
            .sp =>{
                switch(date.month) {
                    1  => return "Ene",
                    2  => return "Feb",
                    3  => return "Mar",
                    4  => return "Abr",
                    5  => return "May",
                    6  => return "Jun",
                    7  => return "Jul",
                    8  => return "Ago",
                    9  => return "Sep",
                    10 => return "Oct",
                    11 => return "Nov",
                    12 => return "Dic",
                    else => {},
                }
            },
            .po =>{
                switch(date.month) {
                    1  => return "Jan",
                    2  => return "Fev",
                    3  => return "Mar",
                    4  => return "Abr",
                    5  => return "Mai",
                    6  => return "Jun",
                    7  => return "Jul",
                    8  => return "Ago",
                    9  => return "Set",
                    10 => return "Out",
                    11 => return "Nov",
                    12 => return "Dez",
                    else => {},
                }
            },
            .it =>{
                switch(date.month) {
                    1  => return "Gen",
                    2  => return "Feb",
                    3  => return "Mar",
                    4  => return "Apr",
                    5  => return "Mag",
                    6  => return "Giu",
                    7  => return "Lug",
                    8  => return "Ago",
                    9  => return "Set",
                    10 => return "Ott",
                    11 => return "Nov",
                    12 => return "Dic",
                    else => {},
                }
            },
            .de =>{
                switch(date.month) {
                    1  => return "Jan",
                    2  => return "Feb",
                    3  => return "Mär",
                    4  => return "Apr",
                    5  => return "Mai",
                    6  => return "Jun",
                    7  => return "Jul",
                    8  => return "Aug",
                    9  => return "Sep",
                    10 => return "Okt",
                    11 => return "Nov",
                    12 => return "Dez",
                    else => {},
                }
            },
            .ne =>{
                switch(date.month) {
                    1  => return "Jan",
                    2  => return "Feb",
                    3  => return "Maa",
                    4  => return "Apr",
                    5  => return "Kun",
                    6  => return "Jun",
                    7  => return "Jul",
                    8  => return "Aug",
                    9  => return "Sep",
                    10 => return "Okt",
                    11 => return "Nov",
                    12 => return "Dec",
                    else => {},
                }
            },
            .fi =>{
                switch(date.month) {
                    1  => return "Tam",
                    2  => return "Hel",
                    3  => return "Maa",
                    4  => return "Huh",
                    5  => return "Tou",
                    6  => return "Kes",
                    7  => return "Hei",
                    8  => return "Elo",
                    9  => return "Syy",
                    10 => return "Lok",
                    11 => return "Mar",
                    12 => return "Jou",
                    else => {},
                }
            },
            .gr =>{
                switch(date.month) {
                    1  => return "Ιαν",
                    2  => return "Φεβ",
                    3  => return "Μάρ",
                    4  => return "Απρ",
                    5  => return "Μάι",
                    6  => return "Ιον",
                    7  => return "Ιολ",
                    8  => return "Αύγ",
                    9  => return "Σεπ",
                    10 => return "Οκτ",
                    11 => return "Νοέ",
                    12 => return "Δεκ",
                    else => {},
                }
            },
            .so =>{
                switch(date.month) {
                    1  => return "Jan",
                    2  => return "Feb",
                    3  => return "Mar",
                    4  => return "Apr",
                    5  => return "Máj",
                    6  => return "jún",
                    7  => return "júl",
                    8  => return "Aug",
                    9  => return "Sep",
                    10 => return "Okt",
                    11 => return "Nov",
                    12 => return "Dec",
                    else => {},
                }
            },
            .lu =>{
                switch(date.month) {
                    1  => return "Sau",
                    2  => return "Vas",
                    3  => return "Kov",
                    4  => return "Bal",
                    5  => return "Geg",
                    6  => return "Bir",
                    7  => return "Lie",
                    8  => return "Rgp",
                    9  => return "Rgs",
                    10 => return "Spa",
                    11 => return "Lap",
                    12 => return "Gru",
                    else => {},
                }
            },
            .es =>{
                switch(date.month) {
                    1  => return "Jan",
                    2  => return "Veb",
                    3  => return "Mär",
                    4  => return "Apr",
                    5  => return "Mai",
                    6  => return "Jun",
                    7  => return "Jul",
                    8  => return "Aug",
                    9  => return "Sep",
                    10 => return "Okt",
                    11 => return "Nov",
                    12 => return "Des",
                    else => {},
                }
            },
            .pl =>{
                switch(date.month) {
                    1  => return "Sty",
                    2  => return "Lut",
                    3  => return "Mar",
                    4  => return "Kwi",
                    5  => return "Maj",
                    6  => return "Cze",
                    7  => return "Lip",
                    8  => return "Sie",
                    9  => return "Wrz",
                    10 => return "Paź",
                    11 => return "Lis",
                    12 => return "Grud",
                    else => {},
                }
            },
            .ro =>{
                switch(date.month) {
                    1  => return "Ian",
                    2  => return "Feb",
                    3  => return "Mar",
                    4  => return "Apr",
                    5  => return "Mai",
                    6  => return "Iun",
                    7  => return "Iul",
                    8  => return "Aug",
                    9  => return "Sep",
                    10 => return "Oct",
                    11 => return "Noi",
                    12 => return "Dec",
                    else => {},
                }
            },
            .cn =>{
                switch(date.month) {
                    1  => return "一月",
                    2  => return "二月",
                    3  => return "三月",
                    4  => return "四月",
                    5  => return "五月",
                    6  => return "六月",
                    7  => return "七月",
                    8  => return "八月",
                    9  => return "九月",
                    10 => return "十月",
                    11 => return "十一月",
                    12 => return "十二月",
                    else => {},
                }
            },
            .co =>{
                switch(date.month) {
                    1  => return "1월",
                    2  => return "2월",
                    3  => return "3월",
                    4  => return "4월",
                    5  => return "5월",
                    6  => return "6월",
                    7  => return "7월",
                    8  => return "8월",
                    9  => return "9월",
                    10 => return "10월",
                    11 => return "11월",
                    12 => return "12월",
                    else => {},
                }
            },
            .jp =>{
                switch(date.month) {
                    1  => return "1月",
                    2  => return "2月",
                    3  => return "3月",
                    4  => return "4月",
                    5  => return "5月",
                    6  => return "6月",
                    7  => return "7月",
                    8  => return "8月",
                    9  => return "9月",
                    10 => return "10月",
                    11 => return "11月",
                    12 => return "12月",
                    else => {},
                }
            },
            .ru =>{
                switch(date.month) {
                    1  => return "Янв",
                    2  => return "Фев",
                    3  => return "Мар",
                    4  => return "Апр",
                    5  => return "Май",
                    6  => return "Июн",
                    7  => return "Июл",
                    8  => return "Авг",
                    9  => return "Сен",
                    10 => return "Окт",
                    11 => return "Ноя",
                    12 => return "Дек",
                    else => {},
                }
            },
        }
        return "";
    }     

    // Return the name of the month, eg "January"
    pub fn nameMonth(date:Date, lng : Idiom) []const u8 {
        switch( lng) {
            .en => {
                switch(date.month) {
                    1  => return "January",
                    2  => return "February",
                    3  => return "March",
                    4  => return "April",
                    5  => return "May",
                    6  => return "June",
                    7  => return "Jul",
                    8  => return "August",
                    9  => return "September",
                    10 => return "October",
                    11 => return "November",
                    12 => return "December",
                    else => {},
                }
             },
            .fr =>{
                switch(date.month) {
                    1  => return "Janvier",
                    2  => return "Février",
                    3  => return "Mars",
                    4  => return "Avril",
                    5  => return "Mai",
                    6  => return "Juin",
                    7  => return "Juillet",
                    8  => return "Août",
                    9  => return "Septembre",
                    10 => return "Octobre",
                    11 => return "Novembre",
                    12 => return "Décembre",
                    else => {},
                }
            },
            .sp =>{
                switch(date.month) {
                    1  => return "Enero",
                    2  => return "Febrero",
                    3  => return "Marzo",
                    4  => return "Abril",
                    5  => return "Mayo",
                    6  => return "Junio",
                    7  => return "Julio",
                    8  => return "Agosto",
                    9  => return "Septiembre",
                    10 => return "Octubre",
                    11 => return "Noviembre",
                    12 => return "Diciembre",
                    else => {},
                }
            },
            .po =>{
                switch(date.month) {
                    1  => return "Janeiro",
                    2  => return "Fevereiro",
                    3  => return "Março",
                    4  => return "Abril",
                    5  => return "Maio",
                    6  => return "Junho",
                    7  => return "Julho",
                    8  => return "Agosto",
                    9  => return "Setembro",
                    10 => return "Outubro",
                    11 => return "Novembro",
                    12 => return "Dezembro",
                    else => {},
                }
            },
            .it =>{
                switch(date.month) {
                    1  => return "Gennaio",
                    2  => return "Febbraio",
                    3  => return "Marzo",
                    4  => return "Aprile",
                    5  => return "Maggio",
                    6  => return "Giugno",
                    7  => return "Luglio",
                    8  => return "Agosto",
                    9  => return "Settembre",
                    10 => return "Ottobre",
                    11 => return "Novembre",
                    12 => return "Dicembre",
                    else => {},
                }
            },
            .de =>{
                switch(date.month) {
                    1  => return "Januar",
                    2  => return "Februar",
                    3  => return "März",
                    4  => return "April",
                    5  => return "Mai",
                    6  => return "Juni",
                    7  => return "Juli",
                    8  => return "August",
                    9  => return "September",
                    10 => return "Oktober",
                    11 => return "November",
                    12 => return "Dezember",
                    else => {},
                }
            },
            .ne =>{
                switch(date.month) {
                    1  => return "Januari",
                    2  => return "Februari",
                    3  => return "Maart",
                    4  => return "April",
                    5  => return "Kunnen",
                    6  => return "Juni",
                    7  => return "Juli",
                    8  => return "Augustus",
                    9  => return "September",
                    10 => return "Oktober",
                    11 => return "November",
                    12 => return "December",
                    else => {},
                }
            },
            .fi =>{
                switch(date.month) {
                    1  => return "Tammikuu",
                    2  => return "Helmikuu",
                    3  => return "Maaliskuuta",
                    4  => return "Huhtikuuta",
                    5  => return "Toukokuuta",
                    6  => return "Kesäkuuta",
                    7  => return "Heinäkuuta",
                    8  => return "Elokuuta",
                    9  => return "Syyskuuta",
                    10 => return "Lokakuuta",
                    11 => return "Marraskuuta",
                    12 => return "Joulukuu",
                    else => {},
                }
            },
            .gr =>{
                switch(date.month) {
                    1  => return "Ιανουάριος",
                    2  => return "Φεβρουάριος",
                    3  => return "Μάρτιος",
                    4  => return "Απρίλιος",
                    5  => return "Μάιος",
                    6  => return "Ιούνιος",
                    7  => return "Ιούλιος",
                    8  => return "Αύγουστος",
                    9  => return "Σεπτέμβριος",
                    10 => return "Οκτώβριος",
                    11 => return "Νοέμβριος",
                    12 => return "Δεκέμβριος",
                    else => {},
                }
            },
            .so =>{
                switch(date.month) {
                    1  => return "Január",
                    2  => return "Február",
                    3  => return "Marec",
                    4  => return "Apríl",
                    5  => return "Máj",
                    6  => return "jún",
                    7  => return "júl",
                    8  => return "August",
                    9  => return "Septembe",
                    10 => return "Október",
                    11 => return "November",
                    12 => return "December",
                    else => {},
                }
            },
            .lu =>{
                switch(date.month) {
                    1  => return "Sausio",
                    2  => return "Vasario",
                    3  => return "Kovas",
                    4  => return "Balandis",
                    5  => return "Gegužė",
                    6  => return "Birželis",
                    7  => return "Liepa",
                    8  => return "Rugpjūtis",
                    9  => return "Rugsėjis",
                    10 => return "Spalis",
                    11 => return "Lapkritis",
                    12 => return "Gruodis",
                    else => {},
                }
            },
            .es =>{
                switch(date.month) {
                    1  => return "Jaanuar",
                    2  => return "Veebruar",
                    3  => return "Märts",
                    4  => return "Aprill",
                    5  => return "Mai",
                    6  => return "Juuni",
                    7  => return "Juuli",
                    8  => return "August",
                    9  => return "September",
                    10 => return "Oktoober",
                    11 => return "November",
                    12 => return "Detsember",
                    else => {},
                }
            },
            .pl =>{
                switch(date.month) {
                    1  => return "Styczeń",
                    2  => return "Luty",
                    3  => return "Marzec",
                    4  => return "Kwiecień",
                    5  => return "Maj",
                    6  => return "Czerwiec",
                    7  => return "Lipiec",
                    8  => return "Sierpień",
                    9  => return "Wrzesień",
                    10 => return "Październik",
                    11 => return "Listopad",
                    12 => return "Grudzień",
                    else => {},
                }
            },
            .ro =>{
                switch(date.month) {
                    1  => return "Ianuarie",
                    2  => return "Februarie",
                    3  => return "Martie",
                    4  => return "Aprilie",
                    5  => return "Mai",
                    6  => return "Iunie",
                    7  => return "Iulie",
                    8  => return "August",
                    9  => return "Septembrie",
                    10 => return "Octombrie",
                    11 => return "Noiembrie",
                    12 => return "Decembrie",
                    else => {},
                }
            },
            .cn =>{
                switch(date.month) {
                    1  => return "一月",
                    2  => return "二月",
                    3  => return "三月",
                    4  => return "四月",
                    5  => return "五月",
                    6  => return "六月",
                    7  => return "七月",
                    8  => return "八月",
                    9  => return "九月",
                    10 => return "十月",
                    11 => return "十一月",
                    12 => return "十二月",
                    else => {},
                }
            },
            .co =>{
                switch(date.month) {
                    1  => return "1월",
                    2  => return "2월",
                    3  => return "3월",
                    4  => return "4월",
                    5  => return "5월",
                    6  => return "6월",
                    7  => return "7월",
                    8  => return "8월",
                    9  => return "9월",
                    10 => return "10월",
                    11 => return "11월",
                    12 => return "12월",
                    else => {},
                }
            },
            .jp =>{
                switch(date.month) {
                    1  => return "1月",
                    2  => return "2月",
                    3  => return "3月",
                    4  => return "4月",
                    5  => return "5月",
                    6  => return "6月",
                    7  => return "7月",
                    8  => return "8月",
                    9  => return "9月",
                    10 => return "10月",
                    11 => return "11月",
                    12 => return "12月",
                    else => {},
                }
            },
           .ru =>{
                switch(date.month) {
                    1  => return "Январь",
                    2  => return "Февраль",
                    3  => return "Март",
                    4  => return "Апрель",
                    5  => return "Май",
                    6  => return "Июнь",
                    7  => return "Июль",
                    8  => return "Август",
                    9  => return "Сентябрь",
                    10 => return "Октябрь",
                    11 => return "Ноябрь",
                    12 => return "Декабрь",
                    else => {},
                }
            },
        }
        return "";
    }
};

