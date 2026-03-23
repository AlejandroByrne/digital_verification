// `timescale 1ns / 1ps
// `default_nettype none

module cascade_or #(parameter SIZE = 4) (
    input  logic [SIZE-1:0] in,
    output logic          out
);

generate
  // For a single-bit input, just assign it to the output.
  if (SIZE == 1) begin: single_bit
    assign out = in[0];
  end else begin: cascade
    // Create a chain of wires to hold the intermediate OR results.
    /* verilator lint_off UNOPTFLAT */
    wire [SIZE-2:0] chain;
    /* verilator lint_off UNOPTFLAT */

    // First inputs are from in, then the chain begins
    or or_gate0 (chain[0], in[0], in[1]);

    // Cascade additional OR gates: each ORs the previous result with the next bit.
    /* verilator lint_off WIDTHEXPAND */
    for (genvar i = 1; i < SIZE-1; i = i + 1) begin: or_chain
    /* verilator lint_off WIDTHEXPAND */
      or or_gate (chain[i], chain[i-1], in[i+1]);
    end

    assign out = chain[SIZE-2];
  end
endgenerate

endmodule

module overflow_detect #(parameter SIZE = 4) (
    input logic             msb,
    input logic             stage_enable,
    input logic [SIZE-1:0]  stage_wires,
    output logic            out_bit
);

    wire [SIZE-1:0] or_inputs;
    /* verilator lint_off UNOPTFLAT */
    wire [$clog2(SIZE):0][SIZE-1:0] or_stages;
    /* verilator lint_off UNOPTFLAT */
    genvar i, j;

    generate
        for  (i = 0; i < SIZE; i = i + 1) begin: muxes_xors
            wire mux_out;
            mux_2 mux (.a(msb), .b(stage_wires[i]), .sel(stage_enable), .out(mux_out));
            xor orx (or_inputs[i], msb, mux_out);
        end
        // First stage of the or gates receives the muxes' outputs as the first input
        assign or_stages[$clog2(SIZE)] = or_inputs;

        for (i = 0; i < $clog2(SIZE); i = i + 1) begin: or_stages_loop
            for (j = 0; j < (1 << i); j = j + 1) begin: ors
                assign or_stages[i][j] = or_stages[i + 1][j * 2] | or_stages[i + 1][j * 2 + 1];
            end
        end
    endgenerate
    assign out_bit = or_stages[0][0];
endmodule

module mux_2 (
    input logic a,
    input logic b,
    input logic sel,
    output logic out
);
    assign out = sel ? b : a;
endmodule

// a simple module that gives an RTL description of the barrelshifter.
module barrelshifter #(parameter D_SIZE) (
    input logic [D_SIZE-1:0]            x_in,
    input logic [$clog2(D_SIZE)-1:0]    s_in,
    input logic [2:0]                   op_in,
    output logic [D_SIZE-1:0]           y_out,
    output logic                        zf_out,
    output logic                        vf_out
);
    // assign y_out = 0;
    // assign vf_out = 0;
    // assign zf_out = 0;

    wire zf_tmp;

    // Compute indicator flags:
    wire rotate, lsa, rsa, reverse;
    assign rotate = op_in[1];
    assign lsa = op_in[2] & !op_in[1] & op_in[0];
    assign rsa = !op_in[2] & !op_in[1] & op_in[0];
    assign reverse = op_in[2];

    genvar i, j;

    generate
        /* verilator lint_off UNOPTFLAT */
        wire [$clog2(D_SIZE):0][D_SIZE-1:0] stage_outputs;
        /* verilator lint_off UNOPTFLAT */
        wire [$clog2(D_SIZE)-1:0][D_SIZE-1:0] or_outputs;
        /* verilator lint_off UNOPTFLAT */
        wire [$clog2(D_SIZE)-1:0][D_SIZE-1:0] rotate_stages;
        /* verilator lint_off UNOPTFLAT */
        wire [$clog2(D_SIZE)-1:0] overflow_outputs ;

        wire msb, shift_in;
        assign msb = x_in[D_SIZE-1];
        mux_2 mux (.a(0), .b(msb), .sel(rsa), .out(shift_in));

        // Pre-reversal
        for (i = 0; i < D_SIZE; i = i + 1) begin: reversal1
            mux_2 mux (.a(x_in[i]), .b(x_in[D_SIZE-1-i]), .sel(reverse), .out(stage_outputs[$clog2(D_SIZE)][i]));
        end

        wire lsa_bit;

        for (i = $clog2(D_SIZE) - 1; i >= 0; i = i - 1) begin: stages
            // Creating the stages of multiplexors for shifting and rotating
            wire mux_sel;
            assign mux_sel = s_in[i];

            for (j = 0; j < D_SIZE; j = j + 1) begin: digits
                wire mux_in0, mux_in1;
                wire overflow_mux_out;

                assign mux_in0 = stage_outputs[i+1][j];
                if (j >= D_SIZE - (1 << i)) begin // rotator multiplexor and overflow flag stage
                    // rotator mux
                    mux_2 mux1 (.a(shift_in), .b(stage_outputs[i+1][j - (D_SIZE - (1 << i))]), .sel(rotate), .out(mux_in1));
                    mux_2 mux (.a (mux_in0), .b (mux_in1), .sel (mux_sel), .out (stage_outputs[i][j]));
                end else if (i == 0 && j == 0) begin // LSA MSB retention
                    assign mux_in1 = stage_outputs[i+1][(1 << i) + j];
                    mux_2 mux (.a (mux_in0), .b (mux_in1), .sel (mux_sel), .out (lsa_bit));
                    mux_2 mux1 (.a(lsa_bit), .b(x_in[D_SIZE - 1]), .sel(lsa), .out(stage_outputs[i][j]));
                end else begin // regular multiplexor step
                    assign mux_in1 = stage_outputs[i+1][(1 << i) + j];
                    mux_2 mux (.a (mux_in0), .b (mux_in1), .sel (mux_sel), .out (stage_outputs[i][j]));
                end
            end

            // Overflow detection for this stage:
            overflow_detect #(1 << i) od (
                .msb(x_in[D_SIZE - 1]),
                .stage_enable(mux_sel),
                .stage_wires(stage_outputs[i+1][(1 << i):1]),
                .out_bit(overflow_outputs[i])
            );
        end

        // Post-reversal
        for (i = 0; i < D_SIZE; i = i + 1) begin: reversal2
            mux_2 mux (.a(stage_outputs[0][i]), .b(stage_outputs[0][D_SIZE-1-i]), .sel(reverse), .out(y_out[i]));
        end
        // Zero flag logic
        cascade_or #(D_SIZE) cor1 (
            .in(stage_outputs[0][D_SIZE-1:0]),
            .out(zf_tmp)
        );

    endgenerate

    // Final overflow step
    wire overflow_out;
    cascade_or #($clog2(D_SIZE)) cor (
        .in(overflow_outputs[$clog2(D_SIZE)-1:0]),
        .out(overflow_out)
    );
    assign vf_out = overflow_out & lsa;
    assign zf_out = ~zf_tmp;
endmodule: barrelshifter
