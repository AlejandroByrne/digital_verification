class packet;
    rand bit [7:0] data;
    rand bit       valid;

    // Constructor
    function new(bit [7:0] d = 8'h00, bit v = 0);
        data  = d;
        valid = v;
        $display("[NEW] Constructor called: data=%0h valid=%0b", data, valid);
    endfunction

    function void display();
        $display("[PKT] data=%0h valid=%0b", data, valid);
    endfunction
endclass


module tb;
    packet p1, p2;

    initial begin
        // Object with default constructor args
        p1 = new();
        p1.display();

        // Object with custom constructor args
        p2 = new(8'hAA, 1);
        p2.display();

        // Randomize AFTER construction
        assert(p2.randomize());
        p2.display();

        #10 $finish;
    end
endmodule
