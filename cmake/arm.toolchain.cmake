set(ARM_TOOLCHAIN arm-none-eabi)
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR ARM)

set(ext "${CMAKE_EXECUTABLE_SUFFIX}")

unset(CMAKE_C_COMPILER)

# Try to find arm gcc from env
set(ARM_TOOLCHAIN_PATH "$ENV{GNUARMEMB_TOOLCHAIN_PATH}" CACHE PATH "arm-none-eabi-<version> install location")
if (EXISTS "${ARM_TOOLCHAIN_PATH}")
    get_filename_component(CMAKE_C_COMPILER "${ARM_TOOLCHAIN_PATH}/bin/${ARM_TOOLCHAIN}-gcc${ext}" REALPATH)
    get_filename_component(ARM_TOOLCHAIN_BIN "${CMAKE_C_COMPILER}" DIRECTORY CACHE)
endif ()

# Try to find arm gcc in path
if(NOT EXISTS "${CMAKE_C_COMPILER}")
    get_filename_component(_C_COMPILER ${ARM_TOOLCHAIN}-gcc${ext} PROGRAM)
    if(EXISTS "${_C_COMPILER}")
        get_filename_component(CMAKE_C_COMPILER "${_C_COMPILER}" REALPATH CACHE)
        get_filename_component(ARM_TOOLCHAIN_BIN "${CMAKE_C_COMPILER}" DIRECTORY CACHE)
    endif()
endif()

if(NOT EXISTS "${CMAKE_C_COMPILER}")
    message(SEND_ERROR "Ensure arm-none-eabi-gcc is on your path, or set the GNUARMEMB_TOOLCHAIN_PATH environment variable")
else()
    set(CMAKE_CXX_COMPILER "${ARM_TOOLCHAIN_BIN}/${ARM_TOOLCHAIN}-g++${ext}" CACHE PATH "")
    set(CMAKE_ASM_COMPILER "${CMAKE_C_COMPILER}" CACHE PATH "")
    set(SIZE_FUNC "${ARM_TOOLCHAIN_BIN}/${ARM_TOOLCHAIN}-size" CACHE PATH "")
endif()

# Perform compiler test without linker, since we're cross-compiling
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(ARM_COMPILER_FLAGS
        -mcpu=cortex-m4
        -mthumb
        -mabi=aapcs
        -mfloat-abi=hard
        -mfpu=fpv4-sp-d16
        )

set(ARM_OPTIMIZATION_FLAGS
        -fno-common
        -ffunction-sections
        -fdata-sections
        -fno-strict-aliasing
        -fno-builtin
        -fshort-enums
        )

set(ARM_LINKER_FLAGS
        -Wl,--gc-sections
        --specs=nano.specs
        --specs=nosys.specs
        )


# Convert into proper space-separated strings
macro(set_flags var)
    string(JOIN " " ${var} ${ARGN})
endmacro()

set_flags(CMAKE_C_FLAGS_INIT ${ARM_COMPILER_FLAGS} ${ARM_OPTIMIZATION_FLAGS})
set_flags(CMAKE_C_FLAGS_DEBUG_INIT -ggdb)
set_flags(CMAKE_C_FLAGS_RELEASE_INIT -Os)

set(CMAKE_CXX_FLAGS_INIT ${CMAKE_C_FLAGS_INIT})
set(CMAKE_ASM_FLAGS_INIT ${CMAKE_C_FLAGS_INIT})

set_flags(CMAKE_EXE_LINKER_FLAGS_INIT ${ARM_LINKER_FLAGS})
