// A2_1_class_basics.sv
// Phase A2.1 – Classes & Objects

class packet;

    // Data members
    rand bit [7:0] data;
    rand bit       valid;

    // Method inside class
    function void display();
        $display("PACKET :: data = 0x%0h , valid = %0b", data, valid);
    endfunction

endclass


module tb_class_basics;

    packet pkt;   // class handle (NOT object yet)

    initial begin
        // Create object
        pkt = new();

        // Randomize object
        if (!pkt.randomize())
            $fatal("Randomization failed");

        // Call class method
        pkt.display();

        #10;
        $finish;
    end

endmodule
