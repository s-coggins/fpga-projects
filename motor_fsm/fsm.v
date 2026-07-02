/*
Title: 	FSM
Author: 	Sean Coggins
Date: 	7/2/2026
Version: 1.1

Change Log:
*v1.1 [7/2/26] 
-Creation of header block
-Added more comments per interview feedback
-fixed accidental derived clock in sequential always block; changed to clock enable
--------------------------------------------------

FUNCTION:
Motor Control Moore FSM - 7 States
State:  s0,  s1,  s2,  s3,  s4, s5,  s6 
Speed: 00%, 15%, 30%, 45%, 60%, 75%, 90%

Traditional approach - separated combinational and sequential logic into two always blocks
*Typically better to use modern approach of single case statement to avoid accidentally inferring latches
--------------------------------------------------

INPUTS (Designed for Terasic DE10-Lite / MAX 10):
i_u: 	    Push Button to speed up  (increase state, active LOW)
i_d: 	    Push Button to slow down (decrease state, active LOW)
i_clk:    Internal MAX 10 50 MHz clock
i_reset:  Switch to reset speed to 0% and initialize to s0 on startup
i_enable: 1 Hz clock enable using 50 MHz clock
--------------------------------------------------

OUTPUTS (Designed for Terasic DE10-Lite / MAX 10):
r_state: 	  3-bit value representing current state of 7 in binary
o_cv: 	     4-bit Compare value, State output sent to pwm.v speed control (value compared against counter in PWM)
r_leftDigit:  4-bit Ten's place digit (0-9) for speed %, to be sent to 7seg.v and displayed on 7-segment display
r_rightDigit: 4-bit One's place digit (0-9) for speed %, to be sent to 7seg.v and displayed on 7-segment display
-------------------------------------------------- 

*NOTES:
-Speed changes in 15% increments, maxing out at 90%
-Assumes both buttons are not pressed simultaneously, will exit/break FSM if both are pressed
-Buttons not debounced since clock is 1s for FSM
-Moore selected for stable transitions and design clarity, Mealy responsiveness not needed here 
-4-bit PWM resolution selected, CV rounded to closest speed, increase bits for higher resolution (finer speed control)
-Less-Than PWM comparison formula used: (CV / 2^N) x 100 = Duty Cycle%
-E.g., (2/16)x100 = 12.5% DC, closer to desired 15% than CV of 3, so 2 is selected for s1
--------------------------------------------------
*/

module fsm
	(
		input i_u, 
		input i_d,
		input i_clk,
		input i_reset,
		input i_enable,
		output reg [2:0] r_state, //q or ff output (current state)
		output reg [3:0] o_cv,
		output reg [3:0] r_leftDigit, 
		output reg [3:0] r_rightDigit 
	);
	
	reg [2:0] r_ns; //d or ff input (next state)
	localparam s0 = 3'b000, //represent states as 3-bit binary for easy coding
				  s1 = 3'b001,
				  s2 = 3'b010,
				  s3 = 3'b011,
				  s4 = 3'b100,
				  s5 = 3'b101,
				  s6 = 3'b110;
				  
	//sequential (current state) output logic to handle state transitions
	always@(posedge i_clk or posedge i_reset) begin
		if(i_reset)  	
			r_state <= s0; 	
		else if(i_enable)  //only update on 1 Hz clock enable		
			r_state <= r_ns;	
	end


	//combinational Moore Next State logic to handle output logic
	always@(*) begin 
		r_ns = r_state; 		//set next state to current state
		r_leftDigit = 4'd0;	//initialize output regs to 0 just in case
		r_rightDigit= 4'd0;	
		o_cv = 4'd0;
		case (r_state)									//check current state
			s0 : begin									//if in state 0
				      r_ns = (~i_u & i_d) ? s1:	//set NS to s1 if pressing up, 
													 s0;	//otherwise maintain s0 
						r_leftDigit = 4'd0;
						r_rightDigit = 4'd0;			//display '00' in s0 on 7-segment display
						o_cv = 4'd0;					//s0 CV = 0 (0% DC)
				  end
			s1 : begin									//States 1-5 have similar behavior: if in state 'X':
						r_ns = (i_u & ~i_d) ? s0 : //set NS to s'X'-1 if pressing down,
								 (~i_u & i_d) ? s2 : //s'X'+1 if pressing up,
													  s1;	//otherwise maintain s'X'
						r_leftDigit = 4'd1;											
						r_rightDigit = 4'd5;			//7-seg = '15'			
						o_cv = 4'd2;					//s1 CV = 2 (12.5% DC)
				  end
			s2 : begin									//see s1 comment								
						r_ns = (i_u & ~i_d) ? s1 :
								 (~i_u & i_d) ? s3 :
													  s2;
						r_leftDigit = 4'd3;
						r_rightDigit = 4'd0;			//7-seg = '30'
						o_cv = 4'd5;					//s2 CV = 5 (31.25% DC)
				  end
			s3 : begin									//see s1 comment
						r_ns = (i_u & ~i_d) ? s2 :
						       (~i_u & i_d) ? s4 :
						                       s3;
						r_leftDigit = 4'd4;
						r_rightDigit = 4'd5;			//7-seg = 45
						o_cv = 4'd7;					//s3 CV = 7 (43.75% DC)
				  end
			s4 : begin									//see s1 comment
						r_ns = (i_u & ~i_d) ? s3 :
						       (~i_u & i_d) ? s5 :
						                       s4;
						r_leftDigit = 4'd6;
						r_rightDigit = 4'd0;			//7-seg = 60
						o_cv = 4'd10;					//s4 CV = 10 (62.5% DC)
				  end
			s5 : begin									//see s1 comment
						r_ns = (i_u & ~i_d) ? s4 : 
						       (~i_u & i_d) ? s6 :
						                       s5;
						r_leftDigit = 4'd7;
						r_rightDigit = 4'd5;			//7-seg = 75
						o_cv = 4'd12;					//s5 CV = 12 (75% DC)
					end	
			s6 : begin 									//if in state 6 (final state)
						r_ns = (i_u & ~i_d) ? s5:	//set NS to s5 if pressing down,
						                      s6;	//otherwise maintain s6
						r_leftDigit = 4'd9;											
						r_rightDigit = 4'd0;			//7-seg = 90 
						o_cv = 4'd14;					//s6 CV = 14 (87.5% DC)
					end
			default : begin							//default outputs to 0 to ensure no latching is inferred
						     r_ns =  s0;				
							  r_leftDigit = 4'd0;
							  r_rightDigit = 4'd0;
							  o_cv = 4'd0;
					end
		endcase
	end	
endmodule