class my_driver extends uvm_driver #(bshift_txn);
  `uvm_component_utils(my_driver)

  virtual dut_if dut_vi;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    my_dut_config dut_config;
    if (!uvm_config_db #(my_dut_config)::get(this, "", "dut_config", dut_config))
      `uvm_fatal("MY_DRIVER", "No dut_config found");
    dut_vi = dut_config.dut_vi;
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    bshift_txn txn;
    forever begin
      seq_item_port.get_next_item(txn);
      dut_vi.x_in  = txn.x_in;
      dut_vi.s_in  = txn.s_in;
      dut_vi.op_in = txn.op_in;
      #10;
      seq_item_port.item_done();
    end
  endtask: run_phase

endclass: my_driver
