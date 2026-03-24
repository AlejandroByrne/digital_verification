`include "dut_if.sv"
`include "bshift_pkg.sv"

module top;
  import uvm_pkg::*;
  import bshift_pkg::*;

  logic clk;
  initial clk = 0;
  always #5 clk = ~clk;

  dut_if dut_if1 (clk);

  barrelshifter #(.D_SIZE(DATA_WIDTH)) dut1 (
    .x_in  (dut_if1.x_in),
    .s_in  (dut_if1.s_in),
    .op_in (dut_if1.op_in),
    .y_out (dut_if1.y_out),
    .zf_out(dut_if1.zf_out),
    .vf_out(dut_if1.vf_out)
  );

  initial begin
    uvm_config_db #(virtual dut_if)::set(null, "uvm_test_top", "dut_vi", dut_if1);
    // Pass "" so the test name comes from +UVM_TESTNAME= in sim options.
    // In EDA Playground: add +UVM_TESTNAME=test_directed  (or test_random, my_test)
    // to the simulation options box next to the run button.
    run_test("");
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

endmodule: top
