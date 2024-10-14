const builtin = @import("builtin");
const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // STB Image library
    const stbi = b.dependency("stb_image_zig", .{ .target = target, .optimize = optimize });

    // Example application using libstb-image
    const exe = b.addExecutable(.{
        .name = "stb_image_zig_test",
        .root_source_file = b.path("main.zig"),
        .version = .{ .major = 0, .minor = 1, .patch = 0 },
        .optimize = optimize,
        .target = target,
    });

    exe.root_module.addImport("stb_image", stbi.module("stb_image"));
    b.installArtifact(exe);

    const app_run = b.addRunArtifact(exe);
    app_run.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        app_run.addArgs(args);
    }

    // Run the application
    const run = b.step("run", "Run the demo application");
    run.dependOn(&app_run.step);
}
