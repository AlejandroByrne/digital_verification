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

  // random_seq rand_s;
  // dir_bin_seq low_s;

  task run_phase(uvm_phase phase);
    // my_sequence seq; 
    // my_virtual_seq vseq;
    // mvvseq_multi vseq;
    layered_vseq vseq;

    phase.raise_objection(this);

    // rand_s = random_seq::type_id::create("rand_s", this);
    // low_s = dir_bin_seq::type_id::create("low_s", this);

    // rand_s.start(env.seqr);
    // low_s.start(env.seqr);
    // vseq = my_virtual_seq::type_id::create("vseq", this);
    // vseq = mvvseq_multi::type_id::create("vseq", this);
    vseq = layered_vseq::type_id::create("vseq", this);


    vseq.start(env.vseqr);     // 🔥 inject virtual sequencer
    // vseq.start(null);           // 🔥 ALWAYS null

    #100;   // allow monitor/scoreboard to finish

    phase.drop_objection(this); 
  endtask
endclass

/*
Concepts reinforced
    -Test creates env
    -run_phase controls simulation life
    -Objection = simulation control
*/