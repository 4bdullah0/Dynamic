const std = @import("std");
const c = @import("c.zig").c;
const pathf = @import("io/path/windows.zig");
const cli = @import("cli/args.zig");
const engine = @import("core/Engine.zig");
pub fn main(init: std.process.Init) !void {
    const io = init.io;

    var stdout_buff: [1024]u8 = undefined;
    var stdout_file_writer = std.Io.File.Writer.init(std.Io.File.stdout(), io, &stdout_buff);
    const stdout_writer = &stdout_file_writer.interface;

    var stdin_buff: [1024]u8 = undefined;
    var stdin = std.Io.File.stdin();
    var stdin_file_reader = stdin.reader(io, &stdin_buff);
    var reader = &stdin_file_reader.interface;
    const line = try reader.takeDelimiterExclusive('\n');

    try stdout_writer.print("Hello World! {s}\n", .{line});
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
    const eng = engine.init(.{});
    defer eng.deinit();
    _ = try eng.createHandle(path_w);
    const add_ptr = try eng.lookFor("add");
    const add_fn = *const fn (a: i32, b: i32) callconv(.c) i32;
    const add = @as(add_fn, @ptrCast(add_ptr));
    std.debug.print("1+4: {}\n", .{add(1, 6)});
    try stdout_writer.flush();
}
