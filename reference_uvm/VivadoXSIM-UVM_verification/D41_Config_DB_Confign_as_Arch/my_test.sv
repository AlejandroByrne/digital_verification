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
    
    // uvm_config_db#(test_mode_e)::set(
    //   null, "uvm_test_top.env.vseqr", "mode", SANITY);
    uvm_config_db#(bit)::set(
      null, "uvm_test_top.env.*", "drive_delay", 1);  
    `uvm_info("TEST", "Mode set in Config DB", UVM_NONE)

    // ✅ Day-34 factory usage
    // factory = uvm_factory::get();
    // // // Type Override
    // factory.set_type_override_by_type(
    //   sanity_traffic_seq::get_type(), 
    //   error_traffic_seq::get_type());

    // `uvm_info("FACTORY", "SANITY replaced with ERROR traffic", UVM_LOW)
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
    // vseq.mode = STRESS;

    // env.scb.write_actual;
    // env.scb.write_expected;

    env.scb.set_expected_count(total_txns);

    vseq.start(env.vseqr);     // 🔥 inject virtual sequencer
    // vseq.start(null);           // 🔥 ALWAYS null
    // #100;   // allow monitor/scoreboard to finish ❌ Delays are wrong
   
    // vseq.wait_for_sequence_state(UVM_FINISHED);

    // 🔑 Knowledge-based wait
    // `uvm_info("TEST", "Waiting Scoreboard to complete", UVM_LOW)
    // env.scb.done_ev.wait_trigger();
    
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