const builtin = @import("builtin");
const std = @import("std");

const CFlags = &[_][]const u8{"-fPIC"};

pub fn build(b: *std.Build) !void {
    comptime {
        const current_zig = builtin.zig_version;
        const min_zig = std.SemanticVersion.parse("0.13.0") catch unreachable;
        if (current_zig.order(min_zig) == .lt) {
            @compileError(std.fmt.comptimePrint("Your Zig version v{} does not meet the minimum build requirement of v{}", .{
                current_zig,
                min_zig,
            }));
        }
    }

    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    _ = b.addModule("root", .{
        .root_source_file = b.path("src/stb_image.zig"),
    });

    const stb_image_lib = b.addStaticLibrary(.{
        .name = "stb_image",
        .target = target,
        .optimize = optimize,
    });
    stb_image_lib.addIncludePath(b.path("include/stb"));
    if (optimize == .Debug) {
        // TODO: Workaround for Zig bug.
        stb_image_lib.addCSourceFile(.{
            .file = b.path("src/stb_image.c"),
            .flags = &.{
                "-std=c99",
                "-fno-sanitize=undefined",
                "-g",
                "-O0",
            },
        });
    } else {
        stb_image_lib.addCSourceFile(.{
            .file = b.path("src/stb_image.c"),
            .flags = &.{
                "-std=c99",
                "-fno-sanitize=undefined",
            },
        });
    }
    stb_image_lib.linkLibC();
    b.installArtifact(stb_image_lib);

    const test_step = b.step("test", "Run stb_image tests");

    const tests = b.addTest(.{
        .name = "stb_image-tests",
        .root_source_file = b.path("src/stb_image.zig"),
        .target = target,
        .optimize = optimize,
    });
    tests.linkLibrary(stb_image_lib);
    b.installArtifact(tests);

    test_step.dependOn(&b.addRunArtifact(tests).step);
}
