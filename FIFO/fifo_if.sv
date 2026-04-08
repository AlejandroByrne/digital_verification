interface fifo_if #(parameter WIDTH = 8, parameter DEPTH = 8)
                (input logic clk,
                 input logic rst_n);
    
    // Signals
    logic              wr_en;
    logic [WIDTH-1:0]  data_in;
    logic              rd_en;

    logic [WIDTH-1:0]  data_out;
    logic              is_empty;
    logic              full;

    // ── SystemVerilog Assertions (SVA) ──

    // 1. Overflow: Cannot write when full
    a_no_overflow: assert property (
        @(posedge clk) disable iff (!rst_n)
        (wr_en && full) |-> ##0 !dut.do_write
    ) else $error("SVA: Attempted write while FIFO full!");

    // 2. Underflow: Cannot read when empty
    a_no_underflow: assert property (
        @(posedge clk) disable iff (!rst_n)
        (rd_en && is_empty) |-> ##0 !dut.do_read
    ) else $error("SVA: Attempted read while FIFO empty!");

    // 3. Flag Sanity: Cannot be full and empty at the same time
    a_full_empty_sanity: assert property (
        @(posedge clk) disable iff (!rst_n)
        !(full && is_empty)
    ) else $error("SVA: FIFO reported BOTH full and empty!");

endinterface : fifo_if
