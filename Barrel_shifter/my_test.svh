// ============================================================================
// my_test — quick smoke test, single hardcoded transaction
//
// The original test from bringup. Kept as the default run_test() target
// because it runs fast and confirms the full pipeline (driver → DUT →
// monitor → scoreboard) is wired correctly in one transaction.
//
// Run via: +UVM_TESTNAME=my_test  (or leave as the run_test("") default)
// ============================================================================
class my_test extends my_base_test;
  `uvm_component_utils(my_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new

  task run_phase(uvm_phase phase);
    bshift_simple_seq seq;

    phase.raise_objection(this);

    seq = bshift_simple_seq::type_id::create("seq");
    seq.start(my_env_h.my_agent_h.my_sequencer_h);

    phase.drop_objection(this);
  endtask: run_phase

endclass: my_test
