// -------------------------------------------------------------------------- //
// Copyright (c) 2019-2022, Jean-Pierre Laroche                               //
// Distributed under the terms of the MIT License.                            //
// The full license is in the file LICENSE, distributed with this software.   //
// -------------------------------------------------------------------------- //

// Some of this is ported from cpython's datetime module
const std = @import("std");
pub const tmz = @import("timezones");

pub const ofs = @import("timeoffset");
const lib_file ="/tmp/Timezone/data.mdb";

const AllocDate = std.mem.Allocator;
const Order = std.math.Order;


pub const MIN_YEAR: u16 = 1;
pub const MAX_YEAR: u16 = 9999;
pub const MAX_ORDINAL: u32 = 3652059;

const DAYS_IN_MONTH = [12]u8{ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
const DAYS_BEFORE_MONTH = [12]u16{ 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 };



var udate: DATE = undefined;

/// Errors that may occur when using ZFIELD
    pub const Error = error{
        Failed_zone,
        Failed_value,
    };





var arenaDate = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var allocDate = arenaDate.allocator();
var arenaDtime = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var allocDtime = arenaDtime.allocator();
//----------------------------------
// outils
//----------------------------------

fn checkLeapYear(year: usize) bool {
    return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0);
}

fn dayInYear(year : u32) i64 {
    if (checkLeapYear(year)) return 366 else return 365 ;
}

fn daysInMonth(year: u32, month: u32) u32 {
    const days_per_month = [_]u8 { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
    if (month == 2 and checkLeapYear(year)) {
        return 29;
    }
    return days_per_month[month - 1];
}

// Number of days before Jan 1st of year
fn daysBeforeYear(year: u32) u32 {
    const y: u32 = year - 1;
    return y * 365 + @divFloor(y, 4) - @divFloor(y, 100) + @divFloor(y, 400);
}


fn isFile() bool {
    const test_file = std.fs.openFileAbsolute(lib_file,.{}) catch { return false;};
    test_file.close();
    return true;
}


// Days before 1 Jan 1970
const EPOCH = daysBeforeYear(1970) + 1;

//------------------------------------
// Datetime
// -----------------------------------
pub const DTIME = struct {
    year: u16,
    month: u4,
    day: u8,
    hour: u8 = 0,// 0>23
    minute: u8 = 0,// 0>59
    second: u8 = 0,// 0>59
    nanosecond: u64 = 0,// 0> 999999999
    tmz : i16 = 0,

	pub fn deinitDtime() void {
	    _=arenaDtime.reset(.free_all);
	}
    //Change of field attribute
    pub fn hardTime(buf :[]const u8, ntmz :i32) DTIME{

        var tm = DTIME {
            .year  = 0,
            .month = 0,
            .day   = 0,
            .hour  = 0,
            .minute = 0,
            .second = 0,
            .nanosecond = 0,
            .tmz   = 0
        };
            var sign : i8 = 1; if (ntmz < 0) sign = -1;
            for(buf[0..22], 0..22) |n,x| {
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

                else => {}, 
            }
        }

        tm.tmz = @intCast(ntmz) ; //tm.tmz *= sign;
        return tm;
    }

    // Date initialization in UTC ONLY time-stamp format.
    // use is made of a chronolog
    pub fn nowUTC() DTIME {
        const TS: u128 = @abs(std.time.nanoTimestamp());
        var th: u64 = @intCast(@mod(TS, std.time.ns_per_day));

        // th is now only the time part of the day
        const hr: u64 = @intCast(@divFloor(th, std.time.ns_per_hour));
        th -= hr * std.time.ns_per_hour;
        const min: u64 = @intCast(@divFloor(th, std.time.ns_per_min));
        th -= min * std.time.ns_per_min;
        const sec: u64 = @intCast(@divFloor(th, std.time.ns_per_s));
        const ns: u64 = th - sec * std.time.ns_per_s;

        var days_since_epoch: u64 = @intCast(@divFloor(TS , std.time.ns_per_day));


        // Back to year/month/day from 1970
        var year: u32 = 1970;
        while (days_since_epoch >= dayInYear(year)) {
            days_since_epoch -= if (checkLeapYear(year)) 366 else 365;
            year += 1;
        }

        var month: u32 = 1;
        while (days_since_epoch >= daysInMonth(year, month)) {
            days_since_epoch -= daysInMonth(year, month);
            month += 1;
        }

        const day: u64 = days_since_epoch + 1;
        const chronoHardFMT :[]const u8 = "{:0>4}{:0>2}{:0>2}{:0>2}{:0>2}{:0>2}{:0>9}";
        const  r : []const u8 =  std.fmt.allocPrint(allocDate, chronoHardFMT,
            .{ year, month, day , hr, min,sec,ns})  catch unreachable;

        const tm = hardTime(r, 0) ;
        defer allocDate.free(r);
        return tm;
    }

    //  Date time reverse  timestamp
    pub fn Timestamp(self: DTIME) u64 {

        // Only for a simplified calculation and without leap years here
        const days_per_month = [_]u8 { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
        var total_days: u64 = 0;

        // Add days from previous years
        for (1970..self.year) |y| {
        total_days += if (checkLeapYear(y)) 366 else 365;
        }

        // Add days of the months of the current year
        for (0..(self.month - 1)) |m| {
            total_days += days_per_month[m];
            if (m == 1 and checkLeapYear(self.year)) {
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
    pub fn nowTime(mz :tmz.Timezone) DTIME {
        if (!isFile()) ofs.writeTimezone();
        const offset :i32 = ofs.readTimezone(mz.id);
        
        //timezone  Europe.Paris = 60 minutes in minutes
        const TS : u128 = @intCast(std.time.nanoTimestamp() + (offset * @as(i64,std.time.ns_per_min))) ;

        var th: u64 = @intCast(@mod(TS, std.time.ns_per_day));
          
        // th is now only the time part of the day
        const hr: u64 = @intCast(@divFloor(th, std.time.ns_per_hour));
        th -= hr * std.time.ns_per_hour;
        const min: u64 = @intCast(@divFloor(th, std.time.ns_per_min));
        th -= min * std.time.ns_per_min;
        const sec: u64 = @intCast(@divFloor(th, std.time.ns_per_s));
         const ns: u64 = th - sec * std.time.ns_per_s;



        var days_since_epoch: u64 = @intCast(@divFloor(TS , std.time.ns_per_day));
          // Back to year/month/day from 1970
        var year: u32 = 1970;
        while (days_since_epoch >= dayInYear(year)) {
            days_since_epoch -= if (checkLeapYear(year)) 366 else 365;
            year += 1;
        }
        var month: u32 = 1;
        while (days_since_epoch >= daysInMonth(year, month)) {
            days_since_epoch -= daysInMonth(year, month);
            month += 1;
        }

        const day: u64 = days_since_epoch + 1;

        const chronoHardFMT :[]const u8 = "{:0>4}{:0>2}{:0>2}{:0>2}{:0>2}{:0>2}{:0>9}";
        const  r : []const u8 = std.fmt.allocPrint(allocDtime, chronoHardFMT,
            .{ year, month, day , hr, min,sec,ns}) catch unreachable;

        const tm = hardTime(r, offset) ;
        defer allocDtime.free(r);
        return tm;
    }


    // Date-time formatting
    const  chronoTimeFMT :[]const u8 = "{:0>4}-{:0>2}-{:0>2}T:{:0>2}:{:0>2}:{:0>2}N:{:0>9}Z:{d}";

    pub fn stringTime(self: DTIME) []const u8 {
        return std.fmt.allocPrint(allocDtime, chronoTimeFMT,
            .{ self.year, self.month, self.day, self.hour, self.minute,self.second,self.nanosecond,self.tmz })
            catch unreachable;
    }

    const chronoNumFMT = "{:0>4}{:0>2}{:0>2}{:0>2}{:0>2}{:0>2}{:0>9}{d}";

    pub fn numTime(self: DTIME) u128 {
        const  r : []const u8 = std.fmt.allocPrint(allocDtime, chronoNumFMT,
            .{ self.year, self.month, self.day, self.hour, self.minute,self.second,self.nanosecond,self.tmz })
            catch unreachable;
        const i :u128 =  std.fmt.parseInt(u128,r,10) catch unreachable;
        defer allocDtime.free(r);
        return i;
        
    }

};


//-------------------------------------------------------------
// DATE
//-------------------------------------------------------------
pub const DATE = struct {
    year: u16,
    month: u4 = 1, // Month of year
    day: u8 = 1, // Day of month
    weekday: u3, // Day of week 1-7
    week: u6, // Week of year 1-53
    status : bool = false, // date null

	pub fn deinitDate() void {
	    _=arenaDate.reset(.free_all);
	}

    // Create and validate the date
    pub fn create(year: u32, month: u32, day: u32) !DATE {
        
        if (year < MIN_YEAR or year > MAX_YEAR) return error.InvalidDate;
        if (month < 1 or month > 12) return error.InvalidDate;
        if (day < 1 or day > daysInMonth(year, month)) return error.InvalidDate;
        // Since we just validated the ranges we can now savely cast

        var dat_x =  DATE{
            .year = @intCast(year),
            .month = @intCast(month),
            .day = @intCast(day),
            .weekday = 0,
            .week =0,
            .status = true,
            };
                        
            dat_x.weekday = @intCast(dayNum(dat_x));
            dat_x.week = @intCast(searchWeek(dat_x));

            

            return dat_x;
    }

    // Do not set to zeros for consistency with function set.
    // Date will be output as “string ISO/FR/US” 0000-00-00
    pub fn dateOff(self: *DATE) void {
        self.year = 0;
        self.month =0;
        self.day = 0;
        self.week = 0;
        self.weekday = 0;
        self.status = false;
    }

    // Consistency test of the date
    fn isBad(self: DATE) bool {
        var status :bool = true;
        if (self.year < MIN_YEAR or self.year > MAX_YEAR) status = false;
        if (self.month < 1 or self.month > 12) status = false;
        if (self.day < 1 or self.day > daysInMonth(self.year, self.month)) status = false;
        if (!self.status or  !status ) return false;
        return true;
     }
    fn isBadx(self: *DATE) bool {
        var status :bool = true;
        if (self.year < MIN_YEAR or self.year > MAX_YEAR) status = false;
        if (self.month < 1 or self.month > 12) status = false;
        if (self.day < 1 or self.day > daysInMonth(self.year, self.month)) status = false;
        if (!self.status or  !status ) return false;
        return true;
     }

    // Return a copy of the date
    pub fn copy(self: DATE) !DATE {
        if (!isBad(self)) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDate,
            "\n\n\r file:{s} line:{d} column:{d} func:{s} out-of-service  err:{} >>{d}-{d}-{d}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,Error.Failed_zone, self.year, self.month, self.day})
            	catch unreachable);
        }
        var ctrl : DATE = undefined;
        ctrl.year = self.year; ctrl.month = self.month; ctrl.day = self.day; ctrl.status = self.status;
        return ctrl;
    }

 
    //Change of field attribute
    fn hardDate(buf :[]const u8) DATE{

        var dt = DATE {
            .year  = 0,
            .month = 0,
            .day   = 0,
            .week  = 0,
            .weekday = 0,
            .status = true,
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
    pub fn nowDate(mz : tmz.Timezone) DATE {
        if (!isFile()) ofs.writeTimezone();
        const offset :i128 = ofs.readTimezone(mz.id); 
        //There may be a date difference at a certain time, e.g. Paris and Los Angeles. 
        const TS : u128 = @intCast(std.time.nanoTimestamp() + (offset * @as(i64,std.time.ns_per_min))) ;

        var days_since_epoch: u64 = @intCast(@divFloor(TS , std.time.ns_per_day));


        // Revenir à l'année/mois/jour en partant de 1970
        var year: u32 = 1970;
        while (days_since_epoch >= dayInYear(year)) {
            days_since_epoch -= if (checkLeapYear(year) ) 366 else 365;
            year += 1;
        }
        var month: u32 = 1;
        while (days_since_epoch >= daysInMonth(year, month)) {
            days_since_epoch -= daysInMonth(year, month);
            month += 1;
        }

        const day: u64 = days_since_epoch + 1;


        const chronoHardFMT :[]const u8 = "{:0>4}{:0>2}{:0>2}";
        const  r : []const u8 = std.fmt.allocPrint(allocDate, chronoHardFMT,
            .{ year, month, day }) catch unreachable;
        defer allocDate.free(r);
        
        var datx = hardDate(r);
        datx.weekday = @intCast(dayNum(datx)); datx.week = @intCast(searchWeek(datx));
        return datx;
    }


    // ------------------------------------------------------------------------
    // Comparisons
    // ------------------------------------------------------------------------
    pub fn eql(self: DATE, other: DATE) bool {
        if (!isBad(self)) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDate,
            "\n\n\r file:{s} line:{d} column:{d} func:{s} out-of-service  err:{} >>{d}-{d}-{d}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,Error.Failed_zone, self.year, self.month, self.day})
            	catch unreachable);
        }
        return self.cmp(other) == .eq;
    }

    pub fn cmp(self: DATE, other: DATE) Order {
        if (!isBad(self)) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDate,
            "\n\n\r file:{s} line:{d} column:{d} func:{s} out-of-service  err:{} >>{d}-{d}-{d}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,Error.Failed_zone, self.year, self.month, self.day})
            	catch unreachable);
        }
        if (self.year > other.year) return .gt;
        if (self.year < other.year) return .lt;
        if (self.month > other.month) return .gt;
        if (self.month < other.month) return .lt;
        if (self.day > other.day) return .gt;
        if (self.day < other.day) return .lt;
        return .eq;
    }

    pub fn gt(self: DATE, other: DATE) bool {
        if (!isBad(self)) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDate,
            "\n\n\r file:{s} line:{d} column:{d} func:{s} out-of-service  err:{} >>{d}-{d}-{d}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,Error.Failed_zone, self.year, self.month, self.day})
            	catch unreachable);
        }        return self.cmp(other) == .gt;
    }

    pub fn gte(self: DATE, other: DATE) bool {
        if (!isBad(self)) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDate,
            "\n\n\r file:{s} line:{d} column:{d} func:{s} out-of-service  err:{} >>{d}-{d}-{d}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,Error.Failed_zone, self.year, self.month, self.day})
            	catch unreachable);
        }        const r = self.cmp(other);
        return r == .eq or r == .gt;
    }

    pub fn lt(self: DATE, other: DATE) bool {
        if (!isBad(self)) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDate,
            "\n\n\r file:{s} line:{d} column:{d} func:{s} out-of-service  err:{} >>{d}-{d}-{d}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,Error.Failed_zone, self.year, self.month, self.day})
            	catch unreachable);
        }        return self.cmp(other) == .lt;
    }

    pub fn lte(self: DATE, other: DATE) bool {
        if (!isBad(self)) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDate,
            "\n\n\r file:{s} line:{d} column:{d} func:{s} out-of-service  err:{} >>{d}-{d}-{d}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,Error.Failed_zone, self.year, self.month, self.day})
            	catch unreachable);
        }
        const r = self.cmp(other);
        return r == .eq or r == .lt;
    }

    // ------------------------------------------------------------------------
    // Parsing
    // ------------------------------------------------------------------------
    // Parse date in format YYYY-MM-DD. Numbers must be zero padded.
    pub fn parseISO(ymd: []const u8) !DATE {
        const value = std.mem.trim(u8, ymd, " ");
        if (value.len != 10) return error.InvalidFormat;
        const year = std.fmt.parseInt(u16, value[0..4], 10) catch return error.InvalidFormat;
        const month = std.fmt.parseInt(u8, value[5..7], 10) catch return error.InvalidFormat;
        const day = std.fmt.parseInt(u8, value[8..10], 10) catch return error.InvalidFormat;
        return DATE.create(year, month, day);
    }
    pub fn parseFR(dmy: []const u8) !DATE {
        const value = std.mem.trim(u8, dmy, " ");
        if (value.len != 10) return error.InvalidFormat;
        const day = std.fmt.parseInt(u8, value[0..2], 10) catch return error.InvalidFormat;
        const month = std.fmt.parseInt(u8, value[3..5], 10) catch return error.InvalidFormat;
        const year = std.fmt.parseInt(u16, value[6..10], 10) catch return error.InvalidFormat;
        return DATE.create(year, month, day);
    }
    pub fn parseUS(mdy: []const u8) !DATE {
        const value = std.mem.trim(u8, mdy, " ");
        if (value.len != 10) return error.InvalidFormat;
        const month = std.fmt.parseInt(u8, value[0..2], 10) catch return error.InvalidFormat;
        const day = std.fmt.parseInt(u8, value[3..5], 10) catch return error.InvalidFormat;
        const year = std.fmt.parseInt(u16, value[6..10], 10) catch return error.InvalidFormat;
        return DATE.create(year, month, day);
    }
    // TODO: Parsing

    // ------------------------------------------------------------------------
    // Formatting
    // ------------------------------------------------------------------------

    // Return date in ISO format YYYY-MM-DD
    const ISO_DATE_FMT = "{:0>4}-{:0>2}-{:0>2}";
    pub fn string(self: DATE) []const u8 {
        if (!isBad(self)) return "";

        return std.fmt.allocPrint(allocDate, ISO_DATE_FMT,
            .{ self.year, self.month, self.day }) catch unreachable;
    }

   // Return date in FR format DD/MM/YYYY
    const FR_DATE_FMT = "{:0>2}/{:0>2}/{:0>4}";
    pub fn stringFR(self: DATE) []const u8 {
        if (!isBad(self)) return "";
        return std.fmt.allocPrint(allocDate, FR_DATE_FMT,
            .{ self.day, self.month, self.year }) catch unreachable;
    }

   // Return date in FR format MM/DD/YYYY
    const US_DATE_FMT = "{:0>2}/{:0>2}/{:0>4}";
    pub fn stringUS(self: DATE) []const u8 {
        if (!isBad(self)) return "";
        return std.fmt.allocPrint(allocDate, US_DATE_FMT,
            .{ self.month, self.day, self.year }) catch unreachable;
    }

    // ------------------------------------------------------------------------
    // Properties
    // ------------------------------------------------------------------------


    // Return day of week starting with Monday = 1 and Sunday = 7

    pub fn getYear(self:DATE) u16 {return self.year;}

    pub fn getMonth(self:DATE) u4 {return self.month;}

    pub fn getDay(self:DATE) u8 {return self.day;}

    pub fn getWeek(self:DATE) u6 {return self.week;}

    pub fn getWeekDay(self:DATE) u3 {return self.weekday;}

    pub fn restOfdays(self:DATE) usize {
        const nday  = quantieme(self);
        if (checkLeapYear(self .year)) return 366 - nday else return 365 - nday ;
    }
    
    // Return whether the date is a weekend (Saturday or Sunday)
    pub fn isWeekend(self: DATE) bool {
        return self.dayNum() >= 6;
    }

    pub fn isLeapYear(self :DATE) bool {
        return (self.year % 4 == 0 and self.year % 100 != 0) or (self.year % 400 == 0);
    }

    
    // monday = 1 ... sunday = 7
    fn dayNum(self :DATE) usize {
        const y: u32 = self.year - 1 ;
        var val  = (y * 365 + (y / 4) - (y / 100) + (y / 400));
        val  += DAYS_BEFORE_MONTH[self.month - 1];
        if (self.month > 2 and checkLeapYear(self.year)) val += 1;
        val += self.day;
        val = val % 7;
        return if ( val == 0 ) 7 else val;
     }

     // ------------------------------------------------------------------------
    // Operations
    // ------------------------------------------------------------------------


    // Advance of x days
    pub fn daysMore(self: *DATE, days: u32) bool {
            var ctrl : DATE = undefined;
            ctrl.year = self.year; ctrl.month = self.month; ctrl.day = self.day; ctrl.status = self.status;
            if (!isBadx(self)) {
    			const s = @src();
                @panic( std.fmt.allocPrint(allocDate,
                "\n\n\r file:{s} line:{d} column:{d} func:{s} out-of-service  err:{} >>{d}-{d}-{d}\n\r"
                ,.{s.file, s.line, s.column,s.fn_name,Error.Failed_zone, self.year, self.month, self.day})
                	catch unreachable);
            }
            var ord : u32 = toOrdinal(ctrl) ;
            ord += days;
            if ( ord > MAX_ORDINAL ) return false;
            ctrl = fromOrdinal( ord + days );
        
            self.year = ctrl.year;  self.month = ctrl.month; self.day = ctrl.day;
            self.weekday = ctrl.weekday; self.week = ctrl.week;

            return true;
    }


    // Move back x days
    pub fn daysLess(self: *DATE, days: u32) bool {
        if (!isBadx(self)) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDate,
            "\n\n\r file:{s} line:{d} column:{d} func:{s} out-of-service  err:{} >>{d}-{d}-{d}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,Error.Failed_zone, self.year, self.month, self.day})
            	catch unreachable);
        }
        var ctrl : DATE = undefined;
        ctrl.year = self.year; ctrl.month = self.month; ctrl.day = self.day; ctrl.status = self.status;
        const ord = toOrdinal(ctrl);
        if ( ord - days < 0 ) return false;
        ctrl = fromOrdinal( ord - days);
        
        self.year = ctrl.year;  self.month = ctrl.month; self.day = ctrl.day;
        self.weekday = ctrl.weekday; self.week = ctrl.week;

        return true;
    }


    // Advance of x YEAR
    pub fn yearsMore(self: *DATE, year: u32) bool {
        if (!isBadx(self)) {
    			const s = @src();
                @panic( std.fmt.allocPrint(allocDate,
                "\n\n\r file:{s} line:{d} column:{d} func:{s} out-of-service  err:{} >>{d}-{d}-{d}\n\r"
                ,.{s.file, s.line, s.column,s.fn_name,Error.Failed_zone, self.year, self.month, self.day})
                	catch unreachable);
        }
        if ( self.year + year > 9999 or year  ==  0) return false;
        
        var ctrl : DATE = undefined;
        ctrl.year = self.year; ctrl.month = self.month; ctrl.day = self.day; ctrl.status = self.status;
        var n : usize = 0 ;
        while( n < year) :( n += 1){
            var ord = toOrdinal(ctrl);
            if (checkLeapYear(ctrl.year + 1)) ord +=366 else ord += 365;
            ctrl = fromOrdinal( ord);
        }
        self.year = ctrl.year;  self.month = ctrl.month; self.day = ctrl.day;
        self.weekday = ctrl.weekday; self.week = ctrl.week;

        return true;
    }

    // Move back x YEAR
    pub fn yearsLess(self: *DATE, year: u32) bool {
        if (!isBadx(self)) {
    			const s = @src();
                @panic( std.fmt.allocPrint(allocDate,
                "\n\n\r file:{s} line:{d} column:{d} func:{s} out-of-service  err:{} >>{d}-{d}-{d}\n\r"
                ,.{s.file, s.line, s.column,s.fn_name,Error.Failed_zone, self.year, self.month, self.day})
                	catch unreachable);
        }
        if ( self.year == year or year > self.year ) return false;
        
        var ctrl : DATE = undefined;
        ctrl.year = self.year; ctrl.month = self.month; ctrl.day = self.day; ctrl.status = self.status;
        var n : usize = year ;
        while( n > 0) :( n -= 1){
            var ord = toOrdinal(ctrl);
            if (checkLeapYear(ctrl.year )) ord -=366 else ord -= 365;
            ctrl = fromOrdinal( ord);
        }
        self.year = ctrl.year;  self.month = ctrl.month; self.day = ctrl.day;
        self.weekday = ctrl.weekday; self.week = ctrl.week;

        return true;
    }

    // Returns the day number in the year  Quantieme
    pub fn quantieme(self: DATE) usize {
        if ( (self.year < MIN_YEAR or self.year > MAX_YEAR) or
             (self.month < 1 or self.month > 12) or
             (self.day < 1 or self.day > daysInMonth(self.year, self.month)) ) {
                 const s = @src();
                @panic( std.fmt.allocPrint(allocDate,
                "\n\n\r file:{s} line:{d} column:{d} func:{s} out-of-service  err:{} >>{d}-{d}-{d}\n\r"
                ,.{s.file, s.line, s.column,s.fn_name,Error.Failed_zone, self.year, self.month, self.day})
                	catch unreachable);
        }
        const days_per_month = [_]usize{ 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

        var numdays: usize = self.day; // Commence avec le jour du mois
        var m: usize = 0;

        while (m < self.month ) : (m += 1) {
            numdays += days_per_month[m];
        }

        // Leap year check
        if ((self.year % 4 == 0 and self.year % 100 != 0) or (self.year % 400 == 0)) {
            if (self.month > 2) {
                numdays += 1; // Add 1 day for February if leap year
            }
        }

        return numdays;
    }

    
    // pub fn daysLeft(self:DATE) usize {
    //     var n: usize= 0;
    //     if ( checkLeapYear(self.year)) n = 366  else n = 365;
    //     return ( n - self.quantieme());
    // }


    //--------------------------------
    //  Internal complex function
    //--------------------------------
    // Calculation of day number with Sunday = 0, Monday = 1...
    fn dayZeller(self :DATE) usize {
        const y: u32 = self.year - 1 ;
        var val : usize  = 0;
        val = (y * 365 + (y / 4) - (y / 100) + (y / 400));
        val  += DAYS_BEFORE_MONTH[self.month - 1];
        if (self.month > 2 and checkLeapYear(self.year)) val += 1;
        val += self.day;
        val = val % 7;
        return val;
    }


    fn searchWeek(self: DATE) usize {

        var ctrl : DATE = undefined;
        // quantieme of Day
        const Q: f32 = @floatFromInt(quantieme(self));
        // N° Day
        var J : f32 = @floatFromInt(dayNum(self));
         // N° week
        var wn : usize = 0;
        var wz : f32 = 0;

        // formule standard pour trouvé le n° de semaine
        // tout doit-être fait en float
        wz = ((J + Q + 5) / 7) - ( J / 5);
        wz  = @ceil(wz);
        wn = @intFromFloat(wz);

        // récupération du dernier jour de l'année
        ctrl.year = self.year - 1;
        ctrl.month = 12;
        ctrl.day = 31;
        J = @floatFromInt(dayZeller(ctrl));
        // récupération du jour encours
        const J0 = dayZeller(self);

        //-----------------------------------------------------------------------------------
        if(checkLeapYear(self.year)){

            // 2020
            if (J == 2 and J0 == 0 ) { wn -= 1; return wn;}
            
            // 2024
            if (J == 0 and wn == 53 and J0 == 1 or J == 0 and wn == 53 and J0 == 2 ) return 1;
            if (J == 0 and wn == 1 and self.day < 4 ) return 1;
            if (J == 0 and wn == 2 and self.day < 8 ) return 1;
            if (J == 0 and wn == 2 and J0 >= 1 and J0 <= 3 ) return wn;
            if (J == 0 and wn > 2 and J0 >= 4  ) { wn -= 1; return wn;}
            if (J == 0 and wn > 2 and J0 == 0  ) { wn -= 1; return wn;}

            // 2028
            if (J == 5 and wn == 1 and J0 == 0) return 52;
            if (J == 5 and wn == 1 and J0 == 6) return 52;
            if (J == 5 and wn > 1 ) { wn -= 1; return wn;}
            
            // 2030
            if (J == 1 and J0 == 1 ) return 1;
         }
        //----------------------------------------------------------------------------------
        else {
            // 2019
            if (J == 1 and wn == 1  ) return 1;
            if (J == 1 and wn == 2 and J0 == 0) return 1;
            if (J == 1 and wn == 2 and J0 == 6) return 1;
            if (J == 1 and wn == 53 and J0 == 1 ) return 1;
            if (J == 1 and wn == 53 and J0 == 2 ) return 1;
            if (J == 1 and wn > 1 and J0 > 0 ) return wn;
            if (J == 1 and wn > 2 and J0 == 0 ) { wn -=1 ; return wn ; }
            if (J == 1 and wn > 2 and J0 == 6 ) { wn -=1 ; return wn ; }

            // 2021
            if (J == 4 and wn == 1  ) return 53;
            if (J == 4 and wn == 1  ) return 1;
            if (J == 4 and wn >  1  ) { wn -=1 ; return wn ; }

            // 2022
            if (J == 5 and wn ==  1 ) return 52 ;
            if (J == 5 and wn >= 2 ) { wn -=1; return wn; }

            // 2023
            if (J == 6 and wn ==  1 and J0 == 0 ) return 52;
            if (J == 6 and J0 ==  1 and wn == 1 ) return wn;
            if (J == 6 and J0 ==  1 and wn >= 1 ) return wn; 
            if (J == 6 and wn > 1 ) { wn -=1 ; return wn ; }
            
            // 2025
            if (J == 2 and wn == 1  ) return 1;
            if (J == 2 and wn == 53 and J0 >= 1 and J0 <= 3) return 1;
            if (J == 2 and wn > 1 and J0 > 0 ) return wn;
            if (J == 2 and wn > 1 and J0 == 0 ) { wn -=1 ; return wn ; }

            // 2026
            if (J == 3 and wn ==  1 ) return 1;
            if (J == 3 and wn > 1 and wn < 52) return wn;

            // 2029
            if (J == 0 and wn ==  1 ) return 1;
            if (J == 0 and wn == 2 and self.day < 8 ) return 1;
            if (J == 0 and wn == 53 and J0 == 1) return 1;
            if (J == 0 and wn > 2 and J0 >= 4  ) { wn -= 1; return wn;}
            if (J == 0 and wn > 2 and J0 == 0  ) { wn -= 1; return wn;}

          }
         return wn; 
    }
     


    fn toOrdinal(self  : DATE ) u32 {
        var d : u32  =0;
        var y : usize  = 1 ;
        var m : u32  = 0;
        var j : u32  =0;
        while ( y < self.year) : (y += 1) {
            if (checkLeapYear(y)) d += 366 else d += 365 ;
        }

        while (m  < self.month - 1  ) :( m += 1 ) {
            j += DAYS_IN_MONTH[m];
            if (checkLeapYear(y) and m == 1) j += 1;
        }

        j += self.day   ;

        return d + j;
    }

    fn fromOrdinal(ord :u32)  DATE {
        var year : usize = 1;
        var n : u32 = ord - 1  ;

        if ( ord > MAX_ORDINAL){
			const s = @src();
            @panic( std.fmt.allocPrint(allocDate,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}({d}) ordinal out-of-service  err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,ord,Error.Failed_zone})
            	catch unreachable);
        }
    
        while( year <= 9999) {
            if (checkLeapYear(year) ) { year += 1 ; n -= 366; } else { year += 1;  n -= 365 ; } 
            if (checkLeapYear(year)  and n < 366 or  !checkLeapYear(year) and n < 365 ) break;
        }
        var day_of_year : u32 = n;
        var month: u32 = 1;
        var days_in_month: u32 = 0;
        var i: usize = 0;

        if (day_of_year == 0 ) { month = 12 ;day_of_year = 31; year -= 1;}

        while (i < 12) : (i += 1) {
            days_in_month = DAYS_IN_MONTH[i];
            if (i == 1 and checkLeapYear(year)) { // Février bissextile
                days_in_month += 1;
            }
            if (day_of_year <= days_in_month) break;
            day_of_year -= days_in_month;
            month += 1;
        }

        udate.year = @intCast(year);
        udate.month = @intCast(month);
        udate.day = @intCast(day_of_year);

               // std.debug.print("  > {any} ",.{udate});
        udate.weekday = @intCast(dayNum(udate));
        udate.week = @intCast(searchWeek(udate));
       
        return DATE{
            .year  = udate.year,
            .month = udate.month,
            .day   = udate.day,
            .weekday = udate.weekday, 
            .week = udate.week,
            .status = true
        };
    }


    //--------------------------------
    //  translate
    //--------------------------------


    // Return date extended
    const DATE_FMT_EXT= "{s} {:0>2} {s} {:0>4}";
    pub fn dateExt(self: DATE, lng: Idiom) []u8 {
        if (!isBad(self)) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDate,
            "\n\n\r file:{s} line:{d} column:{d} func:{s} out-of-service  err:{} >>{d}-{d}-{d}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,Error.Failed_zone, self.year, self.month, self.day})
            	catch unreachable);
        }
        return std.fmt.allocPrint(allocDate, DATE_FMT_EXT,
            .{ Idiom.nameDay(self.weekday,lng), self.day,Idiom.nameMonth(self.month,lng), self.year }) catch unreachable;
    }

    const DATE_FMT_ABR= "{s}. {:0>2} {s}. {:0>4}";
    pub fn dateAbr(self: DATE, lng: Idiom) []u8 {
        if (!isBad(self)) {
			const s = @src();
            @panic( std.fmt.allocPrint(allocDate,
            "\n\n\r file:{s} line:{d} column:{d} func:{s} out-of-service  err:{} >>{d}-{d}-{d}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,Error.Failed_zone, self.year, self.month, self.day})
            	catch unreachable);
        }
        return std.fmt.allocPrint(allocDate, DATE_FMT_ABR,
            .{ Idiom.abbrevDay(self.weekday,lng), self.day, Idiom.abbrevMonth(self.month,lng), self.year }) catch unreachable;
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



        // Return the abbreviation name of the day of the week, eg "Sunday"
        pub fn abbrevDay(weekday: u3, lng : Idiom) [] const u8 {
            switch(lng) {
                .en => {
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
                        1  => return "Mon",
                        2  => return "Die",
                        3  => return "Mit",
                        4  => return "Don",
                        5  => return "Fre",
                        6  => return "Sam",
                        7  => return "Son",
                        else => {},
                    }
                },
                .ne =>{
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
            return "NULL";
        }

        // Return the name of the day of the week, eg "Sunday"
        pub fn nameDay(weekday: u3, lng : Idiom) []const u8 {
            switch( lng) {
                .en => {
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
                    switch(weekday) {
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
            return "NULL";
        }


        // Return the Abbreviation name of the day of the month, eg "January"
        pub fn abbrevMonth(month: u4, lng : Idiom) [] const u8 {
              switch(lng) {
                .en => {
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
            return "NULL";
        }

        // Return the name of the month, eg "January"
        pub fn nameMonth(month: u4, lng : Idiom) []const u8 {
             switch( lng) {
                .en => {
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
                    switch(month) {
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
            return "NULL";
        }
    };    
};

