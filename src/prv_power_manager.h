//
// Created by Benjamin Riggs on 10/28/20.
//

#ifndef PRV_POWER_MANAGER_H
#define PRV_POWER_MANAGER_H

#include <stdbool.h>

extern bool shutdown_outputs(void);
extern bool shutdown_power(void);

void prv_shutdown(void);

/**@brief   Sleep until an event is received. */
void prv_wait(void);

void prv_power_manager_init(void);

#endif //PRV_POWER_MANAGER_H
