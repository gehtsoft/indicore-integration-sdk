#include "../stdafx.h"
#include "host.h"
#include "../terminal/terminal.h"

using namespace indicore3;


SimpleHost::SimpleHost()
{
    mTerminal = new ConsoleTerminal();
}

SimpleHost::~SimpleHost()
{
    mTerminal->release();
}

void SimpleHost::trace(indicore3::IObjectNoRef* caller, const char *str)
{
    std::cout << "trace: " << str << std::endl;
}

ITerminal *SimpleHost::getTerminal(indicore3::IError **error)
{
    mTerminal->addRef();
    return mTerminal;
}