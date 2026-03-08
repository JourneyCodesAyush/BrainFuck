#pragma once
#include <cstdint>

namespace instruction
{
    enum class OpCode : uint8_t
    {
        ADD,
        MOVE,
        INPUT,
        OUTPUT,
        JZ,
        JNZ,
    };

    struct Instruction
    {
        OpCode opcode;
        int32_t argument;
    };
} // namespace instruction