class fa_driver extends uvm_driver #(fa_txn);
  `uvm_component_utils(fa_driver)

  virtual fa_if dut_if;

  function new(string name = "fa_driver", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual fa_if)::get(this, "", "fa_vi", dut_if))
      `uvm_fatal("DVR", "No virtual interface in config_db");
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    forever begin
      fa_txn tx;
      @(posedge dut_if.clk);
      seq_item_port.get_next_item(tx); // ask for the next transaction. calls the sequencer,
      // and the sequencer unblocks the sequence's start_item() call
      dut_if.a_in = tx.a_in;
      dut_if.b_in = tx.b_in;
      dut_if.carry_in = tx.carry_in;
      seq_item_port.item_done(); // unblocks the finish_item() in the sequence to return
    end
  endtask : run_phase
endclass : fa_driver
