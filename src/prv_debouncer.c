//
// Created by Benjamin Riggs on 2/3/21.
//

#include "prv_debouncer.h"

#include "nrfx.h"

typedef struct __packed {
    int8_t max_count;
    int8_t countdown;
    uint8_t last_value;
    uint8_t stable_value;
} debouncer_t;

uint8_t prv_debounced(prv_debouncer_t volatile *p_debouncer) {
    return ((debouncer_t *) p_debouncer)->stable_value;
}

bool prv_debounce(prv_debouncer_t volatile *p_debouncer, uint8_t value, uint8_t *p_stable) {
    ASSERT(((debouncer_t *) p_debouncer)->max_count);
    debouncer_t *d = (debouncer_t *) p_debouncer;
    if (value != d->last_value) {
        d->countdown = d->max_count;
        d->last_value = value;
    } else if (d->countdown) {
        d->countdown--;
    } else {
        *p_stable = d->stable_value = value;
        return true;
    }
    *p_stable = d->stable_value;
    return false;
}

void prv_debounce_init(prv_debouncer_t volatile *p_debouncer, int8_t max_count, uint8_t initial_value) {
    ASSERT(p_debouncer);
    ASSERT(max_count > 0);
    debouncer_t *d = (debouncer_t *) p_debouncer;
    d->countdown = d->max_count = max_count;
    d->stable_value = d->last_value = initial_value;
}
