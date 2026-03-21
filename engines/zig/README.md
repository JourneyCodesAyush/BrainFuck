# BrainFuck Engines (Zig)

A **Brainfuck runtime written in Zig** that supports **multiple execution engines**:

- **Character Interpreter** – executes Brainfuck instructions directly
- **IR + Virtual Machine** – compiles Brainfuck into an intermediate representation (IR) and executes it on a VM

This project is designed for **learning and experimentation** with interpreters, intermediate representations, and virtual machine execution.

> Memory is **fixed-size** and wraps at boundaries.
> The memory tape consists of `32768` cells, similar to traditional Brainfuck implementations.

---

## Features

- Supports all Brainfuck instructions: `> < + - . , [ ]`
- Two execution engines:
  - **Character Interpreter**
  - **IR + Virtual Machine**

- Engine selection via command-line
- Ignores non-Brainfuck characters
- Detects unmatched brackets
- Prevents pointer underflow
- Optional **REPL mode**

---

## Execution Modes

### Character Interpreter

Executes Brainfuck **one character at a time**.

```bash
./zig-out/bin/brainfuck program.bf --mode=char
```

This is the **simplest and most direct implementation**.

---

### IR + Virtual Machine

1. Brainfuck source is **compiled into an Intermediate Representation (IR)**
2. The **VM executes the IR instructions**

```bash
./zig-out/bin/brainfuck program.bf --mode=ir
```

This architecture enables:

- Instruction collapsing
- Optimizations
- Experimentation with runtime design

---

### Optimization Example

The IR layer collapses repeated Brainfuck instructions into single operations.

Brainfuck source:

```brainfuck
+++++++
```

Optimized IR:

```txt
ADD 7
```

Pointer movement is also collapsed:

```brainfuck
>>>>
```

becomes:

```txt
MOVE 4
```

---

### Example IR

Brainfuck source:

```brainfuck
+++++>+++
```

Generated IR:

```txt
ADD 5
MOVE 1
ADD 3
```

---

## REPL

If no file is provided, the interpreter launches a **REPL** that reads and executes Brainfuck **character-by-character**:

```bash
./zig-out/bin/brainfuck
```

You can type Brainfuck code directly.

---

## Usage

Build:

```bash
cd engines/zig
zig build -Doptimize=ReleaseFast
```

Run a program:

```bash
./zig-out/bin/brainfuck program.bf
```

Specify engine:

```bash
./zig-out/bin/brainfuck program.bf --mode=char
./zig-out/bin/brainfuck program.bf --mode=ir
```

---

## Example

Run the included example program:

```bash
./zig-out/bin/brainfuck ../../examples/hello_world.bf
```

Or explicitly use the IR engine:

```bash
./zig-out/bin/brainfuck ../../examples/hello_world.bf --mode=ir
```

---

## Project Structure

```text
engines/zig/
├── src/
│   ├── main.zig
│   ├── runner/
│   │   ├── runner.zig
│   ├── interpreter/
│   │   └── interpreter.zig
│   └── ir_vm/
│       ├── parser/
│       ├── instructions/
│       ├── optimization/
│       └── virtual-machine/
├── build.zig
├── build.zig.zon
└── README.md
```

---

## Architecture Overview

```text
Brainfuck Source
       │
       ▼
       Runner
       │
       ├── Character Interpreter
       │
       └── IR Compiler → Virtual Machine
```

The runner selects the execution engine based on the **`--mode` flag**.

---

## License

Check [here](../../LICENSE)

---

## Author's Notes

This project began as a **simple Brainfuck character interpreter in Zig** and evolved to support **IR compilation and virtual machine execution**, enabling experimentation with different runtime architectures.

And the **Zig** version has more been about learning **Zig** itself rather than virtual machine
