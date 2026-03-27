// ============================================================
//  Half Adder — Package
//
//  All UVM classes live inside this package.
//  Include order matters: dependencies must come first.
// ============================================================

package ha_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Transaction (no dependencies)
    `include "ha_txn.svh"

    // Sequencer (depends on txn)
    `include "ha_sequencer.svh"

    // Driver (depends on txn + interface)
    `include "ha_driver.svh"

    // Monitor (depends on txn + interface)
    `include "ha_monitor.svh"

    // Coverage (depends on txn)
    `include "ha_coverage.svh"

    // Scoreboard (depends on txn)
    `include "ha_scoreboard.svh"

    // Sequences
    `include "ha_smoke_seq.svh"
    `include "ha_random_seq.svh"

    // Structural hierarchy
    `include "ha_agent.svh"
    `include "ha_env.svh"
    `include "ha_base_test.svh"
    `include "ha_smoke_test.svh"
    `include "ha_random_test.svh"

endpackage : ha_pkg
