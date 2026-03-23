package bshift_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Include order matters: each file can only reference things defined above it.
  `include "bshift_txn.svh"        // transaction (no deps on other custom classes)
  `include "my_dut_config.svh"     // config object (references virtual dut_if)
  `include "bshift_sequencer.svh"  // typedef — depends on bshift_txn
  `include "bshift_simple_seq.svh" // sequence — depends on bshift_txn
  `include "my_driver.svh"         // driver — depends on bshift_txn, my_dut_config
  `include "my_agent.svh"          // agent — depends on my_driver, bshift_sequencer
  `include "my_env.svh"            // env — depends on my_agent
  `include "my_test.svh"           // test — depends on my_env, my_dut_config, bshift_simple_seq

endpackage: bshift_pkg
