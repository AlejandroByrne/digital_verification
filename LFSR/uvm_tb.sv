// ============================================================================
// UVM Testbench for 4-bit LFSR — Fill in the TODOs
// ============================================================================
// This file contains EVERYTHING in one file for simplicity.
// In a real project, each class would be its own file.
//
// REFERENCE MATERIAL:
//   - verificationacademy.com (UVM class reference)
//   - chipverify.com (practical UVM tutorials)
//
// HOW TO RUN (EDA Playground):
//   1. Go to edaplayground.com
//   2. Left pane: paste your lfsr_4bit module (rename to .sv)
//   3. Right pane: paste this file
//   4. Simulator: Synopsys VCS or Aldec Riviera-PRO
//   5. Check "UVM/OVM" box in the left panel
//   6. Add to compile options: +UVM_TESTNAME=lfsr_test
//   7. Click Run
// ============================================================================

`timescale 1ns/1ps

// This one line imports the entire UVM library — every base class, macro,
// and utility you'll use. It's like `import numpy as np` in Python.
`include "uvm_macros.svh"
import uvm_pkg::*;


// ============================================================================
// 1. INTERFACE — The physical wires between testbench and DUT
// ============================================================================
// WHY: In UVM, we don't drive DUT ports directly from the testbench module.
//      Instead, we define an "interface" that bundles all the signals, and
//      then both the DUT and the testbench classes connect to it.
//
// This replaces the loose `logic clk, rst_n, q;` signals from your
// original testbench.
// ============================================================================
interface lfsr_if(input logic clk);
    logic       rst_n;
    logic [3:0] q;

    // A "clocking block" defines WHEN signals are sampled/driven relative
    // to the clock. This prevents race conditions in simulation.
    clocking driver_cb @(posedge clk);
        output rst_n;   // Driver controls rst_n
        input  q;       // Driver can read q
    endclocking

    clocking monitor_cb @(posedge clk);
        input rst_n;    // Monitor only observes
        input q;        // Monitor only observes
    endclocking
endinterface


// ============================================================================
// 2. TRANSACTION — One "unit of data" flowing through the testbench
// ============================================================================
// WHY: In your original TB, there's no explicit data object — you just
//      toggle rst_n and read q. In UVM, we formalize this: a transaction
//      describes one cycle's worth of stimulus + expected response.
//
// This is a SystemVerilog CLASS (like a Python class), not a module.
// UVM testbench components are all classes that extend UVM base classes.
//
// KEY CONCEPT: `uvm_object` is the base class for data items that flow
//              through the testbench. Transactions extend it via
//              `uvm_sequence_item`.
// ============================================================================
class lfsr_transaction extends uvm_sequence_item;

    // TODO 1: Register this class with the UVM factory.
    // The factory is how UVM creates objects — it allows you to swap
    // implementations later without changing code.
    //
    // HINT: The macro is `uvm_object_utils(class_name)
    // Write it below:
    // >>>

    // <<<

    // The data fields for this transaction.
    // rand means "this field can be randomized" — not useful for rst_n
    // in this simple case, but it's the pattern you'll use everywhere.
    rand logic rst_n;      // Stimulus: are we resetting?
    logic [3:0] q;         // Observed output from DUT

    // TODO 2: Write the constructor.
    // Every UVM class needs a constructor that calls super.new().
    //
    // HINT: function new(string name = "lfsr_transaction");
    //           super.new(name);
    //       endfunction
    // Write it below:
    // >>>

    // <<<

endclass


// ============================================================================
// 3. SEQUENCE — Generates a stream of transactions (your stimulus plan)
// ============================================================================
// WHY: This replaces the `initial begin` block where you toggled rst_n
//      and ran 15 cycles. A sequence is a reusable recipe for stimulus.
//
// FLOW: Sequence creates transactions → sends them to the Sequencer →
//       Sequencer feeds them to the Driver one at a time.
// ============================================================================
class lfsr_reset_sequence extends uvm_sequence #(lfsr_transaction);
    `uvm_object_utils(lfsr_reset_sequence)

    function new(string name = "lfsr_reset_sequence");
        super.new(name);
    endfunction

    // The body() task is where the action happens. This is called
    // automatically when the sequence is started on a sequencer.
    virtual task body();
        lfsr_transaction txn;

        // --- Phase 1: Assert reset for 3 cycles ---
        // This replaces your: rst_n = 0; #15;
        repeat (3) begin
            txn = lfsr_transaction::type_id::create("txn");

            // start_item/finish_item is the handshake with the sequencer.
            // start_item BLOCKS until the driver is ready for the next item.
            start_item(txn);

            // TODO 3: Set txn.rst_n to 0 (assert reset)
            // >>>

            // <<<

            finish_item(txn);
        end

        // --- Phase 2: Release reset, run for 15 cycles ---
        // This replaces your: rst_n = 1; repeat(15)...
        repeat (15) begin
            txn = lfsr_transaction::type_id::create("txn");
            start_item(txn);

            // TODO 4: Set txn.rst_n to 1 (release reset)
            // >>>

            // <<<

            finish_item(txn);
        end
    endtask
endclass


// ============================================================================
// 4. DRIVER — Takes transactions and wiggles actual DUT pins
// ============================================================================
// WHY: The driver is the translator between abstract transactions and
//      physical signals. It's the only component that DRIVES the interface.
//
// In your original TB, the driver was implicit — you directly wrote
// `rst_n = 0`. In UVM, the driver does that on behalf of the sequence.
//
// STRUCTURE: Driver extends uvm_driver, which has a built-in TLM port
//            called seq_item_port that connects to the sequencer.
// ============================================================================
class lfsr_driver extends uvm_driver #(lfsr_transaction);
    `uvm_component_utils(lfsr_driver)

    // A handle to the interface — this is how the driver accesses the wires.
    // "virtual" means it's a reference to an interface instance, not a copy.
    virtual lfsr_if vif;

    function new(string name = "lfsr_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    // build_phase: UVM calls this automatically during testbench construction.
    // We use it to grab the interface handle from the UVM config database.
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual lfsr_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRIVER", "Could not get interface handle from config_db")
    endfunction

    // run_phase: The main loop. Runs forever until the test ends.
    // Gets transactions from the sequencer and drives them onto the DUT.
    virtual task run_phase(uvm_phase phase);
        lfsr_transaction txn;
        forever begin
            // Get the next transaction from the sequencer
            seq_item_port.get_next_item(txn);

            // TODO 5: Drive the rst_n signal from the transaction onto
            //         the interface, then wait one clock cycle.
            //
            // HINT: Use the clocking block:
            //   vif.driver_cb.rst_n <= txn.rst_n;
            //   @(vif.driver_cb);
            // >>>

            // <<<

            // Tell the sequencer we're done with this transaction
            seq_item_port.item_done();
        end
    endtask
endclass


// ============================================================================
// 5. MONITOR — Observes DUT outputs (NEVER drives anything)
// ============================================================================
// WHY: The monitor watches the interface and captures what the DUT
//      actually did. It then broadcasts that observation to anyone
//      listening (the scoreboard).
//
// In your original TB, the monitor was the `$display` + `assert` block.
// In UVM, we split observation (monitor) from checking (scoreboard).
//
// BROADCAST: The monitor uses an "analysis port" to send transactions.
//            Any number of components can listen. This is the "publish"
//            side of a publish-subscribe pattern.
// ============================================================================
class lfsr_monitor extends uvm_monitor;
    `uvm_component_utils(lfsr_monitor)

    virtual lfsr_if vif;

    // Analysis port — this is how the monitor broadcasts observations
    uvm_analysis_port #(lfsr_transaction) ap;

    function new(string name = "lfsr_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // TODO 6: Create the analysis port.
        //
        // HINT: ap = new("ap", this);
        // >>>

        // <<<

        if (!uvm_config_db#(virtual lfsr_if)::get(this, "", "vif", vif))
            `uvm_fatal("MONITOR", "Could not get interface handle from config_db")
    endfunction

    virtual task run_phase(uvm_phase phase);
        lfsr_transaction txn;
        forever begin
            @(vif.monitor_cb);
            txn = lfsr_transaction::type_id::create("txn");

            // TODO 7: Capture the current DUT outputs into the transaction.
            //
            // HINT: Read from the clocking block:
            //   txn.rst_n = vif.monitor_cb.rst_n;
            //   txn.q     = vif.monitor_cb.q;
            // >>>

            // <<<

            // Broadcast this observation to all subscribers (scoreboard)
            ap.write(txn);
        end
    endtask
endclass


// ============================================================================
// 6. SCOREBOARD — Checks correctness (your LUT + assert logic lives here)
// ============================================================================
// WHY: This is the brain of your testbench. It receives observations from
//      the monitor and checks them against a reference model.
//
// Your original TB had:   expected_q = lfsr_lut[$past(q)];
//                         assert (q === expected_q)
// That logic moves here.
//
// SUBSCRIBE: The scoreboard implements `uvm_subscriber`, which has a
//            built-in `write()` function that gets called every time
//            the monitor broadcasts a transaction.
// ============================================================================
class lfsr_scoreboard extends uvm_subscriber #(lfsr_transaction);
    `uvm_component_utils(lfsr_scoreboard)

    // Your reference model — the same LUT from your original testbench!
    logic [3:0] lfsr_lut [16] = '{
        4'b0000, 4'b0010, 4'b0100, 4'b0110,
        4'b1001, 4'b1011, 4'b0110, 4'b0111,
        4'b0001, 4'b0011, 4'b0101, 4'b0111,
        4'b1000, 4'b1010, 4'b1100, 4'b1110
    };

    logic [3:0] prev_q;
    bit         first_sample;  // Track if this is the first observation
    int         pass_count;
    int         fail_count;

    function new(string name = "lfsr_scoreboard", uvm_component parent);
        super.new(name, parent);
        first_sample = 1;
        pass_count = 0;
        fail_count = 0;
    endfunction

    // write() is called automatically every time the monitor broadcasts.
    // This is the UVM equivalent of your `assert` block.
    virtual function void write(lfsr_transaction txn);
        logic [3:0] expected_q;

        if (!txn.rst_n) begin
            // During reset, just record the state — nothing to check yet
            prev_q = 4'b0001;  // We know the seed value
            first_sample = 1;
            return;
        end

        if (first_sample) begin
            // First cycle after reset — we know q should be the seed
            prev_q = txn.q;
            first_sample = 0;
            return;
        end

        // TODO 8: Compute the expected value using the LUT and compare
        //         it to the actual observed value.
        //
        // HINT: This is almost identical to your original testbench:
        //   expected_q = lfsr_lut[prev_q];
        //   if (txn.q !== expected_q) begin
        //       `uvm_error("SCOREBOARD", $sformatf(
        //           "MISMATCH! Observed: %0d, Expected: %0d", txn.q, expected_q))
        //       fail_count++;
        //   end else begin
        //       pass_count++;
        //   end
        //   prev_q = txn.q;
        // >>>

        // <<<
    endfunction

    // report_phase: Called at the end of the test. Print your results.
    virtual function void report_phase(uvm_phase phase);
        `uvm_info("SCOREBOARD", $sformatf(
            "Test complete: %0d PASSED, %0d FAILED", pass_count, fail_count),
            UVM_LOW)
    endfunction
endclass


// ============================================================================
// 7. AGENT — Bundles driver + monitor + sequencer into one reusable unit
// ============================================================================
// WHY: An agent is the standard UVM container for one "interface worth"
//      of verification components. If you later verify a chip with 3 SPI
//      ports, you instantiate 3 SPI agents.
//
// CONNECTIONS: The agent wires up:
//   Sequencer ——> Driver    (transactions flow from sequencer to driver)
//   Monitor   ——> outside   (analysis port exposed for scoreboard)
// ============================================================================
class lfsr_agent extends uvm_agent;
    `uvm_component_utils(lfsr_agent)

    lfsr_driver    drv;
    lfsr_monitor   mon;
    uvm_sequencer #(lfsr_transaction) sqr;

    function new(string name = "lfsr_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // TODO 9: Create the driver, monitor, and sequencer using
        //         the UVM factory pattern (type_id::create).
        //
        // HINT:
        //   drv = lfsr_driver::type_id::create("drv", this);
        //   mon = lfsr_monitor::type_id::create("mon", this);
        //   sqr = uvm_sequencer#(lfsr_transaction)::type_id::create("sqr", this);
        // >>>

        // <<<
    endfunction

    // connect_phase: Wire the components together.
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // TODO 10: Connect the driver's seq_item_port to the sequencer's
        //          seq_item_export. This is how transactions flow.
        //
        // HINT: drv.seq_item_port.connect(sqr.seq_item_export);
        // >>>

        // <<<
    endfunction
endclass


// ============================================================================
// 8. ENVIRONMENT — Top-level container for agents + scoreboard
// ============================================================================
// WHY: The env is the complete, reusable verification environment.
//      A test might swap out sequences, but the env stays the same.
// ============================================================================
class lfsr_env extends uvm_env;
    `uvm_component_utils(lfsr_env)

    lfsr_agent      agt;
    lfsr_scoreboard sb;

    function new(string name = "lfsr_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = lfsr_agent::type_id::create("agt", this);
        sb  = lfsr_scoreboard::type_id::create("sb", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // TODO 11: Connect the monitor's analysis port to the scoreboard.
        // This is the pub-sub wiring: monitor publishes, scoreboard subscribes.
        //
        // HINT: agt.mon.ap.connect(sb.analysis_export);
        // >>>

        // <<<
    endfunction
endclass


// ============================================================================
// 9. TEST — Configures the env and starts the sequence
// ============================================================================
// WHY: The test is the top-level UVM component. It creates the env,
//      picks which sequence to run, and controls the test lifecycle.
//
// In your original TB, the test was the `initial begin` block.
// ============================================================================
class lfsr_test extends uvm_test;
    `uvm_component_utils(lfsr_test)

    lfsr_env env;

    function new(string name = "lfsr_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = lfsr_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        lfsr_reset_sequence seq;

        // raise_objection / drop_objection tell UVM "the test is still
        // running, don't shut down yet." Without this, UVM would end
        // the test before your sequence even starts.
        phase.raise_objection(this);

        seq = lfsr_reset_sequence::type_id::create("seq");

        // TODO 12: Start the sequence on the agent's sequencer.
        //
        // HINT: seq.start(env.agt.sqr);
        // >>>

        // <<<

        // Small delay to let the last transaction propagate
        #100;

        phase.drop_objection(this);
    endtask
endclass


// ============================================================================
// 10. TOP MODULE — The hardware shell that wires everything together
// ============================================================================
// WHY: UVM classes can't create hardware (modules, interfaces, clocks).
//      This top module instantiates the interface, the DUT, generates
//      the clock, and passes the interface handle into UVM's config_db
//      so that the driver and monitor can find it.
//
// This is the "non-UVM glue" that you always need.
// ============================================================================
module tb_top;

    logic clk;

    // Clock generation — same as your original testbench
    initial clk = 0;
    always #5 clk = ~clk;

    // Instantiate the interface
    lfsr_if intf(clk);

    // Instantiate the DUT, connected to the interface
    lfsr_4bit dut (
        .clk   (clk),
        .rst_n (intf.rst_n),
        .q     (intf.q)
    );

    initial begin
        // Store the interface handle in the config database so that
        // UVM classes (driver, monitor) can retrieve it.
        uvm_config_db#(virtual lfsr_if)::set(null, "*", "vif", intf);

        // Launch UVM — this one call does everything:
        // builds the test, runs all phases, shuts down cleanly.
        run_test("lfsr_test");
    end
endmodule
