class traffic_seq extends uvm_sequence #(my_txn);
    `uvm_object_utils(traffic_seq)

    function new(string name="traffic_seq");
        super.new(name);
    endfunction //new()

    task body();
        `uvm_info("TRFC_SEQ", "Starting traffic layer", UVM_MEDIUM)

        repeat(5) begin
            my_txn tx = my_txn::type_id::create("tx");
            start_item(tx);
            assert(tx.randomize());
            finish_item(tx);
        end

        `uvm_info("TRFC_SEQ", "Traffic done", UVM_MEDIUM)
    endtask
endclass //traffic_seq extends uvm_sequence