
module pwm(
		input i_clk,
		input i_cv,
		output reg o_speed
	);
	
	reg [3:0] r_count = 4'd0;	

	always@(posedge i_clk) begin
		
		if (r_count <= i_cv)
			o_speed <= 1'b1;
		else
			o_speed <= 1'b0;
		r_count <= r_count + 1;
	end
	
	
endmodule