const std = @import("std");
const exts = @import("../core/constants.zig").LibraryExtensions;

pub fn parseArgs(args: []const [:0]const u8) void {
    for (args) |arg| {
        if (std.mem.endsWith(u8, arg, exts.windows)) {
            std.debug.print("this is a DLL\n", .{});
        }
    }
}
