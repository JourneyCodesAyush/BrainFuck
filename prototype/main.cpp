#include <iostream>
#include <fstream>
#include <filesystem>
#include <sstream>

#include "interpreter.hpp"

void print_help()
{
    std::cout << " ____            _       _____           _    \n"
              << "| __ ) _ __ __ _(_)_ __ |  ___|_/\\__ ___| | __\n"
              << "|  _ \\| '__/ _` | | '_ \\| |_  \\    // __| |/ /\n"
              << "| |_) | | | (_| | | | | |  _| /_  _\\ (__|   < \n"
              << "|____/|_|  \\__,_|_|_| |_|_|     \\/  \\___|_|\\_\\\n";

    std::cout << "\nStart with this 'Hello World' program\n";
    std::cout << "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>\n\n";
}

void run(interpreter::Interpreter &intrprt, const std::string &source)
{
    intrprt.set_source(source);
    intrprt.interpret();
}

void run_prompt()
{
    print_help();
    interpreter::Interpreter intrprt;
    std::string source;
    while (true)
    {
        std::cin.clear();
        std::cout << "$ ";
        if (!std::getline(std::cin, source))
        {
            // End-of-file (Ctrl+D / Ctrl+Z)
            std::cout << "\nExiting BrainF*ck REPL...\n";
            break;
        }

        if (source == "q" || source == "quit" || source == "exit")
        {
            std::cout << "Exiting BrainF*ck REPL...\n";
            break;
        }

        if (!source.empty()) // only run non-empty input
            run(intrprt, source);
    }
}

void run_file(const char *filename)
{
    namespace fs = std::filesystem;
    auto file = fs::path(filename);

    interpreter::Interpreter intrprt;

    if (file.extension().string() == ".bf" or file.extension().string() == ".b")
    {
        std::stringstream source;
        std::ifstream source_file(filename);
        if (!source_file.is_open())
        {
            std::cerr << "Could not open file " << filename << "\n!";
            exit(EXIT_FAILURE);
        }
        source << source_file.rdbuf();
        run(intrprt, source.str());
    }
}

int main(int argc, char *argv[])
{
    if (argc == 1)
    {
        run_prompt();
    }
    else if (argc == 2)
    {
        run_file(argv[1]);
    }
    else
    {
        std::cout << "What the 'cake' did you do?\n [Insert slang as per your taste in place of 'cake']\n"
                  << "Usage: brainfuck [filename]";
    }

    return 0;
}
