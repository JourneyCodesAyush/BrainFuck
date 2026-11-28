//! Defines the instruction set used by the IR virtual machine.

/// Operations supported by the virtual machine.
pub const OpCode: type = enum {
    ADD,
    MOVE,
    INPUT,
    OUTPUT,
    JZ,
    JNZ,
};

/// Represents an instruction with an opcode and its associated argument.
pub const Instructions: type = struct { opcode: OpCode, argument: i32 };
