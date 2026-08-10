`timescale 1ns / 1ps


module tb_fifo ();

    reg clk, reset, push, pop;
    reg  [7:0] wdata;
    wire [7:0] rdata;
    wire full, empty;

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

    task FIFO_WRITE(input [7:0] send_data);
        begin
            @(negedge clk);
            push  = 1;
            wdata = send_data;
        end
    endtask

    task FIFO_READ();
        begin
            @(negedge clk);
            pop = 1;
        end
    endtask

    task FIFO_WRITE_READ(input [7:0] send_data);
        begin
            @(negedge clk);
            push  = 1;
            pop   = 1;
            wdata = send_data;
        end
    endtask

    initial begin
        clk   = 0;
        reset = 1;
        push  = 0;
        pop   = 0;
        wdata = 8'h00;
        #10;
        reset = 0;

        //push 5번
        FIFO_WRITE(8'h0a);
        FIFO_WRITE(8'h0b);
        FIFO_WRITE(8'h0c);
        FIFO_WRITE(8'h0d);
        FIFO_WRITE(8'h0e);

        @(negedge clk);
        push = 0;
        #10;

        //pop 5번
        FIFO_READ();
        FIFO_READ();
        FIFO_READ();
        FIFO_READ();
        FIFO_READ();

        @(negedge clk);
        pop = 0;
        #10;

        //push,pop 동시에 8번
        FIFO_WRITE_READ(8'h0);
        FIFO_WRITE_READ(8'h1);
        FIFO_WRITE_READ(8'h2);
        FIFO_WRITE_READ(8'h3);
        FIFO_WRITE_READ(8'h4);
        FIFO_WRITE_READ(8'h5);
        FIFO_WRITE_READ(8'h6);
        FIFO_WRITE_READ(8'h7);
        FIFO_WRITE_READ(8'h8);

        //pop 1번
        @(negedge clk);
        push = 0;
        #10;


    end
endmodule
