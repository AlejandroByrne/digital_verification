`include "uvm_macros.svh"
import uvm_pkg::*;   // 🔥 REQUIRED

class my_scoreboard extends uvm_component;
    `uvm_component_utils(my_scoreboard);

    uvm_tlm_analysis_fifo #(my_txn) fifo;

    function new(string name="my_scoreboard",uvm_component parent);
        super.new(name, parent);
        // imp = new("imp", this);
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
    task run_phase(uvm_phase phase);
        my_txn ts;

        forever begin
            fifo.get(ts);           // BLOCKING, SAFE

            `uvm_info("SCB", 
                $sformatf("Checking data = %0d", ts.data),
                UVM_LOW)

            // compare expected vs actual
            if (ts.data inside {[0:255]}) begin
                `uvm_info("SCB", "Pass", UVM_LOW)
            end else begin
                `uvm_error("SCB", "Fail: Data out of range")
            end
        end 
    endtask
endclass //my_scoreboard extends uvm_component