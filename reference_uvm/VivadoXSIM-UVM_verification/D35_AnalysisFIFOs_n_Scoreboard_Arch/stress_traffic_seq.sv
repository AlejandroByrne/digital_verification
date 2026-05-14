class stress_traffic_seq extends uvm_sequence #(my_txn);
    `uvm_object_utils(stress_traffic_seq);

    function new(string name="stress_traffic_seq");
        super.new(name);
    endfunction //new()

    task body();
        `uvm_info("STRESS_SEQ", "Stress traffic running", UVM_MEDIUM)

        repeat(50) begin
            my_txn tx = my_txn::type_id::create("tx");
            start_item(tx);
            tx.randomize();
            finish_item(tx);
        end
    endtask
endclass //stress_traffic_seq extends uvm_sequence