package sa_pkg;
  import uvm_pkg::*;
  import ha_pkg::*;
  import fa_pkg::*;
  `include "uvm_macros.svh"

  // Change this one value to resize the entire testbench + DUT
  parameter int SA_WIDTH = 4;

  // Transaction
  `include "sa_txn.svh"

  // Sequencer (depends on txn)
  `include "sa_sequencer.svh"

  // Driver + Monitor (depend on txn + interface)
  `include "sa_driver.svh"
  `include "sa_monitor.svh"

  // Sequences (depend on txn)
  `include "sa_random_sequence.svh"

  // Coverage + Scoreboard
  `include "sa_coverage.svh"
  `include "sa_scoreboard.svh"

  // Hierarchy
  `include "sa_agent.svh"
  `include "sa_env.svh"
  `include "sa_random_test.svh"
endpackage : sa_pkg
