class my_faulty_driver extends my_driver;
  `uvm_component_utils(my_faulty_driver)

  virtual my_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
      `uvm_fatal("DRV", "Virtual interface not found");
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

      seq_item_port.item_done();
    end
  endtask

  // Override behavior only
  virtual task drive(my_txn t);
    `uvm_info("FAULTY_DRV", "Injecting protocol violation", UVM_MEDIUM)

    vif.valid <= 1;
    vif.data  <= t.data;

    // ❌ Violation: deassert valid too early
    #1;
    vif.valid <= 0;
  endtask
endclass
