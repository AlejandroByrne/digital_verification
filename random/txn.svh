class some_txn extends uvm_sequence_item;
    `uvm_object_utils(some_txn)

    rand logic [15:0] addr;
    rand logic [31:0] data;
    rand logic [1:0] op;

    constraint addr_aligned {
        addr[1:0] == 2'b00;
    }

    constraint valid_op {
        op inside {0, 1, 2};
    }

    constraint write_nonzero {
        (op == 1) -> (data != 32'h0);
    }

    function new(string name="some_txn");
        super.new(name);
    endfunction
    
endclass : some_txn