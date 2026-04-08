// ============================================================
//  FIFO — Agent (Non-parameterized)
// ============================================================

class fifo_agent extends uvm_agent;
    `uvm_component_utils(fifo_agent)

    fifo_driver    drv;
    fifo_monitor   mon;
    fifo_sequencer seqr;
    uvm_analysis_port #(fifo_txn) ap;

    function new(string name = "fifo_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        mon = fifo_monitor::type_id::create("mon", this);
        if (get_is_active() == UVM_ACTIVE) begin
            drv  = fifo_driver::type_id::create("drv", this);
            seqr = fifo_sequencer::type_id::create("seqr", this);
        end
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        mon.ap.connect(this.ap);
        if (get_is_active() == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction : connect_phase
endclass
