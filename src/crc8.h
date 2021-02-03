//
// Created by Benjamin Riggs on 7/28/20.
//

#ifndef CRC8_H
#define CRC8_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

/**@brief crc-8 calculator configuration.
 */
typedef struct {
    uint8_t polynomial;
    uint8_t initial_value;
    uint8_t final_value;
    bool reflect_input;
    bool reflect_result;
} crc8_conf_t;

#define CRC8_CONF (crc8_conf_t) { \
    .polynomial = 0x07, \
    .initial_value = 0, \
    .final_value = 0, \
    .reflect_input = false, \
    .reflect_result = false \
}

typedef struct {
    uint32_t state;
    uint8_t lookup_table[256];
} crc8_t;

/**@brief   Initialize crc-8 calculator.
 *
 * This will generate a lookup table in RAM based on the polynomial, and fix the initial and final values used in
 * CRC calculations.
 *
 * @param p_crc8            Pointer to memory where crc-8 structure values will be stored.
 * @param p_crc8_conf         Configuration parameters for crc-8 calculator.
 */
void crc8_init(crc8_t *p_crc8, crc8_conf_t const *p_crc8_conf);

/**@brief   Calculate the crc-8 of a data.
 *
 * @param p_crc8    Pointer to initialized crc-8 structure.
 * @param buffer    Data to calculate CRC over.
 * @param length    Length of data.
 * @return          Calculated CRC value for data and given crc-8.
 */
uint8_t crc8_calc(crc8_t const *p_crc8, uint8_t const *p_data, size_t length);

#endif //CRC8_H
