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
        FP_ZERO      = 0,
        FP_SUBNORMAL = 1,
        FP_NORMAL    = 2,
        FP_INFINITY  = 3,
        FP_QNAN      = 4,
        FP_SNAN      = 5
    } fp32_cls_t;

    function automatic fp32_cls_t classify_fp32(logic [31:0] f);
        logic [7:0]  exp  = f[30:23];
        logic [22:0] frac = f[22:0];
        if (exp == 8'h00) begin
            return (frac == 23'h0) ? FP_ZERO : FP_SUBNORMAL;
        end else if (exp == 8'hFF) begin
            if (frac == 23'h0) return FP_INFINITY;
            return frac[22] ? FP_QNAN : FP_SNAN;
        end else begin
            return FP_NORMAL;
        end
    endfunction

    // Transaction (no dependencies)
    `include "fp32_txn.svh"

    // Sequencer (depends on txn)
    `include "fp32_sequencer.svh"

    // Components that touch the interface
    `include "fp32_driver.svh"
    `include "fp32_monitor.svh"

    // Checking
    `include "fp32_scoreboard.svh"

    // Coverage collector
    `include "fp32_coverage.svh"

    // Sequences — will be added here
    // `include "fp32_smoke_seq.svh"
    // `include "fp32_random_seq.svh"
    // `include "fp32_directed_seq.svh"

    // Structural hierarchy
    `include "fp32_agent.svh"
    `include "fp32_env.svh"
    `include "fp32_base_test.svh"

endpackage : fp32_pkg
