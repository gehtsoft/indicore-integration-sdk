cmake_minimum_required (VERSION 2.6)

set (PROJECT LoadIndicatorsList)

project (${PROJECT})

add_definitions(-ggdb)
set(CMAKE_BUILD_TYPE Debug)

if (${CMAKE_SYSTEM} MATCHES "Darwin")
    SET (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ -std=c++11")
else()
    SET (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -std=c++11")
endif()

if (DEFINED Mac32)
    set (ARCHFLAGS "-arch i386 -DMac32")
elseif (${CMAKE_SYSTEM} MATCHES "Linux" AND ${CMAKE_SYSTEM_PROCESSOR} MATCHES "i[3-6]86")
    set (ARCHFLAGS "-march=i486")
else ()
    set (ARCHFLAGS "")
endif ()

if (${CMAKE_SYSTEM} MATCHES "Linux")
    set (SHAREDSUFFIX "so")
elseif (${CMAKE_SYSTEM} MATCHES "Darwin")
    set (SHAREDSUFFIX "dylib")
endif ()

set (INDICORE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../..")

set (EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/bin)
set (LIBRARY_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/bin)

set (CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS} ${ARCHFLAGS}")
set (CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS} ${ARCHFLAGS}")

set (CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS} ${ARCHFLAGS}")
set (CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS} ${ARCHFLAGS}")

set (CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS} ${ARCHFLAGS}")
set (CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS} ${ARCHFLAGS}")

if (NOT CMAKE_BUILD_TYPE)
    set (CMAKE_BUILD_TYPE Release CACHE STRING
            "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
            FORCE
            )
endif (NOT CMAKE_BUILD_TYPE)

include_directories (
        ${INDICORE_DIR}/include
        )

link_directories (
        ${INDICORE_DIR}/lib
)

set (HEADERS
        source/stdafx.h
        )

set (SOURCES
        source/LoadIndicatorsList.cpp
        source/Utils.cpp
        )

if (NOT CMAKE_CROSSCOMPILING)
    add_executable (${PROJECT} ${HEADERS} ${SOURCES})
else ()
    add_library (${PROJECT} STATIC ${HEADERS} ${SOURCES})
endif ()

if (${CMAKE_SYSTEM} MATCHES "Linux")
    target_link_libraries (${PROJECT} indicore)
elseif (${CMAKE_SYSTEM} MATCHES "Darwin")
    target_link_libraries (${PROJECT} indicore)
endif ()

# Post - build event to create symlinks for shared objects
add_custom_command (TARGET ${PROJECT}
        POST_BUILD
        COMMAND find ${INDICORE_DIR}/lib -name lib*.${SHAREDSUFFIX} -exec ln -sf {} \;

        WORKING_DIRECTORY ${EXECUTABLE_OUTPUT_PATH}
        VERBATIM
        )

if (${CMAKE_SYSTEM} MATCHES "Linux")
    set_target_properties (${PROJECT} PROPERTIES
            LINK_FLAGS -Wl,-rpath,.
            )
elseif (${CMAKE_SYSTEM} MATCHES "Darwin")
    set_target_properties (${PROJECT} PROPERTIES
            BUILD_WITH_INSTALL_RPATH 1
            INSTALL_NAME_DIR "@rpath"
            LINK_FLAGS "-Wl,-rpath,@loader_path,-rpath,./"
            )
endif ()

