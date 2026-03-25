class fp_mult_env extends uvm_env;
  `uvm_component_utils(fp_mult_env)

  fp_mult_agent      agent;
  fp_mult_scoreboard sb;
  // Coverage collector will be added here later

  function new(string name="fp_mult_env", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = fp_mult_agent::type_id::create("agent", this);
    sb    = fp_mult_scoreboard::type_id::create("sb", this);
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Wire: monitor's analysis_port → scoreboard's analysis_export
    // Every transaction the monitor captures gets sent to the scoreboard
    agent.mon.analysis_port.connect(sb.analysis_export);
  endfunction: connect_phase
endclass: fp_mult_env
