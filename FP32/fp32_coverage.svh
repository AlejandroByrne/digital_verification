// ============================================================
//  IEEE 754 Float32 Multiplier — Coverage Collector
//
//  Tracks functional coverage for operands, rounding modes,
//  exception flags, and their cross-products.
// ============================================================

class fp32_coverage extends uvm_subscriber #(fp32_txn);
    `uvm_component_utils(fp32_coverage)

    fp32_txn txn;

    covergroup cg_fp32;
        option.per_instance = 1;
        option.name = "cg_fp32";

        // ── Stimulus ──
        cp_rnd_mode: coverpoint txn.rnd_mode {
            bins modes[] = {0, 1, 2, 3};
        }

        cp_a_class: coverpoint classify_fp32(txn.a_in) {
            bins classes[] = {FP_ZERO, FP_SUBNORMAL, FP_NORMAL, FP_INFINITY, FP_QNAN, FP_SNAN};
        }
        cp_b_class: coverpoint classify_fp32(txn.b_in) {
            bins classes[] = {FP_ZERO, FP_SUBNORMAL, FP_NORMAL, FP_INFINITY, FP_QNAN, FP_SNAN};
        }

        cp_a_sign: coverpoint txn.a_in[31] {
            bins pos = {0};
            bins neg = {1};
        }
        cp_b_sign: coverpoint txn.b_in[31] {
            bins pos = {0};
            bins neg = {1};
        }

        // ── Results ──
        cp_res_class: coverpoint classify_fp32(txn.result) {
            bins classes[] = {FP_ZERO, FP_SUBNORMAL, FP_NORMAL, FP_INFINITY, FP_QNAN, FP_SNAN};
        }
        cp_res_sign: coverpoint txn.result[31] {
            bins pos = {0};
            bins neg = {1};
        }

        // ── Flags (Individual and Combinations) ──
        cp_flag_nv: coverpoint txn.flags[4] { bins hit = {1}; }
        cp_flag_dz: coverpoint txn.flags[3] { bins hit = {1}; }
        cp_flag_of: coverpoint txn.flags[2] { bins hit = {1}; }
        cp_flag_uf: coverpoint txn.flags[1] { bins hit = {1}; }
        cp_flag_nx: coverpoint txn.flags[0] { bins hit = {1}; }

        // ── Cross Products ──
        cross_op_classes: cross cp_a_class, cp_b_class;
        cross_signs:      cross cp_a_sign, cp_b_sign;
        cross_rnd_flags:  cross cp_rnd_mode, cp_flag_nx, cp_flag_of, cp_flag_uf;

    endgroup : cg_fp32

    function new(string name = "fp32_coverage", uvm_component parent = null);
        super.new(name, parent);
        cg_fp32 = new();
    endgroup : new

    function void write(fp32_txn t);
        this.txn = t;
        cg_fp32.sample();
    endfunction : write

endclass : fp32_coverage
