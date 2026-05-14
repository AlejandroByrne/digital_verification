`include "uvm_macros.svh"
import uvm_pkg::*;

class my_test_factory extends my_test;
  `uvm_component_utils(my_test_factory)

  function new(string name="my_test_factory", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("TEST_ID", "BUILD: my_test_factory", UVM_NONE)
        // 🔥 Global replacement
    // uvm_factory::get().set_type_override_by_type(
    //   my_driver::get_type(),
    //   my_faulty_driver::get_type()
    // );
    // `uvm_info("FACTORY_TEST", "Driver overrided", UVM_LOW)

    uvm_config_db#(bit)::set(null, "uvm_test_top.env.drv", "fault_enable", 0);
  endfunction

  task run_phase(uvm_phase phase);
    `uvm_info("TEST_ID", "RUN: my_test_factory", UVM_NONE)
    super.run_phase(phase);
  endtask
endclass
