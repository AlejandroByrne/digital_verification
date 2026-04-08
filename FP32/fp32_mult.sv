`timescale 1ns/1ps

// ============================================================
//  IEEE 754 Float32 Single-Cycle Multiplier
//
//  Architecture: combinational core + registered outputs
//  Latency: 1 clock cycle
//  Format: [31] sign | [30:23] exponent (bias=127) | [22:0] fraction
//
//  Supports:
//    - All IEEE 754 special cases (NaN, Inf, Zero, Subnormal)
//    - Four rounding modes: RNE(0), RTZ(1), RDN(2), RUP(3)
//    - Exception flags: {NV, DZ, OF, UF, NX}  (RISC-V fflags order)
// ============================================================

module fp32_mult (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] a_in,
    input  logic [31:0] b_in,
    input  logic [1:0]  rnd_mode_in,
    input  logic        valid_in,
    output logic [31:0] result_out,
    output logic [4:0]  flags_out,
    output logic        valid_out
);

    // ── Combinational core ──
    logic [31:0] result_comb;
    logic [4:0]  flags_comb;

    fp32_mult_core core (
        .a        (a_in),
        .b        (b_in),
        .rnd_mode (rnd_mode_in),
        .result   (result_comb),
        .flags    (flags_comb)
    );

    // ── Registered outputs: 1-cycle latency ──
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out  <= 1'b0;
            result_out <= 32'h0;
            flags_out  <= 3'h0;
        end else begin
            valid_out <= valid_in;
            if (valid_in) begin
                result_out <= result_comb;
                flags_out  <= flags_comb;
            end
        end
    end

endmodule


// ============================================================
//  Combinational multiply core
//  Pure combinational — no clocks, no state
// ============================================================
module fp32_mult_core (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [1:0]  rnd_mode,
    output logic [31:0] result,
    output logic [4:0]  flags
);

    // ── Constants ──
    localparam BIAS    = 127;
    localparam EXP_MAX = 255;
    localparam [31:0] QNAN = 32'h7FC00000;

    // ════════════════════════════════════════════════════════
    //  STAGE 1: Unpack fields
    // ════════════════════════════════════════════════════════
    logic        sign_a, sign_b, sign_r;
    logic [7:0]  exp_a, exp_b;
    logic [22:0] frac_a, frac_b;

    assign sign_a = a[31];
    assign sign_b = b[31];
    assign sign_r = sign_a ^ sign_b;
    assign exp_a  = a[30:23];
    assign exp_b  = b[30:23];
    assign frac_a = a[22:0];
    assign frac_b = b[22:0];

    // ════════════════════════════════════════════════════════
    //  STAGE 2: Classify each operand
    // ════════════════════════════════════════════════════════
    logic a_zero, a_sub, a_inf, a_snan, a_qnan;
    logic b_zero, b_sub, b_inf, b_snan, b_qnan;

    assign a_zero = (exp_a == 8'h00) && (frac_a == 23'h0);
    assign a_sub  = (exp_a == 8'h00) && (frac_a != 23'h0);
    assign a_inf  = (exp_a == 8'hFF) && (frac_a == 23'h0);
    assign a_snan = (exp_a == 8'hFF) && (frac_a != 23'h0) && !frac_a[22];
    assign a_qnan = (exp_a == 8'hFF) && (frac_a != 23'h0) &&  frac_a[22];

    assign b_zero = (exp_b == 8'h00) && (frac_b == 23'h0);
    assign b_sub  = (exp_b == 8'h00) && (frac_b != 23'h0);
    assign b_inf  = (exp_b == 8'hFF) && (frac_b == 23'h0);
    assign b_snan = (exp_b == 8'hFF) && (frac_b != 23'h0) && !frac_b[22];
    assign b_qnan = (exp_b == 8'hFF) && (frac_b != 23'h0) &&  frac_b[22];

    // ════════════════════════════════════════════════════════
    //  STAGE 3: Special-case detection (IEEE 754 §6, §7)
    // ════════════════════════════════════════════════════════
    logic        is_special;
    logic [31:0] special_result;
    logic [4:0]  special_flags;

    always_comb begin
        is_special     = 1'b1;
        special_result = 32'h0;
        special_flags  = 5'h0;

        // Priority order: sNaN > qNaN > Inf×0 > Inf > Zero
        if (a_snan || b_snan) begin
            special_result = QNAN;
            special_flags  = 3'b100;     // NV
        end else if (a_qnan || b_qnan) begin
            special_result = QNAN;         // no exception
        end else if ((a_inf && b_zero) || (a_zero && b_inf)) begin
            special_result = QNAN;
            special_flags  = 3'b100;     // NV
        end else if (a_inf || b_inf) begin
            special_result = {sign_r, 8'hFF, 23'h0};   // ±Inf
        end else if (a_zero || b_zero) begin
            special_result = {sign_r, 31'h0};           // ±Zero
        end else begin
            is_special = 1'b0;             // proceed to multiply
        end
    end

    // ════════════════════════════════════════════════════════
    //  STAGE 4: Pre-normalize subnormal inputs
    //  Shift mantissa left until MSB is at bit 23 (implicit 1),
    //  adjust exponent to compensate.
    // ════════════════════════════════════════════════════════
    logic [4:0]  lz_a, lz_b;
    logic [23:0] mant_a, mant_b;
    logic signed [9:0] exp_a_adj, exp_b_adj;

    fp32_clz23 clz_a (.data(frac_a), .count(lz_a));
    fp32_clz23 clz_b (.data(frac_b), .count(lz_b));

    always_comb begin
        if (a_sub) begin
            mant_a    = {1'b0, frac_a} << (lz_a + 5'd1);
            exp_a_adj = -$signed({5'b0, lz_a});
        end else begin
            mant_a    = {1'b1, frac_a};
            exp_a_adj = $signed({2'b0, exp_a});
        end

        if (b_sub) begin
            mant_b    = {1'b0, frac_b} << (lz_b + 5'd1);
            exp_b_adj = -$signed({5'b0, lz_b});
        end else begin
            mant_b    = {1'b1, frac_b};
            exp_b_adj = $signed({2'b0, exp_b});
        end
    end

    // ════════════════════════════════════════════════════════
    //  STAGE 5: Multiply mantissas  (24 × 24 → 48 bits)
    // ════════════════════════════════════════════════════════
    logic [47:0] product;
    assign product = mant_a * mant_b;

    // ════════════════════════════════════════════════════════
    //  STAGE 6: Add exponents  (exp_a + exp_b − bias)
    // ════════════════════════════════════════════════════════
    logic signed [10:0] exp_sum;
    assign exp_sum = $signed({1'b0, exp_a_adj})
                   + $signed({1'b0, exp_b_adj})
                   - $signed(11'd127);

    // ════════════════════════════════════════════════════════
    //  STAGE 7: First normalization
    //  Product MSB at bit 47 → exp + 1 (value ≥ 2.0)
    //  Product MSB at bit 46 → no change (value in [1.0, 2.0))
    // ════════════════════════════════════════════════════════
    logic [47:0]        norm_product;
    logic signed [10:0] norm_exp;

    always_comb begin
        if (product[47]) begin
            norm_product = product;
            norm_exp     = exp_sum + $signed(11'd1);
        end else begin
            norm_product = product << 1;
            norm_exp     = exp_sum;
        end
    end
    // After this: norm_product[47] = hidden bit (always 1)
    //   [46:24] = 23-bit fraction
    //   [23]    = guard
    //   [22]    = round
    //   [21:0]  = sticky region

    // ════════════════════════════════════════════════════════
    //  STAGE 8: Denormalize if result exponent underflows
    //  When norm_exp ≤ 0, shift right to produce a subnormal.
    // ════════════════════════════════════════════════════════
    logic [47:0]        shifted_product;
    logic signed [10:0] shifted_exp;
    logic               denorm_sticky;
    logic               is_subnormal_out;
    logic signed [10:0] denorm_shift;

    assign denorm_shift = $signed(11'd1) - norm_exp;

    always_comb begin
        shifted_product   = norm_product;
        shifted_exp       = norm_exp;
        denorm_sticky     = 1'b0;
        is_subnormal_out  = 1'b0;

        if (norm_exp <= $signed(11'd0) && !is_special) begin
            is_subnormal_out = 1'b1;
            shifted_exp      = $signed(11'd0);

            if (denorm_shift >= $signed(11'd48)) begin
                // Complete underflow — all bits lost
                shifted_product = 48'h0;
                denorm_sticky   = 1'b1;
            end else if (denorm_shift > $signed(11'd0)) begin
                // Partial shift: capture lost bits for sticky
                denorm_sticky   = |(norm_product & ((48'h1 << denorm_shift[5:0]) - 48'h1));
                shifted_product = norm_product >> denorm_shift[5:0];
            end
        end
    end

    // ════════════════════════════════════════════════════════
    //  STAGE 9: Extract guard / round / sticky
    // ════════════════════════════════════════════════════════
    logic [22:0] frac_pre;
    logic        guard, round_bit, sticky, lsb, inexact;

    assign frac_pre  = shifted_product[46:24];
    assign guard     = shifted_product[23];
    assign round_bit = shifted_product[22];
    assign sticky    = |shifted_product[21:0] | denorm_sticky;
    assign lsb       = shifted_product[24];
    assign inexact   = guard | round_bit | sticky;

    // ════════════════════════════════════════════════════════
    //  STAGE 10: Rounding
    // ════════════════════════════════════════════════════════
    logic do_round;

    always_comb begin
        case (rnd_mode)
            2'b00:   do_round = guard & (round_bit | sticky | lsb);  // RNE
            2'b01:   do_round = 1'b0;                                 // RTZ
            2'b10:   do_round = sign_r & inexact;                      // RDN
            2'b11:   do_round = !sign_r & inexact;                     // RUP
            default: do_round = 1'b0;
        endcase
    end

    // Apply rounding increment
    logic [23:0]        frac_rounded;   // 24 bits to detect carry
    logic signed [10:0] round_exp;

    always_comb begin
        frac_rounded = {1'b0, frac_pre} + {23'h0, do_round};
        round_exp    = shifted_exp;

        // Fraction carry: 1.111...1 + 1 = 10.000...0
        if (frac_rounded[23]) begin
            round_exp = shifted_exp + $signed(11'd1);
            // frac_rounded[22:0] is already 0 from the carry
        end
    end

    // ════════════════════════════════════════════════════════
    //  STAGE 11: Final assembly with overflow / underflow
    // ════════════════════════════════════════════════════════
    always_comb begin
        if (is_special) begin
            // ── Special case (NaN / Inf / Zero) ──
            result = special_result;
            flags  = special_flags;

        end else if (round_exp >= $signed(11'd255)) begin
            // ── Overflow: result too large ──
            flags = 5'b00101;   // OF + NX
            case (rnd_mode)
                2'b01:   result = {sign_r, 8'hFE, 23'h7FFFFF};         // RTZ → max finite
                2'b10:   result = sign_r ? 32'hFF800000                 // RDN
                               : {1'b0, 8'hFE, 23'h7FFFFF};
                2'b11:   result = sign_r ? {1'b1, 8'hFE, 23'h7FFFFF}   // RUP
                               : 32'h7F800000;
                default: result = {sign_r, 8'hFF, 23'h0};              // RNE → ±Inf
            endcase

        end else if (round_exp <= $signed(11'd0)) begin
            // ── Subnormal or underflow to zero ──
            result = {sign_r, 8'h00, frac_rounded[22:0]};
            flags  = inexact ? 5'b00011 : 5'b00000;   // UF + NX if inexact

        end else begin
            // ── Normal result ──
            result = {sign_r, round_exp[7:0], frac_rounded[22:0]};
            flags  = {4'b0000, inexact};               // NX if inexact
        end
    end

endmodule


// ============================================================
//  Leading-zero counter for 23-bit fraction fields
//  Used to pre-normalize subnormal inputs
// ============================================================
module fp32_clz23 (
    input  logic [22:0] data,
    output logic [4:0]  count
);
    always_comb begin
        count = 5'd23;   // default: all zeros
        for (int i = 22; i >= 0; i--) begin
            if (data[i]) begin
                count = 5'(22 - i);
                break;
            end
        end
    end
endmodule
