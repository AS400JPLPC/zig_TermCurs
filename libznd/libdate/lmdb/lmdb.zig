//! Wrapper and utilities for interacting with LMDB.
//! You should start at Environment.

const std = @import("std");
// const testing = std.testing;

const c = @cImport({
    @cInclude("lmdb.h");
});

const log = std.log.scoped(.LMDB);


pub const DirTmp = struct {
    dir: std.fs.Dir,
    parent_dir: std.fs.Dir,
    sub_path: [sub_path_len]u8,

    const random_bytes_count = 12;
    const sub_path_len = std.fs.base64_encoder.calcSize(random_bytes_count);


    pub fn cleanup(self: *DirTmp) void {
        self.dir.close();
        self.parent_dir.deleteTree(&self.sub_path) catch {};
        self.parent_dir.close();
        self.* = undefined;
    }
};


    
    pub fn tmpDir(opts: std.fs.Dir.OpenOptions) DirTmp {
        var random_bytes: [DirTmp.random_bytes_count]u8 = undefined;
        std.crypto.random.bytes(&random_bytes);
        var sub_path: [DirTmp.sub_path_len]u8 = undefined;
        const cwd = std.fs.cwd();
        var cache_dir = cwd.makeOpenPath(".zig-tmp", .{}) catch
                @panic("unable to make tmp dir for testing: unable to make and open .zig-tmp dir");
        defer cache_dir.close();
        const parent_dir = cache_dir.makeOpenPath("tmp", opts) catch
                @panic("unable to make tmp dir for testing: unable to make and open .zig-tmp/tmp dir");
        const dir = parent_dir.makeOpenPath(&sub_path, opts) catch
            @panic("unable to make tmp dir for testing: unable to make and open the tmp dir");
        return .{
           .dir = dir,
           .parent_dir = parent_dir,

           .sub_path = sub_path,
        };
    }    

pub const defDir = struct {
    dir: std.fs.Dir,

    pub fn cleanup(self: *defDir) void {
        self.dir.close();
        self.* = undefined;
   }
};


    pub fn createDir(lib : []const u8) defDir {

        std.fs.cwd().makeDir(lib) catch {
                @panic("unable to make tmp dir for testing: unable to make and open .zig-tmp/tmp dir");
            };
        const path_dir = std.fs.cwd().makeOpenPath(lib,.{}) catch unreachable;
        return .{
           .dir = path_dir,
        };
    }

    pub fn openDir(lib : []const u8) defDir {


        const path_dir = std.fs.cwd().makeOpenPath(lib,.{}) catch {
                @panic("unable to make tmp dir for testing: unable to make and open .zig-tmp/tmp dir");
            };

                
        return .{
           .dir = path_dir,
        };
    }

    pub fn isFile(lib_file : []const u8) bool {
        
        const test_file = std.fs.openFileAbsolute(lib_file,.{}) catch { return false;};
        test_file.close();
        return true;
    }
    
    /// TransactionMode.
    pub const TransactionMode = enum(c_uint) {
        ReadAndWrite = 0,
        ReadOnly = 0x2000,
    };

    /// Options when you open an environment.
    pub const EnvironmentOptions = struct {
        /// Octal code for permissions to the Environment directory.
        dir_mode: u16 = 0o600,
        /// Maximum number of databases on this Environment. Zero means unlimited.
        max_dbs: u32 = 0,
    };

    /// To start using LMDB you need an Environment.
    /// It will wrap LMDB native environment and allow you to open Databases and start Transactions.
    pub const Environment = struct {
        /// Hold a reference to LMDB environment.
        environment: ?*c.MDB_env,

        /// Create and open an environment.
        pub fn init(dir: std.fs.Dir, options: EnvironmentOptions) !@This() {
            var env: ?*c.MDB_env = undefined;
            var r = c.mdb_env_create(&env);
            errdefer c.mdb_env_close(env);
            if (r != 0) {
                log.err("Error creating environment: {s}.", .{c.mdb_strerror(r)});
                return error.CreateEnvError;
            }

            if (options.max_dbs > 0) {
                r = c.mdb_env_set_maxdbs(env, options.max_dbs);
            }
            if (r != 0) {
                log.err("Error setting max dbs: {s}.", .{c.mdb_strerror(r)});
                return error.SetMaxDBsError;
            }

            var buffer: [std.fs.max_path_bytes:0]u8 = undefined;
            const realpath = try dir.realpath(".", &buffer);
            buffer[realpath.len] = 0;

            // TODO: flags
            r = c.mdb_env_open(env, @as([*c]const u8, @ptrCast(&buffer)), 0, options.dir_mode);
            if (r != 0) {
                log.err("Error opening environment: {s}.", .{c.mdb_strerror(r)});
                return error.EnvOpenError;
            }

            return .{
                .environment = env,
            };
        }

        /// Close active Environment.
        pub fn deinit(self: @This()) void {
            c.mdb_env_close(self.environment);
        }

        /// Begin a Transaction on active Environment.
        pub fn beginTransaction(self: @This(), mode: TransactionMode) !Transaction {
            return try Transaction.init(self, mode);
        }

        /// Open a Database on this Environment, already handling initial Transaction.
        pub fn openDatabase(self: @This(), name: ?[]const u8) !Database {
            errdefer self.deinit();
            const tx = try self.beginTransaction(.ReadAndWrite);
            const db = try tx.open(name);
            try tx.commit();
            return db;
        }
    };

    /// Hold a reference to an open Database.
    /// Should be created via Environment.openDatabase or Transaction.openDatabase.
    pub const Database = struct {
        database: c_uint,
        environment: ?*c.MDB_env,

        pub fn deinit(self: @This()) void {
            c.mdb_dbi_close(self.environment, self.database);
        }
    };

    /// Hold an open Transaction.
    /// Can also be created from Environment.beginTransaction.
    pub const Transaction = struct {
        environment: ?*c.MDB_env,
        transaction: ?*c.MDB_txn,

        /// Begin a Transaction with given TransactionMode.
        pub fn init(env: Environment, mode: TransactionMode) !@This() {
            var txn: ?*c.MDB_txn = undefined;
            const r = c.mdb_txn_begin(env.environment, null, @intFromEnum(mode), &txn);
            if (r != 0) {
                log.err("Error trasaction begin: {s}.", .{c.mdb_strerror(r)});
                return error.TransactionBeginError;
            }
            return .{
                .environment = env.environment,
                .transaction = txn,
            };
        }

        /// Open a Database from this Transaction.
        pub fn open(self: @This(), name: ?[]const u8) !Database {
            var dbi: c_uint = undefined;
            var r: c_int = 0;
            // TODO: flags
            if (name) |db| {
                r = c.mdb_dbi_open(self.transaction, @as([*c]const u8, @ptrCast(db)), 0x40000, &dbi);
            } else {
                r = c.mdb_dbi_open(self.transaction, null, 0x40000, &dbi);
            }
            if (r != 0) {
                log.err("Error open database: {s}.", .{c.mdb_strerror(r)});
                return error.DBOpenError;
            }
            const db = Database{
                .environment = self.environment,
                .database = dbi,
            };
            return db;
        }

        /// Utility to work with a Database (already opened) in this Transaction.
        pub fn withDatabase(self: @This(), db: Database) DBTX {
            return DBTX{
                .environment = self.environment,
                .transaction = self.transaction,
                .database = db.database,
            };
        }

        /// Abort Transaction.
        pub fn abort(self: @This()) void {
            c.mdb_txn_abort(self.transaction);
        }

        /// Reset Transaction.
        pub fn reset(self: @This()) void {
            c.mdb_txn_reset(self.transaction);
        }

        /// Renew Transaction.
        pub fn renew(self: @This()) !void {
            const r = c.mdb_txn_renew(self.transaction);
            if (r != 0) {
                log.err("Error transaction renew: {s}.", .{c.mdb_strerror(r)});
                return error.TransactionRenewFailed;
            }
        }

        /// Commit the Transaction.
        pub fn commit(self: @This()) !void {
            const r = c.mdb_txn_commit(self.transaction);
            if (r != 0) {
                log.err("Error transaction commit: {s}.", .{c.mdb_strerror(r)});
                return error.TransactionCommitFailed;
            }
        }
    };

    /// Utility to hold an open Database, in a Transaction.
    /// Create it from Transaction.withDatabase.
    pub const DBTX = struct {
        environment: ?*c.MDB_env,
        transaction: ?*c.MDB_txn,
        database: c_uint,

        /// Get bytes from key.
        pub fn get(self: @This(), key: []const u8) ![]const u8 {
            var k = c.MDB_val{ .mv_size = key.len, .mv_data = @as(?*void, @ptrFromInt(@intFromPtr(key.ptr))) };
            var v: c.MDB_val = undefined;

            const r = c.mdb_get(self.transaction, self.database, &k, &v);
            if (r != 0) {
                if (r == c.MDB_NOTFOUND) {
                    return "";
                } else {
                    log.err("Error get: {s}.", .{c.mdb_strerror(r)});
                    return error.GetError;
                }
            }

            const data = @as([*]const u8, @ptrCast(v.mv_data))[0..v.mv_size];
            return data;
        }

         pub fn getInt32(self: @This(), key: []const u8) !i32 {
            var k = c.MDB_val{ .mv_size = key.len, .mv_data = @as(?*void, @ptrFromInt(@intFromPtr(key.ptr))) };
            var v: c.MDB_val = undefined;

            const r = c.mdb_get(self.transaction, self.database, &k, &v);
            if (r != 0) {
                if (r == c.MDB_NOTFOUND) {
                    return 0;
                } else {
                    log.err("Error get: {s}.", .{c.mdb_strerror(r)});
                    return error.GetError;
                }
            }

            const data = @as([*]const u8, @ptrCast(v.mv_data))[0..v.mv_size];
            const ival = try std.fmt.parseInt(i32, data,10);
            return ival;
        }


         pub fn getInt64(self: @This(), key: []const u8) !i64 {
            var k = c.MDB_val{ .mv_size = key.len, .mv_data = @as(?*void, @ptrFromInt(@intFromPtr(key.ptr))) };
            var v: c.MDB_val = undefined;

            const r = c.mdb_get(self.transaction, self.database, &k, &v);
            if (r != 0) {
                if (r == c.MDB_NOTFOUND) {
                    return 0;
                } else {
                    log.err("Error get: {s}.", .{c.mdb_strerror(r)});
                    return error.GetError;
                }
            }

            const data = @as([*]const u8, @ptrCast(v.mv_data))[0..v.mv_size];
            const ival = try std.fmt.parseInt(i64, data,10);
            return ival;
        }

         pub fn getInt128(self: @This(), key: []const u8) !i128 {
            var k = c.MDB_val{ .mv_size = key.len, .mv_data = @as(?*void, @ptrFromInt(@intFromPtr(key.ptr))) };
            var v: c.MDB_val = undefined;

            const r = c.mdb_get(self.transaction, self.database, &k, &v);
            if (r != 0) {
                if (r == c.MDB_NOTFOUND) {
                    return 0;
                } else {
                    log.err("Error get: {s}.", .{c.mdb_strerror(r)});
                    return error.GetError;
                }
            }

            const data = @as([*]const u8, @ptrCast(v.mv_data))[0..v.mv_size];
            const ival = try std.fmt.parseInt(i128, data,10);
            return ival;
        }

         pub fn getFloat(self: @This(), key: []const u8) !f128 {
            var k = c.MDB_val{ .mv_size = key.len, .mv_data = @as(?*void, @ptrFromInt(@intFromPtr(key.ptr))) };
            var v: c.MDB_val = undefined;

            const r = c.mdb_get(self.transaction, self.database, &k, &v);
            if (r != 0) {
                if (r == c.MDB_NOTFOUND) {
                    return 0;
                } else {
                    log.err("Error get: {s}.", .{c.mdb_strerror(r)});
                    return error.GetError;
                }
            }

            const data = @as([*]const u8, @ptrCast(v.mv_data))[0..v.mv_size];
            const fval = try std.fmt.parseFloat(f128, data);
            return fval;
        }
    

    
        /// Put value on key.
        pub fn put(self: @This(), key: []const u8, value: []const u8) !void {
            var k = c.MDB_val{ .mv_size = key.len, .mv_data = @as(?*void, @ptrFromInt(@intFromPtr(key.ptr))) };
            var v = c.MDB_val{ .mv_size = value.len, .mv_data = @as(?*void, @ptrFromInt(@intFromPtr(value.ptr))) };

            // TODO: flags
            const r = c.mdb_put(self.transaction, self.database, &k, &v, 0);
            if (r != 0) {
                log.err("Error put: {s}.", .{c.mdb_strerror(r)});
                return error.PutError;
            }
        }
        /// Put value on key.
        pub fn putInt32(self: @This(), key: []const u8, ivalue: i32) !void {
            const max_len = 11; // 10 & +  max 10 digit
            var buf: [max_len]u8 = undefined;
            const value = try std.fmt.bufPrint(&buf, "{d}", .{ivalue});
            var k = c.MDB_val{ .mv_size = key.len, .mv_data = @as(?*void, @ptrFromInt(@intFromPtr(key.ptr))) };
            var v = c.MDB_val{ .mv_size = value.len, .mv_data = @as(?*void, @ptrFromInt(@intFromPtr(value.ptr))) };

            // TODO: flags
            const r = c.mdb_put(self.transaction, self.database, &k, &v, 0);
            if (r != 0) {
                log.err("Error put: {s}.", .{c.mdb_strerror(r)});
                return error.PutError;
            }
        }

        /// Put value on key.
        pub fn putInt64(self: @This(), key: []const u8, ivalue: i64) !void {
            const max_len = 20; // 19 & +  max 19 digit
            var buf: [max_len]u8 = undefined;
            const value = try std.fmt.bufPrint(&buf, "{d}", .{ivalue});
            var k = c.MDB_val{ .mv_size = key.len, .mv_data = @as(?*void, @ptrFromInt(@intFromPtr(key.ptr))) };
            var v = c.MDB_val{ .mv_size = value.len, .mv_data = @as(?*void, @ptrFromInt(@intFromPtr(value.ptr))) };

            // TODO: flags
            const r = c.mdb_put(self.transaction, self.database, &k, &v, 0);
            if (r != 0) {
                log.err("Error put: {s}.", .{c.mdb_strerror(r)});
                return error.PutError;
            }
        }

        /// Put value on key.
        pub fn putInt128(self: @This(), key: []const u8, ivalue: i128) !void {
            const max_len = 40;// 39 & + = 40   max 34  digit
            var buf: [max_len]u8 = undefined;
            const value = try std.fmt.bufPrint(&buf, "{d}", .{ivalue});
            var k = c.MDB_val{ .mv_size = key.len, .mv_data = @as(?*void, @ptrFromInt(@intFromPtr(key.ptr))) };
            var v = c.MDB_val{ .mv_size = value.len, .mv_data = @as(?*void, @ptrFromInt(@intFromPtr(value.ptr))) };

            // TODO: flags
            const r = c.mdb_put(self.transaction, self.database, &k, &v, 0);
            if (r != 0) {
                log.err("Error put: {s}.", .{c.mdb_strerror(r)});
                return error.PutError;
            }
        }

        pub fn putFloat(self: @This(), key: []const u8, fvalue: f128) !void {
            const max_len = 40; // 39 & + = 40   max 34 digit
            var buf: [max_len]u8 = undefined;
            const value = try std.fmt.bufPrint(&buf, "{d}", .{fvalue});
            var k = c.MDB_val{ .mv_size = key.len, .mv_data = @as(?*void, @ptrFromInt(@intFromPtr(key.ptr))) };
            var v = c.MDB_val{ .mv_size = value.len, .mv_data = @as(?*void, @ptrFromInt(@intFromPtr(value.ptr))) };

            // TODO: flags
            const r = c.mdb_put(self.transaction, self.database, &k, &v, 0);
            if (r != 0) {
                log.err("Error put: {s}.", .{c.mdb_strerror(r)});
                return error.PutError;
            }
        }   

        /// Delete key.
        pub fn delete(self: @This(), key: []const u8) !void {
            var k = c.MDB_val{ .mv_size = key.len, .mv_data = @as(?*void, @ptrFromInt(@intFromPtr(key.ptr))) };
            var v = c.MDB_val{ .mv_size = 0, .mv_data = null };

            const r = c.mdb_del(self.transaction, self.database, &k, &v);
            if (r != 0) {
                log.err("Error delete: {s}.", .{c.mdb_strerror(r)});
                return error.DeleteError;
            }
        }

        /// Open a Cursor, for iterating over keys.
        pub fn openCursor(self: @This()) !Cursor {
            var cursor: ?*c.MDB_cursor = undefined;
            const r = c.mdb_cursor_open(self.transaction, self.database, &cursor);
            if (r != 0) {
                log.err("Error opening cursor: {s}.", .{c.mdb_strerror(r)});
                return error.CursorOpenError;
            }
            return .{
                .environment = self.environment,
                .transaction = self.transaction,
                .database = self.database,
                .cursor = cursor,
            };
        }
    };

    /// A KeyValue Tuple.
    pub const KV = std.meta.Tuple(&[_]type{ []const u8, []const u8 });

    /// Cursors are used for iterating over a Database.
    /// You can get it from a DBTX.
    pub const Cursor = struct {
        environment: ?*c.MDB_env,
        transaction: ?*c.MDB_txn,
        database: c_uint,
        cursor: ?*c.MDB_cursor,

        /// Return first KeyValue on the cursor.
        pub fn first(self: *@This()) !?KV {
            var k: c.MDB_val = undefined;
            var v: c.MDB_val = undefined;

            const r = c.mdb_cursor_get(self.cursor, &k, &v, c.MDB_FIRST);
            if (r != 0) {
                log.err("Error cursor set: {s}.", .{c.mdb_strerror(r)});
                return error.CursorSetError;
            }

            const key = @as([*]const u8, @ptrCast(k.mv_data))[0..k.mv_size];
            const value = @as([*]const u8, @ptrCast(v.mv_data))[0..v.mv_size];
            return .{ key, value };
        }

        /// Set the cursor at Key position.
        pub fn set(self: *@This(), key: []const u8) !?KV {
            var k = c.MDB_val{ .mv_size = key.len, .mv_data = @as(?*void, @ptrFromInt(@intFromPtr(key.ptr))) };
            var v: c.MDB_val = undefined;

            const r = c.mdb_cursor_get(self.cursor, &k, &v, c.MDB_SET);
            if (r != 0) {
                log.err("Error cursor set: {s}.", .{c.mdb_strerror(r)});
                return error.CursorSetError;
            }

            const value = @as([*]const u8, @ptrCast(v.mv_data))[0..v.mv_size];
            return .{ key, value };
        }

        /// Get next KeyValue and advance the cursor.
        pub fn next(self: *@This()) !?KV {
            var k: c.MDB_val = undefined;
            var v: c.MDB_val = undefined;

            const r = c.mdb_cursor_get(self.cursor, &k, &v, c.MDB_NEXT);
            if (r != 0) {
                if (r == c.MDB_NOTFOUND) {
                    return null;
                } else {
                    log.err("Error cursor next: {s}.", .{c.mdb_strerror(r)});
                    return error.CursorNextError;
                }
            }

            const key = @as([*]const u8, @ptrCast(k.mv_data))[0..k.mv_size];
            const value = @as([*]const u8, @ptrCast(v.mv_data))[0..v.mv_size];
            return .{ key, value };
        }

        pub fn deinit(self: *@This()) void {
            c.mdb_cursor_close(self.cursor);
        }
    };

