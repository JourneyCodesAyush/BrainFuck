# BrainFuck Interpreter (C++)

This is a **Brainfuck interpreter in C++17**, built to execute `.bf` programs directly in the terminal.

> Does **not** expand memory dynamically. Wraps at boundaries.

---

## Features

- Fully implements Brainfuck instructions: `> < + - . , [ ]`
- Ignores non-Brainfuck characters
- Detects unmatched brackets
- Prevents pointer underflow
- Simple, educational, and portable

---

## Usage

```bash
cd engines/cpp  # Change directory if not already done
make            # builds 'brainfuck' executable
./brainfuck program.bf
```

> Tested on **Windows**.

---

## Project Structure

```text
cpp/
├── src/
│   ├── main.cpp
│   ├── interpreter.cpp
│   └── interpreter.hpp
├── Makefile
└── summary.md
```

---

## Author's Notes

Learning-focused Brainfuck interpreter in C++.
