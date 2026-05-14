`include "uvm_macros.svh"
import uvm_pkg::*;

class my_sequencer extends uvm_sequencer #(my_txn);
    `uvm_component_utils(my_sequencer)

    function new(string name="my_sequencer", uvm_component parent=null);
        super.new(name, parent);
    endfunction //new()
endclass //my_sequencer extends uvm_sequencer