module d_ff (
    input logic clk,
    input logic rst,
    input logic en,
    input logic d,

    output logic q
);
    always_ff @( posedge clk or posedge rst ) begin
        if (rst)
            q <= 0;
        // else if (en)
        else            // ❌ BUG: en is ignored
            q <= d;
        
    end

endmodule