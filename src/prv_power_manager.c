//
// Created by Benjamin Riggs on 10/28/20.
//

#include "prv_power_manager.h"

#include "nrf_pwr_mgmt.h"
#include "nrf_log.h"
#include "app_error.h"
#if DEBUG
#include "app_scheduler.h"
#endif

#ifdef SOFTDEVICE_PRESENT
#include "nrf_sdh.h"
#endif

static shutdown_func_t m_application_fn = NULL;
static shutdown_func_t m_power_fn = NULL;

static bool shutdown_softdevice(void) {
    #ifdef SOFTDEVICE_PRESENT
    if (nrf_sdh_is_enabled()) {
        APP_ERROR_CHECK(nrf_sdh_disable_request());
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
            if (m_application_fn && !m_application_fn()) return false;
            // Stop calling if function return true;
            m_application_fn = NULL;
            if (!shutdown_softdevice()) return false;
            NRF_LOG_INFO("Power management allowed to reset to DFU mode.");
            break;

        case NRF_PWR_MGMT_EVT_PREPARE_SYSOFF:
        case NRF_PWR_MGMT_EVT_PREPARE_WAKEUP:
            if (m_application_fn && !m_application_fn()) return false;
            // Stop calling if function return true;
            m_application_fn = NULL;
            if (!shutdown_softdevice()) return false;
            if (m_power_fn && !m_power_fn()) return false;
            // Stop calling if function return true;
            m_power_fn = NULL;
            break;

        default:
            break;
    }

    return true;
}

//lint -esym(528, m_app_shutdown_handler)
/**@brief Register application shutdown handler with priority 0.
 */
NRF_PWR_MGMT_HANDLER_REGISTER(app_shutdown_handler, 0);

void prv_shutdown(void) {
    NRF_LOG_DEBUG("Shutting down. Scheduler queue utilization - Current space: %d, Maximum utilization: %d",
                  app_sched_queue_space_get(), app_sched_queue_utilization_get());
    nrf_pwr_mgmt_shutdown(NRF_PWR_MGMT_SHUTDOWN_GOTO_SYSOFF);
}

void prv_wait(void) {
    nrf_pwr_mgmt_run();
}

void prv_power_manager_init(shutdown_func_t app, shutdown_func_t power) {
    m_application_fn = app;
    m_power_fn = power;
    APP_ERROR_CHECK(nrf_pwr_mgmt_init());
}
