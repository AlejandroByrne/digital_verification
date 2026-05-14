// ============================================================
//  FP32 — Smoke Directed Sequence
//  A handful of hand-picked vectors. No randomization.
// ============================================================

class fp32_smoke_seq extends uvm_sequence #(fp32_txn);
    `uvm_object_utils(fp32_smoke_seq)

    function new(string name = "fp32_smoke_seq");
        super.new(name);
    endfunction : new

    task drive_one(input logic [31:0] a, input logic [31:0] b, input logic [1:0] rnd);
        req = fp32_txn::type_id::create("req");
        start_item(req);
        req.a_in     = a;
        req.b_in     = b;
        req.rnd_mode = rnd;
        finish_item(req);
    endtask

    task body();
        // 3.0 * 2.0 = 6.0
        drive_one(32'h40400000, 32'h40000000, 2'b00);
        // 1.0 * 1.0 = 1.0
        drive_one(32'h3F800000, 32'h3F800000, 2'b00);
        // -1.5 * 2.0 = -3.0
        drive_one(32'hBFC00000, 32'h40000000, 2'b00);
        // 0.0 * 5.0 = 0.0
        drive_one(32'h00000000, 32'h40A00000, 2'b00);
        // Inf * 2.0 = Inf
        drive_one(32'h7F800000, 32'h40000000, 2'b00);
    endtask : body

endclass : fp32_smoke_seq
