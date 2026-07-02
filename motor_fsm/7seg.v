/*
Title: 	7SEG (DECODER)
Author: 	Sean Coggins
Date: 	7/2/2026
Version: 1.1

Change Log:
*v1.1 [7/2/26] 
-Creation of header block
-Added more comments per interview feedback
--------------------------------------------------

FUNCTION:
-Decode 4-bit input to corresponding 7-segment display value
-Displays 4-bit value as hex equivalent {0-9; a,b,c,d,e,f}
--------------------------------------------------

INPUTS (Designed for Terasic DE10-Lite / MAX 10):
i_hex: 4-bit hex value to be decoded
--------------------------------------------------

OUTPUTS (Designed for Terasic DE10-Lite / MAX 10):
o_seg: 7-bit output representing equivalent input on 7-segment display
-------------------------------------------------- 

*NOTES:
-7-segment display is common anode (active LOW to light up)
--------------------------------------------------
*/
module seven_seg_decoder(
    input  [3:0] i_hex,     
    output reg [6:0] o_seg   
);

always @(*) begin
    case (i_hex)
        4'h0: o_seg = 7'b0000001;
        4'h1: o_seg = 7'b1001111;
        4'h2: o_seg = 7'b0010010;
        4'h3: o_seg = 7'b0000110;
        4'h4: o_seg = 7'b1001100;
        4'h5: o_seg = 7'b0100100;
        4'h6: o_seg = 7'b0100000;
        4'h7: o_seg = 7'b0001111;
        4'h8: o_seg = 7'b0000000;
        4'h9: o_seg = 7'b0000100;
        4'hA: o_seg = 7'b0001000;
        4'hB: o_seg = 7'b1100000;
        4'hC: o_seg = 7'b0110001;
        4'hD: o_seg = 7'b1000010;
        4'hE: o_seg = 7'b0110000;
        4'hF: o_seg = 7'b0111000;
        default: o_seg = 7'b1111111;  // all off
    endcase
end

endmodule
