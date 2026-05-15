//use demux and counter (instead of LFSR) to make simple blinking led select
module Demux_Counter_project_top 
	(input i_clk,
	input i_sw0,
	input i_sw1,
	output o_led0,
	output o_led1,
	output o_led2,
	output o_led3);
	
	localparam COUNT_LIMIT = 16777215;
	wire w_counter_toggle;
	
	//24 bit LFSR equivalent  
	count_toggler #(.COUNT_LIMIT(COUNT_LIMIT)) CT_inst
	(.i_clk(i_clk),
	 .i_en(1'b1),
	 .o_toggle(w_counter_toggle));
	
	demux_1_to_4 demux_inst
	(.i_sel0(i_sw0),
	 .i_sel1(i_sw1),
	 .i_data(w_counter_toggle),
	 .o_data0(o_led0),
	 .o_data1(o_led1),
	 .o_data2(o_led2),
	 .o_data3(o_led3));

endmodule