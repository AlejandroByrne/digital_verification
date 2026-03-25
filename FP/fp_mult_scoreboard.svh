class fp_mult_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(fp_mult_scoreboard)

  uvm_analysis_imp #(fp_mult_txn, fp_mult_scoreboard) analysis_export;

  int pass_count = 0;
  int fail_count = 0;

  // Constants derived from the package-level P and E
  localparam int BIAS      = (1 << (E-1)) - 1;   // 127
  localparam int EXP_MAX   = (1 << E) - 1;        // 255 (all 1s = special)
  localparam int FRAC_BITS = P - 1;                // 7

  function new(string name="fp_mult_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_export = new("analysis_export", this);
  endfunction: build_phase

  // ----------------------------------------------------------------
  //  write() — called by the monitor via the analysis port
  // ----------------------------------------------------------------
  function void write(fp_mult_txn txn);
    logic [P+E-1:0] exp_p;
    logic [3:0]     exp_oor;

    compute_expected(txn.x_in, txn.y_in, txn.round_in, exp_p, exp_oor);

    if (txn.p_out === exp_p && txn.oor_out === exp_oor) begin
      pass_count++;
      `uvm_info("SB_PASS", $sformatf(
        "0x%04h * 0x%04h [r=%0d] = 0x%04h  oor=%04b",
        txn.x_in, txn.y_in, txn.round_in, txn.p_out, txn.oor_out), UVM_MEDIUM)
    end else begin
      fail_count++;
      `uvm_error("SB_FAIL", $sformatf(
        "0x%04h * 0x%04h [r=%0d] | DUT: p=0x%04h oor=%04b | REF: p=0x%04h oor=%04b",
        txn.x_in, txn.y_in, txn.round_in,
        txn.p_out, txn.oor_out, exp_p, exp_oor))
    end
  endfunction: write

  // ----------------------------------------------------------------
  //  classify_fp() — matches oor_assembler: {zero, inf, nan, subnormal}
  // ----------------------------------------------------------------
  function logic [3:0] classify_fp(logic [P+E-1:0] val);
    logic [E-1:0]         exp_bits;
    logic [FRAC_BITS-1:0] frac_bits;
    logic                 e_min, e_max, frac_zero;
    exp_bits  = val[P+E-2:P-1];
    frac_bits = val[P-2:0];
    e_min     = (exp_bits == '0);
    e_max     = (&exp_bits);
    frac_zero = (frac_bits == '0);
    return {e_min & frac_zero,    // [3] zero
            e_max & frac_zero,    // [2] infinity
            e_max & ~frac_zero,   // [1] NaN
            e_min & ~frac_zero};  // [0] subnormal
  endfunction: classify_fp

  // ----------------------------------------------------------------
  //  compute_expected() — golden reference model
  // ----------------------------------------------------------------
  //  Algorithmically independent from the RTL: uses wide integer math
  //  rather than mirroring the gate-level pipeline.
  // ----------------------------------------------------------------
  function void compute_expected(
    input  logic [P+E-1:0] x, y,
    input  logic [1:0]     rnd,
    output logic [P+E-1:0] result,
    output logic [3:0]     oor
  );
    // -- field extraction --
    logic                 sign_x, sign_y, sign_r;
    logic [E-1:0]         exp_x, exp_y;
    logic [P-1:0]         mant_x, mant_y;
    logic [3:0]           cls_x, cls_y;
    logic                 is_nan, is_inf, is_zero;
    // -- normal-path variables --
    int                   exp_r;
    logic [2*P-1:0]       product;
    logic [2*P:0]         product_wide;   // extra bit for rounding carry
    logic                 guard, rnd_bit, sticky, lsb, do_round;
    logic [E-1:0]         final_exp;
    logic [FRAC_BITS-1:0] final_frac;

    // ---- Extract fields ----
    sign_x = x[P+E-1];
    sign_y = y[P+E-1];
    sign_r = sign_x ^ sign_y;
    exp_x  = x[P+E-2:P-1];
    exp_y  = y[P+E-2:P-1];

    // ---- Classify inputs ----
    cls_x = classify_fp(x);
    cls_y = classify_fp(y);

    // ---- Special-case detection (mirrors input_handler) ----
    //  NaN "corrupts" everything; also Inf × 0 = NaN
    is_nan  = cls_x[1] || cls_y[1] ||
              (cls_x[3] && cls_y[2]) || (cls_x[2] && cls_y[3]);
    is_inf  = (cls_x[2] || cls_y[2]) && !is_nan;
    is_zero = (cls_x[3] || cls_y[3]) && !is_nan;

    if (is_nan) begin
      // Canonical NaN: exponent all-1s, fraction all-1s
      result = {sign_r, {E{1'b1}}, {FRAC_BITS{1'b1}}};
      oor    = classify_fp(result);
      return;
    end
    if (is_inf) begin
      result = {sign_r, {E{1'b1}}, {FRAC_BITS{1'b0}}};
      oor    = classify_fp(result);
      return;
    end
    if (is_zero) begin
      result = {sign_r, {(P+E-1){1'b0}}};
      oor    = classify_fp(result);
      return;
    end

    // ============================================================
    //  Normal multiplication
    // ============================================================

    // Step 1: Multiply mantissas (with implicit leading 1)
    mant_x  = {1'b1, x[P-2:0]};
    mant_y  = {1'b1, y[P-2:0]};
    product = mant_x * mant_y;      // fits in 2P bits

    // Step 2: Add exponents and subtract bias
    exp_r = int'({1'b0, exp_x}) + int'({1'b0, exp_y}) - BIAS;

    // Step 3: First normalization
    //  Product is in format [2P-1 : 0] with binary point after bit [2*(P-1)].
    //  If MSB is set, the integer part is >= 2 — increment exponent.
    //  Otherwise shift left so MSB becomes the hidden bit.
    if (product[2*P-1]) begin
      exp_r = exp_r + 1;
      // product stays; hidden bit is at [2P-1], fraction at [2P-2 : P]
    end else begin
      product = product << 1;
    end

    // Step 4: Rounding
    //  After normalization, product[2P-1] = 1 (hidden bit).
    //  Bits [2P-2 : P] = result fraction (7 bits for P=8)
    //  Bit  [P-1]      = guard
    //  Bit  [P-2]      = round
    //  Bits [P-3 : 0]  = sticky region
    guard   = product[P-1];
    rnd_bit = product[P-2];
    sticky  = |product[P-3:0];
    lsb     = product[P];       // LSB of the result fraction

    case (rnd)
      2'b00:   // RNE — round to nearest, ties to even
        do_round = (guard & ~rnd_bit & ~sticky) ? lsb : guard;
      2'b01:   // RTZ — round toward zero (truncate)
        do_round = 1'b0;
      2'b10:   // RD  — round down (toward –∞)
        do_round = sign_r & (guard | rnd_bit | sticky);
      2'b11:   // RU  — round up (toward +∞)
        do_round = !sign_r & (guard | rnd_bit | sticky);
      default: do_round = 1'b0;
    endcase

    if (do_round) begin
      // Add 1 at bit position P (increment the fraction LSB)
      product_wide = {1'b0, product} + (1 << P);

      if (product_wide[2*P]) begin
        // Mantissa overflowed from rounding — renormalize
        product = product_wide[2*P:1];   // shift right by 1
        exp_r   = exp_r + 1;
      end else begin
        product = product_wide[2*P-1:0];
      end
    end

    // Step 5: Extract fraction
    final_frac = product[2*P-2:P];

    // Step 6: Output assembly with overflow saturation
    //  Matches output_assembler: if exponent hits all-1s, clamp to
    //  the largest representable normal number.
    if (exp_r >= EXP_MAX) begin
      // Overflow → saturate to max normal (NOT infinity)
      result = {sign_r, {(E-1){1'b1}}, 1'b0, {FRAC_BITS{1'b1}}};
    end else if (exp_r <= 0) begin
      // Underflow → flush to zero (DUT doesn't support subnormals)
      result = {sign_r, {(P+E-1){1'b0}}};
    end else begin
      final_exp = exp_r[E-1:0];
      result    = {sign_r, final_exp, final_frac};
    end

    oor = classify_fp(result);
  endfunction: compute_expected

  // ----------------------------------------------------------------
  //  report_phase — print final pass/fail tally
  // ----------------------------------------------------------------
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SB", $sformatf(
      "\n=============================\n  SCOREBOARD: %0d PASS, %0d FAIL\n=============================",
      pass_count, fail_count), UVM_LOW)
  endfunction: report_phase

endclass: fp_mult_scoreboard
