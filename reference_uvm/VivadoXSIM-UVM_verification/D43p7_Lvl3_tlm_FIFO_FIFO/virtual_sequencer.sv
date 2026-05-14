class virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(virtual_sequencer)

    my_sequencer seqr;      // Handle to real sequencer

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()
endclass //virtual_sequencer extends superClass

// 📌 This is only a container of handles, nothing else.