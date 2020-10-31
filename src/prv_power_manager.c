//
// Created by Benjamin Riggs on 10/28/20.
//

#include "prv_power_manager.h"

#include "nrf_pwr_mgmt.h"
#include "nrf_log.h"
#include "app_error.h"

#ifdef SOFTDEVICE_PRESENT
#include "nrf_sdh.h"
#endif

static bool shutdown_softdevice(void) {
    #ifdef SOFTDEVICE_PRESENT
    if (nrf_sdh_is_enabled()) {
        nrfx_err_t err_code = nrf_sdh_disable_request();
        APP_ERROR_CHECK(err_code);
    }
    return !nrf_sdh_is_enabled();
    #else
    return true;
    #endif
}

/**@brief Handler for shutdown preparation.
 *
 * @details During shutdown procedures, this function will be called at a 1 second interval
 *          until the function returns true. When the function returns true, it means that the
 *          app is ready to reset to DFU mode.
 *
 * @param[in]   event   Power manager event.
 *
 * @retval  True if shutdown is allowed by this power manager handler, otherwise false.
 */
static bool app_shutdown_handler(nrf_pwr_mgmt_evt_t event) {
    switch (event) {
        case NRF_PWR_MGMT_EVT_PREPARE_DFU:
        case NRF_PWR_MGMT_EVT_PREPARE_RESET:
            NRF_LOG_INFO("Power management wants to reset to DFU mode.");
            if (!shutdown_outputs()) return false;
            return shutdown_softdevice();

        case NRF_PWR_MGMT_EVT_PREPARE_SYSOFF:
        case NRF_PWR_MGMT_EVT_PREPARE_WAKEUP:
            if (!shutdown_outputs()) return false;
            if (!shutdown_softdevice()) return false;
            return shutdown_power();

        default:
            return true;
    }

    NRF_LOG_INFO("Power management allowed to reset to DFU mode.");
    return true;
}

//lint -esym(528, m_app_shutdown_handler)
/**@brief Register application shutdown handler with priority 0.
 */
NRF_PWR_MGMT_HANDLER_REGISTER(app_shutdown_handler, 0);

void prv_shutdown(void) {
    NRF_LOG_DEBUG("shutting down");
    nrf_pwr_mgmt_shutdown(NRF_PWR_MGMT_SHUTDOWN_GOTO_SYSOFF);
}

void prv_wait(void) {
    nrf_pwr_mgmt_run();
}

void prv_power_manager_init(void) {
    APP_ERROR_CHECK(nrf_pwr_mgmt_init());
}
