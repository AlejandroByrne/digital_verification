// ============================================================
//  IEEE 754 Float32 Multiplier — Driver
//
//  Protocol:
//    Cycle N:   Drive a_in, b_in, rnd_mode. Assert valid_in.
//    Cycle N+1: DUT registers inputs. Deassert valid_in.
//    Cycle N+2: valid_out = 1 (registered). Outputs sampled.
// ============================================================

class fp32_driver extends uvm_driver #(fp32_txn);
    `uvm_component_utils(fp32_driver)

    virtual fp32_if vif;

    function new(string name = "fp32_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual fp32_if)::get(this, "", "fp32_vi", vif))
            `uvm_fatal("DRV", "No virtual interface in config_db")
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        // Idle state
        vif.valid_in = 1'b0;
        vif.a_in     = 32'h0;
        vif.b_in     = 32'h0;
        vif.rnd_mode = 2'b00;

        forever begin
            seq_item_port.get_next_item(req);

            // Drive inputs on the next clock edge
            @(posedge vif.clk);
            vif.a_in     = req.a_in;
            vif.b_in     = req.b_in;
            vif.rnd_mode = req.rnd_mode;
            vif.valid_in = 1'b1;

            // Deassert after one cycle pulse
            @(posedge vif.clk);
            vif.valid_in = 1'b0;

            // Wait for valid_out (registered — appears one cycle after valid_in)
            @(posedge vif.clk iff vif.valid_out);

            seq_item_port.item_done();
        end
    endtask : run_phase

endclass : fp32_driver
