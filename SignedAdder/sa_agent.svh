class sa_agent extends uvm_agent;
  `uvm_component_utils(sa_agent)

  sa_sequencer sa_sequencer_h;
  sa_driver    sa_driver_h;
  sa_monitor   sa_monitor_h;

  // Expose the monitor's analysis port at the agent level
  uvm_analysis_port #(sa_txn) analysis_port;

  function new(string name = "sa_agent", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    // Monitor always exists (active or passive)
    sa_monitor_h = sa_monitor::type_id::create("sa_monitor_h", this);
    analysis_port = new("analysis_port", this);

    // Driver + sequencer only in active mode
    if (get_is_active() == UVM_ACTIVE) begin
      sa_sequencer_h = sa_sequencer::type_id::create("sa_sequencer_h", this);
      sa_driver_h    = sa_driver::type_id::create("sa_driver_h", this);
    end
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    // Monitor broadcasts to anyone connected at the env level
    sa_monitor_h.analysis_port.connect(analysis_port);

    // Driver pulls from sequencer (active mode only)
    if (get_is_active() == UVM_ACTIVE)
      sa_driver_h.seq_item_port.connect(sa_sequencer_h.seq_item_export);
  endfunction : connect_phase

endclass : sa_agent
