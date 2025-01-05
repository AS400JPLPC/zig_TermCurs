    ///-----------------------
    /// build Gencurs
    /// zig 0.13.0 dev
    ///-----------------------

const std = @import("std");


pub fn build(b: *std.Build) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const target   = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});


    // ===========================================================
    const logger = b.dependency("library", .{}).module("logger");

    const logsrc = b.dependency("library", .{}).module("logsrc");
    const cursed = b.dependency("library", .{}).module("cursed");
    const utils  = b.dependency("library", .{}).module("utils");
    const forms  = b.dependency("library", .{}).module("forms");
    const grid   = b.dependency("library", .{}).module("grid");
    const menu   = b.dependency("library", .{}).module("menu");
    const mvzr   = b.dependency("library", .{}).module("mvzr");


    const srcdef = b.createModule(.{
        .root_source_file = b.path("./srcdef.zig" ),
        .imports= &.{},
    });

    const mdlSjson = b.createModule(.{
        .root_source_file = b.path("./mdlSjson.zig" ),
        .imports= &.{
            .{ .name = "cursed", .module = cursed },
            .{ .name = "utils",  .module = utils },
            .{ .name = "forms",  .module = forms },
            .{ .name = "grid",   .module = grid  },
            .{ .name = "menu",   .module = menu  },
            .{ .name = "mvzr",   .module = mvzr  },
        },
    });


    const mdlRjson = b.createModule(.{
        .root_source_file = b.path( "./mdlRjson.zig" ),
        .imports= &.{
            .{ .name = "cursed", .module = cursed },
            .{ .name = "utils",  .module = utils },
            .{ .name = "forms",  .module = forms },
            .{ .name = "grid",   .module = grid  },
            .{ .name = "menu",   .module = menu  },
            .{ .name = "mvzr",   .module = mvzr  },
        },
    });

    const mdlFile = b.createModule(.{
        .root_source_file = b.path( "./mdlFile.zig" ),
        .imports= &.{
            .{ .name = "logger", .module = logger },
            .{ .name = "cursed", .module = cursed },
            .{ .name = "utils",  .module = utils },
            .{ .name = "forms",  .module = forms },
            .{ .name = "grid",   .module = grid  },
            .{ .name = "menu",   .module = menu  },
            .{ .name = "mvzr",   .module = mvzr  },
            .{ .name = "mdlSjson",  .module = mdlSjson},
            .{ .name = "mdlRjson",  .module = mdlRjson},
        },
    });

    const srcMenu = b.createModule(.{
        .root_source_file = b.path( "./srcMenu.zig" ),
        .imports= &.{
            .{ .name = "logsrc", .module = logsrc },
            .{ .name = "cursed", .module = cursed },
            .{ .name = "utils",  .module = utils },
            .{ .name = "menu",   .module = menu  },
            .{ .name = "srcdef", .module = srcdef  },
        },
    });



    const srcForms = b.createModule(.{
        .root_source_file = b.path( "./srcForms.zig" ),
        .imports= &.{
            .{ .name = "logsrc", .module = logsrc },
            .{ .name = "cursed", .module = cursed },
            .{ .name = "utils",  .module = utils },
            .{ .name = "forms",  .module = forms },
            .{ .name = "grid",   .module = grid  },
            .{ .name = "menu",   .module = menu  },
            .{ .name = "mvzr",   .module = mvzr  },
            .{ .name = "srcdef", .module = srcdef  },
        },
    });
    // Building the executable

    const Prog = b.addExecutable(.{
    .name = "Gensrc",
    .root_source_file = b.path( "./Gensrc.zig" ),
    .target = target,
    .optimize = optimize,
    });


    Prog.root_module.addImport("logsrc" , logsrc);
    
    Prog.root_module.addImport("cursed", cursed);

    Prog.root_module.addImport("utils", utils);

    Prog.root_module.addImport("mvzr", mvzr);
    
    Prog.root_module.addImport("forms", forms);
     
    Prog.root_module.addImport("grid" , grid);
    
    Prog.root_module.addImport("menu" , menu);

    Prog.root_module.addImport("srcdef" , srcdef);



    Prog.root_module.addImport("mdlFile"  , mdlFile);
    Prog.root_module.addImport("srcMenu"  , srcMenu);
    Prog.root_module.addImport("srcForms" , srcForms);


    b.installArtifact(Prog);





}
