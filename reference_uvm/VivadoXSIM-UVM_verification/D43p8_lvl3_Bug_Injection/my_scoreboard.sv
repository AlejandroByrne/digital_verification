`include "uvm_macros.svh"
import uvm_pkg::*;   // 🔥 REQUIRED

class my_scoreboard extends uvm_component;
    `uvm_component_utils(my_scoreboard);

    // uvm_analysis_port #(my_txn) ap_accepted;
    int expected_count, actual_count;
    // bit done = 0;
    // my_txn act_q[$];

    
    // int drop_once = 1;
    // Step 1    
    uvm_tlm_analysis_fifo #(my_txn) act_fifo;
    // NEW for Step-2
    uvm_tlm_analysis_fifo #(my_txn) exp_fifo;

    // Counter
    int received_count;

    function new(string name="my_scoreboard",uvm_component parent);
        super.new(name, parent);
        // imp = new("imp", this);
        // done_ev = new("done_ev");    
        // fifo = new("fifo", this);
        actual_count = 0;
        exp_fifo = new("exp_fifo", this);
        act_fifo = new("act_fifo", this);
    endfunction //new()

    // 🔑 Called by test / virtual sequence
    function void set_expected_count(int n);
        expected_count = n;
        `uvm_info("SCB", $sformatf("Expected transaction count set to %0d", n), UVM_LOW)
    endfunction


    task run_phase(uvm_phase phase);
        my_txn act, exp;

        int match_count    = 0;
        int mismatch_count = 0;

        `uvm_info("SCB", "Run phase: entered", UVM_LOW)

        phase.raise_objection(this);
        
        repeat (5) begin
        // forever begin
            // 🔒 BLOCKING — Level-3 semantics
            act_fifo.get(act);       // blocks if empty
            exp_fifo.get(exp);       // blocks if empty
            // if (act_fifo.try_get(act)) begin
            //     `uvm_info("SCB", $sformatf("Got txn: %0d", act.data), UVM_LOW);
            // end

            // if (exp_fifo.try_get(exp)) begin
            // `uvm_info("SCB", $sformatf("Exp=%0d", exp.data), UVM_LOW);
            // end
            actual_count++; // Increase count, when txns arrive symmetrically.

            // `uvm_info("SCB",
            //     $sformatf("Actual txn Received: %0d (count=%0d)", act.data, actual_count),
            //     UVM_LOW)

            // `uvm_info("SCB",
            //     $sformatf("Predicted txn received: %0d", exp.data),
            //     UVM_MEDIUM)
            
            // ---- Comparison ----
            // `uvm_info("SCB", "Run phase: Comparision", UVM_LOW)
            if (act.data === exp.data) begin
                match_count++;
                `uvm_info("SCB",
                    $sformatf("MATCH #%0d : act=%0d exp=%0d",
                            actual_count, act.data, exp.data),
                    UVM_LOW)
            end    
            else begin
                mismatch_count++;
                `uvm_error("SCB_MISMATCH",
                    $sformatf("MISMATCH #%0d : act=%0d exp=%0d",
                            actual_count, act.data, exp.data))
            end

        end
        `uvm_info("SCB",
                "Scoreboard run_phase completed cleanly",
                UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass //my_scoreboard extends uvm_component