add_compile_definitions(
        BOARD_PCA10056
        NRF52840_XXAA
)

if (NOT TARGET "${PROJECT_NAME}")
    message(SEND_ERROR "sdk helper functions require existing target")
    return()
endif ()

get_target_property(ext "${PROJECT_NAME}" SUFFIX)

add_custom_command(TARGET "${PROJECT_NAME}" POST_BUILD
        COMMAND "${CMAKE_OBJCOPY}" -O binary "${PROJECT_NAME}${ext}" "${PROJECT_NAME}.bin"
        COMMAND "${CMAKE_OBJCOPY}" -O ihex "${PROJECT_NAME}${ext}" "${PROJECT_NAME}.hex"
        BYPRODUCTS ${PROJECT_NAME}.hex ${PROJECT_NAME}.bin
        )

get_directory_property(is_included PARENT_DIRECTORY)
if (NOT is_included)
    add_custom_target(sdk_config
            COMMAND java -jar "${SDK_ROOT}/external_tools/cmsisconfig/CMSIS_Configuration_Wizard.jar" "${CMAKE_CURRENT_SOURCE_DIR}/config/sdk_config.h"
            )
    message("'make sdk_config' will launch CMSIS Configuration Wizard")

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

    if (EXISTS "${BOOTLOADER_PATH}")
        if (NOT EXISTS "${PRIVATE_KEY_PATH}")
            message(FATAL_ERROR "Invalid private key specified")
        endif()
        add_custom_target(flash
                COMMAND nrfutil settings generate
                                    --family NRF52840
                                    --bl-settings-version 2
                                    --application "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.hex"
                                    --application-version-string "${plug_VERSION}"
                                    --bootloader-version ${PROJECT_VERSION_MAJOR}
                                    --app-boot-validation VALIDATE_ECDSA_P256_SHA256
                                    --sd-boot-validation VALIDATE_ECDSA_P256_SHA256
                                    --softdevice "${SD_PATH}"
                                    --key-file "${PRIVATE_KEY_PATH}"
                                    "${CMAKE_CURRENT_BINARY_DIR}/settings.hex"
                COMMAND mergehex --merge "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.hex"
                                         "${CMAKE_CURRENT_BINARY_DIR}/settings.hex"
                                 --output "${CMAKE_CURRENT_BINARY_DIR}/merged.hex"
                COMMAND nrfjprog -f nrf52 --program ${CMAKE_CURRENT_BINARY_DIR}/merged.hex --sectoranduicrerase --verify --fast --reset
                DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.hex"
                BYPRODUCTS "${CMAKE_CURRENT_BINARY_DIR}/settings.hex" "${CMAKE_CURRENT_BINARY_DIR}/merged.hex"
                VERBATIM
                )
        message("'make flash' will flash application and bootloader settings onto a connected board")

        add_custom_target(dfu_pkg
                COMMAND nrfutil pkg generate --application "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.hex"
                --application-version-string "${plug_VERSION}"
                --sd-req ${SD_FIRMWARE_ID}
                --key-file "${PRIVATE_KEY_PATH}"
                --app-boot-validation VALIDATE_ECDSA_P256_SHA256
                --sd-boot-validation VALIDATE_ECDSA_P256_SHA256
                --hw-version ${HARDWARE_REV}
                "${CMAKE_CURRENT_SOURCE_DIR}/latest_firmware.zip"
                VERBATIM
                DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.hex"
                )
        message("'make dfu_pkg' will generate 'latest_firmware.zip', ready to be uploaded via the Nordic DFU service.")

    else()
        add_custom_target(flash
                COMMAND nrfjprog -f nrf52 --program "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.hex" --sectorerase --verify --fast --reset
                DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.hex"
                )
        message("'make flash' will flash ${PROJECT_NAME}.hex onto a connected board")
    endif()
endif ()

set_property(TARGET ${PROJECT_NAME} PROPERTY ADDITIONAL_CLEAN_FILES ${PROJECT_NAME}.map)

if (EXISTS ${SIZE_FUNC})
    add_custom_command(TARGET "${PROJECT_NAME}" POST_BUILD
            COMMAND "${SIZE_FUNC}" "${PROJECT_NAME}${ext}"
            )
endif ()
