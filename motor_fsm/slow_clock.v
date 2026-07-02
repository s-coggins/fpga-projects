/*
Title: 	SLOW CLOCK (1s)
Author: 	Sean Coggins
Date: 	7/2/2026
Version: 1.1

Change Log:
*v1.1 [7/2/26] 
-Creation of header block
-Added more comments per interview feedback
--------------------------------------------------

FUNCTION:
-Create a 1 Hz clock enable to drive FSM state transitions
-Divide 50 MHz MAX 10 system clock to 1 Hz
-Achieved via clock enable
--------------------------------------------------

INPUTS (Designed for Terasic DE10-Lite / MAX 10):
i_clk_50MHz: MAX 10 50 MHz system clock
--------------------------------------------------

OUTPUTS (Designed for Terasic DE10-Lite / MAX 10):
o_clk_enable: clock enable output (every 1 Hz)
-------------------------------------------------- 

*NOTES:
-N/A
--------------------------------------------------
*/

module slow_clock(
		input i_clk_50MHz,
		output reg o_clk_enable = 1'b0
	);
	
	reg [25:0] r_clk_count = 26'd0;
	
	always@(posedge i_clk_50MHz) begin
		if (r_clk_count == (50000000-1)) begin 
			o_clk_enable <= 1'b1;
			r_clk_count  <= 26'd0;
		end else begin
			r_clk_count  <= r_clk_count + 1;
			o_clk_enable <= 1'b0;
		end
	end

endmodule	