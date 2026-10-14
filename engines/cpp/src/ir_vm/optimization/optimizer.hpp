#pragma once

#include "../instruction/OpCode.hpp"

#include <vector>

std::vector<instruction::Instruction> optimize(const std::vector<instruction::Instruction>& raw);
