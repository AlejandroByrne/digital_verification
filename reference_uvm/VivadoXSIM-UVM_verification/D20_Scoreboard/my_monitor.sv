class my_monitor extends uvm_component;
    `uvm_component_utils(my_monitor)

    virtual my_if vif;
    uvm_analysis_port #(my_txn) ap;

    function new(string name="my_monitor", uvm_component parent=null);
        super.new(name, parent);
        ap = new("ap", this);
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

                `uvm_info("MON", $sformatf("Observed Data = %0d", tm.data), UVM_MEDIUM)
            end
        end
    endtask
endclass //my_monitor extends uvm_component