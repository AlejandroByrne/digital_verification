// ============================================================
//  FIFO — Driver (Non-parameterized)
// ============================================================

class fifo_driver extends uvm_driver #(fifo_txn);
    `uvm_component_utils(fifo_driver)

    virtual fifo_if #(8, 16) vif;

    function new(string name = "fifo_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual fifo_if #(8, 16))::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "No virtual interface in config_db")
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        vif.wr_en   <= 1'b0;
        vif.rd_en   <= 1'b0;
        vif.data_in <= 8'h00;
        wait(vif.rst_n === 1'b1);
        forever begin
            fifo_txn req;
            seq_item_port.get_next_item(req);
            repeat (req.delay) @(posedge vif.clk);
            vif.wr_en   <= req.wr_en;
            vif.rd_en   <= req.rd_en;
            vif.data_in <= req.data_in;
            @(posedge vif.clk);
            vif.wr_en   <= 1'b0;
            vif.rd_en   <= 1'b0;
            seq_item_port.item_done();
        end
    endtask : run_phase
endclass
