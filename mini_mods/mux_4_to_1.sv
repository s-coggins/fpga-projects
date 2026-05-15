
module mux_4_to_1(
	input i_sel0,
	input i_sel1,
	input i_data0,
	input i_data1,
	input i_data2,
	input i_data3,
	output o_data);
	
	assign o_data = !i_sel1 & !i_sel0 ? i_data0 : 
						 !i_sel1 &  i_sel0 ? i_data1 :
						  i_sel1 & !i_sel0 ? i_data2 : i_data3;
						 
endmodule