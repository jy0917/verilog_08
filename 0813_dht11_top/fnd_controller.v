`timescale 1ns / 1ps


module fnd_controller (
    input clk,
    input reset,
    input [7:0] fnd_in,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    //    assign fnd_com = 4'b1110;
    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [3:0] bcd;
    wire [1:0] w_digit_sel;
    wire w_1khz;
    wire w_50mhz, w_25mhz, w_16mhz, w_8mhz;

    clk_div_2 U_CLK_DIV2 (
        .clk(clk),
        .reset(reset),
        .o_50mhz(w_50mhz)
    );
    clk_div_4 U_CLK_DIV4 (
        .clk(clk),
        .reset(reset),
        .o_25mhz(w_25mhz)
    );
    clk_div_6 U_CLK_DIV6 (
        .clk(clk),
        .reset(reset),
        .o_16mhz(w_16mhz)
    );
    clk_div_12 U_CLK_DIV12 (
        .clk(clk),
        .reset(reset),
        .o_8mhz(w_8mhz)
    );
    clk_div U_CLK_DIV (
        .clk(clk),
        .reset(reset),
        .o_1khz(w_1khz)
    );
    counter_4 U_COUNTER_4 (
        .clk(w_1khz),
        .reset(reset),
        .digit_sel(w_digit_sel)
    );

    decoder_2x4 U_DECODER_2x4 (
        .digit_sel(w_digit_sel),
        .fnd_com  (fnd_com)
    );

    digit_splitter U_DS (
        .seg_data(fnd_in),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );
    mux_4x1 U_MUX_4x1 (
        .sel(w_digit_sel),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000),
        .mux_out(bcd)
    );

    bcd U_BCD (
        .bcd_in (bcd),
        .bcd_out(fnd_data)
    );

endmodule


module clk_div_2 (
    input  clk,
    input  reset,
    output o_50mhz
);
    reg [1:0] counter_reg = 0;
    reg clk_reg = 0;

    assign o_50mhz = clk_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            clk_reg <= 1'b0;
        end else begin
            if (counter_reg == 0) begin
                counter_reg <= 0;
                clk_reg <= ~clk_reg;
            end else begin
                counter_reg <= counter_reg + 1;
            end
        end
    end
endmodule

module clk_div_4 (
    input  clk,
    input  reset,
    output o_25mhz
);
    reg [1:0] counter_reg = 0;
    reg clk_reg =0;

    assign o_25mhz = clk_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            clk_reg <= 1'b0;
        end else begin
            if (counter_reg == 1) begin
                counter_reg <= 0;
                clk_reg <= ~clk_reg;
            end else begin
                counter_reg <= counter_reg + 1;
            end
        end
    end
endmodule

module clk_div_6 (
    input  clk,
    input  reset,
    output o_16mhz
);
    reg [2:0] counter_reg = 0;
    reg clk_reg = 0;

    assign o_16mhz = clk_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            clk_reg <= 1'b0;
        end else begin
            if (counter_reg == 2) begin
                counter_reg <= 0;
                clk_reg <= ~clk_reg;
            end else begin
                counter_reg <= counter_reg + 1;
            end
        end
    end
endmodule

module clk_div_12 (
    input  clk,
    input  reset,
    output o_8mhz
);
    reg [5:0] counter_reg = 0;
    reg clk_reg = 0;

    assign o_8mhz = clk_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            clk_reg <= 1'b0;
        end else begin
            if (counter_reg == 5) begin
                counter_reg <= 0;
                clk_reg <= ~clk_reg;
            end else begin
                counter_reg <= counter_reg + 1;
            end
            if (counter_reg < 4) begin
                clk_reg <= 1'b1;
            end else begin
                clk_reg <= 1'b0;
            end
        end
    end
endmodule

module clk_div (
    input  clk,
    input  reset,
    output o_1khz
);
    reg [15:0] counter_reg;
    reg clk_reg;

    assign o_1khz = clk_reg;

    //sequantial logic
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            clk_reg <= 1'b0;
        end else begin
            //operation
            counter_reg <= counter_reg + 1;
            if (counter_reg == (50000 - 1)) begin
                counter_reg <= 0;
                clk_reg <= ~clk_reg;
            end
        end
    end

endmodule

module counter_4 (
    input clk,
    input reset,
    output [1:0] digit_sel
);

    reg [1:0] counter_reg;

    assign digit_sel = counter_reg;

    // sequential logic : SL
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
        end else begin
            //operation
            counter_reg <= counter_reg + 1;
        end
    end

endmodule

module decoder_2x4 (
    input [1:0] digit_sel,
    output reg [3:0] fnd_com
);
    always @(digit_sel) begin
        case (digit_sel)
            2'b00:   fnd_com = 4'b1110;  //digit_1
            2'b01:   fnd_com = 4'b1101;  //digit_10
            2'b10:   fnd_com = 4'b1011;  //digit_100
            2'b11:   fnd_com = 4'b0111;  //digit_1000
            default: fnd_com = 4'b1110;  //default 
        endcase
    end
endmodule

module digit_splitter (
    input  [7:0] seg_data,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);
    assign digit_1 = seg_data % 10;
    assign digit_10 = (seg_data / 10) % 10;
    assign digit_100 = (seg_data / 100) % 10;
    assign digit_1000 = (seg_data / 1000) % 10;

endmodule

module mux_4x1 (
    input [1:0] sel,  //mux selection
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    output [3:0] mux_out
);
    assign mux_out = (sel == 2'b00) ? digit_1 :
                     (sel == 2'b01) ? digit_10 :
                     (sel == 2'b10) ? digit_100 : digit_1000;

endmodule

module bcd (
    input [3:0] bcd_in,
    output reg [7:0] bcd_out
);

    always @(bcd_in) begin
        case (bcd_in)
            4'b0000: bcd_out = 8'hc0;
            4'b0001: bcd_out = 8'hf9;
            4'b0010: bcd_out = 8'ha4;
            4'b0011: bcd_out = 8'hb0;
            4'b0100: bcd_out = 8'h99;
            4'b0101: bcd_out = 8'h92;
            4'b0110: bcd_out = 8'h82;
            4'b0111: bcd_out = 8'hf8;
            4'b1000: bcd_out = 8'h80;
            4'b1001: bcd_out = 8'h90;
            4'b1010: bcd_out = 8'h88;  //a
            4'b1011: bcd_out = 8'h83;  //b
            4'b1100: bcd_out = 8'hc6;  //c
            4'b1101: bcd_out = 8'ha1;  //d
            4'b1110: bcd_out = 8'h86;  //e
            4'b1111: bcd_out = 8'h8e;  //f
        endcase
    end
endmodule
