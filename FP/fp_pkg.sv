package fp_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Configurable variables
  // Default should be single FP (32 bits)
  localparam P = 8;
  localparam E = 8;

  `include "fp_mult_txn.svh"
  `include "fp_mult_config.svh"
  `include "fp_mult_sequencer.svh"
  `include "fp_mult_driver.svh"
  `include "fp_mult_smoke_seq.svh"
  `include "fp_mult_agent.svh"
  `include "fp_mult_env.svh"
  `include "fp_mult_base_test.svh"
  // add new includes as the components are implemented
endpackage
