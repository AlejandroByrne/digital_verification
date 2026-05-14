package FIFO_scoreboard_pkg;
	import uvm_pkg::*;
	import FIFO_shared_pkg::*;
	import FIFO_sequence_item_pkg::*;
	`include "uvm_macros.svh"

	class FIFO_scoreboard extends uvm_scoreboard;
		`uvm_component_utils(FIFO_scoreboard)
		uvm_analysis_export #(FIFO_sequence_item) sb_export;
		uvm_tlm_analysis_fifo #(FIFO_sequence_item) sb_fifo;
		FIFO_sequence_item seq_item_sb;

		logic [FIFO_WIDTH-1:0] fifo_queue[$];
    	logic [FIFO_WIDTH-1:0] data_out_ref;
		logic [3:0] fifo_count;
		integer correct_counter=0;
		integer error_counter=0;		

		function new(string name = "FIFO_scoreboard", uvm_component parent = null);
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			sb_export =new("sb_export",this);
			sb_fifo =new("sb_fifo",this);
		endfunction : build_phase

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			sb_export.connect(sb_fifo.analysis_export);
		endfunction : connect_phase

		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			forever begin
				sb_fifo.get(seq_item_sb);
				reference_model(seq_item_sb);
				if (seq_item_sb.data_out != data_out_ref) begin
					`uvm_error("run_phase", $sformatf("There is an error!!, Transacton received by the DUT is: %s whilethe refernce output is: 0b%0b",
					 seq_item_sb.convert2string_stimulus(), data_out_ref));
					error_counter++;
				end 
				else begin
					`uvm_info("run_phase", $sformatf("Correct Transacton received, Output is: %0b, compared to ref = %0b",
								 seq_item_sb.data_out,data_out_ref),UVM_LOW)
					correct_counter++;
				end
			end
		endtask : run_phase

		task reference_model(FIFO_sequence_item seq_item_chk);

    		if (!seq_item_chk.rst_n) begin
        		fifo_queue <= {}; 
        		fifo_count <= 0;
    		end
    		else begin
        		if (seq_item_chk.wr_en && fifo_count < FIFO_DEPTH) begin
            		fifo_queue.push_back(seq_item_chk.data_in);  
            		fifo_count <= fifo_queue.size();       
        		end

        
        		if (seq_item_chk.rd_en && fifo_count != 0) begin
            		data_out_ref <= fifo_queue.pop_front();
            		fifo_count <= fifo_queue.size();          
        		end
    		end
    	endtask : reference_model


		function void report_phase(uvm_phase phase);
			super.report_phase(phase);
			`uvm_info("report_phase", $sformatf("Total correct counts is: 0d%0d",correct_counter),UVM_LOW)
			`uvm_info("report_phase", $sformatf("Total error counts is: 0d%0d",error_counter),UVM_LOW)
		endfunction : report_phase
	endclass
endpackage