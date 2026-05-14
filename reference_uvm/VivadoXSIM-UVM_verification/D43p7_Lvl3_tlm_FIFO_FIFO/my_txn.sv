`include "uvm_macros.svh"
import uvm_pkg::*;

class my_txn extends uvm_sequence_item;
    `uvm_object_utils_begin(my_txn)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(write, UVM_ALL_ON)
    `uvm_object_utils_end

    rand bit [7:0] data;
    rand bit write;
    rand bit rst;

    bit accepted;    

    constraint c_valid {
        write dist {0:=1, 1:=3};
    }

    function new(string name="my_txn");
        super.new(name);
    endfunction //new()

    // function void copy(uvm_object rhs);
    //     my_txn t;
    //     if (!$cast(t, rhs)) begin
    //     `uvm_fatal("COPY", "Cannot cast rhs to my_txn")
    //     end
    //     this.data = t.data;
    // endfunction

    // function uvm_object clone();
    //     my_txn t = my_txn::type_id::create("t");
    //     t.copy(this);
    //     return t;
    // endfunction

endclass //my_txn extends uvm_sequence__item