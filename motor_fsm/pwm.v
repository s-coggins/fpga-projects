/*
Title: 	PWM
Author: 	Sean Coggins
Date: 	7/2/2026
Version: 1.1

Change Log:
*v1.1 [7/2/26] 
-Creation of header block
-Added more comments per interview feedback
-Enable triggered instead of derived clock
--------------------------------------------------

FUNCTION:
-Provide Duty Cycle % to H-bridge->DC Motor
-Achieved via clock enable
--------------------------------------------------

INPUTS (Designed for Terasic DE10-Lite / MAX 10):
i_clk: 	 MAX 10 50 MHz system clock
i_enable: 100 kHz FD clock enable signal
i_cv:		 4-bit FSM Compare Values to determine motor duty cycle %
--------------------------------------------------

OUTPUTS (Designed for Terasic DE10-Lite / MAX 10):
o_speed:  1-bit (duty cycle %) driving DC motor
-------------------------------------------------- 

*NOTES:
-N/A
--------------------------------------------------
*/

module pwm(
		input i_clk,
		input i_enable,
		input [3:0] i_cv,
		output reg o_speed = 1'b0
	);
	
	reg [3:0] r_count = 4'd0;	

	always@(posedge i_clk) begin
		if(i_enable) begin		//during 100 kHz enable
			if (r_count < i_cv) 
				o_speed <= 1'b1;
			else
				o_speed <= 1'b0;
			r_count <= r_count + 1;
		end
	end
	
	
endmodule