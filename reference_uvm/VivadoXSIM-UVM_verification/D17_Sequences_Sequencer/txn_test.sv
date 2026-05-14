module txn_test;
    import uvm_pkg::*;

    initial begin
        my_txn t1, t2;

        t1 = my_txn::type_id::create("t1");
        t2 = my_txn::type_id::create("t2");

        t1.print(); 
        t2.print(); 

        assert (t1.randomize()); 
        t1.print();             // Print (Debugging)
        t2.copy(t1);
        t2.print();  

        $display("Comaparision: %0b", t1.compare(t2));    // Compare (Checking)   1 → MATCH ✅ 0 → MISMATCH ❌

    end
endmodule