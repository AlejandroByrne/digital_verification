class fa_agent extends uvm_agent;
  `uvm_component_utils(fa_agent)

  fa_sequencer fa_sequencer_h;
  fa_driver fa_driver_h;
  fa_monitor fa_monitor_h;
  fa_coverage fa_coverage_h;

  uvm_analysis_port #(fa_txn) analysis_port;

  function new(string name = "fa_agent", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    fa_sequencer_h = fa_sequencer::type_id::create("fa_sequencer_h", this);
    fa_driver_h = fa_driver::type_id::create("fa_driver_h", this);
    fa_monitor_h = fa_monitor::type_id::create("fa_monitor_h", this);
    fa_coverage_h = fa_coverage::type_id::create("fa_coverage_h", this);
    analysis_port = new("analysis_port", this);
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    // Connect the driver's input seq port to the sequencer's export port
    fa_driver_h.seq_item_port.connect(fa_sequencer_h.seq_item_export);
    // add agent as a subscriber to the monitor's analysis port
    fa_monitor_h.analysis_port.connect(analysis_port);
    // add coverage as a subscriber to the monitor's analysis port
    fa_monitor_h.analysis_port.connect(fa_coverage_h.analysis_export);
  endfunction : connect_phase

endclass : fa_agent
