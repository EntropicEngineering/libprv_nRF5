# Require out-of-source builds
file(TO_CMAKE_PATH "${PROJECT_BINARY_DIR}/CMakeLists.txt" LOC_PATH)
if (EXISTS LOC_PATH)
    message(FATAL_ERROR "You cannot build in a source directory (or any directory with a CMakeLists.txt file). Please make a build subdirectory. Feel free to remove CMakeCache.txt and CMakeFiles.")
endif ()

# Set a default build type if none was specified
set(default_build_type "Debug")

if (NOT CMAKE_BUILD_TYPE)
    get_filename_component(CWD "${PROJECT_BINARY_DIR}" NAME)
    string(TOLOWER "${CWD}" cwd)
    if (${cwd} MATCHES .*debug.*)
        set(CMAKE_BUILD_TYPE "Debug" CACHE
                STRING "Build type." FORCE)
    elseif(${cwd} MATCHES .*release.*)
        set(CMAKE_BUILD_TYPE "Release" CACHE
                STRING "Build type." FORCE)
    else()
        set(CMAKE_BUILD_TYPE "${default_build_type}" CACHE
                STRING "Build type." FORCE)
    endif()
    message(STATUS "Set build type to '${CMAKE_BUILD_TYPE}'.")
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
            "${CMAKE_CURRENT_SOURCE_DIR}/external/nRF5_SDK*"
            "${CMAKE_CURRENT_SOURCE_DIR}/external/nRF5SDK*"
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

if(NOT EXISTS "${CMAKE_PROJECT_CONFIG}")
    set(CMAKE_PROJECT_CONFIG "${CMAKE_MODULE_PATH}/project_config.cmake")
endif()

set(CMAKE_PROJECT_INCLUDE_BEFORE "${CMAKE_MODULE_PATH}/arm.toolchain.cmake")
set(CMAKE_PROJECT_INCLUDE "${CMAKE_PROJECT_CONFIG}")

set(LIBPRV true)
