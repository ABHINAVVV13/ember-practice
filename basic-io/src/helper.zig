const std = @import("std");

const fileData = struct {
    file_contents: []const u8,
    file_size: usize,
};

pub fn printTerminal(io: std.Io, comptime string: []const u8, args: anytype) !void {
    const bufferType = [1024]u8;
    var stdout_buffer: bufferType = undefined;
    var std_writer = std.Io.File.stdout().writer(io, &stdout_buffer);
    const writer = &std_writer.interface;

    try writer.print(string, args);
    try writer.flush();
}

pub fn readFileContents(io: std.Io, gpa: std.mem.Allocator, comptime path: []const u8) !fileData {
    const file_contents = try std.Io.Dir.cwd().readFileAlloc(io, path, gpa, .limited(100 * 1024 * 1024));
    const data = fileData{ .file_contents = file_contents, .file_size = file_contents.len };
    return data;
}

pub fn getFileSize(io: std.Io, comptime path: []const u8) !u64 {
    const metadata = try std.Io.Dir.cwd().statFile(io, path, .{});
    return metadata.size;
}
