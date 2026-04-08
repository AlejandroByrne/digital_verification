// ============================================================
//  FIFO — Testbench Top
// ============================================================

`include "fifo_pkg.sv"
`include "fifo_if.sv"

module top;
    import uvm_pkg::*;
    import fifo_pkg::*;

    // ── Parameters ──
    localparam WIDTH = 8;
    localparam DEPTH = 16;

    // ── Clock & Reset ──
    logic clk;
    logic rst_n;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #40 rst_n = 1;
    end

    // ── Interface ──
    fifo_if #(.WIDTH(WIDTH), .DEPTH(DEPTH)) vif (.clk(clk), .rst_n(rst_n));

    // ── DUT ──
    fifo #(.WIDTH(WIDTH), .DEPTH(DEPTH)) dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .wr_en    (vif.wr_en),
        .data_in  (vif.data_in),
        .rd_en    (vif.rd_en),
        .data_out (vif.data_out),
        .full     (vif.full),
        .empty    (vif.is_empty)
    );

    // ── UVM Entry ──
    initial begin
        // Set virtual interface in config_db
        uvm_config_db #(virtual fifo_if #(WIDTH, DEPTH))::set(null, "*", "vif", vif);
        
        // Start Test (specified via +UVM_TESTNAME from bash script)
        run_test(); 
    end

    // ── Waveform Dump ──
    initial begin
        $dumpfile("fifo_dump.vcd");
        $dumpvars(0, top);
    end

endmodule : top
