`timescale 1ns / 1ps

module tb_baud_tick ();

//내가 설계한 거 
    reg  clk;
    reg  reset;
    wire o_baud_tick;

    
    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #10 reset = 0;
        #(1_000_000 * 10);
        $stop;
    end
endmodule
