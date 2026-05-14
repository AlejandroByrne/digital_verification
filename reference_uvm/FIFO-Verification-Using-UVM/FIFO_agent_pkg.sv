package FIFO_agent_pkg;
	import FIFO_driver_pkg::*;
	import MySequencer_pkg::*;
	import FIFO_config_pkg::*;
	import FIFO_monitor_pkg::*;
	import FIFO_sequence_item_pkg::*;
	
	import uvm_pkg::*;	
	`include "uvm_macros.svh"
	class FIFO_agent extends uvm_agent ;
		`uvm_component_utils(FIFO_agent)
		MySequencer sqr;
		FIFO_driver drv;
		FIFO_monitor mon;
		FIFO_config FIFO_cfg;
		uvm_analysis_port #(FIFO_sequence_item) agt_ap; 

		function new(string name = "FIFO_agent", uvm_component parent = null);
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			drv = FIFO_driver::type_id::create("drv",this);
			sqr = MySequencer::type_id::create("sqr",this);
			mon = FIFO_monitor::type_id::create("mon",this);
			agt_ap =new("agt_ap",this);
			if (!uvm_config_db #(FIFO_config)::get(this,"","CFG",FIFO_cfg)) begin
			 	`uvm_fatal("build_phase","Driver - unable to get configuration object");
			 end 	
		endfunction : build_phase

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			drv.seq_item_port.connect(sqr.seq_item_export);
			drv.FIFO_Vif=FIFO_cfg.FIFO_Vif;
			mon.FIFO_Vif=FIFO_cfg.FIFO_Vif;
			mon.mon_ap.connect(agt_ap);
		endfunction : connect_phase
	endclass
endpackage