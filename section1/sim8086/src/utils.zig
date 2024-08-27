// @todo: move to register module
pub fn get_register(word: u8, register: usize) @TypeOf("AX") {
    if (word == 1) {
        return switch (register) {
            0b000 => "ax",
            0b001 => "cx",
            0b010 => "dx",
            0b011 => "bx",
            0b100 => "sp",
            0b101 => "bp",
            0b110 => "si",
            0b111 => "di",
            else => unreachable,
        };
    } else {
        return switch (register) {
            0b000 => "al",
            0b001 => "cl",
            0b010 => "dl",
            0b011 => "bl",
            0b100 => "ah",
            0b101 => "ch",
            0b110 => "dh",
            0b111 => "bh",
            else => unreachable,
        };
    }
}
