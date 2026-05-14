package FIFO_sequence_item_pkg;

	import FIFO_shared_pkg::*;	
	import uvm_pkg::*;

	`include "uvm_macros.svh"
	class FIFO_sequence_item extends uvm_sequence_item ;
		`uvm_object_utils(FIFO_sequence_item)

		rand logic [FIFO_WIDTH-1:0] data_in; 
		rand logic rst_n, wr_en, rd_en;
		logic [FIFO_WIDTH-1:0] data_out;
		logic wr_ack, overflow;
		logic full, empty, almostfull, almostempty, underflow;


		constraint  A {rst_n dist {1:/90, 0:/10};}
		constraint  B {wr_en dist {1:/70, 0:/30};}
		constraint  C {rd_en dist {1:/30, 0:/70};}

		function new(string name = "FIFO_sequence_item");
			super.new(name);
		endfunction

  		function string convert2string();
  			return $sformatf("%s rst_n_rand = 0b%0b,  data_in = 0b%0b, wr_en = 0b%0b, rd_en = 0b%0b, data_out = 0b%0b, wr_ack =0b%0b
  								, overflow =0b%0b, full =0b%0b, empty =%s, almostfull =0b%0b, almostempty =0b%0b, underflow =0b%0b",
  			 super.convert2string(), rst_n, data_in, wr_en, rd_en, data_out, wr_ack, overflow, full
  			 , empty, almostfull, almostempty, underflow);
  		endfunction : convert2string

  		function string convert2string_stimulus();
  			return $sformatf("%s rst_n_rand = 0b%0b,  data_in = 0b%0b, wr_en = 0b%0b, rd_en = 0b%0b",
  			 super.convert2string(), rst_n, data_in, wr_en, rd_en);
  		endfunction : convert2string_stimulus
	endclass
	
	
endpackage