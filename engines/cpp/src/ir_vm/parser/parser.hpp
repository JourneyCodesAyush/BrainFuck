#pragma once

#include "../instruction/OpCode.hpp"

#include <exception>
#include <stack>
#include <string>
#include <vector>

namespace parser {
class ParseError : public std::exception {
  private:
    std::string message;

  public:
    ParseError(const std::string& message) : message(message) {}

    virtual const char* what() const noexcept {
        return message.c_str();
    }
};

class Parser {
  private:
    std::string source;
    std::vector<instruction::Instruction> instruction;
    std::stack<size_t> loop_stack;
    size_t current = 0;
    inline instruction::Instruction emitByte(instruction::OpCode, int argument = 0);

    void advance();

  public:
    Parser() : source("") {}
    Parser(std::string& source) : source(source) {}
    void setSource(const std::string& source);
    std::vector<instruction::Instruction> parse();
};
} // namespace parser
