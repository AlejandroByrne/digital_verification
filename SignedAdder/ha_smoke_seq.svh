// ============================================================
//  Half Adder — Smoke Sequence
//
//  Exhaustive: all 4 input combinations for a 2-input gate.
// ============================================================

class ha_smoke_seq extends uvm_sequence #(ha_txn);
    `uvm_object_utils(ha_smoke_seq)

    function new(string name = "ha_smoke_seq");
        super.new(name);
    endfunction : new

    task body();
        ha_txn txn;

        for (int a = 0; a < 2; a++) begin
            for (int b = 0; b < 2; b++) begin
                txn = ha_txn::type_id::create($sformatf("txn_a%0d_b%0d", a, b));
                start_item(txn);
                assert(txn.randomize() with {
                    a_in == a[0];
                    b_in == b[0];
                }) else `uvm_fatal("SEQ", "Randomization failed")
                `uvm_info("SMOKE", $sformatf("Driving a=%0b b=%0b", txn.a_in, txn.b_in), UVM_MEDIUM)
                finish_item(txn);
            end
        end
    endtask : body

endclass : ha_smoke_seq
