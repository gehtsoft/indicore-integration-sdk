#include "../stdafx.h"
#include "terminal.h"
#include "../util/Utils.h"

//7386DBF30-6BEF-424C-92BE-94A0689E1ED2
#define IID_Terminal {0x386dbf30, 0x6bef, 0x424c, {0x92, 0xbe, 0x94, 0xa0, 0x68, 0x9e, 0x1e, 0xd2}}
CLASS_ID(ConsoleTerminal, IID_Terminal)

BEGIN_IS_MAP(ConsoleTerminal)
    MAP_IS(ConsoleTerminal)
    MAP_IS(indicore3::ITerminal)
    MAP_IS(indicore3::IObject)
END_IS_MAP()

BEGIN_TO_MAP(ConsoleTerminal)
    MAP_TO(ConsoleTerminal)
    MAP_TO(indicore3::ITerminal)
    MAP_TO(indicore3::IObject)
END_TO_MAP()

bool ConsoleTerminal::alertMessage(indicore3::IInstance *instance, const char *instrument, double price, const char *signalname, double time, indicore3::IError **error)
{
    std::cout << instrument << ";" << Utils::formatDate(time) << ";" << price << ";" << signalname << ";" << std::endl;
    return true;
}

bool ConsoleTerminal::alertSound(indicore3::IInstance *instance, const char *file, bool recurrent, indicore3::IError **error)
{
    std::cout << "alertSound";
    return true;
}

bool ConsoleTerminal::alertEmail(indicore3::IInstance *instance, const char *to, const char *subject, const char *text, indicore3::IError **error)
{
    std::cout << "alertEmail";
    return true;
}

const char *ConsoleTerminal::executeOrder(indicore3::IInstance *instance, int cookie, indicore3::IValueMap *params, indicore3::IError **error)
{
    const char * request_ID = "1";
    std::cout << "executeOrder";
    return request_ID;
}
