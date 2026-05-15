//50 MHz to 1Hz 
module slow_clock(
		input i_clk_50MHz,
		output reg o_clk_out
	);
	
	reg [25:0] r_clk_count = 26'd0;
	//o_clk_out = 1'b0;
	
	always@(posedge i_clk_50MHz) 
	begin
			if (r_clk_count == (50000000-1))
			begin 
				o_clk_out <= 1'b1;
				r_clk_count <= 0;
			end
			else 
			begin
				r_clk_count <= r_clk_count + 1;
				o_clk_out <= 1'b0;
			end
	end

endmodule	