`timescale 1ns / 1ps

module tb_uart ();

    //(system freq/baud rate)*clock period
    //1hz=10nsec
    parameter BAUD_TICK = (100_000_000 / 9600) * 10;
    reg clk, reset,btn_R;
    wire o_baud_tick;
    
    wire w_baud_tick;
    wire w_tx_start;

    btn_debouncer U_BD_UART_TX_START (
        .clk(clk),
        .reset(reset),
        .i_btn(btn_R),
        .o_btn(w_tx_start)
    );

    uart_tx U_UART_TX (
        .clk(clk),
        .reset(reset),
        .tx_start(w_tx_start),
        .tx_data(8'h30),
        .i_baud_tick(w_baud_tick),
        .tx(tx)

    );
    baud_tick U_BAUD_TICK (
        .clk(clk),
        .reset(reset),
        .o_baud_tick(w_baud_tick)
    );

    baud_tick dut (
        .clk(clk),
        .reset(reset),
        .o_baud_tick(o_baud_tick)
    );

    //freq = 100Mhz
    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        btn_R = 0;
        #10;
        reset = 0;
        
        #(BAUD_TICK * 10);
        btn_R = 1;
        #(BAUD_TICK * 10);
        #10
        btn_R = 0;
        #100;
        $stop;

    end
endmodule
