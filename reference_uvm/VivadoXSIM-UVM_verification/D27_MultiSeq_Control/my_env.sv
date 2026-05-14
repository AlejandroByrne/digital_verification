`include "uvm_macros.svh"           // Include UVM Macros
import uvm_pkg::*;                  // Import UVM Package (Concept: types & base classes)

class my_env extends uvm_env;
    `uvm_component_utils(my_env)
    
    my_driver drv;
    my_sequencer seqr;
    my_monitor mon;
    my_scoreboard scb;

    virtual_sequencer vseqr;

    function new(string name="my_env", uvm_component parent=null);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //create components here
        drv  = my_driver        ::type_id::create("drv",  this);
        seqr = my_sequencer     ::type_id::create("seqr", this);
        mon  = my_monitor       ::type_id::create("mon", this);
        scb  = my_scoreboard    ::type_id::create("scb", this);

        vseqr = virtual_sequencer::type_id::create("vseqr", this);  
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        drv.seq_item_port.connect(seqr.seq_item_export);
        mon.ap.connect(scb.imp);
        vseqr.seqr = seqr;      // 🔥 KEY CONNECTION 
    endfunction
endclass //my_env extends uvm_env

/*
Concepts reinforced
-uvm_env is structural
-build_phase prepares hierarchy

*/