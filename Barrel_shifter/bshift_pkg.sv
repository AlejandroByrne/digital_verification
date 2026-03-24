package bshift_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // ------------------------------------------------------------------
  // Include order matters: each file can only reference names defined
  // above it. Dependency order is listed in comments.
  // ------------------------------------------------------------------

  // Data objects (uvm_object, no parent arg)
  `include "bshift_txn.svh"               // no custom deps
  `include "my_dut_config.svh"            // references virtual dut_if

  // Sequencer typedef (depends on bshift_txn)
  `include "bshift_sequencer.svh"

  // Sequences (depend on bshift_txn)
  `include "bshift_simple_seq.svh"
  `include "bshift_rand_seq.svh"
  `include "bshift_directed_edge_seq.svh"

  // Structural components (uvm_component, take parent arg)
  `include "my_driver.svh"                // depends on bshift_txn, my_dut_config
  `include "my_monitor.svh"               // depends on bshift_txn, my_dut_config
  `include "my_scoreboard.svh"            // depends on bshift_txn
  `include "bshift_coverage.svh"          // depends on bshift_txn
  `include "my_agent.svh"                 // depends on driver, sequencer, monitor
  `include "my_env.svh"                   // depends on agent, scoreboard

  // Tests — base class first, then all derived tests
  `include "my_base_test.svh"             // depends on my_env, my_dut_config
  `include "my_test.svh"                  // smoke test — extends my_base_test
  `include "test_directed.svh"            // extends my_base_test
  `include "test_random.svh"              // extends my_base_test

endpackage: bshift_pkg
