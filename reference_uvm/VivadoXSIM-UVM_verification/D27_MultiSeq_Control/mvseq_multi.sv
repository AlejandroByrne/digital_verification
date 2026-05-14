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
        super.new(name  );        
    endfunction //new()

    task body();
        dir_bin_seq low_s;
        random_seq rand_s;

        low_s  = dir_bin_seq::type_id::create("low_s");
        rand_s = random_seq::type_id::create("rand_s");
        
        // `uvm_info("VSEQ_DIR", "Starting directed [0:63] sequence", UVM_MEDIUM)
        // low_s.start(vseqr.seqr);
        // `uvm_info("VSEQ_RAND", "Starting random sequence", UVM_MEDIUM)
        // rand_s.start(vseqr.seqr);       // 🔥 controlling real sequencer

        // `uvm_info("VSEQ", "Starting parallel sequences", UVM_MEDIUM)

        // fork
        //     low_s.start(vseqr.seqr);
        //     rand_s.start(vseqr.seqr);
        // join

          // Step-1: Directed first
        low_s.start(vseqr.seqr);

        // Step-2: Parallel stress
        `uvm_info("VSEQ", "Starting parallel sequences", UVM_MEDIUM)
        fork
            rand_s.start(vseqr.seqr);
            low_s.start(vseqr.seqr);
        join
    endtask
endclass //my_virtual_sequence extends uvm_sequence