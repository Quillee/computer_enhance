const std = @import("std");
const utils = @import("utils.zig");
const logger = @import("log/log.zig");
const get_register = utils.get_register;

const InputError = error{
// @dumb: not always even
NonEvenInstructionSet};

const Register = struct {
    width: u8,
    data: usize,
};

fn decode() void {}

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 1) {
        logger.log(logger.LogType.ERROR, "No filename provided");
        return error.NoFilenameProvided;
    }

    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();

    var buffer_reader = std.io.bufferedReader(file.reader());
    var buffer: [2]u8 = undefined;
    while (try buffer_reader.read(&buffer) > 0) {
        var instr = [_]u8{ 0, 0, 0 };
        // 1 0 0 0 1 0 D W = 146
        // 1 0 1 1 R REG   = 176
        //
        std.mem.copy(u8, &instr, switch (buffer[0]) {
            // register to register
            // 136 -> 139
            0b100010_00...0b100010_11 => "mov",
            // immediate to register
            // 176 -> 191
            0b1011_0000...0b1011_1111 => "mov",
            // immediate to memory/register
            // 198 -> 199
            0b1100_0110...0b1100_0111 => "mov",
            else => unreachable,
        });
        const d = (buffer[0] & 0x02) > 0;
        const w = buffer[0] & 0x01;

        const reg = (buffer[1] & 0x38) >> 3;
        const reg_mem = buffer[1] & 0x7;

        const source = get_register(w, if (d) reg else reg_mem);
        const dest = get_register(w, if (d) reg_mem else reg);
        std.debug.print("{s} {s}, {s}\n", .{ instr, source, dest });
    }
}
