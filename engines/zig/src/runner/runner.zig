const std = @import("std");
const instruction = @import("../ir_vm/instructions/opcode.zig");
const intrpreter = @import("../char_interpreter/interpreter.zig");
const parser = @import("../ir_vm/parser/parser.zig");
const vm = @import("../ir_vm/virtual-machine/vm.zig");
const optimizer = @import("../ir_vm/optimization/optimizer.zig");

const errors = @import("../errors/error.zig");

pub const Mode = enum { CHAR, IR };

pub const Runner = struct {
    mode: Mode,
    source: []u8,
    allocator: std.mem.Allocator,
    prs: parser.Parser = undefined,
    vir_mac: vm.VirtualMachine = undefined,
    intrprt: intrpreter.Interpreter = undefined,
    optimize: optimizer.Optimizer = undefined,

    pub fn init(self: *Runner, allocator: std.mem.Allocator) errors.Errors!void {
        self.allocator = allocator;
        self.source = &[_]u8{};

        try self.intrprt.init("", self.allocator);
        try self.prs.init("", self.allocator);
        try self.optimize.init(self.allocator);
        self.vir_mac.init();
    }

    pub fn deinit(self: *Runner) void {
        self.intrprt.deinit();
        self.prs.deinit();
        self.optimize.deinit();
        if (self.source.len > 0) {
            self.allocator.free(self.source);
            self.source = &[_]u8{};
        }
    }

    pub fn setMode(self: *Runner, mode: Mode) void {
        self.mode = mode;
    }

    pub fn runRepl(self: *Runner) errors.Errors!void {
        printReplHelp();

        const stdin = std.fs.File.stdin();
        var buf: [1024]u8 = undefined;

        while (true) {
            std.debug.print("$ ", .{});

            const len = stdin.read(&buf) catch {
                return errors.Errors.IOError;
            };

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
                const line_heap = try self.allocator.alloc(u8, trimmed.len);

                @memcpy(line_heap, trimmed);
                self.setSourceOwned(line_heap);

                switch (self.mode) {
                    Mode.CHAR => {
                        self.runCharInterpreter() catch |err| {
                            handleError(err);
                        };
                    },
                    Mode.IR => {
                        self.runByteCodeVirtualMachine() catch |err| {
                            handleError(err);
                        };
                    },
                }
            }

            std.debug.print("\n", .{});
        }
    }

    pub fn runFromFile(self: *Runner, filename: []const u8) errors.Errors!void {
        if (!(std.mem.endsWith(u8, filename, ".b") or std.mem.endsWith(u8, filename, ".bf"))) {
            std.debug.print("Use .b or .bf extension for BrainF*ck source files\n", .{});
            return;
        }

        // Read entire file
        const source = std.fs.cwd().readFileAlloc(
            self.allocator,
            filename,
            10 * 1024 * 1024,
        ) catch {
            return errors.Errors.IOError;
        };

        self.setSourceOwned(source);

        switch (self.mode) {
            Mode.CHAR => {
                try self.runCharInterpreter();
            },
            Mode.IR => {
                try self.runByteCodeVirtualMachine();
            },
        }
    }

    fn setSourceOwned(self: *Runner, new: []u8) void {
        if (self.source.len > 0) {
            self.allocator.free(self.source);
        }
        self.source = new;
    }

    fn printReplHelp() void {
        const message: []const u8 =
            \\ ____            _       _____           _    
            \\| __ ) _ __ __ _(_)_ __ |  ___|_/\__ ___| | __
            \\|  _ \| '__/ _` | | '_ \| |_  \    // __| |/ /
            \\| |_) | | | (_| | | | | |  _| /_  _\ (__|   < 
            \\|____/|_|  \__,_|_|_| |_|_|     \/  \___|_|\_\
        ;

        std.debug.print("{s}", .{message});

        std.debug.print("\n\nStart with this 'Hello World' program\n", .{});
        std.debug.print("++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>\n\n", .{});
    }

    fn handleError(err: errors.Errors) void {
        switch (err) {
            errors.Errors.IOError => std.debug.print("IOError", .{}),
            errors.Errors.OutOfMemory => std.debug.print("OutOfMemory", .{}),
            errors.Errors.ParseError => std.debug.print("ParseError", .{}),
            errors.Errors.UnbalancedClosingBracket => std.debug.print("UnbalancedClosingBracket", .{}),
            errors.Errors.UnbalancedOpeningBracket => std.debug.print("UnbalancedOpeningBracket", .{}),
        }
    }

    fn runCharInterpreter(self: *Runner) errors.Errors!void {
        try self.intrprt.setSource(self.source);
        try self.intrprt.interpret();
    }

    fn runByteCodeVirtualMachine(self: *Runner) errors.Errors!void {
        self.prs.setSource(self.source);
        const instr: []instruction.Instructions = try self.prs.parse();
        self.optimize.setRaw(instr);
        const optimized = try self.optimize.optimize();
        // self.vir_mac.setInstructions(instr);
        self.vir_mac.setInstructions(optimized);
        try self.vir_mac.run();
    }
};
