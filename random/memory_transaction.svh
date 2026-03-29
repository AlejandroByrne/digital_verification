class memory_transaction extends uvm_sequence_item;
    `uvm_object_utils(memory_transaction)

    rand logic [7:0] src_addr;
    rand logic [7:0] dst_addr;
    rand logic [3:0] length;

    constraint src_dst_not_equal {
        src_addr != dst_addr;
    }

    constraint length_non_zero {
        length inside {[1:8]};
    }

    constraint boundary_256 {
        // length max 15
        // src_addr max 255
        (src_addr + length) <= 256;
    }

    function new(string name="memory_transaction");
        super.new(name);
    endfunction
endclass