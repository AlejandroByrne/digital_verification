// ============================================================
//  IEEE 754 Float32 Multiplier — Scoreboard
//
//  Contains a bit-accurate behavioral reference model that is
//  algorithmically independent from the structural RTL DUT.
//  Compares DUT result + flags against the reference on every
//  transaction received from the monitor.
//
//  For comprehensive cross-checking, also run the Python
//  golden model (golden_model.py --mult <a> <b> <rnd>).
// ============================================================

class fp32_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fp32_scoreboard)

    uvm_analysis_imp #(fp32_txn, fp32_scoreboard) analysis_export;

    int pass_count = 0;
    int fail_count = 0;

    function new(string name = "fp32_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_export = new("analysis_export", this);
    endfunction : build_phase

    // ────────────────────────────────────────────────────────
    //  write() — called by the monitor via analysis port
    // ────────────────────────────────────────────────────────
    function void write(fp32_txn txn);
        logic [31:0] exp_result;
        logic [4:0]  exp_flags;

        compute_expected(txn.a_in, txn.b_in, txn.rnd_mode, exp_result, exp_flags);

        if (txn.result === exp_result && txn.flags === exp_flags) begin
            pass_count++;
            `uvm_info("SB_PASS", $sformatf(
                "0x%08h × 0x%08h [rnd=%0d] → 0x%08h flags=%05b",
                txn.a_in, txn.b_in, txn.rnd_mode,
                txn.result, txn.flags), UVM_MEDIUM)
        end else begin
            fail_count++;
            `uvm_error("SB_FAIL", $sformatf(
                "\n  0x%08h × 0x%08h [rnd=%0d]\n  DUT: result=0x%08h flags=%05b\n  REF: result=0x%08h flags=%05b",
                txn.a_in, txn.b_in, txn.rnd_mode,
                txn.result, txn.flags,
                exp_result, exp_flags))
        end
    endfunction : write

    // ────────────────────────────────────────────────────────
    //  Behavioral reference model
    //  Same algorithm as golden_model.py, different coding style.
    // ────────────────────────────────────────────────────────
    function automatic void compute_expected(
        input  logic [31:0] a, b,
        input  logic [1:0]  rnd,
        output logic [31:0] exp_result,
        output logic [4:0]  exp_flags
    );
        // ── Field extraction ──
        logic        sa, sb, sr;
        logic [7:0]  ea, eb;
        logic [22:0] fa, fb;

        // ── Classification ──
        logic az, asub, ainf, asnan, aqnan, anan;
        logic bz, bsub, binf, bsnan, bqnan, bnan;

        // ── Pre-normalized mantissas ──
        logic [23:0] ma, mb;
        int          exa, exb;   // signed true exponents

        // ── Product ──
        logic [47:0] prod;
        int          esum;

        // ── Normalized ──
        logic [47:0] nprod;
        int          nexp;

        // ── Denormalization ──
        int          dshift;
        logic        dsticky;

        // ── Rounding ──
        logic        g, r, s, l, inx, do_rnd;
        logic [23:0] frac_rnd;
        int          rexp;

        // ── Leading-zero count ──
        int          lz;

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        //  Unpack
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        sa = a[31]; sb = b[31]; sr = sa ^ sb;
        ea = a[30:23]; eb = b[30:23];
        fa = a[22:0];  fb = b[22:0];

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        //  Classify
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        az   = (ea == 0) && (fa == 0);
        asub = (ea == 0) && (fa != 0);
        ainf = (ea == 8'hFF) && (fa == 0);
        asnan = (ea == 8'hFF) && (fa != 0) && !fa[22];
        aqnan = (ea == 8'hFF) && (fa != 0) &&  fa[22];
        anan  = asnan || aqnan;

        bz   = (eb == 0) && (fb == 0);
        bsub = (eb == 0) && (fb != 0);
        binf = (eb == 8'hFF) && (fb == 0);
        bsnan = (eb == 8'hFF) && (fb != 0) && !fb[22];
        bqnan = (eb == 8'hFF) && (fb != 0) &&  fb[22];
        bnan  = bsnan || bqnan;

        exp_flags = 5'h0;

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        //  Special cases
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        if (asnan || bsnan) begin
            exp_result = 32'h7FC00000;
            exp_flags  = 5'b10000;
            return;
        end
        if (anan || bnan) begin
            exp_result = 32'h7FC00000;
            return;
        end
        if ((ainf && bz) || (az && binf)) begin
            exp_result = 32'h7FC00000;
            exp_flags  = 5'b10000;
            return;
        end
        if (ainf || binf) begin
            exp_result = {sr, 8'hFF, 23'h0};
            return;
        end
        if (az || bz) begin
            exp_result = {sr, 31'h0};
            return;
        end

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        //  Pre-normalize subnormals
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        if (asub) begin
            lz = 22;
            for (int i = 22; i >= 0; i--)
                if (fa[i]) begin lz = 22 - i; break; end
            ma  = {1'b0, fa} << (lz + 1);
            exa = -lz;
        end else begin
            ma  = {1'b1, fa};
            exa = int'({1'b0, ea});
        end

        if (bsub) begin
            lz = 22;
            for (int i = 22; i >= 0; i--)
                if (fb[i]) begin lz = 22 - i; break; end
            mb  = {1'b0, fb} << (lz + 1);
            exb = -lz;
        end else begin
            mb  = {1'b1, fb};
            exb = int'({1'b0, eb});
        end

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        //  Multiply mantissas
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        prod = ma * mb;

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        //  Add exponents
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        esum = exa + exb - 127;

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        //  Normalize
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        if (prod[47]) begin
            nprod = prod;
            nexp  = esum + 1;
        end else begin
            nprod = prod << 1;
            nexp  = esum;
        end

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        //  Denormalize (if underflow)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        dsticky = 1'b0;
        if (nexp <= 0) begin
            dshift = 1 - nexp;
            if (dshift >= 48) begin
                nprod   = 48'h0;
                dsticky = 1'b1;
            end else begin
                for (int i = 0; i < dshift; i++)
                    dsticky = dsticky | nprod[i];
                nprod = nprod >> dshift;
            end
            nexp = 0;
        end

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        //  Extract G/R/S
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        g   = nprod[23];
        r   = nprod[22];
        s   = (|nprod[21:0]) | dsticky;
        l   = nprod[24];
        inx = g | r | s;

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        //  Rounding
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        case (rnd)
            2'b00:   do_rnd = g & (r | s | l);  // RNE
            2'b01:   do_rnd = 1'b0;              // RTZ
            2'b10:   do_rnd = sr & inx;           // RDN
            2'b11:   do_rnd = !sr & inx;          // RUP
            default: do_rnd = 1'b0;
        endcase

        frac_rnd = {1'b0, nprod[46:24]} + {23'h0, do_rnd};
        rexp     = nexp;
        if (frac_rnd[23]) begin
            rexp = nexp + 1;
        end

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        //  Final assembly
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        if (rexp >= 255) begin
            exp_flags = 5'b00101;  // OF + NX
            case (rnd)
                2'b01:   exp_result = {sr, 8'hFE, 23'h7FFFFF};
                2'b10:   exp_result = sr ? 32'hFF800000 : {1'b0, 8'hFE, 23'h7FFFFF};
                2'b11:   exp_result = sr ? {1'b1, 8'hFE, 23'h7FFFFF} : 32'h7F800000;
                default: exp_result = {sr, 8'hFF, 23'h0};
            endcase
        end else if (rexp <= 0) begin
            exp_result = {sr, 8'h00, frac_rnd[22:0]};
            exp_flags  = inx ? 5'b00011 : 5'b00000;  // UF + NX
        end else begin
            exp_result = {sr, rexp[7:0], frac_rnd[22:0]};
            exp_flags  = {4'b0000, inx};  // NX
        end

    endfunction : compute_expected

    // ────────────────────────────────────────────────────────
    //  Report — final pass/fail tally
    // ────────────────────────────────────────────────────────
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SB", $sformatf(
            "\n═══════════════════════════════════\n  SCOREBOARD: %0d PASS, %0d FAIL\n═══════════════════════════════════",
            pass_count, fail_count), UVM_LOW)
    endfunction : report_phase

endclass : fp32_scoreboard
