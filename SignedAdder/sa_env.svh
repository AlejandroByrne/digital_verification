class sa_env extends uvm_env;
  `uvm_component_utils(sa_env)

  sa_agent      sa_agent_h;
  sa_coverage   sa_coverage_h;
  sa_scoreboard sa_scoreboard_h;

  function new(string name = "sa_env", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    sa_agent_h      = sa_agent::type_id::create("sa_agent", this);
    sa_coverage_h   = sa_coverage::type_id::create("sa_coverage_h", this);
    sa_scoreboard_h = sa_scoreboard::type_id::create("sa_scoreboard_h", this);
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    sa_agent_h.analysis_port.connect(sa_coverage_h.analysis_export);
    sa_agent_h.analysis_port.connect(sa_scoreboard_h.imp);
  endfunction : connect_phase
endclass : sa_env
