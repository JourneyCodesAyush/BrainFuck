#pragma once

#include <vector>
#include "../instruction/opcode.hpp"

std::vector<instruction::Instruction> optimize(const std::vector<instruction::Instruction> &raw);