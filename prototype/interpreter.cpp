#include <iostream>
#include <string>
#include <cstdint>

#include "interpreter.hpp"
#define MAX_SIZE 32768

namespace interpreter
{
    Interpreter::Interpreter(std::istream &input_stream)
        : input(input_stream), instruction_pointer(0), line(0), memory_pointer(0)
    {
        source = "";
        // memory is already initialized in the header
    }

    Interpreter::Interpreter(const std::string &source_str, std::istream &input_stream)
        : input(input_stream), instruction_pointer(0), line(0), memory_pointer(0)
    {
        source = source_str;
        // memory already zeroed
    }

    Interpreter::~Interpreter()
    {
    }

    void Interpreter::set_source(const std::string &source)
    {
        this->source = source;
    }

    void Interpreter::source_brackets_trace()
    {
        while (instruction_pointer < source.size())
        {
            // std::cout << "Tracing brackets...\n";
            char c = source.at(instruction_pointer);
            int popped = -1;
            switch (c)
            {
            case '\n':
                line++;
                break;
            case '[':
                trace_brackets.push(instruction_pointer);
                // brackets[instruction_pointer] = -1;
                break;
            case ']':
                if (trace_brackets.empty())
                {
                    std::cerr << "Unbalanced bracket at position " << instruction_pointer << "\n";
                    exit(EXIT_FAILURE);
                }
                popped = trace_brackets.top();
                trace_brackets.pop();
                // brackets[popped] = instruction_pointer;

                brackets[popped] = instruction_pointer;
                brackets[instruction_pointer] = popped;
                break;
            default:
                break;
            }
            advance();
        }

        if (!trace_brackets.empty())
        {
            std::cerr << "Unbalanced bracket(s): missing closing ] for [ at position(s): ";
            while (!trace_brackets.empty())
            {
                std::cerr << trace_brackets.top() << " ";
                trace_brackets.pop();
            }
            std::cerr << "\nLine number: " << line << "\n";
            exit(EXIT_FAILURE);
        }

        // std::cout << "Tracing complete...\n";
    }

    void Interpreter::reset_current_pointer()
    {
        instruction_pointer = 0;
    }

    void Interpreter::advance()
    {
        instruction_pointer++;
    }

    void Interpreter::increment_memory_pointer()
    {
        if (memory_pointer == MAX_SIZE - 1)
        {
            memory_pointer = 0;
        }
        else
        {
            memory_pointer++;
        }
    }

    void Interpreter::decrement_memory_pointer()
    {
        if (memory_pointer == 0)
        {
            memory_pointer = MAX_SIZE - 1;
        }
        else
        {
            memory_pointer--;
        }
    }

    void Interpreter::print_memory_pointer()
    {
        std::cout << char(memory[memory_pointer]);
        // << "<something>";
    }

    void Interpreter::increment_memory_value()
    {
        memory[memory_pointer]++;
    }

    void Interpreter::decrement_memory_value()
    {
        memory[memory_pointer]--;
    }

    void Interpreter::take_input()
    {
        int ch = input.get();
        if (ch == EOF)
        {
            memory[memory_pointer] = 255;
        }
        else
        {
            if (ch == 13)
                ch = 10;
            memory[memory_pointer] = static_cast<uint8_t>(ch);
        }

        if (input.peek() == '\n')
            input.get();
    }

    void Interpreter::interpret()
    {
        reset_current_pointer();
        source_brackets_trace();
        reset_current_pointer();
        // std::cout << "Inside interpret method..\n";
        try
        {
            while (instruction_pointer < source.size())
            {
                char c = source.at(instruction_pointer);
                switch (c)
                {
                case '>':
                    increment_memory_pointer();
                    break;
                case '<':
                    decrement_memory_pointer();
                    break;
                case '.':
                    print_memory_pointer();
                    break;
                case ',':
                    // std::cout << "> ";
                    take_input();
                    break;
                case '+':
                    increment_memory_value();
                    break;
                case '-':
                    decrement_memory_value();
                    break;

                case '[':
                    if (memory[memory_pointer] == 0)
                        instruction_pointer = brackets[instruction_pointer];
                    break;
                case ']':
                    if (memory[memory_pointer] != 0)
                        instruction_pointer = brackets[instruction_pointer];
                    break;
                default:
                    // std::cout << "Comment encountered...\n";
                    break;
                }
                advance();
            }
        }
        catch (const std::exception &e)
        {
            std::cerr << e.what() << '\n';
        }
        std::cout << "\n";
    }

}