class reset_seq extends uvm_sequence #(my_txn);
    `uvm_object_utils(reset_seq)
    `uvm_declare_p_sequencer(my_sequencer)

    function new(string name="reset_seq");
        super.new(name);
    endfunction //new()

    task body();
        `uvm_info("RESET_SEQ", "Taking grab ownership", UVM_MEDIUM)
        p_sequencer.grab(this);
        
        repeat(2) begin
            my_txn tx = my_txn::type_id::create("tx");
            start_item(tx);
            // tx.data = 8'h00;
            tx.rst = 1;
            finish_item(tx);
        end
        
        p_sequencer.ungrab(this);
        `uvm_info("RESET_SEQ", "Releasing grab", UVM_MEDIUM)
    endtask
endclass //reset_seq extends uvm_sequence