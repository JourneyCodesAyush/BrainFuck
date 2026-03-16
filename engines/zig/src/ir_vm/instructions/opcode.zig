pub const OpCode: type = enum {
    ADD,
    MOVE,
    INPUT,
    OUTPUT,
    JZ,
    JNZ,
};

pub const Instructions: type = struct { opcode: OpCode, argument: i32 };
