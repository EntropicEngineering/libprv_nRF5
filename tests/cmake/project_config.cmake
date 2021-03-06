# pragma once
include_guard(GLOBAL)

# Configure project
add_executable("${PROJECT_NAME}")

# On macOS, have cmake look for unix libraries first
set(CMAKE_FIND_FRAMEWORK LAST)
set(CMAKE_FIND_APPBUNDLE LAST)

# Precompiler definitions
target_compile_definitions("${PROJECT_NAME}" PRIVATE
        SUPPRESS_INLINE_IMPLEMENTATION
        USE_APP_CONFIG
        HARDWARE_REV=${HARDWARE_REV}
        APP_TIMER_V2
        APP_TIMER_V2_RTC1_ENABLED
        CONFIG_GPIO_AS_PINRESET
        FLOAT_ABI_HARD
        NRF_DFU_SVCI_ENABLED
        $<$<BOOL:${SOFTDEVICE}>:NRF_DFU_TRANSPORT_BLE=1>
        MBEDTLS_CONFIG_FILE="nrf_crypto_mbedtls_config.h"
        NRF_CRYPTO_MAX_INSTANCE_COUNT=1
        uECC_ENABLE_VLI_API=0
        uECC_OPTIMIZATION_LEVEL=3
        uECC_SQUARE_FUNC=0
        uECC_SUPPORT_COMPRESSED_POINT=0
        uECC_VLI_NATIVE_LITTLE_ENDIAN=1
)

target_link_libraries("${PROJECT_NAME}"
        Catch2::Catch2
        c
        m
)

if(SOFTDEVICE)
    file (GLOB SD_PATH "${SDK_ROOT}/components/softdevice/${SOFTDEVICE}/hex/${SOFTDEVICE}_nrf52_${SD_VERSION}_softdevice.hex")
    if (EXISTS "${SD_PATH}")
        string(SUBSTRING "${SD_VERSION}" 0 1 SD_MAJOR_VERSION)
        string(TOUPPER ${SOFTDEVICE} SOFTDEVICE_FLAG)
        target_compile_definitions("${PROJECT_NAME}" PRIVATE
                SOFTDEVICE_PRESENT
                NRF_SD_BLE_API_VERSION=${SD_MAJOR_VERSION}
                ${SOFTDEVICE_FLAG}
                )
    else()
        message(FATAL_ERROR "Invalid softdevice: ${SOFTDEVICE} version ${SD_VERSION}")
    endif()
endif()

if(ENABLE_SPIM3)
    target_compile_definitions("${PROJECT_NAME}" PRIVATE NRFX_SPIM3_NRF52840_ANOMALY_198_WORKAROUND_ENABLED=0)
endif()

if(HEAP_SIZE)
    target_compile_definitions("${PROJECT_NAME}" PRIVATE __HEAP_SIZE=${HEAP_SIZE})
endif()

if(STACK_SIZE)
    target_compile_definitions("${PROJECT_NAME}" PRIVATE __STACK_SIZE=${STACK_SIZE})
endif()

if(DEFINED ENABLE_USB_SERIAL)
    target_compile_definitions("${PROJECT_NAME}" PRIVATE ENABLE_USB_SERIAL=${ENABLE_USB_SERIAL})
endif()

if(DEFINED ENABLE_BOOTLOADER)
    target_compile_definitions("${PROJECT_NAME}" PRIVATE ENABLE_BOOTLOADER=${ENABLE_BOOTLOADER})
endif()

get_filename_component(LIB_ROOT "${CMAKE_MODULE_PATH}/../.." ABSOLUTE CACHE)
message("LIB_ROOT is ${LIB_ROOT}")

target_sources("${PROJECT_NAME}" PRIVATE
#        "${SDK_ROOT}/modules/nrfx/mdk/gcc_startup_nrf52840.S"
#        "$<$<CONFIG:Debug>:${SDK_ROOT}/components/libraries/log/src/nrf_log_backend_serial.c>"
#        "$<$<CONFIG:Debug>:${SDK_ROOT}/components/libraries/log/src/nrf_log_backend_uart.c>"
#        "$<$<CONFIG:Debug>:${SDK_ROOT}/components/libraries/log/src/nrf_log_backend_rtt.c>"
#        "$<$<CONFIG:Debug>:${SDK_ROOT}/components/libraries/log/src/nrf_log_default_backends.c>"
#        "$<$<CONFIG:Debug>:${SDK_ROOT}/components/libraries/log/src/nrf_log_frontend.c>"
#        "$<$<CONFIG:Debug>:${SDK_ROOT}/components/libraries/log/src/nrf_log_str_formatter.c>"
#        "$<$<CONFIG:Debug>:${SDK_ROOT}/components/libraries/stack_guard/nrf_stack_guard.c>"
#        "$<$<CONFIG:Debug>:${SDK_ROOT}/external/segger_rtt/SEGGER_RTT.c>"
#        "$<$<CONFIG:Debug>:${SDK_ROOT}/external/segger_rtt/SEGGER_RTT_Syscalls_GCC.c>"
#        "$<$<CONFIG:Debug>:${SDK_ROOT}/external/segger_rtt/SEGGER_RTT_printf.c>"
#        "${SDK_ROOT}/components/libraries/mpu/nrf_mpu_lib.c"
#        "${SDK_ROOT}/components/boards/boards.c"
#        "${SDK_ROOT}/components/libraries/button/app_button.c"
#        "${SDK_ROOT}/components/libraries/crc16/crc16.c"
#        "${SDK_ROOT}/components/libraries/util/app_error.c"
#        "${SDK_ROOT}/components/libraries/util/app_error_handler_gcc.c"
#        "${SDK_ROOT}/components/libraries/util/app_error_weak.c"
#        "${SDK_ROOT}/components/libraries/util/app_util_platform.c"
#        "${SDK_ROOT}/components/libraries/util/nrf_assert.c"
#        "${SDK_ROOT}/components/libraries/fifo/app_fifo.c"
#        "${SDK_ROOT}/components/libraries/scheduler/app_scheduler.c"
#        "${SDK_ROOT}/components/libraries/timer/app_timer2.c"
#        "${SDK_ROOT}/components/libraries/timer/drv_rtc.c"
#        "${SDK_ROOT}/components/libraries/usbd/app_usbd.c"
#        "${SDK_ROOT}/components/libraries/usbd/class/cdc/acm/app_usbd_cdc_acm.c"
#        "${SDK_ROOT}/components/libraries/usbd/app_usbd_core.c"
#        "${SDK_ROOT}/components/libraries/usbd/app_usbd_serial_num.c"
#        "${SDK_ROOT}/components/libraries/usbd/app_usbd_string_desc.c"
#        "${SDK_ROOT}/external/fnmatch/fnmatch.c"
#        "${SDK_ROOT}/components/libraries/hardfault/nrf52/handler/hardfault_handler_gcc.c"
#        "${SDK_ROOT}/components/libraries/hardfault/hardfault_implementation.c"
#        "${SDK_ROOT}/components/libraries/atomic_fifo/nrf_atfifo.c"
#        "${SDK_ROOT}/components/libraries/atomic_flags/nrf_atflags.c"
#        "${SDK_ROOT}/components/libraries/atomic/nrf_atomic.c"
#        "${SDK_ROOT}/components/libraries/balloc/nrf_balloc.c"
#        "${SDK_ROOT}/external/fprintf/nrf_fprintf.c"
#        "${SDK_ROOT}/external/fprintf/nrf_fprintf_format.c"
#        "${SDK_ROOT}/external/thedotfactory_fonts/orkney24pts.c"
#        "${SDK_ROOT}/external/thedotfactory_fonts/orkney8pts.c"
#        "${SDK_ROOT}/components/libraries/fds/fds.c"
#        "${SDK_ROOT}/components/libraries/fstorage/nrf_fstorage.c"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/libraries/fstorage/nrf_fstorage_sd.c>"
#        "$<$<NOT:$<BOOL:${SOFTDEVICE}>>:${SDK_ROOT}/components/libraries/fstorage/nrf_fstorage_nvmc.c>"
#        "$<$<NOT:$<BOOL:${SOFTDEVICE}>>:${SDK_ROOT}/components/libraries/fstorage/nrf_fstorage_nvmc.c>"
#        "$<$<NOT:$<BOOL:${SOFTDEVICE}>>:${SDK_ROOT}/modules/nrfx/hal/nrf_nvmc.c>"
#        "${SDK_ROOT}/components/libraries/gfx/nrf_gfx.c"
#        "${SDK_ROOT}/components/libraries/memobj/nrf_memobj.c"
#        "${SDK_ROOT}/components/libraries/pwr_mgmt/nrf_pwr_mgmt.c"
#        "${SDK_ROOT}/components/libraries/queue/nrf_queue.c"
#        "${SDK_ROOT}/components/libraries/ringbuf/nrf_ringbuf.c"
#        "${SDK_ROOT}/components/libraries/experimental_section_vars/nrf_section_iter.c"
#        "${SDK_ROOT}/components/libraries/sortlist/nrf_sortlist.c"
#        "${SDK_ROOT}/components/libraries/strerror/nrf_strerror.c"
#        "${SDK_ROOT}/integration/nrfx/legacy/nrf_drv_clock.c"
#        "${SDK_ROOT}/integration/nrfx/legacy/nrf_drv_power.c"
##        "${SDK_ROOT}/integration/nrfx/legacy/nrf_drv_uart.c"
#        "$<$<NOT:$<BOOL:${SOFTDEVICE}>>:${SDK_ROOT}/components/drivers_nrf/nrf_soc_nosd/nrf_nvic.c>"
#        "$<$<NOT:$<BOOL:${SOFTDEVICE}>>:${SDK_ROOT}/components/drivers_nrf/nrf_soc_nosd/nrf_soc.c>"
#        "${SDK_ROOT}/modules/nrfx/soc/nrfx_atomic.c"
#        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_clock.c"
#        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_gpiote.c"
#        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_power.c"
#        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_ppi.c"
#        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_pwm.c"
#        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_rtc.c"
#        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_spim.c"
#        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_spis.c"
#        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_swi.c"
#        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_systick.c"
#        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_temp.c"
#        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_timer.c"
#        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_twim.c"
#        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_uart.c"
#        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_uarte.c"
#        "${SDK_ROOT}/modules/nrfx/drivers/src/nrfx_usbd.c"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/libraries/bootloader/dfu/nrf_dfu_svci.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/common/ble_advdata.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/ble_advertising/ble_advertising.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/common/ble_conn_params.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/common/ble_conn_state.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/common/ble_srv_common.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/nrf_ble_gatt/nrf_ble_gatt.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/nrf_ble_qwr/nrf_ble_qwr.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/ble_link_ctx_manager/ble_link_ctx_manager.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/peer_manager/auth_status_tracker.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/peer_manager/gatt_cache_manager.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/peer_manager/gatts_cache_manager.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/peer_manager/id_manager.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/peer_manager/peer_data_storage.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/peer_manager/peer_database.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/peer_manager/peer_id.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/peer_manager/peer_manager.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/peer_manager/peer_manager_handler.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/peer_manager/pm_buffer.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/peer_manager/security_dispatcher.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/peer_manager/security_manager.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/ble_services/ble_dfu/ble_dfu.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/ble_services/ble_dfu/ble_dfu_bonded.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/ble_services/ble_dfu/ble_dfu_unbonded.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/ble_services/ble_nus/ble_nus.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/softdevice/common/nrf_sdh.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/softdevice/common/nrf_sdh_ble.c>"
#        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/softdevice/common/nrf_sdh_soc.c>"
#        "${LIB_ROOT}/src/prv_power_manager.c"
#        "${LIB_ROOT}/src/prv_temperature.c"
#        "${LIB_ROOT}/src/prv_debouncer.c"
#        "${LIB_ROOT}/src/prv_timers.c"
#        "${LIB_ROOT}/src/prv_utils.c"
#        "${LIB_ROOT}/src/crc8.c"
#        "${SDK_ROOT}/modules/nrfx/mdk/system_nrf52840.c"
        )

target_include_directories("${PROJECT_NAME}" PRIVATE
        "$<$<BOOL:${INCLUDE_OVERRIDES}>:${INCLUDE_OVERRIDES}>"
        "${LIB_ROOT}/config"
        "${LIB_ROOT}/src"
        "${SDK_ROOT}/components"
        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/softdevice/common>"
        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/softdevice/s140/headers>"
        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/softdevice/s140/headers/nrf52>"
        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/peer_manager>"
        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/ble_services/ble_dfu>"
        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/libraries/bootloader/ble_dfu>"
        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/ble_services/ble_nus>"
        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/ble_link_ctx_manager>"
        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/common>"
        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/ble_advertising>"
        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/nrf_ble_gatt>"
        "$<$<BOOL:${SOFTDEVICE}>:${SDK_ROOT}/components/ble/nrf_ble_qwr>"
        "$<$<CONFIG:Debug>:${SDK_ROOT}/components/libraries/stack_guard>"
        "$<$<CONFIG:Debug>:${SDK_ROOT}/components/libraries/mpu>"
        "$<$<CONFIG:Debug>:${SDK_ROOT}/external/segger_rtt>"
#        "${SDK_ROOT}/components/libraries/cli"
        "${SDK_ROOT}/modules/nrfx/mdk"
        "${SDK_ROOT}/components/libraries/bootloader"
        "${SDK_ROOT}/components/libraries/bootloader/dfu"
        "${SDK_ROOT}/components/libraries/scheduler"
        "${SDK_ROOT}/components/libraries/queue"
        "${SDK_ROOT}/components/libraries/pwr_mgmt"
        "${SDK_ROOT}/components/libraries/fds"
        "${SDK_ROOT}/components/libraries/crc16"
        "${SDK_ROOT}/components/libraries/fifo"
        "${SDK_ROOT}/components/libraries/fstorage"
        "${SDK_ROOT}/components/libraries/gfx"
        "${SDK_ROOT}/components/libraries/sortlist"
        "${SDK_ROOT}/components/libraries/strerror"
        "${SDK_ROOT}/components/toolchain/cmsis/include"
        "${SDK_ROOT}/components/libraries/timer"
        "${SDK_ROOT}/components/libraries/util"
        "${SDK_ROOT}/components/libraries/bsp"
        "${SDK_ROOT}/components/libraries/usbd/class/cdc"
        "${SDK_ROOT}/components/libraries/balloc"
        "${SDK_ROOT}/components/libraries/ringbuf"
        "${SDK_ROOT}/components/libraries/hardfault/nrf52"
#        "${SDK_ROOT}/components/libraries/cli/uart"
        "${SDK_ROOT}/components/libraries/hardfault"
        "${SDK_ROOT}/components/libraries/svc"
        "${SDK_ROOT}/components/libraries/uart"
        "${SDK_ROOT}/components/libraries/log"
        "${SDK_ROOT}/components/libraries/log/src"
        "${SDK_ROOT}/components/libraries/button"
        "${SDK_ROOT}/modules/nrfx"
        "${SDK_ROOT}/modules/nrfx/soc"
        "${SDK_ROOT}/modules/nrfx/hal"
        "${SDK_ROOT}/modules/nrfx/drivers/include"
        "${SDK_ROOT}/components/libraries/experimental_section_vars"
        "${SDK_ROOT}/integration/nrfx/legacy"
        "${SDK_ROOT}/components/libraries/usbd"
        "${SDK_ROOT}/components/libraries/usbd/class/cdc/acm"
        "${SDK_ROOT}/components/libraries/mutex"
        "${SDK_ROOT}/components/libraries/delay"
        "${SDK_ROOT}/components/libraries/atomic_fifo"
        "${SDK_ROOT}/components/libraries/atomic_flags"
        "$<$<NOT:$<BOOL:${SOFTDEVICE}>>:${SDK_ROOT}/components/drivers_nrf/nrf_soc_nosd/>"
        "${SDK_ROOT}/components/libraries/atomic"
        "${SDK_ROOT}/components/boards"
        "${SDK_ROOT}/components/libraries/memobj"
        "${SDK_ROOT}/external/fnmatch"
        "${SDK_ROOT}/integration/nrfx"
        "${SDK_ROOT}/external/fprintf"
        "${SDK_ROOT}/external/thedotfactory_fonts"
        "${SDK_ROOT}/external/utf_converter"
        )

target_compile_options("${PROJECT_NAME}" PRIVATE
        # Disable errors about pointer casts
        -fms-extensions
        # Warn on everything
        -Wall
        -Wno-unused-function
        -Wno-unused-variable
        # Emit debug symbols tailored for gdb
        $<$<CONFIG:Debug>:-ggdb>
        # Use relative paths in debug symbols
        -fdebug-prefix-map=${CMAKE_CURRENT_SOURCE_DIR}=.
        )

target_link_options("${PROJECT_NAME}" PRIVATE
        # Add linker script
#        "-T${LIB_ROOT}/config/gcc$<$<BOOL:${SOFTDEVICE}>:_${SOFTDEVICE}>_nrf52$<$<BOOL:${ENABLE_SPIM3}>:_spim3>$<$<CONFIG:Debug>:_debug>.ld"
        # Add GNU build ID hash
#        "-Wl,--build-id"
        # Generate memory map
#        "-Wl,-Map=${PROJECT_NAME}.map"
        )
