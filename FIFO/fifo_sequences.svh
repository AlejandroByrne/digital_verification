// ============================================================
//  FIFO — Consolidated Sequences (Minimalist)
// ============================================================

virtual class fifo_base_seq extends uvm_sequence #(fifo_txn);
    function new(string name = "fifo_base_seq");
        super.new(name);
    endfunction : new
endclass

class fifo_rand_seq extends fifo_base_seq;
    `uvm_object_utils(fifo_rand_seq)
    int num_items = 50;
    function new(string name = "fifo_rand_seq"); super.new(name); endfunction
    task body();
        repeat (num_items) begin
            req = fifo_txn::type_id::create("req");
            start_item(req);
            if (!req.randomize()) `uvm_error("SEQ", "Rand failed")
            // Manually constrain if needed
            req.delay = req.delay % 4; 
            finish_item(req);
        end
    endtask
endclass

class fifo_full_empty_seq extends fifo_base_seq;
    `uvm_object_utils(fifo_full_empty_seq)
    function new(string name = "fifo_full_empty_seq"); super.new(name); endfunction
    task body();
        repeat (16) begin
            req = fifo_txn::type_id::create("req");
            start_item(req);
            req.wr_en = 1; req.rd_en = 0; req.data_in = $urandom; req.delay = 0;
            finish_item(req);
        end
        repeat (16) begin
            req = fifo_txn::type_id::create("req");
            start_item(req);
            req.wr_en = 0; req.rd_en = 1; req.delay = 0;
            finish_item(req);
        end
    endtask
endclass

class fifo_error_seq extends fifo_base_seq;
    `uvm_object_utils(fifo_error_seq)
    function new(string name = "fifo_error_seq"); super.new(name); endfunction
    task body();
        // Underflow
        req = fifo_txn::type_id::create("req");
        start_item(req);
        req.wr_en = 0; req.rd_en = 1; req.delay = 0;
        finish_item(req);
        
        // Fill
        repeat (16) begin
            req = fifo_txn::type_id::create("req");
            start_item(req);
            req.wr_en = 1; req.rd_en = 0; req.data_in = $urandom; req.delay = 0;
            finish_item(req);
        end
        
        // Overflow
        req = fifo_txn::type_id::create("req");
        start_item(req);
        req.wr_en = 1; req.rd_en = 0; req.data_in = 8'hAA; req.delay = 0;
        finish_item(req);
    endtask
endclass
