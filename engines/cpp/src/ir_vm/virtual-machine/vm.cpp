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

    void VirtualMachine::setInstructions(const std::vector<instruction::Instruction> &instructions)
    {
        this->ip = 0;
        this->instructions = instructions;
    }

    void VirtualMachine::takeInput()
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
            bool advanced = false;
            switch (instr.opcode)
            {
            case instruction::OpCode::ADD:
                memory[memory_pointer] = uint8_t(memory[memory_pointer] + instr.argument);
                break;
            case instruction::OpCode::MOVE:
                if (instr.argument >= 0)
                    memory_pointer = (memory_pointer + instr.argument) % MAX_SIZE;
                else
                    memory_pointer = (memory_pointer + MAX_SIZE + instr.argument % MAX_SIZE) % MAX_SIZE;
                break;
            case instruction::OpCode::INPUT:
                this->takeInput();
                break;
            case instruction::OpCode::OUTPUT:
                std::cout << char(this->memory[this->memory_pointer]);
                break;
            case instruction::OpCode::JZ:
                if (this->memory[this->memory_pointer] == 0)
                    this->ip = instr.argument;
                else
                {
                    this->advance();
                    advanced = true;
                }
                break;

            case instruction::OpCode::JNZ:
                if (this->memory[this->memory_pointer] != 0)
                    this->ip = instr.argument;
                else
                {
                    advanced = true;
                    this->advance();
                }
                break;

            default:
                break;
            }
            if (!advanced)
                this->advance();
        }

        std::cout << "\n";
    }
} // namespace vm