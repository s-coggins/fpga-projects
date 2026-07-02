/*
Title: 	MOTOR CONTROL (PROJECT TOP LEVEL)
Author: 	Sean Coggins
Date: 	7/2/2026
Version: 1.1

Change Log:
*v1.1 [7/2/26] 
-Creation of header block
-Added more comments per interview feedback
-Updated FSM instantiation to correctly use i_enable
--------------------------------------------------

FUNCTION:
-Top level project file to instantiate necessary modules
-Control DC motor speed
--------------------------------------------------

INPUTS (Designed for Terasic DE10-Lite / MAX 10):
i_clk_50MHz: 50 MHz system clock 
i_bu: push button to increase motor speed
i_bd: push button to decrease motor speed
i_reset: reset switch for FSM
--------------------------------------------------

OUTPUTS (Designed for Terasic DE10-Lite / MAX 10):
o_ld0-6: 	10s place (left) 7-segment display outputs
o_rd0-6: 	1s place (right) 7-segment display outputs
o_pwmspeed: PWM output wired to H-bridge->DC Motor
-------------------------------------------------- 

*NOTES:
-Assumes DC motor->H-bridge->DE-10 Lite wiring is correct
-Typical configuration is push buttons for speed control, switch for reset
-Speed changes in 15% increments, starting at 0% and ending at 90%
-Assumes both buttons are not pressed simultaneously, will exit/break FSM if both are pressed
-Buttons not debounced since clock is 1 Hz for FSM
-Moore selected for stable transitions and design clarity, Mealy responsiveness not needed here 
--------------------------------------------------
*/


module motorcontrol(
		input i_clk_50MHz, 
		input i_bu, 
		input i_bd, 
		input i_reset, 
		output o_ld0, 
		output o_ld1,
		output o_ld2,
		output o_ld3,
		output o_ld4,
		output o_ld5,
		output o_ld6,
		output o_rd0, 
		output o_rd1,
		output o_rd2,
		output o_rd3,
		output o_rd4,
		output o_rd5,
		output o_rd6,
		output o_pwmspeed
	);
	
	wire w_fsm_enable;
	wire w_pwm_enable;
	wire [2:0] w_state;
	wire [3:0] w_cv;
	wire [3:0] w_lD;
	wire [3:0] w_rD;
	wire [6:0] w_leftD;
	wire [6:0] w_rightD;
	
	//instantiate 100 kHz FD for PWM
	fd fd_1 (.i_clk_50MHz(i_clk_50MHz), .o_clk_enable(w_pwm_enable));
	
	//instantiate 1 Hz enable for FSM
	slow_clock fd_2 (.i_clk_50MHz(i_clk_50MHz), .o_clk_enable(w_fsm_enable));
	
	//instantiate FSM
	fsm fsm_1 (.i_u(i_bu), .i_d(i_bd), .i_clk(i_clk_50MHz), .i_reset(i_reset), .i_enable(w_fsm_enable), .r_state(w_state), .o_cv(w_cv), .r_leftDigit(w_lD), .r_rightDigit(w_rD));
		
	//instantiate PWM
	pwm pwm_1 (.i_clk(i_clk_50MHz), .i_enable(w_pwm_enable), .i_cv(w_cv), .o_speed(o_pwmspeed));
	
	//instantiate 7-segment decoders
	seven_seg_decoder left (.i_hex(w_lD), .o_seg(w_leftD));
	seven_seg_decoder right (.i_hex(w_rD), .o_seg(w_rightD));

	//intentional bit reversal to match DE-10 lite segment ordering
	assign o_ld0 = w_leftD[6];
	assign o_ld1 = w_leftD[5];
	assign o_ld2 = w_leftD[4];
	assign o_ld3 = w_leftD[3];
	assign o_ld4 = w_leftD[2];
	assign o_ld5 = w_leftD[1];
	assign o_ld6 = w_leftD[0];
	

	assign o_rd0 = w_rightD[6];
	assign o_rd1 = w_rightD[5];
	assign o_rd2 = w_rightD[4];
	assign o_rd3 = w_rightD[3];
	assign o_rd4 = w_rightD[2];
	assign o_rd5 = w_rightD[1];
	assign o_rd6 = w_rightD[0];
	
endmodule
	
