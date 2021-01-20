
#include <stdbool.h>

#include "prv_utils.h"

#ifdef DEBUG
#include "nrf_log_ctrl.h"
#include "nrf_log_default_backends.h"
#include "nrf_log_backend_rtt.h"
#if !ENABLE_BOOTLOADER
#include "SEGGER_RTT.h"
#endif
#endif  // DEBUG

typedef struct {
    uint32_t namesz;
    uint32_t descsz;
    uint32_t type;
    uint8_t data[];
} elf_note_section_t;

extern const elf_note_section_t g_note_build_id;

build_id_hash *prv_get_build_id(void) {
    // Desc field is 4-byte aligned, but namesz doesn't include padding.
    size_t const name_padding = sizeof(uint32_t) - 1U;
    size_t desc_offset = (g_note_build_id.namesz + name_padding) & ~name_padding;
    return (build_id_hash *) &g_note_build_id.data[desc_offset];
}

/**
 * @brief Function for updating UICR registers.
 *
 * @param [in] regout0_vout         One of the UICR_REGOUT_VOUT_#V# macros
 * @param [in] nfcpins_protect      UICR_NFCPINS_PROTECT_NFC or UICR_NFCPINS_PROTECT_Disabled
 * @param
 */
void prv_set_UICR(uint32_t regout0_vout, uint32_t nfcpins_protect) {
    bool update = false;

    // Configure UICR_REGOUT0_VOUT register only if needed.
    if ((NRF_UICR->REGOUT0 & UICR_REGOUT0_VOUT_Msk) != (regout0_vout << UICR_REGOUT0_VOUT_Pos)) {
        NRF_NVMC->CONFIG = NVMC_CONFIG_WEN_Wen;
        while (NRF_NVMC->READY == NVMC_READY_READY_Busy) {}

        NRF_UICR->REGOUT0 = (NRF_UICR->REGOUT0 & ~((uint32_t) UICR_REGOUT0_VOUT_Msk)) |
                            (regout0_vout << UICR_REGOUT0_VOUT_Pos);
        while (NRF_NVMC->READY == NVMC_READY_READY_Busy) {}
        update = true;
    }

    // Configure UICR_NFCPINS_PROTECT register only if needed.
    if ((NRF_UICR->NFCPINS & UICR_NFCPINS_PROTECT_Msk) != (nfcpins_protect << UICR_NFCPINS_PROTECT_Pos)) {
        NRF_NVMC->CONFIG = NVMC_CONFIG_WEN_Wen;
        while (NRF_NVMC->READY == NVMC_READY_READY_Busy) {}

        NRF_UICR->NFCPINS = (NRF_UICR->NFCPINS & ~((uint32_t) UICR_NFCPINS_PROTECT_Msk)) |
                            nfcpins_protect;
        while (NRF_NVMC->READY == NVMC_READY_READY_Busy) {}
        update = true;
    }

    if (update) {
        NRF_NVMC->CONFIG = NVMC_CONFIG_WEN_Ren;
        while (NRF_NVMC->READY == NVMC_READY_READY_Busy) {}

        // System reset is needed to update UICR registers.
        NVIC_SystemReset();
    }
}

void prv_logging_init(void) {
#ifdef DEBUG
    APP_ERROR_CHECK(NRF_LOG_INIT(NULL));
#if !ENABLE_BOOTLOADER
    // RTT init code doesn't zero-out magic string, so force the issue here
    memset(&_SEGGER_RTT, 0, sizeof(SEGGER_RTT_CB));
    NRF_LOG_DEFAULT_BACKENDS_INIT();
#else
    NRF_LOG_BACKEND_RTT_DEF(rtt_log_backend);
    int32_t backend_id = -1;
    backend_id = nrf_log_backend_add(&rtt_log_backend, NRF_LOG_SEVERITY_DEBUG);
    ASSERT(backend_id >= 0);
    nrf_log_backend_enable(&rtt_log_backend);
#endif
    NRF_LOG_FLUSH();
#endif  // DEBUG
}
