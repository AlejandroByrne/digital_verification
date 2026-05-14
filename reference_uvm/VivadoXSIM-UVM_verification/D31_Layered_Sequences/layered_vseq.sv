class layered_vseq  extends uvm_sequence;
    `uvm_object_utils(layered_vseq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    function new(string name="layered_vseq");
        super.new(name);
    endfunction //new()

    reset_seq rst_s;
    config_seq  cfg_s;
    traffic_seq tfc_s;

    task body();
        `uvm_info("LAYERED_VSEQ", "Starting layers", UVM_MEDIUM)

        rst_s = reset_seq::type_id::create("rst_s");
        cfg_s = config_seq::type_id::create("cfg_s");
        tfc_s = traffic_seq::type_id::create("tfc_s");

        rst_s.start(p_sequencer.seqr);
        cfg_s.start(p_sequencer.seqr);
        tfc_s.start(p_sequencer.seqr);

        `uvm_info("LAYERED_VSEQ", "All layers completed", UVM_MEDIUM)
    endtask
endclass //layered_seq extends uvm_sequence