`include "uvm_macros.svh"
import uvm_pkg::*;   // 🔥 REQUIRED

class my_scoreboard extends uvm_component;
    `uvm_component_utils(my_scoreboard);

    uvm_tlm_analysis_fifo #(my_txn) fifo;
    uvm_analysis_port #(my_txn) ap_accepted;
    int expected_count, actual_count;
    // bit done = 0;
    // uvm_event done_ev;

    function new(string name="my_scoreboard",uvm_component parent);
        super.new(name, parent);
        // imp = new("imp", this);
        // done_ev = new("done_ev");    
        // fifo = new("fifo", this);
        actual_count = 0;
        ap_accepted = new("ap_accepted", this);
    endfunction //new()

    // function void write(my_txn ts);
    //     `uvm_info("SCB", 
    //         $sformatf("Checking data = %0d", ts.data),
    //         UVM_MEDIUM)
        
    //     // Simple pass-through check
    //     // (Future: compare with expected queue)
    //     if (ts.data inside {[0:255]}) begin
    //         `uvm_info("SCB", "Pass", UVM_LOW)
    //     end else begin
    //         `uvm_error("SCB", "Fail: Data out of range")
    //     end

    // endfunction

    function void build_phase(uvm_phase phase);
        fifo = new("fifo", this);
    endfunction
    
    // function void write_expected();
    //     `uvm_info("SCB","Write expected", UVM_LOW);
    //     expected_count++;
    // endfunction

    // function void write_actual();
    //     `uvm_info("SCB","Write Actual", UVM_LOW);
    //     actual_count++;
    //     if (actual_count == expected_count) begin
    //         done_ev.trigger();
    //     end
    // endfunction

    // 🔑 Called by test / virtual sequence
    function void set_expected_count(int n);
        expected_count = n;
        `uvm_info("SCB", $sformatf("Expected transaction count set to %0d", n), UVM_LOW)
    endfunction

    task run_phase(uvm_phase phase);
        my_txn ts;

        while (actual_count < expected_count) begin
            fifo.get(ts);           // BLOCKING, SAFE

            actual_count++;

            `uvm_info("SCB", 
                $sformatf("Checking data = %0d", ts.data),
                UVM_LOW)

            // compare expected vs actual
            if (ts.data inside {[0:255]}) begin
                ts.accepted = 1;
                `uvm_info("SCB", "Pass", UVM_LOW)
                ap_accepted.write(ts);  
            end else begin
                ts.accepted = 0;
                `uvm_error("SCB", "Fail: Data out of range")
            end

            // // 🔒 ONE-SHOT completion
            // `uvm_info("SCB", $sformatf("Actual Count = %0d Exp = %0d", actual_count, expected_count), UVM_LOW)
            // if (actual_count == expected_count) begin
            //     `uvm_info("SCB", "All expected transaction checked", UVM_LOW)
            //     done_ev.trigger();
            //     `uvm_info("SCB", "Event trigger executed", UVM_LOW)
            // end
            
        end
        `uvm_info("SCB",
                "Scoreboard run_phase completed cleanly",
                UVM_LOW)
    endtask

endclass //my_scoreboard extends uvm_component