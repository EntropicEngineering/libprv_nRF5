# pragma once
include_guard(GLOBAL)

add_compile_definitions(
        BOARD_PCA10056
        NRF52840_XXAA
)

if (NOT TARGET "${PROJECT_NAME}")
    message(SEND_ERROR "sdk helper functions require existing target")
    return()
endif ()

get_target_property(ext "${PROJECT_NAME}" SUFFIX)

add_custom_target(sdk_config
        COMMAND java -jar "${SDK_ROOT}/external_tools/cmsisconfig/CMSIS_Configuration_Wizard.jar" "${CMAKE_SOURCE_DIR}/config/sdk_config.h"
        )
message("'make sdk_config' will launch CMSIS Configuration Wizard")

add_custom_target(flash
        COMMAND nrfjprog -f nrf52 --program "${PROJECT_NAME}.hex" --sectorerase --verify --fast --reset
        )
message("'make flash' will flash ${PROJECT_NAME}.hex onto a connected board")

add_custom_target(erase
        COMMAND nrfjprog -f nrf52 --recover
        )
message("'make erase' will completely erase a connected board. This is required before programming a module for the first time.")

add_custom_target(flash_blink_canary
        COMMAND nrfjprog -f nrf52 --program "${SDK_ROOT}/examples/peripheral/blinky/hex/blinky_pca10056.hex" --sectorerase --verify --fast --reset
        )
message("'make flash_blink' will reflash the nRF52DK LED blinky app.")

if (${SOFTDEVICE})
    add_custom_target(flash_${SOFTDEVICE}
            COMMAND nrfjprog -f nrf52 --program "${SDK_ROOT}/components/softdevice/${SOFTDEVICE}/hex/${SOFTDEVICE}_nrf52_7.0.1_softdevice.hex" --sectorerase --verify --fast --reset
            )
    message("'make flash_${SOFTDEVICE}' will flash the ${SOFTDEVICE} SoftDevice onto a connected board")
endif ()

add_custom_command(TARGET "${PROJECT_NAME}" POST_BUILD
        COMMAND "${CMAKE_OBJCOPY}" -O binary "${PROJECT_NAME}${ext}" "${PROJECT_NAME}.bin"
        COMMAND "${CMAKE_OBJCOPY}" -O ihex "${PROJECT_NAME}${ext}" "${PROJECT_NAME}.hex"
        )

if (EXISTS ${SIZE_FUNC})
    add_custom_command(TARGET "${PROJECT_NAME}" POST_BUILD
            COMMAND "${SIZE_FUNC}" "${PROJECT_NAME}${ext}"
            )
endif ()
