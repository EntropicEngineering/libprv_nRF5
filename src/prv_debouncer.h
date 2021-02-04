//
// Created by Benjamin Riggs on 2/3/21.
//

#ifndef PRV_DEBOUNCER_H
#define PRV_DEBOUNCER_H

#include <stdint.h>
#include <stdbool.h>

typedef uint32_t prv_debouncer_t;

/**
 * @brief Retrieve the stable value from a debouncer without providing a new value.
 *
 * @param[in] p_debouncer   Pointer to an initialized debouncer.
 * @return      The stable value from the debouncer.
 */
uint8_t prv_debounced(prv_debouncer_t volatile *p_debouncer);

/**
 * @brief Debounce tracking for hardware inputs
 *
 * @param[in] p_debouncer   Pointer to an initialized debouncer.
 * @param[in] value         New value given to the debouncer.
 * @param[out] p_stable     Pointer that is set to the stable value of the debouncer.
 * @retval true             Stable value has changed.
 * @retval false            Stable value has not changed.
 */
bool prv_debounce(prv_debouncer_t volatile *p_debouncer, uint8_t value, uint8_t *p_stable);

/**
 * @brief Initialize a debouncer.
 *
 * @param[in] p_debouncer       Pointer to memory used to store debouncer state.
 * @param[in] max_count         Number of successive values that must be identical for the new input to become the
 *                              stable value. Generally this is DEBOUNCE_MS / POLL_MS.
 *                              (Or DEBOUNCE_MS * POLL_Hz / 1000)
 * @param[in] initial_value     Initial stable value for debouncer.
 */
void prv_debounce_init(prv_debouncer_t volatile *p_debouncer, int8_t max_count, uint8_t initial_value);

#endif //PRV_DEBOUNCER_H
