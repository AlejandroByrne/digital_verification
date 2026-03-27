// ============================================================
//  IEEE 754 Float32 Multiplier — Base Test
//
//  Builds the environment. Derived tests add sequences.
//  Use +UVM_TESTNAME=<test_class> to select which test to run.
// ============================================================

class fp32_base_test extends uvm_test;
    `uvm_component_utils(fp32_base_test)

    fp32_env env;

    function new(string name = "fp32_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = fp32_env::type_id::create("env", this);
    endfunction : build_phase

    // Base test does nothing — derive tests and add sequences
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("TEST", "Base test: no sequences. Create a derived test.", UVM_LOW)
        #100;
        phase.drop_objection(this);
    endtask : run_phase

endclass : fp32_base_test
