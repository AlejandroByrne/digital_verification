// Base class (method MUST be virtual)
class packet;
    rand bit [7:0] data;

    virtual function void display();
        $display("[base] data =%0h ", data);
        
    endfunction
    
endclass

// Child class (override)
class error_packet extends packet;
    rand bit parity;
    
    function void display();
        $display("Data = %0h, Parity = %0b", data, parity);
    endfunction //display()
endclass //error_packet extends packet

module tb;
    packet p;
    error_packet ep;

    initial begin
        ep = new();
        p = ep;

        assert (p.randomize()); 
        p.display();

        #10 $finish;
    end
    
endmodule