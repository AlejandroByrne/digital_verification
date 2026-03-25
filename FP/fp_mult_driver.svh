class fp_mult_driver extends uvm_driver #(fp_mult_txn);
  `uvm_component_utils(fp_mult_driver)

  virtual fp_mult_if vif;

  function new(string name="fp_mult_driver", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  // Grab the virtual interface from config during build
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual fp_mult_if)::get(this, "", "fp_mult_vi", vif))
      `uvm_fatal("DRV", "No virtual interface found in config_db")
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    // Initialize interface signals to idle state
    vif.start_in = 1'b0;
    vif.x_in     = '0;
    vif.y_in     = '0;
    vif.round_in = 2'b00;

    forever begin
      // 1. Get next transaction from the sequencer (blocks until one is available)
      seq_item_port.get_next_item(req);

      // 2. Drive inputs onto the interface BEFORE asserting start
      @(posedge vif.clk);
      vif.x_in     = req.x_in;
      vif.y_in     = req.y_in;
      vif.round_in = req.round_in;
      vif.start_in = 1'b1;

      // 3. Wait one cycle — DUT registers go <= start_in on this edge
      //    After this edge: go=1, done_out=1, outputs are valid
      @(posedge vif.clk);
      vif.start_in = 1'b0;    // deassert after one cycle pulse

      // 4. Wait for done_out to confirm outputs are ready
      //    With the fixed DUT, done_out = go, so it should already be high.
      //    But we wait explicitly in case timing changes — defensive coding.
      @(posedge vif.clk iff vif.done_out);

      // 5. Tell the sequencer we're done with this transaction
      seq_item_port.item_done();
    end
  endtask: run_phase
endclass: fp_mult_driver
