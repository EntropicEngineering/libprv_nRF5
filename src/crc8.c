//
// Created by Benjamin Riggs on 7/28/20.
//

#include "crc8.h"

static __inline uint8_t bit_reverse (uint8_t b) {
    uint32_t res;
    // RBIT reverses all bits in a 32-bit register
    __asm("RBIT %[out], %[in]"
        : [out] "=r" (res)
        : [in] "r" (b)
        );
    return (uint8_t) (res >> 24);
}

void crc8_init(crc8_t *p_crc8, crc8_conf_t conf) {
    p_crc8->initial_value = conf.initial_value;
    p_crc8->final_value = conf.final_value;
    p_crc8->reflect_input = conf.reflect_input;
    p_crc8->reflect_result = conf.reflect_result;
    for (size_t i = 0; i < 256; i++) {
        uint8_t crc = i;
        for (uint8_t bit = 0; bit < 8; bit++) {
            crc = (crc & 0x80) ? ((crc << 1) ^ conf.polynomial) : (crc << 1);
        }
        p_crc8->lookup_table[i] = crc;
    }
}

uint8_t crc8_calc(crc8_t *p_crc8, uint8_t *p_data, size_t length) {
    uint8_t crc = p_crc8->initial_value;
    if (p_crc8->reflect_input) {
        while (length) {
            crc = p_crc8->lookup_table[crc ^ bit_reverse(*p_data)];
            p_data++;
            length--;
        }
    } else {
        while (length) {
            crc = p_crc8->lookup_table[crc ^ *p_data];
            p_data++;
            length--;
        }
    }
    return p_crc8->reflect_result ? bit_reverse(crc) ^ p_crc8->final_value : crc ^ p_crc8->final_value;
}
