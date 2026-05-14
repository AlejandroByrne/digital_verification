`include "uvm_macros.svh"
import uvm_pkg::*;

class my_driver extends uvm_driver #(my_txn);
  `uvm_component_utils(my_driver)
  
  virtual my_if vif;

  function new(string name="my_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not found");
  endfunction

  task run_phase(uvm_phase phase);
    my_txn tx;
    forever begin
      seq_item_port.get_next_item(tx);
      
      // Drive DUT
      vif.valid <= 1;
      vif.data  <= tx.data;
      @(posedge vif.clk);
      vif.valid <= 0;

      seq_item_port.item_done();
    end
  endtask
endclass
