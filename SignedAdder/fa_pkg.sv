package fa_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Includes in order of dependencies
  `include "fa_txn.svh"

  // Sequencer (depends on txn)
  `include "fa_sequencer.svh"

  // Driver (depends on txn + interface)
  `include "fa_driver.svh"

  // Monitor (depends on txn + interface)
  `include "fa_monitor.svh"

  // Sequences
  `include "fa_random_sequence.svh"

  // Rest of heirarchy
  `include "fa_coverage.svh"
  `include "fa_agent.svh"
  `include "fa_env.svh"
  `include "fa_random_test.svh"
endpackage : fa_pkg
