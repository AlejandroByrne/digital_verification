// ============================================================
//  FIFO — Package
// ============================================================

package fifo_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Configuration
    `include "fifo_config.svh"

    // Transaction
    `include "fifo_txn.svh"

    // Sequencer
    `include "fifo_sequencer.svh"

    // Components
    `include "fifo_driver.svh"
    `include "fifo_monitor.svh"
    `include "fifo_agent.svh"

    // Verification
    `include "fifo_scoreboard.svh"
    `include "fifo_coverage.svh"

    // Hierarchy
    `include "fifo_env.svh"
    `include "fifo_base_test.svh"

    // Sequences
    `include "fifo_sequences.svh"

    // Tests
    `include "fifo_tests.svh"

endpackage : fifo_pkg
