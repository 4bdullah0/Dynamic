const std = @import("std");
const exts = @import("../core/constants.zig").LibraryExtensions;

pub fn parseArgs(args: []const [:0]const u8) void {
    for (args) |arg| {
        if (std.mem.endsWith(u8, arg, exts.windows)) {
            std.debug.print("this is a windows dynamic linked library\n", .{});
        } else if (std.mem.endsWith(u8, arg, exts.linux)) {
            std.debug.print("this is a linux shared object\n", .{});
        } else if (std.mem.endsWith(u8, arg, exts.mac)) {
            std.debug.print("this is a macos dynamic library\n", .{});
        }
    }
}
