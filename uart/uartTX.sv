/*

assumes no parity bit, allows variable data width (5-9), baud rate, fpga clock, but fixed start/stop width (1)

requires user to calculate baud_tick (clocks per bit):
BAUD_TICK = FPGA_CLK / BAUD_RATE
Example: 50 MHz FPGA CLK, 115200 Baud rate
BAUD_TICK = 50000000 / 115200 = 434
*/
module uartTX #(parameter DATA_WIDTH = 8, BAUD_TICK = 434)
	(
	input 						i_clk,
	input 						i_txDV,
	input [DATA_WIDTH-1:0] 	i_txByte,
	output 						o_txDone,
	output 						o_txActive,
	output reg					o_txBit
	);
	
	
	//implement a 4 state FSM; IDLE, START, DATA, STOP
	localparam s_IDLE 	= 3'b000;
	localparam s_START 	= 3'b001;
	localparam s_DATA 	= 3'b010;
	localparam s_STOP 	= 3'b011;
	localparam s_RESET 	= 3'b100;
	
	
	
	reg r_txBit 										= 1'b1;
	reg r_txDone										= 1'b0;
	reg r_txActive										= 1'b0;
	reg [2:0] 							r_currState = s_IDLE;
	reg [DATA_WIDTH-1:0] 			r_txByte 	= 0;
	reg [$clog2(BAUD_TICK)-1:0] 	r_clkCount	= 0;
	reg [$clog2(DATA_WIDTH)-1:0] 	r_bitIndex 	= 0;
	
	
	//1 always (modern approach) FSM to handle Uart Tx
	always @(posedge i_clk)
	begin
		case(r_currState)
			s_IDLE: //transmit 1 while inactive
				begin
					o_txBit 		<= 1'b1;
					r_txDone 	<= 1'b0;
					r_clkCount 	<= 1'b0;
					r_bitIndex 	<= 1'b0;
					
					if(i_txDV == 1'b1) //if there is data to be loaded
						begin
								r_currState <= s_START;
								r_txByte 	<= i_txByte;//load data bus
								r_txActive 	<= 1'b1;
						end
					else
						r_currState <= s_IDLE;
				end //case IDLE
			
			s_START: //send start bit (low/0)
				begin
					o_txBit <= 1'b0;
					
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
					o_txBit <= r_txByte[r_bitIndex];
					
					if (r_clkCount < (BAUD_TICK-1))
						begin
							r_clkCount 	<= r_clkCount + 1;
							r_currState <= s_DATA;
						end
					else 
						begin
							r_clkCount 	<= 0;
							
							if (r_bitIndex < (DATA_WIDTH-1))
								begin
									r_bitIndex 	<= r_bitIndex + 1;
									r_currState <= s_DATA;
								end
							else
								begin
									r_bitIndex 	<= 0;
									r_currState <= s_STOP;
								end
						end
				end //case DATA
			
			s_STOP: //wait out stop bit
				begin
					o_txBit <= 1'b1;
					
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
	
	assign o_txActive = r_txActive;
	assign o_txDone 	= r_txDone;
	
endmodule