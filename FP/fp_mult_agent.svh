class fp_mult_agent extends uvm_agent;
  `uvm_component_utils(fp_mult_agent)

  fp_mult_driver    drv;
  fp_mult_sequencer sqr;
  // Monitor will be added here later (always created, active or passive)

  function new(string name="fp_mult_agent", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Only create driver + sequencer if agent is ACTIVE
    // (passive agent = monitor only, for observation without driving)
    if (get_is_active() == UVM_ACTIVE) begin
      drv = fp_mult_driver::type_id::create("drv", this);
      sqr = fp_mult_sequencer::type_id::create("sqr", this);
    end

    // Monitor creation will go here
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Wire the driver's seq_item_port to the sequencer's export
    // This is the channel that get_next_item/item_done talk through
    if (get_is_active() == UVM_ACTIVE)
      drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction: connect_phase
endclass: fp_mult_agent
