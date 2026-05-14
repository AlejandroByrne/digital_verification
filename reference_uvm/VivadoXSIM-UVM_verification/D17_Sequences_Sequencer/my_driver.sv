`include "uvm_macros.svh"
import uvm_pkg::*;

class my_driver extends uvm_driver #(my_txn);
  `uvm_component_utils(my_driver)

  function new(string name="my_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    my_txn tx;
    forever begin
      seq_item_port.get_next_item(tx);
      `uvm_info("DRIVER", "Transaction received:", UVM_MEDIUM)
      tx.print();
      seq_item_port.item_done();
    end
  endtask
endclass
