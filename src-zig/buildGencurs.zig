///-----------------------
/// build Gencurs
/// zig 0.13.0 dev
///-----------------------

const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const target   = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});


    // ===========================================================
    const logger    = b.dependency("libtui", .{}).module("logger");
    const alloc    = b.dependency("libtui", .{}).module("alloc");
    const cursed   = b.dependency("libtui", .{}).module("cursed");
    const utils    = b.dependency("libtui", .{}).module("utils");
    const forms    = b.dependency("libtui", .{}).module("forms");
    const grid     = b.dependency("libtui", .{}).module("grid");
    const menu     = b.dependency("libtui", .{}).module("menu");
    const mvzr     = b.dependency("libtui", .{}).module("mvzr");

        
    const mdlPanel = b.createModule(.{
        .root_source_file = b.path( "./mdlPanel.zig" ),
        .imports= &.{
            .{ .name = "alloc",    .module = alloc},
            .{ .name = "cursed",   .module = cursed},
            .{ .name = "utils",    .module = utils },
            .{ .name = "forms",    .module = forms },
            .{ .name = "grid",     .module = grid  },
            .{ .name = "menu",     .module = menu  },
            .{ .name = "mvzr",     .module = mvzr  },
        },
    });    

        const mdlForms = b.createModule(.{
        .root_source_file = b.path( "./mdlForms.zig" ),
        .imports= &.{
            .{ .name = "alloc",    .module = alloc},
            .{ .name = "cursed",   .module = cursed},
            .{ .name = "utils",    .module = utils },
            .{ .name = "forms",    .module = forms },
            .{ .name = "grid",     .module = grid  },
            .{ .name = "menu",     .module = menu  },
            .{ .name = "mvzr",     .module = mvzr  },
        },
    });

     const mdlGrids = b.createModule(.{
         .root_source_file = b.path( "./mdlGrids.zig" ),
         .imports= &.{
            .{ .name = "alloc",    .module = alloc},
            .{ .name = "cursed",   .module = cursed},
            .{ .name = "utils",    .module = utils },
            .{ .name = "forms",    .module = forms },
            .{ .name = "grid",     .module = grid  },
            .{ .name = "menu",     .module = menu  },
            .{ .name = "mvzr",     .module = mvzr  },
         },
     });

    const mdlMenus = b.createModule(.{
         .root_source_file = b.path( "./mdlMenus.zig" ),
         .imports= &.{
            .{ .name = "alloc",    .module = alloc},
            .{ .name = "cursed",   .module = cursed},
            .{ .name = "utils",    .module = utils },
            .{ .name = "forms",    .module = forms },
            .{ .name = "grid",     .module = grid  },
            .{ .name = "menu",     .module = menu  },
            .{ .name = "mvzr",     .module = mvzr  },

         },
     });
     
    const mdlSjson = b.createModule(.{
        .root_source_file = b.path("./mdlSjson.zig" ),
        .imports= &.{
            .{ .name = "alloc",    .module = alloc},
            .{ .name = "cursed",   .module = cursed},
            .{ .name = "utils",    .module = utils },
            .{ .name = "forms",    .module = forms },
            .{ .name = "grid",     .module = grid  },
            .{ .name = "menu",     .module = menu  },
            .{ .name = "mvzr",     .module = mvzr  },

        },
    });


    const mdlRjson = b.createModule(.{
        .root_source_file = b.path( "./mdlRjson.zig" ),
        .imports= &.{
            .{ .name = "alloc",    .module = alloc},
            .{ .name = "cursed",   .module = cursed},
            .{ .name = "utils",    .module = utils },
            .{ .name = "forms",    .module = forms },
            .{ .name = "grid",     .module = grid  },
            .{ .name = "menu",     .module = menu  },
            .{ .name = "mvzr",     .module = mvzr  },
        },
    });

    const mdlFile = b.createModule(.{
        .root_source_file = b.path( "./mdlFile.zig" ),
        .imports= &.{
            .{ .name = "alloc",    .module = alloc},
            .{ .name = "cursed",   .module = cursed},
            .{ .name = "utils",    .module = utils },
            .{ .name = "forms",    .module = forms },
            .{ .name = "grid",     .module = grid  },
            .{ .name = "menu",     .module = menu  },
            .{ .name = "mvzr",     .module = mvzr  },

            .{ .name = "mdlSjson",  .module = mdlSjson},
            .{ .name = "mdlRjson",  .module = mdlRjson},
        },
    });



    // Building the executable

    const Prog = b.addExecutable(.{
        .name = "Gencurs",
        .root_module = b.createModule(.{
            .root_source_file = b.path( "./Gencurs.zig" ),
            .target = target,
            .optimize = optimize,
        }),    
    });


    // Resolve the 'library' dependency.
    // const library_dep = b.dependency("library", .{});

    Prog.root_module.addImport("alloc", alloc);
    
    Prog.root_module.addImport("cursed", cursed);

    Prog.root_module.addImport("utils", utils);

    Prog.root_module.addImport("mvzr", mvzr);
    
    Prog.root_module.addImport("forms", forms);
     
    Prog.root_module.addImport("grid" , grid);
    
    Prog.root_module.addImport("menu" , menu);

    
    Prog.root_module.addImport("mdlPanel" , mdlPanel);

    Prog.root_module.addImport("mdlForms" , mdlForms);

    Prog.root_module.addImport("mdlFile"  , mdlFile);

    Prog.root_module.addImport("mdlGrids" , mdlGrids);

    Prog.root_module.addImport("mdlMenus" , mdlMenus);

    Prog.root_module.addImport("logger"   , logger);

    b.installArtifact(Prog);

    
    
  const docs = b.addTest(.{
        .name = "Gencurs",
        .root_module = b.createModule(.{
            .root_source_file = b.path( "./Gencurs.zig" ),
            .target = target,
            .optimize = optimize,
        }),
    });
  

    docs.root_module.addImport("alloc", alloc);
    
    docs.root_module.addImport("cursed", cursed);

    docs.root_module.addImport("utils", utils);

    docs.root_module.addImport("mvzr", mvzr);
    
    docs.root_module.addImport("forms", forms);
     
    docs.root_module.addImport("grid" , grid);
    
    docs.root_module.addImport("menu" , menu);

    
    docs.root_module.addImport("mdlPanel" , mdlPanel);

    docs.root_module.addImport("mdlForms" , mdlForms);

    docs.root_module.addImport("mdlFile"  , mdlFile);

    docs.root_module.addImport("mdlGrids" , mdlGrids);

    docs.root_module.addImport("mdlMenus" , mdlMenus);

    docs.root_module.addImport("logger"   , logger);

    
    const install_docs = b.addInstallDirectory(.{
        .source_dir = docs.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "../Docs_Gencurs",
    });
    const docs_step = b.step("docs", "Generate docs");
    docs_step.dependOn(&install_docs.step);
    docs_step.dependOn(&docs .step);}
