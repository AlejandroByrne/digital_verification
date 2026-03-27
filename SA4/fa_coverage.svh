class fa_coverage extends uvm_subscriber #(fa_txn);
  `uvm_component_utils(fa_coverage)

  // Local fields sampled by the coverage group
  logic a_in;
  logic b_in;
  logic carry_in;
  logic result_out;
  logic carry_out;

  covergroup fa_cg;
    // Coverpoints
    cp_a_in: coverpoint a_in {
      bins zero = {0};
      bins one = {1};
    }

    cp_b_in: coverpoint b_in {
      bins zero = {0};
      bins one = {1};
    }

    cp_carry_in: coverpoint carry_in {
      bins no_carry = {0};
      bins carry = {1};
    }

    cp_result_out: coverpoint result_out {
      bins zero = {0};
      bins one = {1};
    }

    cp_carry_out: coverpoint carry_out {
      bins no_carry = {0};
      bins carry = {1};
    }

    cx_a_carry: cross a_in, carry_out;
  endgroup : fa_cg

  function new(string name = "fa_coverage", uvm_component parent = null);
    super.new(name, parent);
    fa_cg = new();
  endfunction : new

  function void write(fa_txn t);
    a_in = t.a_in;
    b_in = t.b_in;
    carry_in = t.carry_in;
    result_out = t.result_out;
    carry_out = t.carry_out;
    fa_cg.sample(); // place current values into respective coverpoint bins
  endfunction : write

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("COV", $sformatf("cp_a_in:       %.1f%%", fa_cg.cp_a_in.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("cp_b_in:       %.1f%%", fa_cg.cp_b_in.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("cp_carry_in:   %.1f%%", fa_cg.cp_carry_in.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("cp_result_out: %.1f%%", fa_cg.cp_result_out.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("cp_carry_out:  %.1f%%", fa_cg.cp_carry_out.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("cx_a_carry:    %.1f%%", fa_cg.cx_a_carry.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("TOTAL:         %.1f%%", fa_cg.get_coverage()), UVM_LOW)
  endfunction : report_phase
endclass : fa_coverage
