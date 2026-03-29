module reg_file (
    input clk,
    input wr_en,
    input [1:0] wr_addr,
    input [7:0] wr_data,
    input [1:0] rd_addr,
    output [7:0] rd_data
);
    // Design deicisions:
    // 1) Should the rd_data only front the correct data if wr_en is low?
    // No, only let the rd_data output valid values when wr_en is low
    // 2) 
    logic [7:0] registers [4];
    // Reads combinational. 4 to 1 mux from the registers to
    assign rd_data = registers[rd_addr];

    always_ff @(posedge clk) begin
        if (wr_en) begin
            registers[wr_addr] <= wr_data;
        end
    end

endmodule : reg_file