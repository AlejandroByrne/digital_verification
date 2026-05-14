package FIFO_reset_sequence_pkg;
	import uvm_pkg::*;
	import FIFO_sequence_item_pkg::*;
	import FIFO_shared_pkg::*;	
	
	`include "uvm_macros.svh"
	class FIFO_reset_sequence extends uvm_sequence #(FIFO_sequence_item) ;
		`uvm_object_utils(FIFO_reset_sequence)

		FIFO_sequence_item seq_item;

		function new(string name = "FIFO_reset_sequence");
			super.new(name);
		endfunction

		task body;
			seq_item = FIFO_sequence_item::type_id::create("seq_item");
			start_item(seq_item);
			seq_item.rst_n=0;
			seq_item.wr_en=0;
			seq_item.rd_en=0;
			seq_item.data_in=0;
			finish_item(seq_item);
		endtask : body
	endclass
	
	
endpackage