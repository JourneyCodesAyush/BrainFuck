#pragma once

#include <vector>
#include <iostream>
#include "../instruction/opcode.hpp"

#define MAX_SIZE 32768

namespace vm
{
    class VirtualMachine
    {
    private:
        std::istream &input;
        std::vector<instruction::Instruction> instructions;
        size_t ip;
        size_t memory_pointer;
        std::uint8_t memory[MAX_SIZE] = {0};

        inline void advance();
        void takeInput();

    public:
        VirtualMachine(std::istream &input_stream = std::cin) : input(input_stream), instructions({}), ip(0), memory_pointer(0) {}

        VirtualMachine(const std::vector<instruction::Instruction> &instructions, std::istream &input_stream = std::cin) : input(input_stream), instructions{instructions}, ip(0), memory_pointer(0) {}

        void setInstructions(const std::vector<instruction::Instruction> &instructions);

        void run();
    };
} // namespace vm