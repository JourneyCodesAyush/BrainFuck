#pragma once

#include <vector>
#include "../instruction/OpCode.hpp"

std::vector<instruction::Instruction> optimize(const std::vector<instruction::Instruction> &raw);