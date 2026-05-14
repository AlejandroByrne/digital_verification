package FIFO_test_pkg;
	import FIFO_env_pkg::*;
	import FIFO_driver_pkg::*;
	import FIFO_config_pkg::*;
	import FIFO_rd_wr_sequence_pkg::*;
	import FIFO_reset_sequence_pkg::*;
	import FIFO_write_sequence_pkg::*;
	import FIFO_read_sequence_pkg::*;
	import FIFO_agent_pkg::*;
	
	import MySequencer_pkg::*;
	
	import uvm_pkg::*;
	`include "uvm_macros.svh"

	class FIFO_test extends uvm_test ;
		`uvm_component_utils(FIFO_test)

		FIFO_env env;
		FIFO_config FIFO_cfg;
		virtual FIFO_if FIFO_Vif;
		FIFO_reset_sequence reset_seq;
		FIFO_rd_wr_sequence rd_wr_seq;
		FIFO_read_sequence read_seq;
		FIFO_write_sequence write_seq;

		function new(string name = "FIFO_test", uvm_component parent = null);
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			env = FIFO_env::type_id::create("env",this); 
			FIFO_cfg = FIFO_config::type_id::create("FIFO_cfg"); 
			reset_seq = FIFO_reset_sequence::type_id::create("reset_seq");
			rd_wr_seq = FIFO_rd_wr_sequence::type_id::create("rd_wr_seq");
			read_seq = FIFO_read_sequence::type_id::create("read_seq");
			write_seq = FIFO_write_sequence::type_id::create("write_seq");


			if (!uvm_config_db #(virtual FIFO_if)::get(this,"","FIFO_Vif",FIFO_cfg.FIFO_Vif)) begin
			 			`uvm_fatal("build_phase","Test - unable to get the virtual interface");
			 end

			uvm_config_db #(FIFO_config)::set(this,"*","CFG",FIFO_cfg); 		
		endfunction 

		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			phase.raise_objection(this);

			reset_seq.start(env.agt.sqr);
			`uvm_info("run_phase","Reset asserted", UVM_LOW)

			repeat(100)begin

				write_seq.start(env.agt.sqr);
				`uvm_info("run_phase","write only asserted", UVM_LOW)
				
				read_seq.start(env.agt.sqr);
				`uvm_info("run_phase","Read only asserted", UVM_LOW)

				
			end
			
			rd_wr_seq.start(env.agt.sqr);
			`uvm_info("run_phase","Stimulus generation started", UVM_LOW)

			phase.drop_objection(this);
		endtask 
	endclass 
endpackage
