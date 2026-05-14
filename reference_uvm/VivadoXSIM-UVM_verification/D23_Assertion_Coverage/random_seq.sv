`include "uvm_macros.svh"
import uvm_pkg::*;

class random_seq extends uvm_sequence #(my_txn);
    `uvm_object_utils(random_seq)

    function new(string name="random_seq");
        super.new(name);
    endfunction //new()

    task body();
        my_txn tx;

        repeat(10) begin
           tx = my_txn::type_id::create("tx");
           start_item(tx);
           assert(tx.randomize());
           finish_item(tx);
        end
    endtask

endclass //my_sequence extends uvm_sequence