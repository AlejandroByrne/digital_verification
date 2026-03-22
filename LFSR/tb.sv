`timescale 1ns/1ps  // Defines the unit of time (1ns) and precision (1ps)

module tb_lfsr();

    // 1. Signals to connect to our Module Under Test (MUT)
    logic       clk;
    logic       rst_n;
    logic [3:0] q;

    logic [3:0] lfsr_lut [16] = '{
        0: 4'b0000,
        1: 4'b0010,
        2: 4'b0100,
        3: 4'b0110,
        4: 4'b1001,
        5: 4'b1011,
        6: 4'b0110,
        7: 4'b0111,
        8: 4'b0001,
        9: 4'b0011,
        10: 4'b0101,
        11: 4'b0111,
        12: 4'b1000,
        13: 4'b1010,
        14: 4'b1100,
        15: 4'b1110
    };
    logic [3:0] expected_q;

    // 2. Instantiate the Module
    lfsr_4bit dut (
        // Connect the testbench signals to the modeul ins/outs
        .clk   (clk),
        .rst_n (rst_n),
        .q     (q)
    );

    // 3. Clock Generation
    // This flips the clock every 5 nanoseconds, creating a 100MHz clock.
    initial clk = 0;
    always #5 clk = ~clk;

    // 4. The Stimulus (The "Action")
    initial begin
        // Initialize and Reset
        $display("Starting Simulation...");
        rst_n = 0;      // Start in reset
        #15;            // Wait 15ns
        rst_n = 1;      // Release reset
        // 5. Observe the output for 10 clock cycles
        repeat (15) begin
            @(posedge clk); 
            // $display("Time: %0t | LFSR State: %b (%d)", $time, q, q);
            expected_q = lfsr_lut[$past(q)]; // use the value of q just before this clock edge
            assert (q === expected_q)
                else $error("MISMATCH! Observed: %d, Expected %d", q, expected_q);
        end

        $display("Simulation Finished.");
        $finish; // Stops the simulator
    end

endmodule