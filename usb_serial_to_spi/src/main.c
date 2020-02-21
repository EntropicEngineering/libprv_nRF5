/*
 * USB-serial <-> SPI bridge
 */

#include "app_config.h"

#include <stdint.h>
#include <stddef.h>

#include "nrf.h"
#include "nrf_drv_clock.h"
#include "nrf_drv_usbd.h"
#include "nrf_gpio.h"
#include "nrf_log.h"
#include "nrf_log_ctrl.h"
#include "nrf_log_default_backends.h"

#include "app_error.h"
#include "app_util.h"
#include "app_usbd_core.h"
#include "app_usbd.h"
#include "app_usbd_cdc_acm.h"
#include "app_usbd_serial_num.h"

#include "boards.h"

#include <nrfx.h>
#include <nrfx_spim.h>

#define MESSAGE_LENGTH 5

#define LED_USB_RESUME      (BSP_BOARD_LED_0)
#define LED_CDC_ACM_OPEN    (BSP_BOARD_LED_1)
#define LED_CDC_ACM_RX      (BSP_BOARD_LED_2)
#define LED_CDC_ACM_TX      (BSP_BOARD_LED_3)

static void cdc_acm_user_ev_handler(app_usbd_class_inst_t const * p_inst,
                                    app_usbd_cdc_acm_user_event_t event);

static uint8_t data_to_device[MESSAGE_LENGTH], data_from_device[MESSAGE_LENGTH];
typedef enum {
    DISABLED,
    IDLE,
    AWAITING_INPUT,
    TRANSCEIVING,
    OUTPUTTING,
} state_t;
static volatile state_t state = DISABLED;

/**
 * @brief SPIM instance.
 * */
static const nrfx_spim_t spim = NRFX_SPIM_INSTANCE(SPI_ID);
static const nrfx_spim_xfer_desc_t xfer_descriptor = NRFX_SPIM_XFER_TRX(data_to_device, MESSAGE_LENGTH, data_from_device, MESSAGE_LENGTH);

/**
 * @brief CDC_ACM class instance
 * */
APP_USBD_CDC_ACM_GLOBAL_DEF(app_cdc_acm,
                            cdc_acm_user_ev_handler,
                            CDC_ACM_COMM_INTERFACE,
                            CDC_ACM_DATA_INTERFACE,
                            CDC_ACM_COMM_EPIN,
                            CDC_ACM_DATA_EPIN,
                            CDC_ACM_DATA_EPOUT,
                            APP_USBD_CDC_COMM_PROTOCOL_AT_V250
);

static void receive(size_t offset) {
    NRF_LOG_DEBUG("receive called with offset: %d", offset)
    nrfx_err_t return_code = app_usbd_cdc_acm_read(&app_cdc_acm,
                                                   (uint8_t *) (data_to_device + offset),
                                                   MESSAGE_LENGTH - offset);
    if (return_code == NRF_SUCCESS || return_code == NRF_ERROR_IO_PENDING || return_code == NRF_ERROR_BUSY) {
        bsp_board_led_on(LED_CDC_ACM_RX);
        state = AWAITING_INPUT;
    } else {
        state = IDLE;
        APP_ERROR_CHECK(return_code);
    }
}

static void spi_xfer() {
    nrfx_err_t return_code = nrfx_spim_xfer(&spim, &xfer_descriptor, 0);
    if (return_code == NRF_SUCCESS) {
        state = TRANSCEIVING;
    } else {
        state = IDLE;
        APP_ERROR_CHECK(return_code);
    }
}

/**
 * @brief Called on every event coming from the hardware driver after the USB library processes it.
 *
 * @param event
 */
static void usbd_user_ev_handler(app_usbd_event_type_t event)
{
    switch (event)
    {
        case APP_USBD_EVT_DRV_SUSPEND:
            bsp_board_led_off(LED_USB_RESUME);
            break;
        case APP_USBD_EVT_DRV_RESUME:
            bsp_board_led_on(LED_USB_RESUME);
            break;
        case APP_USBD_EVT_DRV_RESET:
            NRF_LOG_DEBUG("APP_USBD_EVT_RESET")
            break;
        case APP_USBD_EVT_STARTED:
            NRF_LOG_DEBUG("APP_USBD_EVT_STARTED")
            break;
        case APP_USBD_EVT_STOPPED:
            state = DISABLED;
            app_usbd_disable();
            bsp_board_leds_off();
            break;
        case APP_USBD_EVT_POWER_DETECTED:
            NRF_LOG_INFO("USB power detected")

            if (!nrf_drv_usbd_is_enabled())
            {
                app_usbd_enable();
            }
            break;
        case APP_USBD_EVT_POWER_REMOVED:
            NRF_LOG_INFO("USB power removed")
            app_usbd_stop();
            break;
        case APP_USBD_EVT_POWER_READY:
            NRF_LOG_INFO("USB ready")
            app_usbd_start();
            break;
        default:
            break;
    }
}

/**
 * @brief User event handler @ref app_usbd_cdc_acm_user_ev_handler_t (headphones)
 * */
static void cdc_acm_user_ev_handler(app_usbd_class_inst_t const * p_inst,
                                    app_usbd_cdc_acm_user_event_t event)
{
    app_usbd_cdc_acm_t const * p_cdc_acm = app_usbd_cdc_acm_class_get(p_inst);

    switch (event)
    {
        case APP_USBD_CDC_ACM_USER_EVT_PORT_OPEN:
            bsp_board_led_on(LED_CDC_ACM_OPEN);
            NRF_LOG_DEBUG("APP_USB_CDC_ACM_USER_EVT_PORT_OPEN")
            state = IDLE;
            /*Setup first transfer*/
            receive(0);
            break;
        case APP_USBD_CDC_ACM_USER_EVT_PORT_CLOSE:
            bsp_board_led_off(LED_CDC_ACM_OPEN);
            state = DISABLED;
            break;
        case APP_USBD_CDC_ACM_USER_EVT_TX_DONE:
            bsp_board_led_off(LED_CDC_ACM_TX);
//            NRF_LOG_DEBUG("%d bytes waiting after TX", app_usbd_cdc_acm_bytes_stored(p_cdc_acm))
            state = IDLE;
            break;
        case APP_USBD_CDC_ACM_USER_EVT_RX_DONE:
            // Should only be triggered when data_to_device has 5 fresh bytes.
            bsp_board_led_off(LED_CDC_ACM_RX);
//            NRF_LOG_DEBUG("%d bytes waiting", app_usbd_cdc_acm_bytes_stored(p_cdc_acm))
            NRF_LOG_DEBUG("Received %d bytes", app_usbd_cdc_acm_rx_size(p_cdc_acm))
            spi_xfer();
            break;
        default:
            break;
    }
}

void spi_ev_handler(nrfx_spim_evt_t *p_event, __unused void *p_context) {
    nrfx_err_t return_code = app_usbd_cdc_acm_write(&app_cdc_acm, data_from_device, MESSAGE_LENGTH);
    if (return_code != NRFX_SUCCESS) {
        state = IDLE;
        APP_ERROR_CHECK(return_code);
    } else {
        bsp_board_led_on(LED_CDC_ACM_TX);
        state = OUTPUTTING;
    }
}

static void clk_init() {
    if (nrf_drv_clock_lfclk_is_running()) {
        return;
    }

    APP_ERROR_CHECK(nrf_drv_clock_init());

    nrf_drv_clock_lfclk_request(NULL);

    while(!nrf_drv_clock_lfclk_is_running())
    {
        /* Just waiting */
    }
}

static void usb_init() {
    static const app_usbd_config_t usbd_config = {
        .ev_state_proc = usbd_user_ev_handler
    };

    app_usbd_serial_num_generate();

    // app_usbd_init requires nrf_drv_clock_init
    clk_init();

    APP_ERROR_CHECK(app_usbd_init(&usbd_config));
    NRF_LOG_INFO("USBD init")

    APP_ERROR_CHECK(app_usbd_class_append(app_usbd_cdc_acm_class_inst_get(&app_cdc_acm)));

    if (APP_USBD_CONFIG_POWER_EVENTS_PROCESS)
    {
        APP_ERROR_CHECK(app_usbd_power_events_enable());
    }
    else
    {
        NRF_LOG_INFO("No USB power detection enabled\r\nStarting USB now")

        app_usbd_enable();
        app_usbd_start();
    }
}

static void spi_init() {
    nrfx_spim_config_t spim_cfg = NRFX_SPIM_DEFAULT_CONFIG;
    spim_cfg.frequency = NRF_SPIM_FREQ_1M;
    spim_cfg.mode = NRF_SPIM_MODE_3;
    spim_cfg.sck_pin = SPI_3_SCK_PIN;
    spim_cfg.miso_pin = SPI_3_MISO_PIN;
    spim_cfg.mosi_pin = SPI_3_MOSI_PIN;
    spim_cfg.ss_pin = SPI_3_SS_PIN;

    APP_ERROR_CHECK(nrfx_spim_init(&spim, &spim_cfg, (nrfx_spim_evt_handler_t) &spi_ev_handler, NULL));
    NRF_LOG_INFO("SPIM init")
}

int main(void) {

    NRF_LOG_INIT(NULL);
    NRF_LOG_DEFAULT_BACKENDS_INIT();
    NRF_LOG_INFO("Logging init")

    spi_init();

    usb_init();

    bsp_board_init(BSP_INIT_LEDS);

    while(true) {
        while (app_usbd_event_queue_process()) { /* Nothing to do */ }

        if (!NRF_LOG_PROCESS()) {
            if (state == IDLE) {
                receive(0);
            } else {
                /* Sleep CPU only if there was no interrupt since last loop processing */
                __WFE();
            }
        }
    }
}
