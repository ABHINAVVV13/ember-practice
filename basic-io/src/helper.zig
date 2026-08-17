const std = @import("std");

const fileData = struct {
    file_contents: []const u8,
    file_size: usize,
};

fn requireAbsolute(path: []const u8) !void {
    if (!std.Io.Dir.path.isAbsolute(path)) return error.PathNotAbsolute;
}

pub fn printTerminal(io: std.Io, comptime string: []const u8, args: anytype) !void {
    const bufferType = [1024]u8;
    var stdout_buffer: bufferType = undefined;
    var std_writer = std.Io.File.stdout().writer(io, &stdout_buffer);
    const writer = &std_writer.interface;

    try writer.print(string, args);
    try writer.flush();
}

pub fn readFileContents(io: std.Io, absolute_path: []const u8, gpa: std.mem.Allocator) !fileData {
    try requireAbsolute(absolute_path);
    const file_contents = try std.Io.Dir.cwd().readFileAlloc(io, absolute_path, gpa, .limited(100 * 1024 * 1024));
    return .{ .file_contents = file_contents, .file_size = file_contents.len };
}

pub fn getFileSize(io: std.Io, absolute_path: []const u8) !u64 {
    try requireAbsolute(absolute_path);
    const metadata = try std.Io.Dir.cwd().statFile(io, absolute_path, .{});
    return metadata.size;
}

pub fn createEmptyFile(io: std.Io, absolute_path: []const u8) !void {
    try requireAbsolute(absolute_path);
    const file = try std.Io.Dir.createFileAbsolute(io, absolute_path, .{ .exclusive = true });
    defer file.close(io);
}

pub fn saveFile(io: std.Io, absolute_dir_path: []const u8, filename: []const u8, contents: []const u8) !void {
    try requireAbsolute(absolute_dir_path);
    const dir = try std.Io.Dir.openDirAbsolute(io, absolute_dir_path, .{});
    defer dir.close(io);

    var atomic_file = try dir.createFileAtomic(io, filename, .{ .replace = true });
    defer atomic_file.deinit(io);

    var buffer: [4 * 1024]u8 = undefined;
    var file_writer = atomic_file.file.writer(io, &buffer);
    const writer = &file_writer.interface;

    try writer.writeAll(contents);
    try writer.flush();
    try atomic_file.replace(io);
}

pub fn rename(io: std.Io, old_absolute_path: []const u8, new_absolute_path: []const u8) !void {
    try requireAbsolute(old_absolute_path);
    try requireAbsolute(new_absolute_path);
    try std.Io.Dir.renameAbsolute(old_absolute_path, new_absolute_path, io);
}

pub fn deleteFile(io: std.Io, absolute_path: []const u8) !void {
    try requireAbsolute(absolute_path);
    try std.Io.Dir.deleteFileAbsolute(io, absolute_path);
}

pub fn createDirectory(io: std.Io, absolute_path: []const u8) !void {
    try requireAbsolute(absolute_path);
    try std.Io.Dir.createDirAbsolute(io, absolute_path, .default_dir);
}

pub fn listFilesInDir(io: std.Io, absolute_dir_path: []const u8) !void {
    try requireAbsolute(absolute_dir_path);
    const dir = try std.Io.Dir.openDirAbsolute(io, absolute_dir_path, .{ .iterate = true });
    defer dir.close(io);

    var it = dir.iterate();
    while (try it.next(io)) |entry| {
        try printTerminal(io, "{s}\n", .{entry.name});
    }
}

pub fn walkFilesInDir(io: std.Io, absolute_dir_path: []const u8, gpa: std.mem.Allocator) !void {
    try requireAbsolute(absolute_dir_path);
    const dir = try std.Io.Dir.openDirAbsolute(io, absolute_dir_path, .{ .access_sub_paths = true, .iterate = true });

    var walker = try dir.walk(gpa);

    while (try walker.next(io)) |entry| {
        try printTerminal(io, "{s}\n", .{entry.path});
    }

    walker.deinit();
    dir.close(io);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///                                                                   Tests
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

const testing = std.testing;

/// Absolute path of `tmp.dir`. Caller owns the result.
fn tmpAbsPath(tmp: *testing.TmpDir, gpa: std.mem.Allocator) ![]u8 {
    var buffer: [std.Io.Dir.max_path_bytes]u8 = undefined;
    const len = try tmp.dir.realPath(testing.io, &buffer);
    return gpa.dupe(u8, buffer[0..len]);
}

test "requireAbsolute rejects relative paths" {
    const io = testing.io;
    try testing.expectError(error.PathNotAbsolute, createEmptyFile(io, "relative.txt"));
    try testing.expectError(error.PathNotAbsolute, getFileSize(io, "./relative.txt"));
    try testing.expectError(error.PathNotAbsolute, deleteFile(io, "../relative.txt"));
    try testing.expectError(error.PathNotAbsolute, createDirectory(io, "sub/dir"));
    try testing.expectError(error.PathNotAbsolute, listFilesInDir(io, "sub"));
}

test "printTerminal formats arguments" {
    try printTerminal(testing.io, "test {s} {d}\n", .{ "ok", 42 });
}

test "createEmptyFile creates an empty file and rejects duplicates" {
    const io = testing.io;
    const gpa = testing.allocator;

    var tmp = testing.tmpDir(.{});
    defer tmp.cleanup();

    const dir_path = try tmpAbsPath(&tmp, gpa);
    defer gpa.free(dir_path);

    const file_path = try std.Io.Dir.path.join(gpa, &.{ dir_path, "empty.txt" });
    defer gpa.free(file_path);

    try createEmptyFile(io, file_path);
    try testing.expectEqual(@as(u64, 0), try getFileSize(io, file_path));

    try testing.expectError(error.PathAlreadyExists, createEmptyFile(io, file_path));
}

test "saveFile writes contents and readFileContents reads them back" {
    const io = testing.io;
    const gpa = testing.allocator;

    var tmp = testing.tmpDir(.{});
    defer tmp.cleanup();

    const dir_path = try tmpAbsPath(&tmp, gpa);
    defer gpa.free(dir_path);

    try saveFile(io, dir_path, "notes.txt", "hello ember");

    const file_path = try std.Io.Dir.path.join(gpa, &.{ dir_path, "notes.txt" });
    defer gpa.free(file_path);

    const data = try readFileContents(io, file_path, gpa);
    defer gpa.free(data.file_contents);

    try testing.expectEqualStrings("hello ember", data.file_contents);
    try testing.expectEqual(@as(usize, 11), data.file_size);
    try testing.expectEqual(@as(u64, 11), try getFileSize(io, file_path));
}

test "saveFile replaces existing contents" {
    const io = testing.io;
    const gpa = testing.allocator;

    var tmp = testing.tmpDir(.{});
    defer tmp.cleanup();

    const dir_path = try tmpAbsPath(&tmp, gpa);
    defer gpa.free(dir_path);

    try saveFile(io, dir_path, "notes.txt", "first version");
    try saveFile(io, dir_path, "notes.txt", "second");

    const file_path = try std.Io.Dir.path.join(gpa, &.{ dir_path, "notes.txt" });
    defer gpa.free(file_path);

    const data = try readFileContents(io, file_path, gpa);
    defer gpa.free(data.file_contents);

    try testing.expectEqualStrings("second", data.file_contents);
}

test "rename moves a file to a new name" {
    const io = testing.io;
    const gpa = testing.allocator;

    var tmp = testing.tmpDir(.{});
    defer tmp.cleanup();

    const dir_path = try tmpAbsPath(&tmp, gpa);
    defer gpa.free(dir_path);

    try saveFile(io, dir_path, "old.txt", "payload");

    const old_path = try std.Io.Dir.path.join(gpa, &.{ dir_path, "old.txt" });
    defer gpa.free(old_path);
    const new_path = try std.Io.Dir.path.join(gpa, &.{ dir_path, "new.txt" });
    defer gpa.free(new_path);

    try rename(io, old_path, new_path);

    try testing.expectError(error.FileNotFound, getFileSize(io, old_path));

    const data = try readFileContents(io, new_path, gpa);
    defer gpa.free(data.file_contents);
    try testing.expectEqualStrings("payload", data.file_contents);
}

test "deleteFile removes a file" {
    const io = testing.io;
    const gpa = testing.allocator;

    var tmp = testing.tmpDir(.{});
    defer tmp.cleanup();

    const dir_path = try tmpAbsPath(&tmp, gpa);
    defer gpa.free(dir_path);

    try saveFile(io, dir_path, "doomed.txt", "bye");

    const file_path = try std.Io.Dir.path.join(gpa, &.{ dir_path, "doomed.txt" });
    defer gpa.free(file_path);

    try deleteFile(io, file_path);
    try testing.expectError(error.FileNotFound, getFileSize(io, file_path));
    try testing.expectError(error.FileNotFound, deleteFile(io, file_path));
}

test "createDirectory creates a directory" {
    const io = testing.io;
    const gpa = testing.allocator;

    var tmp = testing.tmpDir(.{});
    defer tmp.cleanup();

    const dir_path = try tmpAbsPath(&tmp, gpa);
    defer gpa.free(dir_path);

    const sub_path = try std.Io.Dir.path.join(gpa, &.{ dir_path, "created" });
    defer gpa.free(sub_path);

    try createDirectory(io, sub_path);

    const stat = try std.Io.Dir.cwd().statFile(io, sub_path, .{});
    try testing.expectEqual(std.Io.File.Kind.directory, stat.kind);

    try testing.expectError(error.PathAlreadyExists, createDirectory(io, sub_path));
}

test "listFilesInDir walks the top level only" {
    const io = testing.io;
    const gpa = testing.allocator;

    var tmp = testing.tmpDir(.{});
    defer tmp.cleanup();

    const dir_path = try tmpAbsPath(&tmp, gpa);
    defer gpa.free(dir_path);

    try saveFile(io, dir_path, "top.txt", "a");
    try listFilesInDir(io, dir_path);

    const missing = try std.Io.Dir.path.join(gpa, &.{ dir_path, "missing" });
    defer gpa.free(missing);
    try testing.expectError(error.FileNotFound, listFilesInDir(io, missing));
}

test "walkFilesInDir descends into subdirectories" {
    const io = testing.io;
    const gpa = testing.allocator;

    var tmp = testing.tmpDir(.{});
    defer tmp.cleanup();

    const dir_path = try tmpAbsPath(&tmp, gpa);
    defer gpa.free(dir_path);

    const nested = try std.Io.Dir.path.join(gpa, &.{ dir_path, "nested" });
    defer gpa.free(nested);

    try createDirectory(io, nested);
    try saveFile(io, dir_path, "top.txt", "a");
    try saveFile(io, nested, "deep.txt", "b");

    try walkFilesInDir(io, dir_path, gpa);
}
