const std = @import("std");
const instruction = @import("../instructions/opcode.zig");
const errors = @import("../../errors/error.zig");
const max_move: i32 = @import("../virtual-machine/vm.zig").max_size;

pub const Optimizer: type = struct {
    raw: []instruction.Instructions,
    optimized: std.ArrayList(instruction.Instructions) = .empty,
    loop_stack: std.ArrayList(usize) = .empty,

    allocator: std.mem.Allocator,

    pub fn init(self: *Optimizer, allocator: std.mem.Allocator) !void {
        self.allocator = allocator;
        self.optimized = try std.ArrayList(instruction.Instructions).initCapacity(self.allocator, 1024);
        self.loop_stack = try std.ArrayList(usize).initCapacity(self.allocator, 1024);
    }

    pub fn setRaw(self: *Optimizer, raw: []instruction.Instructions) void {
        self.raw = raw;
        self.resetState();
    }

    fn resetState(self: *Optimizer) void {
        self.optimized.clearRetainingCapacity();
        self.loop_stack.clearRetainingCapacity();
    }

    pub fn optimize(self: *Optimizer) errors.Errors![]instruction.Instructions {
        for (self.raw) |curr| {
            if (self.optimized.items.len != 0) {
                const last = self.optimized.items[self.optimized.items.len - 1];

                if (curr.opcode == last.opcode) {
                    if (curr.opcode == instruction.OpCode.ADD) {
                        var sum: i32 = @as(i32, last.argument) + @as(i32, curr.argument);
                        _ = self.optimized.pop();

                        while (sum != 0) {
                            const chunk = std.math.clamp(sum, -127, 127);
                            try self.optimized.append(self.allocator, .{
                                .opcode = instruction.OpCode.ADD,
                                .argument = @intCast(chunk),
                            });
                            sum -= chunk;
                        }
                        continue;
                    } else if (curr.opcode == instruction.OpCode.MOVE) {
                        var sum: i32 = last.argument + curr.argument;
                        _ = self.optimized.pop();

                        while (sum != 0) {
                            const chunk = std.math.clamp(sum, -(max_move - 1), (max_move - 1));
                            try self.optimized.append(self.allocator, .{
                                .opcode = instruction.OpCode.MOVE,
                                .argument = chunk,
                            });
                            sum -= chunk;
                        }
                        continue;
                    }
                }
            }

            try self.optimized.append(self.allocator, curr);
        }

        for (0..self.optimized.items.len) |i| {
            var start_idx: usize = undefined;
            if (self.optimized.items[i].opcode == instruction.OpCode.JZ) {
                try self.loop_stack.append(self.allocator, i);
            } else if (self.optimized.items[i].opcode == instruction.OpCode.JNZ) {
                start_idx = self.loop_stack.pop() orelse return errors.Errors.UnbalancedClosingBracket;
                self.optimized.items[start_idx].argument = @intCast(i);
                self.optimized.items[i].argument = @intCast(start_idx);
            }
        }
        if (self.loop_stack.items.len != 0) {
            return errors.Errors.UnbalancedOpeningBracket;
        }

        return self.optimized.items;
    }

    pub fn deinit(self: *Optimizer) void {
        self.optimized.deinit(self.allocator);
        self.loop_stack.deinit(self.allocator);
    }
};
