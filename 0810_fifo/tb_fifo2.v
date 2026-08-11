`timescale 1ns / 1ps


module tb_fifo2 ();

    parameter WIDTH = 3;

    reg clk, reset, push, pop;
    reg  [7:0] wdata;
    wire [7:0] rdata;
    wire full, empty;
    integer i = 0;
    //for random simulation
    reg [7:0] compare_buffer[0:(2**WIDTH)-1];
    reg [WIDTH-1:0] push_cnt;
    reg [WIDTH-1:0] pop_cnt;
    integer pass_count = 0, fail_count = 0;

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
        pop = 0;
        #10;

        $display("%t : RANDOM TEST start", $time);
        push_cnt = 0;
        pop_cnt  = 0;
        // @(negedge clk);


        //empty state
        for (i = 0; i < 256; i = i + 1) begin
            //for문 내부로 옮겨 동기식 업데이트 반복
            //drive
            @(posedge clk);
            #1;
            //push,pop 는 1과 0으로 두 가지 경우의 수니까
            push  = $random % 2;
            pop   = $random % 2;
            //wdata는 최대 256까지 가질 수 있으니까
            wdata = $random % 256;
            //display 위에 있어서 strobe 사용
            $display("%t : push = %d, pop = %d, wdata = %d", $time, push, pop,
                     wdata);

            //negedge에 판단하기 위해
            //monitor , scoreboard
            @(negedge clk);
            if (!full & push) begin
                compare_buffer[push_cnt] = wdata;
                $display("%t : compare_buffer = %d, push = %d", $time,
                         compare_buffer[push_cnt], push);
                push_cnt = push_cnt + 1;
            end
            if (!empty & pop) begin
                if (compare_buffer[pop_cnt] == rdata) begin
                    $display(
                        "%t : PASS !! compare_data = %d, rdata = %d, pop= %d, empty = %d",
                        $time, compare_buffer[pop_cnt], rdata, pop, empty);
                    pass_count = pass_count + 1;
                end else begin
                    $display(
                        "%t : FAIL !! compare_data = %d, rdata = %d, pop= %d, empty = %d",
                        $time, compare_buffer[pop_cnt], rdata, pop, empty);
                    fail_count = fail_count + 1;
                end
                if(push_cnt == 3'd4) begin
                    if(full == 1'b1) begin
                        $display(
                        "%t : PASS !! compare_data = %d, rdata = %d, pop= %d, empty = %d",
                        $time, compare_buffer[pop_cnt], rdata, pop, empty);
                    pass_count = pass_count + 1;
                    end
                end else begin
                    $display(
                        "%t : FAIL !! compare_data = %d, rdata = %d, pop= %d, empty = %d",
                        $time, compare_buffer[pop_cnt], rdata, pop, empty);
                    fail_count = fail_count + 1;
                end


                pop_cnt = pop_cnt + 1;
            end
            // #10;
            //negedge 로 판단을 바꿨기 때문에
        end
        $display("%t: pass count = %d, fail_count = %d", $time, pass_count,
                 fail_count);
        #100;
        $stop;
    end


endmodule
