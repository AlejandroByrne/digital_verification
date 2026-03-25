`include "fp_pkg.sv"
`include "fp_mult_if.sv"

module top;
  import uvm_pkg::*;
  import fp_pkg::*;

  logic clk;
  initial clk = 0;
  always #5 clk = ~clk;

  fp_mult_if dut_if(clk);

  fp_mult_rtl #(.P(P), .Q(E)) dut (
    .rst_in_N(dut_if.rst_in_N),
    .clk_in(clk),
    .x_in(dut_if.x_in),
    .y_in(dut_if.y_in),
    .round_in(dut_if.round_in),
    .start_in(dut_if.start_in),
    .p_out(dut_if.p_out),
    .oor_out(dut_if.oor_out),
    .done_out(dut_if.done_out)
  );

  // Provide the config for when UVM starts the build phase
  initial begin
    uvm_config_db #(virtual fp_mult_if)::set(null, "*", "fp_mult_vi", dut_if);

    // Pass "" so the test name comes from +UVM_TESTNAME= in sim options.
    run_test("");
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule: top
