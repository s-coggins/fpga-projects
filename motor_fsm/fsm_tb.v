`timescale 1us/1ns

module fsm_tb;

	reg r_u;
	reg r_d;
	reg r_clk;
	reg r_reset;
	reg r_enable;
	wire [2:0] w_state;
	wire [3:0] w_cv;
	wire [3:0] w_leftDigit;
	wire [3:0] w_rightDigit;
	
	fsm U1 (.i_u(r_u), .i_d(r_d), .i_clk(r_clk),.i_reset(r_reset), .i_enable(r_enable),
			  .r_state(w_state), .r_leftDigit(w_leftDigit), .r_rightDigit(w_rightDigit), .o_cv(w_cv));
			  
	initial r_clk = 0;
	always #5 r_clk = ~r_clk;
	
	initial begin 
		//initialize inputs
		r_reset = 1;
		r_u = 1;
		r_d = 1;
		r_enable = 1; //bypass 1 Hz clock for FSM testing
		#10;
		//Test: increase speed through all states
		r_reset = 0;
		r_u = 0;
		r_d = 1;
		#80;
		//Test: decrease speed through all states
		r_u = 1;
		r_d = 0;
		#80;
		
		$stop;
		
	end 
endmodule
		
		
	
