`include "uvm_macros.svh"
import uvm_pkg::*;   // 🔥 REQUIRED

class my_monitor extends uvm_component;
    `uvm_component_utils(my_monitor)

    virtual my_if vif;
    uvm_analysis_port #(my_txn) ap;
    
    logic prev_accept;
    logic valid_d;
    logic accept_d;

    // ---------------------
    // Functional Coverage
    // ---------------------
    // bit [7:0] cov_data;
    // bit cov_rst;

    // covergroup data_cg;

    // endgroup

    function new(string name="my_monitor", uvm_component parent=null);
        super.new(name, parent);
        ap = new("ap", this);
        // data_cg = new();  
        accept_d = 0;

    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Virtual interface not found in Monitor");
    endfunction

    task run_phase(uvm_phase phase);
        // my_txn tm;
        /*
        forever begin
            @(posedge vif.clk);begin
                if (vif.rst) begin
                    prev_accept <= 0;
                end
                else begin
                    if (vif.valid && vif.ready && !prev_accept) begin
                        tm = my_txn::type_id::create("tm", this);
                        tm.data = vif.data;
                    
                        ap.write(tm);
                        prev_accept <= 1;
                        
                        $display("Ready? = %0b", vif.ready);
                        `uvm_info("MON", $sformatf("Observed Data = %0d", tm.data), UVM_MEDIUM)
                        #10;
                    end
                    else if (!vif.valid) begin
                        prev_accept <= 0; // ready for next txn
                    end

                end
            end
        end

        */

        my_txn tm;

        forever begin
            @(posedge vif.clk) begin
                if (vif.rst) begin
                    accept_d <= 0;
                end
                else begin
                    logic accept;
                    accept = vif.valid && vif.ready;

                    // Sample ONLY on acceptance edge
                    if (accept && !accept_d) begin
                        tm = my_txn::type_id::create("tm", this);
                        tm.data = vif.data;
                        ap.write(tm);

                        `uvm_info("MON",
                        $sformatf("Observed Data (ACCEPT EDGE) = %0d", tm.data),
                        UVM_MEDIUM)
                    end

                    accept_d <= accept;
                end
            end
        end

        
    endtask
endclass //my_monitor extends uvm_component

/*
data & rst : signals inside the virtual interface
Covergroups do not magically see interface signals

🔑 Interview-Grade Insight

If interviewer asks:
“Why can’t you use vif.data directly in a coverpoint?”

Correct answer:
“Covergroups sample variables, not hierarchical expressions. So we assign the signal to a sampled variable before calling sample().”

*/