`include "uvm_macros.svh"
import uvm_pkg::*;

class my_sequence extends uvm_sequence #(my_txn);
    `uvm_object_utils(my_sequence)

    function new(string name="my_sequence");
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