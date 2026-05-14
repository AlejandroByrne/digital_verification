class dir_bin_seq extends uvm_sequence #(my_txn);
  `uvm_object_utils(dir_bin_seq)

    function new(string name="random_seq");
        super.new(name);
    endfunction //new()  

    task body();
        my_txn req;
        req = my_txn::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
        data inside {[0:63]};
        });
        finish_item(req);
    endtask
endclass
