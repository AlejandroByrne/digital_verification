// ============================================================
//  FIFO — Scoreboard (Non-parameterized)
// ============================================================

class fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fifo_scoreboard)

    uvm_analysis_imp #(fifo_txn, fifo_scoreboard) analysis_export;

    logic [7:0] ref_queue [$];
    bit next_full  = 0;
    bit next_empty = 1;
    logic [7:0] expected_data;
    bit         pending_read = 0;

    int pass_count = 0;
    int fail_count = 0;

    function new(string name = "fifo_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_export = new("analysis_export", this);
    endfunction : build_phase

    function void write(fifo_txn txn);
        if (txn.full !== next_full) begin
            `uvm_error("SB_FAIL", $sformatf("Full flag mismatch: EXP=%b, GOT=%b", next_full, txn.full))
            fail_count++;
        end
        if (txn.is_empty !== next_empty) begin
            `uvm_error("SB_FAIL", $sformatf("Empty flag mismatch: EXP=%b, GOT=%b", next_empty, txn.is_empty))
            fail_count++;
        end
        if (pending_read) begin
            if (txn.data_out !== expected_data) begin
                `uvm_error("SB_FAIL", $sformatf("Read mismatch: EXP=0x%h, GOT=0x%h", expected_data, txn.data_out))
                fail_count++;
            end else begin
                `uvm_info("SB_PASS", $sformatf("Read match: 0x%h", txn.data_out), UVM_HIGH)
                pass_count++;
            end
            pending_read = 0;
        end

        if (txn.wr_en && !txn.full) begin
            ref_queue.push_back(txn.data_in);
        end
        if (txn.rd_en && !txn.is_empty) begin
            if (ref_queue.size() > 0) begin
                expected_data = ref_queue.pop_front();
                pending_read = 1;
            end
        end
        next_full  = (ref_queue.size() == 16);
        next_empty = (ref_queue.size() == 0);
    endfunction : write

    function void report_phase(uvm_phase phase);
        `uvm_info("SB", $sformatf("Scoreboard: %0d Pass, %0d Fail", pass_count, fail_count), UVM_LOW)
    endfunction : report_phase
endclass
