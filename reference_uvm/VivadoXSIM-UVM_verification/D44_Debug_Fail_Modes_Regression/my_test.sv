`include "uvm_macros.svh"
import uvm_pkg::*;
import test_mode_pkg::*;

class my_test extends uvm_test;
  `uvm_component_utils(my_test)

  my_env env;

  function new(string name="my_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
   // ✅ ALL declarations first
    // uvm_factory factory;

    super.build_phase(phase);
    `uvm_info("TEST_ID", "BUILD: my_test", UVM_NONE)
    
    env = my_env::type_id::create("env", this);
    
    // uvm_config_db#(test_mode_e)::set(
    //   null, "uvm_test_top.env.vseqr", "mode", SANITY);
    uvm_config_db#(bit)::set(
      null, "uvm_test_top.env.*", "drive_delay", 1);  
    `uvm_info("TEST", "Mode set in Config DB", UVM_NONE)

  endfunction

  // random_seq rand_s;
  // dir_bin_seq low_s;

  task run_phase(uvm_phase phase);

    layered_vseq vseq;

    // Total transactions across all layers
    int total_txns  = 2   // reset layer
                    + 2   // config layer
                    + 5;  // sanity traffic
    
    phase.raise_objection(this);

    vseq = layered_vseq::type_id::create("vseq", this);

    env.scb.set_expected_count(total_txns);
    `uvm_info("TEST_ID", "RUN: my_test", UVM_NONE)

    if (env.vseqr == null)
      `uvm_fatal("TEST", "Virtual sequencer is NULL")

    vseq.start(env.vseqr);

    `uvm_info("TEST", "Scoreboard complete observed", UVM_LOW)

    phase.drop_objection(this); 
    
  endtask
endclass

/*
Concepts reinforced
    -Test creates env
    -run_phase controls simulation life
    -Objection = simulation control
*/