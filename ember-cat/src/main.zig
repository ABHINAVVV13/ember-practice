const std = @import("std");
const helper = @import("helpers.zig");

const ember_cat = @import("ember_cat");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);

    if (args.len < 2) {
        try helper.printTerminal(io, "usage: ember-cat <path>\n", .{});
        return error.MissingArgument;
    }
    var path: []const u8 = args[1];

    const isAbsolute = std.Io.Dir.path.isAbsolute(path);
    if (!isAbsolute) {
        const cwd_path = try std.process.currentPathAlloc(io, gpa);
        defer gpa.free(cwd_path);
        path = try std.Io.Dir.path.resolve(gpa, &.{ cwd_path, path });
    }

    defer if (!isAbsolute) gpa.free(path);

    const file_data = try helper.readFileContents(io, path, gpa);
    try helper.printTerminal(io, "Size of the file is: {d} bytes\n{s}\n", .{ file_data.file_size, file_data.file_contents });
    defer gpa.free(file_data.file_contents);
}
