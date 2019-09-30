// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#ifdef _WIN32
    #ifndef _WIN32_WINNT        // Allow use of features specific to Windows XP or later.
    #define _WIN32_WINNT 0x0501 // Change this to the appropriate m_value to target other versions of Windows.
    #endif
    #include <tchar.h>
    #include <windows.h>
#endif

#ifdef __linux__
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#endif

#include <stdio.h>

#include <string>
#include <vector>
#include <map>
#include <iostream>

#ifndef WIN32
    #include <unistd.h>
#endif

#include "indicore3.h"

#include "AutoRelease.h"