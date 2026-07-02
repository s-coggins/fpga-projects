/*
Title: 	FD (Frequency Divider)
Author: 	Sean Coggins
Date: 	7/2/2026
Version: 1.1

Change Log:
*v1.1 [7/2/26] 
-Creation of header block
-Added more comments per interview feedback
-Changed from derived clock to clock enable
--------------------------------------------------

FUNCTION:
-Provide 100 kHz clock enable for PWM functionality
-Divide 50 MHz MAX 10 system clock to 100 kHz
--------------------------------------------------

INPUTS (Designed for Terasic DE10-Lite / MAX 10):
i_clk_50MHz: MAX 10 50 MHz system clock
--------------------------------------------------

OUTPUTS (Designed for Terasic DE10-Lite / MAX 10):
o_clk_enable: clock enable output every 100 kHz
-------------------------------------------------- 

*NOTES:
-50 MHz to 100kHz (mod 500)
--------------------------------------------------
*/


module fd(
		input i_clk_50MHz,
		output reg o_clk_enable = 1'b0
	);
	
	reg [8:0] r_clk_count = 9'b000000000;
	
	
	
	always@(posedge i_clk_50MHz) begin
	
		if (r_clk_count == 499) begin   //500-cycle period
			 r_clk_count  <= 0;
			 o_clk_enable <= 1'b1;       //pulse high for one cycle
		end else begin
			 r_clk_count  <= r_clk_count + 1;
			 o_clk_enable <= 1'b0;
		end
	end

endmodule	