`timescale 1ns / 1ps

module tb_top_dht11 ();

    reg clk, reset, btn_L, btn_R;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    wire dht11_io;
    reg dht_drive, dht_val;

    reg [39:0] test_data;

    assign dht11_io = dht_drive ? dht_val : 1'bz;

    top_dht11 U_TOP_DHT11 (
        .clk(clk),
        .reset(reset),
        .btn_L(btn_L),  //start
        .btn_R(btn_R),  //온도 습도 전환
        .dht11_io(dht11_io),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    always #5 clk = ~clk;

    integer i;
    
    initial begin
        test_data = {8'd50, 8'd0, 8'd25, 8'd0, 8'd75};
        clk = 0;
        reset = 1;
        btn_L = 0;
        btn_R = 0;
        dht_drive = 0;
        dht_val = 0;
        #10;
        reset = 0;

        btn_L = 1;
        #10_000;
        btn_L = 0;
        //start
        #19_000_000;
        //wait
        #30_000;
        dht_drive = 1;
        //sync
        dht_val = 0;
        //low
        #80_000;
        //high
        dht_val = 1;
        #80_000;
        //data
        for(i=39;i>=0;i=i-1) begin
            dht_val = 0;
            #50_000;
            dht_val = 1;
            #(test_data[i] ? 70_000 : 26_000);
        end
        dht_val = 0;
    end
endmodule
