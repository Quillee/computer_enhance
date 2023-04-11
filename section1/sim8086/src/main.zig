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
    const file = try std.fs.openFileAbsolute("X:\\home\\courses\\computer_enhance\\section1\\sim8086\\instructions\\input", .{ .mode = std.fs.File.OpenMode.read_write });
    defer file.close();

    var buffer: [100]u8 = undefined;
    var i: usize = 0;
    const bytes_read = try file.readAll(&buffer);
    var instruction_arr = buffer[0..bytes_read];
    if (@rem(instruction_arr.len, @intCast(usize, 2)) == 0) {
        std.debug.print("{d}", .{ @rem(instruction_arr.len, @intCast(usize, 2)) });
        return InputError.NonEvenInstructionSet;
    }

    var decoded_str = "bits 16\n\n";
    const word_registers = [_]u8{ "AX", "CX", "DX", "BX", "SP", "BP", "SI", "DI" };
    const byte_registers = [_]u8{ "AL", "CL", "DL", "BL", "AH", "CH", "DH", "BH" };

    // @dumb: in reality instructions will decide the length of the input
    while (i < instruction_arr.len) : (i += 2) {
        const instruction = buffer[i] & 0xFC;
        switch (instruction) {
            136 => {
                decoded_str += "mov ";
                var registers: []u8 = undefined;
                const d = buffer[i] & 0x02;
                const w = buffer[i] & 0x01;
                // 11000000
                const mod = buffer[i + 1] & 0xC0;
                // 00111000
                const reg = buffer[i + 1] & 0x38;
                // 00000111
                const reg_mem = buffer[i + 1] & 0x7;
                if (mod == 3) {
                    log(LogType.ERROR, "mod provided doesn't represent register to register.\n");
                    break;
                }
                if (d == 1) {

                }
                if (w == 1) {
                    registers = word_registers[0..];
                } else {
                    registers = byte_registers[0..];
                }
                const source = registers[reg];
                const dest = registers[reg_mem];
                std.debug.print("D bit: {d}, w bit: {d}, args: {d} ,source: {s}, dest: {s}", .{ d, w, instruction, source, dest });
            },
            else => std.debug.print("Unknown instruction", .{})
        }
    }
    std.debug.print("File contents {s}\n", .{ instruction_arr });
}

