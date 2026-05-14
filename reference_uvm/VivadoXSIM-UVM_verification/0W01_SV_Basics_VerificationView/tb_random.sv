class pkt;
    // rand bit [7:0] data[4];
    // rand int addr;
    rand bit en;
/*    
    constraint addr_c {
        // // inside with set
        // addr inside {0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20};
        // inside with Range
        addr inside {[0:4], [15:19]};
    } 
*/
    constraint en_dist {
        // dist is probabilistic, not exact.
        en dist {0 := 20, 1:= 80};
    }    

endclass

module tb_random;
    pkt p = new();
    int zeros = 0, ones = 0;

    initial begin
        
        // p.randomize();

        // `foreach` on array
        // foreach (p.data[i]) begin
        //     $display("data[%0d] = %0d", i, p.data[i]);
        // end

/*
        repeat (10) begin
            assert (p.randomize()); 
            $display("address = %0d", p.addr);
        end
*/       
        repeat (100) begin
            assert(p.randomize());
            if (p.en) ones++;
            else zeros++;
        end

        $display("Count(en=0)= %0d__Count(en=1)= %0d", zeros, ones);

        $finish;
    end
    
endmodule