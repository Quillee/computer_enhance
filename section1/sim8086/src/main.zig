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
            0 => "ax",
            1 => "cx",
            2 => "dx",
            3 => "bx",
            4 => "sp",
            5 => "bp",
            6 => "si",
            7 => "di",
            else => unreachable
        };
    } else {
        return switch(register) {
            0 => "al",
            1 => "cl",
            2 => "dl",
            3 => "bl",
            4 => "ah",
            5 => "ch",
            6 => "dh",
            7 => "bh",
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
    const file = try std.fs.cwd().openFile("instructions/listing_0038_many_register_mov", .{});
    defer file.close();

    var buffer_reader = std.io.bufferedReader(file.reader());
    var buffer: [2]u8 = undefined;
    while (try buffer_reader.read(&buffer) > 0) {
        var instr = [_]u8{ 0, 0, 0 };
        //std.debug.print("Foo: {b}, Baz: {b:>8}, Boo: {any}\n\n", .{ buffer[0] & 0xFC, buffer[0] & 0b111111_0_0, buffer });
        std.mem.copy(u8, &instr, switch (buffer[0] & 0xFC) {
            0b100010_00 => "mov",
            else => unreachable,
        });
        const d = (buffer[0] & 0x02) > 0;
        const w = buffer[0] & 0x01;

        // 11000000
        // const mod = buffer[1] & 0xC0;
        // 00111000
        const reg = (buffer[1] & 0x38) >> 3;
        // 00000111
        const reg_mem = buffer[1] & 0x7;

        const source = get_register(w, if (d) reg else reg_mem);
        const dest = get_register(w, if (d) reg_mem else reg);
        std.debug.print("{s} {s}, {s}\n", .{ instr, source, dest });
    }
}

