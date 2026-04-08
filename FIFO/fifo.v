module fifo #(parameter WIDTH = 8,
              parameter DEPTH = 8) (
    input logic                 clk,
    input logic                 rst_n,
    input logic                 wr_en,
    input logic[WIDTH-1:0]      data_in,
    input logic                 rd_en,
    output logic[WIDTH-1:0]     data_out,
    output logic                full,
    output logic                empty
);
    logic [WIDTH-1:0] mem [DEPTH-1:0];

    localparam PTR_W = $clog2(DEPTH);
    localparam EXT_W = PTR_W + 1;

    logic [EXT_W-1:0] rd_ptr, wr_ptr;

    logic do_read, do_write;

    always_comb begin
        full = (rd_ptr == {~wr_ptr[EXT_W-1], wr_ptr[PTR_W-1:0]});
        empty = (rd_ptr == wr_ptr);

        do_read = rd_en && ~empty;
        do_write = wr_en && ~full;
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            data_out <= 0;
            rd_ptr <= 0;
            wr_ptr <= 0;
        end else begin
            if (do_read) begin
                data_out <= mem[rd_ptr[PTR_W-1:0]];
                rd_ptr <= rd_ptr + 1'b1;
            end
            if (do_write) begin
                mem[wr_ptr[PTR_W-1:0]] <= data_in;
                wr_ptr <= wr_ptr + 1'b1;
            end
        end
    end
endmodule