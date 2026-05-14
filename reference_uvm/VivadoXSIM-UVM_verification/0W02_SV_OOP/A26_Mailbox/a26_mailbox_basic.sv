class packet;
    rand byte data;

    function void display(string tag="");
        $display("[%s] payload.data = %0h", tag, data);
    endfunction
endclass



module tb ();
    // mailbox : transaction pipe
    mailbox #(packet) mbx;

    task producer(); // Producer Task
        packet pkt;
        repeat(5) begin
            pkt = new();
            assert(pkt.randomize());
            pkt.display("PRODUCER");
            mbx.put(pkt);           // BLOCKS if mailbox full
            #10;
        end
    endtask

    task consumer();  // Consumer Task
        packet pkt;
        repeat(5) begin
            mbx.get(pkt);       // BLOCKS if mailbox empty
            pkt.display("CONSUMER");

        end
    endtask
    
    initial begin
        mbx = new();


        fork
            producer();
            consumer();
        join

        #10 $finish;
    end

endmodule