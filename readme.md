# nRF5 SDK CMake
Entropic Engineering's CMake build scripts for the Nordic nRF5 SDK.

Some helper functionality we've found helpful:

* These scritps will automatically locate `arm-none-eabi-gcc` if it is on your path.

* By default, CMAKE_BUILD_TYPE is set to `Debug` (in `biolerplate.cmake`).
Additionally, when the build type is `Debug`, a `DEBUG` macro is defined (as `1`).

* The `pca10056_sdk_functions.cmake` file adds compile flags for the associated board.
It also adds convenience make targets `make sdk_config`, which launches the CMSIS Config Wizard,
and `make flash`, which will flash the Nordic dev board, or anything attached to it.

# Installation Instructions

## As a fork
Fork this repository and create an `external` directory in the project root.

## As a submodule
Create an `external` directory in the project repository and add this repo as a submodule into that `external` directory.

## nRF5 SDK
Download manually from https://www.nordicsemi.com/Software-and-tools/Software/nRF5-SDK

Unpack and place in the `external` directory. CMake looks for a directory that begins with `external/nRF5_SDK*`.
Alternatively, pass `-DSDK_ROOT=<SDK directory>` when calling `cmake`.

## GNU Arm embedded toolchain

### Install via homebrew on macOS
https://github.com/ARMmbed/homebrew-formulae

```bash
$ brew tap ArmMbed/homebrew-formulae
$ brew install arm-none-eabi-gcc
```

### Install via Linux package manager
Most Linux distros will provide a package for `gcc-arm-none-eabi` which can be installed via the default system package manager, e.g. `sudo apt install gcc-arm-none-eabi`.

### Download From ARM
Download from https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads

Unpack and install where desired (e.g. `/usr/local` on OS X).
Then, either symlink (don't copy) everything from the `bin` directory of the install to your path
(e.g. `ln -s /usr/local/gcc-arm-none-eabi-8-2019-q3-update/bin/arm-none-eabi-* /usr/local/bin/`),
or set the `GNUARMEMB_TOOLCHAIN_PATH` environment variable.

# Build missing SDK dependency
There is one external dependency for the nRF5 SDK that needs to be manually built once.
To do so, modify the following commands appropriately for your system:
```bash
$ cd external/nRF5_SDK_16.0.0_98a08e2/external/micro-ecc
$ git clone https://github.com/kmackay/micro-ecc.git
$ GNU_INSTALL_ROOT=/usr/local/gcc-arm-none-eabi-8-2019-q3-update/bin/ make -C nrf52hf_armgcc/armgcc/
$ cd -
```

# CMake
Install CMake 3.15+ on your local system. CLion comes bundled with its own version.

Note : The cmake included in your *nix distro may be too old - see below.

To install system-wide, Kitware (makers of CMake) provides additional helpful resources: https://apt.kitware.com/ & https://pypi.org/project/cmake/


# Building
`cd` into project directory (e.g. `cd spi_uart`), make a build directory (i.e. `mkdir build`),
then `cd build`, `cmake`, and `make`

To make a release build (which you should DEFINITELY do if you have V2 board as the debug uart and channel 1 share pins (badly))

`cmake . -B build -DCMAKE_BUILD_TYPE=Release`

# Flashing
Flashing uses `nrfjprog`, which is available as part of the
[nRF Command Line Tools](https://www.nordicsemi.com/Software-and-tools/Development-Tools/nRF-Command-Line-Tools).
For convenience, the `*_sdk_functions` cmake modules provide a make target for flashing, via `make flash`.

Alternatively, the manual flashing command is:
`nrfjprog -f nrf52 --program "${name}.hex" --sectorerase --verify --fast --reset`

If flashing fails on a new chip, it may be write protected.
It can be unlocked with `nrfjprog -f nrf52 --recover`.

# Starting a new project

## `CMakeLists.txt`
Set version requirements, then add required boilerplate, then define project:
```cmake
cmake_minimum_required(VERSION 3.15)

# Tell CMake where to look for includes
# Select one of:
#set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/external/nRF5_CMake/cmake)
# OR
#set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(boilerplate NO_POLICY_SCOPE)

project(spi_uart VERSION 0.0.1
        DESCRIPTION "simple spi to uart bridge"
        LANGUAGES C CXX ASM)
```
Finally, define executable, add sources, etc. (left as an exercise for the reader)

`include(pca10056_sdk_functions)` to get helper functions for SDK includes and board flags.
See `cmake/pca10056_sdk_functions.cmake` for details.

## `config` directory
### `app_config.h`
By convention, this is used to define the pins used, default values, app-wide constants, etc.
It should be `#include`'d in `main.c`.

### `sdk_config.h`
This file enables/disables the various library features.
Copy the default from `<SDK Root>/config/<chip>/config/sdk_config.h`.
It can be edited using CMSIS Configuration Wizard from Arm, included under `<SDk Root>/external_tools`.
For convenience, the `*_sdk_functions` cmake module provides a make target for editing, via `make sdk_config`.

### `gcc_nrf52.ld`
This is the linker file that indicates what memory regions are used for what purpose.
Copy the default from `<SDK Root>/config/<chip>/armgcc/generic_gcc_nrf52.ld`.
