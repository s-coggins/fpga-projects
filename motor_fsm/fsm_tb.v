
`timescale 1us/1ns

module fsm_tb;

	reg r_u;
	reg r_d;
	reg r_clk;
	reg r_reset;
	wire [2:0] w_state;
	wire [3:0] w_cv;
	wire [3:0] w_leftDigit;
	wire [3:0] w_rightDigit;
	
	fsm U1 (.i_u(r_u), .i_d(r_d), .i_clk(r_clk),.i_reset(r_reset),
			  .r_state(w_state), .r_leftDigit(w_leftDigit), .r_rightDigit(w_rightDigit), .o_cv(w_cv));
			  
	initial r_clk = 0;
	always #5 r_clk = ~r_clk;
	
	initial begin 
		r_reset = 1;
		r_u = 1;
		r_d = 1;
		#10;
		
		r_reset = 0;
		r_u = 0;
		r_d = 1;
		#80;
		
		r_u = 1;
		r_d = 0;
		#80;
		
		$stop;
		
	end 
endmodule
		
		
	
