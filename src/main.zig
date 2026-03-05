const std = @import("std");
const interpreter = @import("interpreter.zig");

fn run(intrprt: *interpreter.Interpreter, source: []const u8) void {
    intrprt.setSource(source) catch |e| {
        std.debug.print("SetSource error: {any}\n", .{e});
        return;
    };

    intrprt.interpret() catch |e| {
        const msg = switch (e) {
            interpreter.Errors.UnbalancedOpeningBracket => "Error: unmatched '['",
            interpreter.Errors.UnbalancedClosingBracket => "Error: unmatched ']'",
            interpreter.Errors.IOError => "I/O error occurred",
            else => "Unknown error during interpret",
        };
        std.debug.print("{s}\n", .{msg});
    };
}

fn runPrompt() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var intrprt: interpreter.Interpreter = undefined;
    try intrprt.init("", @constCast(&allocator));
    defer intrprt.deinit();

    const stdin = std.fs.File.stdin();

    var buf: [1024]u8 = undefined;

    while (true) {
        std.debug.print("$ ", .{});

        const len = try stdin.read(&buf);
        const line = buf[0..len];
        const trimmed = std.mem.trim(u8, line, "\r\n");

        if (std.mem.eql(u8, trimmed, "q") or
            std.mem.eql(u8, trimmed, "quit") or
            std.mem.eql(u8, trimmed, "exit"))
        {
            std.debug.print("Exiting BrainF*ck REPL...\n", .{});
            return;
        }

        if (trimmed.len > 0) {
            run(&intrprt, trimmed);
        }

        std.debug.print("\n", .{});
    }
}

fn runFile(filename: []const u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    if (!(std.mem.endsWith(u8, filename, ".b") or std.mem.endsWith(u8, filename, ".bf"))) {
        std.debug.print("Use .b or .bf extension for BrainF*ck source files\n", .{});
        return;
    }

    // Read entire file
    const source = try std.fs.cwd().readFileAlloc(
        allocator,
        filename,
        10 * 1024 * 1024,
    );
    defer allocator.free(source);

    var intrprt: interpreter.Interpreter = undefined;
    try intrprt.init(source, @constCast(&allocator));
    defer intrprt.deinit();

    run(&intrprt, source);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len == 1) {
        try runPrompt();
    } else if (args.len == 2) {
        try runFile(args[1]);
    } else {
        std.debug.print("What the 'cake' did you do?\n [Insert slang as per your taste in place of 'cake']\n", .{});
        std.debug.print(
            "Usage: brainfuck <filename>\n",
            .{},
        );
        return;
    }
}
