class fp_mult_env extends uvm_env;
  `uvm_component_utils(fp_mult_env)

  fp_mult_agent agent;
  // Scoreboard and coverage collector will be added here later

  function new(string name="fp_mult_env", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = fp_mult_agent::type_id::create("agent", this);
  endfunction: build_phase

  // connect_phase will wire monitor → scoreboard/coverage later
endclass: fp_mult_env
