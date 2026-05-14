`include "uvm_macros.svh"
import uvm_pkg::*;   // 🔥 REQUIRED

class my_monitor extends uvm_component;
    `uvm_component_utils(my_monitor)

    virtual my_if vif;
    uvm_analysis_port #(my_txn) ap;
    uvm_tlm_analysis_fifo #(my_txn) act_fifo;  // new blocking FIFO

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

    int drop_once = 1;
    int seen_count;

    // ---- Bug 3 ----
    int act_dup_count = 0;
    int DUP_N = 2;   // duplicate the 2nd ACT (you can change later)

    function new(string name="my_monitor", uvm_component parent=null);
        super.new(name, parent);
        ap = new("ap", this);
        // data_cg = new();  
        accept_d = 0;
        act_fifo = new("act_fifo", this);
        seen_count = 0;
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Virtual interface not found in Monitor");
    endfunction

/*
    function void write(my_txn t);
        my_txn act = my_txn::type_id::create("act");

        act.copy(t);
        
        `uvm_info("MON",
        $sformatf("Observed Data (ACCEPT EDGE) = %0d", act.data),
        UVM_LOW)

        ap.write(act);             // push to TLM FIFO

    endfunction

    */

    task run_phase(uvm_phase phase);

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
                        // -----< BUG-1: Missing ACT transaction >-----
                        // seen_count++;
                        // if (drop_once && seen_count == 3) begin
                        //     `uvm_info("MON", "INTENTIONAL DROP of ACT txn", UVM_LOW)
                        //     continue;   // 🚨 ACT missing
                        // end

                        tm = my_txn::type_id::create("tm", this);
                        tm.data = vif.data;
                        `uvm_info("MON",
                            $sformatf("Observed Data (ACCEPT EDGE) = %0d", tm.data),
                            UVM_MEDIUM)
                        `uvm_info("MON_ALIGN",
                            $sformatf("ACCEPT @ %0t data=%0d", $time, tm.data),
                            UVM_LOW)

                        ap.write(tm);
                        act_fifo.put(tm);

                        // ----<Bug 3: Extra Act transaction>----
                        // act_dup_count++;
                        // if (act_dup_count == DUP_N) begin
                        //     `uvm_warning("MON",
                        //         "INTENTIONAL DUPLICATE ACT txn")
                        //     act_fifo.put(tm);   // EXTRA ACT injected
                        // end

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