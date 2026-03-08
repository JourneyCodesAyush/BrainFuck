#include "Parser.hpp"

namespace parser
{
    void Parser::setSource(const std::string &source)
    {
        this->source = source;
    }

    void Parser::advance()
    {
        this->current++;
    }

    inline instruction::Instruction Parser::emitByte(instruction::OpCode opcode, int argument)
    {
        return instruction::Instruction{opcode, argument};
    };

    std::vector<instruction::Instruction> Parser::parse()
    {
        this->instruction.clear();
        while (!loop_stack.empty())
            loop_stack.pop();
        this->current = 0;

        while (current < this->source.size())
        {
            char c = source.at(current);
            switch (c)
            {
            case '+':
            {
                this->instruction.push_back(this->emitByte(instruction::OpCode::ADD, 1));
                break;
            }
            case '-':
            {
                this->instruction.push_back(this->emitByte(instruction::OpCode::ADD, -1));
                break;
            }
            case '>':
            {
                this->instruction.push_back(this->emitByte(instruction::OpCode::MOVE, 1));
                break;
            }
            case '<':
            {
                this->instruction.push_back(this->emitByte(instruction::OpCode::MOVE, -1));
                break;
            }
            case ',':
            {
                this->instruction.push_back(this->emitByte(instruction::OpCode::INPUT, 0));
                break;
            }
            case '.':
            {
                this->instruction.push_back(this->emitByte(instruction::OpCode::OUTPUT, 0));
                break;
            }
            case '[':
            {
                this->instruction.push_back(this->emitByte(instruction::OpCode::JZ, -1));
                this->loop_stack.push(instruction.size() - 1);
                break;
            }
            case ']':
            {
                if (this->loop_stack.empty())
                {
                    throw ParseError("Unmatched ']' at source position " + std::to_string(current));
                }

                int start_idx = this->loop_stack.top();
                this->loop_stack.pop();
                this->instruction.push_back(this->emitByte(instruction::OpCode::JNZ, start_idx));
                this->instruction[start_idx].argument = instruction.size() - 1;
                break;
            }

            default:
                break;
            }
            advance();
        }
        return this->instruction;
    }

} // namespace parser