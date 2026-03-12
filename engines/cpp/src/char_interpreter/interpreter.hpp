#pragma once

#include <iostream>
#include <stack>
#include <unordered_map>
#include <string>
#include <cstdint>

#define MAX_SIZE 32768

namespace interpreter
{
    class Interpreter
    {
    private:
        std::istream &input;
        std::string source;
        size_t instruction_pointer;
        int line;
        int memory_pointer;
        std::uint8_t memory[MAX_SIZE] = {0};

        std::stack<int> trace_brackets;
        std::unordered_map<int, int> brackets;

        void sourceBracketsTrace();
        void resetCurrentPointer();

        // Helper methods
        void advance();
        void decrementMemoryPointer();
        void incrementMemoryPointer();
        void printMemoryPointer();
        void incrementMemoryValue();
        void decrementMemoryValue();
        void takeInput();

    public:
        Interpreter(std::istream &input_stream = std::cin);
        Interpreter(const std::string &source_str, std::istream &input_stream = std::cin);
        void interpret();
        void setSource(const std::string &source);
        ~Interpreter();
    };

} // namespace interpreter