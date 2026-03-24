class bshift_directed_edge_seq extends uvm_sequence #(bshift_txn);
  `uvm_object_utils(bshift_directed_edge_seq)

  function new(string name = "bshift_directed_edge_seq");
    super.new(name);
  endfunction: new

  // -----------------------------------------------------------------------
  // Helper task — eliminates the create/start_item/assign/finish_item
  // boilerplate for every single transaction. The string label shows up
  // in simulation logs so each transaction is identifiable.
  // -----------------------------------------------------------------------
  local task send(logic [7:0] x, logic [2:0] s, logic [2:0] op, string label);
    bshift_txn txn = bshift_txn::type_id::create(label);
    start_item(txn);
    txn.x_in  = x;
    txn.s_in  = s;
    txn.op_in = op;
    finish_item(txn);
  endtask : send

  task body();

    // =====================================================================
    // GROUP 1 — Universal: s_in = 0 (no shift, any operation)
    //
    // For every shift operation, shifting by zero must be an identity:
    // y_out must equal x_in exactly. For SLA, vf must be 0.
    // We use 0xA5 (1010_0101) because it has a mix of 0s and 1s and
    // its MSB is 1 — so it exercises both sign-sensitive paths.
    // =====================================================================

    send(8'hA5, 3'd0, 3'b000, "s0_srl");  // SRL by 0 → y=0xA5
    send(8'hA5, 3'd0, 3'b001, "s0_sra");  // SRA by 0 → y=0xA5
    send(8'hA5, 3'd0, 3'b010, "s0_ror");  // ROR by 0 → y=0xA5
    send(8'hA5, 3'd0, 3'b100, "s0_sll");  // SLL by 0 → y=0xA5
    send(8'hA5, 3'd0, 3'b101, "s0_sla");  // SLA by 0 → y=0xA5, vf=0
    send(8'hA5, 3'd0, 3'b110, "s0_rol");  // ROL by 0 → y=0xA5

    // =====================================================================
    // GROUP 2 — Universal: x_in = 0 (zero input, any operation)
    //
    // Shifting or rotating zero always produces zero, so zf must fire.
    // This tests the zero flag independently of the operation logic.
    // =====================================================================

    send(8'h00, 3'd3, 3'b000, "zero_srl");  // SRL: 0>>3=0, zf=1
    send(8'h00, 3'd3, 3'b001, "zero_sra");  // SRA: 0>>>3=0, zf=1
    send(8'h00, 3'd3, 3'b100, "zero_sll");  // SLL: 0<<3=0, zf=1
    send(8'h00, 3'd3, 3'b101, "zero_sla");  // SLA: 0, vf=0, zf=1

    // =====================================================================
    // GROUP 3 — SRL: Shift Right Logical (op=000)
    //
    // SRL always zero-fills from the left. It does NOT sign-extend.
    // The key contrast with SRA is that a negative number (MSB=1)
    // becomes smaller after SRL but sign-extends after SRA.
    // =====================================================================

    // 0xFF >> 1: MSB (1) is replaced by 0, NOT preserved.
    // SRL: 1111_1111 >> 1 = 0111_1111 = 0x7F
    // SRA: 1111_1111 >>> 1 = 1111_1111 = 0xFF  (see Group 4 for the contrast)
    send(8'hFF, 3'd1, 3'b000, "srl_sign_bit");  // y=0x7F, zf=0

    // Max shift (s_in=7): only the original MSB survives, in the LSB position
    // 0xFF >> 7: 1111_1111 >> 7 = 0000_0001 = 0x01
    send(8'hFF, 3'd7, 3'b000, "srl_max_shift_ff");  // y=0x01, zf=0

    // One bit shifted out causes zero: 0x01 >> 1 = 0x00, zero flag fires
    send(8'h01, 3'd1, 3'b000, "srl_to_zero");  // y=0x00, zf=1

    // =====================================================================
    // GROUP 4 — SRA: Shift Right Arithmetic (op=001)
    //
    // SRA replicates the sign bit (MSB) into vacated positions.
    // Positive numbers (MSB=0): zero-fills — identical to SRL.
    // Negative numbers (MSB=1): one-fills — the value stays negative.
    // =====================================================================

    // Negative input, shift 1: sign bit replicates. 0x80=1000_0000 → 1100_0000=0xC0
    // SRL of same input gives 0x40 (MSB is cleared). Contrast is the point.
    send(8'h80, 3'd1, 3'b001, "sra_neg_s1");   // y=0xC0, zf=0

    // Fully sign-extended: -128 >>> 7 = -1 = 0xFF (all sign bits)
    send(8'h80, 3'd7, 3'b001, "sra_neg_max");   // y=0xFF, zf=0

    // Positive input: zero-fills just like SRL. 0x40 >>> 1 = 0x20
    send(8'h40, 3'd1, 3'b001, "sra_pos_s1");   // y=0x20, zf=0

    // All-ones input: -1 >>> anything = -1 = 0xFF (stays saturated)
    send(8'hFF, 3'd1, 3'b001, "sra_allones");  // y=0xFF, zf=0

    // =====================================================================
    // GROUP 5 — ROR: Rotate Right (op=010)
    //
    // Bits shifted off the right end reappear at the left end.
    // No bits are lost — the operation is reversible.
    //
    // Implementation: (x >> s) | (x << (-s))
    // -s_in in 3-bit arithmetic: -1→7, -2→6, -3→5, -4→4, etc.
    // So for s=1: (x >> 1) | (x << 7)
    //    The bit shifted off the right (bit 0) reappears at bit 7 (MSB).
    // =====================================================================

    // LSB wraps to MSB: 0x01 = 0000_0001 → 1000_0000 = 0x80
    send(8'h01, 3'd1, 3'b010, "ror_lsb_wrap");  // y=0x80

    // MSB shifts right by 1: 0x80 = 1000_0000 → 0100_0000 = 0x40
    // Note: the 0 that wraps from bit 0 lands at bit 7 (which was already 0 for bit-1)
    send(8'h80, 3'd1, 3'b010, "ror_msb_s1");    // y=0x40

    // Half-rotation: rotate an alternating pattern by 4.
    // 0xF0 = 1111_0000 rotated right 4 = 0000_1111 = 0x0F
    // Upper nibble (1111) ends up in lower nibble. Lower nibble (0000) wraps to upper.
    send(8'hF0, 3'd4, 3'b010, "ror_nibble");    // y=0x0F

    // =====================================================================
    // GROUP 6 — SLL: Shift Left Logical (op=100)
    //
    // SLL zero-fills from the right. Bits shifted off the left are lost.
    // The symmetric counterpart to SRL.
    // =====================================================================

    // Max shift: only the original LSB survives, in the MSB position
    // 0xFF << 7: 1111_1111 << 7 = 1000_0000 = 0x80
    send(8'hFF, 3'd7, 3'b100, "sll_max_shift");   // y=0x80, zf=0

    // MSB shifted out causes zero: 0x80 << 1 = 0000_0000 = 0x00
    send(8'h80, 3'd1, 3'b100, "sll_msb_to_zero"); // y=0x00, zf=1

    // LSB climbs to MSB: 0x01 << 7 = 0x80
    send(8'h01, 3'd7, 3'b100, "sll_lsb_to_msb");  // y=0x80, zf=0

    // =====================================================================
    // GROUP 7 — SLA: Shift Left Arithmetic (op=101)
    //
    // The most complex operation. The MSB (sign bit) is PRESERVED — it
    // never changes. The remaining 7 bits (the "mantissa") shift left.
    // The overflow flag (vf) fires when any bit shifted out of the
    // mantissa differs from the preserved sign bit.
    //
    // In other words: vf=1 means "the value couldn't be represented
    // correctly in the output because significant bits were lost."
    //
    // Four distinct scenarios:
    //   A — positive input (MSB=0), overflow:     bit 6 of x_in = 1
    //   B — positive input (MSB=0), no overflow:  bit 6 of x_in = 0
    //   C — negative input (MSB=1), overflow:     bit 6 of x_in = 0
    //   D — negative input (MSB=1), no overflow:  bit 6 of x_in = 1
    // =====================================================================

    // A: POSITIVE, OVERFLOW. x=0x40=0100_0000. MSB=0, bit6=1.
    //    Bit 6 (1) shifted out ≠ MSB (0) → vf=1
    //    y = (0x40<<1 & 0x7F) | (0x40 & 0x80) = (0x80 & 0x7F) | 0x00 = 0x00
    send(8'h40, 3'd1, 3'b101, "sla_pos_ovf");   // y=0x00, zf=1, vf=1

    // B: POSITIVE, NO OVERFLOW. x=0x3F=0011_1111. MSB=0, bit6=0.
    //    Bit 6 (0) shifted out = MSB (0) → vf=0
    //    y = (0x3F<<1 & 0x7F) | 0x00 = 0x7E & 0x7F = 0x7E
    send(8'h3F, 3'd1, 3'b101, "sla_pos_noovf"); // y=0x7E, zf=0, vf=0

    // C: NEGATIVE, OVERFLOW. x=0xBF=1011_1111. MSB=1, bit6=0.
    //    Bit 6 (0) shifted out ≠ MSB (1) → vf=1
    //    y = (0xBF<<1 & 0x7F) | (0xBF & 0x80) = 0x7E | 0x80 = 0xFE
    send(8'hBF, 3'd1, 3'b101, "sla_neg_ovf");   // y=0xFE, zf=0, vf=1

    // D: NEGATIVE, NO OVERFLOW. x=0xE0=1110_0000. MSB=1, bits 6 and 5 = "11".
    //    Shifted out bits (1,1) all equal MSB (1) → vf=0
    //    y = (0xE0<<2 & 0x7F) | (0xE0 & 0x80) = (0x80 & 0x7F) | 0x80 = 0x80
    send(8'hE0, 3'd2, 3'b101, "sla_neg_noovf"); // y=0x80, zf=0, vf=0

    // E: EXTREME — all mantissa bits shifted out. x=0x80=1000_0000, s=7.
    //    Bits 6:0 = 0000000; MSB = 1. None of the shifted-out bits match MSB → vf=1.
    //    y = (0x80<<7 & 0x7F) | (0x80 & 0x80) = 0x00 | 0x80 = 0x80 (sign preserved)
    send(8'h80, 3'd7, 3'b101, "sla_all_out");   // y=0x80, zf=0, vf=1

    // =====================================================================
    // GROUP 8 — ROL: Rotate Left (op=110)
    //
    // Bits shifted off the left end reappear at the right end.
    // Symmetric to ROR. Implementation: (x << s) | (x >> (-s))
    // =====================================================================

    // MSB wraps to LSB: 0x80 = 1000_0000 rotated left 1 = 0000_0001 = 0x01
    send(8'h80, 3'd1, 3'b110, "rol_msb_wrap");  // y=0x01

    // LSB climbs to MSB after 7 left rotations: 0x01 << 7 | 0x01 >> 1
    // -s_in for s=7: -7 in 3-bit = 1, so (0x01 << 7) | (0x01 >> 1) = 0x80 | 0x00 = 0x80
    send(8'h01, 3'd7, 3'b110, "rol_lsb_to_msb"); // y=0x80

  endtask : body

endclass: bshift_directed_edge_seq
