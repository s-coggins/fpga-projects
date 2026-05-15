//50 MHz clock = 20 ns period
//((2^24) - 1)*20ns = ~0.3 s LFSR toggle
module LFSR_24
	(input i_clk,
	output [23:0] o_LFSR_data,
	output o_LFSR_done);
	
	reg [23:0] r_LFSR = 24'd0;
	wire w_XNOR;
	
	always @(posedge i_clk)
	begin
		r_LFSR <= {r_LFSR[22:0], w_XNOR};
	end
	
	assign w_XNOR = r_LFSR[23] ^~ r_LFSR[22];
	assign o_LFSR_done = (r_LFSR == 24'd0);
	assign o_LFSR_data = r_LFSR;

endmodule