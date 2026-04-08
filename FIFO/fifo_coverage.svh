// ============================================================
//  FIFO — Coverage Collector (Non-parameterized)
// ============================================================

class fifo_coverage extends uvm_subscriber #(fifo_txn);
    `uvm_component_utils(fifo_coverage)

    fifo_txn txn;

    covergroup cg_fifo;
        option.per_instance = 1;
        option.name = "cg_fifo";
        cp_wr: coverpoint txn.wr_en { bins hit = {1}; }
        cp_rd: coverpoint txn.rd_en { bins hit = {1}; }
        cross_rw: cross cp_wr, cp_rd;
        cp_full:  coverpoint txn.full     { bins hit = {1}; }
        cp_empty: coverpoint txn.is_empty { bins hit = {1}; }
        cp_full_trans: coverpoint txn.full {
            bins going_full = (0 => 1);
            bins leaving_full = (1 => 0);
        }
        cp_empty_trans: coverpoint txn.is_empty {
            bins going_empty = (0 => 1);
            bins leaving_empty = (1 => 0);
        }
        cp_data_in: coverpoint txn.data_in {
            bins all_zeros = {8'h00};
            bins all_ones  = {8'hFF};
            bins walking_ones[] = {1, 2, 4, 8, 16, 32, 64, 128};
        }
    endgroup : cg_fifo

    function new(string name = "fifo_coverage", uvm_component parent = null);
        super.new(name, parent);
        cg_fifo = new();
    endfunction : new

    function void write(fifo_txn t);
        this.txn = t;
        cg_fifo.sample();
    endfunction : write
endclass
