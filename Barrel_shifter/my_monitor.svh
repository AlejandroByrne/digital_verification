class my_monitor extends uvm_monitor;
  // register with the factory
  `uvm_component_utils(my_monitor)

  virtual dut_if dut_vi;

  // Analysis port: broadcasts completed transactions to any subscriber (scoreboard).
  // Unlike the driver's seq_item_port (1-to-1 pull), an analysis port is a 1-to-many
  // broadcast — the monitor doesn't know or care who is listening.
  uvm_analysis_port #(bshift_txn) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    my_dut_config cfg;
    if (!uvm_config_db #(my_dut_config)::get(this, "", "dut_config", cfg))
      `uvm_fatal("MY_MONITOR", "No dut_config found");
    dut_vi = cfg.dut_vi;
    ap = new("ap", this);
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    bshift_txn txn;
    forever begin
      // The barrel shifter is purely combinational: outputs settle as soon as
      // inputs change. Wait for any input to change, then give it 1ns to
      // propagate before sampling.
      @(dut_vi.x_in or dut_vi.s_in or dut_vi.op_in);
      #1;

      txn = bshift_txn::type_id::create("txn");

      // Capture inputs
      txn.x_in  = dut_vi.x_in;
      txn.s_in  = dut_vi.s_in;
      txn.op_in = dut_vi.op_in;

      // Capture DUT outputs
      txn.y_out  = dut_vi.y_out;
      txn.zf_out = dut_vi.zf_out;
      txn.vf_out = dut_vi.vf_out;

      // Broadcast to scoreboard (and any other future subscribers)
      ap.write(txn);
    end
  endtask: run_phase

endclass: my_monitor
