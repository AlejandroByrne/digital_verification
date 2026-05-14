`include "uvm_macros.svh"
import uvm_pkg::*;

class my_test extends uvm_test;
  `uvm_component_utils(my_test)

  my_env env;

  function new(string name="my_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = my_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    // `uvm_info("TEST", "Day-15: UVM skeleton running", UVM_MEDIUM)
    my_sequence seq;

    phase.raise_objection(this);
    seq = my_sequence::type_id::create("seq", this);
    seq.start(env.seqr);

    phase.drop_objection(this); 
  endtask
endclass

/*
Concepts reinforced
    -Test creates env
    -run_phase controls simulation life
    -Objection = simulation control
*/