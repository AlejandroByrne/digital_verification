`include "uvm_macros.svh"           // Include UVM Macros
import uvm_pkg::*;                  // Import UVM Package (Concept: types & base classes)

class my_env extends uvm_env;
    `uvm_component_utils(my_env)
    
    my_driver drv;
    my_sequencer seqr;
    my_monitor mon;
    my_scoreboard scb;
    my_coverage cov;
    my_predictor pred;

    virtual_sequencer vseqr;
    
    uvm_tlm_analysis_fifo #(my_txn) mon2scb_fifo;   //Analysis FIFO
    uvm_analysis_port #(my_txn) coverage;

    function new(string name="my_env", uvm_component parent=null);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //create components here
        drv  = my_driver        ::type_id::create("drv", this);
        seqr = my_sequencer     ::type_id::create("seqr", this);
        mon  = my_monitor       ::type_id::create("mon", this);
        scb  = my_scoreboard    ::type_id::create("scb", this);
        cov  = my_coverage      ::type_id::create("cov", this);
        pred = my_predictor     ::type_id::create("pred", this);

        vseqr = virtual_sequencer::type_id::create("vseqr", this);  
        // Setting Arbitration mode - Priority based
        // vseqr.set_arbitration(UVM_SEQ_ARB_WEIGHTED);

        mon2scb_fifo = new("mon2scb_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Driver
        drv.seq_item_port.connect(seqr.seq_item_export);
        vseqr.seqr = seqr;      // 🔥 KEY CONNECTION 

        // mon.ap.connect(mon2scb_fifo.analysis_export);
        // scb.fifo = mon2scb_fifo;
        
        // scb.ap_accepted.connect(cov.analysis_export);
        mon.ap.connect(cov.analysis_export);    //To coverage

        // Step-1: Monitor → Scoreboard (ACTUAL)
        // // mon.ap.connect(scb.act_imp);
        // //  or
        mon.ap.connect(scb.act_fifo.analysis_export);

        
        // Step-2
        // // Predictor INPUT (from sequence/driver side)
        // drv.ap.connect(pred.in_imp);
        // monitor → predictor
        mon.ap.connect(pred.in_imp);

        // Predictor OUTPUT
        pred.ap.connect(scb.exp_fifo.analysis_export);

       
    endfunction
endclass //my_env extends uvm_env

/*
Concepts reinforced
-uvm_env is structural
-build_phase prepares hierarchy

*/