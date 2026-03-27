// ============================================================
//  Half Adder — Agent
//
//  Active mode:  driver + sequencer (+ monitor when added)
//  Passive mode: monitor only (for when SA4 top-level drives)
// ============================================================

class ha_agent extends uvm_agent;
    `uvm_component_utils(ha_agent)

    ha_driver    drv;
    ha_sequencer sqr;
    // ha_monitor mon;  — will be added when we walk through it

    function new(string name = "ha_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Monitor always exists — even passive agents observe
        // mon = ha_monitor::type_id::create("mon", this);

        // Driver + sequencer only in active mode
        if (get_is_active() == UVM_ACTIVE) begin
            drv = ha_driver::type_id::create("drv", this);
            sqr = ha_sequencer::type_id::create("sqr", this);
        end
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (get_is_active() == UVM_ACTIVE)
            drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction : connect_phase

endclass : ha_agent
