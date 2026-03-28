`include "ha_pkg.sv"
`include "fa_pkg.sv"
`include "sa_pkg.sv"
`include "ha_if.sv"
`include "fa_if.sv"
`include "sa_if.sv"
`include "half_adder.sv"
`include "full_adder.sv"
`include "signed_adder.sv"

module top;
  import uvm_pkg::*;
  import ha_pkg::*;
  import fa_pkg::*;
  import sa_pkg::*;

  // Clock generation
  logic clk;
  initial clk = 1'b0;
  always #1 clk = ~clk;

  // ── Top-level interface ──
  sa_if #(.WIDTH(SA_WIDTH)) sa_if_inst (.clk(clk));

  // ── DUT ──
  signed_adder #(.WIDTH(SA_WIDTH)) dut (
    .a_in(sa_if_inst.a_in),
    .b_in(sa_if_inst.b_in),
    .result_out(sa_if_inst.result_out),
    .flags(sa_if_inst.flags)
  );

  // ── Spy interface: half adder (dut.ha) ──
  // This reaches INTO the DUT and taps the internal half adder's signals.
  // The passive HA agent's monitor will sample these.
  ha_if ha_spy (.clk(clk));
  assign ha_spy.a_in       = dut.ha.a_in;
  assign ha_spy.b_in       = dut.ha.b_in;
  assign ha_spy.result_out = dut.ha.result_out;
  assign ha_spy.carry_out  = dut.ha.carry_out;

  // ── Spy interfaces: full adder chain (dut.fa_chain[i].fa) ──
  // One spy per generated full adder. The generate index matches the DUT's.
  genvar j;
  generate
    for (j = 1; j < SA_WIDTH; j++) begin : fa_spies
      fa_if fa_spy (.clk(clk));
      assign fa_spy.a_in       = dut.fa_chain[j].fa.a_in;
      assign fa_spy.b_in       = dut.fa_chain[j].fa.b_in;
      assign fa_spy.carry_in   = dut.fa_chain[j].fa.carry_in;
      assign fa_spy.result_out = dut.fa_chain[j].fa.result_out;
      assign fa_spy.carry_out  = dut.fa_chain[j].fa.carry_out;
    end
  endgenerate

  // ── Register all interfaces in config_db ──
  initial begin
    // Top-level SA interface
    uvm_config_db #(virtual sa_if #(SA_WIDTH))::set(null, "*", "sa_vi", sa_if_inst);

    // HA spy — the passive HA agent's monitor looks up "ha_vi"
    uvm_config_db #(virtual ha_if)::set(null, "*ha_agent*", "ha_vi", ha_spy);

    // FA spies — each passive FA agent gets its own interface.
    // The path "*fa_agent_1*" targets the agent named "fa_agent_1" in the env,
    // so only that agent's monitor picks up this specific spy.
    for (int j = 1; j < SA_WIDTH; j++) begin
      uvm_config_db #(virtual fa_if)::set(
        null,
        $sformatf("*fa_agent_%0d*", j),
        "fa_vi",
        fa_spies[j].fa_spy
      );
    end

    run_test("");
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule : top
