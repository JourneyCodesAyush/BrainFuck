#include "interpreter.hpp"

int main(int argc, char *argv[])
{
    interpreter::Interpreter intrpt(">++++++++[<+++++++++>-]<.>++++[<+++++++>-]<+.+++++++..+++.>>++++++[<+++++++>-]<++.------------.>++++++[<+++++++++>-]<+.<.+++.------.--------.>>>++++[<++++++++>-]<+.");
    intrpt.interpret();
    return 0;
}