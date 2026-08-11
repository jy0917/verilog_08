`timescale 1ns / 1ps


module tb_fifo2 ();

    reg clk, reset, push, pop;
    reg  [7:0] wdata;
    wire [7:0] rdata;
    wire full, empty;
    integer i;

    fifo #(
        .WIDTH(2)
    ) dut (
        .clk  (clk),
        .reset(reset),
        .push (push),
        .pop  (pop),
        .wdata(wdata),  //push data
        .rdata(rdata),  //pop data
        .full (full),
        .empty(empty)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        push  = 0;
        pop   = 0;
        #10;
        reset = 0;

        //push only push = 1, pop = 0
        @(negedge clk);
        push  = 1;
        wdata = 8'h0a;
        #10;
        push  = 1;
        wdata = 8'h0b;
        #10;
        push  = 1;
        wdata = 8'h0c;
        #10;
        push  = 1;
        wdata = 8'h0d;
        #10;
        push  = 1;
        wdata = 8'h0e;
        #10;
        push = 0;

        //pop only pop= 1, push = 1
        @(negedge clk);
        pop = 1;
        #10;
        #10;
        #10;
        #10;
        #10;
        pop = 0;

        #10;
        //push = 1, pop = 1
        push  = 1;
        wdata = 8'h0f;
        #10;
        for (i = 0; i < 8; i = i + 1) begin
            push  = 1;
            pop   = 1;
            wdata = i;
            #10;

        end
        push = 0;
        pop  = 1;
        #10;

        #100;
        $stop;

    end
endmodule
