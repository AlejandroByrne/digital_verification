typedef enum logic [1:0] {GREEN, YELLOW, RED} state_t;

module traffic_light_controller (
    input logic clk,
    input logic rst_n,
    input logic sensor,
    output state_t light
);

    logic [1:0] yellow_cycles;
    logic [2:0] red_cycles;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            light <= GREEN;
            yellow_cycles <= 2;
            red_cycles <= 4;
        end else if (light == 0) begin
            if (sensor) begin
                light <= YELLOW;
                yellow_cycles <= 2;
            end
        end else if (light == 1) begin // if yellow
            if (yellow_cycles == 0) begin
                light <= RED;
                red_cycles <= 4;
            end else begin
                yellow_cycles <= yellow_cycles - 1;
            end
        end else if (light == 2) begin
            if (red_cycles == 0) begin
                light <= GREEN;
            end else begin
                red_cycles <= red_cycles - 1;
            end
        end
    end

endmodule