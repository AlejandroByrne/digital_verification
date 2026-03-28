class sa_driver extends uvm_driver #(sa_txn);
  `uvm_component_utils(sa_driver)

  virtual sa_if #(SA_WIDTH) dut_vi;

  function new(string name = "sa_driver", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual sa_if #(SA_WIDTH))::get(this, "", "sa_vi", dut_vi))
      `uvm_fatal("DVR", "No virtual interface in config_db")
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    forever begin
      sa_txn tx;
      @(posedge dut_vi.clk);
      seq_item_port.get_next_item(tx);
      dut_vi.a_in = tx.a_in;
      dut_vi.b_in = tx.b_in;
      seq_item_port.item_done();
    end
  endtask : run_phase
endclass : sa_driver
