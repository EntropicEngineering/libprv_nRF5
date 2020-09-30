//
// Created by Benjamin Riggs on 7/28/20.
//

#include "crc8.h"

void crc8_init(crc8_t *p_crc8, uint8_t polynomial, uint8_t initial_val, uint8_t final_val) {
    p_crc8->initial_value = initial_val;
    p_crc8->final_value = final_val;
    for (size_t i = 0; i < 256; i++) {
        uint8_t crc = i;
        for (uint8_t bit = 0; bit < 8; bit++) {
            crc = (crc & 0x80) ? ((crc << 1) ^ polynomial) : (crc << 1);
        }
        p_crc8->lookup_table[i] = crc;
    }
}

uint8_t crc8_calc(crc8_t *p_crc8, uint8_t *p_data, size_t length) {
    uint8_t crc = p_crc8->initial_value;
    while (length) {
        crc = p_crc8->lookup_table[crc ^ *p_data];
        p_data++;
        length--;
    }
    return p_crc8->final_value ^ crc;
}
