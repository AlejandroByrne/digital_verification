class fp_mult_smoke_seq extends uvm_sequence #(fp_mult_txn);
  `uvm_object_utils(fp_mult_smoke_seq)

  function new(string name="fp_mult_smoke_seq");
    super.new(name);
  endfunction: new

  task body();
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

    `uvm_info("SMOKE", $sformatf(
      "Sent: x=0x%04h * y=0x%04h, round=%0b",
      req.x_in, req.y_in, req.round_in), UVM_LOW)
  endtask: body
endclass: fp_mult_smoke_seq
