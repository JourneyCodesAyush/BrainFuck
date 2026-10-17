import os
import subprocess
import sys
import tempfile
from pathlib import Path

TIMEOUT_SECONDS: int = 2

ROOT_DIR = Path(__file__).resolve().parent

BUILD_DIRS: dict[str, Path] = {
    "cpp": ROOT_DIR / "engines" / "cpp" / "build",
    "zig": ROOT_DIR / "engines" / "zig" / "zig-out" / "bin",
}


def executable_path(engine: str) -> Path:
    """Return the platform-specific executable path."""
    executable_name = "brainfuck.exe" if os.name == "nt" else "brainfuck"
    return BUILD_DIRS[engine] / executable_name


IMPLEMENTATIONS: dict[str, list[str]] = {
    "cpp-char": [
        str(executable_path("cpp")),
        "--mode=char",
        "{source}",
    ],
    "cpp-ir": [
        str(executable_path("cpp")),
        "--mode=ir",
        "{source}",
    ],
    "zig-char": [
        str(executable_path("zig")),
        "--mode=char",
        "{source}",
    ],
    "zig-ir": [
        str(executable_path("zig")),
        "--mode=ir",
        "{source}",
    ],
}

# Each test:
#   name: descriptive test name
#   source: Brainfuck source code
#   input_hex: input bytes, encoded as hexadecimal
#   output_hex: expected output bytes, encoded as hexadecimal

TESTS: list[dict[str, str]] = [
    {
        "name": "empty",
        "source": "",
        "input_hex": "",
        "output_hex": "",
    },
    {
        "name": "addition",
        "source": "+++++.",
        "input_hex": "",
        "output_hex": "05",
    },
    {
        "name": "subtraction",
        "source": "+-.",
        "input_hex": "",
        "output_hex": "00",
    },
    {
        "name": "clear_cell",
        "source": "+++++[-].",
        "input_hex": "",
        "output_hex": "00",
    },
    {
        "name": "zero_loop",
        "source": "+++[-].",
        "input_hex": "",
        "output_hex": "00",
    },
    {
        "name": "nested_loops",
        "source": "++[>++[>+<-]<-]>>.",
        "input_hex": "",
        "output_hex": "04",
    },
    {
        "name": "transfer",
        "source": "+++++[->+<]>.",
        "input_hex": "",
        "output_hex": "05",
    },
    {
        "name": "ignored_characters",
        "source": "abc+++xyz.",
        "input_hex": "",
        "output_hex": "03",
    },
    {
        "name": "echo",
        "source": ",.",
        "input_hex": "41",
        "output_hex": "41",
    },
    {
        "name": "multiple_io",
        "source": ",>,.<.",
        "input_hex": "4142",
        "output_hex": "4241",
    },
    {
        "name": "binary_io",
        "source": ",>,>,.<.<.",
        "input_hex": "007FFF",
        "output_hex": "FF7F00",
    },
    {
        "name": "loop_skipped",
        "source": "[+++++].",
        "input_hex": "",
        "output_hex": "00",
    },
    {
        "name": "loop_one_iteration",
        "source": "+[.-]",
        "input_hex": "",
        "output_hex": "01",
    },
    {
        "name": "increment_many",
        "source": "++++++++++.",
        "input_hex": "",
        "output_hex": "0A",
    },
    {
        "name": "hello_world",
        "source": (
            "++++++++++[>+++++++>++++++++++>+++>+<<<<-]"
            ">++.>+.+++++++..+++.>++.<<+++++++++++++++.>."
            "+++.------.--------.>+.>."
        ),
        "input_hex": "",
        "output_hex": "48656C6C6F20576F726C64210A",
    },
]


def run_test(command: list[str], test: dict[str, str]) -> tuple[bool, str]:
    source: bytes = test["source"].encode("ascii")
    stdin_data: bytes = bytes.fromhex(test["input_hex"])
    expected: bytes = bytes.fromhex(test["output_hex"])

    # Use a temporary directory instead of keeping a NamedTemporaryFile
    # open while the child process tries to read it. This works reliably
    # with Windows file-sharing behavior.
    with tempfile.TemporaryDirectory(prefix="brainfuck_test_") as temp_dir:
        source_path = Path(temp_dir) / "program.bf"
        source_path.write_bytes(source)

        args = [arg.replace("{source}", str(source_path)) for arg in command]

        try:
            result = subprocess.run(
                args,
                input=stdin_data,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=TIMEOUT_SECONDS,
                check=False,
                cwd=ROOT_DIR,
            )

        except subprocess.TimeoutExpired:
            return False, "TIMEOUT"

        except FileNotFoundError as exc:
            return False, f"EXECUTABLE NOT FOUND: {exc}"

        except OSError as exc:
            return False, f"PROCESS ERROR: {exc}"

        if result.returncode != 0:
            return False, (
                f"exit={result.returncode}, " f"stderr={result.stderr[:200]!r}"
            )

        if result.stdout != expected:
            return False, (
                f"expected={expected.hex().upper()}, "
                f"actual={result.stdout.hex().upper()}"
            )

        return True, ""


def main() -> int:
    passed: int = 0
    failed: int = 0
    total: int = len(TESTS) * len(IMPLEMENTATIONS)

    for impl_name, command in IMPLEMENTATIONS.items():
        print(f"\n=== {impl_name} ===")

        for test in TESTS:
            ok, detail = run_test(command, test)

            if ok:
                passed += 1
                print(f"  PASS  {test['name']}")
            else:
                failed += 1
                print(f"  FAIL  {test['name']}: {detail}")

    print(f"\nResults: {passed}/{total} passed, {failed} failed")

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
