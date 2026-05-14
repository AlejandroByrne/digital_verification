module FIFO_SVA (FIFO_if.DUT FIFO_Vif);

    logic [FIFO_Vif.FIFO_WIDTH-1:0] data_fifo[$];
    logic [FIFO_Vif.FIFO_WIDTH-1:0] data_ref;




    property p_1;
    	@(posedge FIFO_Vif.clk) disable iff (!FIFO_Vif.rst_n) (FIFO_Vif.rd_en && !FIFO_Vif.empty && (data_fifo.size() > 0)) |-> (FIFO_Vif.data_out === data_ref);
	endproperty

    property p_2;
    	@(posedge FIFO_Vif.clk) disable iff (!FIFO_Vif.rst_n) (FIFO_Vif.full && FIFO_Vif.wr_en) |=> (FIFO_Vif.overflow);
	endproperty

	property p_3;
    	@(posedge FIFO_Vif.clk) disable iff (!FIFO_Vif.rst_n) (FIFO_Vif.empty && FIFO_Vif.rd_en) |=> (FIFO_Vif.underflow);
	endproperty

	property p_4;
    	@(posedge FIFO_Vif.clk) disable iff (!FIFO_Vif.rst_n) (data_fifo.size() == FIFO_Vif.FIFO_DEPTH) |-> (FIFO_Vif.full);
	endproperty

	property p_5;
    	@(posedge FIFO_Vif.clk) disable iff (!FIFO_Vif.rst_n) (data_fifo.size()== 0) |-> (FIFO_Vif.empty);
	endproperty

	property p_6;
    	@(posedge FIFO_Vif.clk) disable iff (!FIFO_Vif.rst_n) (data_fifo.size()== (FIFO_Vif.FIFO_DEPTH-1'b1)) |-> (FIFO_Vif.almostfull);
	endproperty

	property p_7;
    	@(posedge FIFO_Vif.clk) disable iff (!FIFO_Vif.rst_n) (data_fifo.size() == 1) |-> (FIFO_Vif.almostempty);
	endproperty

	property p_8;
    	@(posedge FIFO_Vif.clk) disable iff (!FIFO_Vif.rst_n) (FIFO_Vif.wr_en && (data_fifo.size()< FIFO_Vif.FIFO_DEPTH)) |=> (FIFO_Vif.wr_ack);
	endproperty

    always @(posedge FIFO_Vif.clk or negedge FIFO_Vif.rst_n) begin
        if (!FIFO_Vif.rst_n) begin
            data_fifo <= {};
        end
        else begin

            if (FIFO_Vif.wr_en && !FIFO_Vif.full) begin
                data_fifo.push_back(FIFO_Vif.data_in);
                
            end
            
            if (FIFO_Vif.rd_en && !FIFO_Vif.empty) begin
                if (data_fifo.size() > 0) begin
                	 data_ref <= data_fifo[0];
                     data_fifo.pop_front();
                end
            end
        end
    end

		AP: assert property (p_1) else $display("p_1 failed");
		BP: assert property (p_2) else $display("p_2 failed");
		CP: assert property (p_3) else $display("p_3 failed");
		DP: assert property (p_4) else $display("p_4 failed");
		EP: assert property (p_5) else $display("p_5 failed");
		FP: assert property (p_6) else $display("p_6 failed");
		GP: assert property (p_7) else $display("p_7 failed");
		HP: assert property (p_8) else $display("p_8 failed");

		
		Ac: cover property (p_1)  $display("p_1 pass");
		Bc: cover property (p_2)  $display("p_2 pass");
		Cc: cover property (p_3)  $display("p_3 pass");
		Dc: cover property (p_4)  $display("p_4 pass");
		Ec: cover property (p_5)  $display("p_5 pass");
		Fc: cover property (p_6)  $display("p_6 pass");
		Gc: cover property (p_7)  $display("p_7 pass");
		Hc: cover property (p_8)  $display("p_8 pass");
		

endmodule
