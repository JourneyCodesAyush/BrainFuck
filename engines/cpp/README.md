# Brainfuck Engines (C++)

A **Brainfuck runtime written in C++17** that supports **multiple execution engines**:

- **Character Interpreter** - executes Brainfuck instructions directly
- **IR + Virtual Machine** - compiles Brainfuck into an intermediate representation and executes it with a VM

This project is designed as an **experimental runtime for Brainfuck**, exploring different execution strategies.

> Memory is **fixed-size** and wraps at boundaries.
> The memory tape consists of `32768` cells, similar to traditional Brainfuck implementations.

---

## Features

- Supports all Brainfuck instructions: `> < + - . , [ ]`
- Two execution engines:
  - **Character Interpreter**
  - **IR + Virtual Machine**

- Runtime engine selection
- Ignores non-Brainfuck characters
- Detects unmatched brackets
- Prevents pointer underflow
- Optional **REPL mode**

---

## Execution Modes

### Character Interpreter

Executes Brainfuck **one character at a time**.

```bash
brainfuck program.bf --mode=char
```

This is the **simplest and most direct implementation**.

---

### IR + Virtual Machine

1. Brainfuck source is **compiled into an Intermediate Representation (IR)**
2. The **VM executes the IR instructions**

```bash
brainfuck program.bf --mode=ir
```

This architecture enables:

- optimizations
- instruction collapsing
- experimentation with runtime design

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

becomes

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

If no file is provided, the program launches a **REPL** that interprets Brainfuck code character-by-character:

```bash
./brainfuck
```

You can type Brainfuck code directly.

---

## Usage

Build:

```bash
cd engines/cpp
make
```

Run a program:

```bash
./brainfuck program.bf # Character interpreter is the default mode
```

Specify engine:

```bash
./brainfuck program.bf --mode=char
./brainfuck program.bf --mode=ir
```

---

## Example

Run the included example program:

```bash
./brainfuck ../../examples/hello_world.bf
```

or explicitly use the IR engine:

```bash
./brainfuck ../../examples/hello_world.bf --mode=ir
```

---

## Project Structure

```bash
engines/
└── cpp/
    ├── src/
    │   ├── main.cpp
    │   │
    │   ├── char_interpreter/
    │   │   ├── interpreter.cpp
    │   │   └── interpreter.hpp
    │   │
    │   ├── ir_vm/
    │   │   ├── instruction/
    │   │   ├── parser/
    │   │   ├── optimization/
    │   │   └── virtual-machine/
    │   │
    │   └── runner/
    │
    ├── Makefile
    └── README.md # You are reading it!
```

---

## Architecture Overview

```bash
Brainfuck Source
       │
       ▼
   BrainFuckRunner
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

This project began as a **simple Brainfuck character interpreter** and evolved into a **multi-engine runtime** to explore:

- interpreter design
- intermediate representations
- virtual machine execution
