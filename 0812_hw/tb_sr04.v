`timescale 1ns / 1ps

module tb_sr04 ();

    reg clk, reset, start, echo;
    wire trigger, done;
    wire [8:0] distance;

    sr04_controller dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .echo(echo),
        .trigger(trigger),
        .done(done),
        .distance(distance)
    );

    always #5 clk = ~clk;

    // integer i;
    // integer test[0:1];

    initial begin
        clk   = 0;
        reset = 1;
        start = 0;
        echo  = 0;
        #10;
        reset = 0;

        @(negedge clk);
        start = 1;
        #10;
        start = 0;


        // trigger가 Low로 떨어질 때까지 대기 (START→WAIT 전환 확인)
        @(negedge trigger);
        #200_000;

        // echo=1 -> 10cm*58=580us 동안 High
        echo = 1;
        #580_000;

        // echo=0 -> COUNT 종료, DISTANCE 진입
        echo = 0;
        #580_000;

        // 두 번째 측정 사이클도 정상 동작하는지 (IDLE 복귀 후 재시작 확인)
        start = 1;
        #10;
        start = 0;
        @(negedge trigger);
        #200_000;
        echo = 1;
        #580_000;
        echo = 0;
        #580_000;
        $stop;

        // test[0] = 30;
        // test[1] = 50;

        // clk   = 0;
        // reset = 1;
        // start = 0;
        // echo  = 0;
        // #10;
        // reset = 0;

        // for (i=0; i<2; i=i+1)begin
        //     start = 1;
        //     #10;
        //     start = 0;
        //     @(negedge trigger);
        //     #200_000;
        //     echo = 1;
        //     #(test[i] * 58 * 1000)
        //     echo = 0;
        //     #580_000;
        // end
        //     $stop;
        // end

    end
endmodule
