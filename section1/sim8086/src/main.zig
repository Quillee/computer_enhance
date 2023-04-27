const std = @import("std");

const InputError = error {
    // @dumb: not always even
    NonEvenInstructionSet
};

const LogType = enum {
    DEBUG,
    INFO,
    WARN,
    ERROR,
};

fn get_register(width: u8, register:  usize) @TypeOf("AX") {
    if (width == 1) {
        return switch(register) {
            1 => "ax",
            2 => "cx",
            3 => "dx",
            4 => "bx",
            5 => "sp",
            6 => "bp",
            7 => "si",
            8 => "di",
            else => unreachable
        };
    } else {
        return switch(register) {
            1 => "al",
            2 => "cl",
            3 => "dl",
            4 => "bl",
            5 => "ah",
            6 => "bh",
            7 => "dh",
            8 => "bh",
            else => unreachable
        };
    }
}

fn log(log_type: LogType, message: []u8) void {
    const now = std.time.Timer.now();
    switch(log_type) {
        LogType.DEBUG => std.debug.print("[DEBUG] {any} > {s}", .{ now, message }),
        LogType.INFO => std.debug.print("[INFO] {any} > {s}", .{ now, message}),
        LogType.WARN => std.debug.print("[WARN] {any} > {s}", .{ now, message }),
        LogType.ERROR => std.debug.print("[ERR] {any} > {s}", .{ now, message }),
        else => std.debug.print("[CRITICAL] {any} | Log type provided doesn't exist > {s}", .{now, message})
    }
}

pub fn main() anyerror!void {
    const file = try std.fs.cwd().openFile("instructions/input", .{});
    defer file.close();

    var buffer_reader = file.reader();
    var buffer = try buffer_reader.readBoundedBytes(2);
    while (buffer.len > 0) {
        var instr = [_]u8{ 0, 0, 0 };
        std.debug.print("Foo: {b}, Baz: {b:>8}, Boo: {any}\n\n", .{ buffer.get(0) & 0xFC, buffer.get(0) & 0b111111_0_0, buffer });
        std.mem.copy(u8, &instr, switch (buffer.get(0) & 0xFC) {
            0b100001_00, 60 => "mov",
            else => unreachable,
        });
        const d = (buffer.get(0) & 0x02) > 0;
        const w = buffer.get(0) & 0x01;

        // 11000000
        // const mod = buffer[1] & 0xC0;
        // 00111000
        const reg = (buffer.get(1) & 0x38) >> 3;
        // 00000111
        const reg_mem = buffer.get(1) & 0x7;

        const source = get_register(w, if (d) reg else reg_mem);
        const dest = get_register(w, if (d) reg_mem else reg);
        std.debug.print("{s} {s}, {s}\n", .{ instr, source, dest });
        buffer = try buffer_reader.readBoundedBytes(2);
    }
}

