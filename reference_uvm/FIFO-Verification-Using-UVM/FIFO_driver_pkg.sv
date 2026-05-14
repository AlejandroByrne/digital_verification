package FIFO_driver_pkg;
	
	import FIFO_sequence_item_pkg::*;	
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	class FIFO_driver extends uvm_driver #(FIFO_sequence_item);
		`uvm_component_utils(FIFO_driver);
		virtual FIFO_if FIFO_Vif;
		FIFO_sequence_item stim_seq_item;

		function new(string name = "FIFO_driver", uvm_component parent = null);
			super.new(name,parent);
		endfunction

		task run_phase(uvm_phase phase);
			super.run_phase (phase);
			forever begin
				stim_seq_item=FIFO_sequence_item::type_id::create("stim_seq_item");
				seq_item_port.get_next_item(stim_seq_item);
				FIFO_Vif.rst_n=stim_seq_item.rst_n;
				FIFO_Vif.data_in=stim_seq_item.data_in;
				FIFO_Vif.wr_en=stim_seq_item.wr_en;
				FIFO_Vif.rd_en=stim_seq_item.rd_en;

				@(negedge FIFO_Vif.clk);
				seq_item_port.item_done();
				`uvm_info("run_phase",stim_seq_item.convert2string_stimulus(), UVM_HIGH)
			end
		endtask 
	endclass	
endpackage 
