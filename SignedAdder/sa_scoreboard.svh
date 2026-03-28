class sa_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(sa_scoreboard)

  uvm_analysis_imp #(sa_txn, sa_scoreboard) imp;

  int unsigned pass_count;
  int unsigned fail_count;

  function new(string name = "sa_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    imp = new("imp", this);
    pass_count = 0;
    fail_count = 0;
  endfunction : build_phase

  // ── Reference model ──
  // Compute expected result and flags independently from the DUT.
  function void write(sa_txn t);
    // Sign-extend to one extra bit so we can detect overflow/underflow
    logic signed [SA_WIDTH:0] a_ext, b_ext, sum_ext;
    logic signed [SA_WIDTH-1:0] expected_result;
    logic [1:0] expected_flags;

    a_ext = { t.a_in[SA_WIDTH-1], t.a_in };  // sign-extend
    b_ext = { t.b_in[SA_WIDTH-1], t.b_in };
    sum_ext = a_ext + b_ext;

    expected_result = sum_ext[SA_WIDTH-1:0];  // truncate back to WIDTH

    // Overflow:  two positives produced a negative
    // Underflow: two negatives produced a positive
    expected_flags[0] = ~t.a_in[SA_WIDTH-1] & ~t.b_in[SA_WIDTH-1] &  expected_result[SA_WIDTH-1];
    expected_flags[1] =  t.a_in[SA_WIDTH-1] &  t.b_in[SA_WIDTH-1] & ~expected_result[SA_WIDTH-1];

    if (t.result_out !== expected_result || t.flags !== expected_flags) begin
      `uvm_error("SB", $sformatf(
        "MISMATCH: a=%0d b=%0d | got result=%0d flags=%02b | expected result=%0d flags=%02b",
        signed'(t.a_in), signed'(t.b_in),
        signed'(t.result_out), t.flags,
        signed'(expected_result), expected_flags))
      fail_count++;
    end else begin
      `uvm_info("SB", $sformatf(
        "PASS: a=%0d + b=%0d = %0d  flags=%02b",
        signed'(t.a_in), signed'(t.b_in),
        signed'(t.result_out), t.flags), UVM_HIGH)
      pass_count++;
    end
  endfunction : write

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SB", $sformatf("Results: %0d passed, %0d failed out of %0d total",
      pass_count, fail_count, pass_count + fail_count), UVM_LOW)
    if (fail_count > 0)
      `uvm_error("SB", "TEST FAILED — see mismatches above")
    else
      `uvm_info("SB", "ALL TRANSACTIONS PASSED", UVM_LOW)
  endfunction : report_phase

endclass : sa_scoreboard
