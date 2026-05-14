package FIFO_coverage_pkg;
	import uvm_pkg::*;
	import FIFO_shared_pkg::*;
	import FIFO_sequence_item_pkg::*;
	`include "uvm_macros.svh"
	class FIFO_coverage extends uvm_component;
		`uvm_component_utils(FIFO_coverage)
		uvm_analysis_export #(FIFO_sequence_item) cov_export;
		uvm_tlm_analysis_fifo #(FIFO_sequence_item) cov_fifo;
		FIFO_sequence_item seq_item_cov;

		covergroup cvr_gp();

			wr_cp: coverpoint seq_item_cov.wr_en;
			rd_cp: coverpoint seq_item_cov.rd_en;
			wr_ack_cp: coverpoint seq_item_cov.wr_ack;
			overflow_cp: coverpoint seq_item_cov.overflow;
			underflow_cp: coverpoint seq_item_cov.underflow;
			full_cp: coverpoint seq_item_cov.full;

			cross_0: cross wr_cp, rd_cp, wr_ack_cp {
    			ignore_bins wr_en_low_wr_ack_high = binsof(wr_cp) intersect {0} && binsof(wr_ack_cp) intersect {1};
			}

			cross_1: cross wr_cp, rd_cp, overflow_cp{
				ignore_bins wr_en_low_overflow = binsof(wr_cp) intersect {0} && binsof(overflow_cp) intersect {1};
			}
			cross_2: cross wr_cp, rd_cp, full_cp{
				ignore_bins wr_en_low_full = binsof(wr_cp) intersect {0} && binsof(rd_cp) intersect {1} && binsof(full_cp) intersect {1};
				ignore_bins wr_en_high_full = binsof(wr_cp) intersect {1} && binsof(rd_cp) intersect {1} && binsof(full_cp) intersect {1};
			}
			cross_3: cross wr_cp, rd_cp, underflow_cp {
  				ignore_bins rd_en_0_underflow_1 = binsof(rd_cp) intersect {0} && binsof(underflow_cp) intersect {1};
			}
			cross_4: cross seq_item_cov.wr_en, seq_item_cov.rd_en, seq_item_cov.empty;
			cross_5: cross seq_item_cov.wr_en, seq_item_cov.rd_en, seq_item_cov.almostfull;
			cross_6: cross seq_item_cov.wr_en, seq_item_cov.rd_en, seq_item_cov.almostempty;

		endgroup 

		function new(string name = "FIFO_coverage", uvm_component parent = null);
			super.new(name,parent);
			cvr_gp=new();
		endfunction

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			cov_export =new("cov_export",this);
			cov_fifo =new("cov_fifo",this);
		endfunction : build_phase

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			cov_export.connect(cov_fifo.analysis_export);
		endfunction : connect_phase

		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			forever begin
				cov_fifo.get(seq_item_cov);
				cvr_gp.sample();
			end
		endtask : run_phase


	endclass
endpackage