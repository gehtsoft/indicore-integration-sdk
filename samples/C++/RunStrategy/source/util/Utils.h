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

    /**
    Construct double value in OLE Automation date format from string with specific format
    */
    static bool constructDate(const std::string &strDate, double& dateTime);
};
