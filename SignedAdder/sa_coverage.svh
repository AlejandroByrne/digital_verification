class sa_coverage extends uvm_subscriber #(sa_txn);
  `uvm_component_utils(sa_coverage)

  // Signals to be covered
  logic [SA_WIDTH-1:0] a_in;
  logic [SA_WIDTH-1:0] b_in;
  logic [SA_WIDTH-1:0] result_out;
  logic [1:0]          flags;

  covergroup sa_cg;

    cp_a_in: coverpoint a_in {
      bins zero     = {0};
      bins negative = {[(1 << (SA_WIDTH-1)) : ((1 << SA_WIDTH) - 1)]};  // MSB=1: negative
      bins positive = {[1 : ((1 << (SA_WIDTH-1)) - 1)]};               // MSB=0, nonzero: positive
    }

    cp_b_in: coverpoint b_in {
      bins zero     = {0};
      bins negative = {[(1 << (SA_WIDTH-1)) : ((1 << SA_WIDTH) - 1)]};
      bins positive = {[1 : ((1 << (SA_WIDTH-1)) - 1)]};
    }

    cp_result_out: coverpoint result_out {
      bins zero     = {0};
      bins negative = {[(1 << (SA_WIDTH-1)) : ((1 << SA_WIDTH) - 1)]};
      bins positive = {[1 : ((1 << (SA_WIDTH-1)) - 1)]};
    }

    cp_flags: coverpoint flags {
      bins normal    = {2'b00};
      bins overflow  = {2'b01};
      bins underflow = {2'b10};
      illegal_bins over_and_under_flow = {2'b11};
    }

    cx_a_flags: cross cp_a_in, cp_flags {
      // These combos are structurally impossible — exclude from coverage goal
      // Can't overflow/underflow when a_in is zero
      ignore_bins zero_overflow  = binsof(cp_a_in) intersect {0} && binsof(cp_flags) intersect {2'b01};
      ignore_bins zero_underflow = binsof(cp_a_in) intersect {0} && binsof(cp_flags) intersect {2'b10};
      // Positive a_in can never cause underflow (needs both negative)
      ignore_bins pos_underflow  = binsof(cp_a_in.positive) && binsof(cp_flags) intersect {2'b10};
      // Negative a_in can never cause overflow (needs both positive)
      ignore_bins neg_overflow   = binsof(cp_a_in.negative) && binsof(cp_flags) intersect {2'b01};
    }
  endgroup : sa_cg

  function new(string name = "sa_coverage", uvm_component parent = null);
    super.new(name, parent);
    sa_cg = new();
  endfunction : new

  function void write(sa_txn t);
    a_in       = t.a_in;
    b_in       = t.b_in;
    result_out = t.result_out;
    flags      = t.flags;
    sa_cg.sample();
  endfunction : write

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("COV", $sformatf("cp_a_in:       %.1f%%", sa_cg.cp_a_in.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("cp_b_in:       %.1f%%", sa_cg.cp_b_in.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("cp_result_out: %.1f%%", sa_cg.cp_result_out.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("cp_flags:      %.1f%%", sa_cg.cp_flags.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("cx_a_flags:    %.1f%%", sa_cg.cx_a_flags.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("TOTAL:         %.1f%%", sa_cg.get_coverage()), UVM_LOW)
  endfunction : report_phase
endclass : sa_coverage
