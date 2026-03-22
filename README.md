# Brainfuck

![C++](https://img.shields.io/badge/C%2B%2B-17-orange)
![Zig](https://img.shields.io/badge/Zig-v0.15.2-yellow)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Table of Contents

- [Brainfuck](#brainfuck)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Supported Engines](#supported-engines)
    - [C++](#c)
    - [Zig](#zig)
  - [Quick Install](#quick-install)
    - [C++](#c-1)
    - [Zig](#zig-1)
  - [Usage](#usage)
  - [Examples](#examples)
    - [Hello World](#hello-world)
    - [Echo Input](#echo-input)
    - [Test Environment](#test-environment)
    - [Build Configuration](#build-configuration)
  - [Benchmark](#benchmark)
  - [Features](#features)
  - [Known Limitations](#known-limitations)
  - [Project Structure](#project-structure)
  - [Contributing](#contributing)
  - [License](#license)
  - [📬 Author](#-author)

---

## Overview

This repository contains Brainfuck engines written in:

- C++
- Zig

The implementations explore different execution strategies for running Brainfuck programs.

- The **C++ engine** supports multiple execution modes consisting of a character interpreter and an IR-based virtual machine.
- The **Zig engine** is a minimal direct interpreter.

The project is designed for learning and experimentation with interpreter design, intermediate representations, and virtual machine runtimes.

---

## Supported Engines

### C++

The C++ implementation provides a **multi-engine Brainfuck runtime**.

Features:

- Fixed-size memory tape (`32768` cells)
- Supports all 8 Brainfuck instructions
- Detects **unmatched brackets**
- Prevents **pointer underflow**
- Runtime engine selection
- Optional REPL mode
- IR instruction collapsing optimization

Execution engines:

- **Character Interpreter** — executes Brainfuck instructions directly
- **IR + Virtual Machine** — compiles Brainfuck into an intermediate representation before execution

### Zig

- Builds with `zig build` and produces `brainfuck` executable
- Minimalistic direct Brainfuck interpreter
- Simple implementation designed for learning purposes

---

## Quick Install

### C++

```bash
cd engines/cpp
make
./brainfuck hello.bf
```

### Zig

```bash
cd engines/zig
zig build
./zig-out/bin/brainfuck hello.bf
```

---

## Usage

All engines run by passing a `.bf` file as a command-line argument. Example:

```bash
./brainfuck program.bf
./zig-out/bin/brainfuck program.bf
```

The C++ engine also supports selecting the execution mode:

```bash
./brainfuck program.bf --mode=char
./brainfuck program.bf --mode=ir
```

---

## Examples

### Hello World

```brainfuck
++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>.
```

Expected output:

```
Hello World!
```

### Echo Input

```brainfuck
,.
```

Type a character, and it will be printed back.

---

### Test Environment

- **CPU**: Intel(R) Core(TM) i5 M 460 @ 2.53GHz
- **Cores / Threads**: 2 cores / 4 threads
- **RAM**: 4 GB
- **System**: Dell Inspiron N5010
- **OS**: Windows 10 Home (Build 19045, x64)

### Build Configuration

- **Zig**: ReleaseFast
- **C++**: -O3

---

## Benchmark

For [Mandel Brot code](./examples/mandel.b)

| Run         | C++ Interpreter (ms) | Zig Interpreter (ms) | C++ VM (ms) | Zig VM (ms) |
| ----------- | -------------------- | -------------------- | ----------- | ----------- |
| 1           | 994222               | 90883                | 50028       | 43827       |
| 2           | 101755               | 92457                | 42753       | 37110       |
| 3           | 100700               | 91428                | 36374       | 38758       |
| 4           | 112873               | 92705                | 33157       | 39720       |
| 5           | 106427               | 92208                | 31967       | 29985       |
| **Average** | **104235**           | **91936.2**          | **38855.8** | **37880**   |

---

## Features

- Runs Brainfuck `.b` or `.bf` programs
- Supports `>, <, +, -, ., ,, [, ]`
- Multiple execution engines (C++)
- IR-based virtual machine (C++)
- Instruction collapsing optimizations (C++)
- Fixed-size memory model
- Bracket validation
- Pointer safety checks
- Optional REPL mode in both Zig and C++

---

## Known Limitations

- No memory expansion (C++ & Zig)
- Only basic IR optimizations implemented
- No debugging mode or step execution
- Input is character-based only
- Console encoding may vary by platform

---

## Project Structure

```text
brainfuck
├── engines/
│   ├── cpp/
│   │   ├── src/          # C++ interpreter sources
│   │   └── Makefile
│   └── zig/
│       ├── src/          # Zig interpreter sources
│       ├── build.zig
│       └── build.zig.zon
│
├── examples/
│
├── LICENSE
└── README.md
```

---

## Contributing

Contributing guidelines will be added soon.

---

## License

[MIT](./LICENSE)

---

## 📬 Author

Made with ❤️ by [JourneyCodesAyush](https://github.com/JourneyCodesAyush)
