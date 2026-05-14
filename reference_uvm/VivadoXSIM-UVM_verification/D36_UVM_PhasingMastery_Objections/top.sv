module top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    logic clk = 0;
    always #5 clk = ~clk;

    my_if if0(clk);

    dut d0 (
        .clk(clk),
        .rst(if0.rst),
        .valid(if0.valid),
        .data(if0.data),
        .ready(if0.ready)
    );

    initial begin
        if0.rst   = 1;
        if0.valid = 0;
        #20 if0.rst = 0;
    end

    initial begin
        uvm_config_db#(virtual my_if)::set(null, "*", "vif", if0);
        run_test("my_test");
    end
endmodule

/*
Concept
    -run_test() hands control to UVM
    -No manual instantiation
*/