class dff_txn;
    rand bit en;
    rand bit d;
    bit q;

    constraint valid_c {
        en dist {0 := 3, 1 := 7};   // bias towards en=1
        if (en)
            d dist {0 := 4, 1 := 6};  // force toggling
        else
            d == 0;
    }

    function void display(string tag="TXN");
        $display("[%s] en=%0b d=%0b q=%0b", tag, en, d, q);
    endfunction

endclass //txn

    // DFF Interface
interface dff_if (input logic clk);
    // all DUT signals
    logic rst;
    logic en;
    logic d;
    logic q;    

    // Driver clocking block
    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        output en;
        output d;
        input  q;
    endclocking

    // Monitor clocking block
    clocking mon_cb @(posedge clk);
        default input #1step output #0;
        input en;
        input d;
        input q;
    endclocking

    modport TB(clocking drv_cb, input clk);
    modport DUT(input  clk, rst, en, d, output q);

    // All assertions   
    property hold_when_en_low;
        @(mon_cb) disable iff (rst)
        !mon_cb.en |=> (mon_cb.q == $past(mon_cb.q));
    endproperty

    assert property (hold_when_en_low)
    else $error("ASSERTION FAILED: Hold violation en=%0b, d=%0b, Q=%0b", mon_cb.en, mon_cb.d, mon_cb.q);

    cover_hold_when_en_low: cover property (hold_when_en_low) $display("The prop property is hit");      //Assertion coverage (DID this scenario occur?)

    // // Coverage: Bins for coverage data, e.g., how many times it passed/failed
    // cover property (hold_when_en_low) @(mon_cb) {
    //     bins hold_passes = (hold_when_en_low == 1); // Coverage bin for successful validation
    //     bins hold_fails = (hold_when_en_low == 0);  // Coverage bin for failed validation
    // }

endinterface

    // -------------------------
    // Functional Coverage Class
    // -------------------------

class dff_coverage;
    virtual dff_if vif;
    covergroup dff_cg @(posedge vif.clk);
        option.per_instance = 1;

        en_cp : coverpoint vif.en {
            bins off = {0};
            bins on  = {1};
        }

        d_cp : coverpoint vif.d {
            bins zero = {0};
            bins one  = {1};
        }

        q_cp : coverpoint vif.q {
            bins zero = {0};
            bins one  = {1};
        }

        // 🔥 THIS IS THE KEY
        en_d_cross : cross en_cp, d_cp{
            ignore_bins no_d_when_en0 = binsof(en_cp.off) && binsof(d_cp.one);
        }


    endgroup

    function new(virtual dff_if vif);
        this.vif = vif;
        dff_cg = new();
    endfunction
endclass


    // Monitor class
class dff_monitor;
    virtual dff_if vif;
    mailbox #(dff_txn) mon_mb;

    dff_coverage cov;

    function new(virtual dff_if vif,
                mailbox #(dff_txn) mb);
        this.vif = vif;
        this.mon_mb =mb;
        cov = new(vif);     // Coverage created here
    endfunction

        // task runs Monitor
    task run();
        dff_txn t;
        forever begin
            @(vif.mon_cb);  // Sample at clock edge

            t = new();
            t.en = vif.en;
            t.d = vif.d;
            t.q = vif.q;

            t.display("Monitor");
            mon_mb.put(t);
            // coverage samples automatically on posedge
        end
    endtask
        
endclass

// Score board class
class dff_scoreboard;
    mailbox #(dff_txn) sb_mb;
    bit exp_q;

    function new(mailbox #(dff_txn) mb);
        sb_mb = mb;
        exp_q = 0;
    endfunction

    task run();
        dff_txn t;
        forever begin
            sb_mb.get(t);

            // Update Reference Model after Check
            if (t.en)
                exp_q = t.d;
                
            // CHECK FIRST (compare current q with previous expected)
            if (t.q !== exp_q)
                $error("[ScoreBoard] Fail, Actual=%0b, Expect=%0b", t.q, exp_q);
            else
                $display("[ScoreBoard] Pass, Q=%0b", t.q);


        end
    endtask
endclass

// ------------------------------------------------------
// Driver
// ------------------------------------------------------

class dff_driver;
  virtual dff_if vif;

  function new(virtual dff_if vif);
    this.vif = vif;
  endfunction

  task drive(dff_txn tx);
    vif.drv_cb.en <= tx.en;
    vif.drv_cb.d  <= tx.d;
    @(vif.drv_cb);

  endtask
endclass


// ==========================================================
// Testbench
// ==========================================================
module tb_dff;
    logic clk;



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
        repeat (2) @(dif.drv_cb);
        dif.rst <= 0;
    end

    // dff_txn txn = new();

    dff_if dif(clk);

    // d_ff DUT(dif);
    // Instantiate the DUT without changing its code
    // Manually map interface signals to DUT pins
    d_ff u_dut (
        .clk    (dif.clk),
        .rst    (dif.rst),
        .en (dif.en),
        .d  (dif.d),
        .q  (dif.q)
    );

    dff_driver     drv;
    dff_monitor    mon;
    dff_scoreboard sb;

    mailbox #(dff_txn) mon_sb_mb;
    dff_txn tx;
    
/*

*/
    initial begin
        mon_sb_mb = new();

        drv = new(dif); 
        mon = new(dif, mon_sb_mb);
        sb = new(mon_sb_mb);

        fork
            mon.run();
            sb.run();
        join_none

        // @(negedge dif.rst);

        repeat(10) begin
            tx = new();
            assert(tx.randomize());
            drv.drive(tx);
        end

        #20 $display("TEST COMPLETED");
        $finish;
    end
endmodule