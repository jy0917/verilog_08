`timescale 1ns / 1ps

module top_dht11 (
    input clk,
    input reset,
    input btn_L,  //start
    input btn_R,  //온도 습도 전환
    inout dht11_io,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    wire w_btn_start;
    wire [15:0] w_humidity, w_temperature;
    wire w_done, w_valid;
    //지금 온도인지 습도인지
    reg sel_reg;
    wire w_btn_toggle_raw, w_btn_toggle_pulse;
    //reset이면 온도(0), 버튼 누를 때마다 토글
    always@(posedge clk, posedge reset) begin
        if(reset) begin
            sel_reg <= 0;
        end else begin
            if(w_btn_toggle_pulse) begin
                sel_reg <= ~sel_reg;
            end
        end
    end

    dht11 U_DHT11 (
        .clk(clk),
        .reset(reset),
        .start(w_btn_start),
        .humidity(w_humidity),
        .temperature(w_temperature),
        .done(w_done),
        .valid(w_valid),
        .dht11_io(dht11_io)
    );

    fnd_controller U_FND_CNTL (
        .clk(clk),
        .reset(reset),
        .fnd_in(sel_reg ? w_humidity[15:8] : w_temperature[15:8]),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    btn_debounce U_BTN_L (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_L),
        .o_btn(w_btn_start)
    );

    btn_debounce U_BTN_R (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_R),
        .o_btn(w_btn_toggle_raw)
    );

    edge_detector U_EDGE_DETECTOR (
        .clk(clk),
        .reset(reset),
        .i_signal(w_btn_toggle_raw),
        .o_pulse(w_btn_toggle_pulse)
    );

endmodule
