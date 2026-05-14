package FIFO_monitor_pkg;
	import FIFO_config_pkg::*;
	import FIFO_sequence_item_pkg::*;
	import FIFO_shared_pkg::*;	
	
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	
	class FIFO_monitor extends uvm_monitor ;
		`uvm_component_utils(FIFO_monitor);
		virtual FIFO_if FIFO_Vif;
		FIFO_sequence_item rsp_seq_item;
		uvm_analysis_port #(FIFO_sequence_item) mon_ap;

		function new(string name = "FIFO_monitor", uvm_component parent = null);
			super.new(name,parent);
		endfunction

		function void build_phase (uvm_phase phase);
			super.build_phase(phase);
			mon_ap = new("mon_ap",this);		
		endfunction

		task run_phase(uvm_phase phase);
			super.run_phase (phase);
			forever begin
				rsp_seq_item = FIFO_sequence_item::type_id::create("rsp_seq_item");

				@(negedge FIFO_Vif.clk);
				@(posedge FIFO_Vif.clk);
				
				rsp_seq_item.rst_n=FIFO_Vif.rst_n;
				rsp_seq_item.rd_en=FIFO_Vif.rd_en;
				rsp_seq_item.wr_en=FIFO_Vif.wr_en;
				rsp_seq_item.data_in=FIFO_Vif.data_in;
				rsp_seq_item.overflow=FIFO_Vif.overflow;
				rsp_seq_item.underflow=FIFO_Vif.underflow;
				rsp_seq_item.full=FIFO_Vif.full;
				rsp_seq_item.empty=FIFO_Vif.empty;
				rsp_seq_item.wr_ack=FIFO_Vif.wr_ack;
				rsp_seq_item.almostfull=FIFO_Vif.almostfull;
				rsp_seq_item.almostempty=FIFO_Vif.almostempty;
				rsp_seq_item.data_out=FIFO_Vif.data_out;



				mon_ap.write(rsp_seq_item);

				`uvm_info("run_phase",rsp_seq_item.convert2string_stimulus(), UVM_HIGH)
			end
		endtask 

	endclass	
endpackage 
