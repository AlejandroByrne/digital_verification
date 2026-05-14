class confiq_seq extends uvm_sequence #(my_txn);
    `uvm_object_utils(confiq_seq)
    `uvm_declare_p_sequencer(my_sequencer)

    function new(string name="confiq_seq");
        super.new(name);
    endfunction //new()

    task body();
        `uvm_info("CFG", "Waiting for lock", UVM_MEDIUM)
        p_sequencer.lock(this);

        repeat(2) begin
            my_txn tx = my_txn::type_id::create("tx");
            start_item(tx);
            tx.data = 8'hA5;
            finish_item(tx);
        end

        p_sequencer.unlock(this);
        `uvm_info("CFG", "Released lock", UVM_MEDIUM)
    endtask
endclass //confiq_seq extends uvm_sequence #(my_txn)