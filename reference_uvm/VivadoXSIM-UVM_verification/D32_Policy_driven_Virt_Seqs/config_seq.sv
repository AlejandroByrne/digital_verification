class config_seq extends uvm_sequence #(my_txn);
    `uvm_object_utils(config_seq)
    // `uvm_declare_p_sequencer(my_sequencer)

    function new(string name="config_seq");
        super.new(name);
    endfunction //new()

    task body();
        `uvm_info("CFG_SEQ", "Starting config layer", UVM_MEDIUM)
        // p_sequencer.lock(this);

        repeat(2) begin
            my_txn tx = my_txn::type_id::create("tx");
            start_item(tx);
            tx.data = 8'hA5;
            finish_item(tx);
        end

        // p_sequencer.unlock(this);
        `uvm_info("CFG_SEQ", "Config done", UVM_MEDIUM)
    endtask
endclass //confiq_seq extends uvm_sequence #(my_txn)