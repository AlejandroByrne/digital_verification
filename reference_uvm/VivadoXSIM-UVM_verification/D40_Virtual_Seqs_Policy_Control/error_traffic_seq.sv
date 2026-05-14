class error_traffic_seq extends sanity_traffic_seq;
    `uvm_object_utils(error_traffic_seq)

    function new(string name="error_traffic_seq");
        super.new(name);
    endfunction //new()

    task body();
        `uvm_info("ERROR_SEQ", "Error traffic running", UVM_LOW)
        repeat(3) begin
            my_txn tx = my_txn::type_id::create("tx");
            start_item(tx);
            tx.data = 8'hFF;    // illegal / Corner case
            finish_item(tx);
        end
    endtask
endclass //error_traffic_seq extends sanity_traffic_seq