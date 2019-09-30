#pragma once
#include <functional>

class Utils
{
 public:
    /**
     Converts OLE Automation date to
      human readable string mm/dd/YYYY
    */
    static const char *formatDate(double dt);

    /**
      Prints an Indicore error to a console.
    */
    static void printIndicoreError(indicore3::IError *error);

    static bool IsPathExist(const std::string &s);
};
