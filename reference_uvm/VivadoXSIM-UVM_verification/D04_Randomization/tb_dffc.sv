class dff_txn;
    rand bit en;
    rand bit d;
    
    constraint valid_c {
        if (en == 0) d == 0;
    }

    function void post_randomize();
        $display("[TXN] en=%0b d=%0b", en, d);
    endfunction

endclass //txn

module tb_dff;
    // all DUT signals
    logic rst;
    logic clk;
    logic en;
    logic d;
    logic q;

    logic exp_q;

    dff_txn txn = new();

    // DUT instance
    d_ff dut (
        .rst(rst),
        .clk(clk),
        .en(en),
        .d(d),
        .q(q)
    );

    // ==================================================
    // Task-1: Clock & Reset
    // ==================================================
    
    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Resetvvvvv
    initial begin
        rst = 1;
        en = 0;
        d = 0;
        exp_q = 0;
        #20 rst = 0;
    end

    // ==================================================
    // Task-2: Stimulus Task
    // ==================================================
    task drive_ip(
        input logic en_i,
        input logic d_i
    );
        en = en_i;
        d = d_i;
        @(posedge clk);   // consume time properly
    endtask //

    // ==================================================
    // Task-3: Checker Task
    // ==================================================   

    task check(
        input string msg
    );
        if (q !== exp_q)
            $error("Failed, %s, expected = %0b, actual = %0b", msg, exp_q, q);
        else
            $display("Passed, %s, q = %0b", msg, q);
    endtask // 

    // ==================================================
    // Reference Model (Golden Behavior) always add Reference model to 
    // ==================================================
    always @(posedge clk or posedge rst) begin
        if (rst)
            exp_q <= 0;
        else if (en)
            exp_q <= d;
    end

    // ==================================================
    // Task-4: Parallel Execution (fork…join)
    // ==================================================

    initial begin
        @(negedge rst);

            // Stimulus thread
        repeat (10) begin
            assert(txn.randomize());
            //Drive before clock
            drive_ip(txn.en, txn.d);
            

            // Checker thread
            
            @(posedge clk);
            check("Dff check");

        end

        $display("Test completed");
        #10 $finish;
    end
    
endmodule