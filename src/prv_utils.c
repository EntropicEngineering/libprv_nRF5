
#include <stdbool.h>

#include "prv_utils.h"

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

