`timescale 1ns / 1ps

module tb_uart_top ();
    
    parameter BAUD_TICK = (100_000_000 / 9600) * 10;
    reg clk,reset,btn_R;
    wire tx;

    uart_controller dut (
        .clk(clk),
        .reset(reset),
        .btn_R(btn_R),
        .tx(tx)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        btn_R = 0;
        #20;
        reset = 0;

        #1000;
        btn_R = 1;
        #(BAUD_TICK * 10);
        #10
        btn_R = 0;
        #300;

        $stop;
    end
endmodule
