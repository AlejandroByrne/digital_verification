class my_agent extends uvm_agent;
  `uvm_component_utils(my_agent)

  // The monitor is always present — both active and passive agents observe.
  my_monitor       my_monitor_h;

  // Driver and sequencer only exist in active mode.
  // In passive mode (e.g. when reused in a larger SoC testbench that drives
  // this interface from elsewhere), these are never created.
  my_driver        my_driver_h;
  bshift_sequencer my_sequencer_h;

  // Forwarding analysis port: passes monitor broadcasts up to the env so
  // the env can connect them to the scoreboard (or any other subscriber).
  // Always present regardless of active/passive mode.
  uvm_analysis_port #(bshift_txn) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    // Monitor and analysis port: always built.
    my_monitor_h = my_monitor::type_id::create("my_monitor_h", this);
    ap           = new("ap", this);

    // Driver and sequencer: only built in active mode.
    // get_is_active() reads the is_active field, which defaults to UVM_ACTIVE.
    // A parent test or env can switch this agent passive before build_phase
    // runs by setting is_active = UVM_PASSIVE via uvm_config_db.
    if (get_is_active() == UVM_ACTIVE) begin
      my_driver_h    = my_driver::type_id::create("my_driver_h",    this);
      my_sequencer_h = bshift_sequencer::type_id::create("my_sequencer_h", this);
    end
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    // Observation path: always connected.
    my_monitor_h.ap.connect(ap);

    // Stimulus path: only wired in active mode.
    if (get_is_active() == UVM_ACTIVE)
      my_driver_h.seq_item_port.connect(my_sequencer_h.seq_item_export);
  endfunction: connect_phase

endclass: my_agent
