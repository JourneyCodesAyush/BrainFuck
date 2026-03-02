const std = @import("std");

const max_size: usize = 32_768;

pub const Interpreter = struct {
    memory: [max_size]u8,
    instruction_pointer: usize,
    memory_pointer: usize,
    source: []const u8,

    pub fn init(self: *Interpreter, source_code: []const u8) void {
        self.memory_pointer = max_size / 2;
        self.instruction_pointer = 0;
        self.source = source_code;

        @memset(&self.memory, 0);
    }

    fn decrementMemoryPointer(self: *Interpreter) void {
        if (self.memory_pointer == 0)
            self.memory_pointer = max_size - 1
        else
            self.memory_pointer -= 1;
    }

    fn incrementMemoryPointer(self: *Interpreter) void {
        if (self.memory_pointer == max_size - 1)
            self.memory_pointer = 0
        else
            self.memory_pointer += 1;
    }

    fn incrementMemoryValue(self: *Interpreter) void {
        self.memory[self.memory_pointer] +%= 1;
    }

    fn decrementMemoryValue(self: *Interpreter) void {
        self.memory[self.memory_pointer] -%= 1;
    }

    fn resetInstructionPointer(self: *Interpreter) void {
        self.instruction_pointer = 0;
    }

    fn advance(self: *Interpreter) void {
        self.instruction_pointer += 1;
    }

    pub fn interpret(self: *Interpreter) void {
        self.resetInstructionPointer();

        while (self.instruction_pointer < self.source.len) {
            const instruction = self.source[self.instruction_pointer];

            switch (instruction) {
                '>' => self.incrementMemoryPointer(),
                '<' => self.decrementMemoryPointer(),
                '+' => self.incrementMemoryValue(),
                '-' => self.decrementMemoryValue(),
                '.' => std.debug.print("{c}", .{
                    self.memory[self.memory_pointer],
                }),
                else => {},
            }

            self.advance();
        }
    }
};
