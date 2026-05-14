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
    uvm_factory factory;

    super.build_phase(phase);
    
    env = my_env::type_id::create("env", this);
    
    uvm_config_db#(test_mode_e)::set(env.vseqr, "", "mode", SANITY);
    `uvm_info("CFG_SET", "Mode set in Config DB", UVM_NONE)

    // ✅ Day-34 factory usage
    factory = uvm_factory::get();
    // // Type Override
    // factory.set_type_override_by_type(
    //   sanity_traffic_seq::get_type(), 
    //   error_traffic_seq::get_type());

    // Instance Override
    factory.set_inst_override_by_type(
      sanity_traffic_seq::get_type(), 
      error_traffic_seq::get_type(),
      "*.san_seq");    

    `uvm_info("FACTORY", "SANITY replaced with ERROR traffic", UVM_LOW)
  endfunction

  // random_seq rand_s;
  // dir_bin_seq low_s;

  task run_phase(uvm_phase phase);

    layered_vseq vseq;

    
    phase.raise_objection(this);

    vseq = layered_vseq::type_id::create("vseq", this);
    // vseq.mode = STRESS;

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