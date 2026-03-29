#include <iostream>
#include <fstream>
#include <filesystem>
#include <sstream>

#include "char_interpreter/interpreter.hpp"
#include "runner/brainfuck-runner.hpp"

int main(int argc, char *argv[])
{
    try
    {
        std::ios::sync_with_stdio(false);
        std::string filename;
        runner::Mode mode = runner::Mode::CHAR;

        std::string arg;
        for (int i = 1; i < argc; i++)
        {
            arg = argv[i];
            if (arg.rfind("--mode=", 0) == 0)
            {
                std::string value = arg.substr(7); // get the part after '='
                if (value == "char")
                    mode = runner::Mode::CHAR;
                else if (value == "ir")
                    mode = runner::Mode::IR;
                else
                    throw std::runtime_error("Unknown mode: " + value);
            }
            else if (filename.empty())
            {
                filename = arg;
            }
            else
            {
                throw std::runtime_error("Unknown argument: " + arg + "\n");
            }
        }

        runner::BrainFuckRunner bfRunner(mode);
        if (filename.empty())
        {
            bfRunner.runRepl();
        }
        else
        {
            bfRunner.runFromFile(filename);
        }
    }
    catch (const std::exception &e)
    {
        std::cerr << "ERROR: "
                  << e.what() << "\n";
    }

    return 0;
}
