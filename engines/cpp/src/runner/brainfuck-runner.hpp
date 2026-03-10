#pragma once

#include <string>

#include "char_interpreter/interpreter.hpp"
#include "ir_vm/instruction/opcode.hpp"
#include "ir_vm/parser/parser.hpp"
#include "ir_vm/optimization/optimizer.hpp"
#include "ir_vm/virtual-machine/vm.hpp"

namespace runner
{
    enum class Mode
    {
        CHAR,
        IR
    };

    class BrainFuckRunner
    {
    private:
        std::string source;
        interpreter::Interpreter intrprt;
        parser::Parser prs;
        vm::VirtualMachine vir_machine;
        Mode mode;

        void runCharInterpreter();
        void runByteCodeVirtualMachine();

        void printReplHelp();

    public:
        BrainFuckRunner(Mode mode = Mode::CHAR) : source(""), mode(mode) {}
        void runRepl();
        void runFromFile(std::string &filename);
        void setMode(Mode mode);
    };
} // namespace runner