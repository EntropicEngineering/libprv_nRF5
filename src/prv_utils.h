//
// Created by Benjamin Riggs on 10/30/20.
//

#ifndef PRV_UTILS_H
#define PRV_UTILS_H

#include "app_util_platform.h"
#include "app_scheduler.h"

#include "nrf_log.h"

#define SCHED_FN(fn) (app_sched_event_handler_t)(&fn)

#if DEBUG
#define DEBUG_BREAKPOINT NRF_BREAKPOINT_COND
#define DEBUG_BREAKPOINT_CHECK(condition) if (condition) NRF_BREAKPOINT_COND
#define FAIL_WITH_SIZE(size) char (*__fail)(void)[sizeof(size)] = 1;
#else
#define DEBUG_BREAKPOINT
#define DEBUG_BREAKPOINT_CHECK(condition)
#endif

typedef uint8_t build_id_hash[20];  // SHA-160 of elf sections

build_id_hash *prv_get_build_id(void);

/**
 * @brief Function for updating UICR registers.
 *
 * @param [in] regout0_vout         One of the UICR_REGOUT_VOUT_#V# macros
 * @param [in] nfcpins_protect      UICR_NFCPINS_PROTECT_NFC or UICR_NFCPINS_PROTECT_Disabled
 * @param
 */
void prv_set_UICR(uint32_t regout0_vout, uint32_t nfcpins_protect);

void prv_logging_init(void);

/**@brief   Sleep until an event is received. */
void prv_wait(void);

#endif //PRV_UTILS_H
