
module demux_1_to_4_tb();

	reg r_sel0 = 1'b0, r_sel1 = 1'b0; 
	reg r_data = 1'b0;
	wire w_data0, w_data1, w_data2, w_data3;
	
	demux_1_to_4 UUT (.i_sel0(r_sel0),
							.i_sel1(r_sel1),
							.i_data(r_data),
							.o_data0(w_data0),
							.o_data1(w_data1),
							.o_data2(w_data2),
							.o_data3(w_data3));
							
	task set_sel (input reg [1:0] sel);
	
		#1;
		r_sel0 = sel[0];
		r_sel1 = sel[1];
		#1;
	
	endtask
	
	initial 
	begin
	
		set_sel(0);
		assert (w_data0 == r_data);
		set_sel(1);
		assert (w_data1 == r_data);
		set_sel(2);
		assert (w_data2 == r_data);
		set_sel(3);
		assert (w_data3 == r_data);
		$finish;
	
	end
	
endmodule