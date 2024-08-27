const std = @import("std");
const Tuple = std.meta.Tuple;
const get_register = @import("../utils.zig").get_register;
const RegisterName = @TypeOf("AX");

pub const OpcodeWithOffset = Tuple(&.{ Opcode, usize });

const DecoderErrors = error{
    EmptyBuffer,
    InvalidLength,
    InvalidPayload,
};

const Opcode = struct {
    instruction: []u8,
    source_reg: RegisterName,
    dest_reg: RegisterName,
    displacement_low: u8,
    displacement_high: u8,
    w: u1,
    d: u1,
};

fn handle_single_bit(bit: u1) u8 {
    return bit;
}

pub fn decode(buffer: []u8, pos: usize) DecoderErrors!OpcodeWithOffset {
    if (buffer.len < 1) {
        return DecoderErrors.EmptyBuffer;
    }
    var next_pos = pos + 1;

    var opcode: Opcode = undefined;
    std.mem.copy(Opcode, &opcode, switch (buffer[pos]) {
        // register to register
        // 136 -> 139
        0b100010_00...0b100010_11 => {
            const dest_bit = handle_single_bit(buffer[pos] >> 1);
            const word_bit = handle_single_bit(buffer[pos]);

            const reg = (buffer[pos + 1] & 0x38) >> 3;
            const reg_mem = buffer[pos + 1] & 0x7;
            Opcode{
                .instruction = "mov",
                .source_reg = get_register(word_bit, if (dest_bit) reg else reg_mem),
                .dest_reg = get_register(word_bit, if (dest_bit) reg_mem else reg),
                .displacement_low = 0,
                .displacement_high = 0,
                // d=1 means that the register is the desination, otherwise it is the source
                // shift bits to the right by 1 to get the value of d
                .d = handle_single_bit(buffer[pos] >> 1),
                // w=1 means that the register is 16 bits, otherwise it is 8 bits
                .w = handle_single_bit(buffer[pos]),
            };
        },
        // immediate to register
        // 176 -> 191
        0b1011_0000...0b1011_1111 => "mov",
        // immediate to memory/register
        // 198 -> 199
        0b1100_0110...0b1100_0111 => "mov",
        // accumulator to memory/register
        // 80
        0b10100100 => "mov",
        // memory/register to accumulator
        // 81
        0b101001_01 => "mov",
        else => unreachable,
    });
}

test "decode opcode into Opcode structure" {
    const simple_example = [_]u8{ 0b100010_00, 0b00000000 };
    const pos: usize = 0;
    const opcode = decode(simple_example[0..], pos);
    const expected = Opcode{
        .instruction = "mov",
        .source_reg = "ch",
        .dest_reg = "bh",
        .displacement_low = 0,
        .displacement_high = 0,
        .w = 0,
        .d = 0,
    };
    std.testing.expect(opcode == expected);

    const d_example = [_]u8{ 0b100010_10, 0b00000000 };
    const pos2: usize = 0;
    const opcode2 = decode(d_example[0..], pos2);
    const expected2 = Opcode{
        .instruction = "mov",
        .source_reg = "bl",
        .dest_reg = "cl",
        .displacement_low = 0,
        .displacement_high = 0,
        .w = 0,
        .d = 1,
    };
    std.debug.print("opcode2: {any}\n", opcode2);
    std.testing.expect(opcode2 == expected2);

    const dw_example = [_]u8{ 0b100010_11, 0b00000000 };
    const pos3: usize = 0;
    const opcode3 = decode(dw_example[0..], pos3);
    const expected3 = Opcode{
        .instruction = "mov",
        .source_reg = "dx",
        .dest_reg = "ax",
        .displacement_low = 0,
        .displacement_high = 0,
        .w = 1,
        .d = 1,
    };
    std.testing.expect(opcode3 == expected3);
}
