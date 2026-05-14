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


    // DFF Interface
interface dff_if (input logic clk);
    // all DUT signals
    logic rst;
    logic en;
    logic d;
    logic q;    

    // Clocking Block (MOST IMPORTANT PART)
    clocking cb @(posedge clk);
        default input #1step output #0;

        output en;
        output d;
        input q;              

    endclocking

    modport DUT (
        input  clk, rst, en, d,
        output q
    );

    modport TB (
        clocking cb,
        output rst
    );

    // All assertions   
    property hold_when_en_low;
        @(cb) disable iff (rst)
        !cb.en |-> (cb.q == $past(cb.q));
    endproperty

    assert property (hold_when_en_low);

endinterface

module tb_dff;
    logic clk;
    logic exp_q;
    dff_if dif(clk);

    dff_txn txn = new();


    // DUT instance
    d_ff dut (
        // .rst(dif.rst),
        // .clk(dif.clk),
        // .en(dif.en),
        // .d(dif.d),
        // .q(dif.q)
        dif.DUT
    );

    // ==================================================
    // Task-1: Clock & Reset
    // ==================================================
    
    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Resetvvvvv
    initial begin
        dif.rst <= 1;
        repeat (2) @(dif.cb);
        dif.rst <= 0;
    end



    // ==================================================
    // Task-2: Stimulus Task
    // ==================================================
    // task drive_ip(
    //     input logic en_i,
    //     input logic d_i
    // );
    //     en = en_i;
    //     d = d_i;
    //     @(posedge clk);   // consume time properly
    // endtask //
    task drive_ip(bit en_i, bit d_i);
        dif.cb.en <= en_i;
        dif.cb.d  <= d_i;
        @(dif.cb);
    endtask
    // ==================================================
    // Task-3: Checker Task
    // ==================================================   


    task check(
        input string msg
    );
        // if (q !== exp_q)
        //     $error("Failed, %s, expected = %0b, actual = %0b", msg, exp_q, q);

        if (dif.cb.q !== exp_q)
            $error("Mismatch , %s, expected = %0b, actual = %0b", msg, exp_q, dif.cb.q);
        else
            $display("Passed, %s, q = %0b", msg, dif.cb.q);    
    endtask // 

    // ==================================================
    // Reference Model (Golden Behavior) always add Reference model to 
    // ==================================================
    always @(posedge dif.clk or posedge dif.rst) begin
        if (dif.rst)
            exp_q <= 0;
        else if (dif.en)
            exp_q <= dif.cb.d;
    end

    // // =================================================
    // // Assertion #1 — Reset Behavior : When reset is high, q must be 0
    // // =================================================
    // property reset_clears_q;
    //     @(posedge clk)
    //     rst |-> (q == 0);
    // endproperty

    // // =================================================
    // // Assertion #2 — Capture on Enable : If enable is high, q must capture d
    // // =================================================
    // property capture_when_en;
    //     @(posedge clk) 
    //     (!rst && en) |-> (q ==d);
    // endproperty

    // // =================================================
    // // Assertion #3 — Hold When Disabled (VERY IMPORTANT) : If enable is low, q must not change
    // // =================================================
    // property hold_when_en_low;
    //     @(posedge clk) 
    //     (!rst && !en) |-> (q == $past(q));
    // endproperty

    // // =================================================
    // assert property (reset_clears_q)
    //     else $error("Reset failed to clear q");
            
    // assert property (capture_when_en)
    //     else $error("Capture failed");

    // assert property (hold_when_en_low)
    //     else $error("Hold violation");


    // =================================================
    covergroup dff_cg @(posedge dif.clk iff !dif.rst);     
    // iff not reset Avoids sampling during reset
    //               Prevents meaningless bins during reset cycles
        coverpoint dif.cb.en {
            bins en_0 = {0};
            bins en_1 = {1};
            // Transition Coverage on en
            bins en_toggle = (0 => 1 => 0);   //Did enable assert and later deassert?            
        }

        coverpoint dif.cb.d {
            bins d_0 = {0};
            bins d_1 = {1};
            // Transition Coverage on d    
            bins d_toggle[] = (0 => 1), (1 => 0);    //Ensures data is not stuck
        }

        // Transition coverage with condition
        // coverpoint d iff (en) {
        //     bins capture_toggle[] = (0 => 1), (1 => 0);  //Count data transitions only when enable is active
        // }

        cross dif.en, dif.d {
            // illegal bin - illegal case never generated
            illegal_bins illegal_idle = binsof(dif.en) intersect {0} && binsof(dif.d) intersect {1};
            // Idle case → allowed but ignored
            ignore_bins idle_case = binsof(dif.en) intersect {0} && binsof(dif.d)  intersect {0};
        }

    endgroup

    dff_cg cg = new();


    // ==================================================
    // Task-4
    // ==================================================

    initial begin
        @(negedge dif.rst);

            // Stimulus thread
        repeat (20) begin
            assert(txn.randomize());
            //Drive before clock
            drive_ip(txn.en, txn.d);
            

            // Checker thread
            
            @(posedge dif.clk);
            check("Dff check");

        end

        $display("Test completed");
        #10 $finish;
    end
    
endmodule