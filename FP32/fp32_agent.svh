// ============================================================
//  IEEE 754 Float32 Multiplier — Agent
//
//  Active mode: driver + sequencer + monitor
//  Passive mode: monitor only (for observation without driving)
// ============================================================

class fp32_agent extends uvm_agent;
    `uvm_component_utils(fp32_agent)

    fp32_driver    drv;
    fp32_sequencer sqr;
    fp32_monitor   mon;

    function new(string name = "fp32_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Monitor always exists — even passive agents observe
        mon = fp32_monitor::type_id::create("mon", this);

        // Driver + sequencer only in active mode
        if (get_is_active() == UVM_ACTIVE) begin
            drv = fp32_driver::type_id::create("drv", this);
            sqr = fp32_sequencer::type_id::create("sqr", this);
        end
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (get_is_active() == UVM_ACTIVE)
            drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction : connect_phase

endclass : fp32_agent
