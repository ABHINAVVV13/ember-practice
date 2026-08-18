const std = @import("std");
const helpers = @import("helpers.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;
    const arena = init.arena.allocator();

    const args = try init.minimal.args.toSlice(arena);

    var case_insensitive = false;
    var pattern: ?[]const u8 = null;
    var paths: std.ArrayList([]const u8) = .empty;
    errdefer paths.deinit(arena);

    for (args[1..]) |arg| {
        if (std.mem.eql(u8, arg, "-i")) {
            case_insensitive = true;
        } else if (pattern == null) {
            pattern = arg;
        } else {
            try paths.append(arena, arg);
        }
    }

    if (pattern == null or paths.items.len == 0) return error.MissingArgument;

    try helpers.grep(io, gpa, pattern.?, paths.items, .{ .case_insensitive = case_insensitive });
}
