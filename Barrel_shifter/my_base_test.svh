// ============================================================================
// my_base_test — base class for all barrel-shifter tests
//
// Responsibility: build the environment and wire the virtual interface into
// the config object. Nothing else. Derived tests own run_phase entirely.
//
// Why a base test at all?
//   Every test needs identical build_phase logic. Putting it here means a
//   new test is just a class with a run_phase — no boilerplate to repeat.
//   If the env structure ever changes (e.g. a second agent added), only this
//   file needs updating, not every test.
// ============================================================================
class my_base_test extends uvm_test;
  `uvm_component_utils(my_base_test)

  my_env        my_env_h;
  my_dut_config dut_config_0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    // Build the environment — this creates the full agent/driver/monitor/
    // scoreboard tree underneath it.
    my_env_h = my_env::type_id::create("my_env_h", this);

    // Create the config object and fetch the virtual interface that the
    // top module deposited in the config_db before run_test() was called.
    dut_config_0 = new();
    if (!uvm_config_db #(virtual dut_if)::get(this, "", "dut_vi", dut_config_0.dut_vi))
      `uvm_fatal("MY_BASE_TEST", "No virtual interface found in config_db");

    // Broadcast the config object to every component in the hierarchy.
    // The driver and monitor both do a get() for "dut_config" in their
    // own build_phase to retrieve the virtual interface.
    uvm_config_db #(my_dut_config)::set(this, "*", "dut_config", dut_config_0);
  endfunction: build_phase

  // run_phase is intentionally empty. Running the base test directly
  // produces a valid (if uninteresting) simulation — the env builds, time
  // advances, and the test exits immediately. Derived tests override this.
  task run_phase(uvm_phase phase);
  endtask: run_phase

endclass: my_base_test
