const std: type = @import("std");
const instruction: type = @import("../instructions/opcode.zig");
const errors = @import("../../errors/error.zig");

pub const max_size: usize = 32_768;

pub const VirtualMachine: type = struct {
    io: std.Io,
    writer: *std.Io.Writer,
    instructions: []instruction.Instructions,
    memory: [max_size]u8,
    ip: usize,
    memory_pointer: usize,

    pub fn init(self: *VirtualMachine, io: std.Io, writer: *std.Io.Writer) void {
        // std.debug.print("Initialize the VM...\n", .{});
        self.io = io;
        self.writer = writer;
        self.ip = 0;
        self.memory_pointer = 0;

        @memset(&self.memory, 0);
    }

    pub fn setInstructions(self: *VirtualMachine, instructions: []instruction.Instructions) void {
        // std.debug.print("Set instructions...\n", .{});
        self.instructions = instructions;
        self.ip = 0;
        self.memory_pointer = 0;
    }

    inline fn advance(self: *VirtualMachine) void {
        self.ip += 1;
    }

    fn takeInput(self: *VirtualMachine) errors.Errors!void {
        var buf: [1]u8 = undefined;
        const stdin = std.Io.File.stdin();
        // std.debug.print("> ", .{});
        // self.writer.print("> ", .{}) catch return errors.Errors.WriteFailedError;

        var rdr = stdin.reader(self.io, &buf);
        const n = rdr.interface.readSliceShort(&buf) catch return errors.Errors.IOError;
        if (n == 0) return errors.Errors.IOError;
        self.memory[self.memory_pointer] = buf[0];
    }

    pub fn run(self: *VirtualMachine) errors.Errors!void {
        var instr: instruction.Instructions = undefined;
        var advanced: bool = undefined;
        // std.debug.print("Running the VM...\n", .{});
        while (self.ip < self.instructions.len) {
            // std.debug.print("Inside the loop running VM..\n", .{});
            advanced = false;
            instr = self.instructions[self.ip];
            // std.debug.print("IP: {d}\n", .{self.ip});
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
                    // std.debug.print("{c}", .{self.memory[self.memory_pointer]});
                    self.writer.print("{c}", .{self.memory[self.memory_pointer]}) catch return errors.Errors.WriteFailedError;
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
                        advanced = true;
                    }
                },
            }

            if (!advanced)
                self.advance();
        }
    }
};
