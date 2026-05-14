module dut(
    input   logic clk,
    input   logic rst,
    input   logic valid,
    input   logic [7:0] data,
    output  logic ready
);

    always_ff @(posedge clk) begin
        if (rst) begin
            ready <= 0;
            $display("[DUT] Reset");
        end
        else begin
            ready <= valid;         // simple handshake

            if (valid)
                $display("[DUT] Data Received = %0d", data);
        end 
    end

endmodule   