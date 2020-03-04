# pragma once
include_guard(GLOBAL)

macro(pca10056_sdk_compile_definitions)
    add_compile_definitions(
            BOARD_PCA10056
            NRF52840_XXAA
            )
endmacro()

function(pca10056_generate_convenience_functions target)
    if (NOT TARGET "${target}")
        message(SEND_ERROR "sdk helper functions must be called with existing target")
        return()
    endif ()

    get_target_property(name "${target}" NAME)
    get_target_property(ext "${target}" SUFFIX)

    add_custom_target(sdk_config
            COMMAND java -jar "${SDK_ROOT}/external_tools/cmsisconfig/CMSIS_Configuration_Wizard.jar" "${CMAKE_SOURCE_DIR}/config/sdk_config.h"
            )
    message("'make sdk_config' will launch CMSIS Configuration Wizard")

    add_custom_target(flash
            COMMAND nrfjprog -f nrf52 --program "${name}.hex" --sectorerase --verify --fast --reset
            )
    message("'make flash' will flash ${name}.hex onto a connected board")

    if (DEFINED SOFTDEVICE)
        add_custom_target(flash_${SOFTDEVICE}
                COMMAND nrfjprog -f nrf52 --program "${SDK_ROOT}/components/softdevice/${SOFTDEVICE}/hex/${SOFTDEVICE}_nrf52_7.0.1_softdevice.hex" --sectorerase --verify --fast --reset
                )
        message("'make flash_${SOFTDEVICE}' will flash the ${SOFTDEVICE} SoftDevice onto a connected board")
    endif ()

    add_custom_command(TARGET "${name}" POST_BUILD
            COMMAND "${CMAKE_OBJCOPY}" -O binary "${name}${ext}" "${name}.bin"
            COMMAND "${CMAKE_OBJCOPY}" -O ihex "${name}${ext}" "${name}.hex"
            )

    if (EXISTS ${SIZE_FUNC})
        add_custom_command(TARGET "${name}" POST_BUILD
                COMMAND "${SIZE_FUNC}" "${name}${ext}"
                )
    endif ()

endfunction()
