//
// Created by Benjamin Riggs on 12/6/19.
//

#ifndef LIBPRV_CONFIG_H
#define LIBPRV_CONFIG_H

#ifndef ENABLE_USB_SERIAL
#define ENABLE_USB_SERIAL 0
#endif

/**
 * nRF5 SDK settings
 */
// It's much easier to manage them here than in sdk_config.h

/**
 * Peripheral Configuration
 */
//Temperature sensor.
#ifndef SOFTDEVICE_PRESENT
#define NRFX_TEMP_ENABLED 1
#endif
#if ENABLE_USB_SERIAL
// app_usb_cdc_acm library uses legacy clock driver
#define NRFX_USBD_ENABLED 1
#define NRF_CLOCK_ENABLED 1
#endif
// Updates & BLE timers
#define APP_TIMER_ENABLED 1
// ms counter, RTC0: softdevice, RTC1: app_timer, RTC2: ms timer
#define NRFX_RTC_ENABLED 1
#define NRFX_RTC2_ENABLED 1
#define MS_RTC_INSTANCE 2

/**
 * Interrupt priorities
 */
// SoftDevice is at 0, 1, & 4
#define MS_RTC_IRQ_PRIORITY 2
#define PULSE_UPDATES_IRQ_PRIORITY 3
#ifndef SOFTDEVICE_PRESENT
#define NRFX_TEMP_DEFAULT_CONFIG_IRQ_PRIORITY 4
#endif
#define ON_BOARD_COMMS_IRQ_PRIORITY 5
#define EXTERNAL_COMMS_IRQ_PRIORITY 6
#define APP_TIMER_CONFIG_IRQ_PRIORITY 7

/**
 * SDK Library Config
 */
#if DEBUG
#define NRF_MPU_LIB_ENABLED 1
#define NRF_STACK_GUARD_ENABLED 1
#define NRF_STACK_GUARD_CONFIG_SIZE 9
#define NRF_LOG_ENABLED 1
#define NRF_LOG_BACKEND_RTT_ENABLED 1
#define NRF_LOG_DEFERRED 0
#define NRF_LOG_NON_DEFFERED_CRITICAL_REGION_ENABLED 1
/// Changing any of the following SEGGER_RTT_* values requires updating linker files
#define SEGGER_RTT_CONFIG_BUFFER_SIZE_UP 4096
#define SEGGER_RTT_CONFIG_MAX_NUM_UP_BUFFERS 2
#define SEGGER_RTT_CONFIG_BUFFER_SIZE_DOWN 16
#define SEGGER_RTT_CONFIG_MAX_NUM_DOWN_BUFFERS 2
#define SEGGER_RTT_ALIGNMENT 4
#define SEGGER_RTT_BUFFER_ALIGNMENT 4
#define SEGGER_RTT_SECTION ".rtt_cb"
#define SEGGER_RTT_BUFFER_SECTION ".rtt_buffers"
#else
#define NRF_LOG_ENABLED 0
#endif

#if ENABLE_USB_SERIAL
#define APP_USBD_ENABLED 1
// FIXME: Acquire VID/PID
#define APP_USBD_VID 0x1915
#define APP_USBD_PID 0x520E
#define APP_USBD_DEVICE_VER_MAJOR 0
#define APP_USBD_DEVICE_VER_MINOR 1
#define APP_USBD_DEVICE_VER_SUB 0
#define APP_USBD_CONFIG_SELF_POWERED 1
#define APP_USBD_CONFIG_MAX_POWER 100
#define APP_USBD_CONFIG_POWER_EVENTS_PROCESS 1
#define APP_USBD_CONFIG_EVENT_QUEUE_ENABLE 1
#define APP_USBD_STRINGS_MANUFACTURER APP_USBD_STRING_DESC("Entropic Engineering")
#define APP_USBD_STRINGS_PRODUCT APP_USBD_STRING_DESC(DEVICE_NAME)
#define APP_USBD_STRING_SERIAL g_extern_serial_number
#define APP_USBD_STRINGS_CONFIGURATION APP_USBD_STRING_DESC("Default configuration")
// TODO
//#define APP_USBD_STRINGS_USER Refer to sdk_config.h

#define CDC_ACM_COMM_INTERFACE  0
#define CDC_ACM_COMM_EPIN       NRF_DRV_USBD_EPIN2
#define CDC_ACM_DATA_INTERFACE  1
#define CDC_ACM_DATA_EPIN       NRF_DRV_USBD_EPIN1
#define CDC_ACM_DATA_EPOUT      NRF_DRV_USBD_EPOUT1
#endif // _ENABLE_USB

#define APP_SCHEDULER_ENABLED 1

/// Enable Power Management Module.
#define NRF_PWR_MGMT_ENABLED 1
#define NRF_PWR_MGMT_CONFIG_AUTO_SHUTDOWN_RETRY 1
#define NRF_PWR_MGMT_CONFIG_USE_SCHEDULER 1
#if DEBUG
#define NRF_PWR_MGMT_CONFIG_CPU_USAGE_MONITOR_ENABLED 1
#endif

/// Flash Device Storage library
#define FDS_ENABLED 1
#ifdef SOFTDEVICE_PRESENT
#define FDS_BACKEND NRF_FSTORAGE_SD
#else
#define FDS_BACKEND NRF_FSTORAGE_NVMC
#endif
// Size of FDS: FDS_VIRTUAL_PAGES * 4096 bytes
#define FDS_VIRTUAL_PAGES 16
#define CRC16_ENABLED 1
#define FDS_CRC_CHECK_ON_READ 1
#define FDS_CRC_CHECK_ON_WRITE 1


/**
 * Softdevice Config
 */
#ifdef SOFTDEVICE_PRESENT

// Enable Device Firmware Updates (DFU) via BLE
#define BLE_DFU_ENABLED 1
// Require BLE bonding for DFU
#define NRF_DFU_BLE_BUTTONLESS_SUPPORTS_BONDS 0
// Needs to be defined in app_config
#define NRF_DFU_HW_VERSION HARDWARE_REVISION
// Softdevice handler config
// https://infocenter.nordicsemi.com/topic/sdk_nrf5_v16.0.0/group__nrf__sdh__config.html
#define NRF_SDH_ENABLED 1
// Use app_sched library
#define NRF_SDH_DISPATCH_MODEL 1
#define NRF_SDH_CLOCK_LF_SRC 1
// 20ppm via https://www.digikey.com/product-detail/en/ecs-inc/ECS-.327-7-12R-TR/XC2743CT-ND/8593622
#define NRF_SDH_CLOCK_LF_ACCURACY 7
#define NRF_SDH_REQ_OBSERVER_PRIO_LEVELS 2
#define NRF_SDH_STATE_OBSERVER_PRIO_LEVELS 2
#define NRF_SDH_STACK_OBSERVER_PRIO_LEVELS 2

// Softdevice SoC handler config
#define NRF_SDH_SOC_ENABLED 1
#define NRF_SDH_SOC_OBSERVER_PRIO_LEVELS 2

// Softdevice BLE handler config
#define NRF_SDH_BLE_ENABLED 1
#define NRF_SDH_BLE_GAP_DATA_LENGTH 27
#define NRF_SDH_BLE_PERIPHERAL_LINK_COUNT 3
#define NRF_SDH_BLE_CENTRAL_LINK_COUNT 0
#define NRF_SDH_BLE_TOTAL_LINK_COUNT 3
#define NRF_SDH_BLE_GAP_EVENT_LENGTH 6
#define NRF_SDH_BLE_GATT_MAX_MTU_SIZE 23
#define NRF_SDH_BLE_GATTS_ATTR_TAB_SIZE 1408
#define NRF_SDH_BLE_VS_UUID_COUNT 3     // Vendor-specific UUID count
#define NRF_SDH_BLE_SERVICE_CHANGED 0
#define NRF_SDH_BLE_OBSERVER_PRIO_LEVELS 4

// Softdevice BLE config
#define BLE_ADVERTISING_ENABLED 1
#define BLE_NUS_ENABLED 1

#endif  // SOFTDEVICE_PRESENT

#endif //LIBPRV_CONFIG_H
