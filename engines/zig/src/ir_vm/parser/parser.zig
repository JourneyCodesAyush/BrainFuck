const std: type = @import("std");
const instruction: type = @import("../instructions/opcode.zig");

const errors = @import("../../errors/error.zig");

pub const Parser = struct {
    current: usize,
    source: []const u8,
    array: std.ArrayList(instruction.Instructions),
    loop_stack: std.ArrayList(usize),

    allocator: std.mem.Allocator,

    pub fn init(self: *Parser, source: []const u8, allocator: std.mem.Allocator) !void {
        // std.debug.print("Initializing the parser...\n", .{});
        self.source = source;
        self.allocator = allocator;
        self.current = 0;
        self.array = try std.ArrayList(instruction.Instructions).initCapacity(self.allocator, 1024);
        self.loop_stack = try std.ArrayList(usize).initCapacity(self.allocator, 256);
    }

    pub fn deinit(self: *Parser) void {
        // std.debug.print("Deinitializing the parser...\n", .{});
        self.array.deinit(self.allocator);
        self.loop_stack.deinit(self.allocator);
    }

    pub fn setSource(self: *Parser, source: []const u8) void {
        self.source = source;
        self.current = 0;
    }

    pub fn parse(self: *Parser) errors.Errors![]instruction.Instructions {
        // std.debug.print("Parsing the raw code to IR...\n", .{});
        while (self.current < self.source.len) {
            switch (self.source[self.current]) {
                '+' => {
                    self.array.append(self.allocator, emitByte(instruction.OpCode.ADD, 1)) catch return errors.Errors.ParseError;
                },
                '-' => {
                    self.array.append(self.allocator, emitByte(instruction.OpCode.ADD, -1)) catch return errors.Errors.ParseError;
                },
                '>' => {
                    self.array.append(self.allocator, emitByte(instruction.OpCode.MOVE, 1)) catch return errors.Errors.ParseError;
                },
                '<' => {
                    self.array.append(self.allocator, emitByte(instruction.OpCode.MOVE, -1)) catch return errors.Errors.ParseError;
                },
                '.' => {
                    self.array.append(self.allocator, emitByte(instruction.OpCode.OUTPUT, 0)) catch return errors.Errors.ParseError;
                },
                ',' => {
                    self.array.append(self.allocator, emitByte(instruction.OpCode.INPUT, 0)) catch return errors.Errors.ParseError;
                },
                '[' => {
                    self.loop_stack.append(self.allocator, self.array.items.len) catch return errors.Errors.ParseError;
                    self.array.append(self.allocator, emitByte(instruction.OpCode.JZ, 0)) catch return errors.Errors.ParseError;
                },
                ']' => {
                    const start = self.loop_stack.pop() orelse return errors.Errors.ParseError;
                    self.array.items[start].argument = @intCast(self.array.items.len);
                    self.array.append(self.allocator, emitByte(instruction.OpCode.JNZ, @intCast(start))) catch return errors.Errors.ParseError;
                },
                else => {},
            }
            self.advance();
        }

        return self.array.items;
    }

    fn emitByte(opcode: instruction.OpCode, argument: i32) instruction.Instructions {
        return instruction.Instructions{ .opcode = opcode, .argument = argument };
    }

    fn advance(self: *Parser) void {
        self.current += 1;
    }
};
