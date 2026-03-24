class my_env extends uvm_env;
  `uvm_component_utils(my_env)

  my_agent       my_agent_h;
  my_scoreboard  my_scoreboard_h;
  bshift_coverage my_coverage_h;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    my_agent_h      = my_agent::type_id::create("my_agent_h",       this);
    my_scoreboard_h = my_scoreboard::type_id::create("my_scoreboard_h",  this);
    my_coverage_h   = bshift_coverage::type_id::create("my_coverage_h",  this);
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    // The agent's analysis port is a broadcast — connecting multiple
    // subscribers here is perfectly legal. Every transaction the monitor
    // captures will be delivered to BOTH write() functions independently.
    my_agent_h.ap.connect(my_scoreboard_h.analysis_export);
    my_agent_h.ap.connect(my_coverage_h.analysis_export);
  endfunction: connect_phase

endclass: my_env
