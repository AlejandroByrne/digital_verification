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


    // =================================================
    covergroup dff_cg @(posedge clk iff !rst);     
    // iff not reset Avoids sampling during reset
    //               Prevents meaningless bins during reset cycles
        coverpoint en {
            bins en_0 = {0};
            bins en_1 = {1};
            // Transition Coverage on en
            bins en_toggle = (0 => 1 => 0);   //Did enable assert and later deassert?            
        }

        coverpoint d {
            bins d_0 = {0};
            bins d_1 = {1};
            // Transition Coverage on d    
            bins d_toggle[] = (0 => 1), (1 => 0);    //Ensures data is not stuck
        }

        // Transition coverage with condition
        // coverpoint d iff (en) {
        //     bins capture_toggle[] = (0 => 1), (1 => 0);  //Count data transitions only when enable is active
        // }

        cross en, d {
            // illegal bin - illegal case never generated
            illegal_bins illegal_idle = binsof(en) intersect {0} && binsof(d) intersect {1};
            // Idle case → allowed but ignored
            ignore_bins idle_case = binsof(en) intersect {0} && binsof(d)  intersect {0};
        }

    endgroup

    dff_cg cg = new();


    // ==================================================
    // Task-4: Parallel Execution (fork…join)
    // ==================================================

    initial begin
        @(negedge rst);

            // Stimulus thread
        repeat (20) begin
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