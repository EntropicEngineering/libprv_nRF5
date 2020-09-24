//
// Created by Benjamin Riggs on 9/17/20.
//

#ifndef PRV_TEMPERATURE_H
#define PRV_TEMPERATURE_H

#include <stdint.h>

void prv_temperature_init(void);

/// Returns chip temperature * 100. Must call prv_temperature_init first.
uint32_t prv_temperature_get(void) ;

#endif //PRV_TEMPERATURE_H
