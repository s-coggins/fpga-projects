/*
Title: 	 UART TX
Author: 	 Sean Coggins
Date: 	 7/3/2026
Version:  1.1
Platform: Terasic DE10-Lite (Intel MAX 10)

Change Log:
*v1.1 [7/3/26] 
-Creation of header block
-Added more comments per interview feedback
--------------------------------------------------

FUNCTION:

-UART transmission logic module
--------------------------------------------------

INPUTS:

i_clk: 		Desired clock input to determine baud_tick
i_txDV: 		Data valid flag; Data ready to be transmitted
i_txByte:	UART data packet to be transmitted

--------------------------------------------------

OUTPUTS:

o_txDone: 	Done transmitting data flag
o_txActive:	Actively transmitting data flag
o_txBit:		1-bit transmitted at a time from i_txByte
-------------------------------------------------- 

*NOTES:

-Assumes no parity bit
-Accepts 5 to 9-bit data width; 1-bit start/stop bit
-Requires user to calculate baud_tick / clocks per bit
-Default baud_tick parameter configured for 50 MHz clock
-BAUD_TICK:
	BAUD_TICK = FPGA_CLK / BAUD_RATE
	Example: 50 MHz FPGA CLK, 115200 Baud rate
	BAUD_TICK = 50000000 / 115200 = 434
	
-$clog2: minimum bits to represent value, auto-sizes counter widths
--------------------------------------------------
*/

module uartTX #(parameter DATA_WIDTH = 8, BAUD_TICK = 434)
	(
	input 						i_clk,
	input 						i_txDV,
	input [DATA_WIDTH-1:0] 	i_txByte,
	output 						o_txDone,
	output 						o_txActive,
	output 						o_txBit
	);
	
	
	//implement a 5 state FSM; IDLE, START, DATA, STOP, RESET
	localparam s_IDLE 	= 3'b000;
	localparam s_START 	= 3'b001;
	localparam s_DATA 	= 3'b010;
	localparam s_STOP 	= 3'b011;
	localparam s_RESET 	= 3'b100;
	
	
	
	reg r_txBit 										= 1'b1; //transmit 1-bit per BAUD_TICK
	reg r_txDone										= 1'b0; //transmission completion flag
	reg r_txActive										= 1'b0; //transmission active flag
	reg [2:0] 							r_currState = s_IDLE; //initialize in IDLE state
	reg [DATA_WIDTH-1:0] 			r_txByte 	= 0; //txByte supports 5-9 data bits (per UART standards)
	reg [$clog2(BAUD_TICK)-1:0] 	r_clkCount	= 0; 
	reg [$clog2(DATA_WIDTH)-1:0] 	r_bitIndex 	= 0;
	
	
	//1 always (modern approach) FSM to handle Uart Tx
	always @(posedge i_clk)
	begin
		case(r_currState)
			s_IDLE: //transmit HIGH (1) while inactive
				begin
					r_txBit 		<= 1'b1;
					r_txDone 	<= 1'b0;
					r_clkCount 	<= 1'b0;
					r_bitIndex 	<= 1'b0;
					
					if(i_txDV == 1'b1) //if there is data to be loaded
						begin
								r_currState <= s_START;
								r_txByte 	<= i_txByte;//load data bus
								r_txActive 	<= 1'b1;	//transmitting
						end
					else
						r_currState <= s_IDLE;
				end //case IDLE
			
			s_START: //send start bit LOW (0)
				begin
					r_txBit <= 1'b0;
					
					if (r_clkCount < (BAUD_TICK-1))
						begin
							r_clkCount 	<= r_clkCount + 1;
							r_currState <= s_START;	
						end
					else
						begin
								r_clkCount 	<= 0; 
								r_currState <= s_DATA;
						end
				end //case START
			
			s_DATA: //transmit r_txByte LSB to MSB, 1 bit per BAUD_TICK
				begin
					//transmit current bit
					r_txBit <= r_txByte[r_bitIndex];
					//wait 1 BAUD_TICK cycle
					if (r_clkCount < (BAUD_TICK-1))
						begin
							r_clkCount 	<= r_clkCount + 1;
							r_currState <= s_DATA;
						end
					//after 1 cycle
					else 
						begin
							//move on to next bit; reset cycle
							r_clkCount 	<= 0;
							
							if (r_bitIndex < (DATA_WIDTH-1))
								begin
									r_bitIndex 	<= r_bitIndex + 1;
									r_currState <= s_DATA;
								end
							//once all bits are transmitted, move to STOP state
							else
								begin
									r_bitIndex 	<= 0;
									r_currState <= s_STOP;
								end
						end
				end //case DATA
			
			s_STOP: //wait out stop bit
				begin
					r_txBit <= 1'b1;
					
					if (r_clkCount < (BAUD_TICK-1))
						begin
							r_clkCount 	<= r_clkCount + 1;
							r_currState <= s_STOP;
						end
					else
						begin
							r_txDone 	<= 1'b1;
							r_clkCount 	<= 0;
							r_currState <= s_RESET;
							r_txActive 	<= 1'b0;
						end
				end //case STOP
			
			s_RESET: //reset after 1 clk cycle
				begin
					r_currState <= s_IDLE;
					r_txDone 	<= 1'b1;
				end //case RESET
			
			default: r_currState <= s_IDLE;
		
		endcase
		
	end
	
	assign o_txBit 	= r_txBit;
	assign o_txActive = r_txActive;
	assign o_txDone 	= r_txDone;
	
endmodule