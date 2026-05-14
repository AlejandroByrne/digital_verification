class sanity_traffic_seq extends uvm_sequence #(my_txn);
    `uvm_object_utils(sanity_traffic_seq)

    function new(string name="sanity_traffic_seq");
        super.new(name);
    endfunction //new()

    task body();
        `uvm_info("SANITY_SEQ", "Sanity traffic running", UVM_MEDIUM)

        repeat(5) begin
            my_txn tx = my_txn::type_id::create("tx");
            start_item(tx);
            tx.randomize() with { data inside {[8'h10:8'h1F]};};
            finish_item(tx); 
        end
    endtask
endclass //sanity_traffic_seq extends uvm_sequence #(my_txn)