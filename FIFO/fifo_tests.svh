// ============================================================
//  FIFO — Consolidated Tests (Non-parameterized)
// ============================================================

class fifo_rand_test extends fifo_base_test;
    `uvm_component_utils(fifo_rand_test)
    function new(string name = "fifo_rand_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    task run_phase(uvm_phase phase);
        fifo_rand_seq seq;
        phase.raise_objection(this);
        seq = fifo_rand_seq::type_id::create("seq");
        seq.start(env.agt.seqr);
        #100;
        phase.drop_objection(this);
    endtask
endclass

class fifo_full_empty_test extends fifo_base_test;
    `uvm_component_utils(fifo_full_empty_test)
    function new(string name = "fifo_full_empty_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    task run_phase(uvm_phase phase);
        fifo_full_empty_seq seq;
        phase.raise_objection(this);
        seq = fifo_full_empty_seq::type_id::create("seq");
        seq.start(env.agt.seqr);
        #100;
        phase.drop_objection(this);
    endtask
endclass

class fifo_error_test extends fifo_base_test;
    `uvm_component_utils(fifo_error_test)
    function new(string name = "fifo_error_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    task run_phase(uvm_phase phase);
        fifo_error_seq seq;
        phase.raise_objection(this);
        seq = fifo_error_seq::type_id::create("seq");
        seq.start(env.agt.seqr);
        #100;
        phase.drop_objection(this);
    endtask
endclass
