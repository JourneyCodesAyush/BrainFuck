const std = @import("std");
const interpreter = @import("interpreter.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var intrprt: interpreter.Interpreter = undefined;

    intrprt.init(">++++++++[<+++++++++>-]<.>++++[<+++++++>-]<+.+++++++..+++.>>++++++[<+++++++>-]<++.------------.>++++++[<+++++++++>-]<+.<.+++.------.--------.>>>++++[<++++++++>-]<+.", @constCast(&gpa.allocator())) catch |e| {
        const msg = switch (e) {
            interpreter.Errors.UnbalancedOpeningBracket => "Error: unmatched '['",
            interpreter.Errors.UnbalancedClosingBracket => "Error: unmatched ']'",
            else => "Unknown error during init",
        };
        std.debug.print("{s}\n", .{msg});
        return;
    };

    intrprt.interpret() catch |e| {
        const msg = switch (e) {
            interpreter.Errors.UnbalancedOpeningBracket => "Error: unmatched '['",
            interpreter.Errors.UnbalancedClosingBracket => "Error: unmatched ']'",
            else => "Unknown error during interpret",
        };
        std.debug.print("{s}\n", .{msg});
        return;
    };

    // try intrprt.interpret();
    intrprt.deinit();
}
