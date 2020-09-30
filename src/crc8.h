//
// Created by Benjamin Riggs on 7/28/20.
//

#ifndef CRC8_H
#define CRC8_H

#include <stdint.h>
#include <stddef.h>

typedef struct {
    uint8_t initial_value;
    uint8_t final_value;
    uint8_t lookup_table[256];
} crc8_t;

#define CRC8_INIT(p_crc8) crc8_init(p_crc8, 0x07, 0, 0)

/**@brief   Initialize crc-8 calculator.
 *
 * This will generate a lookup table in RAM based on the polynomial, and fix the initial and final values used in
 * CRC calculations.
 *
 * @param p_crc8            Pointer to memory where crc8 structure values will be stored.
 * @param polynomial        Polynomial used by CRC
 * @param initial_value     Initialization value given to CRC calculation.
 * @param final_value       Final value XOR'd with result of CRC calculation.
 */
void crc8_init(crc8_t *p_crc8, uint8_t polynomial, uint8_t initial_value, uint8_t final_value);

/**@brief   Calculate the crc-8 of a data.
 *
 * @param p_crc     Pointer to initialized crc8 structure.
 * @param buffer    Data to calculate CRC over.
 * @param length    Length of data.
 * @return          Calculated CRC value for data and given crc8.
 */
uint8_t crc8_calc(crc8_t *p_crc8, uint8_t *p_data, size_t length);

#endif //CRC8_H
