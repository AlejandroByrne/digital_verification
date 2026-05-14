`include "uvm_macros.svh"
import uvm_pkg::*;

class random_seq extends uvm_sequence #(my_txn);
    `uvm_object_utils(random_seq)

    function new(string name="random_seq");
        super.new(name);
    endfunction //new()

    virtual task pre_body();
        `uvm_info("SEQ_Rand", "pre_body: Random Sequence starting", UVM_MEDIUM)
    endtask

    task body();
        my_txn tx;

        if (starting_phase != null)
            starting_phase.raise_objection(this);
            
        repeat(10) begin
            tx = my_txn::type_id::create("tx");
            start_item(tx);
            assert(tx.randomize());
            finish_item(tx);
            `uvm_info("SEQ_Rand", "<Random Sequence>", UVM_MEDIUM)
        end

        if (starting_phase != null)
            starting_phase.drop_objection(this);
    endtask

    virtual task post_body();
        `uvm_info("SEQ_Rand", "post_body: Random Sequence completed", UVM_MEDIUM)
    endtask

endclass //my_sequence extends uvm_sequence