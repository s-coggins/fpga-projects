//uart loopback testbench

`timescale 1ns / 1ps
module uart_tb();

	//50 MHz clock, baud rate of 115200
	//baud tick of 434 (clock/baud rate)
	parameter c_FPGA_CLK 		= 50000000;
	parameter c_BAUD_RATE 		= 115200;
	parameter c_BAUD_TICK 		= c_FPGA_CLK/c_BAUD_RATE;
	parameter c_DATA_WIDTH 		= 8;
	parameter c_CLK_PERIOD_NS 	= 20;
	parameter c_UART_WAIT 		= c_BAUD_TICK * c_CLK_PERIOD_NS;
	
	//test ASCII 'A' (0x41)
	parameter c_ASCII_A 	= 8'h41;
	parameter c_ASCII_Z 	= 8'h5A;
	
	reg r_clk 								= 0;	
	reg r_txDV 								= 0;
	reg [c_DATA_WIDTH-1:0] r_txByte 	= 0;
	reg r_rxBit 							= 1;
	reg [c_DATA_WIDTH-1:0] r_txCheck	= 0;
	wire w_txDone;
	wire [c_DATA_WIDTH-1:0] w_rxByte;
	wire w_txOut;
	
	
	//instantiate tx and rx
	uartTX #(.DATA_WIDTH(c_DATA_WIDTH), .BAUD_TICK(c_BAUD_TICK)) TX1
	(
		.i_clk(r_clk),
		.i_txDV(r_txDV),
		.i_txByte(r_txByte),
		.o_txDone(w_txDone),
		.o_txActive(),
		.o_txBit(w_txOut)
	);
	
	
	uartRX #(.DATA_WIDTH(c_DATA_WIDTH), .BAUD_TICK(c_BAUD_TICK)) RX1
	(
		.i_rxData(r_rxBit),
		.i_clk(r_clk),
		.o_rxDataByte(w_rxByte),
		.o_rxDV()
	);
	
	//simulate UART data bus
	task automatic UART_WRITE_BYTE(input [c_DATA_WIDTH:0] i_data);
		begin
			
			//start bit
			r_rxBit = 1'b0;
			#(c_UART_WAIT);
			//#1000;
			
			//data byte
			for (integer count = 0; count < (c_DATA_WIDTH); count = count+1)
				begin
					r_rxBit = i_data[count];
					#(c_UART_WAIT);
				end

			//stop bit
			r_rxBit = 1'b1;
			#(c_UART_WAIT);
		end
	endtask //UART_WRITE_BYTE
	
	task automatic UART_TX_PLAYBACK();
		integer count;
		begin
			for (integer count = 0; count < (c_DATA_WIDTH+2); count = count+1)
				begin
					if (count == 0)
						#(c_UART_WAIT);
					else
						begin
							r_txCheck[(c_DATA_WIDTH-1)-(count-1)] = w_txOut;
							#(c_UART_WAIT);
						end
				end
		end
	endtask
	
	
	
	//clock toggles every half period (50% DC)
	always #(c_CLK_PERIOD_NS/2) r_clk = !r_clk;
	
	//main
	initial 
		begin
			//test TX
			@(posedge r_clk);
			@(posedge r_clk);
			r_txByte = c_ASCII_A;
			r_txDV = 1'b1;
			@(posedge r_clk);
			r_txDV = 1'b0;
			UART_TX_PLAYBACK();
			@(posedge r_clk);
			if (r_txCheck == c_ASCII_A)
				$display("Test Passed - Correct Byte Sent");
			else
				begin
					$display("Test Failed - Incorrect Byte Sent");
					$display("transmitted: %b", r_txCheck);
				end

			
			//test RX
			@(posedge r_clk);
			UART_WRITE_BYTE(c_ASCII_Z);
			@(posedge r_clk);
			
			if (w_rxByte == c_ASCII_Z)
				$display("Test Passed - Correct Byte Received");
			else
				begin
					$display("Test Failed - Incorrect Byte Received");
					$display(w_rxByte);
					$display(c_ASCII_Z);
				end
		end
	
endmodule