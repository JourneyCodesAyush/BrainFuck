#pragma once

#include <iostream>
#include <vector>
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
        std::string source;
        size_t current_char;
        int line;
        int memory_pointer;
        std::uint8_t memory[MAX_SIZE];

        std::stack<int> trace_brackets;
        std::unordered_map<int, int> brackets;

        void source_brackets_trace();
        void reset_current_pointer();

        // Helper methods
        void advance();
        void decrement_memory_pointer();
        void increment_memory_pointer();
        void print_memory_pointer();
        void increment_memory_value();
        void decrement_memory_value();
        void take_input();

    public:
        Interpreter();
        Interpreter(const std::string &source);
        void interpret();
        void set_source(const std::string &source);
        ~Interpreter();
    };

} // namespace interpreter