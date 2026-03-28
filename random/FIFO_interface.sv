interface FIFO_if #(parameter WIDTH = 64) (input logic clk);
  logic [WIDTH-1:0] wdata, rdata;
  logic push, pop, full, empty;

  modport dut(
    input wdata, push, pop,
    output rdata, full, empty
  );
  modport tb(
    output wdata, push, pop,
    input rdata, full, empty
  );
endinterface : FIFO
