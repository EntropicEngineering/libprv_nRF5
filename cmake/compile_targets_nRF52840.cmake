add_compile_definitions(
        BOARD_PCA10056
        NRF52840_XXAA
)

if (NOT TARGET "${PROJECT_NAME}")
    message(SEND_ERROR "sdk helper functions require existing target")
    return()
endif ()

get_target_property(ext "${PROJECT_NAME}" SUFFIX)

get_directory_property(is_included PARENT_DIRECTORY)
if (NOT is_included)
    add_custom_target(sdk_config
            COMMAND java -jar "${SDK_ROOT}/external_tools/cmsisconfig/CMSIS_Configuration_Wizard.jar" "${CMAKE_CURRENT_SOURCE_DIR}/config/sdk_config.h"
            )
    message("'make sdk_config' will launch CMSIS Configuration Wizard")

    add_custom_target(flash
            COMMAND nrfjprog -f nrf52 --program ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.hex --sectorerase --verify --fast --reset
            )
    message("'make flash' will flash ${PROJECT_NAME}.hex onto a connected board")

    add_custom_target(erase
            COMMAND nrfjprog -f nrf52 -e
            )
    message("'make erase' will completely erase a connected board. This is required before programming a module for the first time.")

    add_custom_target(flash_blink_canary
            COMMAND nrfjprog -f nrf52 --program "${SDK_ROOT}/examples/peripheral/blinky/hex/blinky_pca10056.hex" --sectorerase --verify --fast --reset
            )
    message("'make flash_blink_canary' will reflash the nRF52DK LED blinky app.")

    if (SOFTDEVICE)
        add_custom_target(flash_${SOFTDEVICE}
                COMMAND nrfjprog -f nrf52 --program "${SD_PATH}" --sectorerase --verify --fast --reset
                )
        message("'make flash_${SOFTDEVICE}' will flash the ${SOFTDEVICE} SoftDevice onto a connected board")
    endif ()
endif ()

add_custom_command(TARGET "${PROJECT_NAME}" POST_BUILD
        COMMAND "${CMAKE_OBJCOPY}" -O binary "${PROJECT_NAME}${ext}" "${PROJECT_NAME}.bin"
        COMMAND "${CMAKE_OBJCOPY}" -O ihex "${PROJECT_NAME}${ext}" "${PROJECT_NAME}.hex"
        )

set_property(TARGET ${PROJECT_NAME}
        PROPERTY ADDITIONAL_CLEAN_FILES ${PROJECT_NAME}.map ${PROJECT_NAME}.hex ${PROJECT_NAME}.bin)

if (EXISTS ${SIZE_FUNC})
    add_custom_command(TARGET "${PROJECT_NAME}" POST_BUILD
            COMMAND "${SIZE_FUNC}" "${PROJECT_NAME}${ext}"
            )
endif ()
