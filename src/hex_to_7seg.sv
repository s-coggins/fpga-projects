// hex to 7-segment
module hex_to_7seg
	(input [3:0] i_hex,
	 output [6:0] o_segments
	);
	
	reg [6:0] r_seg = 7'b0000000;
	
	always @(*)
		case(i_hex)
			4'h0 : r_seg <= 7'b1000000;
			4'h1 : r_seg <= 7'b1111001;
			4'h2 : r_seg <= 7'b0100100;
			4'h3 : r_seg <= 7'b0110000;
			4'h4 : r_seg <= 7'b0011001;
			4'h5 : r_seg <= 7'b0010010;
			4'h6 : r_seg <= 7'b0000010;
			4'h7 : r_seg <= 7'b1111000;
			4'h8 : r_seg <= 7'b0000000;
			4'h9 : r_seg <= 7'b0011000;
			4'hA : r_seg <= 7'b0001000;
			4'hB : r_seg <= 7'b0000011;
			4'hC : r_seg <= 7'b1000110;
			4'hD : r_seg <= 7'b0100001;
			4'hE : r_seg <= 7'b0000110;
			4'hF : r_seg <= 7'b0001110;
		endcase
	
	assign o_segments = r_seg;
	
endmodule