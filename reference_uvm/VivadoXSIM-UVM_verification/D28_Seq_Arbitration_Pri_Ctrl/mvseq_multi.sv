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
        
        // Setting Priority
        rand_s.set_priority(1000);   //High Priority
        low_s.set_priority(1);     //Low Priority

        `uvm_info("VSEQ", "Starting parallel sequences", UVM_MEDIUM)
        fork
            rand_s.start(vseqr.seqr);
            low_s.start(vseqr.seqr);
        join
    endtask
endclass //my_virtual_sequence extends uvm_sequence