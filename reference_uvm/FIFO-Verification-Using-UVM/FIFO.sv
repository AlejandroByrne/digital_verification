////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital VerifVifation using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////


module FIFO(FIFO_if.DUT FIFO_Vif);

localparam max_fifo_addr = $clog2(FIFO_Vif.FIFO_DEPTH);

reg [FIFO_Vif.FIFO_WIDTH-1:0] mem [FIFO_Vif.FIFO_DEPTH-1:0];
reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count; 

always @(posedge FIFO_Vif.clk or negedge FIFO_Vif.rst_n) begin
    if (!FIFO_Vif.rst_n) begin
        wr_ptr <= 0;
        FIFO_Vif.overflow<=0;
        FIFO_Vif.wr_ack<=0;
    end
    else if (FIFO_Vif.wr_en && count < FIFO_Vif.FIFO_DEPTH) begin
        mem[wr_ptr] <= FIFO_Vif.data_in;
        FIFO_Vif.wr_ack <= 1;
        wr_ptr <= wr_ptr + 1;
    end
    else begin 
        FIFO_Vif.wr_ack <= 0; 
        if (FIFO_Vif.full & FIFO_Vif.wr_en)
            FIFO_Vif.overflow <= 1;
        else
            FIFO_Vif.overflow <= 0;
    end
end

always @(posedge FIFO_Vif.clk or negedge FIFO_Vif.rst_n) begin
    if (!FIFO_Vif.rst_n) begin
        rd_ptr <= 0;
        FIFO_Vif.underflow<=0;
    end
    else if (FIFO_Vif.rd_en && count != 0) begin
        FIFO_Vif.data_out <= mem[rd_ptr];
        rd_ptr <= rd_ptr + 1;
    end
    else begin 
        if (FIFO_Vif.empty && FIFO_Vif.rd_en)begin
        	FIFO_Vif.underflow <= 1;
        end     
        else begin
            FIFO_Vif.underflow <= 0;   // underflow was modified to be sequential instead of combinational 	
        end
    end
end

always @(posedge FIFO_Vif.clk or negedge FIFO_Vif.rst_n) begin
    if (!FIFO_Vif.rst_n) begin
        count <= 0;
    end
    else begin
        if	(({FIFO_Vif.wr_en, FIFO_Vif.rd_en} == 2'b10) && !FIFO_Vif.full)
            count <= count + 1;
        else if (({FIFO_Vif.wr_en, FIFO_Vif.rd_en} == 2'b01) && !FIFO_Vif.empty)
            count <= count - 1;
        else if ({FIFO_Vif.wr_en, FIFO_Vif.rd_en} == 2'b11) begin // if condition was added to handle if the wr_en , rd_en are asserted at the same time
    		if (FIFO_Vif.full) begin
        		count <= count - 1;
    		end
            else if (FIFO_Vif.empty) begin
        		count <= count + 1;
    		end
		end
	end
end

assign FIFO_Vif.full = (count == FIFO_Vif.FIFO_DEPTH)? 1 : 0;
assign FIFO_Vif.empty = (count == 0)? 1 : 0;
assign FIFO_Vif.almostfull = (count == FIFO_Vif.FIFO_DEPTH-1)? 1 : 0;  // corrected to be -1  instead of -2
assign FIFO_Vif.almostempty = (count == 1)? 1 : 0;

endmodule
