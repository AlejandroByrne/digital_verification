// ============================================================
//  Half Adder — Base Test
//
//  Builds the environment. Derived tests add sequences.
//  Use +UVM_TESTNAME=<test_class> to select which test to run.
// ============================================================

class ha_base_test extends uvm_test;
    `uvm_component_utils(ha_base_test)

    ha_env env;

    function new(string name = "ha_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = ha_env::type_id::create("env", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("TEST", "Base test: no sequences. Create a derived test.", UVM_LOW)
        #100;
        phase.drop_objection(this);
    endtask : run_phase

endclass : ha_base_test
