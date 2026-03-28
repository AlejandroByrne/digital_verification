class sa_monitor extends uvm_monitor;
  `uvm_component_utils(sa_monitor)

  uvm_analysis_port #(sa_txn) analysis_port;
  virtual sa_if #(SA_WIDTH) dut_vi;

  function new(string name = "sa_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    analysis_port = new("analysis_port", this);
    if (!uvm_config_db #(virtual sa_if #(SA_WIDTH))::get(this, "", "sa_vi", dut_vi))
      `uvm_fatal("MON", "No virtual interface in config_db")
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    // Skip the first clock edge — inputs haven't been driven yet
    @(posedge dut_vi.clk);

    forever begin
      sa_txn tx;
      @(posedge dut_vi.clk);
      tx = sa_txn::type_id::create("tx");
      tx.a_in       = dut_vi.a_in;
      tx.b_in       = dut_vi.b_in;
      tx.result_out = dut_vi.result_out;
      tx.flags      = dut_vi.flags;
      analysis_port.write(tx);
    end
  endtask : run_phase
endclass : sa_monitor
