//
// Created by Benjamin Riggs on 7/28/20.
//

#include "crc8.h"

#include "nrfx.h"

typedef struct {
    bool initialized: 1;
    bool reflect_input: 1;
    bool reflect_result: 1;
    uint8_t initial_value;
    uint8_t final_value;
} crc8_state_t;

static __inline uint8_t bit_reverse (uint8_t b) {
    uint32_t res;
    // RBIT reverses all bits in a 32-bit register
    __asm("RBIT %[out], %[in]"
        : [out] "=r" (res)
        : [in] "r" (b)
        );
    return (uint8_t) (res >> 24);
}

void crc8_init(crc8_t *p_crc8, crc8_conf_t const *p_crc8_conf) {
    ASSERT(p_crc8);
    ASSERT(p_crc8_conf);
    crc8_state_t *state = (crc8_state_t *) &p_crc8->state;
    state->initial_value = p_crc8_conf->initial_value;
    state->final_value = p_crc8_conf->final_value;
    state->reflect_input = p_crc8_conf->reflect_input;
    state->reflect_result = p_crc8_conf->reflect_result;
    for (size_t i = 0; i < 256; i++) {
        uint8_t crc = i;
        for (uint8_t bit = 0; bit < 8; bit++) {
            crc = (crc & 0x80) ? ((crc << 1) ^ p_crc8_conf->polynomial) : (crc << 1);
        }
        p_crc8->lookup_table[i] = crc;
    }
    state->initialized = true;
}

uint8_t crc8_calc(crc8_t const *p_crc8, uint8_t const *data, size_t length) {
    ASSERT(p_crc8);
    ASSERT(((crc8_state_t *) p_crc8->state)->initialized);
    ASSERT(data);
    crc8_state_t *state = (crc8_state_t *) p_crc8->state;
    uint8_t crc = state->initial_value;
    if (state->reflect_input) {
        while (length) {
            crc = p_crc8->lookup_table[crc ^ bit_reverse(*data)];
            data++;
            length--;
        }
    } else {
        while (length) {
            crc = p_crc8->lookup_table[crc ^ *data];
            data++;
            length--;
        }
    }
    return state->reflect_result * (bit_reverse(crc) ^ state->final_value) +
           (1 - state->reflect_result) * (crc ^ state->final_value);
}
