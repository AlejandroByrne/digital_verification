`include "sa_pkg.sv"
`include "sa_if.sv"
`include "half_adder.sv"
`include "full_adder.sv"
`include "signed_adder.sv"

module top;
  import uvm_pkg::*;
  import sa_pkg::*;

  // Clock generation
  logic clk;
  initial clk = 1'b0;
  always #1 clk = ~clk;

  // Interface — parameterized to match SA_WIDTH
  sa_if #(.WIDTH(SA_WIDTH)) sa_if_inst (.clk(clk));

  // DUT — parameterized signed adder
  signed_adder #(.WIDTH(SA_WIDTH)) dut (
    .a_in(sa_if_inst.a_in),
    .b_in(sa_if_inst.b_in),
    .result_out(sa_if_inst.result_out),
    .flags(sa_if_inst.flags)
  );

  initial begin
    uvm_config_db #(virtual sa_if #(SA_WIDTH))::set(null, "*", "sa_vi", sa_if_inst);
    run_test("");
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule : top
