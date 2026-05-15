//use demux and LFSR to make simple blinking led select
module Demux_LFSR_project_top 
	(input i_clk,
	input i_sw0,
	input i_sw1,
	output o_led0,
	output o_led1,
	output o_led2,
	output o_led3);
	 
	reg r_LFSR_toggle = 1'b0;
	wire w_LFSR_done;
	 
	LFSR_24 LFSR_inst
	(.i_clk(i_clk),
	 .o_LFSR_data(), //not connected
	 .o_LFSR_done(w_LFSR_done));
	 
	always @(posedge i_clk)
	begin
		if (w_LFSR_done)
			r_LFSR_toggle <= !r_LFSR_toggle;
	end
	
	demux_1_to_4 demux_inst
	(.i_sel0(i_sw0),
	 .i_sel1(i_sw1),
	 .i_data(r_LFSR_toggle),
	 .o_data0(o_led0),
	 .o_data1(o_led1),
	 .o_data2(o_led2),
	 .o_data3(o_led3));

endmodule