class my_virtual_seq extends uvm_sequence;
    `uvm_object_utils(my_virtual_seq)
    
    virtual_sequencer vseqr;

    function new(string name="my_virtual_seq");
        super.new(name);        
    endfunction //new()

    task body();
        random_seq rs;
        rs = random_seq::type_id::create("rs");

        `uvm_info("VSEQ", "Starting chiild sequence", UVM_MEDIUM)

        rs.start(vseqr.seqr);       // 🔥 controlling real sequencer
    endtask
endclass //my_virtual_sequence extends uvm_sequence