class fp32_coverage extends uvm_subscriber #(fp32_txn);
    `uvm_component_utils(fp32_coverage)

    fp32_txn txn;

    typedef enum 

    covergroup cg_fp32 with function sample(rnd_mode_t rm, flags_t f);
        // Coverpoints
        cp_rnd_mode: coverpoint rm;

        cp_flags: coverpoint f {
            bins valid_flags[] = {[ZERO : SNAN]};
            illegal_bins invalid_flags = {6, 7};
        };

        cp_result: coverpoint txn.result {
            bins normal = {[32'h0000_0000 : 32'hFFFF_FFFF]
            } with(item[30:23] != 8'h00 && item[30:23] != 8'hFF);
            bins subnormal = {[32'h0000_0001 : 32'h007F_FFFF], // positive subnormals
                              [32'h8000_0001 : 32'h807F_FFFF] // negative subnormals
            } with (item[30:23] == 8'h00 && item[22:0] != 23'h0);
            bins zero = {32'h0000_0000, 32'h8000_0000}; // pos and neg zero
            bins NaN = {[32'h0000_0000 : 32'hFFFF_FFFF]
            } with (item[30:23] == 8'hFF && item[22:0] != 23'h0);
            bins qNan = {[32'h0000_0000 : 32'hFFFF_FFFF]
            } with (item[30:23] == 8'hFF && item[22] == 1'b0 && item[21:0] != 22'h0);
            bins sNan = {[32'h0000_0000 : 32'hFFFF_FFFF]
            } with (item[30:23] == 8'hFF && item[22] == 1'b1);
            bins infinity = {32'h7F80_0000, 32'hFF80_0000
            } with(item[22:0] == 23'h0 && item[30:23] == 8'hFF);
        }
    endgroup

    function void write(fp32_txn t);
        txn = t;
        cg_fp32.sample();
    endfunction

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass