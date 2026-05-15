//50 MHz to 100kHz (mod 500)
module fd(
		input i_clk_50MHz,
		output reg o_clk_out
	);
	
	reg [8:0] r_clk_count = 9'b000000000;
	//o_clk_out = 1'b0;
	
	always@(posedge i_clk_50MHz) 
	begin
			if (r_clk_count == 249)
			begin
				r_clk_count <= 0;
				o_clk_out <= ~o_clk_out;
			end
			else 
			begin
				r_clk_count <= r_clk_count + 1;
			end
	end

endmodule	