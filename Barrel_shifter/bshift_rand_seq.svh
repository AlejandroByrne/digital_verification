class bshift_rand_seq extends uvm_sequence #(bshift_txn);
  `uvm_object_utils(bshift_rand_seq)

  // How many random transactions to generate. The test sets this before
  // calling seq.start(). Default is 20 for quick smoke runs.
  int unsigned num_txns = 20;

  function new(string name = "bshift_rand_seq");
    super.new(name);
  endfunction: new

  task body();
    bshift_txn txn;

    repeat (num_txns) begin
      txn = bshift_txn::type_id::create("txn");
      start_item(txn);

      // ---------------------------------------------------------------
      // randomize() with { ... } adds inline constraints for this single
      // call only. They layer on top of any constraints already in the
      // transaction class (bshift_txn has none for this DUT, but the
      // pattern works regardless).
      //
      // op_in: not constrained here — all 8 encodings are valid operations
      // and we want uniform coverage across all of them. The 3-bit field
      // naturally produces each value with equal probability.
      // ---------------------------------------------------------------
      if (!txn.randomize() with {

        // ---------------------------------------------------------------
        // s_in distribution
        //
        // The notation:  value := weight
        //                [lo:hi] :/ weight
        //
        // := assigns that exact weight to EACH individual value listed.
        //    3'd0 := 20  means value 0 alone carries weight 20.
        //    3'd7 := 20  means value 7 alone carries weight 20.
        //
        // :/ DIVIDES the total weight ACROSS all values in the range.
        //    [3'd1:3'd6] :/ 60  means values 1,2,3,4,5,6 share 60 total.
        //    Each of those 6 values gets 60/6 = 10.
        //
        // Weight pool: 20 + 20 + 60 = 100 (convenient — reads as percent)
        //   s_in = 0    → 20% of transactions  (no shift at all)
        //   s_in = 7    → 20% of transactions  (maximum shift for 8-bit)
        //   s_in = 1..6 → 10% each             (middle values, equal share)
        //
        // Why bias toward 0 and 7?
        //   s_in=0: the output must equal the input for all shift ops,
        //           and no rotation should change bits.
        //   s_in=7: all data bits are shifted out for SLL/SRL,
        //           sign fills the whole register for SRA, and
        //           the bit that "wraps around" in ROR/ROL is the LSB/MSB.
        // ---------------------------------------------------------------
        s_in dist {
          3'd0        := 20,
          3'd7        := 20,
          [3'd1:3'd6] :/ 60
        };

        // ---------------------------------------------------------------
        // x_in distribution
        //
        // Same := vs :/ rules apply to an 8-bit field.
        //
        // Single interesting values get := (each carries its own weight):
        //   8'h00 := 10  →  0x00 alone = 10% of transactions
        //   8'hFF := 10  →  0xFF alone = 10%
        //   8'h80 := 10  →  0x80 alone = 10%
        //   8'h01 := 10  →  0x01 alone = 10%
        //
        // Ranges get :/ (weight split evenly across every value in range):
        //   [8'h02:8'h7F] :/ 35
        //     That range contains 0x7F - 0x02 + 1 = 126 values.
        //     Each of those 126 values gets 35/126 ≈ 0.28% probability.
        //     The whole range together = 35% of transactions.
        //
        //   [8'h81:8'hFE] :/ 25
        //     Also 126 values (0xFE - 0x81 + 1).
        //     Each gets 25/126 ≈ 0.20%. Whole range = 25%.
        //
        // Weight pool: 10+10+10+10+35+25 = 100
        //   0x00             → 10%   all zeros; zero flag must fire
        //   0xFF             → 10%   all ones; tests SRL zero-fill and SLA overflow
        //   0x80             → 10%   MSB set only; negative in signed ops (SRA, SLA)
        //   0x01             → 10%   LSB set only; stresses ROR/ROL wrap-around
        //   0x02..0x7F       → 35%   positive values (MSB clear), spread thin
        //   0x81..0xFE       → 25%   negative non-extreme values (MSB set), spread thin
        //
        // The four special values together consume 40% of runs even though
        // they are only 4 out of 256 possible values. This is the whole
        // point of distribution weighting: rare-but-important cases appear
        // often enough to actually stress the DUT.
        // ---------------------------------------------------------------
        x_in dist {
          8'h00          := 10,
          8'hFF          := 10,
          8'h80          := 10,
          8'h01          := 10,
          [8'h02:8'h7F] :/ 35,
          [8'h81:8'hFE] :/ 25
        };

      }) `uvm_fatal("BSHIFT_RAND_SEQ", "Randomization failed");

      finish_item(txn);
    end // repeat

  endtask: body

endclass: bshift_rand_seq
