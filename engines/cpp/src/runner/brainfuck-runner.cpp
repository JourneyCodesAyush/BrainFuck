#include "brainfuck-runner.hpp"

#include <algorithm>
#include <iostream>
#include <exception>
#include <fstream>
#include <filesystem>
#include <sstream>

namespace runner
{
    void BrainFuckRunner::setMode(Mode mode)
    {
        this->mode = mode;
    }
    void BrainFuckRunner::printReplHelp()
    {
        std::cout << " ____            _       _____           _    \n"
                  << "| __ ) _ __ __ _(_)_ __ |  ___|_/\\__ ___| | __\n"
                  << "|  _ \\| '__/ _` | | '_ \\| |_  \\    // __| |/ /\n"
                  << "| |_) | | | (_| | | | | |  _| /_  _\\ (__|   < \n"
                  << "|____/|_|  \\__,_|_|_| |_|_|     \\/  \\___|_|\\_\\\n";

        std::cout << "\nStart with this 'Hello World' program\n";
        std::cout << "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>\n\n";
    }

    void BrainFuckRunner::runRepl()
    {
        this->printReplHelp();
        while (true)
        {
            std::cin.clear();
            std::cout << "$ ";
            if (!std::getline(std::cin, this->source))
            {
                // End-of-file (Ctrl+D / Ctrl+Z)
                std::cout << "\nExiting BrainF*ck REPL...\n\n";
                break;
            }

            if (source == "q" || source == "quit" || source == "exit")
            {
                std::cout << "\nExiting BrainF*ck REPL...\n\n";
                break;
            }

            if (!source.empty())
            { // only run non-empty input
                if (this->mode == Mode::CHAR)
                {
                    this->runCharInterpreter();
                }
                else
                {
                    this->runByteCodeVirtualMachine();
                }
            }
        }
    }

    void BrainFuckRunner::runFromFile(const std::string &filename)
    {
        namespace fs = std::filesystem;
        auto file = fs::path(filename);

        auto ext = file.extension().string();
        std::transform(ext.begin(), ext.end(), ext.begin(), ::tolower);
        if (!((ext == ".bf") || (ext == ".b")))
        {
            throw std::runtime_error("Invalid file extension!");
        }

        std::stringstream source;
        std::ifstream source_file(filename);
        if (!source_file.is_open())
        {
            std::cerr << "Could not open file " << filename << "\n!";
            exit(EXIT_FAILURE);
        }
        source << source_file.rdbuf();
        this->source = source.str();

        if (this->mode == Mode::CHAR)
        {
            this->runCharInterpreter();
        }
        else
        {
            this->runByteCodeVirtualMachine();
        }
    }

    void BrainFuckRunner::runCharInterpreter()
    {
        try
        {
            this->intrprt.setSource(this->source);
            this->intrprt.interpret();
        }
        catch (const std::exception &e)
        {
            throw e;
        }
    }

    void BrainFuckRunner::runByteCodeVirtualMachine()
    {
        try
        {
            this->prs.setSource(this->source);
            auto instructions = this->prs.parse();
            auto optimized = optimize(instructions);
            this->vir_machine.setInstructions(optimized);
            this->vir_machine.run();
        }
        catch (const std::exception &e)
        {
            throw e;
        }
    }
} // namespace runner