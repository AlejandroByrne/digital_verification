// ============================================================
//  FIFO — Transaction (Minimalist for xsim stability)
// ============================================================

class fifo_txn extends uvm_sequence_item;
    `uvm_object_utils(fifo_txn)

    rand logic [0:0]        wr_en;
    rand logic [7:0]        data_in;
    rand logic [0:0]        rd_en;
    rand int                delay; 

    logic [7:0]             data_out;
    logic                   is_empty;
    logic                   full;

    function new(string name = "fifo_txn");
        super.new(name);
    endfunction : new

    function string convert2string();
        return $sformatf("wr=%b rd=%b data_in=0x%h data_out=0x%h full=%b empty=%b delay=%0d", 
                         wr_en, rd_en, data_in, data_out, full, is_empty, delay);
    endfunction
endclass
