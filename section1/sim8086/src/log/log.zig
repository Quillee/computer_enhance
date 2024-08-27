const std = @import("std");

pub const LogType = enum {
    DEBUG,
    INFO,
    WARN,
    ERROR,
};

pub fn log(log_type: LogType, message: []const u8) void {
    switch (log_type) {
        LogType.DEBUG => std.debug.print("[DEBUG] > {s}", .{message}),
        LogType.INFO => std.debug.print("[INFO] {s}", .{message}),
        LogType.WARN => std.debug.print("[WARN] {s}", .{message}),
        LogType.ERROR => std.debug.print("[ERR] {s}", .{message}),
        // else => std.debug.print("[CRITICAL] | Log type provided doesn't exist > {s}", .{message}),
    }
}
