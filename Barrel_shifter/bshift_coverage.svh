// ============================================================================
// bshift_coverage — functional coverage collector
//
// Extends uvm_subscriber, which is a convenience base class that:
//   1. Automatically creates an analysis_export (no need to declare one)
//   2. Requires you to implement write() — called on every broadcast
//
// This class is ONLY about coverage. It does not check correctness (that
// is the scoreboard's job). The separation matters: coverage answers
// "did we exercise this case?", not "was the result correct?".
// ============================================================================
class bshift_coverage extends uvm_subscriber #(bshift_txn);
  `uvm_component_utils(bshift_coverage)

  // The current transaction. Updated in write() before sampling.
  // The covergroup references this handle's fields directly.
  bshift_txn txn;

  // -----------------------------------------------------------------------
  // Covergroup definition
  //
  // A covergroup is a SystemVerilog construct, not a UVM construct.
  // It must be instantiated (like a class) before it can collect data.
  // We instantiate it in new() below.
  // -----------------------------------------------------------------------
  covergroup bshift_cg;

    // -------------------------------------------------------------------
    // COVERPOINT: op_in
    //
    // 6 named bins — groups the two ROR aliases (010/011) into one bin
    // and the two ROL aliases (110/111) into one bin. We care that ROR
    // was exercised, not which alias was used.
    // -------------------------------------------------------------------
    cp_op: coverpoint txn.op_in {
      bins srl = {3'b000};
      bins sra = {3'b001};
      bins ror = {3'b010, 3'b011};   // both encodings behave identically
      bins sll = {3'b100};
      bins sla = {3'b101};
      bins rol = {3'b110, 3'b111};   // both encodings behave identically
    }

    // -------------------------------------------------------------------
    // COVERPOINT: s_in
    //
    // Individual bins for every shift amount.
    // The [] after mid_shifts creates one bin per value automatically:
    //   mid_shifts[1], mid_shifts[2], ..., mid_shifts[6]
    // We keep 0 and 7 as named bins because they are semantically
    // distinct (identity and maximum-shift edge cases).
    // -------------------------------------------------------------------
    cp_shift: coverpoint txn.s_in {
      bins no_shift     = {3'd0};
      bins max_shift    = {3'd7};
      bins mid_shifts[] = {[3'd1:3'd6]};
    }

    // -------------------------------------------------------------------
    // COVERPOINT: x_in
    //
    // We don't need a bin for every one of the 256 possible values — that
    // would create 256 bins and be slow to close. Instead we define bins
    // for the classes of values that stress different parts of the logic:
    //
    //   all_zeros (0x00)     → guaranteed zero output; zero flag must fire
    //   all_ones  (0xFF)     → stresses SRL zero-fill and SLA overflow
    //   msb_only  (0x80)     → negative in signed ops; tests SRA sign ext.
    //   lsb_only  (0x01)     → stresses ROR/ROL single-bit wrap-around
    //   positive  (0x02–7F)  → MSB clear; non-special positive values
    //   negative  (0x81–FE)  → MSB set; non-special negative values
    //
    // A single bin for the entire range [0x02:0x7F] is hit the moment any
    // one value in that range appears — you don't need all 126 of them.
    // -------------------------------------------------------------------
    cp_x: coverpoint txn.x_in {
      bins all_zeros = {8'h00};
      bins all_ones  = {8'hFF};
      bins msb_only  = {8'h80};
      bins lsb_only  = {8'h01};
      bins positive  = {[8'h02:8'h7F]};
      bins negative  = {[8'h81:8'hFE]};
    }

    // -------------------------------------------------------------------
    // COVERPOINT: zf_out
    //
    // Did the zero flag ever fire (output = all zeros)?
    // Did it ever stay clear (output has at least one 1)?
    // Both must be hit for meaningful coverage.
    // -------------------------------------------------------------------
    cp_zf: coverpoint txn.zf_out {
      bins zf_clear = {1'b0};
      bins zf_set   = {1'b1};
    }

    // -------------------------------------------------------------------
    // COVERPOINT: vf_out
    //
    // Did the overflow flag ever fire? vf=1 is only possible for SLA
    // (op=101). If this bin is never hit, no overflow scenario was
    // exercised — meaning the SLA overflow path is uncovered.
    // -------------------------------------------------------------------
    cp_vf: coverpoint txn.vf_out {
      bins vf_clear = {1'b0};
      bins vf_set   = {1'b1};
    }

    // -------------------------------------------------------------------
    // CROSS: op × shift amount
    //
    // The most important cross in this testbench.
    // Ensures every operation was exercised with every shift amount.
    // 6 op bins × 8 shift bins = 48 cross bins.
    //
    // Example bug this catches: a DUT that works for s_in=1 on all ops,
    // but silently treats s_in=7 as s_in=0 for SRA only. Pure op or pure
    // shift coverpoints would both show 100% — only the cross exposes it.
    // -------------------------------------------------------------------
    cx_op_shift: cross cp_op, cp_shift;

    // -------------------------------------------------------------------
    // CROSS: op × x_in class
    //
    // Ensures every operation was exercised with each interesting input
    // class. 6 op bins × 6 x_in bins = 36 cross bins.
    //
    // Example: SRA with MSB clear (positive) vs MSB set (negative) must
    // both be hit to verify that sign extension works in both directions.
    // -------------------------------------------------------------------
    cx_op_x: cross cp_op, cp_x;

  endgroup: bshift_cg

  function new(string name, uvm_component parent);
    super.new(name, parent);
    // Covergroups are not automatically instantiated — unlike class fields,
    // they require an explicit new(). Without this line, sample() would
    // crash with a null-handle error.
    bshift_cg = new();
  endfunction: new

  // Called automatically by UVM whenever the monitor broadcasts a transaction.
  function void write(bshift_txn t);
    txn = t;           // point the covergroup at this transaction's fields
    bshift_cg.sample(); // trigger one sample of every coverpoint
  endfunction: write

  // Print coverage summary at end of simulation
  function void report_phase(uvm_phase phase);
    `uvm_info("COVERAGE", $sformatf("Overall  : %0.1f%%",
        bshift_cg.get_coverage()),             UVM_NONE)
    `uvm_info("COVERAGE", $sformatf("cp_op    : %0.1f%%",
        bshift_cg.cp_op.get_coverage()),       UVM_NONE)
    `uvm_info("COVERAGE", $sformatf("cp_shift : %0.1f%%",
        bshift_cg.cp_shift.get_coverage()),    UVM_NONE)
    `uvm_info("COVERAGE", $sformatf("cp_x     : %0.1f%%",
        bshift_cg.cp_x.get_coverage()),        UVM_NONE)
    `uvm_info("COVERAGE", $sformatf("cp_zf    : %0.1f%%",
        bshift_cg.cp_zf.get_coverage()),       UVM_NONE)
    `uvm_info("COVERAGE", $sformatf("cp_vf    : %0.1f%%",
        bshift_cg.cp_vf.get_coverage()),       UVM_NONE)
    `uvm_info("COVERAGE", $sformatf("cx_op_shift : %0.1f%%",
        bshift_cg.cx_op_shift.get_coverage()), UVM_NONE)
    `uvm_info("COVERAGE", $sformatf("cx_op_x     : %0.1f%%",
        bshift_cg.cx_op_x.get_coverage()),     UVM_NONE)
  endfunction: report_phase


endclass: bshift_coverage
