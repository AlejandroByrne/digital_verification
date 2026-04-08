// ============================================================
//  FIFO — Configuration Object
// ============================================================

class fifo_config #(int WIDTH = 8, int DEPTH = 8) extends uvm_object;
    `uvm_object_param_utils(fifo_config #(WIDTH, DEPTH))

    virtual fifo_if #(WIDTH, DEPTH) vif;
    uvm_active_passive_enum is_active = UVM_ACTIVE;

    function new(string name = "fifo_config");
        super.new(name);
    endfunction : new

endclass : fifo_config
