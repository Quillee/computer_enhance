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
            1 => "AX",
            2 => "CX",
            3 => "DX",
            4 => "BX",
            5 => "SP",
            6 => "BP",
            7 => "SI",
            8 => "DI",
            else => unreachable
        };
    } else {
        return switch(register) {
            1 => "AL",
            2 => "CL",
            3 => "DL",
            4 => "BL",
            5 => "SH",
            6 => "BH",
            7 => "SH",
            8 => "DH",
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
    // @rewrite: should be relative
    const file = try std.fs.cwd().openFile("instructions/input", .{});
    defer file.close();

    var buffer: [100]u8 = undefined;
    var i: usize = 0;
    const bytes_read = try file.readAll(&buffer);
    var instruction_arr = buffer[0..bytes_read];
    if (@rem(instruction_arr.len, @intCast(usize, 2)) != 0) {
        std.debug.print("{d}", .{ @rem(instruction_arr.len, @intCast(usize, 2)) });
        return InputError.NonEvenInstructionSet;
    }
    std.debug.print("{d}\n\n", .{buffer});

    // @dumb: in reality instructions will decide the length of the input
    while (i < instruction_arr.len) : (i += 2) {
        const instruction = buffer[i] & 0xFC;
        switch (instruction) {
            136 => {
                const d = buffer[i] & 0x02 > 0;
                const w = buffer[i] & 0x01;
                // 11000000
                const mod = buffer[i + 1] & 0xC0;
                // 00111000
                const reg = (buffer[i + 1] & 0x38) >> 3;
                // 00000111
                const reg_mem = buffer[i + 1] & 0x7;
                if (mod == 3) {
                    std.debug.print("[ERR] mod not working", .{});
                    break;
                }

                const source = get_register(w, if (d) reg else reg_mem);
                const dest = get_register(w, if (d) reg_mem else reg);
                // std.debug.print("D bit: {d}, w bit: {d}, args: {d} ,source: {s}, dest: {s}", .{ d, w, instruction, source, dest });
                std.debug.print("mov {s}, {s}\n", .{ source, dest });
            },
            else => std.debug.print("Unknown instruction {d}\n", .{ instruction })
        }
    }
    // std.debug.print("File contents {s}\n", .{ instruction_arr });
}

