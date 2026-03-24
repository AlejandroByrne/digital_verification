// ============================================================================
// test_directed — runs all hardcoded edge-case transactions
//
// Selects: bshift_directed_edge_seq
// Use when: you want a deterministic, fast check of all known boundary
//           conditions. Every run produces identical stimulus.
//
// Run via: +UVM_TESTNAME=test_directed
// ============================================================================
class test_directed extends my_base_test;
  `uvm_component_utils(test_directed)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new

  task run_phase(uvm_phase phase);
    bshift_directed_edge_seq seq;

    phase.raise_objection(this);

    seq = bshift_directed_edge_seq::type_id::create("seq");
    seq.start(my_env_h.my_agent_h.my_sequencer_h);

    phase.drop_objection(this);
  endtask: run_phase

endclass: test_directed
