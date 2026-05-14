// 2:1 Multiplexer DUT
module mux2 (
    input  logic a,
    input  logic b,
    input  logic sel,
    output logic y
);

    // Combinational logic
    always_comb begin
        if (sel)
            y = b;
        else
            y = a;
    end

endmodule
