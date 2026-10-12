#include <emscripten/emscripten.h>

#include <iostream>
#include <sstream>
#include <string>
#include <exception>

#include "runner/brainfuck-runner.hpp"

extern "C"
{
    EMSCRIPTEN_KEEPALIVE
    const char *run_brainfuck(const char *source, const char *mode, const char *input)
    {
        static std::string result;
        std::istringstream input_stream(input ? input : "");
        std::ostringstream output_stream;

        auto *old_in = std::cin.rdbuf(input_stream.rdbuf());
        auto *old_out = std::cout.rdbuf(output_stream.rdbuf());

        try
        {
            runner::Mode selected_mode =
                mode && std::string(mode) == "ir"
                    ? runner::Mode::IR
                    : runner::Mode::CHAR;

            runner::BrainFuckRunner runner(selected_mode);
            runner.runSource(source ? source : "");
            result = output_stream.str();
        }
        catch (const std::exception &e)
        {
            result = std::string("ERROR: ") + e.what();
        }
        std::cin.rdbuf(old_in);
        std::cout.rdbuf(old_out);
        return result.c_str();
    }
}
