class fp_mult_smoke_seq extends uvm_sequence #(fp_mult_txn);
  `uvm_object_utils(fp_mult_smoke_seq)

  function new(string name="fp_mult_smoke_seq");
    super.new(name);
  endfunction: new

  task body();
    fp_mult_txn req, req1, req2;
    // Single hardcoded multiply: 1.0 × 2.0 = 2.0
    // bfloat16-like encoding (1 sign + 8 exp + 7 fraction, bias=127):
    //   1.0 = 0_01111111_0000000 = 16'h3F80
    //   2.0 = 0_10000000_0000000 = 16'h4000
    //   Expected result: 2.0 = 16'h4000
    req = fp_mult_txn::type_id::create("req");
    start_item(req);
    req.x_in     = 16'h3F80;   // 1.0
    req.y_in     = 16'h4000;   // 2.0
    req.round_in = 2'b00;      // RNE (round to nearest even)
    finish_item(req);

    // Infinity example
    // For P = 8, E = 8, Emax is 127, thus Nmax ~= 2^127 = 1.7014 * 10^38
    // So (1.5 * 10^20) * (2.4 * 10^18) should be out of range
    // Answer should be ~= 3.6 * 10^38
    // Real answer is: 0x3e8e -> 0011111010001110
    // Exponent: 0011 1110, Significand: 1000 1110
    // Evaluates to: 4.213989e-20 This is wrong
    // FOr (1.5 * 10^20) closest we can get is 1.498798e20
    // Exponent: 1100 0010, Significand: 0000 0100
    // Combined with sign is: 16'hC204
    // For (2.4 * 10^18) closest we can get is 2.395915e18
    // Exponent: 1011 1100, Significand: 0000 1010
    // Combined with sign is: 16'hBC0A
    req1 = fp_mult_txn::type_id::create("req1");
    start_item(req1);
    req1.x_in = 16'hC204;
    req1.y_in = 16'hBC0A;
    req1.round_in = 2'b00; // RNE
    finish_item(req1);
    // But (5.5 * 10^18) * (2.4 * 10^18) should stay within Nmax
    // For (5.5 * 10^18) closest we can get is 5.4943915e18
    // Exponent: 1101 1101, Significand: 0011 0001
    // Combined with sign is: 16'hDD31
    // Answer should be: 1.32 * 10^37
    // Real answer is: 0x3e8e -> 0011 1110 1000 1110
    // Evaluates to:
    req2 = fp_mult_txn::type_id::create("req2");
    start_item(req2);
    req2.x_in = 16'hDD31;
    req2.y_in = 16'hBC0A; // same as req2
    req2.round_in = 2'b00; //RNE
    finish_item(req2);
    `uvm_info("SMOKE", $sformatf(
      "Sent: x=0x%04h * y=0x%04h, round=%0b",
      req.x_in, req.y_in, req.round_in), UVM_LOW)
  endtask: body
endclass: fp_mult_smoke_seq
