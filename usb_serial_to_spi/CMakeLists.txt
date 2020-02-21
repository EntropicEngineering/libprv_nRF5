cmake_minimum_required(VERSION 3.15)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../cmake)
include(boilerplate NO_POLICY_SCOPE)

project(usb_serial_to_spi VERSION 0.1.0
        DESCRIPTION "simple usb-serial to spi bridge"
        LANGUAGES C CXX ASM)

set(NAME "${PROJECT_NAME}" CACHE STRING "")
add_executable("${NAME}")
set_target_properties("${NAME}" PROPERTIES SUFFIX ".elf")

# Include template functions
include(pca10056_sdk_functions)
pca10056_sdk_target_compile_definitions("${NAME}")
pca10056_generate_convenience_functions("${NAME}")

target_sources("${NAME}" PRIVATE
        "${SDK_ROOT}/modules/nrfx/mdk/gcc_startup_nrf52840.S"
        "${SDK_ROOT}/components/libraries/log/src/nrf_log_backend_serial.c"
        "${SDK_ROOT}/components/libraries/log/src/nrf_log_backend_uart.c"
        "${SDK_ROOT}/components/libraries/log/src/nrf_log_default_backends.c"
        "${SDK_ROOT}/components/libraries/log/src/nrf_log_frontend.c"
        "${SDK_ROOT}/components/libraries/log/src/nrf_log_str_formatter.c"
        "${SDK_ROOT}/components/boards/boards.c"
        "${SDK_ROOT}/components/libraries/button/app_button.c"
        "${SDK_ROOT}/components/libraries/util/app_error.c"
        "${SDK_ROOT}/components/libraries/util/app_error_handler_gcc.c"
        "${SDK_ROOT}/components/libraries/util/app_error_weak.c"
        "${SDK_ROOT}/components/libraries/fifo/app_fifo.c"
        "${SDK_ROOT}/components/libraries/scheduler/app_scheduler.c"
        "${SDK_ROOT}/components/libraries/timer/app_timer2.c"
        "${SDK_ROOT}/components/libraries/uart/app_uart_fifo.c"
        "${SDK_ROOT}/components/libraries/usbd/app_usbd.c"
        "${SDK_ROOT}/components/libraries/usbd/class/cdc/acm/app_usbd_cdc_acm.c"
        "${SDK_ROOT}/components/libraries/usbd/app_usbd_core.c"
        "${SDK_ROOT}/components/libraries/usbd/app_usbd_serial_num.c"
        "${SDK_ROOT}/components/libraries/usbd/app_usbd_string_desc.c"
        "${SDK_ROOT}/components/libraries/util/app_util_platform.c"
        "${SDK_ROOT}/components/libraries/timer/drv_rtc.c"
        "${SDK_ROOT}/external/fnmatch/fnmatch.c"
        "${SDK_ROOT}/components/libraries/hardfault/nrf52/handler/hardfault_handler_gcc.c"
        "${SDK_ROOT}/components/libraries/hardfault/hardfault_implementation.c"
        "${SDK_ROOT}/components/libraries/util/nrf_assert.c"
        "${SDK_ROOT}/components/libraries/atomic_fifo/nrf_atfifo.c"
        "${SDK_ROOT}/components/libraries/atomic/nrf_atomic.c"
        "${SDK_ROOT}/components/libraries/balloc/nrf_balloc.c"
        "${SDK_ROOT}/components/libraries/cli/nrf_cli.c"
        "${SDK_ROOT}/components/libraries/cli/uart/nrf_cli_uart.c"
        "${SDK_ROOT}/external/fprintf/nrf_fprintf.c"
        "${SDK_ROOT}/external/fprintf/nrf_fprintf_format.c"
        "${SDK_ROOT}/components/libraries/memobj/nrf_memobj.c"
        "${SDK_ROOT}/components/libraries/pwr_mgmt/nrf_pwr_mgmt.c"
        "${SDK_ROOT}/components/libraries/queue/nrf_queue.c"
        "${SDK_ROOT}/components/libraries/ringbuf/nrf_ringbuf.c"
        "${SDK_ROOT}/components/libraries/experimental_section_vars/nrf_section_iter.c"
        "${SDK_ROOT}/components/libraries/sortlist/nrf_sortlist.c"
        "${SDK_ROOT}/components/libraries/strerror/nrf_strerror.c"
        "${SDK_ROOT}/integration/nrfx/legacy/nrf_drv_clock.c"
        "${SDK_ROOT}/integration/nrfx/legacy/nrf_drv_power.c"
        "${SDK_ROOT}/integration/nrfx/legacy/nrf_drv_uart.c"
        "${SDK_ROOT}/components/drivers_nrf/nrf_soc_nosd/nrf_nvic.c"
        "${SDK_ROOT}/components/drivers_nrf/nrf_soc_nosd/nrf_soc.c"
        "${SDK_ROOT}/modules/nrfx/soc/nrfx_atomic.c"
        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_clock.c"
        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_gpiote.c"
        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_power.c"
        "${SDK_ROOT}/modules/nrfx/drivers/src/prs/nrfx_prs.c"
        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_spim.c"
        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_systick.c"
        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_uart.c"
        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_uarte.c"
        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_usbd.c"
        "${SDK_ROOT}/components/libraries/bsp/bsp.c"
        "${SDK_ROOT}/components/libraries/bsp/bsp_cli.c"
        "${CMAKE_SOURCE_DIR}/src/main.c"
        "${SDK_ROOT}/modules/nrfx/mdk/system_nrf52840.c"
        "${SDK_ROOT}/external/utf_converter/utf.c"
        )
target_link_directories(${NAME} BEFORE PUBLIC
        "${SDK_ROOT}/modules/nrfx/mdk"
        )
target_include_directories("${NAME}" PRIVATE
        "${SDK_ROOT}/components"
        "${SDK_ROOT}/components/libraries/cli"
        "${SDK_ROOT}/modules/nrfx/mdk"
        "${SDK_ROOT}/components/libraries/scheduler"
        "${SDK_ROOT}/components/libraries/queue"
        "${SDK_ROOT}/components/libraries/pwr_mgmt"
        "${SDK_ROOT}/components/libraries/fifo"
        "${SDK_ROOT}/components/libraries/sortlist"
        "${SDK_ROOT}/components/libraries/strerror"
        "${SDK_ROOT}/components/toolchain/cmsis/include"
        "${SDK_ROOT}/components/libraries/timer"
        "${SDK_ROOT}/components/libraries/util"
        "${SDK_ROOT}/components/libraries/bsp"
        "${CMAKE_SOURCE_DIR}/config"
        "${SDK_ROOT}/components/libraries/usbd/class/cdc"
        "${SDK_ROOT}/components/libraries/balloc"
        "${SDK_ROOT}/components/libraries/ringbuf"
        "${SDK_ROOT}/components/libraries/hardfault/nrf52"
        "${SDK_ROOT}/components/libraries/cli/uart"
        "${SDK_ROOT}/components/libraries/hardfault"
        "${SDK_ROOT}/components/libraries/uart"
        "${SDK_ROOT}/components/libraries/log"
        "${SDK_ROOT}/components/libraries/button"
        "${SDK_ROOT}/modules/nrfx"
        "${SDK_ROOT}/components/libraries/experimental_section_vars"
        "${SDK_ROOT}/integration/nrfx/legacy"
        "${SDK_ROOT}/components/libraries/usbd"
        "${SDK_ROOT}/components/libraries/usbd/class/cdc/acm"
        "${SDK_ROOT}/components/libraries/mutex"
        "${CMAKE_SOURCE_DIR}/src"
        "${SDK_ROOT}/components/libraries/delay"
        "${SDK_ROOT}/external/segger_rtt"
        "${SDK_ROOT}/components/libraries/atomic_fifo"
        "${SDK_ROOT}/components/drivers_nrf/nrf_soc_nosd"
        "${SDK_ROOT}/components/libraries/atomic"
        "${SDK_ROOT}/components/boards"
        "${SDK_ROOT}/components/libraries/memobj"
        "${SDK_ROOT}/external/fnmatch"
        "${SDK_ROOT}/integration/nrfx"
        "${SDK_ROOT}/external/utf_converter"
        "${SDK_ROOT}/modules/nrfx/drivers/include"
        "${SDK_ROOT}/modules/nrfx/hal"
        "${SDK_ROOT}/external/fprintf"
        "${SDK_ROOT}/components/libraries/log/src"
        )

target_compile_options("${NAME}" PRIVATE -Wall $<$<CONFIG:Debug>:-ggdb>)

# Add linker script
target_link_options("${NAME}" PRIVATE
        "-T${CMAKE_SOURCE_DIR}/config/gcc_nrf52.ld"
        "-Wl,-Map=${NAME}.map"
        )
