// ============================================================
//  FIFO — Environment (Non-parameterized)
// ============================================================

class fifo_env extends uvm_env;
    `uvm_component_utils(fifo_env)

    fifo_agent      agt;
    fifo_scoreboard sb;
    fifo_coverage   cvg;

    function new(string name = "fifo_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = fifo_agent::type_id::create("agt", this);
        sb  = fifo_scoreboard::type_id::create("sb", this);
        cvg = fifo_coverage::type_id::create("cvg", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.ap.connect(sb.analysis_export);
        agt.ap.connect(cvg.analysis_export);
    endfunction : connect_phase
endclass
