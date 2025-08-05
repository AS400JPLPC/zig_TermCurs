const std = @import("std");
const c = @cImport(@cInclude("sqlite3.h"));



pub const Error = error{
    // Generic error
    SQLITE_ERROR,
    // Internal logic error in SQLite
    SQLITE_INTERNAL,
    // Access permission denied
    SQLITE_PERM,
    // Callback routine requested an abort
    SQLITE_ABORT,
    // The database file is locked
    SQLITE_BUSY,
    // A table in the database is locked
    SQLITE_LOCKED,
    // A malloc() failed
    SQLITE_NOMEM,
    // Attempt to write a readonly database
    SQLITE_READONLY,
    // Operation terminated by sqlite3_interrupt()
    SQLITE_INTERRUPT,
    // Some kind of disk I/O error occurred
    SQLITE_IOERR,
    // The database disk image is malformed
    SQLITE_CORRUPT,
    // Unknown opcode in sqlite3_file_control()
    SQLITE_NOTFOUND,
    // Insertion failed because database is full
    SQLITE_FULL,
    // Unable to open the database file
    SQLITE_CANTOPEN,
    // Database lock protocol error
    SQLITE_PROTOCOL,
    // Internal use only
    SQLITE_EMPTY,
    // The database schema changed
    SQLITE_SCHEMA,
    // String or BLOB exceeds size limit
    SQLITE_TOOBIG,
    // Abort due to constraint violation
    SQLITE_CONSTRAINT,
    // Data type mismatch
    SQLITE_MISMATCH,
    // Library used incorrectly
    SQLITE_MISUSE,
    // Uses OS features not supported on host
    SQLITE_NOLFS,
    // Authorization denied
    SQLITE_AUTH,
    // Not used
    SQLITE_FORMAT,
    // 2nd parameter to sqlite3_bind out of range
    SQLITE_RANGE,
    // File opened that is not a database file
    SQLITE_NOTADB,
    // Notifications from sqlite3_log()
    SQLITE_NOTICE,
    // Warnings from sqlite3_log()
    SQLITE_WARNING,
    // sqlite3_step() has another row ready
    SQLITE_ROW,
    // sqlite3_step() has finished executing
    SQLITE_DONE,
};
pub fn getError(code: c_int) Error {
    return switch (code & 0xFF) {
        c.SQLITE_ERROR => Error.SQLITE_ERROR,
        c.SQLITE_INTERNAL => Error.SQLITE_INTERNAL,
        c.SQLITE_PERM => Error.SQLITE_PERM,
        c.SQLITE_ABORT => Error.SQLITE_ABORT,
        c.SQLITE_BUSY => Error.SQLITE_BUSY,
        c.SQLITE_LOCKED => Error.SQLITE_LOCKED,
        c.SQLITE_NOMEM => Error.SQLITE_NOMEM,
        c.SQLITE_READONLY => Error.SQLITE_READONLY,
        c.SQLITE_INTERRUPT => Error.SQLITE_INTERRUPT,
        c.SQLITE_IOERR => Error.SQLITE_IOERR,
        c.SQLITE_CORRUPT => Error.SQLITE_CORRUPT,
        c.SQLITE_NOTFOUND => Error.SQLITE_NOTFOUND,
        c.SQLITE_FULL => Error.SQLITE_FULL,
        c.SQLITE_CANTOPEN => Error.SQLITE_CANTOPEN,
        c.SQLITE_PROTOCOL => Error.SQLITE_PROTOCOL,
        c.SQLITE_EMPTY => Error.SQLITE_EMPTY,
        c.SQLITE_SCHEMA => Error.SQLITE_SCHEMA,
        c.SQLITE_TOOBIG => Error.SQLITE_TOOBIG,
        c.SQLITE_CONSTRAINT => Error.SQLITE_CONSTRAINT,
        c.SQLITE_MISMATCH => Error.SQLITE_MISMATCH,
        c.SQLITE_MISUSE => Error.SQLITE_MISUSE,
        c.SQLITE_NOLFS => Error.SQLITE_NOLFS,
        c.SQLITE_AUTH => Error.SQLITE_AUTH,
        c.SQLITE_FORMAT => Error.SQLITE_FORMAT,
        c.SQLITE_RANGE => Error.SQLITE_RANGE,
        c.SQLITE_NOTADB => Error.SQLITE_NOTADB,
        c.SQLITE_NOTICE => Error.SQLITE_NOTICE,
        c.SQLITE_WARNING => Error.SQLITE_WARNING,
        c.SQLITE_ROW => Error.SQLITE_ROW,
        c.SQLITE_DONE => Error.SQLITE_DONE,
        else => @panic("invalid error code"),
    };
}

pub fn throw(code: c_int) Error!void {
    return switch (code & 0xFF) {
        c.SQLITE_OK => {},
        else => getError(code),
    };
}

//=========================================================
//=========================================================
pub const Blob = struct { data: []const u8 };
pub const Text = struct { data: []const u8 };
pub const Numeric = struct { data: []const u8 };
pub const Date = struct { data: []const u8 };
pub const Bool = struct { data: bool };

pub fn blob(data: []const u8) Blob {
    return .{ .data = data };
}

pub fn text(data: []const u8) Text {
    return .{ .data = data };
}

pub fn numeric(data: []const u8) Numeric {
    return .{ .data = data };
}
pub fn date(data: []const u8) Date {
    return .{ .data = data };
}
pub fn boolean(data: bool) Bool {
    return .{ .data = data };
}


pub fn cbool(data : bool ) i32 {
     if(data) return 1 else return 0;
}
//=========================================================
//=========================================================

pub fn isDir( vdir : []const u8) bool {
    _= std.fs.cwd().openDir(vdir,.{}) catch {return false;};
     return true;
}

pub fn isDbxist( vdir : []const u8, fn_file_name:[]const u8) bool {
    const errDir = error{File_FolderNotFound, };
    const cDIR = std.fs.cwd().openDir(vdir,.{}) catch {@panic(@errorName(errDir.File_FolderNotFound));};
    
    cDIR.access(fn_file_name, .{.mode = .read_write}) catch |err|
        switch (err) {
            error.FileNotFound => return false,
            error.PermissionDenied => return false,
            else => { return false;} ,
        };

    return true;
}

pub fn open(vdir : []const u8, name: []const u8) !Database {
    const errDir = error{File_FolderNotFound, };
    const cDIR = std.fs.cwd().openDir(vdir,.{}) catch {@panic(@errorName(errDir.File_FolderNotFound));};
    
    const allocator = std.heap.c_allocator;
    const path_dir = try cDIR.realpathAlloc(allocator, ".");
    defer allocator.free(path_dir);

    const path_file = try std.fs.path.joinZ(allocator, &.{ path_dir, name });
    defer allocator.free(path_file);

    return try Database.open(.{ .path = path_file });
}


pub fn openTmp(tDir: std.fs.Dir, name: []const u8) !Database {
    
    const allocator = std.heap.c_allocator;
    const path_dir = try tDir.realpathAlloc(allocator, ".");
    defer allocator.free(path_dir);

    const path_file = try std.fs.path.joinZ(allocator, &.{ path_dir, name });
    defer allocator.free(path_file);

    return try Database.open(.{ .path = path_file });
}
//=========================================================
//=========================================================

pub const Database = struct {
    pub const Mode = enum { ReadWrite, ReadOnly };

    pub const Options = struct {
        path: ?[*:0]const u8 = null,
        mode: Mode = .ReadWrite,
        create: bool = true,
    };

    ptr: ?*c.sqlite3,

    pub fn open(options: Options) !Database {
        var ptr: ?*c.sqlite3 = null;

        var flags: c_int = 0;
        switch (options.mode) {
            .ReadOnly => {
                flags |= c.SQLITE_OPEN_READONLY;
            },
            .ReadWrite => {
                flags |= c.SQLITE_OPEN_READWRITE;
                if (options.create and options.path != null) {
                    flags |= c.SQLITE_OPEN_CREATE;
                }
            },
        }

        try throw(c.sqlite3_open_v2(options.path, &ptr, flags, null));

        return .{ .ptr = ptr };
    }

    /// Must not be in WAL mode. Returns a read-only in-memory database.
    pub fn import(data: []const u8) !Database {
        const db = try Database.open(.{ .mode = .ReadOnly });
        const ptr: [*]u8 = @constCast(data.ptr);
        const len: c_longlong = @intCast(data.len);
        const flags = c.SQLITE_DESERIALIZE_READONLY;
        try throw(c.sqlite3_deserialize(db.ptr, "main", ptr, len, len, flags));
        return db;
    }

    pub fn close(db: Database) void {
            throw(c.sqlite3_close_v2(db.ptr)) catch |err| {
            const msg = c.sqlite3_errmsg(db.ptr);
            std.debug.panic("sqlite3_close_v2: {s} {s}", .{ @errorName(err), msg });
        };
    }

    pub fn prepare(db: Database, comptime Params: type, comptime Result: type, sql: []const u8)
                    !Statement(Params, Result) {
        return try Statement(Params, Result).prepare(db, sql);
    }

    pub fn exec(db: Database, sql: []const u8, params: anytype) !void {
        const stmt = try Statement(@TypeOf(params), void).prepare(db, sql);
        defer stmt.finalize();

        try stmt.exec(params);
    }

    pub fn istable(db: Database, sqltbl: []const u8) ! bool  {

        const allocsql = std.heap.page_allocator;
        const sqlTable = try std.fmt.allocPrint(allocsql,
            "SELECT count(*) as count FROM  sqlite_master WHERE type='table' AND name = \"{s}\"",.{sqltbl});
        defer allocsql.free(sqlTable);

        const Result = struct { count: usize };
        const select = try db.prepare(struct {}, Result, sqlTable);
        defer select.finalize();

        try select.bind(.{});

        defer select.reset();

        while (try select.step()) | testx| {
            if(testx.count > 0) return true;
        }
        return false;
    }
};

pub fn Statement(comptime Params: type, comptime Result: type) type {
    const param_bindings = switch (@typeInfo(Params)) {
        .@"struct" => |info| Binding.parseStruct(info),
        else => @compileError("Params type must be a struct"),
    };

    const column_bindings = switch (@typeInfo(Result)) {
        .void => .{},
        .@"struct" => |info| Binding.parseStruct(info),
        else => @compileError("Result type must be a struct or void"),
    };

    const param_count = param_bindings.len;
    const column_count = column_bindings.len;
    const placeholder: c_int = -1;

    return struct {
        const Self = @This();

        ptr: ?*c.sqlite3_stmt = null,
        param_index_map: [param_count]c_int = .{placeholder} ** param_count,
        column_index_map: [column_count]c_int = .{placeholder} ** column_count,

        pub fn prepare(db: Database, sql: []const u8) !Self {
            var stmt = Self{};

                try throw(c.sqlite3_prepare_v2(db.ptr, sql.ptr, @intCast(sql.len), &stmt.ptr, null));
            errdefer throw(c.sqlite3_finalize(stmt.ptr)) catch |err| {
                const msg = c.sqlite3_errmsg(db.ptr);
                std.debug.panic("sqlite3_finalize: {s} {s}", .{ @errorName(err), msg });
            };

            // Populate stmt.param_index_map
            {
                const count = c.sqlite3_bind_parameter_count(stmt.ptr);

                var idx: c_int = 1;
                params: while (idx <= count) : (idx += 1) {
                    const parameter_name = c.sqlite3_bind_parameter_name(stmt.ptr, idx);
                    if (parameter_name == null) {
                        return error.InvalidParameter;
                    }

                    const name = std.mem.span(parameter_name);
                    if (name.len == 0) {
                        return error.InvalidParameter;
                    } else switch (name[0]) {
                        ':', '$', '@' => {},
                        else => return error.InvalidParameter,
                    }

                    inline for (param_bindings, 0..) |binding, i| {
                        if (std.mem.eql(u8, binding.name, name[1..])) {
                            if (stmt.param_index_map[i] == placeholder) {
                                stmt.param_index_map[i] = idx;
                                continue :params;
                            } else {
                                return error.DuplicateParameter;
                            }
                        }
                    }

                    return error.MissingParameter;
                }
            }

            // Populate stmt.column_index_map
            {
                const count = c.sqlite3_column_count(stmt.ptr);

                var n: c_int = 0;
                columns: while (n < count) : (n += 1) {
                    const column_name = c.sqlite3_column_name(stmt.ptr, n);
                    if (column_name == null) {
                        return error.OutOfMemory;
                    }

                    const name = std.mem.span(column_name);

                    inline for (column_bindings, 0..) |binding, i| {
                        if (std.mem.eql(u8, binding.name, name)) {
                            if (stmt.column_index_map[i] == placeholder) {
                                stmt.column_index_map[i] = n;
                                continue :columns;
                            } else {
                                return error.DuplicateColumn;
                            }
                        }
                    }
                }

                for (stmt.column_index_map) |i| {
                    if (i == placeholder) {
                        return error.MissingColumn;
                    }
                }
            }

            return stmt;
        }

        
        pub fn finalize(stmt: Self) void {
                throw(c.sqlite3_finalize(stmt.ptr)) catch |err| {
                const db = c.sqlite3_db_handle(stmt.ptr);
                const msg = c.sqlite3_errmsg(db);
                std.debug.panic("sqlite3_finalize: {s} {s}", .{ @errorName(err), msg });
            };
        }

        pub fn reset(stmt: Self) void {
                throw(c.sqlite3_reset(stmt.ptr)) catch |err| {
                const msg = c.sqlite3_errmsg(c.sqlite3_db_handle(stmt.ptr));
                std.debug.panic("sqlite3_reset: {s} {s}", .{ @errorName(err), msg });
            };

                throw(c.sqlite3_clear_bindings(stmt.ptr)) catch |err| {
                const msg = c.sqlite3_errmsg(c.sqlite3_db_handle(stmt.ptr));
                std.debug.panic("sqlite3_clear_bindings: {s} {s}", .{ @errorName(err), msg });
            };
        }

        pub fn exec(stmt: Self, params: Params) !void {
            switch (@typeInfo(Result)) {
                .void => {},
                else => @compileError("only void Result types can call .exec"),
            }

            try stmt.bind(params);
            defer stmt.reset();
            try stmt.step() orelse {};
        }

        pub fn step(stmt: Self) !?Result {
            switch (c.sqlite3_step(stmt.ptr)) {
                c.SQLITE_ROW => return try stmt.row(),
                c.SQLITE_DONE => return null,
                else => |code| {
                    // sqlite3_reset returns the same code we already have
                    const rc = c.sqlite3_reset(stmt.ptr);
                    if (rc == code) {
                        return getError(code);
                    } else {
                        const err = getError(rc);
                        const msg = c.sqlite3_errmsg(c.sqlite3_db_handle(stmt.ptr));
                        std.debug.panic("sqlite3_reset: {s} {s}", .{ @errorName(err), msg });
                    }
                },
            }
        }

        pub fn bind(stmt: Self, params: Params) !void {
            inline for (param_bindings, 0..) |binding, i| {
                const idx = stmt.param_index_map[i];
                if (binding.nullable) {
                    if (@field(params, binding.name)) |value| {
                        switch (binding.type) {
                            .int32 => try stmt.bindInt32(idx, @intCast(value)),
                            .int64 => try stmt.bindInt64(idx, @intCast(value)),
                            .float64 => try stmt.bindFloat64(idx, @floatCast(value)),
                            .blob => try stmt.bindBlob(idx, value),
                            .text => try stmt.bindText(idx, value),
                            .numeric => try stmt.bindNumeric(idx, value),
                            .date => try stmt.bindDate(idx, value),
                            .boolean => try stmt.bindBoolean(idx, value),
                        }
                    } else {
                        try stmt.bindNull(idx);
                    }
                } else {
                    const value = @field(params, binding.name);
                    switch (binding.type) {
                        .int32 => try stmt.bindInt32(idx, @intCast(value)),
                        .int64 => try stmt.bindInt64(idx, @intCast(value)),
                        .float64 => try stmt.bindFloat64(idx, @floatCast(value)),
                        .blob => try stmt.bindBlob(idx, value),
                        .text => try stmt.bindText(idx, value),
                        .numeric => try stmt.bindNumeric(idx, value),
                        .date => try stmt.bindDate(idx, value),
                        .boolean => try stmt.bindBoolean(idx, value),
                    }
                }
            }
        }

        fn bindNull(stmt: Self, idx: c_int) !void {
            try throw(c.sqlite3_bind_null(stmt.ptr, idx));
        }

        fn bindInt32(stmt: Self, idx: c_int, value: i32) !void {
            try throw(c.sqlite3_bind_int(stmt.ptr, idx, value));
        }

        fn bindInt64(stmt: Self, idx: c_int, value: i64) !void {
            try throw(c.sqlite3_bind_int64(stmt.ptr, idx, value));
        }

        fn bindFloat64(stmt: Self, idx: c_int, value: f64) !void {
            try throw(c.sqlite3_bind_double(stmt.ptr, idx, value));
        }

        fn bindBlob(stmt: Self, idx: c_int, value: Blob) !void {
            const ptr = value.data.ptr;
            const len = value.data.len;
            try throw(c.sqlite3_bind_blob64(stmt.ptr, idx, ptr, @intCast(len), c.SQLITE_STATIC));
        }

        fn bindText(stmt: Self, idx: c_int, value: Text) !void {
            const ptr = value.data.ptr;
            const len = value.data.len;
            try throw(c.sqlite3_bind_text64(stmt.ptr, idx, ptr, @intCast(len), c.SQLITE_STATIC, c.SQLITE_UTF8));
        }
        
        fn bindNumeric(stmt: Self, idx: c_int, value: Numeric) !void {
 
            const ptr = value.data.ptr;
            const len = value.data.len;
            try throw(c.sqlite3_bind_text64(stmt.ptr, idx, ptr, @intCast(len), c.SQLITE_STATIC, c.SQLITE_UTF8));
        }

        
        fn bindDate(stmt: Self, idx: c_int, value: Date) !void {
            const ptr = value.data.ptr;
            const len = value.data.len;
            try throw(c.sqlite3_bind_text64(stmt.ptr, idx, ptr, @intCast(len), c.SQLITE_STATIC, c.SQLITE_UTF8));
        }

        fn bindBoolean(stmt: Self, idx: c_int, value: Bool) !void {
            var val:i32 = 0;
            if (value.data == true) val =1;
             try throw(c.sqlite3_bind_int(stmt.ptr, idx, val));
        }


        fn row(stmt: Self) !Result {
            var result: Result = undefined;

            inline for (column_bindings, 0..) |binding, i| {
                const n = stmt.column_index_map[i];
                switch (c.sqlite3_column_type(stmt.ptr, n)) {
                    c.SQLITE_NULL => if (binding.nullable or binding.type == .date
                                    or binding.type == .text or binding.type == .numeric) {
                        if ( binding.type == .date or binding.type == .text or binding.type == .numeric){
                            switch (binding.type) {
                                .date => @field(result, binding.name) = stmt.columnDate(n),
                                .text => @field(result, binding.name) = stmt.columnText(n),
                                .numeric =>@field(result, binding.name) = stmt.columnNumeric(n),
                                else =>.{},
                            }
                        } else @field(result, binding.name) = null;
                        
                     } else {
                        return error.InvalidColumnType;
                    },

                    c.SQLITE_INTEGER => switch (binding.type) {
                        .int32 => |info| {
                            const value = stmt.columnInt32(n);
                            switch (info.signedness) {
                                .signed => {},
                                .unsigned => {
                                    if (value < 0) {
                                        return error.IntegerOutOfRange;
                                    }
                                },
                            }

                            @field(result, binding.name) = @intCast(value);
                        },
                        .int64 => |info| {
                            const value = stmt.columnInt64(n);
                            switch (info.signedness) {
                                .signed => {},
                                .unsigned => {
                                    if (value < 0) {
                                        return error.IntegerOutOfRange;
                                    }
                                },
                            }

                            @field(result, binding.name) = @intCast(value);
                        },
                         .boolean =>@field(result, binding.name) = stmt.columnBoolean(n),
                         .numeric =>@field(result, binding.name) = stmt.columnNumeric(n),
                        else => return error.InvalidColumnType,
                    },

                    c.SQLITE_FLOAT => switch (binding.type) {
                        .numeric =>@field(result, binding.name) = stmt.columnNumeric(n),
                        .float64 =>@field(result, binding.name) = @floatCast(stmt.columnFloat64(n)),
                         else => return error.InvalidColumnType,
                    },

                    c.SQLITE_BLOB => switch (binding.type) {
                        .blob => @field(result, binding.name) = stmt.columnBlob(n),
                        else => return error.InvalidColumnType,
                    },

                    c.SQLITE_TEXT => switch (binding.type) {
                        .text => @field(result, binding.name) = stmt.columnText(n),
                        .numeric =>@field(result, binding.name) = stmt.columnNumeric(n),
                        .date =>@field(result, binding.name) = stmt.columnDate(n),
                        else => return error.InvalidColumnType,
                    },
                  
                    else => @panic("internal SQLite error"),
                }
            }

            return result;
        }

        fn columnInt32(stmt: Self, n: c_int) i32 {
            return c.sqlite3_column_int(stmt.ptr, n);
        }

        fn columnInt64(stmt: Self, n: c_int) i64 {
            return c.sqlite3_column_int64(stmt.ptr, n);
        }

        fn columnFloat64(stmt: Self, n: c_int) f64 {
            return c.sqlite3_column_double(stmt.ptr, n);
        }

        fn columnBlob(stmt: Self, n: c_int) Blob {
            const ptr: [*]const u8 = @ptrCast(c.sqlite3_column_blob(stmt.ptr, n));
            const len = c.sqlite3_column_bytes(stmt.ptr, n);
            if (len < 0) {
                @panic("sqlite3_column_bytes: len < 0");
            }

            return blob(ptr[0..@intCast(len)]);
        }

        fn columnText(stmt: Self, n: c_int) Text {
            if (c.SQLITE_NULL == c.sqlite3_column_type(stmt.ptr, n)) {
                var val : Text = undefined;
                val.data =""; return val;
            }
            const ptr: [*]const u8 = @ptrCast(c.sqlite3_column_text(stmt.ptr, n));
            const len = c.sqlite3_column_bytes(stmt.ptr, n);
            if (len < 0) {
                @panic("sqlite3_column_bytes: len < 0");
            }

            return text(ptr[0..@intCast(len)]);
        }
        
        fn columnNumeric(stmt: Self, n: c_int) Numeric {
            if (c.SQLITE_NULL == c.sqlite3_column_type(stmt.ptr, n)) {
                var val : Numeric = undefined;
                val.data =""; return val;
            }
            const ptr: [*]const u8 = @ptrCast(c.sqlite3_column_text(stmt.ptr, n));
            const len = c.sqlite3_column_bytes(stmt.ptr, n);
            if (len < 0) {
                @panic("sqlite3_column_bytes: len < 0");
            }

            return numeric(ptr[0..@intCast(len)]);
        }

        fn columnDate(stmt: Self, n: c_int) Date {
            if (c.SQLITE_NULL == c.sqlite3_column_type(stmt.ptr, n)) {
                var val : Date = undefined;
                val.data =""; return val;
            }
            const ptr: [*]const u8 = @ptrCast(c.sqlite3_column_text(stmt.ptr, n));
            const len = c.sqlite3_column_bytes(stmt.ptr, n);
            if (len < 0) {
                @panic("sqlite3_column_bytes: len < 0");
            }

            return date(ptr[0..@intCast(len)]);
        }

        
        fn columnBoolean(stmt: Self, n: c_int) Bool {
            var valBool : Bool = undefined;
            if(c.sqlite3_column_int(stmt.ptr, n) == 1) valBool.data = true else valBool.data = false;
            return valBool;   
        }
    };
}

const Binding = struct {
    pub const TypeTag = enum {
        int32,
        int64,
        float64,
        blob,
        text,
        numeric,
        date,
        boolean,
    };

    pub const Type = union(TypeTag) {
        int32: std.builtin.Type.Int,
        int64: std.builtin.Type.Int,
        float64: std.builtin.Type.Float,
        blob: void,
        text: void,
        numeric: void,
        date:void,
        boolean:void,
        
        pub fn parse(comptime T: type) Type {
            return switch (T) {
                Blob => .{ .blob = {} },
                Text => .{ .text = {} },
                Numeric => .{ .numeric = {} },
                Date => .{ .date = {} },
                Bool => .{ .boolean ={}},
                
                else => switch (@typeInfo(T)) {
                    .int => |info| switch (info.signedness) {
                        .signed => if (info.bits <= 32) .{ .int32 = info } else .{ .int64 = info },
                        .unsigned => if (info.bits <= 31) .{ .int32 = info } else .{ .int64 = info },
                    },
                    .float => |info| .{ .float64 = info },
                    else => @compileError("invalid binding type"),
                },
            };
        }
    };


    name: []const u8,
    type: Type,
    nullable: bool,

    pub fn parseStruct(comptime info: std.builtin.Type.Struct) [info.fields.len]Binding {
        var bindings: [info.fields.len]Binding = undefined;
        inline for (info.fields, 0..) |field, i| {
            bindings[i] = parseField(field);
        }

        return bindings;
    }

    pub fn parseField(comptime field: std.builtin.Type.StructField) Binding {
        return switch (@typeInfo(field.type)) {
            .optional => |field_type| Binding{
                .name = field.name,
                .type = Type.parse(field_type.child),
                .nullable = true,
            },
            else => Binding{
                .name = field.name,
                .type = Type.parse(field.type),
                .nullable = false,
            },
        };
    }
};
