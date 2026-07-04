/*
Title: 	 UART RX
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

-UART receiver logic module
--------------------------------------------------

INPUTS:

i_rxData: 	1-bit data input to RX module
i_clk: 		Desired clock input to determine baud_tick
--------------------------------------------------

OUTPUTS:

o_rxDataByte: Full data packet received (5-9 bits)
o_rxDV: 		  Data valid bit to signal end of UART data packet
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
	
-Data sampled at middle of cycle for highest stability
-$clog2: minimum bits to represent value, auto-sizes counter widths
--------------------------------------------------
*/


module uartRX #(parameter DATA_WIDTH = 8, BAUD_TICK = 434)
	(
	input 						i_rxData,
	input 						i_clk,
	output [DATA_WIDTH-1:0] o_rxDataByte,
	output 						o_rxDV
	);
	
	
	
	//implement a 5 state FSM; IDLE, START, DATA, STOP, RESET
	localparam s_IDLE 	= 3'b000;
	localparam s_START 	= 3'b001;
	localparam s_DATA 	= 3'b010;
	localparam s_STOP 	= 3'b011;
	localparam s_RESET 	= 3'b100;
	
	
	
	reg r_rxData_r 									= 1'b1;	//raw data bit; possibly metastable
	reg r_rxData 										= 1'b1;	//non-metastable data bit
	reg r_rxDV											= 1'b0;	//data valid flag
	reg [2:0] 							r_currState = s_IDLE; //initialize in IDLE state
	reg [DATA_WIDTH-1:0] 			r_rxByte 	= 0; //rxByte supports 5-9 data bits (per UART standards)
	reg [$clog2(BAUD_TICK)-1:0] 	r_clkCount	= 0; 
	reg [$clog2(DATA_WIDTH)-1:0] 	r_bitIndex 	= 0;
	
	
	//i_rxData is asynchronous to i_clk; double register synchronizer to remove metastability
	always @(posedge i_clk)
	begin
		r_rxData_r <= i_rxData;
		r_rxData	  <= r_rxData_r;
	end
	
	//1 always (modern approach) FSM to handle UART Rx
	always @(posedge i_clk)
	begin
		case(r_currState)
			s_IDLE: //IDLE waits for high-to-low start bit to signal packet transmission
				begin
					r_rxDV 		<= 1'b0; //initialize values
					r_clkCount 	<= 1'b0;
					r_bitIndex 	<= 1'b0;
					
					if(r_rxData == 1'b0) //packet transmission, move to START state 
						r_currState <= s_START;
					
					else
						r_currState <= s_IDLE;
				end //case IDLE
			
			s_START: //validate start bit before accepting data
				begin
					if (r_clkCount == ((BAUD_TICK-1)/2)) //check middle of start bit
						begin
							if (r_rxData == 1'b0) //if true start, continue
								begin
									r_clkCount 	<= 0; //reset count at middle
									r_currState <= s_DATA; //prepare to grab data byte
								end
							else //if false start, IDLE
								r_currState <= s_IDLE;
						end
					else
						begin
							r_clkCount <= r_clkCount + 1;
							r_currState <= s_START;
						end
				end //case START
			
			s_DATA: //start valid, store data bits
				begin
					if (r_clkCount < (BAUD_TICK-1))//if less than "clock" cycle
						begin
							r_clkCount 	<= r_clkCount + 1;//increment up
							r_currState <= s_DATA;
						end
					else ////samples at middle of data bit due to start bit synchronization
						begin
							r_rxByte[r_bitIndex] 	<= r_rxData;
							r_currState 				<= s_DATA;
							r_clkCount 					<= 0;
							
							if (r_bitIndex < (DATA_WIDTH-1))//increment data bits received
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
					if (r_clkCount < (BAUD_TICK-1))
						begin
							r_clkCount 	<= r_clkCount + 1;
							r_currState <= s_STOP;
						end
					else
						begin
							r_rxDV 		<= 1'b1;
							r_clkCount 	<= 0;
							r_currState <= s_RESET;
						end
				end //case STOP
			
			s_RESET: //reset after 1 clk cycle
				begin
					r_currState <= s_IDLE;
					r_rxDV 		<= 1'b0;
				end //case RESET
			
			default: r_currState <= s_IDLE;
		
		endcase
		
	end
	
	assign o_rxDV 			= r_rxDV;
	assign o_rxDataByte 	= r_rxByte;
	
endmodule