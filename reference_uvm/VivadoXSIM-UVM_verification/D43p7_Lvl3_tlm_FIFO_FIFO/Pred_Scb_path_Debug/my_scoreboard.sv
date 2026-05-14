`include "uvm_macros.svh"
import uvm_pkg::*;   // 🔥 REQUIRED

class my_scoreboard extends uvm_component;
    `uvm_component_utils(my_scoreboard)

    int expected_count, actual_count;
    
    uvm_tlm_analysis_fifo #(my_txn) exp_fifo;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        exp_fifo = new("exp_fifo", this);
    endfunction

// 🔑 Called by test / virtual sequence
    function void set_expected_count(int n);
        expected_count = n;
        `uvm_info("SCB", $sformatf("Expected transaction count set to %0d", n), UVM_LOW)
    endfunction
    
    task run_phase(uvm_phase phase);
        my_txn exp;

        phase.raise_objection(this);
        repeat (7) begin
        exp_fifo.get(exp);
        `uvm_info("SCB",
            $sformatf("Predicted txn received: %0d", exp.data),
            UVM_LOW)
        end
        phase.drop_objection(this);
    endtask
endclass
