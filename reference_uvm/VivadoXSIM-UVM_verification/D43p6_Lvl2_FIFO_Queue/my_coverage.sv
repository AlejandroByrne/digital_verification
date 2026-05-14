class my_coverage extends uvm_subscriber #(my_txn);
  `uvm_component_utils(my_coverage)

  int unsigned cov_data;
  bit cov_rst;
  
  covergroup cg;
    option.per_instance = 1;

    cp_data : coverpoint cov_data {
      bins low    = {[0:63]};
      bins med    = {[64:127]};
      bins high   = {[128:255]};
      // illegal_bins invalid = {[256:$]};
      illegal_bins invalid = default;
    }

    cp_rst : coverpoint cov_rst iff (!cov_rst) {
      // bins asserted   = {1};
      bins deasserted = {0};
    }

    cross cp_data, cp_rst;
  endgroup;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg = new();
  endfunction

  virtual function void write(my_txn t);
    // Gate sampling on acceptance
    // if (!t.accepted)
    //   return;

    cov_data = t.data;
    cov_rst = t.rst;
    cg.sample();

    `uvm_info("COV",
              $sformatf("Coverage sampled for accepted txn = %0d", cov_data), 
              UVM_LOW)
              
  endfunction
endclass
