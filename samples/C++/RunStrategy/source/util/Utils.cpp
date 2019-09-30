#include "../stdafx.h"
#include "Utils.h"

#ifdef __APPLE__
#include <mach-o/dyld.h>
#include <signal.h>
#include <cmath>
#include <sys/stat.h>
#endif

/**
  Converts OLE Automation date to
  human readable string mm/dd/YYYY
 */
const char *Utils::formatDate(double dt)
{
    static char buf[128];
    SYSTEMTIME st;

    VariantTimeToSystemTime(dt, &st);
    sprintf_s(buf, 128, "%d.%d.%d %d:%d:%d", st.wMonth, st.wDay, st.wYear, st.wHour, st.wMinute, st.wSecond);

    return buf;
}

/**
  Prints an Indicore error to a console.
*/
void Utils::printIndicoreError(indicore3::IError *error)
{
    if (!error)
        return;

    for (index_t i = 0; i < error->size(); i++)
    {
        AutoRelease<const indicore3::IError::IErrorInfo> errorInfo(error->getError(i));
        std::cout << "Error: " << errorInfo->getText() << std::endl;
    }
}

bool Utils::IsPathExist(const std::string &s)
{
    struct stat buffer;
    memset(&buffer, 0, sizeof(struct stat));
    return (stat (s.c_str(), &buffer) == 0);
}

bool Utils::constructDate(const std::string &strDate, double& dateTime)
{
    SYSTEMTIME st = {};
    double dt;
    
    int day, month, year, hour, minute, second;

    int res = sscanf_s(strDate.c_str(), "%d.%d.%d %d:%d:%d", &month, &day, &year, &hour, &minute, &second);
    if (res != 6)
        return false;
    st.wDay = day; st.wMonth = month; st.wYear = year; st.wHour = hour; st.wMinute = minute; st.wSecond = second;

    SystemTimeToVariantTime(&st, &dateTime);
    return true;
}
