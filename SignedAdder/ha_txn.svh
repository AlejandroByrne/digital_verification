// ============================================================
//  Half Adder — Transaction
//
//  Data contract between all UVM components.
//  Inputs are randomizable. Outputs captured by monitor (later).
// ============================================================

class ha_txn extends uvm_sequence_item;
    `uvm_object_utils(ha_txn)

    // ── Stimulus (randomizable) ──
    rand logic a_in;
    rand logic b_in;

    // ── Response (filled by monitor later) ──
    logic result_out;
    logic carry_out;

    function new(string name = "ha_txn");
        super.new(name);
    endfunction : new

endclass : ha_txn
