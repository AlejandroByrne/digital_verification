// ============================================================
//  IEEE 754 Float32 Multiplier — Environment
//
//  Wires: monitor → scoreboard (and later → coverage collector)
// ============================================================

class fp32_env extends uvm_env;
    `uvm_component_utils(fp32_env)

    fp32_agent      agt;
    fp32_scoreboard sb;
    // Coverage collector will be added here

    function new(string name = "fp32_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = fp32_agent::type_id::create("agt", this);
        sb  = fp32_scoreboard::type_id::create("sb", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Monitor broadcasts → scoreboard receives
        agt.mon.ap.connect(sb.analysis_export);
        // Will also connect: agt.mon.ap.connect(cov.analysis_export);
    endfunction : connect_phase

endclass : fp32_env
