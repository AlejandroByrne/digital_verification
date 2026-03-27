// ============================================================
//  Half Adder — Environment
//
//  Agent owns: driver, sequencer, monitor, coverage
//  Env owns:   agent, scoreboard
//
//  Scoreboard lives here (not in agent) so the SA4 top-level
//  env can have one scoreboard across multiple sub-agents.
// ============================================================

class ha_env extends uvm_env;
    `uvm_component_utils(ha_env)

    ha_agent      agt;
    ha_scoreboard sb;

    function new(string name = "ha_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = ha_agent::type_id::create("agt", this);
        sb  = ha_scoreboard::type_id::create("sb", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Monitor broadcasts to scoreboard
        agt.mon.ap.connect(sb.imp);
    endfunction : connect_phase

endclass : ha_env
