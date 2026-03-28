`include "fa_pkg.sv"
`include "fa_if.sv"
`include "half_adder.sv"

module top;
  import uvm_pkg::*;
  import fa_pkg::*;

  // Clock generation
  logic clk;
  initial clk = 1'b0;
  always #1 clk = ~clk;

  // Interface
  fa_if fa_if (.clk(clk));

  full_adder dut (
    .a_in(fa_if.a_in),
    .b_in(fa_if.b_in),
    .carry_in(fa_if.carry_in),
    .result_out(fa_if.result_out),
    .carry_out(fa_if.carry_out)
  );

  initial begin
    uvm_config_db #(virtual fa_if)::set(null, "*", "fa_vi", fa_if);
    run_test("");
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule : top
