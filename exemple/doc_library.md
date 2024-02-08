
        library/
            cursed.zig
            .....x.zig
            library.zig
            build.zig
            build.zig.zon
        src-zig/
            Exemple.zig
            exCallpgm.zig
            buildExemple.zig
            buildexCallpgm.zig
            build.zig.zon



"library": is a directory that contains all the zig files and functions as the underlying engine. It includes a function named "build", along with "build.zig.zon" and "library.zig" files.


Particularities:

"build",



```
	const forms_mod = b.addModule("forms", .{
		.root_source_file = .{ .path = "forms.zig" },
		.imports= &.{
		.{ .name = "cursed", .module = cursed_mod },
		.{ .name = "utils",  .module = utils_mod},
		.{ .name = "match",  .module = match_mod },
		},
	});
```


addModule (do not use CreateModule)
import (do not use dependency)


If you have libraries written in "C"


```
	match_mod.addIncludePath(.{.path = "./lib/"});
	match_mod.link_libc = true;
	match_mod.addObjectFile(.{.cwd_relative = "/usr/lib/libpcre2-posix.so"});
```

The file "build.zig.zon" is required, it remains in its most basic form.< /br>
< /br>
```
.{
	.name = "library",
	.version = "0.0.0",
	.dependencies = .{},
	.paths = .{
		"",
	},
}
```

The file "library.zig" contains all the modules that form your library. Its particularity is to make the constant linked to the import "pub".


```
pub const cursed    = @import("cursed");
pub const utils     = @import("utils");
pub const match     = @import("match");
pub const forms     = @import("forms");
pub const grid      = @import("grid");
pub const menu      = @import("menu");
pub const callpgm   = @import("callpgm");
```

_________________________________________________________

Now, the program part:


In the "src-zig" directory:

The "build.zig.zon" file is mandatory,


```
.{
	.name = "program",
	.version = "0.0.0",
	.dependencies = .{
		.library = .{
			.path = "../library",
		},
	},
	.paths = .{
		"",
	},
}
```


The "buildExample" file:

```
const std = @import("std");
// zig 0.12.0 dev

pub fn build(b: *std.Build) void {
	// Standard release options allow the person running `zig build` to select
	// between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
	const target   = b.standardTargetOptions(.{});
	const optimize = b.standardOptimizeOption(.{});

	// Building the executable

	const Prog = b.addExecutable(.{
	.name = "Example",
	.root_source_file = .{ .path = "./Example.zig" },
	.target = target,
	.optimize = optimize,
	});

	// Resolve the 'library' dependency.
	const library_dep = b.dependency("library", .{});

	// Import the smaller 'cursed' and 'utils' modules exported by the library. etc...
	Prog.root_module.addImport("cursed", library_dep.module("cursed"));
	Prog.root_module.addImport("utils", library_dep.module("utils"));
	Prog.root_module.addImport("match", library_dep.module("match"));
	Prog.root_module.addImport("forms", library_dep.module("forms"));
	Prog.root_module.addImport("grid",  library_dep.module("grid"));
	Prog.root_module.addImport("menu", library_dep.module("menu"));
	Prog.root_module.addImport("callpgm", library_dep.module("callpgm"));

	b.installArtifact(Prog);
}
```

The peculiarity:

To resolve the dependencies, we need to indicate how:


```
const library_dep = b.dependency("library", .{});
```

"library" with its "path" it will fetch and build the object it needs to be linked to your program.
Then, you can declare and connect your modules:



```
Prog.root_module.addImport("cursed", library_dep.module("cursed"))
```

Your program will work as if it were compiled with the sources, for exemple:


```
const term = import(cursed);
const kbd = @import("cursed").kbd;
```

_____________________________________________________________

To compile source files within your "src-zig" directory, which may contain multiple sources such as client, invoice, delivery note, etc., it is simpler to use "--build-file" instead of "build", which allows you to have independent build files.

Here's the command you can use:

```
zig build --build-file /home/soleil/exemple/src-zig/buildExemple.zig

```

