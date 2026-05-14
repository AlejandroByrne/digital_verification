import FIFO_test_pkg::*;
import FIFO_env_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

module top();
	bit clk;
	initial begin
		clk=1;
		forever 
			#1 clk=~clk;
	end

	FIFO_if FIFO_Vif (clk);
	FIFO DUT (FIFO_Vif);


	bind FIFO FIFO_SVA SVA (FIFO_Vif);

	initial begin
		uvm_config_db #(virtual FIFO_if)::set(null, "uvm_test_top", "FIFO_Vif", FIFO_Vif);
		run_test("FIFO_test");
	end

endmodule	