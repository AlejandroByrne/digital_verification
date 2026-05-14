`include "uvm_macros.svh"           // Include UVM Macros
import uvm_pkg::*;                  // Import UVM Package (Concept: types & base classes)

class my_env extends uvm_env;
    `uvm_component_utils(my_env)
    
    function new(string name="my_env", uvm_component parent=null);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // component here
    endfunction
endclass //my_env extends uvm_env

/*
Concepts reinforced
-uvm_env is structural
-build_phase prepares hierarchy

*/