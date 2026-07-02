`timescale 1ns / 1ps   // 1 ns time unit, 1 ps precision

module tb_fd;

    reg clk;
    wire clk_enable;

    // Instantiate divider
    fd uut (
        .i_clk_50MHz(clk),
        .o_clk_enable(clk_enable)
    );

    // Generate a 50 MHz clock (20 ns period)
    always #10 clk = ~clk;   // toggles every 10 ns → 50 MHz

    initial begin
        $dumpfile("fd_tb.vcd");   // for GTKWave or viewing waveforms
        $dumpvars(0, tb_fd);
        clk = 0;

        // Run long enough to see several output toggles
        #100000;   // (enough for several 100kHz cycles)
        $stop;
    end

endmodule
