#include "stdafx.h"
#include "Utils.h"

#ifdef __APPLE__
    #include <mach-o/dyld.h>
#endif

std::string Utils::getAppPath()
{
    const int MAXPATH = 1024;
    char pathBuf[MAXPATH];

#ifdef WIN32
    HINSTANCE hinst = GetModuleHandle(NULL);
    GetModuleFileName(hinst, pathBuf, MAXPATH);
    for (size_t i = strlen(pathBuf) - 1; ; i--)
    {
        if (i == 0)
        {
            strcpy_s(pathBuf, ".");
            break;
        }
        else if (pathBuf[i] == '\\' ||
            pathBuf[i] == '/')
        {
            pathBuf[i] = 0;
            break;
        }
    }
	return pathBuf;
#elif __APPLE__
    uint32_t bufsize = MAXPATH;
    if(_NSGetExecutablePath(pathBuf, &bufsize) != 0)
        return nullptr;
    return Utils::getParentDirectory(pathBuf);
#else
	int len = readlink("/proc/self/exe", pathBuf, MAXPATH - 1);
    pathBuf[len] = 0;
    *(strrchr(pathBuf, '/') + 1) = 0;
	return pathBuf;
#endif
}

char Utils::getDirectorySeparatorChar()
{
#ifdef WIN32
    return '\\';
#else
    return '/';
#endif
}

std::string Utils::getParentDirectory(char *pathBuf)
{
    if (pathBuf == nullptr)
        return nullptr;

    std::string strPath = std::string(pathBuf);
    for (int i = strPath.size(); i > 0; i--)
    {
        char ch = strPath[i - 1];
        if (ch == Utils::getDirectorySeparatorChar())
            return strPath.substr(0, i - 1);
    }

    return nullptr;
}
