# pragma once
include_guard(GLOBAL)

if(CMAKE_VERSION VERSION_LESS 3.12)
    cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})
endif ()

# Require out-of-source builds
file(TO_CMAKE_PATH "${PROJECT_BINARY_DIR}/CMakeLists.txt" LOC_PATH)
if (EXISTS "${LOC_PATH}")
    message(FATAL_ERROR "You cannot build in a source directory (or any directory with a CMakeLists.txt file). Please make a build subdirectory. Feel free to remove CMakeCache.txt and CMakeFiles.")
endif ()

# Set a default build type if none was specified
set(default_build_type "Debug")

if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Setting build type to '${default_build_type}' as none was specified.")
    set(CMAKE_BUILD_TYPE "${default_build_type}" CACHE
            STRING "Choose the type of build." FORCE)
endif ()

# Enable '#if DEBUG' via preprocessor
if (CMAKE_BUILD_TYPE MATCHES Debug)
    add_compile_definitions(DEBUG=1)
    add_compile_definitions(DEBUG_NRF=1)
endif ()

set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 11)

# Find nRF5 SDK
if (NOT EXISTS "${SDK_ROOT}")
    file(GLOB _SDK_ROOT CONFIGURE_DEPENDS
            "${CMAKE_SOURCE_DIR}/external/nRF5_SDK*"
            "${CMAKE_SOURCE_DIR}/external/nRF5SDK*"
            )
    if (EXISTS "${_SDK_ROOT}")
        get_filename_component(SDK_ROOT "${_SDK_ROOT}" ABSOLUTE CACHE)
    endif ()
endif ()

if(NOT EXISTS "${SDK_ROOT}")
    message(FATAL_ERROR "Set SDK_ROOT or symlink/copy SDK directory into 'external' directory in root of repo")
else()
    message(STATUS "Found SDK root directory ${SDK_ROOT}")
endif()

set(CMAKE_PROJECT_INCLUDE_BEFORE "${CMAKE_MODULE_PATH}/arm.toolchain.cmake")
set(CMAKE_PROJECT_INCLUDE "${CMAKE_MODULE_PATH}/project_config.cmake")
