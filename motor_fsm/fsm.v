//FSM

module fsm
	(
		input i_u,
		input i_d,
		input i_clk,
		input i_reset,
		output reg [2:0] r_state, //q or ff output (current state)
		output reg [3:0] o_cv,
		output reg [3:0] r_leftDigit, 
		output reg [3:0] r_rightDigit 
	);
	
	reg [2:0] r_ns; //d or ff input (next state)
	localparam s0 = 3'b000, 
				  s1 = 3'b001,
				  s2 = 3'b010,
				  s3 = 3'b011,
				  s4 = 3'b100,
				  s5 = 3'b101,
				  s6 = 3'b110;
	//sequential (current state) output logic
	always@(posedge i_clk or posedge i_reset) begin
		if(i_reset) begin
			r_state <= s0;
		end else begin
			r_state <= r_ns;
		end
	end


	//combinational Moore NS logic
	always@(*) begin
		r_ns = r_state;
		r_leftDigit = 4'd0;
		r_rightDigit= 4'd0;
		o_cv = 4'd0;
		case (r_state)
			s0 : begin
				      r_ns = (~i_u & i_d) ? s1: s0;
						r_leftDigit = 4'd0;
						r_rightDigit = 4'd0;
						o_cv = 4'd0;
				  end
			s1 : begin
						r_ns = (i_u & ~i_d) ? s0 : (~i_u & i_d) ? s2 : s1;
						r_leftDigit = 4'd1;
						r_rightDigit = 4'd5;
						o_cv = 4'd2;
				  end
			s2 : begin
						r_ns = (i_u & ~i_d) ? s1 : (~i_u & i_d) ? s3 : s2;
						r_leftDigit = 4'd3;
						r_rightDigit = 4'd0;
						o_cv = 4'd4;
				  end
			s3 : begin
						r_ns = (i_u & ~i_d) ? s2 : (~i_u & i_d) ? s4 : s3;
						r_leftDigit = 4'd4;
						r_rightDigit = 4'd5;
						o_cv = 4'd6;
				  end
			s4 : begin
						r_ns = (i_u & ~i_d) ? s3 : (~i_u & i_d) ? s5 : s4;
						r_leftDigit = 4'd6;
						r_rightDigit = 4'd0;
						o_cv = 4'd8;
				  end
			s5 : begin
						r_ns = (i_u & ~i_d) ? s4 : (~i_u & i_d) ? s6 : s5;
						r_leftDigit = 4'd7;
						r_rightDigit = 4'd5;
						o_cv = 4'd11;
					end
			s6 : begin 
						r_ns = (i_u & ~i_d) ? s5: s6;
						r_leftDigit = 4'd9;
						r_rightDigit = 4'd0;
						o_cv = 4'd14;
					end
			default : begin
						     r_ns =  s0;
							  r_leftDigit = 4'd0;
							  r_rightDigit = 4'd0;
							  o_cv = 4'd0;
						 end
		endcase
	end	
endmodule