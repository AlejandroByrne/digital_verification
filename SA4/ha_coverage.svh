// ============================================================
//  Half Adder — Functional Coverage
//
//  Subscribes to the monitor's analysis port (via ha_txn).
//  Samples input and output coverpoints + cross coverage.
//
//  Illegal cross bin: a_in=0 with carry_out=1
//    (carry = a & b, so carry can never be 1 when a is 0)
// ============================================================

class ha_coverage extends uvm_subscriber #(ha_txn);
    `uvm_component_utils(ha_coverage)

    // ── Local fields sampled by the covergroup ──
    logic a_in;
    logic b_in;
    logic carry_out;

    // ── Covergroup ──
    covergroup ha_cg;

        cp_a_in: coverpoint a_in {
            bins zero = {0};
            bins one  = {1};
        }

        cp_b_in: coverpoint b_in {
            bins zero = {0};
            bins one  = {1};
        }

        cp_carry_out: coverpoint carry_out {
            bins no_carry = {0};
            bins carry    = {1};
        }

        // Cross: did we see each a_in value with each carry outcome?
        // a_in=0 can never produce carry=1 (carry = a & b)
        cx_a_carry: cross cp_a_in, cp_carry_out {
            illegal_bins a0_carry1 = binsof(cp_a_in) intersect {0} &&
                                     binsof(cp_carry_out) intersect {1};
        }

    endgroup : ha_cg

    function new(string name = "ha_coverage", uvm_component parent = null);
        super.new(name, parent);
        ha_cg = new();
    endfunction : new

    // Called automatically each time the monitor broadcasts a transaction
    function void write(ha_txn t);
        a_in      = t.a_in;
        b_in      = t.b_in;
        carry_out = t.carry_out;
        ha_cg.sample();
    endfunction : write

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COV", $sformatf("cp_a_in:      %.1f%%", ha_cg.cp_a_in.get_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("cp_b_in:      %.1f%%", ha_cg.cp_b_in.get_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("cp_carry_out: %.1f%%", ha_cg.cp_carry_out.get_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("cx_a_carry:   %.1f%%", ha_cg.cx_a_carry.get_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("TOTAL:        %.1f%%", ha_cg.get_coverage()), UVM_LOW)
    endfunction : report_phase

endclass : ha_coverage
