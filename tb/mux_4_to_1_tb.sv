
module mux_4_to_1_tb();

	reg r_sel0 = 1'b0, r_sel1 = 1'b0; 
	reg r_data0 = 1'b0, r_data1 = 1'b0, r_data2 = 1'b0, r_data3 = 1'b0;
	wire w_dataOut;
	
	mux_4_to_1 UUT (.i_sel0(r_sel0),
						 .i_sel1(r_sel1),
						 .i_data0(r_data0),
						 .i_data1(r_data1),
						 .i_data2(r_data2),
						 .i_data3(r_data3),
						 .o_data(w_dataOut));
	//takes input and drives select inputs
	task set_sel(input reg[1:0] sel);
		#1;
		r_sel0 = sel[0];
		r_sel1 = sel[1];
		#1;
	endtask
	
	
	initial
	begin
			set_sel(0);
			assert (w_dataOut == r_data0);
			set_sel(1);
			assert (w_dataOut == r_data1);
			set_sel(2);
			assert (w_dataOut == r_data2);
			set_sel(3);
			assert (w_dataOut == r_data3);
			$finish();
	end
	
endmodule