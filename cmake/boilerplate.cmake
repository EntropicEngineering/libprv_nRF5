# pragma once
include_guard(GLOBAL)

cmake_minimum_required(VERSION 3.6...3.16)
if(${CMAKE_VERSION} VERSION_LESS 3.12)
    cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})
endif ()

### Require out-of-source builds
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

if (NOT EXISTS "${SDK_ROOT}")
    file(GLOB _SDK_ROOT
            "${CMAKE_SOURCE_DIR}/external/nRF5_SDK*"
            "${CMAKE_SOURCE_DIR}/external/nRF5SDK*"
            )
    if (EXISTS "${_SDK_ROOT}")
        get_filename_component(SDK_ROOT "${_SDK_ROOT}" REALPATH CACHE)
    endif ()
endif ()

if(NOT EXISTS "${SDK_ROOT}")
    message(SEND_ERROR "Set SDK_ROOT or symlink/copy SDK directory into 'external' directory in root of repo")
endif()

# On macOS, have cmake look for unix libraries first
set(CMAKE_FIND_FRAMEWORK LAST)
set(CMAKE_FIND_APPBUNDLE LAST)

include(arm.toolchain NO_POLICY_SCOPE)

# Precompiler definitions
add_compile_definitions(
        APP_TIMER_V2
        APP_TIMER_V2_RTC1_ENABLED
        CONFIG_GPIO_AS_PINRESET
        FLOAT_ABI_HARD
        MBEDTLS_CONFIG_FILE="nrf_crypto_mbedtls_config.h"
        NRF_CRYPTO_MAX_INSTANCE_COUNT=1
        uECC_ENABLE_VLI_API=0
        uECC_OPTIMIZATION_LEVEL=3
        uECC_SQUARE_FUNC=0
        uECC_SUPPORT_COMPRESSED_POINT=0
        uECC_VLI_NATIVE_LITTLE_ENDIAN=1
)

link_libraries(
        c
        nosys
        m
)

macro(set_softdevice softdevice)
    if (EXISTS "${SDK_ROOT}/components/softdevice/${softdevice}/hex/${softdevice}_nrf52_7.0.1_softdevice.hex")
        string(TOUPPER ${softdevice} SOFTDEVICE_FLAG)
        add_compile_definitions(
                SOFTDEVICE_PRESENT
                NRF_SD_BLE_API_VERSION=7
                ${SOFTDEVICE_FLAG}
        )
        set(SOFTDEVICE ${softdevice})
    else()
        message(SEND_ERROR "Invalid softdevice: ${softdevice}")
    endif ()
endmacro()

macro(set_heap_size heap_size)
    add_compile_definitions(__HEAP_SIZE=${heap_size})
endmacro()

macro(set_stack_size stack_size)
    add_compile_definitions(__STACK_SIZE=${stack_size})
endmacro()
