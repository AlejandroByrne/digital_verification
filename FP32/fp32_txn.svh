// ============================================================
//  IEEE 754 Float32 Multiplier — Transaction
//
//  Data contract between all UVM components.
//  Inputs are randomizable (constrained in sequences, not here).
//  Outputs are captured by the monitor.
// ============================================================

class fp32_txn extends uvm_sequence_item;
    `uvm_object_utils(fp32_txn)

    // ── Stimulus (randomizable) ──
    rand logic [31:0] a_in;
    rand logic [31:0] b_in;
    rand logic [1:0]  rnd_mode;

    // ── Response (filled by monitor) ──
    logic [31:0] result;
    logic [4:0]  flags;

    function new(string name = "fp32_txn");
        super.new(name);
    endfunction : new

endclass : fp32_txn
