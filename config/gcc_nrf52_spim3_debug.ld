/* Linker script to configure memory regions. */

SEARCH_DIR(.)
GROUP(-lgcc -lc -lnosys)

MEMORY
{
  FLASH (rx) : ORIGIN = 0x0, LENGTH = 0x100000
  /* SPIM3 needs a dedicated physical RAM block that won't be touched by the CPU during DMA. */
  SPIM3_RAM (rw) : ORIGIN = 0x20000000, LENGTH = 0x2000
  /* Application RAM size is 256K - SoftDevice RAM - 8K */
  /* RAM (rwx) :  ORIGIN = 0x20002000, LENGTH = 0x3CF78 */
  RAM (rwx) :  ORIGIN = 0x20002000, LENGTH = 0x40000 - 0x1000 - 0x1000 - 0x1010 - 0x78
  /* Put RTT data at top of RAM. */
  /* RTT_CB LENGTH = 24 + SEGGER_RTT_CONFIG_MAX_NUM_UP_BUFFERS * 24
                        + SEGGER_RTT_CONFIG_MAX_NUM_DOWN_BUFFERS * 24 */
  RTT_CB (rw) : ORIGIN = 0x2003EF78, LENGTH = 0x78
  /* RTT_BUFFERS LENGTH = + SEGGER_RTT_CONFIG_BUFFER_SIZE_UP
                          + SEGGER_RTT_CONFIG_BUFFER_SIZE_DOWN */
  /* RTT_BUFFERS ORIGIN = 0x20040000 - CB LENGTH - BUFFERS LENGTH */
  RTT_BUFFERS (rw) : ORIGIN = 0x2003EFF0, LENGTH = 0x1010
}

SECTIONS
{
    .spim3 :
    {
        PROVIDE(spim3_rx_buffer = .);
        PROVIDE(spim3_tx_buffer = . + LENGTH(SPIM3_RAM) / 2);
    } > SPIM3_RAM
}

SECTIONS
{
  .rtt_buffers(NOLOAD) :
  {
    KEEP(*(.rtt_buffers))
  } > RTT_BUFFERS
  .rtt_cb(NOLOAD) :
  {
    KEEP(*(.rtt_cb))
  } > RTT_CB
}

SECTIONS
{
  . = ALIGN(4);
  .mem_section_dummy_ram :
  {
  }
  .fs_data :
  {
    PROVIDE(__start_fs_data = .);
    KEEP(*(.fs_data))
    PROVIDE(__stop_fs_data = .);
  } > RAM
  .log_dynamic_data :
  {
    PROVIDE(__start_log_dynamic_data = .);
    KEEP(*(SORT(.log_dynamic_data*)))
    PROVIDE(__stop_log_dynamic_data = .);
  } > RAM
  .log_filter_data :
  {
    PROVIDE(__start_log_filter_data = .);
    KEEP(*(SORT(.log_filter_data*)))
    PROVIDE(__stop_log_filter_data = .);
  } > RAM

} INSERT AFTER .data;

SECTIONS
{
  .mem_section_dummy_rom :
  {
  }
  .sdh_soc_observers :
  {
    PROVIDE(__start_sdh_soc_observers = .);
    KEEP(*(SORT(.sdh_soc_observers*)))
    PROVIDE(__stop_sdh_soc_observers = .);
  } > FLASH
  .sdh_ble_observers :
  {
    PROVIDE(__start_sdh_ble_observers = .);
    KEEP(*(SORT(.sdh_ble_observers*)))
    PROVIDE(__stop_sdh_ble_observers = .);
  } > FLASH
  .pwr_mgmt_data :
  {
    PROVIDE(__start_pwr_mgmt_data = .);
    KEEP(*(SORT(.pwr_mgmt_data*)))
    PROVIDE(__stop_pwr_mgmt_data = .);
  } > FLASH
  .sdh_state_observers :
  {
    PROVIDE(__start_sdh_state_observers = .);
    KEEP(*(SORT(.sdh_state_observers*)))
    PROVIDE(__stop_sdh_state_observers = .);
  } > FLASH
  .sdh_stack_observers :
  {
    PROVIDE(__start_sdh_stack_observers = .);
    KEEP(*(SORT(.sdh_stack_observers*)))
    PROVIDE(__stop_sdh_stack_observers = .);
  } > FLASH
  .sdh_req_observers :
  {
    PROVIDE(__start_sdh_req_observers = .);
    KEEP(*(SORT(.sdh_req_observers*)))
    PROVIDE(__stop_sdh_req_observers = .);
  } > FLASH
  .nrf_queue :
  {
    PROVIDE(__start_nrf_queue = .);
    KEEP(*(.nrf_queue))
    PROVIDE(__stop_nrf_queue = .);
  } > FLASH
  .nrf_balloc :
  {
    PROVIDE(__start_nrf_balloc = .);
    KEEP(*(.nrf_balloc))
    PROVIDE(__stop_nrf_balloc = .);
  } > FLASH
  .crypto_data :
  {
    PROVIDE(__start_crypto_data = .);
    KEEP(*(SORT(.crypto_data*)))
    PROVIDE(__stop_crypto_data = .);
  } > FLASH
  .log_const_data :
  {
    PROVIDE(__start_log_const_data = .);
    KEEP(*(SORT(.log_const_data*)))
    PROVIDE(__stop_log_const_data = .);
  } > FLASH
  .log_backends :
  {
    PROVIDE(__start_log_backends = .);
    KEEP(*(SORT(.log_backends*)))
    PROVIDE(__stop_log_backends = .);
  } > FLASH
  .gnu_build_id :
  {
    PROVIDE(g_note_build_id = .);
    *(.note.gnu.build-id)
  } > FLASH

} INSERT AFTER .text


INCLUDE "nrf_common.ld"
