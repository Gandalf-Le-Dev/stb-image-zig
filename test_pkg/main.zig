const std = @import("std");
const stb = @import("stb_image");

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const stdout = std.io.getStdOut().writer();

// Sample PNG image to be loaded directly in-memory
const sample_png_name = "zig-zero.png";
const sample_png = @embedFile(sample_png_name);

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    var image = try stb.load_image(sample_png_name, null);
    defer image.deinit();
    std.debug.print("Image: {s}\n", .{sample_png_name});
    std.debug.print("Got image of size {d}x{d} with {d} channels\n", .{ image.width, image.height, image.nchan });
}
