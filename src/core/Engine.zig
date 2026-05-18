const std = @import("std");
const c = @import("../c.zig").c;
const windows = @import("../io/path/windows.zig");

const Self = @This();
var handle: [*c]c.struct_HINSTANCE__ = undefined;
const Config = struct {};
pub fn init(config: Config) Self {
    _ = config;
    return .{};
}

pub fn createHandle(this: Self, path: windows.path) anyerror![*c]c.struct_HINSTANCE__ {
    _ = this;
    const windows_handle = c.LoadLibraryExW(path, null, c.LOAD_WITH_ALTERED_SEARCH_PATH);
    if (windows_handle == null) {
        const err = c.GetLastError();
        std.debug.print("LoadLibraryExW failed! Win32 error: {}\n", .{err});
        return error.SystemLibraryNotFound;
    }
    handle = windows_handle;
    return handle;
}
pub fn lookFor(this: Self, name: [:0]const u8) anyerror!c.FARPROC {
    _ = this;
    return c.GetProcAddress(handle, name) orelse return error.DidntFindSymbol;
}
pub fn deinit(this: Self) void {
    _ = this;
    _ = c.FreeLibrary(handle);
}
