class urgent_seq extends uvm_sequence #(my_txn);
    `uvm_object_utils(urgent_seq)
    `uvm_declare_p_sequencer(my_sequencer)
    
    function new(string name="urgent_seq");
        super.new(name);
    endfunction //new()

    task body();
        my_txn tx;   // ✅ declaration at top

        `uvm_info("URGENT", "Attempting preempt", UVM_MEDIUM)

        repeat(2) begin
            tx = my_txn::type_id::create("tx");
            
            start_item(tx);
            tx.data = 8'hFF;
            finish_item(tx);
        end
        `uvm_info("URGENT", "Urgent finished", UVM_MEDIUM)

    endtask
endclass //urgent_seq extends uvm_sequence