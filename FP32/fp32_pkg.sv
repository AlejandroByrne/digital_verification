// ============================================================
//  IEEE 754 Float32 Multiplier — Package
//
//  All UVM classes live inside this package.
//  Include order matters: dependencies must come first.
// ============================================================

package fp32_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    typedef enum {
        RNE = 0,
        RTZ = 1,
        RDN = 2,
        RUP = 3
    } rnd_mode_t;

    typedef enum {
        ZERO      = 0,
        SUBNORMAL = 1,
        NORMAL    = 2,
        INFINITY  = 3,
        QNAN      = 4,
        SNAN      = 5
    } flags_t;

    // Transaction (no dependencies)
    `include "fp32_txn.svh"

    // Sequencer (depends on txn)
    `include "fp32_sequencer.svh"

    // Components that touch the interface
    `include "fp32_driver.svh"
    `include "fp32_monitor.svh"

    // Checking
    `include "fp32_scoreboard.svh"

    // Coverage collector — will be added here
    // `include "fp32_coverage.svh"

    // Sequences — will be added here
    // `include "fp32_smoke_seq.svh"
    // `include "fp32_random_seq.svh"
    // `include "fp32_directed_seq.svh"

    // Structural hierarchy
    `include "fp32_agent.svh"
    `include "fp32_env.svh"
    `include "fp32_base_test.svh"

endpackage : fp32_pkg
