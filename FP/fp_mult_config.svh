class fp_mult_config extends uvm_object;
  `uvm_object_utils(fp_mult_config)

  virtual fp_mult_if fp_vi;

  function new(string name="fp_mult_config");
    super.new(name);
  endfunction: new
endclass: fp_mult_config
