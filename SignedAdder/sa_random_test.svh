class sa_random_test extends uvm_test;
  `uvm_component_utils(sa_random_test)

  sa_env sa_env_h;

  function new(string name = "sa_random_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sa_env_h = sa_env::type_id::create("sa_env", this);
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    sa_random_sequence sa_seq;
    phase.raise_objection(this);
    sa_seq = sa_random_sequence::type_id::create("rand_seq");
    sa_seq.start(sa_env_h.sa_agent_h.sa_sequencer_h);
    phase.drop_objection(this);
  endtask : run_phase
endclass : sa_random_test
