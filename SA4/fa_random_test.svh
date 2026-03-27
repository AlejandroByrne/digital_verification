class fa_random_test extends uvm_test;
  `uvm_component_utils(fa_random_test)

  fa_env fa_env_h;

  function new(string name = "fa_random_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    fa_env_h = fa_env::type_id::create("fa_env", this);
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    fa_random_sequence fa_seq;
    phase.raise_objection(this);
    fa_seq = fa_random_sequence::type_id::create("rand_seq");
    fa_seq.start(fa_env_h.fa_agent_h.fa_sequencer_h);
    phase.drop_objection(this);
  endtask : run_phase
endclass : fa_random_test
