// ============================================================
//  Half Adder — Environment
//
//  Currently just the agent. Scoreboard + coverage added later.
// ============================================================

class ha_env extends uvm_env;
    `uvm_component_utils(ha_env)

    ha_agent agt;
    // ha_scoreboard sb;   — will be added when we walk through it
    // ha_coverage   cov;  — will be added when we walk through it

    function new(string name = "ha_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = ha_agent::type_id::create("agt", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Will connect: agt.mon.ap → sb.analysis_export
        // Will connect: agt.mon.ap → cov.analysis_export
    endfunction : connect_phase

endclass : ha_env
