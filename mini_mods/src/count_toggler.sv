//toggle after counting
module count_toggler #(COUNT_LIMIT = 10)
	(input i_clk,
	 input i_en,
	 output reg o_toggle);
	 
	 //ceiling log base 2 for dynamic bit scaling
	 reg [$clog2(COUNT_LIMIT-1):0] r_counter;
	 
	always @(posedge i_clk)
	begin
		if (i_en == 1'b1)
		begin
			if (r_counter == COUNT_LIMIT - 1)
			begin
				o_toggle <= !o_toggle;
				r_counter <= 0;
			end
			else
				r_counter <= r_counter + 1;
		end
	end
endmodule