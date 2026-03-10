#include <algorithm>
#include <stack>
#include <vector>

#include "../instruction/opcode.hpp"

std::vector<instruction::Instruction> optimize(const std::vector<instruction::Instruction> &raw)
{
    if (raw.empty())
        return {};

    std::vector<instruction::Instruction> optimized;

    // Compress consecutive ADD/MOVE instructions
    for (const auto &curr : raw)
    {
        if (!optimized.empty())
        {
            auto &last = optimized.back();

            if (curr.opcode == last.opcode &&
                (curr.opcode == instruction::OpCode::ADD ||
                 curr.opcode == instruction::OpCode::MOVE))
            {
                last.argument += curr.argument;
                continue;
            }
        }

        optimized.push_back(curr);
    }

    std::stack<size_t> loop_stack;
    for (size_t i = 0; i < optimized.size(); i++)
    {
        if (optimized[i].opcode == instruction::OpCode::JZ)
        {
            loop_stack.push(i);
        }
        else if (optimized[i].opcode == instruction::OpCode::JNZ)
        {
            size_t start_idx = loop_stack.top();
            loop_stack.pop();
            optimized[start_idx].argument = i;
            optimized[i].argument = start_idx;
        }
    }

    return optimized;
}