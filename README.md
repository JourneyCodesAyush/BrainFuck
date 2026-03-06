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
  - [Features](#features)
  - [Known Limitations](#known-limitations)
  - [Project Structure](#project-structure)
  - [Contributing](#contributing)
  - [License](#license)
  - [📬 Author](#-author)

---

## Overview

This repository contains two minimal **Brainfuck interpreters** written in:

- C++
- Zig

Both interpreters execute Brainfuck code directly from a `.bf` source file and are designed for learning, experimentation purposes.

> Lightweight, single-file interpreters with clear memory model and basic error handling.

---

## Supported Engines

### C++

- Uses a **fixed-size memory tape**
- Supports all 8 Brainfuck instructions
- Checks for **unmatched brackets** and **pointer underflow**
- Input/output via terminal

### Zig

- Builds with `zig build` and produces `brainfuck` executable
- Minimalistic design, same behavior as C++ engine

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

## Features

- Runs Brainfuck `.b` or `.bf` programs
- Supports `>, <, +, -, ., ,, [, ]`
- Checks for unmatched brackets
- Prevents pointer underflow (C++ & Zig)
- Fixed-size memory model (C++ & Zig)
- Simple educational codebase

---

## Known Limitations

- No memory expansion (C++ & Zig)
- No optimization of repeated instructions
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
