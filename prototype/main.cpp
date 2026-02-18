#include <iostream>
#include <fstream>
#include <filesystem>
#include <sstream>

#include "interpreter.hpp"

void run(interpreter::Interpreter &intrprt, const std::string &source)
{
    intrprt.set_source(source);
    intrprt.interpret();
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
    if (argc == 2)
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
