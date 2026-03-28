// ============================================================
//  Half Adder — Monitor
//
//  Passive observer: samples DUT inputs and outputs on posedge clk,
//  packs them into an ha_txn, and broadcasts via analysis port.
//
//  The driver drives on posedge clk and waits one cycle.
//  The monitor samples on the *next* posedge (same edge the driver
//  calls item_done), so outputs have settled.
// ============================================================

class ha_monitor extends uvm_monitor;
    `uvm_component_utils(ha_monitor)

    virtual ha_if vif;
    uvm_analysis_port #(ha_txn) ap;

    function new(string name = "ha_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual ha_if)::get(this, "", "ha_vi", vif))
            `uvm_fatal("MON", "No virtual interface in config_db")
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        // Skip the first posedge — driver hasn't driven anything yet
        @(posedge vif.clk);

        forever begin
            ha_txn t = ha_txn::type_id::create("t");

            // Sample after the driver's settling cycle
            @(posedge vif.clk);
            t.a_in       = vif.a_in;
            t.b_in       = vif.b_in;
            t.result_out = vif.result_out;
            t.carry_out  = vif.carry_out;

            ap.write(t);
        end
    endtask : run_phase

endclass : ha_monitor
