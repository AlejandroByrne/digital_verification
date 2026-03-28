class sa_random_sequence extends uvm_sequence #(sa_txn);
  `uvm_object_utils(sa_random_sequence)

  int unsigned num_txn = 100;

  function new(string name = "sa_random_sequence");
    super.new(name);
  endfunction : new

  task body();
    sa_txn txn;

    for (int i = 0; i < num_txn; i++) begin
      txn = sa_txn::type_id::create($sformatf("txn_%0d", i));
      start_item(txn);
        // Constrained random: bias toward edge cases that trigger overflow/underflow.
        // Max positive = (2^(W-1))-1, max negative = 2^(W-1) (unsigned encoding)
        assert(txn.randomize() with {
          a_in dist { ((1 << (SA_WIDTH-1)) - 1) := 20,  // max positive
                      (1 << (SA_WIDTH-1))        := 20,  // max negative
                      [0 : (1 << SA_WIDTH) - 1]  := 60 };
          b_in dist { ((1 << (SA_WIDTH-1)) - 1) := 20,
                      (1 << (SA_WIDTH-1))        := 20,
                      [0 : (1 << SA_WIDTH) - 1]  := 60 };
        });
      finish_item(txn);
    end
  endtask : body
endclass : sa_random_sequence
