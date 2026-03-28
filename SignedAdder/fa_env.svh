class fa_env extends uvm_env;
  `uvm_component_utils(fa_env)

  fa_agent fa_agent_h;

  function new(string name = "fa_env", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    fa_agent_h = fa_agent::type_id::create("fa_agent", this);
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase
endclass : fa_env
