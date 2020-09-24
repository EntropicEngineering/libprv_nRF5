//
// Created by Benjamin Riggs on 9/17/20.
//

#include "prv_temperature.h"

#include "nrfx_temp.h"

void prv_temperature_init(void) {
    #ifndef SOFTDEVICE_PRESENT
    nrfx_temp_config_t temperature_config = NRFX_TEMP_DEFAULT_CONFIG;
    APP_ERROR_CHECK(nrfx_temp_init(&temperature_config, NULL));
    #endif
}

uint32_t prv_temperature_get(void) {
    int32_t raw_temperature;
    #ifdef SOFTDEVICE_PRESENT
    sd_temp_get(&raw_temperature);
    #else
    APP_ERROR_CHECK(nrfx_temp_measure());
    raw_temperature = nrfx_temp_result_get();
    #endif
    return nrfx_temp_calculate(raw_temperature);
}
