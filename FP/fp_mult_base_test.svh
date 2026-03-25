class fp_mult_base_test extends uvm_test;
  `uvm_component_utils(fp_mult_base_test)

  fp_mult_env env;

  function new(string name="fp_mult_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = fp_mult_env::type_id::create("env", this);
  endfunction: build_phase
endclass: fp_mult_base_test

// Smoke test — runs one hardcoded multiply through the real UVM machinery
class fp_mult_smoke_test extends fp_mult_base_test;
  `uvm_component_utils(fp_mult_smoke_test)

  function new(string name="fp_mult_smoke_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  task run_phase(uvm_phase phase);
    fp_mult_smoke_seq smoke;

    // Raise objection: tells UVM "don't end the test yet, I'm still working"
    phase.raise_objection(this);

    smoke = fp_mult_smoke_seq::type_id::create("smoke");
    smoke.start(env.agent.sqr);   // Run the sequence on the agent's sequencer

    // Small drain time to let the last transaction propagate
    #20;

    // Drop objection: "I'm done, UVM can end now"
    phase.drop_objection(this);
  endtask: run_phase
endclass: fp_mult_smoke_test
