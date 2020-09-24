//
// Created by Benjamin Riggs on 9/3/20.
//

#ifndef SERIAL_PARSER_H
#define SERIAL_PARSER_H

#include <stdint.h>
#include <stddef.h>

/** @brief  Callback used to return a response, if any, to parsed serial data.
 *
 * @param[in] p_data    Pointer to data buffer to be sent in response to parsed message
 * @param[in] length    Length of data buffer
 */
typedef void (*prv_serial_response_t)(uint8_t *p_data, size_t *p_length, void *p_ctx);

/** @brief  Parse a buffer of serial data.
 *
 * @details This function centralizes parsing of serial data received via BLE or USB.
 *
 * @param[in] p_data    Pointer to data buffer containing serial data to be parsed
 * @param[in] length    Length of data buffer
 * @param[in] cb        Function that will be called with data to send in response to data parsed.
 *
 * @retval 0            Message parsed and acted upon.
 * @retval SIZE_MAX     Data could not be parsed.
 * @retval missing length   Other values indicate the length of additional expected data for the message.
 */
size_t serial_parse(uint8_t *p_data, size_t length, prv_serial_response_t serial_response, void *p_ctx);

/** Initialize serial parser state. */
void serial_parser_init(void);

#endif //SERIAL_PARSER_H
