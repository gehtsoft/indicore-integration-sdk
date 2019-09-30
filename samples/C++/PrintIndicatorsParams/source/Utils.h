#pragma once

class Utils
{
 public:
    /** Gets the current application's path. */
    static std::string getAppPath();

    /** Gets a directory separator character. */
    static char getDirectorySeparatorChar();

    /** Gets a parent directory. */
    static std::string getParentDirectory(char *pathBuf);
};
