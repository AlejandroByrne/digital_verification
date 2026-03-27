// ============================================================
//  Half Adder — Scoreboard
//
//  Receives transactions from the monitor's analysis port.
//  Checks DUT outputs against the expected model:
//    result_out = a_in ^ b_in
//    carry_out  = a_in & b_in
// ============================================================

class ha_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ha_scoreboard)

    uvm_analysis_imp #(ha_txn, ha_scoreboard) imp;

    int pass_count;
    int fail_count;

    function new(string name = "ha_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imp = new("imp", this);
    endfunction : build_phase

    function void write(ha_txn t);
        logic exp_result = t.a_in ^ t.b_in;
        logic exp_carry  = t.a_in & t.b_in;

        if (t.result_out !== exp_result || t.carry_out !== exp_carry) begin
            `uvm_error("SB", $sformatf(
                "FAIL  a=%0b b=%0b | result: got=%0b exp=%0b | carry: got=%0b exp=%0b",
                t.a_in, t.b_in, t.result_out, exp_result, t.carry_out, exp_carry))
            fail_count++;
        end else begin
            `uvm_info("SB", $sformatf(
                "PASS  a=%0b b=%0b | result=%0b carry=%0b",
                t.a_in, t.b_in, t.result_out, t.carry_out), UVM_HIGH)
            pass_count++;
        end
    endfunction : write

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SB", $sformatf("Scoreboard: %0d passed, %0d failed", pass_count, fail_count), UVM_LOW)
    endfunction : report_phase

endclass : ha_scoreboard
