`timescale 1ns/1ps

// build: verilator --binary fpmult.sv
// ./obj_dir/Vrounding

module fp_mult_rtl #(
        parameter P = 8,
        parameter Q = 8
    )(
    input  logic rst_in_N,        // asynchronous active-low reset
    input  logic clk_in,          // clock
    input  logic [P+Q-1:0] x_in,     // input X; x_in[15] is the sign bit
    input  logic [P+Q-1:0] y_in,     // input Y: y_in[15] is the sign bit
    input  logic [1:0] round_in,  // rounding mode specifier
    input  logic start_in,        // signal to start multiplication
    output logic [P+Q-1:0] p_out,  // output P: p_out[15] is the sign bit
    output logic [3:0] oor_out, // out-of-range indicator vector
    output logic done_out       // signal that outputs are ready
);

    // Preliminary steps
    logic go;

    // VERY FIRST STAGE INPUTS
    logic [P+Q-1:0] x_in_go;
    logic [P+Q-1:0] y_in_go;
    logic [1:0] round_in_go;

    assign x_in_go = go ? x_in : {(P+Q){1'b0}};
    assign y_in_go = go ? y_in : {(P+Q){1'b0}};
    assign round_in_go = go ? round_in : 2'b0;

    // done_out is high whenever go is active (outputs are valid)
    assign done_out = go;
    // Computer sign
    logic sign;
    sign_computer sign_compute (x_in_go[P+Q-1], y_in_go[P+Q-1], sign);

    // STEP 1 --------------
    // Multiply fractions
    logic [P*2-1:0] product;
    // TODO: Implicit 1 can't be added for subnormals (?) if we decide to process those
    braun_multiplier #(P) braun_multiply({1'b1, x_in_go[P-2:0]}, {1'b1, y_in_go[P-2:0]}, product);

    // STEP 2 ---------------- add exponents, and load everything into the first normalizer
    // Sum exponents
    logic [Q-1:0] exponent_sum;
    logic overflow; // dummy value
    // End range at P - 1 because it's inclusive. Fraction bits will be [P-2:0] because of implicit 1
    exponent_adder #(Q) exponent_add (
        .a_in(x_in_go[P+Q-2:P-1]),
        .b_in(y_in_go[P+Q-2:P-1]),
        .y_out(exponent_sum),
        .carry_out(overflow)
    );

    logic [P*2-1:0] post_norm_pa;
    logic [Q-1:0] post_norm_exponent;
    // First normalizer
    normalization #(P, Q) normalize (
        .pa_bits(product),
        .exponent(exponent_sum),
        .pa_bits_out(post_norm_pa),
        .exponent_out(post_norm_exponent)
    );

    // STEP 3 ---------------- load from normalizer (and FP inputs) into rounding
    logic [P*2-1:0] post_round_pa;
    logic [Q-1:0] post_round_exponent;
    logic rounding_overflow;
    rounding #(P, Q) round (
        .rounding_mode(round_in_go),
        .sign(sign),
        .exponent_in(post_norm_exponent),
        .pa_bits(post_norm_pa),
        .pa_bits_out(post_round_pa),
        .exponent_out(post_round_exponent),
        .overflow(rounding_overflow)
    );

    // STEP 4 ---------------- load from rounding to second normalizer
    logic [P*2-1:0] post_renorm_pa;
    logic [Q-1:0] post_renorm_exponent;
    // Renormalizer
    renormalization #(P, Q) renormalize (
        .pa_bits(post_round_pa),
        .exponent(post_round_exponent),
        .overflow(rounding_overflow),
        .pa_bits_out(post_renorm_pa),
        .exponent_out(post_renorm_exponent)
    );

    // STEP 5.0 ----------------- input handling
    // Check for special inputs
    logic special_case;
    logic [P+Q-1:0] special_input;
    input_handler #(P, Q) special_input_handler (
        .a_in(x_in),
        .b_in(y_in),
        .y_out(special_input),
        .oor_out(special_case)
    );

    // Check flag to use output for special case if needed
    logic [P+Q-1:0] p_temp;
    assign p_temp = special_case ? special_input : {sign, post_renorm_exponent, post_renorm_pa[P * 2 - 2: P]};

    // STEP 5.1 ----------------- output handling
  	output_assembler #(P, Q) outputter (
        .sign_in(p_temp[P+Q-1]),
        .exponent_in(p_temp[P+Q-2:P-1]),
        .fraction_in(p_temp[P-2:0]),
        .special_in(special_case),
        .y_out(p_out),
        .oor_out(oor_out)
    );



    // State transitioning:
    // go registers start_in — outputs are valid while go is high
    always_ff @(posedge clk_in or negedge rst_in_N) begin
        if (!rst_in_N)
            go <= 1'b0;
        else
            go <= start_in;
    end

endmodule


module braun_multiplier #(parameter P) (
    input  logic [P-1:0]    a_in,
    input  logic [P-1:0]    b_in,
    output logic [2*P-1:0]  y_out
);

    // Conventional Braun multiplier ripple-carry design
    logic [2*P-1:0] a, b;
    logic [2*P-1:0] adders [P-1:0] /*verilator split_var*/;

    always_comb begin
        // Pad a and b, replicator syntax allows parametrized padding
        a = {{P{1'b0}}, a_in};
        b = {{P{1'b0}}, b_in};
    end

    // Braun single pass shift-add generate block
    // TODO: Make sure assign statements generate combinational logic here
    genvar i;
    generate
        // Special case for first layer
        assign adders[0] = a[0] == 1'b1 ? b : '0;

        for (i = 1; i < P; i++) begin
            assign adders[i] = a[i] == 1'b1 ? adders[i-1] + (b << i) : adders[i-1];
        end
    endgenerate

    always_comb begin
        y_out = adders[P-1][2*P-1:0];
    end

endmodule


// Check 2 inputs for special cases, output flag for special case and output value for case
module input_handler #(
        parameter P,
        parameter Q
    )(
    input   logic [P+Q-1:0] a_in,
    input   logic [P+Q-1:0] b_in,
    output  logic [P+Q-1:0] y_out,
    output  logic           oor_out
);
    logic [3:0] oor_a,
                oor_b;

    oor_assembler #(P, Q) oor_assembler_a (a_in, oor_a);
    oor_assembler #(P, Q) oor_assembler_b (b_in, oor_b);

    typedef enum logic [1:0]{
        SUBNORMAL,
        NAN,
        INFINITY,
        ZERO
    } oor_type;

    // Handle cases for invalid input combinations
    logic   NaN,
            infinity,
            zero;

    logic [P+Q-1:0] y_temp;

    // Sign compute for special case value
    logic sign;
    sign_computer sign_compute(a_in[P+Q-1], b_in[P+Q-1], sign);

    always_comb begin

         // NaN "corrupts" anything. Also check infinity and 0
        NaN = oor_a[NAN] || oor_b[NAN] || ((oor_a[ZERO] && oor_b[INFINITY]) || (oor_a[INFINITY] && oor_b[ZERO]));
        // Infinity check. Check !NaN
        infinity = (oor_a[INFINITY] || oor_b[INFINITY]) && !NaN;
        // Zero check. Check !NaN
        zero = (oor_a[ZERO] || oor_b[ZERO]) && !NaN;

        // Output computation
        y_temp = '0; // Set to 0 vector initially

        y_temp = NaN ? {1'b0, {Q{1'b1}}, {(P-2){1'b1}}, 1'b1} : y_temp; // Set all bits to 1 to represent NaN
        y_temp = infinity ? {1'b0, {Q{1'b1}}, {(P-1){1'b0}}} : y_temp;
        y_temp = zero ? '0 : y_temp;

        // Construct output
        y_out = {sign, y_temp[P+Q-2:0]};

        // OR OORs together for both inputs to create flag for special case
        // Exclude final bit for OOR for each, since we aren't handling subnormal
        oor_out = |{oor_a[3:1], oor_b[3:1]};

    end

endmodule


// Add 2 binary vectors of length D_SIZE, provide carry_out
module oor_assembler #(
        parameter P,
        parameter Q
    )(
    input   logic [P+Q-1:0] x_in,
    output  logic [3:0]    oor_out
);

    logic           sign;
    logic [Q-1:0]   exponent;
    logic [P-2:0]   fraction;

    // Following taken from HP6e Appendix J
    logic   e_min,
            e_max,
            zero_fraction;

    logic   zero_flag,
            infinity_flag,
            nan_flag,
            subnormal_flag;

    always_comb begin
        sign = x_in[P+Q-1];
        exponent = x_in[P+Q-2:P-1]; // End range at P - 1 because it's inclusive. Fraction bits will be [P-2:0] because of implicit 1
        fraction = x_in[P-2:0];

        // OR-reduce and AND-reduce exponent to find whether it's all 0's or all 1's
        e_min = !(|exponent);
        e_max = &exponent;
        zero_fraction = !(|fraction); // OR fraction together then invert. Evaluates to 1 if zero vector, 0 otherwise

        zero_flag = e_min && zero_fraction;
        infinity_flag = e_max && zero_fraction;
        nan_flag = e_max && !zero_fraction;
        subnormal_flag = e_min && !zero_fraction;

        oor_out = {zero_flag, infinity_flag, nan_flag, subnormal_flag};
    end

endmodule


// Add 2 binary vectors of length D_SIZE, provide carry_out
module output_assembler #(
        parameter P,
        parameter Q
    )(
    input   logic           sign_in,
    input   logic [Q-1:0]   exponent_in,
    input   logic [P-2:0]   fraction_in, // -2 because of hidden bit left of decimal
    input   logic           special_in, // indicates special input
    output  logic [P+Q-1:0] y_out,
    output  logic [3:0]    oor_out
);
    logic [P+Q-1:0] y_temp;

    always_comb begin
        y_temp = {sign_in, exponent_in, fraction_in};
        if (!special_in) begin // Don't cap special inputs
            if (exponent_in == {Q{1'b1}}) begin
                y_temp = {sign_in, {(Q-1){1'b1}}, 1'b0, {(P-1){1'b1}}};
            end
        end
        y_out = y_temp;
    end

    oor_assembler #(P, Q) oor (y_temp, oor_out);

endmodule

module exponent_adder #(parameter D_SIZE = 8) (
    input   logic [D_SIZE-1:0] a_in,
    input   logic [D_SIZE-1:0] b_in,
    output  logic [D_SIZE-1:0] y_out,
    output  logic              carry_out
);

    // Internal adder, subtract bias after
    logic [D_SIZE - 1:0] sum;
    logic carry;
    adder #(D_SIZE) bit_adder (a_in, b_in, sum, carry);
	// 0001011011110100
  	// 1111100010010111
    logic [D_SIZE:0] temp;
    always_comb begin
      temp = {carry, sum} - {1'b0, {(D_SIZE-1){1'b1}}};
        carry_out = temp[D_SIZE];
        y_out = carry_out ? {(D_SIZE){1'b1}} : temp[D_SIZE-1:0];
    end

endmodule

// Add 2 binary vectors of length D_SIZE, provide carry_out
module adder #(parameter D_SIZE = 8) (
    input   logic [D_SIZE-1:0] a_in,
    input   logic [D_SIZE-1:0] b_in,
    output  logic [D_SIZE-1:0] y_out,
    output  logic              carry_out
);

    logic [D_SIZE:0] temp;
    always_comb begin
        temp = {1'b0, a_in} + {1'b0, b_in};
        carry_out = temp[D_SIZE];
        y_out = temp[D_SIZE-1:0];
    end

endmodule

module rounding #(parameter int P = 8, parameter int Q = 8) (
    // input logic                         start,
    // input logic                         clk,
    input logic [1:0]                   rounding_mode,
    input logic                         sign,
    input logic [Q - 1 : 0]             exponent_in,
    input logic [P * 2 - 1: 0]     pa_bits,
    output logic [P * 2 - 1: 0]    pa_bits_out,
    output logic [Q - 1 : 0]             exponent_out,
    output logic                         overflow
);

    logic guard, round, po;
    logic sticky;
    logic round_up;
	logic rounded_overflow;
  	logic [P * 2 - 1: 0]    rounded_pa_bits;
    logic [Q - 1 : 0]       incremented_exponent;
    logic overflow_round; // dummy value

    // submodule for rounding up
  	adder #(P * 2) ad_p_bits (pa_bits, {{(P - 1){1'b0}}, {1'b1}, {(P){1'b0}}}, rounded_pa_bits, rounded_overflow);
    // submodule for adding exponent
    exponent_adder #(Q) exp_add (
        .a_in(exponent_in),
        .b_in(1 + {1'b0, {(Q-1){1'b1}}}),
        .y_out(incremented_exponent),
        .carry_out(overflow_round)
    );

    assign po = pa_bits[P];
    assign guard = pa_bits[P - 1];
    assign round = pa_bits[P - 2];
    assign sticky = |pa_bits[P - 3: 0];

    // assign exponent_out = rounded_overflow ? incremented_exponent : exponent_in;

    always_comb begin
        round_up = 1'b0;
        if (rounding_mode == 1) begin // RTZ, never round up
            round_up = 1'b0;
        end else if (rounding_mode == 2) begin // RD
            round_up = sign & (guard | round | sticky);
        end else if (rounding_mode == 3) begin // RU
            round_up = !sign & (guard | round | sticky);
        end else begin // RNE or default
            round_up = (guard & !round & !sticky) ? po : guard;
        end
        if (round_up) begin
            pa_bits_out = rounded_pa_bits & {{(P){1'b1}}, {(P){1'b0}}};
            overflow = overflow_round;
            exponent_out = rounded_overflow ? incremented_exponent : exponent_in;
        end else begin
            pa_bits_out = pa_bits & {{(P){1'b1}}, {(P){1'b0}}}; // Zeroes out the least significant half, making it impossible to round again
            overflow = 1'b0;
            exponent_out = exponent_in; // no rounding, couldn't have possibly changed ANYTHING
        end // round_up end

    end

endmodule

module normalization #(parameter int P = 8, parameter int Q = 8) (
    // input logic                         start,
    // input logic                         clk,
    input logic [P * 2- 1: 0]      pa_bits,
    input logic [Q - 1: 0]         exponent,
    output logic [P * 2 - 1: 0]     pa_bits_out,
    output logic [Q - 1: 0]         exponent_out
);

    logic [P * 2 - 1: 0]   pa_bits_final;
    logic [Q - 1: 0]       incremented_exponent;
    logic overflow; // dummy value, never used

    // Instantiate exponent_adder at module level
    exponent_adder #(Q) exp_add (
        .a_in(exponent),
        .b_in(1 + {1'b0, {(Q-1){1'b1}}}),
        .y_out(incremented_exponent),
        .carry_out (overflow)
    );

    always_comb begin
            if (pa_bits[P * 2 - 1]) begin // If the MSB is 1, just decrement exponent
                pa_bits_final = pa_bits;
                exponent_out = incremented_exponent;
                // overflow = exp_overflow;
            end else begin // Else, shift over 1
                pa_bits_final = pa_bits << 1;
                exponent_out = exponent;
                // overflow = 1'b0;
            end
    end

    assign pa_bits_out = pa_bits_final[P*2 - 1: 0];

endmodule

module renormalization #(parameter int P = 8, parameter int Q = 8) (
    // input logic                         start,
    // input logic                         clk,
    input logic [P * 2- 1: 0]      pa_bits,
    input logic [Q - 1: 0]         exponent,
    input                           overflow,
    output logic [P * 2 - 1: 0]     pa_bits_out,
    output logic [Q - 1: 0]         exponent_out
);

    logic [P * 2 - 1: 0]   pa_bits_final;
    logic [Q - 1: 0]       incremented_exponent;
    logic overflow_dummy; // dummy value, never used

    // Instantiate exponent_adder at module level
    exponent_adder #(Q) exp_add (
        .a_in(exponent),
        .b_in(1 + {1'b0, {(Q-1){1'b1}}}),
        .y_out(incremented_exponent),
        .carry_out (overflow_dummy)
    );

    always_comb begin
            if (overflow) begin // If overflow is 1, just increment exponent
                pa_bits_final = (pa_bits >> 1) | {1'b1, {(P * 2 - 1){1'b0}}};
                exponent_out = incremented_exponent;
            end else begin // Else, DO NOTHING
                pa_bits_final = pa_bits;
                exponent_out = exponent;
            end
    end

    assign pa_bits_out = pa_bits_final[P*2 - 1: 0];

endmodule


// XOR signs together
module sign_computer (
    input   logic   a_in,
    input   logic   b_in,
    output  logic   y_out
);
    always_comb
        y_out = a_in ^ b_in;

endmodule
