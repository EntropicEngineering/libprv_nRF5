//
// Created by Benjamin Riggs on 10/28/20.
//

#ifndef PRV_POWER_MANAGER_H
#define PRV_POWER_MANAGER_H

#include <stdbool.h>

///@brief Trigger system shutdown.
void prv_shutdown(void);

/**@brief   Sleep until an event is received. */
void prv_wait(void);

/**@brief   Function that shuts down outputs or power.
 *
 * @return  True if shutdown has completed
 */
typedef bool (*shutdown_func_t)(void);

/**@brief   Register shutdown handlers.
 *
 * @note    Must come after app_timer_init.
 * @param application_fn    Function to shut down device application.
 *                          After it returns true, the softdevice will be shutdown (if active).
 *                          It will be called repeatedly until it returns true.
 * @param power_fn          Function to shut down device power.
 *                          It will be called only after the softdevice is disabled.
 *                          It will be called repeatedly until it returns true.
 */
void prv_power_manager_init(shutdown_func_t application_fn, shutdown_func_t power_fn);

#endif //PRV_POWER_MANAGER_H
