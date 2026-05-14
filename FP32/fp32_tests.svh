// ============================================================
//  FP32 — Consolidated Tests
// ============================================================

// 1. Base Test (no sequence started)
// (Already defined in fp32_base_test.svh)

// 1b. Smoke Test — minimal directed sequence, ~5 vectors
class fp32_smoke_test extends fp32_base_test;
    `uvm_component_utils(fp32_smoke_test)

    function new(string name = "fp32_smoke_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        fp32_smoke_seq seq;
        fp32_agent     my_agt;

        phase.raise_objection(this);
        `uvm_info("SMOKE", "run_phase entered", UVM_NONE)
        if (!$cast(my_agt, env.agt))
            `uvm_fatal("TEST", "Failed to cast env.agt to fp32_agent")

        seq = fp32_smoke_seq::type_id::create("seq");
        `uvm_info("SMOKE", "starting seq", UVM_NONE)
        seq.start(my_agt.sqr);
        `uvm_info("SMOKE", "seq finished", UVM_NONE)

        #100;
        phase.drop_objection(this);
    endtask
endclass

// 2. Pure Random Test
class fp32_random_test extends fp32_base_test;
    `uvm_component_utils(fp32_random_test)
    function new(string name = "fp32_random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass

// 3. Constrained-Random Test (High Class Density)
class fp32_constrained_test extends fp32_base_test;
    `uvm_component_utils(fp32_constrained_test)
    
    function new(string name = "fp32_constrained_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        fp32_constrained_seq seq;
        fp32_agent my_agt;
        
        phase.raise_objection(this);
        
        // Cast base agent to specific agent to get sequencer
        if (!$cast(my_agt, env.agt)) begin
            `uvm_fatal("TEST", "Failed to cast env.agt to fp32_agent")
        end
        
        seq = fp32_constrained_seq::type_id::create("seq");
        seq.start(my_agt.sqr);
        
        #100;
        phase.drop_objection(this);
    endtask
endclass
