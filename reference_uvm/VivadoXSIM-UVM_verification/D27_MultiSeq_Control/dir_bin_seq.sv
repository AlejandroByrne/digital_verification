class dir_bin_seq extends uvm_sequence #(my_txn);
  `uvm_object_utils(dir_bin_seq)

    function new(string name="random_seq");
        super.new(name);
    endfunction //new()  

    virtual task pre_body();
        `uvm_info("SEQ_Dir", "pre_body: Directed Sequence starting", UVM_MEDIUM)
    endtask

    task body();
        my_txn req;
        req = my_txn::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
        data inside {[0:63]};
        });
        finish_item(req);
    endtask

    virtual task post_body();
        `uvm_info("SEQ_Dir", "post_body: Directed Sequence completed", UVM_MEDIUM)
    endtask

endclass
