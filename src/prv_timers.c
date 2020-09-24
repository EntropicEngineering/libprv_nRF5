//
// Created by Benjamin Riggs on 4/13/20.
//

#include "prv_timers.h"
#include "nrfx_rtc.h"

static nrfx_rtc_t ms_rtc = NRFX_RTC_INSTANCE(MS_RTC_INSTANCE);
APP_TIMER_DEF(prv_update_timer);

// Millisecond counter overflows about every 280 minutes.
#define MS_RTC_MAX 0xFFFFFF
static uint8_t volatile ms_overflows = 0;

static void udpate_timer_init(uint32_t timer_ms, app_timer_timeout_handler_t timer_handler) {
    APP_ERROR_CHECK(app_timer_create(&prv_update_timer, APP_TIMER_MODE_REPEATED, timer_handler));
    APP_ERROR_CHECK(app_timer_start(prv_update_timer, APP_TIMER_TICKS(timer_ms), NULL));
}

static void ms_irq_handler(nrfx_rtc_int_type_t __unused int_type) {
    ms_overflows++;
}

static void rtc_init(void) {
    nrfx_rtc_config_t ms_rtc_config = NRFX_RTC_DEFAULT_CONFIG;
    // fRTC [Hz] = 32768 / (PRESCALER + 1 )
    // PRESCALER of 31 => 1024 Hz, ~0.977 ms tick
    // PRESCALER of 32 => 992.969696... Hz, ~1.007 ms tick
    ms_rtc_config.prescaler = 32;   // ms timer
    ms_rtc_config.tick_latency = 0;
    ms_rtc_config.reliable = 1;
    ms_rtc_config.interrupt_priority = MS_RTC_IRQ_PRIORITY;

    APP_ERROR_CHECK(nrfx_rtc_init(&ms_rtc, &ms_rtc_config, ms_irq_handler));
    nrfx_rtc_overflow_enable(&ms_rtc, true);
    nrfx_rtc_enable(&ms_rtc);
}

uint32_t prv_timestamp(void) {
    uint32_t now = nrfx_rtc_counter_get(&ms_rtc);
    return ms_overflows * (MS_RTC_MAX + 1) + now;
}

void prv_timers_init(uint32_t timer_ms, app_timer_timeout_handler_t timer_handler) {
    rtc_init();
    udpate_timer_init(timer_ms, timer_handler);
}
