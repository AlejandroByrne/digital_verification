interface my_if (input logic clk);
    logic rst;
    logic valid;
    logic [7:0] data;
    logic ready;

    // -----Reset Dominance-----
    property p_rst_ready_low;
        @(posedge clk) rst |=> !ready;
    endproperty
    assert property (p_rst_ready_low)
    else $error("ASSERTION FAILED: READY high during reset");
    // --🎯 Bug caught: Improper reset logic

    // -----Valid-Ready Handshake-----
    property p_handshake;
        @(posedge clk) 
        disable iff (rst)
        valid |=> ready;
    endproperty
    a_handshake: assert property (p_handshake)
        else $error("Handshake failed!");
    // --🎯 Bug caught: Deadlock / backpressure issues

    // -----Data stability Until Accepted-----
    // DATA must remain stable until READY goes high
    property p_data_stable;
        @(posedge clk)
        disable iff (rst)
        (valid && !ready) |=> $stable(data); 
    endproperty
    a_datastable: assert property (p_data_stable)
        else $error("Assertion a_datastable failed!");
    // --🎯 Bug caught: Data corruption

    // -----VALID Must Stay Asserted Until READY
    property p_valid_hold;
        @(posedge clk)
        disable iff (rst)
        valid && !ready |=> valid;
    endproperty
    a_valid_hold: assert property (p_valid_hold)
        else $error("Assertion a_valid_hold failed!");
    // --🎯 Bug caught: Protocol violation

    // -----No Spurious READY
    property p_no_spur_ready;
        @(posedge clk)
        disable iff (rst)
        ready |-> $past(valid);
    endproperty
    a_no_spur_ready: assert property (p_no_spur_ready)
        else $error("Assertion a_no_spur_ready failed!");
    // --🎯 Bug caught: Illegal responder behavior
endinterface //my_if 