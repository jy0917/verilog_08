`timescale 1ns / 1ps

module tb_uart_top ();
    
    reg clk,reset,btn_R;
    wire tx;
    
    uart_controller dut (
        .clk(clk),
        .reset(reset),
        .btn_R(btn_R),
        .tx(tx)
    );
endmodule
