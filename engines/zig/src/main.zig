const std = @import("std");

const Io = std.Io;

const errors = @import("./errors/error.zig");

const runner = @import("./runner/runner.zig");

fn handleError(err: errors.Errors) void {
    switch (err) {
        errors.Errors.IOError => std.debug.print("IOError", .{}),
        errors.Errors.OutOfMemory => std.debug.print("OutOfMemory", .{}),
        errors.Errors.ParseError => std.debug.print("ParseError", .{}),
        errors.Errors.UnbalancedClosingBracket => std.debug.print("UnbalancedClosingBracket", .{}),
        errors.Errors.UnbalancedOpeningBracket => std.debug.print("UnbalancedOpeningBracket", .{}),
        errors.Errors.WriteFailedError => std.debug.print("WriteFailedError", .{}),
    }
}

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();

    var mode: runner.Mode = runner.Mode.CHAR;
    var filename: []const u8 = "";

    // Buffered writer over stdout — flushed once on return via `defer`.
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), init.io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;
    defer stdout_writer.flush() catch {};

    // const args = try std.process.argsAlloc(allocator);
    // defer std.process.argsFree(allocator, args);

    const args = init.minimal.args.toSlice(allocator) catch {
        handleError(errors.Errors.IOError);
        return errors.Errors.IOError;
    };

    var i: usize = 1;

    while (i < args.len) : (i += 1) {
        const arg = args[i];
        if (std.mem.startsWith(u8, arg, "--mode=")) {
            const value = arg[7..];
            if (std.mem.eql(u8, value, "char")) {
                mode = runner.Mode.CHAR;
            } else if (std.mem.eql(u8, value, "ir")) {
                mode = runner.Mode.IR;
            } else {
                std.debug.print("ERROR: Unknown mode '{s}'\n", .{value});
                return;
            }
        } else if (filename.len == 0) {
            filename = arg;
        } else {
            std.debug.print("ERROR: Unknown argument '{s}'\n", .{arg});
            return;
        }
    }

    var rnr: runner.Runner = undefined;
    try rnr.init(init.io, stdout_writer, allocator);

    rnr.setMode(mode);
    if (filename.len != 0) {
        rnr.runFromFile(filename) catch |err| {
            handleError(err);
        };
    } else {
        rnr.runRepl() catch |err| {
            handleError(err);
        };
    }
    defer rnr.deinit();
}
