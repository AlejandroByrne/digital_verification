`include "uvm_macros.svh"
import uvm_pkg::*;

class my_driver extends uvm_driver #(my_txn);
  `uvm_component_utils(my_driver)
  
  virtual my_if vif;
  bit drive_delay;
  bit fault_enable;

  uvm_analysis_port #(my_txn) ap;   // 🔥 ADD THIS

  function new(string name="my_driver", uvm_component parent=null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
      `uvm_fatal("DRV", "Virtual interface not found");
    
    if (!uvm_config_db#(bit)::get(this, "", "fault_enable", fault_enable))
      fault_enable = 0;
  endfunction

  task run_phase(uvm_phase phase);
    my_txn tx;
    forever begin
      // Wait for reset to deassert
      @(posedge vif.clk);
      if (vif.rst) begin
        vif.valid <= 0;
        continue;
      end

      seq_item_port.get_next_item(tx);
      
      drive(tx);
      // Step 2
      ap.write(tx);          // 🔥 broadcast intent

      seq_item_port.item_done();
    end
  endtask

  virtual task drive(my_txn t);
      // Drive DUT one
      if (fault_enable) begin
        `uvm_info("DRV", "Fault mode active", UVM_LOW)
          // Inject fault but still complete transfer
        vif.valid <= 1'b1;
        vif.data  <= 'hx;   // corrupted data
      end else begin
        //  Normal drive
        vif.valid <= 1'b1;
        vif.data  <= t.data;
      end

      // Hold data until ready
      do begin
        @(posedge vif.clk);
      end while (!vif.ready);

      // Handshake
      vif.valid <= 0;
  endtask
endclass
