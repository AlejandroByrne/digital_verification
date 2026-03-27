// ============================================================
//  IEEE 754 Float32 Multiplier — Monitor
//
//  Passively observes the interface.
//  Captures inputs when valid_in is asserted,
//  captures outputs when valid_out is asserted,
//  then broadcasts the complete transaction.
// ============================================================

class fp32_monitor extends uvm_monitor;
    `uvm_component_utils(fp32_monitor)

    virtual fp32_if vif;
    uvm_analysis_port #(fp32_txn) ap;

    function new(string name = "fp32_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual fp32_if)::get(this, "", "fp32_vi", vif))
            `uvm_fatal("MON", "No virtual interface in config_db")
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        fp32_txn txn;

        forever begin
            // Wait for driver to assert valid_in
            @(posedge vif.clk iff vif.valid_in);

            // Capture stimulus
            txn          = fp32_txn::type_id::create("txn");
            txn.a_in     = vif.a_in;
            txn.b_in     = vif.b_in;
            txn.rnd_mode = vif.rnd_mode;

            // Wait for DUT to assert valid_out (1 cycle later)
            @(posedge vif.clk iff vif.valid_out);

            // Capture response
            txn.result = vif.result_out;
            txn.flags  = vif.flags_out;

            `uvm_info("MON", $sformatf(
                "a=0x%08h b=0x%08h rnd=%0d → result=0x%08h flags=%05b",
                txn.a_in, txn.b_in, txn.rnd_mode,
                txn.result, txn.flags), UVM_HIGH)

            // Broadcast to all subscribers
            ap.write(txn);
        end
    endtask : run_phase

endclass : fp32_monitor
