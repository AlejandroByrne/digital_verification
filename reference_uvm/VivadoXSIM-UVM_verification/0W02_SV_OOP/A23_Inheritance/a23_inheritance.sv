// base class
class packet;
    rand bit [7:0] data;
    rand bit valid;

    function void display();
        $display("[Base] Data=%0h, Valid=%0b", data, valid);
        
    endfunction
endclass

// child class
class error_packet extends packet;
    rand bit parity;

    function void display();
        $display("[Child] Data=%0h, Valid=%0b, Parity=%0b", data, valid, parity);
    endfunction

endclass //error_packet extends packet

module tb ();
    packet p;
    error_packet ep;

    initial begin
        p = new();
        ep = new();

        assert (p.randomize()); 
        assert (ep.randomize()); 

        p.display();
        ep.display();

        #10 $finish;

    end
    
endmodule