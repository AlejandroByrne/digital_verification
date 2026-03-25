class fp_mult_monitor extends uvm_monitor;
  `uvm_component_utils(fp_mult_monitor)

  virtual fp_mult_if vif;

  // Analysis port: broadcast captured transactions to any subscriber
  // (scoreboard, coverage collector, or anything else that connects)
  uvm_analysis_port #(fp_mult_txn) analysis_port;

  function new(string name="fp_mult_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_port = new("analysis_port", this);
    if (!uvm_config_db #(virtual fp_mult_if)::get(this, "", "fp_mult_vi", vif))
      `uvm_fatal("MON", "No virtual interface in config_db")
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    fp_mult_txn txn;

    forever begin
      // ── 1. Wait for a new transaction: start_in asserted ──
      //    At this posedge, the driver has placed inputs on the bus
      //    and is holding start_in = 1.
      @(posedge vif.clk iff vif.start_in);

      // ── 2. Capture inputs ──
      txn          = fp_mult_txn::type_id::create("txn");
      txn.x_in     = vif.x_in;
      txn.y_in     = vif.y_in;
      txn.round_in = vif.round_in;

      // ── 3. Wait for outputs to be valid: done_out asserted ──
      //    DUT timing: go registers start_in one cycle later,
      //    done_out = go, so outputs are valid the cycle after start.
      @(posedge vif.clk iff vif.done_out);

      // ── 4. Capture outputs ──
      txn.p_out   = vif.p_out;
      txn.oor_out = vif.oor_out;

      `uvm_info("MON", $sformatf(
        "Captured: x=0x%04h y=0x%04h rnd=%0b → p=0x%04h oor=%04b",
        txn.x_in, txn.y_in, txn.round_in, txn.p_out, txn.oor_out), UVM_HIGH)

      // ── 5. Broadcast to all subscribers (scoreboard, coverage, etc.) ──
      analysis_port.write(txn);
    end
  endtask: run_phase
endclass: fp_mult_monitor
