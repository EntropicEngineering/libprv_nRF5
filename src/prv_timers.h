//
// Created by Benjamin Riggs on 4/13/20.
//

#ifndef PRV_TIMERS_H
#define PRV_TIMERS_H

#include "app_timer.h"

uint32_t prv_timestamp(void);

void prv_timers_init(uint32_t timer_ms, app_timer_timeout_handler_t timer_handler);

#endif //PRV_TIMERS_H
