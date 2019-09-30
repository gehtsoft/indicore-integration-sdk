// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#ifdef _WIN32
    #ifndef _WIN32_WINNT        // Allow use of features specific to Windows XP or later.
    #define _WIN32_WINNT 0x0501 // Change this to the appropriate value to target other versions of Windows.
    #endif
    #include <tchar.h>
    #include <windows.h>
#endif


#include <stdio.h>

#include <string>
#include <vector>
#include <map>
#include <iostream>

#ifndef WIN32
    #include <unistd.h>
#endif

#include <indicore3.h>

#include "AutoRelease.h"
#include "Utils.h"

void printIndicoreError(indicore3::IError *error);
bool parseParams(int argc, char* argv[], std::string& indicatorsPath);