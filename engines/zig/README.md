# BrainFuck Interpreter (Zig)

A **minimal Brainfuck interpreter in Zig**, designed for learning and experimentation.

> Implements standard Brainfuck commands only.

---

## Features

- Supports all 8 Brainfuck instructions: `> < + - . , [ ]`
- Ignores non-Brainfuck characters
- Fixed-size memory model
- Pointer wraps at edges
- Lightweight and fast

---

## Usage

```bash
zig build          # builds 'brainfuck' executable
./zig-out/bin/brainfuck program.bf
```

---

## Project Structure

```text
engines/zig/
├── src/
│   ├── main.zig
│   ├── interpreter.zig
│   └── root.zig
├── build.zig
├── build.zig.zon
└── README.md
```

---

## Author's Notes

Educational Zig Brainfuck interpreter for learning interpreters.
