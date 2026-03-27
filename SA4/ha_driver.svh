// ============================================================
//  Half Adder — Driver
//
//  Combinational DUT protocol:
//    Drive a_in, b_in on posedge clk.
//    Wait one cycle for outputs to settle and be sampled.
// ============================================================

class ha_driver extends uvm_driver #(ha_txn);
    `uvm_component_utils(ha_driver)

    virtual ha_if vif;

    function new(string name = "ha_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual ha_if)::get(this, "", "ha_vi", vif))
            `uvm_fatal("DRV", "No virtual interface in config_db")
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        // Idle state
        vif.a_in = 1'b0;
        vif.b_in = 1'b0;

        forever begin
            seq_item_port.get_next_item(req);

            @(posedge vif.clk);
            vif.a_in = req.a_in;
            vif.b_in = req.b_in;

            // One cycle for combinational outputs to settle and monitor to sample
            @(posedge vif.clk);

            seq_item_port.item_done();
        end
    endtask : run_phase

endclass : ha_driver
