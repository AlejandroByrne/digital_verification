import test_mode_pkg::*;

class layered_vseq  extends uvm_sequence;
    `uvm_object_utils(layered_vseq)
    `uvm_declare_p_sequencer(virtual_sequencer)
    
    reset_seq rst_s;
    config_seq  cfg_s;
    sanity_traffic_seq san_s;
    stress_traffic_seq str_s;

    function new(string name="layered_vseq");
        super.new(name);
        // mode = STRESS;  // Default

    endfunction //new()

    task body();
        test_mode_e mode;
        
        `uvm_info("SEQ_START", "layered_vseq body entered", UVM_NONE)

        // if (!uvm_config_db#(test_mode_e)::get(p_sequencer, "", "mode", mode)) begin
        //     `uvm_fatal("CFG", "Mode not set via config_db")
        // end

        `uvm_info("LAYERED_VSEQ", "Starting layers", UVM_MEDIUM)

        rst_s = reset_seq::type_id::create("rst_s");
        cfg_s = config_seq::type_id::create("cfg_s");
        san_s = sanity_traffic_seq::type_id::create("san_s");
        str_s = stress_traffic_seq::type_id::create("str_s");

        // rst_s.start(p_sequencer.seqr);
        // cfg_s.start(p_sequencer.seqr);

        // if (mode == SANITY) begin
        //     `uvm_info("LAYERED_VSEQ", "Policy: SANITY", UVM_MEDIUM)
        //     san_s.start(p_sequencer.seqr);
        // end else begin
        //     `uvm_info("LAYERED_VSEQ", "Policy: STRESS", UVM_MEDIUM)
        //     str_s.start(p_sequencer.seqr);
        // end
        case (mode)
            SANITY  : begin
                `uvm_info("LAYERED_VSEQ", "Policy: SANITY", UVM_MEDIUM)
                san_s.start(p_sequencer.seqr); 
            end
            STRESS  : begin
                `uvm_info("LAYERED_VSEQ", "Policy: STRESS", UVM_MEDIUM)
                str_s.start(p_sequencer.seqr);
            end
            BURST   : begin
                `uvm_info("LAYERED_VSEQ", "Policy: BURST", UVM_MEDIUM)
                repeat(5) san_s.start(p_sequencer.seqr);
            end
        endcase

        `uvm_info("LAYERED_VSEQ", "All layers completed", UVM_MEDIUM)
        
    endtask
endclass //layered_seq extends uvm_sequence