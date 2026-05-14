class playload;
    rand byte data;

    function display();
        $display("playload.data = %0h", data);
    endfunction //display()
endclass //playload

class packet;
    rand bit valid;
    playload pld;

    function new();
        pld = new();
    endfunction

    // ✅ DEEP COPY METHOD — MUST BE INSIDE CLASS
    function void copy(packet rhs);
        this.valid = rhs.valid;
        this.pld.data = rhs.pld.data;  // deep copy payload
    endfunction

    function void display;
        $display("packet.valid = %0b", valid);
        pld.display();

    endfunction

endclass //packet

module tb ();
    packet p1, p2;

    initial begin
        p1 = new(); 
        p2 = new();

        assert(p1.randomize()); 
        // p2 = p1;    // Shallow Copy: handle copied
        p2.copy(p1);   // ✅ DEEP COPY

        $display("Before Modification:------");
        p1.display();
        p2.display();

        p2.pld.data = 8'hAA;

        $display("After Modification:------");
        p1.display();
        p2.display();
        #10 $finish;

    end

endmodule