class fa_random_sequence extends uvm_sequence #(fa_txn);
  `uvm_object_utils(fa_random_sequence)

  int unsigned num_txn = 20;

  function new(string name = "fa_random_sequence");
    super.new(name);
  endfunction : new

  task body();
    fa_txn txn;

    for (int i = 0; i < num_txn; i++) begin
      txn = fa_txn::type_id::create($sformatf("txn_%0d", i));
      start_item(txn); // blocks until driver calls seq_item_port.get_next_item()
        // in here I am allowed to edit transactions, constrained-randomness, etc.
        assert(txn.randomize());
        // Weighted randomization:
        // assert(txn.randomize() with {
        //   a_in dist {0 := 30, 1 := 70 };
        // });
      finish_item(txn); // blocks until driver calls seq_item_port.item_done()
    end
  endtask : body
endclass : fa_random_sequence
