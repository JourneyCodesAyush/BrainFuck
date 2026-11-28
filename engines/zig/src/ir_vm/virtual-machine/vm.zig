//! Executes optimized intermediate representation instructions using a fixed-size memory tape.

const std: type = @import("std");
const instruction: type = @import("../instructions/opcode.zig");
const errors = @import("../../errors/error.zig");

/// Number of memory cells available to the virtual machine.
pub const max_size: usize = 32_768;

/// Executes IR instructions while managing memory, control flow, and I/O.
pub const VirtualMachine: type = struct {
    io: std.Io,
    reader: *std.Io.Reader,
    writer: *std.Io.Writer,
    instructions: []instruction.Instructions,
    memory: [max_size]u8,
    ip: usize,
    memory_pointer: usize,

    pub fn init(self: *VirtualMachine, io: std.Io, reader: *std.Io.Reader, writer: *std.Io.Writer) void {
        self.io = io;
        self.reader = reader;
        self.writer = writer;
        self.ip = 0;
        self.memory_pointer = 0;

        @memset(&self.memory, 0);
    }

    pub fn setInstructions(self: *VirtualMachine, instructions: []instruction.Instructions) void {
        self.instructions = instructions;
        self.ip = 0;
        self.memory_pointer = 0;
    }

    inline fn advance(self: *VirtualMachine) void {
        self.ip += 1;
    }

    fn takeInput(self: *VirtualMachine) errors.Errors!void {
        const byte = self.reader.takeByte() catch return errors.Errors.IOError;
        self.memory[self.memory_pointer] = byte;
    }

    /// Executes instructions until the instruction sequence is exhausted.
    pub fn run(self: *VirtualMachine) errors.Errors!void {
        var instr: instruction.Instructions = undefined;
        var advanced: bool = undefined;

        while (self.ip < self.instructions.len) {
            advanced = false;
            instr = self.instructions[self.ip];
            switch (instr.opcode) {
                instruction.OpCode.ADD => {
                    const idx = self.memory_pointer;
                    const cell: i32 = @as(i32, self.memory[idx]) + instr.argument;
                    self.memory[idx] = @intCast(cell & 0xFF);
                },
                instruction.OpCode.MOVE => {
                    const mp: isize = @intCast(self.memory_pointer);
                    const arg: isize = instr.argument;

                    const new_mp = @mod(mp + arg, @as(isize, max_size));

                    self.memory_pointer = @intCast(if (new_mp < 0) new_mp + @as(isize, max_size) else new_mp);
                },
                instruction.OpCode.INPUT => {
                    self.takeInput() catch return errors.Errors.IOError;
                },
                instruction.OpCode.OUTPUT => {
                    self.writer.writeByte(self.memory[self.memory_pointer]) catch return errors.Errors.WriteFailedError;
                },
                instruction.OpCode.JZ => {
                    if (self.memory[self.memory_pointer] == 0) {
                        self.ip = @intCast(instr.argument); // cast to usize
                        advanced = true; // prevent extra advance
                    }
                },
                instruction.OpCode.JNZ => {
                    if (self.memory[self.memory_pointer] != 0) {
                        self.ip = @intCast(instr.argument);
                        advanced = true; // Prevent advancing the instruction pointer after a jump.
                    }
                },
            }

            // Jump instructions update the instruction pointer directly.
            if (!advanced)
                self.advance();
        }
        self.writer.flush() catch return errors.Errors.WriteFailedError;
    }
};
