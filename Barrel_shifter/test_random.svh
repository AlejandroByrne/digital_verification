// ============================================================================
// test_random — runs constrained-random stimulus
//
// Selects: bshift_rand_seq
// Use when: you want broad random exploration. Each run uses a different
//           seed, so repeated runs explore different parts of the input space.
//
// Run via: +UVM_TESTNAME=test_random
//
// To change transaction count without editing this file, set num_txns on
// the sequence object before starting it (see run_phase below).
// ============================================================================
class test_random extends my_base_test;
  `uvm_component_utils(test_random)

  // How many random transactions to run. Tests at a higher level (e.g. a
  // nightly regression) can extend this class and override the value,
  // or it can simply be changed here before tapeout.
  int unsigned num_txns = 1000;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new

  task run_phase(uvm_phase phase);
    bshift_rand_seq seq;

    phase.raise_objection(this);

    seq = bshift_rand_seq::type_id::create("seq");
    // Pass the iteration count to the sequence before starting it.
    // The sequence is an object (not a component), so we have a direct
    // handle to it here — no config_db needed.
    seq.num_txns = num_txns;
    seq.start(my_env_h.my_agent_h.my_sequencer_h);

    phase.drop_objection(this);
  endtask: run_phase

endclass: test_random
