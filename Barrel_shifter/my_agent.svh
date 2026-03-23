class my_agent extends uvm_agent;
  `uvm_component_utils(my_agent)

  my_driver        my_driver_h;
  bshift_sequencer my_sequencer_h;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    my_driver_h    = my_driver::type_id::create("my_driver_h", this);
    my_sequencer_h = bshift_sequencer::type_id::create("my_sequencer_h", this);
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    my_driver_h.seq_item_port.connect(my_sequencer_h.seq_item_export);
  endfunction: connect_phase

endclass: my_agent
