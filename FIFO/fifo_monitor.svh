// ============================================================
//  FIFO — Monitor (Non-parameterized)
// ============================================================

class fifo_monitor extends uvm_monitor;
    `uvm_component_utils(fifo_monitor)

    virtual fifo_if #(8, 16) vif;
    uvm_analysis_port #(fifo_txn) ap;

    function new(string name = "fifo_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual fifo_if #(8, 16))::get(this, "", "vif", vif))
            `uvm_fatal("MON", "No virtual interface in config_db")
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        forever begin
            fifo_txn txn;
            @(posedge vif.clk);
            if (vif.rst_n) begin
                txn          = fifo_txn::type_id::create("txn");
                txn.wr_en    = vif.wr_en;
                txn.rd_en    = vif.rd_en;
                txn.data_in  = vif.data_in;
                txn.full     = vif.full;
                txn.is_empty = vif.is_empty;
                txn.data_out = vif.data_out;
                ap.write(txn);
            end
        end
    endtask : run_phase
endclass
