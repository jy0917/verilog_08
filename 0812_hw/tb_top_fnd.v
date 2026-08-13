`timescale 1ns / 1ps

module tb_top_sr04 ();

    reg clk, reset, btn_R, echo;
    wire trigger;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

    top_sr04 U_TOP_SR04 (
        .clk(clk),
        .reset(reset),
        .btn_R(btn_R),
        .echo(echo),
        .trigger(trigger),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        btn_R = 0;
        echo  = 0;
        #10;
        reset = 0;

        @(negedge clk);
        btn_R = 1;
        #10_000;
        btn_R = 0;

         // trigger가 Low로 떨어질 때까지 대기 (START→WAIT 전환 확인)
        @(negedge trigger);
        #200_000;

        // echo=1 -> 10cm*58=580us 동안 High
        echo = 1;
        #(58*10*1000);
        echo = 0;

        #580_000;

         @(negedge clk);
        btn_R = 1;
        #10_000;
        btn_R = 0;

         // trigger가 Low로 떨어질 때까지 대기 (START→WAIT 전환 확인)
        @(negedge trigger);
        #200_000;

        // echo=1 -> 10cm*58=580us 동안 High
        echo = 1;
        #(58*40*1000);
        echo = 0;
        #580_000;
        $stop;
    end
endmodule
