const std = @import("std");
const c = @cImport({
    @cInclude("windows.h");
});
const pathf = @import("io/path/windows.zig");
const cli = @import("cli/args.zig");
pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const path = "zig-out\\dynamic\\Dynamic.dll";
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    const cwd = std.Io.Dir.cwd();
    const cwd_path = try cwd.realPathFileAlloc(io, ".", allocator);
    defer allocator.free(cwd_path);
    const abs = try std.fs.path.resolve(allocator, &.{ cwd_path, path });
    defer allocator.free(abs);
    const args = try init.minimal.args.toSlice(allocator);
    // skip the firt argument because its the path of the exe
    cli.parseArgs(args[1..]);
    var buff: [std.fs.max_path_bytes:0]u16 = undefined;
    const path_w = try pathf.form(path, &buff);
    const handle = c.LoadLibraryExW(path_w, null, c.LOAD_WITH_ALTERED_SEARCH_PATH);
    if (handle == null) {
        const err = c.GetLastError();

        std.debug.print("LoadLibraryExW failed! Win32 error: {}\n", .{err});
        return error.SystemLibraryNotFound;
    }
    defer _ = c.FreeLibrary(handle);

    const add_ptr = c.GetProcAddress(handle, "add") orelse return error.DidntFindSymbol;
    const add_fn = *const fn (a: i32, b: i32) callconv(.c) i32;
    const add = @as(add_fn, @ptrCast(add_ptr));
    std.debug.print("1+4: {}\n", .{add(1, 6)});
}
