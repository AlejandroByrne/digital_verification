// ==========================================================
// Transaction
// ==========================================================
class dff_txn;
    rand bit en;
    rand bit d;

    constraint valid_c {
        if (en == 0) d == 0;
    }

    function void post_randomize();
        $display("[TXN] en=%0b d=%0b", en, d);
    endfunction
endclass


// ==========================================================
// Interface with Clocking Block + Assertions
// ==========================================================
interface dff_if (input logic clk);
    logic rst;
    logic en;
    logic d;
    logic q;

    // Clocking Block
    clocking cb @(posedge clk);
        default input #1step output #0;
        output en;
        output d;
        input  q;
    endclocking

    // Modports
    modport DUT (input clk, rst, en, d, output q);
    modport TB  (clocking cb, output rst);

    // Assertion: Hold when enable is low
    property hold_when_en_low;
        @(cb) disable iff (rst)
        !cb.en |-> (cb.q == $past(cb.q));
    endproperty

    assert property (hold_when_en_low)
        else $error("ASSERTION FAILED: Hold violation");
endinterface


// ==========================================================
// Testbench
// ==========================================================
module tb_dff;
    logic clk;
    logic exp_q;

    dff_if dif(clk);
    dff_txn txn = new();

    // DUT
    d_ff dut (dif.DUT);

    // ------------------------------------------------------
    // Clock Generation
    // ------------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // ------------------------------------------------------
    // Reset (synchronous style for TB)
    // ------------------------------------------------------
    initial begin
        dif.rst <= 1;
        repeat (2) @(dif.cb);
        dif.rst <= 0;
    end

    // ------------------------------------------------------
    // Driver
    // ------------------------------------------------------
    task drive_ip(bit en_i, bit d_i);
        dif.cb.en <= en_i;
        dif.cb.d  <= d_i;
        @(dif.cb);
    endtask

    // ------------------------------------------------------
    // Reference Model (Golden Model)
    // ------------------------------------------------------
    always @(posedge dif.clk or posedge dif.rst) begin
        if (dif.rst)
            exp_q <= 0;
        else if (dif.cb.en)
            exp_q <= dif.cb.d;
    end

    // ------------------------------------------------------
    // Checker
    // ------------------------------------------------------
    task check(string msg);
        if (dif.cb.q !== exp_q)
            $error("FAIL: %s | exp=%0b act=%0b", msg, exp_q, dif.cb.q);
        else
            $display("PASS: %s | q=%0b", msg, dif.cb.q);
    endtask

    // ------------------------------------------------------
    // Functional Coverage
    // ------------------------------------------------------
    covergroup dff_cg @(posedge dif.clk iff !dif.rst);
        coverpoint dif.cb.en {
            bins en_0 = {0};
            bins en_1 = {1};
            bins en_toggle = (0 => 1 => 0);
        }

        coverpoint dif.cb.d {
            bins d_0 = {0};
            bins d_1 = {1};
            bins d_toggle[] = (0 => 1), (1 => 0);
        }

        cross dif.cb.en, dif.cb.d {
            illegal_bins illegal_idle =
                binsof(dif.cb.en) intersect {0} &&
                binsof(dif.cb.d)  intersect {1};

            ignore_bins idle_case =
                binsof(dif.cb.en) intersect {0} &&
                binsof(dif.cb.d)  intersect {0};
        }
    endgroup

    dff_cg cg = new();

    // ------------------------------------------------------
    // Test Sequence
    // ------------------------------------------------------
    initial begin
        @(negedge dif.rst);

        repeat (20) begin
            assert(txn.randomize());
            drive_ip(txn.en, txn.d);
            @(posedge dif.clk);
            check("DFF functional check");
        end

        $display("TEST COMPLETED");
        #10 $finish;
    end
endmodule
