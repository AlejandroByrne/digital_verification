/*
1) Ordered (Sequential) Multi-Sequence Control
Example Order:
👉 First send directed low-range traffic
👉 Then send random traffic
*/

class mvvseq_multi extends uvm_sequence;
    `uvm_object_utils(mvvseq_multi)
    
    virtual_sequencer vseqr;

    function new(string name="my_virtual_seq");
        super.new(name);        
    endfunction //new()

    task body();
        // dir_bin_seq low_s;
        random_seq rand_s;

        // confiq_seq cfg_s;
        reset_seq rst_s;

        // low_s  = dir_bin_seq::type_id::create("low_s");
        rand_s = random_seq::type_id::create("rand_s");

        // cfg_s = confiq_seq::type_id::create("cfg_s");
        rst_s  = reset_seq::type_id::create("rst_s");
        
        `uvm_info("VSEQ", "Starting parallel sequences", UVM_MEDIUM)
        
        // // ---------lock & unlock--------
        // fork
        //     rand_s.start(vseqr.seqr);
        //     cfg_s.start(vseqr.seqr);
        // join
        // // ------------------------------

        // ---------grab & ungrab--------
        fork
            rand_s.start(vseqr.seqr);
            begin
                #20;
                rst_s.start(vseqr.seqr);
            end
        join
        // -------------------------------
    endtask
endclass //my_virtual_sequence extends uvm_sequence