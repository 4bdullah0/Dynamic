const std = @import("std");
const err = @import("errors.zig").WindowsError;

///this forms and creates a windows encoded path from a normal string
///use it always when dealing the windows calls that accpets paths
///the returned slice is slightly optmized to return needed bytes only
pub fn form(path_utf8: []const u8, out_buffer: *[std.fs.max_path_bytes:0]u16) anyerror![:0]u16 {
    const len = try std.unicode.utf8ToUtf16Le(out_buffer, path_utf8);
    out_buffer[len] = 0;
    return out_buffer[0..len :0]; //Nice (:
}
