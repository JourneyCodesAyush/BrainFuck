#include <algorithm>
#include <stack>
#include <vector>

#include "../instruction/opcode.hpp"
#include "../virtual-machine/vm.hpp"

std::vector<instruction::Instruction> optimize(const std::vector<instruction::Instruction> &raw)
{
    if (raw.empty())
        return {};

    std::vector<instruction::Instruction> optimized;

    for (auto curr : raw)
    {
        if (!optimized.empty())
        {
            auto &last = optimized.back();

            // Compress consecutive ADD and MOVE
            if (curr.opcode == last.opcode)
            {
                if (curr.opcode == instruction::OpCode::ADD)
                {
                    int sum = static_cast<int>(last.argument) + static_cast<int>(curr.argument);
                    optimized.pop_back();
                    while (sum != 0)
                    {
                        int chunk = std::clamp(sum, -127, 127);
                        optimized.push_back({instruction::OpCode::ADD, static_cast<int8_t>(chunk)});
                        sum -= chunk;
                    }
                    continue;
                }
                else if (curr.opcode == instruction::OpCode::MOVE)
                {
                    int sum = last.argument + curr.argument;
                    optimized.pop_back();
                    while (sum != 0)
                    {
                        int chunk = std::clamp(sum, -(MAX_SIZE - 1), (MAX_SIZE - 1));
                        optimized.push_back({instruction::OpCode::MOVE, chunk});
                        sum -= chunk;
                    }
                    continue;
                }
            }
        }

        // If not compressible, handle large individual argument
        if (curr.opcode == instruction::OpCode::ADD)
        {
            while (curr.argument != 0)
            {
                int chunk = std::clamp(curr.argument, -127, 127);
                optimized.push_back({instruction::OpCode::ADD, static_cast<int8_t>(chunk)});
                curr.argument -= chunk;
            }
        }
        else if (curr.opcode == instruction::OpCode::MOVE)
        {
            while (curr.argument != 0)
            {
                int chunk = std::clamp(curr.argument, -(MAX_SIZE - 1), (MAX_SIZE - 1));
                optimized.push_back({instruction::OpCode::MOVE, chunk});
                curr.argument -= chunk;
            }
        }
        else
        {
            optimized.push_back(curr);
        }
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
            if (loop_stack.empty())
                throw std::runtime_error("Unmatched instruction JNZ\n");
            size_t start_idx = loop_stack.top();
            loop_stack.pop();
            optimized[start_idx].argument = i;
            optimized[i].argument = start_idx;
        }
    }

    if (!loop_stack.empty())
        throw std::runtime_error("Unmatched instruction JZ\n");

    return optimized;
}