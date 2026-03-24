class my_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(my_scoreboard)

  // Analysis imp: the receiving end of the monitor's broadcast.
  // uvm_analysis_imp #(TransactionType, ThisClass)
  // UVM calls this.write(txn) whenever the monitor does ap.write(txn).
  uvm_analysis_imp #(bshift_txn, my_scoreboard) analysis_export;

  int pass_count;
  int fail_count;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    pass_count = 0;
    fail_count = 0;
  endfunction: new

  function void build_phase(uvm_phase phase);
    analysis_export = new("analysis_export", this);
  endfunction: build_phase

  // Called automatically by UVM whenever the monitor broadcasts a transaction.
  function void write(bshift_txn txn);
    logic [7:0] exp_y;
    logic       exp_zf;
    logic       exp_vf;

    // Run the same inputs through our software reference model
    predict(txn.x_in, txn.s_in, txn.op_in, exp_y, exp_zf, exp_vf);

    // Compare DUT output against expected
    if (txn.y_out === exp_y && txn.zf_out === exp_zf && txn.vf_out === exp_vf) begin
      `uvm_info("SCOREBOARD",
        $sformatf("PASS | x=%08b s=%0d op=%03b | y=%08b zf=%0b vf=%0b",
          txn.x_in, txn.s_in, txn.op_in, txn.y_out, txn.zf_out, txn.vf_out),
        UVM_LOW)
      pass_count++;
    end else begin
      `uvm_error("SCOREBOARD",
        $sformatf("FAIL | x=%08b s=%0d op=%03b | got y=%08b zf=%0b vf=%0b | exp y=%08b zf=%0b vf=%0b",
          txn.x_in, txn.s_in, txn.op_in,
          txn.y_out,  txn.zf_out,  txn.vf_out,
          exp_y,      exp_zf,      exp_vf))
      fail_count++;
    end
  endfunction: write

  // -----------------------------------------------------------------------
  // Reference model — exact software mirror of barrelshifter_ref.v
  //
  // op_in encoding:
  //   000 = shift right logical   (SRL)
  //   001 = shift right arith.    (SRA)
  //   01x = rotate right          (ROR)
  //   100 = shift left logical    (SLL)
  //   101 = shift left arithmetic (SLA)
  //   11x = rotate left           (ROL)
  // -----------------------------------------------------------------------
  function void predict(
    input  logic [7:0] x_in,
    input  logic [2:0] s_in,
    input  logic [2:0] op_in,
    output logic [7:0] exp_y,
    output logic       exp_zf,
    output logic       exp_vf
  );
    logic [7:0] shifted_out;
    logic       msb;

    casez (op_in)
      3'b000: exp_y = x_in >> s_in;                                          // SRL
      3'b001: exp_y = $signed(x_in) >>> s_in;                                // SRA
      3'b01?: exp_y = (x_in >> s_in) | (x_in << (-s_in));                   // ROR
      3'b100: exp_y = x_in << s_in;                                          // SLL
      3'b101: exp_y = ((x_in <<< s_in) & 8'h7F) | (x_in & 8'h80);          // SLA — sign bit preserved
      3'b11?: exp_y = (x_in << s_in) | (x_in >> (-s_in));                   // ROL
      default: exp_y = 'x;
    endcase

    // Overflow: only meaningful for SLA (op 101).
    // If any bit shifted out of the mantissa differs from the sign bit → overflow.
    // ~s_in is a 3-bit trick: for D_SIZE=8 (power of 2), ~s_in == 7-s_in,
    // so $signed(x_in) >>> ~s_in gives us the bits that were shifted out.
    msb         = x_in[7];
    shifted_out = $signed(x_in) >>> ~s_in;
    exp_vf      = (op_in == 3'b101) && |(shifted_out[6:0] ^ {7{msb}});

    // Zero flag: all output bits are 0
    exp_zf = &(~exp_y);

  endfunction: predict

  // Print a summary at the end of the simulation
  function void report_phase(uvm_phase phase);
    `uvm_info("SCOREBOARD",
      $sformatf("RESULTS: %0d PASS  %0d FAIL", pass_count, fail_count),
      UVM_NONE)
  endfunction: report_phase

endclass: my_scoreboard
