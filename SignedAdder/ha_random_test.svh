class ha_random_test extends ha_base_test;
  `uvm_component_utils(ha_random_test)

  function new(string name = "ha_random_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  task run_phase (uvm_phase phase);
    ha_random_seq seq;
    phase.raise_objection(this);
      seq = ha_random_seq::type_id::create("rand_seq");
      seq.start(env.agt.sqr);
    phase.drop_objection(this);
  endtask : run_phase

endclass : ha_random_test
