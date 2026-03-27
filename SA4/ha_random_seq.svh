// ============================================================
//  Half Adder — Random Sequence
//
//  Sends N unconstrained random transactions.
//  Use for coverage ramp-up once coverage collector is added.
// ============================================================

class ha_random_seq extends uvm_sequence #(ha_txn);
    `uvm_object_utils(ha_random_seq)

    int unsigned num_txns = 20;

    function new(string name = "ha_random_seq");
        super.new(name);
    endfunction : new

    task body();
        ha_txn txn;

        for (int i = 0; i < num_txns; i++) begin
            txn = ha_txn::type_id::create($sformatf("txn_%0d", i));
            start_item(txn);
            assert(txn.randomize()) else `uvm_fatal("SEQ", "Randomization failed")
            finish_item(txn);
        end
    endtask : body

endclass : ha_random_seq
