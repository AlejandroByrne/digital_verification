class fa_monitor extends uvm_monitor;
  `uvm_component_utils(fa_monitor)

  uvm_analysis_port #(fa_txn) analysis_port;
  virtual fa_if dut_vi;

  function new(string name = "fa_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    analysis_port = new("analysis_port", this);
    if (!uvm_config_db #(virtual fa_if)::get(this, "", "fa_vi", dut_vi))
      `uvm_fatal("MON", "No virtual interface in config_db");
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    forever begin
      fa_txn tx;
      @(posedge dut_vi.clk);
      tx = fa_txn::type_id::create("tx");
      tx.a_in  = dut_vi.a_in;
      tx.b_in = dut_vi.b_in;
      tx.carry_in = dut_vi.carry_in;
      tx.result_out = dut_vi.result_out;
      tx.carry_out = dut_vi.carry_out;
      analysis_port.write(tx); // send it out to all the subscribers, and those subscribers
      // implement the "write" function to accept this payload and do something with it
    end
  endtask : run_phase
endclass : fa_monitor
