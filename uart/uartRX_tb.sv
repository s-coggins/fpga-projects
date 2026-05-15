//uart RX testbench

`timescale 1ns / 1ps
module uartRX_tb();

	parameter fpga_clk = 50000000;
	parameter baud_rate = 115200;
	parameter baud_tick = fpga_clk/baud_rate;
	parameter data_width = 8;
	parameter clk_period_ns = 20;
	parameter uart_wait = baud_tick * clk_period_ns;
	//test ASCII 'A' 0x41 or 8'b0100 0001
	parameter EMPTY 	= 8'b0000_0000;
	parameter ASCII_A = 8'b0100_0001;
	
	
	reg r_rxData = 1;
	reg r_clk = 0;
	wire [data_width-1:0] w_rxDataByte;
	wire w_rxDV;
	
	uartRX #(.DATA_WIDTH(data_width), .BAUD_TICK(baud_tick)) RX1
	(
		.i_rxData(r_rxData),
		.i_clk(r_clk),
		.o_rxDataByte(w_rxDataByte),
		.o_rxDV(w_rxDV)
	);
	
	//simulate UART data bus
	task set_rxData(input reg[7:0] rxData);
		r_rxData <= 1'b0; //start bit
		#uart_wait;
		r_rxData <= rxData[0]; //data: lsb to msb
		#(baud_tick * clk_period_ns);
		r_rxData <= rxData[1];
		#uart_wait;
		r_rxData <= rxData[2];
		#uart_wait;
		r_rxData <= rxData[3];
		#uart_wait;
		r_rxData <= rxData[4];
		#uart_wait;
		r_rxData <= rxData[5];
		#uart_wait;
		r_rxData <= rxData[6];
		#uart_wait;
		r_rxData <= rxData[7];
		#uart_wait;
		r_rxData <= 1'b1; //stop bit
		#uart_wait;
	endtask
	
	//clock toggles every half period
	always #(clk_period_ns/2) r_clk = !r_clk;
	
	
	initial 
		begin
			$display("Initial: %b", w_rxDV);
			r_rxData <= 1;
			#uart_wait;
			assert (w_rxDV == 1'b0);
			assert (w_rxDataByte == EMPTY);
			$display("Initial After: %b", w_rxDV);
			set_rxData(ASCII_A);
			// Wait for the pulse to actually happen
			assert (w_rxDV == 1'b1);
			$display("Before: %b", w_rxDV);
			#uart_wait;
			assert (w_rxDV == 1'b1);
			$display("After: %b", w_rxDV);
			assert (w_rxDataByte == ASCII_A);
			#uart_wait;
			assert (w_rxDV == 1'b0);
			// Check that the data was received
			if (w_rxDataByte == ASCII_A)
			  $display("Test Passed - Correct Byte Received");
			else
			  $display("Test Failed - Incorrect Byte Received");
			  $display("HEX: %h", w_rxDataByte);
			  $display("BIN: %b", w_rxDataByte);
			  $display("ASCII: %c", w_rxDataByte);
		
		end
	
endmodule