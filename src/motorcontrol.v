




module motorcontrol(
		input i_clk_50MHz, //50 MHz for FD to 100 kHz
		input i_bu, //up/top button
		input i_bd, //down/bottom button
		input i_reset, //reset switch
		output o_ld0, //left segments
		output o_ld1,
		output o_ld2,
		output o_ld3,
		output o_ld4,
		output o_ld5,
		output o_ld6,
		output o_rd0, //right segments
		output o_rd1,
		output o_rd2,
		output o_rd3,
		output o_rd4,
		output o_rd5,
		output o_rd6,
		output o_pwmspeed
		//add h-bridge output from PWM
		
	);
	
	wire r_fd_clk;
	wire r_slow_clk;
	wire [2:0] r_state;
	wire [3:0] r_cv;
	wire [3:0] r_lD;
	wire [3:0] r_rD;
	wire [6:0] r_leftD;
	wire [6:0] r_rightD;
	//instantiate FD
	fd fd_1 (.i_clk_50MHz(i_clk_50MHz), .o_clk_out(r_fd_clk));
	slow_clock fd_2 (.i_clk_50MHz(i_clk_50MHz), .o_clk_out(r_slow_clk));
	//instantiate FSM
	fsm fsm_1 (.i_u(i_bu), .i_d(i_bd), .i_clk(r_slow_clk), .i_reset(i_reset), .r_state(r_state), .o_cv(r_cv), .r_leftDigit(r_lD), .r_rightDigit(r_rD));
		//leftDigit and rightDigit lead to 7 seg
		//CV leads to PWM
	//instantiate PWM
	pwm pwm_1 (.i_clk(r_fd_clk), .i_cv(r_cv), .o_speed(o_pwmspeed));
	//instantiate PWM
		//0_speed leads to h_bridge pins
	seven_seg_decoder left (.i_hex(r_lD), .o_seg(r_leftD));
	seven_seg_decoder right (.i_hex(r_rD), .o_seg(r_rightD));

	assign o_ld0 = r_leftD[6];
	assign o_ld1 = r_leftD[5];
	assign o_ld2 = r_leftD[4];
	assign o_ld3 = r_leftD[3];
	assign o_ld4 = r_leftD[2];
	assign o_ld5 = r_leftD[1];
	assign o_ld6 = r_leftD[0];
	

	assign o_rd0 = r_rightD[6];
	assign o_rd1 = r_rightD[5];
	assign o_rd2 = r_rightD[4];
	assign o_rd3 = r_rightD[3];
	assign o_rd4 = r_rightD[2];
	assign o_rd5 = r_rightD[1];
	assign o_rd6 = r_rightD[0];
	
endmodule
	
