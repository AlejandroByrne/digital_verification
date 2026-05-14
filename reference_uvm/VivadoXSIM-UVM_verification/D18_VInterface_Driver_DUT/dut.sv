module dut(
    input   logic clk,
    input   logic rst,
    input   logic valid,
    input   logic [7:0] data 
);

    always_ff @(posedge clk) begin
        if (rst)
            $display("DUT: Reset");
        else if (valid)
            $display("DUT: Data Received = %0d", data);
    end

endmodule