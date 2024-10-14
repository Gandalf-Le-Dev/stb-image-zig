const builtin = @import("builtin");
const std = @import("std");

const CFlags = &[_][]const u8{"-fPIC"};

pub fn build(b: *std.Build) !void {
    comptime {
        const current_zig = builtin.zig_version;
        const min_zig = std.SemanticVersion.parse("0.12.0-dev.2030") catch unreachable; // build system changes: ziglang/zig#18160
        if (current_zig.order(min_zig) == .lt) {
            @compileError(std.fmt.comptimePrint("Your Zig version v{} does not meet the minimum build requirement of v{}", .{
                current_zig,
                min_zig,
            }));
        }
    }

    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    ////////////////////////////////////////////////////////////////////////////
    // Create the Zig STB Image Module
    ////////////////////////////////////////////////////////////////////////////

    // Compile the C source file into a static library, and ensure it gets installed
    // along with the required include directory
    const stb = b.addStaticLibrary(.{
        .name = "stb-image",
        .optimize = optimize,
        .target = target,
        .link_libc = true,
    });
    stb.addIncludePath(b.path("include"));
    stb.addCSourceFile(.{ .file = b.path("src/stb_image.c"), .flags = CFlags });
    stb.installHeadersDirectory(b.path("include/stb"), "stb", .{});
    b.installArtifact(stb);

    // Export the 'stb_image' module to downstream packages
    //
    // Much like a CMake target, the libraries and includes attached to this module
    // will apply transitively to the modules of downstream packages, meaning it
    // should "Just Work"
    const mod = b.addModule("stb_image", .{
        .root_source_file = b.path("src/stb_image.zig"),
        .link_libc = true,
    });
    mod.linkLibrary(stb);
}
