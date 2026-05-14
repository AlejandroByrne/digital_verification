class my_monitor extends uvm_component;
    `uvm_component_utils(my_monitor)

    virtual my_if vif;
    uvm_analysis_port #(my_txn) ap;

    // ---------------------
    // Functional Coverage
    // ---------------------
    bit [7:0] cov_data;

    covergroup data_cg;
        option.per_instance = 1;

        cp_data : coverpoint cov_data {
            bins low    = {[0:63]};
            bins med    = {[64:127]};
            bins high   = {[128:255]};
        }
    endgroup

    function new(string name="my_monitor", uvm_component parent=null);
        super.new(name, parent);
        ap = new("ap", this);
        data_cg = new();    
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found in Monitor");
    endfunction

    task run_phase(uvm_phase phase);
        my_txn tm;
        forever begin
            @(posedge vif.clk);
            if (!vif.rst && vif.valid) begin
                tm = my_txn::type_id::create("tm", this);
                tm.data = vif.data;
                
                ap.write(tm);

                // Sample Coverage
                cov_data = vif.data;
                data_cg.sample();

                `uvm_info("MON", $sformatf("Observed Data = %0d", tm.data), UVM_MEDIUM)
            end
        end
    endtask
endclass //my_monitor extends uvm_component

/*
🔑 Interview-Grade Insight

If interviewer asks:
“Why can’t you use vif.data directly in a coverpoint?”

Correct answer:
“Covergroups sample variables, not hierarchical expressions. So we assign the signal to a sampled variable before calling sample().”

*/