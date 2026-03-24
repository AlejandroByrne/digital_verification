class test_full extends my_base_test;
  `uvm_component_utils(test_full)

  function new(string name, uvm_component parent)
    super.new(name, parent);
  endfunction: new

  task run_phase(uvm_phase phase);
    bshift_directed_edge_seq  directed_edge_seq;
    bshift_rand_seq           rand_seq;

    phase.raise_objection(this);
      // Directed first -- guarantees critical cases always run
      directed_edge_seq = bshift_directed_edge_seq::type_id::create("directed_seq");
      directed_seq.start(my_env_h.my_agent_h.my_sequencer_h);
      // Random second -- fills in the combinatorial gaps
      rand_seq = bshift_rand_seq::type_id::create("rand_seq");
      rand_seq.start(my_env_h.my_agent_h.my_sequencer_h);
    phase.drop_objection(this);
  endtask: run_phase

endclass: test_full
