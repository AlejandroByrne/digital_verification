localparam DATA_WIDTH  = 8;
localparam SHIFT_WIDTH = $clog2(DATA_WIDTH);

interface dut_if(input logic clk);
  logic [DATA_WIDTH-1:0]  x_in;
  logic [SHIFT_WIDTH-1:0] s_in;
  logic [2:0]             op_in;
  logic [DATA_WIDTH-1:0]  y_out;
  logic                   zf_out;
  logic                   vf_out;
endinterface: dut_if
