`include "uvm_macros.svh"           // Include UVM Macros
import uvm_pkg::*;                  // Import UVM Package (Concept: types & base classes)
// `uvm_analysis_imp_decl(_exp)
// `uvm_analysis_imp_decl(_act)

class my_env extends uvm_env;
    `uvm_component_utils(my_env)
    
    my_driver drv;
    my_sequencer seqr;
    my_monitor mon;
    my_scoreboard scb;
    my_coverage cov;

    virtual_sequencer vseqr;
    my_predictor pred;

    uvm_tlm_analysis_fifo #(my_txn) mon2scb_fifo;   //Analysis FIFO
    uvm_analysis_port #(my_txn) coverage;

    uvm_analysis_imp_exp #(my_txn, my_scoreboard) exp_ap;
    uvm_analysis_imp_act #(my_txn, my_scoreboard) act_ap;

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

        // `uvm_info("ENV_DBG",
        //     $sformatf(
        //         "mon=%p pred=%p scb=%p cov=%p vseqr=%p",
        //         mon, pred, scb, cov, vseqr
        //     ),
        //     UVM_NONE
        //     )

        drv.seq_item_port.connect(seqr.seq_item_export);


        // drv.ap.connect(pred.in_ap);     // what we SENT
        // mon.ap.connect(pred.in_ap);

        // monitor → scoreboard
        // mon.ap.connect(mon2scb_fifo.analysis_export);
        // scb.fifo = mon2scb_fifo;
        mon.ap.connect(pred.in_ap);
        pred.exp_ap.connect(scb.exp_ap);
        mon.ap.connect(scb.act_ap);
        
        scb.ap_accepted.connect(cov.analysis_export);
        
        vseqr.seqr = seqr;      // 🔥 KEY CONNECTION 
    endfunction
endclass //my_env extends uvm_env

/*
Concepts reinforced
-uvm_env is structural
-build_phase prepares hierarchy

*/