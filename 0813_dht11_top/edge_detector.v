`timescale 1ns / 1ps

module edge_detector(
    input clk,
    input reset,
    input i_signal,
    output o_pulse
    );

    reg signal_prev;
    assign o_pulse = i_signal & ~signal_prev;

    always@(posedge clk, posedge reset) begin
        if(reset) signal_prev <= 0;
        else signal_prev <= i_signal;
    end

endmodule
