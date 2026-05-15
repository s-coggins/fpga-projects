/*

assumes no parity bit, allows variable data width (5-9), baud rate, fpga clock, but fixed start/stop width (1)

requires user to calculate baud_tick (clocks per bit):
BAUD_TICK = FPGA_CLK / BAUD_RATE
Example: 50 MHz FPGA CLK, 115200 Baud rate
BAUD_TICK = 50000000 / 115200 = 434
*/
module uartRX #(parameter DATA_WIDTH = 8, BAUD_TICK = 434)
	(
	input 						i_rxData,
	input 						i_clk,
	output [DATA_WIDTH-1:0] o_rxDataByte,
	output 						o_rxDV
	);
	
	//start bit high to low for 1 cycle triggers data
	
	//implement a 4 state FSM; IDLE, START, DATA, STOP
	localparam s_IDLE 	= 3'b000;
	localparam s_START 	= 3'b001;
	localparam s_DATA 	= 3'b010;
	localparam s_STOP 	= 3'b011;
	localparam s_RESET 	= 3'b100;
	
	
	
	reg r_rxData_r 									= 1'b1;	
	reg r_rxData 										= 1'b1;
	reg r_rxDV											= 1'b0;
	reg [2:0] 							r_currState = s_IDLE;
	reg [DATA_WIDTH-1:0] 			r_rxByte 	= 0;
	reg [$clog2(BAUD_TICK)-1:0] 	r_clkCount	= 0;
	reg [$clog2(DATA_WIDTH)-1:0] 	r_bitIndex 	= 0;
	
	
	//double register to remove metastability
	always @(posedge i_clk)
	begin
		r_rxData_r <= i_rxData;
		r_rxData	  <= r_rxData_r;
	end
	
	//1 always (modern approach) FSM to handle Uart Rx
	always @(posedge i_clk)
	begin
		case(r_currState)
			s_IDLE: //wait for high to low start bit to signal packet transmission
				begin
					r_rxDV 		<= 1'b0;
					r_clkCount 	<= 1'b0;
					r_bitIndex 	<= 1'b0;
					
					if(r_rxData == 1'b0)
						r_currState <= s_START;
					
					else
						r_currState <= s_IDLE;
				end //case IDLE
			
			s_START: //validate start bit before accepting data
				begin
					if (r_clkCount == ((BAUD_TICK-1)/2)) //check middle of start bit
						begin
							if (r_rxData == 1'b0)
								begin
									r_clkCount 	<= 0; //reset count at middle
									r_currState <= s_DATA; //prepare to grab data byte
								end
							else
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
					else //at middle of clock cycle sample data
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