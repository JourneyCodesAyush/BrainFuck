#include <iostream>
#include <vector>
#include <string>

#include "vm.hpp"

namespace vm
{
    inline void VirtualMachine::advance()
    {
        this->ip++;
    }

    void VirtualMachine::take_input()
    {
        std::cout << "> ";
        int ch = this->input.get();
        if (ch == EOF)
        {
            this->memory[this->memory_pointer] = 255;
        }
        else
        {
            if (ch == 13)
                ch = 10;
            this->memory[this->memory_pointer] = static_cast<uint8_t>(ch);
        }
        std::string temp;
        std::getline(this->input, temp);
    }

    void VirtualMachine::run()
    {
        size_t instructions_size = this->instructions.size();
        while (this->ip < instructions_size)
        {
            const auto &instr = this->instructions[this->ip];
            switch (instr.opcode)
            {
            case instruction::OpCode::ADD:
                this->memory[this->memory_pointer] += instr.argument;
                break;
            case instruction::OpCode::MOVE:
                this->memory_pointer += instr.argument;
                break;
            case instruction::OpCode::INPUT:
                this->take_input();
                break;
            case instruction::OpCode::OUTPUT:
                std::cout << this->memory[this->memory_pointer];
                break;
            case instruction::OpCode::JZ:
                if (this->memory[this->memory_pointer] == 0)
                    this->ip = instr.argument;
                break;

            case instruction::OpCode::JNZ:
                if (this->memory[this->memory_pointer] != 0)
                    this->ip = instr.argument;
                break;

            default:
                break;
            }
            this->advance();
        }
    }
} // namespace vm