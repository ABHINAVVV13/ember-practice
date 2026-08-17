const std = @import("std");
const helper = @import("helper.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;
    const path: []const u8 = "../README.md";

    const file_data = try helper.readFileContents(io, gpa, path);
    try helper.printTerminal(io, "Size of the file is: {d} bytes\n{s}\n", .{ file_data.file_size, file_data.file_contents });

    gpa.free(file_data.file_contents);
}
