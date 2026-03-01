
module demux_1_to_4
	(input i_sel0,
	 input i_sel1,
	 input i_data,
	 output o_data0,
	 output o_data1,
	 output o_data2,
	 output o_data3);

	assign o_data0 = !i_sel1 & !i_sel0 ? i_data : 1'b0;
	assign o_data1 = !i_sel1 &  i_sel0 ? i_data : 1'b0;
	assign o_data2 =  i_sel1 & !i_sel0 ? i_data : 1'b0;
	assign o_data3 =  i_sel1 &  i_sel0 ? i_data : 1'b0;
	
endmodule