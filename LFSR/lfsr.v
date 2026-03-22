module lfsr_4bit (
    input  logic       clk,    // System Clock
    input  logic       rst_n,  // Active-low Reset
    output logic [3:0] q       // 4-bit Packed Array output
);

    // Internal signal for the feedback bit
    logic feedback;

    // COMBINATIONAL LOGIC
    // Task: XOR the top two bits (q[3] and q[2]) to create the feedback
    assign feedback = q[3] ^ q[2];

    // SEQUENTIAL LOGIC
    // Task: On the clock edge, either reset or shift the bits
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // LFSRs cannot be reset to 0! Pick a 'seed' value like 4'b0001
            q <= 4'b0001;
        end else begin
            // Shift logic: 
            // We want to move bits [2:0] up to positions [3:1] 
            // and put the 'feedback' bit into position [0].
            q <= { q[2:0], feedback };
        end
    end

endmodule