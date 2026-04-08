// ============================================================
//  IEEE 754 Float32 Multiplier — Interface
//
//  Clean valid_in / valid_out handshake.
//  Driver drives: a_in, b_in, rnd_mode, valid_in, rst_n
//  DUT drives:    result_out, flags_out, valid_out
// ============================================================

interface fp32_if (input logic clk);

    // Control
    logic        rst_n;
    logic        valid_in;
    logic        valid_out;

    // Stimulus (driven by driver)
    logic [31:0] a_in;
    logic [31:0] b_in;
    logic [1:0]  rnd_mode;

    // Response (driven by DUT)
    logic [31:0] result_out;
    logic [4:0]  flags_out;     // {NV, DZ, OF, UF, NX}

    // ── Protocol Assertions ──

    // 1. Handshake: valid_out must follow valid_in (1-cycle latency)
    property p_latency;
        @(posedge clk) disable iff (!rst_n)
        valid_in |=> valid_out;
    endproperty
    a_latency: assert property (p_latency);

    // 2. Data Stability: inputs must remain stable if valid_in is high
    // (In this simple case, we just expect valid_in to be high for 1 cycle per txn)
    
    // 3. Reset: outputs must be zero when reset is active
    property p_reset_state;
        @(posedge clk) !rst_n |-> (!valid_out && result_out == 0 && flags_out == 0);
    endproperty
    a_reset_state: assert property (p_reset_state);

endinterface : fp32_if
