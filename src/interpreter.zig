const std = @import("std");

const max_size: usize = 32_768;

pub const Errors = error{ UnbalancedOpeningBracket, UnbalancedClosingBracket, OutOfMemory, IOError };

pub const Interpreter = struct {
    memory: [max_size]u8,
    instruction_pointer: usize,
    memory_pointer: usize,
    source: []const u8,

    brackets: std.AutoHashMap(usize, usize),
    trace_brackets: std.ArrayList(usize),

    allocator: *std.mem.Allocator,
    pub fn init(self: *Interpreter, source_code: []const u8, allocator: *std.mem.Allocator) Errors!void {
        self.memory_pointer = max_size / 2;
        self.instruction_pointer = 0;
        self.source = source_code;
        self.allocator = allocator;
        @memset(&self.memory, 0);

        self.brackets = std.AutoHashMap(usize, usize).init(allocator.*);
        self.trace_brackets = try std.ArrayList(usize).initCapacity(allocator.*, 32);
    }

    pub fn deinit(self: *Interpreter) void {
        self.trace_brackets.deinit(self.allocator.*);
        // self.allocator.free(self.brackets);
        self.brackets.deinit();
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

    fn takeInput(self: *Interpreter) Errors!void {
        const stdin = std.fs.File.stdin();

        var buf: [1]u8 = undefined;

        const n = stdin.read(&buf) catch return Errors.IOError;
        if (n == 0) {
            return Errors.IOError;
        }
        var byte = buf[0];

        // Windows CR (13) → LF (10)
        if (byte == 13) {
            byte = 10;
        }

        self.memory[self.memory_pointer] = byte;
    }

    fn sourceBracketsTrace(self: *Interpreter) Errors!void {
        self.instruction_pointer = 0;
        while (self.instruction_pointer < self.source.len) : (self.instruction_pointer += 1) {
            const c = self.source[self.instruction_pointer];
            switch (c) {
                '[' => try self.trace_brackets.append(self.allocator.*, self.instruction_pointer),
                ']' => {
                    const popped = self.trace_brackets.pop() orelse return Errors.UnbalancedClosingBracket;
                    try self.brackets.put(popped, self.instruction_pointer);
                    try self.brackets.put(self.instruction_pointer, popped);
                },
                else => {},
            }
        }

        if (self.trace_brackets.items.len != 0)
            return Errors.UnbalancedOpeningBracket;
    }

    fn advance(self: *Interpreter) void {
        self.instruction_pointer += 1;
    }

    pub fn setSource(self: *Interpreter, source_code: []const u8) Errors!void {
        self.source = source_code;

        self.brackets.clearRetainingCapacity();
        self.trace_brackets.clearRetainingCapacity();

        // Compute brackets when source is set instead of at run time
        self.resetInstructionPointer();
        try self.sourceBracketsTrace();
        self.resetInstructionPointer();
    }

    pub fn interpret(self: *Interpreter) Errors!void {
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
                ',' => {
                    try self.takeInput();
                },
                '[' => {
                    if (self.memory[self.memory_pointer] == 0) {
                        const jump_to = self.brackets.get(self.instruction_pointer) orelse return Errors.UnbalancedOpeningBracket;
                        self.instruction_pointer = jump_to;
                    }
                },
                ']' => {
                    if (self.memory[self.memory_pointer] != 0) {
                        const jump_to = self.brackets.get(self.instruction_pointer) orelse return Errors.UnbalancedClosingBracket;
                        self.instruction_pointer = jump_to;
                    }
                },
                else => {},
            }

            // self.instruction_pointer += 1;
            self.advance();
        }
    }
};
