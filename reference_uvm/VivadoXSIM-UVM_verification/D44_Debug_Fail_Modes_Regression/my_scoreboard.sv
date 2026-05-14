`include "uvm_macros.svh"
import uvm_pkg::*;   // 🔥 REQUIRED
`uvm_analysis_imp_decl(_exp)
`uvm_analysis_imp_decl(_act)

class my_scoreboard extends uvm_component;
    `uvm_component_utils(my_scoreboard);

    uvm_tlm_analysis_fifo #(my_txn) fifo;
    uvm_analysis_port #(my_txn) ap_accepted;
    int expected_count, actual_count;
    // uvm_analysis_imp #(my_txn, my_scoreboard) act_ap; 
    // uvm_analysis_imp #(my_txn, my_scoreboard) exp_ap; 
    uvm_analysis_imp_exp #(my_txn, my_scoreboard) exp_ap;
    uvm_analysis_imp_act #(my_txn, my_scoreboard) act_ap;

    // Expected transactions
    my_txn exp_q[$];
    // Actual transactions
    my_txn act_q[$]; 

    // bit done = 0;
    // uvm_event done_ev;

    function new(string name="my_scoreboard",uvm_component parent);
        super.new(name, parent);
        // imp = new("imp", this);
        // done_ev = new("done_ev");    
        // fifo = new("fifo", this);
        actual_count = 0;
        ap_accepted = new("ap_accepted", this);
        act_ap = new("act_ap", this);
    endfunction //new()

    function void write_exp(my_txn t);
        exp_q.push_back(t);
        `uvm_info("SCB", $sformatf("Expected enqueued: %0d", t.data), UVM_LOW)
    endfunction

    function void write_act(my_txn t);
        act_q.push_back(t);
        `uvm_info("SCB", $sformatf("Actual enqueued: %0d", t.data), UVM_LOW)
    endfunction

    function void build_phase(uvm_phase phase);
        fifo = new("fifo", this);
    endfunction


    // 🔑 Called by test / virtual sequence
    function void set_expected_count(int n);
        expected_count = n;
        `uvm_info("SCB", $sformatf("Expected transaction count set to %0d", n), UVM_LOW)
    endfunction

    task run_phase(uvm_phase phase);
        my_txn exp, act;

        `uvm_info("SCB", "Run phase starting", UVM_LOW)
        // 🔑 Give stimulus time to execute
        // wait (phase.get_state() == UVM_PHASE_STARTED);
        // #1ns;

        wait (exp_q.size() > 0 || act_q.size() > 0);

        if (exp_q.size() == 0 || act_q.size() == 0)
            `uvm_fatal("SCB", "NO transactions observed — TEST INVALID")

        while (actual_count < expected_count) begin
            // fifo.get(act);           // BLOCKING, SAFE

            actual_count++;


            exp = exp_q.pop_front();
            act = act_q.pop_front();

            if (exp.data == act.data)
                `uvm_info("SCB", "PASS", UVM_LOW)
            else
                `uvm_error("SCB", "FAIL")
            
        end
        `uvm_info("SCB",
                "Scoreboard run_phase completed cleanly",
                UVM_LOW)
    endtask

endclass //my_scoreboard extends uvm_component